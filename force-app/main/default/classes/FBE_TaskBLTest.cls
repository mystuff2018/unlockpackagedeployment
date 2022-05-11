/**************
*@ Class Name                                                    : FBE_TaskBLTest
*@ Description                                                   : Test class for FBE_TaskBL.
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 12-19-2019 [Sireesha Myla]
*@ Modification Log                                              : 07-Jan-2020
***************/ 
@isTest
public class FBE_TaskBLTest 
{
    public static string taskRecordType = System.Label.Task_Support_Request_record_type; //Getting the Task Recordtype 'Support Request' from the Custom Label
    public static string taskTypeConfig =  System.Label.Task_Type;
    public static ID supportReqrecTypeId = FBE_Utility.getSupportReqrecTypeId(taskRecordType);
    public static string taskBDRecordType = System.Label.FBE_BD_Capture_Task_Type; //Getting the Task Recordtype 'BD/Capture Task Type' from the Custom Label
    
    public static User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
    public static Map<String, FBE_SLA_Setting__mdt> slaMetaMap = FBE_Utility.getSLAMetadata();
    public static Map<String, Weekend__mdt> weekendMetaMap = FBE_Utility.getWeekendMetadata();
    public static Map<Id, Leaves_for_Task_SLA__mdt> publicHolidayMap = FBE_Utility.getholidaysMetadata();
    
    
    static testMethod void method1()
    {
        Map<Integer, String> countSLAdaysMap = new Map<Integer, String>();
        countSLAdaysMap.put(5,'Monday;Tuesday;Wednesday;Thursday;Friday');
        countSLAdaysMap.put(4,'Tuesday;Wednesday;Thursday;Friday');
        countSLAdaysMap.put(3,'Wednesday;Thursday;Friday');
        countSLAdaysMap.put(2,'Thursday;Friday');
        countSLAdaysMap.put(1,'Friday');
        DateTime publicHoliday = Date.newInstance(2019,12, 25);
        
        List<Task> tskList = FBE_UtilityFactory.createTasks();
        system.assertNotEquals(null, tskList, 'Tasks not created');
        
        Test.startTest();
        try{
            for(Task tsk: tskList)
            {
                Time timeToSetup = Time.newInstance(14,0,0,0);
                Time tskCreatedTime = tsk.CreatedDate.time();
                DateTime taskCreatedDate = tsk.CreatedDate;
                String dayOfWeek = tsk.CreatedDate.format('EEEE');
                
                if(slaMetaMap.get(tsk.Type).SLA_Time__c != null && slaMetaMap.get(tsk.Type).SLA_Time__c > 0 && 
                   tskCreatedTime > timeToSetup )
                {
                    Integer slaDays = Integer.valueOf(slaMetaMap.get(tsk.Type).SLA_Time__c/24);
                    
                    
                    if (weekendMetaMap.get(dayOfWeek)!= null)
                    {
                        tsk.FBE_SLA_Timer__c = taskCreatedDate + weekendMetaMap.get(dayOfWeek).Days_to_Skip__c + slaMetaMap.get(tsk.Type).SLA_Time__c/24;
                    }
                    else if(!weekendMetaMap.containsKey(dayOfWeek))
                    {
                        tsk.FBE_SLA_Timer__c = taskCreatedDate + slaMetaMap.get(tsk.Type).SLA_Time__c/24;
                    }
                    else if(!countSLAdaysMap.isEmpty() && countSLAdaysMap.get(slaDays)!=null && countSLAdaysMap.get(slaDays).contains(dayOfWeek))
                    {
                        tsk.FBE_SLA_Timer__c = taskCreatedDate + slaDays + 2;
                    }
                }
                else if(tskCreatedTime < timeToSetup && slaMetaMap.get(taskTypeConfig)!= NULL)
                {
                    if(weekendMetaMap.get(dayOfWeek)!= NULL )
                    {
                        DateTime addDay = taskCreatedDate + weekendMetaMap.get(dayOfWeek).Days_to_Skip__c; //Skip the days fri+3, sat+2,sun+1
                        tsk.FBE_SLA_Timer__c = addDay; // Add SLA time to the Task CreatedDate
                        tsk.FBE_SLA_Timer__c  = tsk.FBE_SLA_Timer__c.addHours(12);
                    }
                    else if(!weekendMetaMap.containsKey(dayOfWeek) )
                    {
                        tsk.FBE_SLA_Timer__c = taskCreatedDate.addHours(12);
                    }
                    
                    if(tsk.FBE_SLA_Timer__c != null && weekendMetaMap.containsKey(tsk.FBE_SLA_Timer__c.format('EEEE')))
                    {
                        tsk.FBE_SLA_Timer__c = tsk.FBE_SLA_Timer__c + weekendMetaMap.get(tsk.FBE_SLA_Timer__c.format('EEEE')).Days_to_Skip__c;
                    }
                    tsk.FBE_Team_Assignment__c = slaMetaMap.get(tsk.Type).Public_Group__c;
                }
                if(tsk.FBE_SLA_Timer__c != null && publicHolidayMap != NULL)
                {
                    for(Leaves_for_Task_SLA__mdt holiday: publicHolidayMap.values())
                    {
                        if(holiday.FBE_Leave_Date__c >= taskCreatedDate.Date() && holiday.FBE_Leave_Date__c <= tsk.FBE_SLA_Timer__c.date() )
                        {
                            tsk.FBE_SLA_Timer__c = tsk.FBE_SLA_Timer__c + 1; 
                        }
                        if(tsk.FBE_SLA_Timer__c != null && weekendMetaMap.containsKey(tsk.FBE_SLA_Timer__c.format('EEEE')))
                        {
                            tsk.FBE_SLA_Timer__c = tsk.FBE_SLA_Timer__c + weekendMetaMap.get(tsk.FBE_SLA_Timer__c.format('EEEE')).Days_to_Skip__c;
                        }
                    }
                }
                
                if(tsk.FBE_SLA_Timer__c != null && weekendMetaMap.get(tsk.FBE_SLA_Timer__c.format('EEEE'))!= null)
                {
                    tsk.FBE_SLA_Timer__c = tsk.FBE_SLA_Timer__c + weekendMetaMap.get(tsk.FBE_SLA_Timer__c.format('EEEE')).Days_to_Skip__c;
                }
                /* tsk.FBE_Email_Team_on_Status_Change__c = true ;
				   tsk.Status = 'Deferred';
				   tskList.add(tsk);
				*/
            }
            
        }catch(NullPointerException e)
        {
            system.debug('null value here');
        }
        
        UPDATE tskList;
        Test.stopTest();
        
    }    
}