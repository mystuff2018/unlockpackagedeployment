@isTest
private class UpdateOrdersAfter30DaysSupportTest {

    public static String CRON_EXP = '0 0 0 19 6 ? 2019';
    static testmethod void testScheduledJob() {
        
        List<pse__Region__c> regions = new List<pse__Region__c>();
        
        regions.add(new pse__Region__c (
            Name = 'Test R1',
            ISO_Country_Code__c = 'R1'
        ));
        
        insert(regions);
        // Create some out of date Opportunity records
        List<pse__Proj__c> prjst = new List<pse__Proj__c>();
        Date closeDate = Date.today().addDays(-7);
        for (Integer i=0; i<5; i++) {
            pse__Proj__c o = new pse__Proj__c(
            Name = 'Test Proj  ' + i,
            pse__Project_Phase__c = 'Close',
            pse__Stage__c = 'On Hold',
            pse__Is_Template__c = false,
            pse__Is_Active__c = true,
            pse__Start_Date__c = Date.today(),
            pse__Region__c = regions[0].Id,
            Project_Visibility__c = 'All',
            PM_Complexity__c = 'Low',
            Initiate_Customer_Contact__c = true,
            Planning_and_Design__c = true,
            Delivery_and_Implementation__c = true,
            On_Hold_Reason__c='30 Day Support',
            Closure_Reason__c = 'Services Delivered',
            On_Hold_Date__c = date.newInstance(2019, 6, 6),
            Local_Channel__c = '1212',
            BUID__c = '1212');
            
            prjst.add(o);
        }
        insert prjst;
        
        // Get the IDs of the prjs we just inserted
        Map<Id, pse__Proj__c> opptyMap = new Map<Id, pse__Proj__c>(prjst);
        List<Id> opptyIds = new List<Id>(opptyMap.keySet());
        Test.startTest();
        // Schedule the test job
        String sch = '0 0 23 * * ?';
        UpdateOrdersAfter30DaysSupport updateOrdersClass = new UpdateOrdersAfter30DaysSupport();
        String jobId = System.schedule('UpdateOrdersAfter30DaysSupportSchedule', sch, updateOrdersClass);
        
        system.debug('Just started executing Batch for UpdateOrdersAfter30DaysSupport.');
        Database.executeBatch(updateOrdersClass, 5);

        Test.stopTest(); 
        
        // Verify the scheduled job has not run yet.
        List<Task> lt = [SELECT Id 
            FROM Task 
            WHERE WhatId IN :opptyIds];
        System.assertEquals(0, lt.size(), 'Tasks exist before job has run');
        // Stopping the test will run the job synchronously
              
        // Check schedulable is in the job list
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals('UpdateOrdersAfter30DaysSupport', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');
    
        // check apex batch is in the job list
        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
        System.assertEquals(2, jobsApexBatch.size(), 'expecting one apex batch job');
        System.assertEquals('UpdateOrdersAfter30DaysSupport', jobsApexBatch[0].ApexClass.Name, 'expecting specific batch job');

        pse__Proj__c prj = [Select Id, pse__Stage__c, On_Hold_Reason__c From pse__Proj__c LIMIT 1];
        system.debug('Project = '+ prj);
        System.assert(prj.pse__Stage__c == 'Closure');
        System.assert(prj.On_Hold_Reason__c == null);
    }

    @isTest
    static void should_close_the_30days_projects_batch() {
        // Arrange
        createData(6);

        // Act
        Test.startTest();
        UpdateOrdersAfter30DaysSupport updateOrdersClass = new UpdateOrdersAfter30DaysSupport();
        Id batchId = Database.executeBatch(updateOrdersClass);
        Test.stopTest();

        // Assert
        List<pse__Milestone__c> milestoneResult = [SELECT Id FROM pse__Milestone__c WHERE pse__Status__c = 'Approved'];
        List<OrderItem> orderItemResult = [SELECT Id FROM OrderItem WHERE Service_Is_Delivered__c = true];
        List<pse__Proj__c> projectClosureResult = [SELECT Id FROM pse__Proj__c WHERE pse__Stage__c = 'Closure'];

        System.assertEquals(6, milestoneResult.size(), 'The milestoneResult should have 6 milestones.');
        System.assertEquals(6, orderItemResult.size(), 'The orderItemResult should have 6 order item.');
        System.assertEquals(6, projectClosureResult.size(), 'The projectResult should have 6 Project.');
    }

    

    @isTest              
    static void should_close_the_30days_project() {
        // Arrange
        createData(1);    

        // Act
        Test.startTest();

        UpdateOrdersAfter30DaysSupport updateOrdersClass = new UpdateOrdersAfter30DaysSupport();
        Id batchId = Database.executeBatch(updateOrdersClass);

        Test.stopTest();
    
        // Assert
        // Then the system updates the 30 day config milestone to Approved status 
        pse__Milestone__c milestoneResult = [SELECT Id, pse__Status__c FROM pse__Milestone__c];
        System.assertEquals('Approved', milestoneResult.pse__Status__c, 'The Milestone Status should be Approved.');

        // and the system sets Service is Delivered checkbox on the order items tied to the milestone
        OrderItem orderItemResult = [SELECT Id, Service_Is_Delivered__c, Approved_Rejected_Timestamp__c FROM OrderItem];
        System.assertEquals(true, orderItemResult.Service_Is_Delivered__c, 'The OrderItem Service Is Delivered field should be checked.');

        // and the system sets the Order Item Approval/Reject Timestamp field to the current date
        System.assertEquals(Date.today(), orderItemResult.Approved_Rejected_Timestamp__c.date(), 'The OrderItem Approved / Rejected Timestamp field should be the current date.');

        // and the system updates the project stage field to Closure
        pse__Proj__c projectResult = [SELECT Id, pse__Stage__c, On_Hold_Reason__c FROM pse__Proj__c];
        System.assertEquals('Closure', projectResult.pse__Stage__c, 'The Project Stage should be Closure.');

        // and the system updates the project On Hold Reason to blank
        System.assert(String.isEmpty(projectResult.On_Hold_Reason__c), 'The Project On Hold Reason should be blank');
    }

    private static void createData(Integer quantityData) {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // Region
            pse__Region__c region = new pse__Region__c (
                Name = 'Test Region',
                ISO_Country_Code__c = 'RG'
            );
            INSERT region;

            // Product
            Product2 product = new Product2(
                Name = 'Test product'
            );
            INSERT product;
            List<PricebookEntry> pbentry = [Select ID from PricebookEntry where Product2Id =:product.Id limit 1];
            if(pbentry == null || pbentry.size() == 0){
                // Pricebook
                PriceBookEntry priceBookEntry = new PriceBookEntry(
                    PriceBook2Id = Test.getStandardPricebookId(),
                    Product2Id = product.Id,
                    IsActive = true,
                    UnitPrice = 1
                );
                INSERT priceBookEntry;
                pbentry.add(priceBookEntry);
            }
            List<pse__Proj__c> projects = new List<pse__Proj__c>();
            List<Account> accounts = new List<Account>();

            for (Integer i = 0; i < quantityData; i++) {
                // Project
                pse__Proj__c project = new pse__Proj__c(
                    Name = 'Test Proj ' + String.valueOf(i),
                    DP__c = String.valueOf(i),
                    pse__Project_Phase__c = 'Setup',
                    pse__Stage__c = 'On Hold',
                    pse__Is_Template__c = false,
                    pse__Is_Active__c = true,
                    pse__Start_Date__c = Date.today(),
                    pse__Region__c = region.Id,
                    Project_Visibility__c = 'All',
                    PM_Complexity__c = 'Low',
                    Initiate_Customer_Contact__c = true,
                    Planning_and_Design__c = true,
                    Delivery_and_Implementation__c = true,
                    On_Hold_Date__c = Date.today().addDays(-10),
                    On_Hold_Reason__c = '30 Day Support',
                    Closure_Reason__c = 'Services Delivered',
                    Deal_Type__c = 'Standard',
                    Local_Channel__c = '1212',
                    BUID__c = '1212'

                );

                projects.add(project);
                
                // Accounts
                Account account = new Account(Name = 'Test Account' + String.valueOf(i));
                accounts.add(account); 
            }
            INSERT projects;
            INSERT accounts;

            List<pse__Milestone__c> milestones = new List<pse__Milestone__c>();
            List<Order> orders = new List<Order>();

            for (Integer i = 0; i < quantityData; i++) {
                // Milestone
                pse__Milestone__c milestone = new pse__Milestone__c(
                    Name = '30 Day Support ' + String.valueOf(i),
                    pse__Status__c = 'Open',
                    pse__Target_Date__c = Date.today().addDays(-10),
                    pse__Project__c = projects[i].Id, 
                    Current__c = true,
                    pse__Actual_Date__c = null,
                    pse__Include_In_Financials__c = false
                );
                
                milestones.add(milestone);

                // Order
                Order order = new Order(
                    AccountId = accounts[i].Id,
                    EffectiveDate = Date.today(),
                    Status = 'BK',
                    PoNumber = '888999' + String.valueOf(i),
                    Deal_ID__c = '000111' + String.valueOf(i),
                    OrderNumber__c = '555666' + String.valueOf(i),
                    BUID__c = '11',
                    PriceBook2Id = Test.getStandardPricebookId()
                );

                orders.add(order);
            }
            INSERT milestones;
            INSERT orders;
            
            List<OrderItem> orderItems = new List<OrderItem>();
            for (Integer i = 0; i < quantityData; i++) {
                // Order Item
                OrderItem orderItem = new OrderItem(
                    SKU_Description__c = 'SKU Desc ' + String.valueOf(i),
                    SKU_Number__c = '777-100' + String.valueOf(i),
                    Quantity = 1,
                    UnitPrice = 2,
                    Item_Class_Description__c = 'SVC EDT INSTLN',
                    Tie_Number__c = String.valueOf(i),
                    OrderId = orders[i].Id,
                    PriceBookEntryId = pbentry[0].Id,
                    Project__c = projects[i].Id
                );

                orderItems.add(orderItem);
            }
            INSERT orderItems;

            List<OrderItemMilestoneAssociation__c> juntionObjects = new List<OrderItemMilestoneAssociation__c>();
            for (Integer i = 0; i < quantityData; i++) {
                OrderItemMilestoneAssociation__c junction = new OrderItemMilestoneAssociation__c();
                junction.Order_Product__c =  orderItems[i].Id;
                junction.Milestone__c = milestones[i].Id;

                juntionObjects.add(junction);
            }
            INSERT juntionObjects;
        }
    }
}