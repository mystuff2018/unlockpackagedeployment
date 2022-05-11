trigger RequestTrigger on Request__c ( before insert, after update , after delete , after undelete) {
    
    new RequestTriggerHandler().run();
    
}