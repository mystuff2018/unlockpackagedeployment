/**************
* @Class       : FBE_LeadStatusBatch_Schedule
* @Description   : This is Schedular class to send automated emails to Lead owner's and their respected mangers on 
					every Monday
* @CreatedBy     : DeLL Team
* @CreatedOn     : 03-04-2020 [Soumithri Rekha, Sai]
***************/

public class FBE_LeadStatusBatch_Schedule implements Schedulable {
    public void execute(SchedulableContext ctx) {
        FBE_LeadStatusBatch fbe = new FBE_LeadStatusBatch();
        Database.executeBatch(fbe,40);
    }
}