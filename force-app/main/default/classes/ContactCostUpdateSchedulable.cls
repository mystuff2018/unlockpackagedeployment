global class ContactCostUpdateSchedulable implements Schedulable {
    global void execute(SchedulableContext SC){
        ContactCostUpdateBatch contactBatch = new ContactCostUpdateBatch();   
        Database.executeBatch(contactBatch);
    }
}