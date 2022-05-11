/**************
*@ Class Name                                                    : FBE_TaskBL
*@ Description                                                   : This class is written for calculating SLA Timer and populating Team Assignment based on Task Type.
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 12-19-2019 [Sireesha Myla]
*@ Modification Log                                              : 07-Jan-2020
***************/ 
public with sharing class FBE_TaskBL
{
    public static string taskRecordType = System.Label.Task_Support_Request_record_type; //Getting the Task Recordtype 'Support Request' from the Custom Label
    public static string taskTypeConfig =  System.Label.Task_Type;
    public static ID supportReqrecTypeId = FBE_Utility.getSupportReqrecTypeId(taskRecordType);
    public static string taskBDRecordType = System.Label.FBE_BD_Capture_Task_Type; //Getting the Task Recordtype 'BD/Capture Task Type' from the Custom Label DEFECT 11051095
    
    Public static void onafterupd(map<id,task> newrec, map<id,task> oldrec){
        //EmailTemplate template = [SELECT id FROM EmailTemplate WHERE DeveloperName = 'Email_Team_on_status_change'];
        List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
        for(Task t : newrec.values())
        {    
            // task tas = [select FBE_Assigned_To__r.Email , createdby.email from task where id = : t.id limit 1];        
            if(t.Status != oldrec.get(t.id).Status && t.FBE_Email_Team_on_Status_Change__c == true && t.RecordTypeId != taskBDRecordType && t.RecordTypeId !=supportReqrecTypeId) //Added support request condition for story #11360120
            
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<string> emailuserset = new List<string>();
                //emailuserset.add(t.FBE_Assigned_To__c);
                emailuserset.add(t.CreatedById);
                mail.setSubject('Alert - Services Sales Activities '+ t.Task_Number__c +' Status Change');
                mail.setHtmlBody('Please be aware the Services Sales Activities Task that you either requested, or have been assigned, has had a change in status.'+'</br>'+'Please navigate to this '+ '<a href='+system.URL.getSalesforceBaseUrl().toExternalForm()+'/'+t.Id+'>'+t.Task_Number__c+'</a>'+' for more detail.');
                mail.setTargetObjectId(t.OwnerId);
                mail.setToAddresses(emailuserset);
                //mail.setTemplateId(template.Id);
                mail.setSaveAsActivity(false);
                mailsToSend.add(mail);
            }
        }
        //Send Email
        if(mailsToSend.size() > 0)
        {
            system.debug('recipient----------->>'+mailsToSend);
            Messaging.sendEmail(mailsToSend);        
        }    
    }    
    public static void populateTeamAssignment(List<Task> newRecords)
    {
        Map<String, FBE_SLA_Setting__mdt> taskTypeMeta = FBE_Utility.getSLAMetadata();        
        for(Task tsk: newRecords)
        {
            if(taskTypeMeta.get(tsk.Type) != NULL  
               && taskTypeMeta.get(tsk.Type).Public_Group__c != NULL 
               && (tsk.recordTypeId == supportReqrecTypeId ) )                      
            {
                tsk.FBE_Team_Assignment__c = taskTypeMeta.get(tsk.Type).Public_Group__c;                                 
            }
        }
    }    
    //Future Method to update Public group name and SLA timer
    //updateSLATimer(JSON.serialize(Trigger.new));
    @future 
    public static void updateSLATimer(String jsonTasks){
        List<Task> taskList = (List<Task>)Json.deserialize(jsonTasks,List<Task>.class);
        Map<ID,Task> taskMapToUpdate;
        System.debug('$$$$$$1');
        if(taskList.size() > 0){
            System.debug('$$$$$$2');
            
            Map<String, FBE_SLA_Setting__mdt> taskTypeMeta = FBE_Utility.getSLAMetadata();
            
            Map<String, Weekend__mdt> weekendsMeta = FBE_Utility.getWeekendMetadata();
            
            Map<Id, Leaves_for_Task_SLA__mdt>holidaysMap = FBE_Utility.getholidaysMetadata();
            
            Map<Integer, String> countSLAdaysMap = new Map<Integer, String>();
            countSLAdaysMap.put(5,'Monday;Tuesday;Wednesday;Thursday;Friday');
            countSLAdaysMap.put(4,'Tuesday;Wednesday;Thursday;Friday');
            countSLAdaysMap.put(3,'Wednesday;Thursday;Friday');
            countSLAdaysMap.put(2,'Thursday;Friday');
            countSLAdaysMap.put(1,'Friday');
            
            
            taskMapToUpdate = new Map<ID,Task>();
            for(task tsk : taskList){
                Time timeToSetup = Time.newInstance(14,0,0,0);
                Time tskCreatedTime = tsk.CreatedDate.time();
                String dayOfWeek = tsk.CreatedDate.format('EEEE');
                
                DateTime slaTimer ;
                DateTime taskCreatedDate = tsk.CreatedDate;
                
                // Task created time greater than 14:00 CST for 'Configuration Service'
                if( (taskTypeMeta.get(tsk.Type) != NULL) && 
                   ((tsk.recordTypeId == supportReqrecTypeId && taskTypeMeta.get(tsk.Type).MasterLabel != taskTypeConfig ) 
                    || (tskCreatedTime > timeToSetup && taskTypeMeta.get(taskTypeConfig) != NULL) )){
                        
                        if(taskTypeMeta.get(tsk.Type).SLA_Time__c != NULL && taskTypeMeta.get(tsk.Type).SLA_Time__c > 0){
                            Integer slaDays = Integer.valueOf(taskTypeMeta.get(tsk.Type).SLA_Time__c/24);
                            
                            //Verify Saturday,Sunday  
                            if(weekendsMeta.get(dayOfWeek)!= NULL )
                            {
                                DateTime addDay = taskCreatedDate + weekendsMeta.get(dayOfWeek).Days_to_Skip__c; //Skip the days fri+3, sat+2,sun+1
                                slaTimer = addDay + taskTypeMeta.get(tsk.Type).SLA_Time__c/24; // Add SLA time to the Task CreatedDate
                            }
                            
                            else if(!countSLAdaysMap.isEmpty() && countSLAdaysMap.get(slaDays)!=null && countSLAdaysMap.get(slaDays).contains(dayOfWeek))
                            {
                                slaTimer = taskCreatedDate + slaDays + 2;
                            }
                            else if(!weekendsMeta.containsKey(dayOfWeek) )
                            {
                                slaTimer = taskCreatedDate + taskTypeMeta.get(tsk.Type).SLA_Time__c/24;
                            }
                            
                        }
                        
                    }
                
                else if(tsk.recordTypeId == supportReqrecTypeId && tskCreatedTime < timeToSetup && taskTypeMeta.get(taskTypeConfig)!= NULL )
                {
                    if(weekendsMeta.get(dayOfWeek)!= NULL)
                    {
                        DateTime addDay = taskCreatedDate + weekendsMeta.get(dayOfWeek).Days_to_Skip__c; //Skip the days fri+3, sat+2,sun+1
                        slaTimer = addDay; // Add SLA time to the Task CreatedDate
                        slaTimer  = slaTimer.addHours(12);
                    }
                    else if(!weekendsMeta.containsKey(dayOfWeek) )
                    {
                        slaTimer = taskCreatedDate.addHours(12);
                    }
                    
                    if(slaTimer != null && weekendsMeta.containsKey(slaTimer.format('EEEE')))
                    {
                        slaTimer = slaTimer + weekendsMeta.get(slaTimer.format('EEEE')).Days_to_Skip__c;
                    }
                    tsk.FBE_Team_Assignment__c = taskTypeMeta.get(tsk.Type).Public_Group__c;
                    
                }
                if(slaTimer != null && holidaysMap != NULL)
                {
                    for(Leaves_for_Task_SLA__mdt holiday: holidaysMap.values())
                    {                        
                        if(holiday.FBE_Leave_Date__c >= taskCreatedDate.Date() && holiday.FBE_Leave_Date__c <= slaTimer.date() )
                        {
                            slaTimer = slaTimer + 1; 
                        }
                        if(slaTimer != null && weekendsMeta.containsKey(slaTimer.format('EEEE')))
                        {
                            slaTimer = slaTimer + weekendsMeta.get(slaTimer.format('EEEE')).Days_to_Skip__c;
                        }
                    }
                }                
                if(slaTimer != null)
                    tsk.FBE_SLA_Timer__c = slaTimer;
                    taskMapToUpdate.put(tsk.id,tsk);
            }
        }
        if(taskMapToUpdate.values().size() > 0){
            UPDATE taskMapToUpdate.values();
        }
        FBE_Utility.sendInitialNotifyEmail(taskList);        
    }    
}