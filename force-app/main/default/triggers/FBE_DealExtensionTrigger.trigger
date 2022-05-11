trigger FBE_DealExtensionTrigger on Deal_Extension__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
DealTriggerHandler.handleTrigger(Trigger.new, Trigger.old, trigger.newMap,trigger.oldMap,Trigger.operationType);
}