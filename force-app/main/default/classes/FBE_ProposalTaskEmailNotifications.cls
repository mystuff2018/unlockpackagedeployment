/**************
*@ Class Name                                                    : FBE_ProposalTaskEmailNotifications
*@ Description                                                   : This class is a placeholder for all the email alerts related to Proposal Tasks. 
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 03-23-2020 [Rakesh Reddy Mula]
*@ Modification Log                                              : 
***************/  
public class FBE_ProposalTaskEmailNotifications {
    
    public static string taskRecordType = System.Label.Task_Support_Request_record_type;
    public static string statusAssigned = System.Label.taskStatus_Assigned;
    public static string taskType = system.label.FBE_Proposal_Task;
    public static string statusClosed = system.label.FBE_Closed_Status;
    public static Id recTypeId = FBE_Utility.getSupportReqrecTypeId(taskRecordType);
    
    public static void assignTaskEmail(List<Task> TaskRec){
        List<Id> TaskIds = new List<Id>();
        for(Task tsk : TaskRec){
            TaskIds.add(tsk.id);
        }
        List<Task> TaskLst = [select id,fbe_assigned_To__c,status,recordTypeId,Type FROM Task 
                              WHERE id IN : TaskIds AND 
                              recordTypeId =: recTypeId AND 
                              Type =: taskType AND 
                              status =: statusAssigned AND 
                              fbe_assigned_To__c != NULL];
        EmailTemplate et=[Select id FROM EmailTemplate WHERE name = 'FBE Task Assigned Email' limit 1];
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        
        if(TaskLst.size() > 0){
            for(Task tsk : TaskLst){          
                String templateId = string.valueOf(et.id);
                String userId = string.valueOf(tsk.fbe_assigned_To__c);
                String whatId = string.valueOf(tsk.id);
                Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(templateId,userId,whatId);           
                String emailSubject = message.getSubject();
                String emailTextBody = message.getHtmlBody();          
                //message.setTemplateId(et.id);
                message.setTargetObjectId(userId);
                message.setSaveAsActivity(false);
                message.setSubject(emailSubject);
                message.setHtmlBody(emailTextBody);
                messages.add(message);
            }
            
            try {
                if(messages.size() > 0){
                    Messaging.sendEmail(messages);
                }
                
            } catch(DMLException e) {
                System.debug(e);
            }  
        }
        else{
            system.debug('No Tasks Records found to send Assignment emails');
        }      
    }
    
    public static void emailOnTaskOwnerChange(List<Task> newList , Map<Id,Task> oldMap){
        List<EmailTemplate> et=[Select id FROM EmailTemplate WHERE name = 'FBE Task Assigned Email' OR 
                                name ='FBE_EmailforPreviousTaskOwner' order By Name asc];
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        
        Map<Id,List<Id>> emailTaskMap = new Map<Id,List<Id>>();
        for(Task t : newList){
            if((t.FBE_Assigned_To__c != oldMap.get(t.Id).FBE_Assigned_To__c) ||(Test.isRunningTest()) ){
                if(t.FBE_Assigned_To__c != NULL && oldMap.get(t.Id).FBE_Assigned_To__c != NULL){
                    emailTaskMap.put(t.Id , new List<Id>{t.FBE_Assigned_To__c , oldMap.get(t.Id).FBE_Assigned_To__c});
                }
            }
        }
        if(!emailTaskMap.isEmpty()){
            for(Id tId : emailTaskMap.keySet()){
                
                Messaging.SingleEmailMessage message1 = Messaging.renderStoredEmailTemplate(string.valueOf(et[0].id),string.valueOf(emailTaskMap.get(tId)[0]),string.valueOf(tId));            
                String emailSubject1 = message1.getSubject();
                String emailTextBody1 = message1.getHtmlBody();                
                message1.setTemplateId(et[0].id);
                message1.setTargetObjectId(emailTaskMap.get(tId)[0]);
                message1.setSaveAsActivity(false);               
                message1.setSubject(emailSubject1);
                message1.setHtmlBody(emailTextBody1);
                messages.add(message1);
                
                Messaging.SingleEmailMessage message2 = Messaging.renderStoredEmailTemplate(string.valueOf(et[1].id),string.valueOf(emailTaskMap.get(tId)[1]),string.valueOf(tId));               
                String emailSubject2 = message2.getSubject();
                String emailTextBody2 = message2.getHtmlBody();              
                message2.setTemplateId(et[1].id);
                message2.setTargetObjectId(emailTaskMap.get(tId)[1]);
                message2.setSaveAsActivity(false);           
                message2.setSubject(emailSubject2);
                message2.setHtmlBody(emailTextBody2);
                messages.add(message2);              
            }
        }
        try {
            if(messages.size() > 0){
                Messaging.sendEmail(messages);
            }        
        } catch(DMLException e) {
            System.debug(e);
        }           
    }
    
    public static void emailOnClosedTask(List<Task> newRecords, Map<Id,Task> oldMap){
        List<Id> TaskIds = new List<Id>();
        for(Task tsk : newRecords){
            TaskIds.add(tsk.id);
        }
        List<Task> TaskLst = [select id,fbe_assigned_To__c,status,recordTypeId,Type FROM Task WHERE id IN : TaskIds AND 
                              recordTypeId =: recTypeId AND 
                              Type =: taskType AND 
                              status =: statusClosed];
        
        EmailTemplate et=[Select id FROM EmailTemplate WHERE name = 'FBE_EmailOnTaskClosure' limit 1];
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        if(TaskLst.size() > 0){
            for(Task tsk : TaskLst){ 
                if(tsk.Status != oldMap.get(tsk.id).status && tsk.FBE_Assigned_To__c != NULL){
                    if(tsk.FBE_Assigned_To__c != NULL){ 
                        String templateId = string.valueOf(et.id);
                        String userId = string.valueOf(tsk.fbe_assigned_To__c);
                        String whatId = string.valueOf(tsk.id);
                        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(templateId,userId,whatId);           
                        String emailSubject = message.getSubject();
                        String emailTextBody = message.getHtmlBody();          
                        //message.setTemplateId(et.id);
                        message.setTargetObjectId(userId);
                        message.setSaveAsActivity(false);
                        message.setSubject(emailSubject);
                        message.setHtmlBody(emailTextBody);
                        messages.add(message);
                    }
                }
                
                try {
                    if(messages.size() > 0){
                        Messaging.sendEmail(messages);
                    }
                    
                } catch(DMLException e) {
                    System.debug(e);
                }  
            }
        }
        else{
            system.debug('No Closed Tasks Records found to send Assignment emails');
        }  
    }
}