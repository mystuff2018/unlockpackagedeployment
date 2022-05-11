/**************
 * @ Class Name        : FBE_SetDealExpiredScheduler
 * @ Description       : This is a scheduler class to invoke  Deal Expiry Batch APEX. Created as part of TFS Defect #7756375.
 * @ CreatedBy         : Deloitte Consulting
 * @ CreatedOn         : 12-11-2019
 * @ Modification Log  : Version 1.0 - [Ankita Shingvi] : Initially created script to invoke Deal Expiry Batch APEX.
 *                       
*********/
public with sharing  class FBE_SetDealExpiredScheduler implements Schedulable{
    public void execute(SchedulableContext sc){
         FBE_SetDealExpiredBatch batch = new FBE_SetDealExpiredBatch();
         database.executebatch(batch,2000);
    }
}