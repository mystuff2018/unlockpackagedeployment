trigger ProjectLocationTrigger on Project_Location__c (before insert, before update) {
	system.debug('Trigger.operationType: ' + Trigger.operationType);
    switch on Trigger.operationType {
        when BEFORE_INSERT, BEFORE_UPDATE {
           ProjectLocationTriggerHandler.updateTimezone(Trigger.new); 
        }
    }
}