/*
 *@ Class Name                                                    : FBE_Test_onLeaveBatch 
 *@ Description                                                   : Test Class to test the batch job FBE_onLeaveBatch and the scheduler FBE_onLeaveScheduler
 *@ CreatedBy                                                     : Deloitte Consulting
 *@ CreatedOn                                                     : 01-08-2017 [Namita Verma]
 *@ Modification Log                                              :                     
 */
@isTest(seeAllData = False)
public without sharing class FBE_Test_onLeaveBatch {
    static testMethod void FBE_Test_onLeaveBatch() {

        //Create a User
        List < User > lUsr = FBE_Test_Utility.createUser('System Administrator', 2, 'ab');
        update lUsr;
        system.assertNotEquals(null, lUsr[0].id,'Null check');
        system.assertNotEquals(null, lUsr[1].id,'Null check');

        //Update the Leave Details of User created
        lUsr[0].FBE_Start_Date__c = Date.today() - 8;
        lUsr[0].FBE_End_Date__c = Date.today() - 1;
        lUsr[0].FBE_Delegated_User__c = lUsr[1].id;
        update lUsr[0];

        test.startTest();
        //Test the Batchable Class
        FBE_onLeaveBatch usrBatch = new FBE_onLeaveBatch();
        Database.executeBatch(usrBatch);
        //Test the Scheduler Class
        FBE_onLeaveScheduler usrSchedule = new FBE_onLeaveScheduler();
        String sch = '0 0 5 * * ?';
        system.schedule('Test Scheduler Class', sch, usrSchedule);
        test.stopTest();

    }
}