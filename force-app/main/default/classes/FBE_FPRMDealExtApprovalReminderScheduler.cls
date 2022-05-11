public without sharing class FBE_FPRMDealExtApprovalReminderScheduler implements Schedulable{
	public void execute(SchedulableContext ctx) {
        FBE_FPRMDealExtApprovalReminderBatch fbe = new FBE_FPRMDealExtApprovalReminderBatch();
        Database.executeBatch(fbe,50);
    }
}