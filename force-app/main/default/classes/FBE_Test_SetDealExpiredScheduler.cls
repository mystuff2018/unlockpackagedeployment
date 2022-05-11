/**************
 *@ Class Name        : FBE_Test_SetDealExpiredScheduler
 *@ Description       : Test class to create test for FBE_SetDealExpiredScheduler.
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 12-11-2019
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script to test for FBE_SetDealExpiredScheduler Apex Scheduled Job
						Version 2.0 - [Abhishek Kawle] 03/02/2020 : Commented code to evaluate Next run time of scheduler, since it will cause issues depending on when the scheduler test class is run.
 ***************/
@isTest(seeAllData=false)
public class FBE_Test_SetDealExpiredScheduler {
    /**************
     * @MethodName    : testScheduler
     * @Trigger       : -
     * @Description   : Test scheduled job parameters are set as per expectation by system
     ***************/
    static TestMethod void testScheduler(){
        Test.startTest();
        Datetime curTime = System.Now();
        String CRON_EXP = String.valueOf('0' + ' ' + '0' + ' ' + '0' + ' '  + String.valueOf(curTime.day()) +  ' ' + String.valueOf(curTime.month()) + ' '  + '? ' + String.valueOf(curTime.Year() +2));
        //Datetime newDate = curTime.addYears(2);
        //String nextRunTime = (String.valueOf(newDate));
        //String nextRunExp = nextRunTime.substringBefore(' ');
        //nextrunTime = nextRunExp + ' 00:00:00';
        
        String jobId = System.schedule('testSyncTeamScheduledApex', CRON_EXP, new FBE_SetDealExpiredScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                         FROM CronTrigger WHERE id= :jobId];
        
        //Verify CRON Expressions are same.
        System.assertEquals(CRON_EXP, ct.CronExpression,'CRON Expression');
        
        //Verify the Job has not run.
        System.assertEquals(0, ct.TimesTriggered,'Times triggered');
        
        //Verify the next time the job will run. 
        //System.assertEquals(nextrunTime, String.valueOf(ct.NextFireTime),'Next Run time');
        
        Test.stopTest();
    }
}