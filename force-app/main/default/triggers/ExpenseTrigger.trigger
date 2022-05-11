trigger ExpenseTrigger on pse__Expense__c (after update) {

    if(trigger.isAfter && trigger.isUpdate){
            new ExpenseTriggerHandler().run();
        }
    
}