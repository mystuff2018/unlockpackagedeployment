trigger ProjectTaskAssignmentTrigger on pse__Project_Task_Assignment__c (before insert, before update, before delete,After insert,After Update,After Delete,After Undelete) {
    new ProjectTaskAssignmentTriggerHandler().run(); 
if (Trigger.isInsert && Trigger.isBefore) {
    if(FBE_IDS_NovoraInterLock.runOnceNovoraBeforeUpdate()){
    FBE_IDS_NovoraInterLock.beforeInsertAndUpdateOnPrjTaskAssignmt(Trigger.new);
    System.debug('I am in Before Assignment');
    }
}
    if (Trigger.isUpdate && Trigger.isBefore) {
    if(FBE_IDS_NovoraInterLock.runOnceNovoraBeforeUpdate()){
    FBE_IDS_NovoraInterLock.beforeInsertAndUpdateOnPrjTaskAssignmt(Trigger.new);
    System.debug('I am in Before update Assignment');
    }
}
    
}