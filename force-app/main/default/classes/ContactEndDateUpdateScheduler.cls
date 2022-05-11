global class ContactEndDateUpdateScheduler implements Schedulable {
     global void execute(SchedulableContext SC) {
        ContactEndDateUpdate updateContactLastDate = new ContactEndDateUpdate(); 
        Database.ExecuteBatch(updateContactLastDate);
 } 

}