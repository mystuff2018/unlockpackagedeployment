public class FBE_CaseInactivityTemplate {
    
    public Id userID {get;set;}
    public integer count {get;set;}
    
ID supportReqRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FBE Support Request').getRecordTypeId();
    public List<case> getcaseList(){
        List<case> csList = [SELECT id,CaseNumber,FBE_Age_In_Days__c,Status,FBE_Case_Manager_Comments__c,LastModifiedDate,OwnerId FROM Case
                            WHERE RecordTypeId=:supportReqRecId AND
                                  Status NOT IN ('On Hold','Closed') AND
                                  FBE_Inactivity_Notification_Date__c = Today AND
                                  ownerid =: userID];
        count = csList.size();
        return csLIst;
    }
}