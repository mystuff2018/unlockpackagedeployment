trigger FBE_AccountTeamTrigger on AccountTeamMember (after insert, after update,after delete) {
    //if(FBE_CheckRecursive.runOnce()){
    if( trigger.IsAfter && (trigger.IsInsert || trigger.Isupdate)) {
		FBE_PrimarySE_Account.PrimarySEUserToAccount(Trigger.new);
        FBE_AccountTeamTrigger_Handler.updateChannelSalesRep(trigger.new);
    }
    if(trigger.IsAfter && trigger.IsDelete){
        FBE_PrimarySE_Account.PrimarySEUserToAccount(Trigger.old);
        FBE_AccountTeamTrigger_Handler.updateChannelSalesRep(trigger.old);
    }
    //}
    }