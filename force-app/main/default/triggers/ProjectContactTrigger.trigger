/*
      Purpose:
            Maintain the CE Survey Contact lookup field on Project in relation to CE Survey checkbox
            field on Project Contact, and its Contact__c lookup
            
      Initiative: Dell Thunderbolt PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    8/30/18
*/

trigger ProjectContactTrigger on Project_Contact__c (after insert, after update, before delete) {
    TriggerOperation triggerOp;
    if (Trigger.isInsert && Trigger.isAfter) triggerOp = TriggerOperation.AFTER_INSERT;
    if (Trigger.isInsert && Trigger.isBefore) triggerOp = TriggerOperation.BEFORE_INSERT;
    if (Trigger.isUpdate && Trigger.isAfter) triggerOp = TriggerOperation.AFTER_UPDATE;
    if (Trigger.isUpdate && Trigger.isBefore) triggerOp = TriggerOperation.BEFORE_UPDATE;
    if (Trigger.isDelete && Trigger.isAfter) triggerOp = TriggerOperation.AFTER_DELETE;
    if (Trigger.isDelete && Trigger.isBefore) triggerOp = TriggerOperation.BEFORE_DELETE;
   if (Trigger.isUndelete && Trigger.isAfter) triggerOp = TriggerOperation.AFTER_UNDELETE;
    ProjectContactHandler.maintainProjectContactFields(Trigger.oldMap,Trigger.newMap,triggerOp);
}