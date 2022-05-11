/*
*@ Trigger Name     : FBE_UserTrigger
*@ Description      : This trigger is created on User object. It is executed when a user is inserted or updated. 
                      If more than one users have Integration User checkbox checked, it throws an error. It calls IntegrationUser class.
*@ CreatedBy        : Deloitte Consulting
*@ CreatedOn        : 22-09-2017 [Nileshwari Patil]
*@ Modification Log :                     
*/
trigger FBE_UserTrigger on User (before insert,before update) {
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        FBE_TriggerHandler intUserHandler = new FBE_TriggerHandler(Trigger.isExecuting, Trigger.size);
        intUserHandler.CheckOnlyOneIntegrationUser(trigger.oldMap,trigger.new,Trigger.isUpdate);   
        Map<ID,User> oldMap = trigger.oldMap;
        FBE_UpdateIntStatusToPendingStatus.FBE_UpdateIntegrationStatusToPendingStatus(trigger.new,oldMap);
         
    }
}