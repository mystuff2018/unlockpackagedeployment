/***************************************************************************************
* Created By - Saurav Raj
* Created On - November 24, 2020
* Related Task -
* Purpose - TEST Class for  MilestoneTriggerHandler
****************************************************************************************/
@isTest
public class MilestoneTriggerHandlerTest {
    /***************************************************************************************
    * Test method test function rollUpAmountOnProjectEACRevenueAndFiedPriceRevenue
    ****************************************************************************************/
    static testmethod void rollUpAmountOnProjectEACRevenueTest(){
        //Create region
        pse__Region__c region = TestDataUtility.getRegion(True);

        //Create Account
        Account acc = TestDataUtility.createAccounts(1,false)[0];
        //Create Custom Domain
        //TestDataUtility.createDomainSettings(1,true, true);
        //Create Project
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,false);
        proj.pse__Billing_Type__c = 'Fixed Price';
        insert proj;
        //Create Milestone
        pse__Milestone__c milestone = new pse__Milestone__c();
        milestone.Name = 'test';
        milestone.pse__project__c = proj.id;
        milestone.pse__Milestone_Amount__c= 1000;
        milestone.pse__Target_Date__c= system.today();
        milestone.pse__Approved__c = false;
        insert milestone;
        test.startTest();
        milestone.pse__Approved__c = true;
        update milestone;
        pse__proj__c project = [Select name, Fixed_Price_Planned_Revenue__c From pse__Proj__c Where Id=:proj.id];
      //  System.assertEquals(1000, project.Fixed_Price_Planned_Revenue__c);
        delete milestone;
        pse__proj__c project1 = [Select name, Fixed_Price_Planned_Revenue__c From pse__Proj__c Where Id=:proj.id];
      //  System.assertEquals(null, project1.Fixed_Price_Planned_Revenue__c);
        test.stopTest();
    }

    @IsTest
    static void verifyTwoDistinctMilestonesOneBeingApprovedOtherAlreadyApproved() {
        List<pse__Milestone__c> milestoneList = new List<pse__Milestone__c>();
        List<OrderItemMilestoneAssociation__c> junctions = new List<OrderItemMilestoneAssociation__c>();
        pse__milestone__c milestone1 = new pse__milestone__c();
        pse__milestone__c milestone2 = new pse__milestone__c();

        Order order = OPRTestFactory.createSimpleOrder();
        pse__Proj__c projectTest = new pse__Proj__c(
                Name = 'Test Project 1',
                Project_Complexity__c = 'Low',
                pse__Account__c = order.AccountId,
                pse__Is_Active__c = true);

        insert(projectTest);

        List<SKU_Effort_Map__c> skuEffortMaps = new List<SKU_Effort_Map__c>();

        SKU_Effort_Map__c skuEffortMapDistinct = new SKU_Effort_Map__c(
                Active__c = true,
                Description__c = 'ProDeploy Dell Storage SC Series vAAAA SAN - Deployment Verification',
                X30_Day_Support__c = false,
                Distinct_Project__c = true,
                SKU_Number__c = '777-7777'
        );
        skuEffortMaps.add(skuEffortMapDistinct);

        SKU_Effort_Map__c skuEffortMapDistinctFalse = new SKU_Effort_Map__c(
                Active__c = true,
                Description__c = 'Testing',
                X30_Day_Support__c = false,
                Distinct_Project__c = true,
                SKU_Number__c = '111-1111'
        );
        skuEffortMaps.add(skuEffortMapDistinctFalse);

        insert skuEffortMaps;

        List<SKU_Number__c> skuNumbers = new List<SKU_Number__c>();

        SKU_Number__c skuNumberDistinct = new SKU_Number__c();
        skuNumberDistinct.SKU_Number__c = '777-7777';
        skuNumberDistinct.SKU_to_Effort_Mapping__c = skuEffortMapDistinct.Id;
        skuNumbers.add(skuNumberDistinct);

        SKU_Number__c skuNumber = new SKU_Number__c();
        skuNumber.SKU_Number__c = '111-1111';
        skuNumber.SKU_to_Effort_Mapping__c = skuEffortMapDistinctFalse.Id;
        skuNumbers.add(skuNumber);

        insert skuNumbers;

        milestone1 = new pse__Milestone__c(Name = 'Milestone 1', pse__Project__c = projectTest.Id, pse__Target_Date__c = System.today(), pse__Status__c = 'Approved');
        milestone2 = new pse__Milestone__c(Name = 'Milestone 2', pse__Project__c = projectTest.Id, pse__Target_Date__c = System.today() + 1, pse__Status__c = 'Open');
        milestoneList.add(milestone1);
        milestoneList.add(milestone2);
        insert milestoneList;

        OrderItem orderItem1 = [
                SELECT Id, Service_Is_Delivered__c, Service_Is_Not_Delivered__c,PricebookEntryId
                FROM OrderItem
                WHERE OrderId = :order.Id
                LIMIT 1
        ];

        OrderItem orderItem2 = new OrderItem();
        orderItem2.SKU_Description__c = 'SKU Desc 1';
        orderItem2.SKU_Number__c = '111-1111';
        orderItem2.Quantity = 1;
        orderItem2.UnitPrice = 1;
        orderItem2.Item_Class_Description__c = 'SVC EDT INSTLN';
        orderItem2.Tie_Number__c = '1';
        orderItem2.OrderId = order.Id;
        orderItem2.PriceBookEntryId = orderItem1.PricebookEntryId;
        orderItem2.SKU_Cost__c = 1;
        orderItem2.Unit_Selling_Price_USD__c = 1;
        orderItem2.SKU_Cost_USD__c = 1;
        insert orderItem2;

        orderItem1.SKU_Number__c = '777-7777';

        update orderItem1;

        List<orderItem> orderItems = new List<OrderItem>();
        orderItems.add(orderItem1);
        orderItems.add(orderItem2);

        OrderItemMilestoneAssociation__c junction = new OrderItemMilestoneAssociation__c(
                Order_Product__c = orderItem1.Id,
                Milestone__c = milestone1.Id);
        junctions.add(junction);

        OrderItemMilestoneAssociation__c junction2 = new OrderItemMilestoneAssociation__c(
                Order_Product__c = orderItem2.Id,
                Milestone__c = milestone2.Id);
        junctions.add(junction2);


        insert junctions;
        test.startTest();
        List<pse__Milestone__c> milestones = [SELECT Id,pse__Status__c FROM pse__Milestone__c WHERE pse__Project__c = :projectTest.Id];

        milestones[0].pse__Status__c = 'Approved';
        milestones[1].pse__Status__c = 'Approved';

        update milestones;
        test.stopTest();

        List<OrderItem> orderItemResult = [
                SELECT Id, Service_Is_Delivered__c, Service_Is_Not_Delivered__c
                FROM OrderItem
        ];

        System.debug(' ff1f1 orderItemResult[0] : '+orderItemResult[0]+ '   -  2  - '+orderItemResult[1] +'    ----Milestones : '+milestones);
      //  System.AssertEquals(true, orderItemResult[0].Service_Is_Delivered__c);
        System.AssertEquals(true, orderItemResult[1].Service_Is_Delivered__c);

    }
    @IsTest
    static void verifyOne30DaysOrderProductProcessWhenMilestoneIsApproved() {
        Order order = OPRTestFactory.createSimpleOrder();
        pse__Proj__c projectTest = new pse__Proj__c(
                Name = 'Test Project 1',
                Project_Complexity__c = 'Low',
                pse__Account__c = order.AccountId,
                pse__Is_Active__c = true);
        insert(projectTest);
        SKU_Effort_Map__c skuEffortMapDistinct = new SKU_Effort_Map__c(
                Active__c = true,
                Description__c = 'ProDeploy Dell Storage SC Series vHHH SAN - Deployment Verification',
                X30_Day_Support__c = true,
                SKU_Number__c = '777-7777'
        );
        insert skuEffortMapDistinct;
        SKU_Number__c skuNumberDistinct = new SKU_Number__c();
        skuNumberDistinct.SKU_Number__c = '777-7777';
        skuNumberDistinct.SKU_to_Effort_Mapping__c = skuEffortMapDistinct.Id;
        insert skuNumberDistinct;
        pse__Milestone__c milestone = new pse__Milestone__c(Name = 'Milestone 1', pse__Project__c = projectTest.Id, pse__Target_Date__c = System.today());
        insert milestone;
        OrderItem orderItem = [
                SELECT Id, Service_Is_Delivered__c, Service_Is_Not_Delivered__c
                FROM OrderItem
                WHERE OrderId = :order.Id
                LIMIT 1
        ];
        orderItem.SKU_Number__c = '777-7777';
        update orderItem;
        System.debug('ff1f1  orderItem' + orderItem);
        OrderItemMilestoneAssociation__c junction = new OrderItemMilestoneAssociation__c();
        junction.Order_Product__c = orderItem.Id;
        junction.Milestone__c = milestone.Id;
        insert junction;
        Test.startTest();
        milestone.pse__Status__c = 'Approved';
        update milestone;
        Test.stopTest();
        OrderItem afterUpdateOrderItem = [
                SELECT Id, Service_Is_Delivered__c, Service_Is_Not_Delivered__c
                FROM OrderItem
                WHERE OrderId = :order.Id
                LIMIT 1
        ];
        System.debug('ff1f2  afterUpdateOrderItem' + afterUpdateOrderItem);
        pse__Milestone__c milestoneList = [SELECT id,Name,pse__Project__c,pse__Target_Date__c FROM pse__Milestone__c];
        System.debug('milestoneList ff1f3: ' +milestoneList + 'orderItem : ' +orderItem);
        System.AssertEquals(false, orderItem.Service_Is_Delivered__c, 'The order item should not be tagged as is delivered since is a 30 day');
    }
    @IsTest
    static void verifyTwoDistinctMilestonesBeingApproved() {
        List<pse__Milestone__c> milestoneList = new List<pse__Milestone__c>();
        List<OrderItemMilestoneAssociation__c> junctions = new List<OrderItemMilestoneAssociation__c>();
        pse__milestone__c milestone1 = new pse__milestone__c();
        pse__milestone__c milestone2 = new pse__milestone__c();

        Order order = OPRTestFactory.createSimpleOrder();
        pse__Proj__c projectTest = new pse__Proj__c(
                Name = 'Test Project 1',
                Project_Complexity__c = 'Low',
                pse__Account__c = order.AccountId,
                pse__Is_Active__c = true);

        insert(projectTest);

        List<SKU_Effort_Map__c> skuEffortMaps = new List<SKU_Effort_Map__c>();

        SKU_Effort_Map__c skuEffortMapDistinct = new SKU_Effort_Map__c(
                Active__c = true,
                Description__c = 'ProDeploy Dell Storage SC Series vQQQ SAN - Deployment Verification',
                X30_Day_Support__c = false,
                Distinct_Project__c = true,
                SKU_Number__c = '777-7777'
        );
        skuEffortMaps.add(skuEffortMapDistinct);

        SKU_Effort_Map__c skuEffortMapDistinctFalse = new SKU_Effort_Map__c(
                Active__c = true,
                Description__c = 'Testing',
                X30_Day_Support__c = false,
                Distinct_Project__c = true,
                SKU_Number__c = '111-1111'
        );
        skuEffortMaps.add(skuEffortMapDistinctFalse);

        insert skuEffortMaps;

        List<SKU_Number__c> skuNumbers = new List<SKU_Number__c>();

        SKU_Number__c skuNumberDistinct = new SKU_Number__c();
        skuNumberDistinct.SKU_Number__c = '777-7777';
        skuNumberDistinct.SKU_to_Effort_Mapping__c = skuEffortMapDistinct.Id;
        skuNumbers.add(skuNumberDistinct);

        SKU_Number__c skuNumber = new SKU_Number__c();
        skuNumber.SKU_Number__c = '111-1111';
        skuNumber.SKU_to_Effort_Mapping__c = skuEffortMapDistinctFalse.Id;
        skuNumbers.add(skuNumber);

        insert skuNumbers;

        milestone1 = new pse__Milestone__c(Name = 'Milestone 1', pse__Project__c = projectTest.Id, pse__Target_Date__c = System.today(), pse__Status__c = 'Open');
        milestone2 = new pse__Milestone__c(Name = 'Milestone 2', pse__Project__c = projectTest.Id, pse__Target_Date__c = System.today(), pse__Status__c = 'Open');
        milestoneList.add(milestone1);
        milestoneList.add(milestone2);
        insert milestoneList;

        OrderItem orderItem1 = [
                SELECT Id, Service_Is_Delivered__c, Service_Is_Not_Delivered__c,PricebookEntryId
                FROM OrderItem
                WHERE OrderId = :order.Id
                LIMIT 1
        ];

        OrderItem orderItem2 = new OrderItem();
        orderItem2.SKU_Description__c = 'SKU Desc 1';
        orderItem2.SKU_Number__c = '111-1111';
        orderItem2.Quantity = 1;
        orderItem2.UnitPrice = 1;
        orderItem2.Item_Class_Description__c = 'SVC EDT INSTLN';
        orderItem2.Tie_Number__c = '1';
        orderItem2.OrderId = order.Id;
        orderItem2.PriceBookEntryId = orderItem1.PricebookEntryId;
        orderItem2.SKU_Cost__c = 1;
        orderItem2.Unit_Selling_Price_USD__c = 1;
        orderItem2.SKU_Cost_USD__c = 1;
        insert orderItem2;

        orderItem1.SKU_Number__c = '777-7777';

        update orderItem1;

        List<orderItem> orderItems = new List<OrderItem>();
        orderItems.add(orderItem1);
        orderItems.add(orderItem2);

        for (pse__Milestone__c milestone : milestoneList) {
            for (orderItem oi : orderItems) {
                OrderItemMilestoneAssociation__c junction = new OrderItemMilestoneAssociation__c(
                        Order_Product__c = oi.Id,
                        Milestone__c = milestone.Id);
                junctions.add(junction);
                break;
            }
        }

        insert junctions;
        test.startTest();
        List<pse__Milestone__c> milestones = [SELECT Id,pse__Status__c FROM pse__Milestone__c WHERE pse__Project__c = :projectTest.Id and pse__Status__c != 'Approved'];

        milestones[0].pse__Status__c = 'Approved';
        milestones[1].pse__Status__c = 'Approved';

        update milestones;
        test.stopTest();

        OrderItem orderItemResult = [
                SELECT Id, Service_Is_Delivered__c, Service_Is_Not_Delivered__c
                FROM OrderItem
                WHERE OrderId = :order.Id
                LIMIT 1
        ];

        System.AssertEquals(true, orderItemResult.Service_Is_Delivered__c);
    }
    @IsTest
    static void verifyTwoDistinctMilestonesProcessWhenOneIsApproved() {
        List<pse__Milestone__c> milestoneList = new List<pse__Milestone__c>();
        List<OrderItemMilestoneAssociation__c> junctions = new List<OrderItemMilestoneAssociation__c>();


        Order order = OPRTestFactory.createSimpleOrder();
        pse__Proj__c projectTest = new pse__Proj__c(
                Name = 'Test Project 1',
                Project_Complexity__c = 'Low',
                pse__Account__c = order.AccountId,
                pse__Is_Active__c = true);

        insert(projectTest);

        SKU_Effort_Map__c skuEffortMapDistinct = new SKU_Effort_Map__c(
                Active__c = true,
                Description__c = 'ProDeploy Dell Storage SC Series vIIII SAN - Deployment Verification',
                X30_Day_Support__c = false,
                Distinct_Project__c = true
                //SKU_Number__c = '777-7777'
        );

        insert skuEffortMapDistinct;

        SKU_Effort_Map__c skuEffortMapDistinct2 = new SKU_Effort_Map__c(
                Active__c = true,
                Description__c = 'ProDeploy Dell Storage SC Series vTTT SAN - Deployment Verification',
                X30_Day_Support__c = false,
                Distinct_Project__c = true
                //SKU_Number__c = '777-3335'
        );
        insert skuEffortMapDistinct2;
        List<SKU_Number__c> skuNumberDistinctList = new List<SKU_Number__c>();
        SKU_Number__c skuNumberDistinct = new SKU_Number__c();
        skuNumberDistinct.SKU_Number__c = '777-7777';
        skuNumberDistinct.SKU_to_Effort_Mapping__c = skuEffortMapDistinct.Id;
        skuNumberDistinctList.add(skuNumberDistinct);
        SKU_Number__c skuNumberDistinct2 = new SKU_Number__c();
        skuNumberDistinct2.SKU_Number__c = '777-3335';
        skuNumberDistinct2.SKU_to_Effort_Mapping__c = skuEffortMapDistinct.Id;
        skuNumberDistinctList.add(skuNumberDistinct2);

        insert skuNumberDistinctList;

        pse__Milestone__c milestone1 = new pse__Milestone__c(Name = 'Milestone 1', pse__Project__c = projectTest.Id, pse__Target_Date__c = System.today(), pse__Status__c = 'Planned');
        pse__Milestone__c milestone2 = new pse__Milestone__c(Name = 'Milestone 2', pse__Project__c = projectTest.Id, pse__Target_Date__c = System.today(), pse__Status__c = 'Open');
        milestoneList.add(milestone1);
        milestoneList.add(milestone2);
        insert milestoneList;
        System.debug('pp1p1 projectTest.Id: '+projectTest.Id);

        OrderItem orderItemForTest = [
                SELECT Id, Service_Is_Delivered__c, Service_Is_Not_Delivered__c,PricebookEntryId
                FROM OrderItem
                WHERE OrderId = :order.Id
                LIMIT 1
        ];
        orderItemForTest.SKU_Number__c = '777-7777';
        update orderItemForTest;

        OrderItem orderItem2 = new OrderItem();
        orderItem2.SKU_Description__c = 'SKU Desc 1';
        orderItem2.SKU_Number__c = '777-3335';
        orderItem2.Quantity = 1;
        orderItem2.UnitPrice = 1;
        orderItem2.Item_Class_Description__c = 'SVC EDT INSTLN';
        orderItem2.Tie_Number__c = '1';
        orderItem2.OrderId = order.Id;
        orderItem2.PriceBookEntryId = orderItemForTest.PricebookEntryId;
        orderItem2.SKU_Cost__c = 1;
        orderItem2.Unit_Selling_Price_USD__c = 1;
        orderItem2.SKU_Cost_USD__c = 1;
        insert orderItem2;

        OrderItemMilestoneAssociation__c junction = new OrderItemMilestoneAssociation__c(
                Order_Product__c = orderItemForTest.Id,
                Milestone__c = milestoneList[0].Id);
        junctions.add(junction);
        OrderItemMilestoneAssociation__c junction2 = new OrderItemMilestoneAssociation__c(
                Order_Product__c = orderItem2.Id,
                Milestone__c = milestoneList[1].Id);
        junctions.add(junction2);
        insert junctions;

        List<OrderItem> orderItemPre = new List<OrderItem> ([
                SELECT Id,OrderId, Service_Is_Delivered__c, Service_Is_Not_Delivered__c
                FROM OrderItem
        ]);
        System.debug('orderItemPre:  '+orderItemPre);

        test.startTest();
        List<pse__Milestone__c> milestones = [SELECT Id,pse__Status__c FROM pse__Milestone__c WHERE pse__Project__c = :projectTest.Id];
        System.debug('milestone list in test: ' + milestones);
        milestones[0].pse__Status__c = 'Approved';

        update milestones[0];
        test.stopTest();

        List<pse__Milestone__c> milestonesEnd = [SELECT Id,pse__Status__c,pse__Project__c FROM pse__Milestone__c WHERE pse__Project__c = :projectTest.Id];
        system.debug('ff2ff2 milestones: '+milestonesEnd);

        List<OrderItem> orderItemResult = new List<OrderItem> ([
                SELECT Id,OrderId, Service_Is_Delivered__c, Service_Is_Not_Delivered__c
                FROM OrderItem
        ]);
 System.debug('orderItemResult:  '+orderItemResult);

      //  System.AssertEquals(false, orderItemResult[0].Service_Is_Delivered__c);
    }
    @IsTest
    static void verifyOneDistinctMilestonesProcessWhenCanceled() {

        Order order = OPRTestFactory.createSimpleOrder();
        pse__Proj__c projectTest = new pse__Proj__c(
                Name = 'Test Project 1',
                Project_Complexity__c = 'Low',
                pse__Account__c = order.AccountId,
                pse__Is_Active__c = true);

        insert(projectTest);

        SKU_Effort_Map__c skuEffortMapDistinct = new SKU_Effort_Map__c(
                Active__c = true,
                Description__c = 'ProDeploy Dell Storage SC Series vOOO SAN - Deployment Verification',
                X30_Day_Support__c = false,
                Distinct_Project__c = true,
                SKU_Number__c = '777-7777'
        );

        insert skuEffortMapDistinct;

        SKU_Number__c skuNumberDistinct = new SKU_Number__c();
        skuNumberDistinct.SKU_Number__c = '777-7777';
        skuNumberDistinct.SKU_to_Effort_Mapping__c = skuEffortMapDistinct.Id;

        insert skuNumberDistinct;

        pse__Milestone__c milestone = new pse__Milestone__c(Name = 'Milestone 1', pse__Project__c = projectTest.Id, pse__Target_Date__c = System.today());

        insert milestone;

        OrderItem orderItem = [
                SELECT Id, Service_Is_Delivered__c, Service_Is_Not_Delivered__c
                FROM OrderItem
                WHERE OrderId = :order.Id
                LIMIT 1
        ];

        orderItem.SKU_Number__c = '777-7777';

        update orderItem;

        OrderItemMilestoneAssociation__c junction = new OrderItemMilestoneAssociation__c();
        junction.Order_Product__c = orderItem.Id;
        junction.Milestone__c = milestone.Id;

        insert junction;

        milestone.pse__Status__c = 'Canceled';

        update milestone;

        pse__Proj__c projectUpdate = [SELECT Id, Closure_Reason__c FROM pse__Proj__c WHERE Id = :projectTest.Id];

        orderItem = [
                SELECT Id, Service_Is_Delivered__c, Service_Is_Not_Delivered__c
                FROM OrderItem
                WHERE OrderId = :order.Id
                LIMIT 1
        ];

        System.AssertEquals(false, orderItem.Service_Is_Delivered__c, 'It must be false');
    }
    @IsTest
    static void verifyOneDistinctMilestonesProcessWhenApproved() {

        Order order = OPRTestFactory.createSimpleOrder();
        pse__Proj__c projectTest = new pse__Proj__c(
                Name = 'Test Project 1',
                Project_Complexity__c = 'Low',
                pse__Account__c = order.AccountId,
                pse__Is_Active__c = true);

        insert(projectTest);

        SKU_Effort_Map__c skuEffortMapDistinct = new SKU_Effort_Map__c(
                Active__c = true,
                Description__c = 'ProDeploy Dell Storage SC Series vUUU SAN - Deployment Verification',
                X30_Day_Support__c = false,
                Distinct_Project__c = true,
                SKU_Number__c = '777-7777'
        );

        insert skuEffortMapDistinct;

        SKU_Number__c skuNumberDistinct = new SKU_Number__c();
        skuNumberDistinct.SKU_Number__c = '777-7777';
        skuNumberDistinct.SKU_to_Effort_Mapping__c = skuEffortMapDistinct.Id;

        insert skuNumberDistinct;

        pse__Milestone__c milestone = new pse__Milestone__c(Name = 'Milestone t', pse__Project__c = projectTest.Id, pse__Target_Date__c = System.today());

        insert milestone;

        OrderItem orderItem = [
                SELECT Id, Service_Is_Delivered__c, Service_Is_Not_Delivered__c
                FROM OrderItem
                WHERE OrderId = :order.Id
                LIMIT 1
        ];

        orderItem.SKU_Number__c = '777-7777';

        update orderItem;

        OrderItemMilestoneAssociation__c junction = new OrderItemMilestoneAssociation__c();
        junction.Order_Product__c = orderItem.Id;
        junction.Milestone__c = milestone.Id;

        insert junction;

        Test.StartTest();
        milestone.pse__Status__c = 'Approved';
        update milestone;
        test.stopTest();

        List<pse__Milestone__c>  miletoneAfterC = [SELECT ID,Name,pse__Project__c,pse__Target_Date__c FROM pse__Milestone__c ];
        List<OrderItem> orderAfterItem = [
                SELECT Id, Service_Is_Delivered__c, Service_Is_Not_Delivered__c
                FROM OrderItem
                WHERE OrderId = :order.Id

        ];

        System.debug('ff1f2 orderAfterItem:   '+orderAfterItem +' milestone: '+miletoneAfterC +'  zz order.Id  zz:'+order.Id);
        System.AssertEquals(true, orderAfterItem[0].Service_Is_Delivered__c);
    }
    @IsTest
    static void verifyOne30DaysOrderProductProcessWhenMilestone30DaysMilestoneIsApproved() {
        Order order = OPRTestFactory.createSimpleOrder();
        pse__Proj__c projectTest = new pse__Proj__c(
                Name = 'Test Project 1',
                Project_Complexity__c = 'Low',
                pse__Account__c = order.AccountId,
                pse__Is_Active__c = true);
        insert(projectTest);
        SKU_Effort_Map__c skuEffortMapDistinct = new SKU_Effort_Map__c(
                Active__c = true,
                Description__c = 'ProDeploy Dell Storage SC Series vSSS SAN - Deployment Verification',
                X30_Day_Support__c = true,
                SKU_Number__c = '777-7777'
        );
        insert skuEffortMapDistinct;
        SKU_Number__c skuNumberDistinct = new SKU_Number__c();
        skuNumberDistinct.SKU_Number__c = '777-7777';
        skuNumberDistinct.SKU_to_Effort_Mapping__c = skuEffortMapDistinct.Id;
        insert skuNumberDistinct;
        pse__Milestone__c milestone = new pse__Milestone__c(Name = '30 Day Support', pse__Project__c = projectTest.Id, pse__Target_Date__c = System.today());
        insert milestone;
        OrderItem orderItem = [
                SELECT Id, Service_Is_Delivered__c, Service_Is_Not_Delivered__c
                FROM OrderItem
                WHERE OrderId = :order.Id
                LIMIT 1
        ];
        orderItem.SKU_Number__c = '777-7777';
        update orderItem;
        OrderItemMilestoneAssociation__c junction = new OrderItemMilestoneAssociation__c();
        junction.Order_Product__c = orderItem.Id;
        junction.Milestone__c = milestone.Id;
        insert junction;
        Test.startTest();
        milestone.pse__Status__c = 'Approved';
        update milestone;
        Test.stopTest();
        OrderItem orderItemAfter = [
                SELECT Id, Service_Is_Delivered__c, Service_Is_Not_Delivered__c
                FROM OrderItem
                WHERE OrderId = :order.Id
                LIMIT 1
        ];


        System.debug('ff1f1 orderItem: '+orderItem +'  -   Milestone:' + milestone);

        System.AssertEquals(True, orderItemAfter.Service_Is_Delivered__c, 'The order item should be tagged as is delivered since is a 30 day Milestone');
    }
}