/*Developer : LavaKumar Tonupunuri
  Story : 7113401
  This class is to schedule FBE_CreateAutomatedEmailNotification 
  class to send email notifications to the owner and manager as perthe booking date */
  
    public without sharing class FBE_CreateAutomatedEmailNotificationSch implements Schedulable {
        public void execute(SchedulableContext ctx) {
            FBE_CreateAutomatedEmailNotification fbe = new FBE_CreateAutomatedEmailNotification ();
            Database.executeBatch(fbe,100);
        }
        
    }