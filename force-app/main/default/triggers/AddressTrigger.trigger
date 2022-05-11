trigger AddressTrigger on Schema.Address (before insert, after insert, before update, after update) {
switch on Trigger.operationType {
        when AFTER_INSERT, AFTER_UPDATE {
            Set<Id> setLocation = new Set<Id>(); 
            
            for(Schema.Address ad : Trigger.new)
            {
                setLocation.add(ad.ParentId);
            }
            
            LocationTriggerHandler.updateTimezone(setLocation); 
        }
    }
}