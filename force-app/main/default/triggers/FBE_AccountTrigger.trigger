/*
 *@ Trigger Name      : FBE_AccountTrigger  
 *@ Description       : This trigger is created on Account Object. This is executed
                        every time an account is Updated. The method executed is called under the class 'FBE_AccountTriggerHandler'.
                        
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 04-10-2017
 *@ Modification Log  :                     
 */
trigger FBE_AccountTrigger on Account (after update) {
    FBE_AccountTriggerHandler handler = new FBE_AccountTriggerHandler(Trigger.isExecuting, Trigger.size);
    if(FBE_CheckRecursive.runOnce()){
        if (Trigger.isUpdate && Trigger.isAfter) {
            handler.onAfterUpdate(Trigger.new);
        }
    }    
}