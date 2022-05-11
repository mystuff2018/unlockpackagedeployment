/**
* @description       : Defect : 12192105 Partners were unable to recall a deal in submitted status that is in approval workflow
* @author            : Dipanshu Parakh
* @created on        : 11-03-2022
**/
public with sharing class FBE_FPRM_RecallDealApprlProcessScheduler implements Schedulable{
    public void execute(SchedulableContext ctx) {
        FBE_FPRM_RecallDealApprlProcessBatch fbe = new FBE_FPRM_RecallDealApprlProcessBatch();
        Database.executeBatch(fbe, 50);
    }
}