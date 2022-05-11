/**************
*@ Class Name                                                    : FBE_FPRM_DistyConfigAfflScheduler
*@ Description                                                   : This class is written for scheduling Disty Configuration Error Affiliations -> FBE_FPRM_DistyTransferBatch.
*@ CreatedBy                                                     : Dell Team FPRM
*@ CreatedOn                                                     : 9th June 2021 [Sireesha Myla]
*@ Modification Log                                              : 
***************/   
public class FBE_FPRM_DistyConfigAfflScheduler implements schedulable{
    public void execute(SchedulableContext ctx) {
         FBE_FPRM_Notification_Switch__c disty = FBE_FPRM_Notification_Switch__c.getOrgDefaults();
         if(disty.FBE_FPRM_Enable_Disty_Transfer__c == true)
         {
            FBE_FPRM_DistyTransferBatch dmpBatch = new FBE_FPRM_DistyTransferBatch('Disty Managed', false , 'Configuration Error');
             Database.executeBatch(dmpBatch, 5);
             FBE_FPRM_DistyTransferBatch resellerBatch = new FBE_FPRM_DistyTransferBatch('Reseller', false , 'Configuration Error');
             Database.executeBatch(resellerBatch, 5);
         }
        
    }
}