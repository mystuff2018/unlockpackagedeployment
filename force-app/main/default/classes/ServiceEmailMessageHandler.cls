public without sharing class ServiceEmailMessageHandler {
    public Map<Id, EmailMessage> triggerExistingRecordsMap {get; set;}
    public List<EmailMessage> emailMessageRecordList {get; set;}

    public void handleTrigger(List<EmailMessage> newRecords, Map<Id, EmailMessage> existingRecords, System.TriggerOperation triggerEvent){
        this.emailMessageRecordList = newRecords;
        this.triggerExistingRecordsMap = existingRecords;

        switch on triggerEvent {
            when AFTER_INSERT {
                syncEmailWithSiebel();
            }
            when else {
                //do nothing for BEFORE_UPDATE, BEFORE_INSERT, AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE, AFTER_UNDELETE, BEFORE_DELETE
            }
        }
    }

	private void syncEmailWithSiebel(){
        List<EmailMessage> listEmailsLinkedToServiceCase = getEmailsLinkedToServiceCase();
        if(listEmailsLinkedToServiceCase.isEmpty()) return;

        SiebelSRUpdate.updateSRFromEmailMessage(listEmailsLinkedToServiceCase[0].Id);
	} 

	private List<EmailMessage> getEmailsLinkedToServiceCase(){
        List<EmailMessage> emailsLinkedToCases = new List<EmailMessage>();
        Map<Id, EmailMessage> mapEmailMessageCase = new Map<Id, EmailMessage>(); 
        Set<Id> setCaseIds = new Set<Id>();

		for(EmailMessage emailRecord : emailMessageRecordList){
            if(String.isNotBlank(emailRecord.ParentId)){
                mapEmailMessageCase.put(emailRecord.Id, emailRecord);
                setCaseIds.add(emailRecord.ParentId);
            } 
        }

        if(setCaseIds.isEmpty()) return emailsLinkedToCases;

        Set<Id> serviceCasesWithSrNumber = new Set<Id>();
        Id serviceCaseRecordTypeId = new ServiceCaseHandler().serviceCaseRecordTypeId;
        List<Case> listCasesWithPendingToSync = new List<Case>();

        for(Case caseRecord : [
            SELECT Id, RecordTypeId, SR_Number__c, Service_Tag__c, Order_Number__c
            FROM Case
            WHERE Id in : setCaseIds
        ]){
            if(
                caseRecord.RecordTypeId == serviceCaseRecordTypeId &&
                String.isNotBlank(caseRecord.SR_Number__c) &&
               (String.isNotBlank(caseRecord.Service_Tag__c) || String.isNotBlank(caseRecord.Order_Number__c)) 
                ){
                serviceCasesWithSrNumber.add(caseRecord.Id);
            } else if(caseRecord.RecordTypeId == serviceCaseRecordTypeId){
                listCasesWithPendingToSync.add(
                    new Case(Id = caseRecord.Id, Siebel_Pending_to_Sync__c = true)
                );
            }
        }

        if(!listCasesWithPendingToSync.isEmpty()){
            ServiceCaseHandler.skipCaseTrigger = true;
            update listCasesWithPendingToSync;    
        }

        if(serviceCasesWithSrNumber.isEmpty()) return emailsLinkedToCases;

        for(Id emailMessageId : mapEmailMessageCase.keySet()){
            EmailMessage emailRecord = mapEmailMessageCase.get(emailMessageId);
            if(serviceCasesWithSrNumber.contains(emailRecord.ParentId)){
                emailsLinkedToCases.add(emailRecord);
            }
        }

        return emailsLinkedToCases;
	} 
}