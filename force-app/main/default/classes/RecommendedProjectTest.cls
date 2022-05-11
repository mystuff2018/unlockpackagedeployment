/*
 * @class RecommendedProject
 * @authors Pablo Dunke and Guilherme Chiossi
 * @date 04/15/2020
 */

@IsTest
private class RecommendedProjectTest 
{
    @IsTest
    static void getRecommendedByPoNumber() 
    {
        // Create the data
        Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();

        Account eAccount = OPRTestFactory.createSimpleAccount();
        eAccount.AccountNumber = '102400';
        update eAccount;

        pse__Proj__c engagement = new pse__Proj__c();
        engagement.Name = 'My Engagement';
        engagement.pse__Account__c = eAccount.Id;
        engagement.RecordTypeId = recordTypeId;
        engagement.Po_Number__c = '1600';
        engagement.Deal__c = '';
        engagement.DP__c = '';
        insert engagement;

        Order order = OPRTestFactory.createSimpleOrder();
        order.PoNumber = '1600';
        order.Deal_ID__c = '';
        order.DPID__c = '';
        update order;

        Account oAccount = [SELECT Id FROM Account WHERE Id =: order.Install_At_Account__c]; 
        oAccount.AccountNumber = '102400';
        update oAccount;
         
        
        // Action
        Test.startTest();
        List<SuggestedProjectAssociation> listRecommendation = RecommendedProject.getSetRecommendedEngagementIdByOrderId(order.Id);
        Test.stopTest();

        // Assertion
        System.assertEquals(1, listRecommendation.size());
        System.assertEquals(engagement.Id, listRecommendation.get(0).project.Id);
    }

    @IsTest
    static void getRecommendedByDealId() 
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
        List<SuggestedProjectAssociation> listRecommendation = RecommendedProject.getSetRecommendedEngagementIdByOrderId(order.Id);
        Test.stopTest();

        // Assertion
        System.assertEquals(1, listRecommendation.size());
        System.assertEquals(engagement.Id, listRecommendation.get(0).project.Id);
    }

    @IsTest
    static void getRecommendedByDPID() 
    {
        // Create the data
        Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();

        pse__Proj__c engagement = new pse__Proj__c();
        engagement.Name = 'My Engagement';
        engagement.RecordTypeId = recordTypeId;
        engagement.Po_Number__c = '1700';
        engagement.Deal__c = '';
        engagement.DP__c = '17';
        insert engagement;

        Order order = OPRTestFactory.createSimpleOrder();
        order.PoNumber = '1800';
        order.Deal_ID__c = '';
        order.DPID__c = '17';
        update order;

        // Action
        Test.startTest();
        List<SuggestedProjectAssociation> listRecommendation = RecommendedProject.getSetRecommendedEngagementIdByOrderId(order.Id);
        Test.stopTest();

        // Assertion
        System.assertEquals(1, listRecommendation.size());
        System.assertEquals(engagement.Id, listRecommendation.get(0).project.Id);
    }

    @IsTest
    static void getRecommendedByDealIdAndDPID() 
    {
        // Create the data
        Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();

        pse__Proj__c engagement = new pse__Proj__c();
        engagement.Name = 'My Engagement';
        engagement.RecordTypeId = recordTypeId;
        engagement.Po_Number__c = '5000';
        engagement.Deal__c = '900';
        engagement.DP__c = '48';
        insert engagement;

        Order order = OPRTestFactory.createSimpleOrder();
        order.PoNumber = '1800';
        order.Deal_ID__c = '900';
        order.DPID__c = '48';
        update order;

        // Action
        Test.startTest();
        List<SuggestedProjectAssociation> listRecommendation = RecommendedProject.getSetRecommendedEngagementIdByOrderId(order.Id);
        Test.stopTest();

        // Assertion
        System.assertEquals(1, listRecommendation.size());
        System.assertEquals(engagement.Id, listRecommendation.get(0).project.Id);
    }

    @IsTest
    static void getNoRecommendations() 
    {
        // Create the data
        Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();

        Order order = OPRTestFactory.createSimpleOrder();
        order.PoNumber = '1800';
        order.Deal_ID__c = '500';
        order.DPID__c = '25';
        update order;

        // Action
        Test.startTest();
        List<SuggestedProjectAssociation> listRecommendation = RecommendedProject.getSetRecommendedEngagementIdByOrderId(order.Id);
        Test.stopTest();

        // Assertion
        System.assertEquals(0, listRecommendation.size());
    }

    @IsTest
    static void getTwoRecommendations() 
    {
        // Create the data
        Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();

        pse__Proj__c engagement1 = new pse__Proj__c();
        engagement1.Name = 'Engagement One';
        engagement1.RecordTypeId = recordTypeId;
        engagement1.Po_Number__c = '5000';
        engagement1.Deal__c = '800';
        engagement1.DP__c = '30';
        insert engagement1;

        pse__Proj__c engagement2 = new pse__Proj__c();
        engagement2.Name = 'Engagement Two';
        engagement2.RecordTypeId = recordTypeId;
        engagement2.Po_Number__c = '1700';
        engagement2.Deal__c = '900';
        engagement2.DP__c = '12';
        insert engagement2;

        Order order = OPRTestFactory.createSimpleOrder();
        order.PoNumber = '2300';
        order.Deal_ID__c = '800';
        order.DPID__c = '12';
        update order;

        // Action
        Test.startTest();
        List<SuggestedProjectAssociation> listRecommendation = RecommendedProject.getSetRecommendedEngagementIdByOrderId(order.Id);
        Test.stopTest();

        // Assertion
        System.assertEquals(2, listRecommendation.size());
    }
}