public without sharing class FBE_onLeaveScheduler implements Schedulable
{
    public void execute(SchedulableContext sc)
    {
        // We now call the batch class to be scheduled
        FBE_onLeaveBatch b = new FBE_onLeaveBatch ();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,200);
    }
   
}