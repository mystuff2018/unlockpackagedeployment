/**************
*@ Class Name                                                    : FBE_Utility
*@ Description                                                   : This class is written for fetching the custom metadata values.
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 12-19-2019 [Sireesha Myla]
*@ Modification Log                                              : 
***************/ 
public without sharing class FBE_Utility
{
    public static string taskRecordType = System.Label.Task_Support_Request_record_type; //Getting the Task Recordtype 'Support Request' from the Custom Label
    public static string emailbody =  System.Label.Email_Body;
    public static string escalateEmailbody = System.Label.Task_Escalation_Email_Body;
    
    // Method to get the Task 'Support Request' recordtype
    public static Id getSupportReqrecTypeId(String recTypeName) 
    {
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Task' AND Name =:recTypeName]; 
        return rt.Id;
    }
    
    //Method to get the Weekends Custom Metadata
    public static Map<String,Weekend__mdt>getWeekendMetadata()
    {
        Map<String, Weekend__mdt> weekendsMeta = new Map<String, Weekend__mdt>();
            for(Weekend__mdt weekend : [Select MasterLabel,Days_to_Skip__c from Weekend__mdt])
                weekendsMeta.put(weekend.MasterLabel, weekend);
        
       return weekendsMeta;
    }
    
    //Method to get the SLA Custom Metadata
    public static Map<String,FBE_SLA_Setting__mdt>getSLAMetadata()
    {
        Map<String,FBE_SLA_Setting__mdt> taskSLAMetadatMap = new Map<String,FBE_SLA_Setting__mdt>();
        for(FBE_SLA_Setting__mdt sLAmetadataList : [select MasterLabel,First_Name__c,Email__c,Public_Group__c,SLA_Time__c from FBE_SLA_Setting__mdt])
            taskSLAMetadatMap.put(sLAmetadataList.MasterLabel,sLAmetadataList);
        
       return taskSLAMetadatMap;
    }
    
    public static Map<ID,Leaves_for_Task_SLA__mdt>getholidaysMetadata()
    {
        Map<Id, Leaves_for_Task_SLA__mdt>holidaysMap = new Map<Id, Leaves_for_Task_SLA__mdt>();
            for(Leaves_for_Task_SLA__mdt holidays: [select MasterLabel,FBE_Leave_Date__c from Leaves_for_Task_SLA__mdt Order By FBE_Leave_Date__c Asc])
                holidaysMap.put(holidays.ID, holidays);
        
       return holidaysMap;
    }
    
    //Method to get Escalation(Custom Metadata) send details 
    public static Map<String,FBE_SLA_Breach_Setting__mdt>getEscalateMetadata()
    {
        Map<String,FBE_SLA_Breach_Setting__mdt> taskEscalateMetadatMap = new Map<String,FBE_SLA_Breach_Setting__mdt>();
        for(FBE_SLA_Breach_Setting__mdt escalateMetadata : [select MasterLabel,Email__c,First_Name__c from FBE_SLA_Breach_Setting__mdt])
            taskEscalateMetadatMap.put(escalateMetadata.MasterLabel,escalateMetadata);
        
       return taskEscalateMetadatMap;
    }
      
    //Method to send Initial Email Notification on Task Creation
    public static void sendInitialNotifyEmail(List<Task> newRecords)
   { 
       
       List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
       
       //SOQL to get Type,Email to be send,Public Group Name and SLA time from Custom Metadata 
       Map<String, FBE_SLA_Setting__mdt> SLAmetadataMap = getSLAMetadata();
       
       
       ID supportReqrecTypeId = FBE_Utility.getSupportReqrecTypeId(taskRecordType);
        
       for(Task tsk: newRecords)
       {
            if(tsk.RecordTypeId == supportReqrecTypeId && SLAmetadataMap.get(tsk.Type) != NULL && SLAmetadataMap.get(tsk.Type).Email__c != NULL )
            {
               Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
  			   message.setReplyTo('no-reply@salesforce.com');
               message.setSenderDisplayName('Task Created');
               message.setSubject('Opportunity Support Task Creation – Notification');
			   message.setSaveAsActivity(false);
               String body = 'Dear '+ SLAmetadataMap.get(tsk.Type).First_Name__c +',<br/><br/>' + 'Your '+ SLAmetadataMap.get(tsk.Type).MasterLabel +' '+ emailbody +'</br>'+ system.URL.getSalesforceBaseUrl().toExternalForm()+'/'+Tsk.Id + '</br></br></br>'+'<b>Thank you,</br/>'+'Salesforce Support Team.</b>';
              // string body = 'Dear User,<br/> The Task <b> '+ + '</b>has been created in Salesforce.<p>'+ system.URL.getSalesforceBaseUrl().toExternalForm()+'/'+Tsk.Id + ' to go to the record!'; 
               message.setHtmlBody(body);
               message.toAddresses = new String[] {SLAmetadataMap.get(tsk.Type).Email__c};
               messages.add(message);   
            }
        
       }
          
        try {
               if(messages.size() > 0){
                    Messaging.sendEmail(messages);
                }
            
            } catch(Exception e) {
                    System.debug(e);
                 }
   }
    public static boolean EscalateEmail(List<Task> tasksToBeEscaleted){
         boolean retVal;
         List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
         Map<Id,Task> tasksMap = new Map<Id,Task>();
       
       //SOQL to get Type,Email to be send,Public Group Name and SLA time from Custom Metadata 
       Map<String, FBE_SLA_Breach_Setting__mdt> escalateMetadataMap = getEscalateMetadata();

       ID supportReqrecTypeId = FBE_Utility.getSupportReqrecTypeId(taskRecordType);
        
       for(Task tsk: tasksToBeEscaleted)
       {
            if(tsk.RecordTypeId == supportReqrecTypeId && escalateMetadataMap.get(tsk.Type) != NULL && escalateMetadataMap.get(tsk.Type).Email__c != NULL )
            {
               Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
  			   message.setReplyTo('no-reply@salesforce.com');
               message.setSenderDisplayName('Task Escalated');
               message.setSubject('Opportunity Support Task Escalation – Notification');
			   message.setSaveAsActivity(false);
               String body = 'Dear '+ escalateMetadataMap.get(tsk.Type).First_Name__c +',<br/><br/>' + 'Your '+ escalateMetadataMap.get(tsk.Type).MasterLabel +' '+ escalateEmailbody +'</br>'+ system.URL.getSalesforceBaseUrl().toExternalForm()+'/'+Tsk.Id + '</br></br></br>'+'<b>Thank you,</br/>'+'Salesforce Support Team.</b>';
               //string body = 'Dear User,<br/> The Task <b> '+ + '</b>has been Escalated in Salesforce.<p>'+ system.URL.getSalesforceBaseUrl().toExternalForm()+'/'+Tsk.Id + ' to go to the record!'; 
               message.setHtmlBody(body);
               message.toAddresses = new String[] {escalateMetadataMap.get(tsk.Type).Email__c};
               messages.add(message);   
            }
        
       }
          
        try {
               if(messages.size() > 0){
                   Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                  
                   if (results[0].success) {
                       System.debug('The email was sent successfully.');
                       retVal = true;
                   } else {
                       System.debug('The email failed to send: '
                                    + results[0].errors[0].message);
                    retVal = false;
                   }
                }
            
            } catch(DMLException e) {
                    System.debug(e);
                 }
          return retVal;  
    }

}