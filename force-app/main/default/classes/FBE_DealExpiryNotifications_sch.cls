/**************
*@ Class Name                                                    : FBE_DealExpiryNotifications_sch
*@ Description                                                   : This is a Schedule class for FBE_DealExpiredNotificationsBatch.
                                                                   It is scheduled at 12AM everyday from Apex Scheduling Tool with Job Name "FBE_DealExpiryNotification_Scheduler"
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 05-15-2020 [Rakesh Reddy Mula]
*@ Modification Log                                              : 
***************/

public without sharing class FBE_DealExpiryNotifications_sch implements schedulable{
    public void execute(SchedulableContext ctx) {
        FBE_DealExpiredNotificationsBatch Esc = new FBE_DealExpiredNotificationsBatch();
        FBE_FPRM_Deal_Exp_Notif_Partner expPrm = new FBE_FPRM_Deal_Exp_Notif_Partner();
        Database.executeBatch(Esc, 200);
        Database.executeBatch(expPrm, 200);
    }
    
}