public class FBE_CaseInactivity_EmailBatch implements database.Batchable<sObject>,Database.Stateful{
    
    ID supportReqRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FBE Support Request').getRecordTypeId();
    public Map<id,List<id>> ownerwithCaseIDs = new Map<id,List<id>>();
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        if(Test.isRunningTest()){
     return Database.getQueryLocator([SELECT Id,
                                         CaseNumber,
                                         FBE_Age_In_Days__c,
                                         Status,
                                         FBE_Case_Manager_Comments__c,
                                         LastModifiedDate,
                                         OwnerId
                                         FROM Case
                                         WHERE RecordTypeId=:supportReqRecId]);
}
        else{
        return Database.getQueryLocator([SELECT Id,
                                         CaseNumber,
                                         FBE_Age_In_Days__c,
                                         Status,
                                         FBE_Case_Manager_Comments__c,
                                         LastModifiedDate,
                                         OwnerId
                                         FROM Case
                                         WHERE RecordTypeId=:supportReqRecId AND
                                         Status NOT IN ('On Hold','Closed') AND
                                         FBE_Inactivity_Notification_Date__c = Today]);
        }
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        
        for(Case CaseDetails : (List<Case>)scope){
            if(CaseDetails.OwnerId.getsobjecttype() != Group.SobjectType){
                if(!ownerwithCaseIDs.containsKey(CaseDetails.ownerId)){
                    ownerwithCaseIDs.put(CaseDetails.ownerId,new List<id>{CaseDetails.id});
                }
                else
                    ownerwithCaseIDs.get(CaseDetails.ownerId).add(CaseDetails.id);
            }
        }
        
        system.debug('ownerwithCaseIDs ===> ' +ownerwithCaseIDs);
        system.debug('ownerwithCaseIDs.Keyset() ===> '  +ownerwithCaseIDs.Keyset());
        
        
    }
    
    public void finish(Database.BatchableContext BC){
        
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address =: System.label.FBE_Case_Lead_Notification_OWD limit 1];
        EmailTemplate temp = [select id,name from EmailTemplate where name = 'FBE_Case_Inactivity_Notification'];
        system.debug('template==>' +temp);
        system.debug('Inside loop ownerwithCaseIDs.Keyset() ===> '  +ownerwithCaseIDs.Keyset());
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<String> toAddressList = new List<String>();
        for(ID CaseDetails : ownerwithCaseIDs.Keyset()){ 
                toAddressList.add(CaseDetails);
                system.debug('inside loop toAddressList==>' +toAddressList);
                Messaging.singleEmailMessage email = Messaging.renderStoredEmailTemplate(temp.id,null,ownerwithCaseIDs.get(CaseDetails)[0] );
                email.toAddresses = toAddressList;
                email.setOrgWideEmailAddressId(owea.Id);
                email.setSaveAsActivity(false);
                emailList.add(email);
                toAddressList.clear();
            
       }
        
        if(emailList.size()>0){
            try{
                system.debug('<====Inside Email List====>');
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
            }catch(Exception e){
                System.debug('Exception:: '+e + ' Exception cause::'+e.getCause());
            }
        }
    }

}