trigger BudgetTrigger on pse__Budget__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new BudgetTriggerHandler().run(); 
    /* DLRS Package */
   /* dlrs.RollupService.triggerHandler(pse__Budget__c.SObjectType);*/
}