trigger LocationTrigger on Location (before insert, after insert, before update, after update) {
    switch on Trigger.operationType {
        when AFTER_INSERT, AFTER_UPDATE {
           LocationTriggerHandler.updateTimezone(Trigger.newMap.keySet()); 
        }
    }
}