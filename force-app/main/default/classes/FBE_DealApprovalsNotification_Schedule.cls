/*Developer : Soumiithri
 
  This class is to schedule FBE_CreateAutomatedEmailNotification 
  class to send email notifications to the owner and manager as perthe booking date */
  
    public without sharing class FBE_DealApprovalsNotification_Schedule implements Schedulable {
        public void execute(SchedulableContext ctx) {
            FBE_DealApprovalsNotificationBatch fbe = new FBE_DealApprovalsNotificationBatch ();
            Database.executeBatch(fbe,50);
        }
        
    }