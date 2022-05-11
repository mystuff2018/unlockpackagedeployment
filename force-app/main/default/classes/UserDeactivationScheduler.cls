global class UserDeactivationScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        UserDeactivation deactivateUser = new UserDeactivation(); 
        Database.ExecuteBatch(deactivateUser);
 } 

}