global class OrderProcessScheduler implements Schedulable {
    
    private static FFProcessControlSettings__c executionControl = FFProcessControlSettings__c.getOrgDefaults();
    private static final String JOB_NAME = 'Order Processing';
    private static final Decimal NEXT_EXECUTION_TIME = executionControl != null ? executionControl.NextBatchExecution__c : 5;
    private static final Integer CREATE_PROJECT_BATCH_SIZE = executionControl != null ? Integer.valueOf(executionControl.BatchSize__c) : 200;

    global void execute(SchedulableContext sc) {
        
        try{
            Database.executeBatch(new OrderProcessHandler(), CREATE_PROJECT_BATCH_SIZE);
        }
        catch(Exception e){
            insert SaveResultExceptionLogger.createExceptionLogger(e, OrderProcessScheduler.Class.getName(), 'Order processing schedulable context');   
        }
        finally{
            scheduleNextExecution();
            System.abortJob(SC.getTriggerId());
        }
    }
    
    public void scheduleNextExecution(){
        Integer nextTime = Integer.valueOf(NEXT_EXECUTION_TIME);
        DateTime nextExecution = DateTime.now().addMinutes(nextTime);
        String sch = nextExecution.second() + ' ' + nextExecution.minute() + ' ' + nextExecution.hour() + ' ' + nextExecution.day() + ' ' + nextExecution.month() + ' ?';
        if(!Test.isRunningTest()){
           String jobId = System.schedule(JOB_NAME + ' - ' + DateTime.now(), sch, this);
        }
    }
}