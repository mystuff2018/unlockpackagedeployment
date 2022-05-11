public without sharing class ServiceCaseHandler {
    public static Boolean skipCaseTrigger = false;
    public Map<Id, Case> triggerExistingRecordsMap {get; set;}
    public List<Case> caseRecordList {get; set;}
    @testVisible
    private static Map<String, String> queueToCaseReason = new Map<String, String>{ ServiceConstants.QUEUE_US_CC_FEd_SUPPORT_Email => ServiceConstants.CASE_REASON_CUSTOMER_CARE, 
                                                                                    ServiceConstants.QUEUE_US_CC_FEd_DISTRESSED_SHIPMENTS_EMAIL => ServiceConstants.CASE_REASON_DISTRESSED_SHIPMENTS,
                                                                                    ServiceConstants.QUEUE_US_COMM_FEDERAL_TS_EMAIL => ServiceConstants.CASE_REASON_TECHNICAL_SUPPORT,
                                                                                    ServiceConstants.QUEUE_TS_FEDERAL_DISPATCH_EMAIL => ServiceConstants.CASE_REASON_DISPATCH};


    public Id serviceCaseRecordTypeId {
        get{
            if(null == serviceCaseRecordTypeId){
                serviceCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service').getRecordTypeId();
                return serviceCaseRecordTypeId;
            }
            return serviceCaseRecordTypeId;
        }
        private set;
    }

    public void handleTrigger(List<Case> newRecords, Map<Id, Case> existingRecords, System.TriggerOperation triggerEvent){
        List<Case> serviceCases = getServiceCases(newRecords);
        if(serviceCases.isEmpty()) return;

        this.caseRecordList = serviceCases;
        this.triggerExistingRecordsMap = existingRecords;

        switch on triggerEvent {
            when BEFORE_INSERT {
                updateCaseDefaultValues(serviceCases);
            }    
            when BEFORE_UPDATE {
                updateCaseServiceQueue(serviceCases);
            }
            when else {
                //do nothing for AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE, AFTER_UNDELETE, BEFORE_DELETE
            }
        }
    }

	public List<Case> getServiceCases(List<Case> caseList){
        List<Case> serviceCases = new List<Case>();
        for (Case caseRecord : caseList) {
            if(caseRecord.RecordTypeId == serviceCaseRecordTypeId){
                serviceCases.add(caseRecord);
            }
        }

        return serviceCases;
	}

    public List<Case> getChangedRecords(Set<String> fieldNames)
	{
		List<Case> changedRecords = new List<Case>();
		for (Case newRecord : caseRecordList)
		{
			Id recordId = (Id) newRecord.get('Id');
			if (this.triggerExistingRecordsMap == null || !this.triggerExistingRecordsMap.containsKey(recordId))
			{
				continue;
			}

			Case oldRecord = this.triggerExistingRecordsMap.get(recordId);
			for (String fieldName : fieldNames)
			{
				if (oldRecord.get(fieldName) != newRecord.get(fieldName))
				{
					changedRecords.add(newRecord);
					break;  // prevents the records from being added multiple times
				}
			}
		}
		return changedRecords;
	}

    public void updateCaseServiceQueue(List<Case> caseList){
        List<Case> casesUpdatedOwner = getChangedRecords(new Set<String>{'OwnerId'});
        List<Case> casesAssignedToQueue = getCasesAssignedToQueue(casesUpdatedOwner);

        if(casesAssignedToQueue.isEmpty()) return;
        
        setCaseQueue(casesAssignedToQueue);
    }

    public Boolean isOwnerQueue(Id ownerId){
        if(ownerId.getSobjectType() == Schema.Group.SObjectType){
            return true;
        }
        return false;
    }

    public Map<Id, Group> getMapQueue(List<Case> caseList){
        Set<Id> setQueueIds = new Set<Id>{};

        for (Case caseRecord : caseList) {
            setQueueIds.add(caseRecord.OwnerId);
        }

        Map<Id, Group> mapQueueId = new Map<Id, Group>([
            SELECT Id, Name FROM Group WHERE Id =: setQueueIds
        ]);

        return mapQueueId;
    }

	public List<Case> getCasesAssignedToQueue(List<Case> casesUpdatedOwner){
        List<Case> casesList = new List<Case>();
		for (Case caseRecord : casesUpdatedOwner) {
            if(isOwnerQueue(caseRecord.OwnerId)){
                casesList.add(caseRecord);
            }
        }
        return casesList;
	}
    
    @testVisible
    private void updateCaseDefaultValues(List<Case> casesToPopulateReasons){
        
        List<Case> casesAssignedToQueue = getCasesAssignedToQueue(casesToPopulateReasons);
        if(casesAssignedToQueue.isEmpty()) return;

        setCaseQueue(casesAssignedToQueue);
        setCaseReason(casesAssignedToQueue);
        setCaseOpenStatus(casesAssignedToQueue);
    }

    private void setCaseReason(List<Case> caseList){
        for(Case caseObj : caseList){
            String queueName = caseObj.Service_Queue__c;
            if(queueToCaseReason.containsKey(queueName)){
                caseObj.Reason = queueToCaseReason.get(queueName);
            }
        }    
    }
    private void setCaseOpenStatus(List<Case> caseList){
        for(Case caseObj : caseList){
            caseObj.Status = ServiceConstants.CASE_STATUS_OPEN;
        }
    }

    private void setCaseQueue(List<Case> caseList){
        Map<Id, Group> mapQueues = getMapQueue(caseList);
        for(Case caseObj : caseList)
        {
            String queueName = mapQueues.get(caseObj.OwnerId).Name;
            caseObj.Service_Queue__c = queueName;
        }
    }

}