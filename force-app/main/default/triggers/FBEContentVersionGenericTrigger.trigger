/*
 *@ Trigger Name                                                  : FBEContentVersionGenericTrigger 
 *@ Description                                                   : This trigger is created on Content Version object (Files). This is executed
                                                                    every time a file is uploaded (insert). The method executed is called under the class 'FBE_TriggerHandler'.
                                                                    This basically triggers the sharing of file with the Integration User.
 *@ CreatedBy                                                     : Deloitte Consulting
 *@ CreatedOn                                                     : 23-04-2017 [Sandesh Ghatkar]
 *@ Modification Log                                              :                     
 */
trigger FBEContentVersionGenericTrigger on ContentVersion(after insert) {
    FBE_TriggerHandler handler = new FBE_TriggerHandler(Trigger.isExecuting, Trigger.size);
    if (Trigger.isInsert && Trigger.isAfter) {
        handler.FBEContentVersionGenericTrigger(Trigger.new);
    }
}