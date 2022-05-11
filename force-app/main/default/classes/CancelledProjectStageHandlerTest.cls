@IsTest
public with sharing class CancelledProjectStageHandlerTest {
    @TestSetup
    static void setupData() {
        Order order = OPRTestFactory.createSimpleOrder();

        pse__Proj__c projectTest = new pse__Proj__c(
                Name = 'Test Project 1',
                Project_Complexity__c = 'Low',
                pse__Account__c = order.AccountId,
                pse__Is_Active__c = true,
                pse__Stage__c = 'In Progress'
        );

        insert projectTest;
    }

    @IsTest
    static void shouldSetCancelledProjectDateOnProject(){
        pse__Proj__c proj = [SELECT Id,pse__Stage__c FROM pse__Proj__c LIMIT 1];

        Test.startTest();
        proj.pse__Stage__c = 'Cancelled';
        update proj;
        Test.stopTest();

        pse__Proj__c projAfterUpdate = [SELECT Id,pse__Stage__c,Cancelled_Project_Date__c FROM pse__Proj__c LIMIT 1];

        System.assert(projAfterUpdate.Cancelled_Project_Date__c == System.today());
    }

}