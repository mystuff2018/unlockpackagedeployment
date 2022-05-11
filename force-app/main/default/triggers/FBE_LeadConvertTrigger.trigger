/*
 *@ Trigger Name      : FBE_LeadConvertTrigger  
 *@ Description       : This trigger is created on Lead Object. This is executed
                        every time an deal is Updated. The method executed is called under the class 'FBE_LeadConvertTrigger'.
                        
 *@ CreatedBy         : Dell Team
 *@ CreatedOn         : 10-15-2019
 *@ Modification Log  :                    
 */
trigger FBE_LeadConvertTrigger on Lead (before update,after update,before insert, after insert) {
    FBE_LeadTriggerHandler handler = new FBE_LeadTriggerHandler(Trigger.isExecuting, Trigger.size);  

    //calling Trigger Handler class method to sync Deal Team Members
    
    if(trigger.isbefore && trigger.isupdate){
               handler.AccessToLead(Trigger.new);
               //FBE_IDS_LeadStateCodeUpdateLogic.leadStateCodeUpdate(Trigger.new,Trigger.oldMap);
    } 
    if(trigger.isbefore && trigger.isinsert){
               handler.AccontFieldsMand(Trigger.new);
               //handler.LeadStatusisNew(Trigger.new); Revert the changes as per biz
               //FBE_IDS_LeadStateCodeUpdateLogic.leadStateCodeUpdate(Trigger.new,Null);
               //FBE_IDS_LeadStateCodeUpdateLogic.leadStateCodeUpdate(Trigger.new);
    } 
    if(trigger.isAfter && trigger.isinsert){
               FBE_IDS_LeadStateCodeUpdateLogic.leadStateCodeUpdate(JSON.Serialize(Trigger.new));
               //FBE_IDS_LeadStateCodeUpdateLogic.leadStateCodeUpdate(Trigger.new);
    }  
    //calling Trigger Handler class method to sync Deal Team Members
    if (Trigger.isAfter && Trigger.isupdate) {
        if(FBE_CheckRecursive.runOnce())
            System.debug('After Update');
        handler.RemoveAccessToLead(Trigger.oldMap,Trigger.new,Trigger.old);
        handler.CloseTaskForLead(Trigger.new);
    }  
}