trigger Risk_Rollup_Summary_Trigger on pse__Risk__c (after insert, after update, after delete, after undelete) {
	List<Id> lstProjectIds = new List<Id>(); 
    if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete)
    {for(pse__Risk__c Risk:Trigger.NEW){
        lstProjectIds.add(Risk.pse__Project__c);
    }}
    if(Trigger.isUpdate || Trigger.isDelete)
    {for(pse__Risk__c Risk:Trigger.Old)
    {
        lstProjectIds.add(Risk.pse__Project__c);
    }}
    
    Risk_Rollup_Summary_Trigger_Handler.updateRiskCount(lstProjectIds);
}