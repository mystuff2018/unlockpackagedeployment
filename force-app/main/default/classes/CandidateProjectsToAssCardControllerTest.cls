/*
 * @class CandidateProjectsToAssCardController
 * @authors Pablo Dunke and Guilherme Chiossi
 * @date 04/15/2020
 */

@IsTest
private class CandidateProjectsToAssCardControllerTest 
{
    @IsTest
    static void testAssociationEngagementToOrder() 
    {
        // Create the data
        Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();

        pse__Proj__c engagement = new pse__Proj__c();
        engagement.Name = 'My Engagement';
        engagement.RecordTypeId = recordTypeId;
        engagement.Po_Number__c = '1700';
        engagement.Deal__c = '150';
        engagement.DP__c = '';
        insert engagement;

        Order order = OPRTestFactory.createSimpleOrder();
        order.PoNumber = '1800';
        order.Deal_ID__c = '150';
        order.DPID__c = '';
        update order;

        // Action
        Test.startTest();
        CandidateProjectsToAssCardController.associateOrderToEngagement(order.Id, engagement.Id);
        Test.stopTest();

        Order result = [SELECT Id, Project__c FROM Order WHERE Id =: order.Id];

        // Assertion
        System.assertEquals(engagement.Id, result.Project__c);
    }
}