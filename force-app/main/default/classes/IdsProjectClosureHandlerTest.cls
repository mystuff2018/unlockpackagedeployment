@isTest
public class IdsProjectClosureHandlerTest {
    
    @testSetup static void setupProjects() {
       
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            Schema.Location objLocation = new Schema.Location();
            objLocation.OwnerId = UserInfo.getUserId();
            objLocation.Name = '233 N Michigan Ave_Chicago';
            objLocation.CurrencyIsoCode = 'USD';
            objLocation.LocationType = 'Site';
            objLocation.IsMobile = false;
            objLocation.IsInventoryLocation = false;
            insert objLocation;

            Schema.Address objAddress = new Schema.Address();
            objAddress.CurrencyIsoCode = 'USD';
            objAddress.ParentId = objLocation.Id;
            objAddress.LocationType = 'Warehouse';
            objAddress.AddressType = 'Mailing';
            objAddress.Street = '233 North Michigan Avenue';
            objAddress.City = 'Chicago';
            objAddress.State = 'Illinois';
            objAddress.PostalCode = '60601';
            objAddress.Country = 'United States';
            objAddress.StateCode = 'IL';
            objAddress.CountryCode = 'US';
            objAddress.Latitude = 41.887140000000000;
            objAddress.Longitude = -87.623288000000000;
            objAddress.GeocodeAccuracy = 'Address';
            insert objAddress;
            
            List<pse__Region__c> regions = new List<pse__Region__c>();
            
            regions.add(new pse__Region__c (
                Name = 'Test R1',
                ISO_Country_Code__c = 'R1'
            ));
            
            insert regions;
            
            Profile profile = [
                SELECT Id 
                FROM Profile 
                WHERE Name = 'PSA Project Manager'
            ];
            
             Account account = new Account(
                Name = 'Test account'
            );
            insert account;
            
            User userIns = new User(
                UserName = 'pm_test_user@dell.com',
                LastName = 'One',
                Email = 'pm_test_user@dell.com',
                Alias = 't1',
                CommunityNickname = 't1',
                Federal_Access__c = false,
                FederationIdentifier = '22334466',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profile.Id,
                LanguageLocaleKey = 'en_US',
                OSP__c = 'No',
                Dell_NTUserID__c = 'TEST_USER',
                Service_User_Type__c = 'Service Account',
                External_ID__c = '22334466',
                Organization__c = 'Test Org',
                File_Source__c = 'AMS - System Admin',
                EmployeeNumber='1234'+'22334466'
            );
            
            insert userIns;
            
            pse__Work_Calendar__c workCalendar = new pse__Work_Calendar__c(
                Name = 'Test Work Calendar'
            );
            
            insert workCalendar;
                    
            Contact contactIns = new Contact(
                FirstName = 'Test',
                LastName = 'Test',
                Email = 'pm_test_user@dell.com',
                AccountId = account.Id,
                pse__Salesforce_User__c = userIns.Id,
                pse__Region__c = regions[0].Id,
                pse__Work_Calendar__c = workCalendar.Id,
                pse__Is_Resource_Active__c = true,
                Phone = '2367895624',
                pse__Is_Resource__c = true
            );
            
            insert contactIns;
            
            List<pse__Proj__c> listProject = new List<pse__Proj__c>();

            pse__Proj__c testProj1 = new pse__Proj__c(
                Name = 'Test Proj 1',
                DP__c = '1',
                pse__Project_Phase__c = 'Setup',
                pse__Is_Template__c = false,
                pse__Is_Active__c = true,
                pse__Start_Date__c = Date.today(),
                pse__Region__c = regions[0].Id,
                Project_Visibility__c = 'All',
                PM_Complexity__c = 'Low',
                Initiate_Customer_Contact__c = true,
                Planning_and_Design__c = true,
                Delivery_and_Implementation__c = true,
                pse__Project_Manager__c = contactIns.Id,
                Local_Channel__c = '1212',
                BUID__c = '1212',
                On_Hold_Date__c = date.newInstance(2019, 6, 29)
            );

            listProject.add(testProj1); 
            
            pse__Proj__c testProj2 = new pse__Proj__c(
                Name = 'Test Proj 2',
                DP__c = '2',
                pse__Project_Phase__c = 'Setup',
                pse__Is_Template__c = false,
                pse__Is_Active__c = true,
                pse__Start_Date__c = Date.today(),
                pse__Region__c = regions[0].Id,
                Project_Visibility__c = 'All',
                PM_Complexity__c = 'Low',
                Initiate_Customer_Contact__c = true,
                Planning_and_Design__c = true,
                Delivery_and_Implementation__c = true,
                Closure_Reason__c = 'Services Delivered',
                pse__Project_Manager__c = contactIns.Id,
                Local_Channel__c = '1212',
                BUID__c = '1212',
                On_Hold_Date__c = date.newInstance(2019, 6, 29)
            );
            
            listProject.add(testProj2);
            
            pse__Proj__c testProj3 = new pse__Proj__c(
                Name = 'Test Proj 3',
                DP__c = '3',
                pse__Project_Phase__c = 'Setup',
                pse__Is_Template__c = false,
                pse__Is_Active__c = true,
                pse__Start_Date__c = Date.today(),
                pse__Region__c = regions[0].Id,
                Project_Visibility__c = 'All',
                PM_Complexity__c = 'Low',
                Initiate_Customer_Contact__c = true,
                Planning_and_Design__c = true,
                Delivery_and_Implementation__c = true,
                //Closure_Reason__c = 'Services Delivered',
                pse__Stage__c = 'In Progress',
                pse__Project_Manager__c = contactIns.Id,
                Deal_Type__c = 'Standard',
                Local_Channel__c = '1212',
                BUID__c = '1212',
                On_Hold_Date__c = null
            );

            listProject.add(testProj3);

            pse__Proj__c testProjCustom = new pse__Proj__c(
                Name = 'Test Proj Custom',
                DP__c = '10',
                pse__Project_Phase__c = 'Setup',
                pse__Is_Template__c = false,
                pse__Is_Active__c = true,
                pse__Start_Date__c = Date.today(),
                pse__Region__c = regions[0].Id,
                Project_Visibility__c = 'All',
                PM_Complexity__c = 'Low',
                Initiate_Customer_Contact__c = true,
                Planning_and_Design__c = true,
                Delivery_and_Implementation__c = true,
                Closure_Reason__c = 'Services Delivered',
                pse__Stage__c = 'In Progress',
                pse__Project_Manager__c = contactIns.Id,
                Local_Channel__c = '1212',
                BUID__c = '1212',
                Deal_Type__c = 'Custom'
            );
            
            listProject.add(testProjCustom);
            
            pse__Proj__c testProjCustom2 = new pse__Proj__c(
                Name = 'Test Proj Custom 2',
                DP__c = '20',
                pse__Project_Phase__c = 'Setup',
                pse__Is_Template__c = false,
                pse__Is_Active__c = true,
                pse__Start_Date__c = Date.today(),
                pse__Region__c = regions[0].Id,
                Project_Visibility__c = 'All',
                PM_Complexity__c = 'Low',
                Initiate_Customer_Contact__c = true,
                Planning_and_Design__c = true,
                Delivery_and_Implementation__c = true,
                Closure_Reason__c = 'Services Delivered',
                pse__Stage__c = 'In Progress',
                pse__Project_Manager__c = contactIns.Id,
                Local_Channel__c = '1212',
                BUID__c = '1212',
                Deal_Type__c = 'Custom'
            );
            
            listProject.add(testProjCustom2);

            pse__Proj__c testProj4 = new pse__Proj__c(
                Name = 'Test Proj 4',
                DP__c = '4',
                pse__Project_Phase__c = 'Setup',
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
                Closure_Reason__c = 'Services Delivered',
                pse__Project_Manager__c = contactIns.Id,
                On_Hold_Date__c = Date.today().addDays(20),
                Local_Channel__c = '1212',
                BUID__c = '1212',
                On_Hold_Reason__c = '30 Day Support'
            );

            listProject.add(testProj4); 

            insert listProject;
            
            Schema.Location location = [
                SELECT Id 
                FROM Location 
                LIMIT 1
            ];
            
            List<Project_Location__c> listProjectLocation = new List<Project_Location__c>();

            Project_Location__c projectSite = new Project_Location__c(
                Address_Type__c = 'Shipping',
                Location__c = location.Id,
                Project__c = testProj1.Id
            );
            
            listProjectLocation.add(projectSite);

            Project_Location__c projectSite2 = new Project_Location__c(
                Address_Type__c = 'Shipping',
                Location__c = location.Id,
                Project__c = testProj2.Id
            );
            
            listProjectLocation.add(projectSite2);

            Project_Location__c projectSite3 = new Project_Location__c(
                Address_Type__c = 'Shipping',
                Location__c = location.Id,
                Project__c = testProj3.Id
            );
            
            listProjectLocation.add(projectSite3);

            insert listProjectLocation;

            List<pse__Budget__c> listBudget = new List<pse__Budget__c>();

            pse__Budget__c budget = new pse__Budget__c (
                pse__Amount__c = 100,
                pse__Project__c = testProj1.Id
            );
            
            listBudget.add(budget);
            
            pse__Budget__c budget2 = new pse__Budget__c (
                pse__Amount__c = 100,
                pse__Project__c = testProj2.Id
            );
            
            listBudget.add(budget2);
            
            pse__Budget__c budget3 = new pse__Budget__c (
                pse__Amount__c = 100,
                pse__Project__c = testProj3.Id
            );
            
            listBudget.add(budget3);

            insert listBudget;
        
            
            List<pse__Milestone__c> milestones = new List<pse__Milestone__c>();
            
            pse__Milestone__c milestone1 = new pse__Milestone__c(
                Name = 'Forecast Completion Date',
                pse__Status__c = 'Open',
                pse__Target_Date__c = Date.today(),
                pse__Project__c = testProj1.Id, 
                Current__c = true
            );
            
            milestones.add(milestone1);
            
            pse__Milestone__c milestone2 = new pse__Milestone__c(
                Name = 'Next Follow Up Date',
                pse__Status__c = 'Open',
                pse__Target_Date__c = Date.today(),
                pse__Project__c = testProj1.Id, 
                Current__c = false
            );
            
            milestones.add(milestone2);
            
            pse__Milestone__c milestone3 = new pse__Milestone__c(
                Name = 'Milestoine Planned 1',
                pse__Status__c = 'Planned',
                pse__Target_Date__c = Date.today(),
                pse__Project__c = testProj2.Id, 
                Current__c = true
            );
            
            milestones.add(milestone3);
            
            pse__Milestone__c milestone4 = new pse__Milestone__c(
                Name = 'Milestone Planned 2',
                pse__Status__c = 'Planned',
                pse__Target_Date__c = Date.today(),
                pse__Project__c = testProj2.Id, 
                Current__c = false
            );
            
            milestones.add(milestone4);
            
            pse__Milestone__c milestone5 = new pse__Milestone__c(
                Name = 'Milestoine Planned 1',
                pse__Status__c = 'Planned',
                pse__Target_Date__c = Date.today(),
                pse__Project__c = testProj3.Id, 
                Current__c = true,
                Milestone_Amount_USD__c = 100,
                pse__Milestone_Amount__c = 100,
                Milestone_Cost_USD__c = 100,
                pse__Milestone_Cost__c = 100
            );
            
            milestones.add(milestone5);
            
            pse__Milestone__c milestone6 = new pse__Milestone__c(
                Name = 'Milestone Planned Custom',
                pse__Status__c = 'Planned',
                pse__Target_Date__c = Date.today(),
                pse__Project__c = testProjCustom.Id, 
                Current__c = true
            );
            
            milestones.add(milestone6);
            
            pse__Milestone__c milestone7 = new pse__Milestone__c(
                Name = 'Milestone Approved Custom',
                pse__Target_Date__c = Date.today(),
                pse__Project__c = testProjCustom2.Id, 
                Current__c = true
            );
            
            milestones.add(milestone7);
            
            insert milestones;
            
            
            Account firstAccount = [
                SELECT Id 
                FROM Account 
                LIMIT 1
            ];

            Order order = new Order(
                AccountId = firstAccount.Id,
                EffectiveDate = Date.today(),
                Status = 'BK',
                PoNumber = '888999',
                Deal_ID__c = '000111',
                OrderNumber__c = '555666',
                BUID__c = '11',
                PriceBook2Id = Test.getStandardPricebookId()
            );

            insert order;
            
            Product2 product = new Product2(
                Name = 'Test product'
            );
            insert product;
            Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true);
            //Insert standardPricebook;
            PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=product.id,unitprice=1.0, isActive=true);
            insert pbe;

            List<PricebookEntry> pbentry = [Select ID from PricebookEntry where Product2Id =:product.Id limit 1];
            if(pbentry == null && pbentry.size() == 0){
                PriceBookEntry priceBookEntry = new PriceBookEntry(
                    PriceBook2Id = order.Pricebook2Id,
                    Product2Id = product.Id,
                    IsActive = true,
                    UnitPrice = 1
                );
               insert priceBookEntry;
               pbentry.add(pricebookEntry);
            }
           List<OrderItem> orderItems = new List<OrderItem>();

           OrderItem orderItem = new OrderItem(
                SKU_Description__c = 'SKU Desc 1',
                SKU_Number__c = '777-1000',
                Quantity = 1,
                UnitPrice = 2,
                Item_Class_Description__c = 'SVC EDT INSTLN',
                Tie_Number__c = '1',
                OrderId = order.Id,
                PriceBookEntryId = pbentry[0].Id,
                Project__c = testProj1.Id
            );

            orderItems.Add(orderItem);
            
            Order order2 = new Order(
                AccountId = firstAccount.Id,
                EffectiveDate = Date.today(),
                Status = 'BK',
                PoNumber = '888922',
                Deal_ID__c = '000122',
                BUID__c = '11',
                OrderNumber__c = '555622',
                PriceBook2Id = Test.getStandardPricebookId()
            );
            
            insert order2;
            
            Product2 product2 = new Product2(
                Name = 'Test product'
            );

            insert product2;
            PricebookEntry pbe1 = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=product2.id,unitprice=1.0, isActive=true);
            insert pbe1;
            List<PricebookEntry> pbentry1 = [Select ID from PricebookEntry where Product2Id =:product2.Id limit 1];
            if(pbentry1 == null && pbentry1.size() == 0){
                PriceBookEntry priceBookEntry2 = new PriceBookEntry(
                    PriceBook2Id = order2.Pricebook2Id,
                    Product2Id = product2.Id,
                    IsActive = true,
                    UnitPrice = 1
                );
                insert priceBookEntry2;
                pbentry1.add(pricebookEntry2);
            } 
            
            orderItems.Add(new OrderItem(
                SKU_Description__c = 'SKU Desc 3',
                SKU_Number__c = '777-3133',
                Quantity = 1,
                UnitPrice = 2,
                Item_Class_Description__c = 'SVC EDT INSTLN',
                Tie_Number__c = '1',
                OrderId = order2.Id,
                PriceBookEntryId = pbentry1[0].Id,
                Project__c = testProj2.Id)
            );

            Order order3 = new Order(
                AccountId = firstAccount.Id,
                EffectiveDate = Date.today(),
                Status = 'BK',
                PoNumber = '888933',
                Deal_ID__c = '008133',
                OrderNumber__c = '555633',
                BUID__c = '11',
                PriceBook2Id = Test.getStandardPricebookId()
            );

            insert order3;
            
            Product2 product3 = new Product2(
                Name = 'Test product'
            );

            insert product3;
            PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=product3.id,unitprice=1.0, isActive=true);
            insert pbe2;
            List<PricebookEntry> pbentry2 = [Select ID from PricebookEntry where Product2Id =:product3.Id limit 1];
            if(pbentry2 == null && pbentry2.size() == 0){
                PriceBookEntry priceBookEntry3 = new PriceBookEntry(
                    PriceBook2Id = order3.Pricebook2Id,
                    Product2Id = product3.Id,
                    IsActive = true,
                    UnitPrice = 1
                );
                insert priceBookEntry3;
                pbentry2.add(pricebookEntry3);
            } 
            orderItems.Add(new OrderItem(
                SKU_Description__c = 'SKU Desc 1',
                SKU_Number__c = '777-1333',
                Quantity = 1,
                UnitPrice = 2,
                Item_Class_Description__c = 'SVC EDT INSTLN',
                Tie_Number__c = '1',
                OrderId = order3.Id,
                PriceBookEntryId = pbentry2[0].Id,
                Unit_Selling_Price_Local__c = 100,
                Unit_Selling_Price_USD__c = 100,
                SKU_Cost_Local__c = 100,
                SKU_Cost_USD__c = 100,
                Project__c = testProj3.Id)
            );
            
            insert orderItems;

            SKU_Effort_Map__c skuEffortMap = new SKU_Effort_Map__c(
                Active__c = true,
                Description__c = 'ProDeploy Dell Storage SC Series vXXXX SAN - Deployment Verification',
                X30_Day_Support__c = false
            );
            insert skuEffortMap;

            SKU_Number__c skuNumber1 = new SKU_Number__c();
            skuNumber1.SKU_Number__c = '777-1000';
            skuNumber1.SKU_to_Effort_Mapping__c = skuEffortMap.Id;
            insert skuNumber1;
            
            SKU_Effort_Map__c skuEffortMap2 = new SKU_Effort_Map__c(
                Active__c = true,
                Description__c = '30 day Support',
                X30_Day_Support__c = true
            );
            insert skuEffortMap2;

            SKU_Number__c skuNumber2 = new SKU_Number__c();
            skuNumber2.SKU_Number__c = '777-1333';
            skuNumber2.SKU_to_Effort_Mapping__c = skuEffortMap2.Id;
            insert skuNumber2;


            List<pse__Skill__c> skills = new List<pse__Skill__c>();

            pse__Skill__c lowSkill = new pse__Skill__c(Name = 'Project Management (Low)',pse__External_Id__c='9321');
            skills.add(lowSkill);

            pse__Skill__c mediumSkill = new pse__Skill__c(Name = 'Project Management (Medium)',pse__External_Id__c='9322');
            skills.add(mediumSkill);

            pse__Skill__c highSkill = new pse__Skill__c(Name = 'Project Management (High)',pse__External_Id__c='9323');
            skills.add(highSkill);

            insert skills;
        }   
    }

    @isTest 
    static void should_Update_Project_OnHold_And_Create_30Day_Milestone() {
        // arrange
        // project with a 30 day sku
        pse__Proj__c project = [SELECT Id, pse__Project_Phase__c, pse__Stage__c, Closure_Reason__c FROM  pse__Proj__c WHERE Name = 'Test Proj 3'];
        project.Closure_Reason__c = 'Services Delivered';        
        project.pse__Project_Phase__c = 'Close';
        //project.Local_Channel__c = '1212';
       // project.BUID__c = '1212';

        UPDATE project;

        // Junction Object
        OrderItem orderItem = [SELECT Id FROM OrderItem WHERE Project__c = :project.Id];
        pse__Milestone__c milestone = [SELECT Id FROM pse__Milestone__c WHERE pse__Project__c = :project.Id];

        OrderItemMilestoneAssociation__c junction = new OrderItemMilestoneAssociation__c();
        junction.Order_Product__c =  orderItem.Id;
        junction.Milestone__c = milestone.Id;

        INSERT junction;

        // act
        // update project to closure
        Test.startTest();
        
        project.pse__Stage__c = 'Closure';
        //project.Local_Channel__c = '1212';
       // project.BUID__c = '1212';
        UPDATE project;

        Test.stopTest();

        // assert
        pse__Proj__c projectResult = [SELECT Id, pse__Stage__c FROM pse__Proj__c WHERE Id = :project.Id];
        // should put the project to On Hold
        System.assertEquals('On Hold', projectResult.pse__Stage__c, 'The Project Stage should be On Hold.');

        // Should Create a new 30 day milestone with all the amount from the old milestone
        List<pse__Milestone__c> milestoneResults = [SELECT Id, Name, pse__Milestone_Amount__c, pse__Target_Date__c, pse__Status__c, Current__c FROM pse__Milestone__c WHERE pse__Project__c = :project.Id ORDER BY CreatedDate ASC];
        System.assertEquals(2, milestoneResults.size(), 'The project should have 2 milestones.');
        
        // and the system updates the remaining Opened milestone status to approved
        pse__Milestone__c oldMilestone = milestoneResults[0];
        System.assertEquals('Approved', oldMilestone.pse__Status__c, 'The system should Update the milestone to Approves status.');
        System.assertEquals(0, oldMilestone.pse__Milestone_Amount__c, 'The Milestone Amount should be 0');

        // and the system sets 30 day config milestone status to Open
        pse__Milestone__c thirtyDayMilestone = milestoneResults[1];
        System.assertEquals('30 Day Support', thirtyDayMilestone.Name, 'The system should create a 30 day Support milestones.');
        System.assertEquals(true, thirtyDayMilestone.Current__c, 'The system should update the 30 day Support milestones to current milestone.');
        System.assertEquals('Open', thirtyDayMilestone.pse__Status__c, 'The system should create a 30 day SUpport milestones with status Open.');
        System.assertEquals(100, thirtyDayMilestone.pse__Milestone_Amount__c, 'The Milestone Amount should be 100');

        // and system sets milestone target date to current day + 29  
        System.assertEquals(Date.today().addDays(29), thirtyDayMilestone.pse__Target_Date__c, 'The Milestone Amount should be the current date + 29.');
        
        // and the system moves the order items with 30 day config  to the 30 day config milestone
        OrderItemMilestoneAssociation__c junctionResult = [SELECT Order_Product__c, Milestone__c FROM OrderItemMilestoneAssociation__c WHERE Id = :junction.Id]; 
        System.assertEquals(thirtyDayMilestone.Id, junctionResult.Milestone__c, 'The system should update the junction object to have the new Milestone Id.');
    }

    @isTest
    static void should_ThrowError_ProjectCustom_With_MilestoneOpen() {
        // arrange
        pse__Proj__c project = [
            SELECT Id, Name, pse__Project_Phase__c, Closure_Reason__c, pse__Stage__c 
            FROM pse__Proj__c 
            WHERE DP__c = '10'
        ];

        project.pse__Project_Phase__c = 'Close';
        project.pse__Stage__c = 'Closure';
        project.Closure_Reason__c = 'Services Delivered';

        // act
        Test.startTest();

        try {
            UPDATE project;
            System.assert(false, 'The system should throw an DML exception before to arrive on this assert.');
        } 
        catch (Exception ex) {
            // assert
            System.assert(ex.getMessage().contains('Please approve milestones in Planned/Open status before closing the project.'), 'The system should unable the user to update Project Custom with any milestone open.');
        }

        Test.stopTest();
    }
    
    @isTest
    static void should_Close_ProjectCustom_With_MilestoneClosed() {
        // arrange
        pse__Proj__c project = [
            SELECT Id, Name, pse__Project_Phase__c, Closure_Reason__c, pse__Stage__c 
            FROM pse__Proj__c 
            WHERE DP__c = '20'
        ];

        pse__Milestone__c milestone = [SELECT Id, pse__Status__c, pse__Approved__c FROM pse__Milestone__c WHERE Name = 'Milestone Approved Custom'];
        milestone.pse__Status__c = 'Approved';
        milestone.pse__Approved__c = true;

        UPDATE milestone;

        project.pse__Project_Phase__c = 'Close';
        project.pse__Stage__c = 'Closure';
        project.Closure_Reason__c = 'Services Delivered';
       // project.Local_Channel__c = '1212';
      //  project.BUID__c = '1212';

        // act
        Test.startTest();
        
        UPDATE project;        

        Test.stopTest();

        // assert
        System.assertEquals('Close', project.pse__Project_Phase__c, 'The system should close the Custom Project if all milestones are close.');
    }

    @isTest
    static void should_Not_update_to_Close_When_OnHold() {
        // arrange
        pse__Proj__c project = [
            SELECT Id, Name, pse__Project_Phase__c, Closure_Reason__c, pse__Stage__c 
            FROM pse__Proj__c 
            WHERE DP__c = '4'
        ];

        project.pse__Project_Phase__c = 'Close';
        project.pse__Stage__c = 'Closure';
        project.Closure_Reason__c = 'Services Delivered';
        //project.Local_Channel__c = '1212';
       // project.BUID__c = '1212';

        // act
        Test.startTest();

        try {
            UPDATE project;
            System.assert(false, 'The system should throw an DML exception before to arrive on this assert.');
        } 
        catch (Exception ex) {
            // assert
            System.assert(ex.getMessage().contains('Cannot close this project within 30 day support period.'), 'The system should unable the user to close Project when it is within 30 day support.');
        }

        Test.stopTest();
    }

    @isTest
    static void IdsProjectTrigger_Should_Approve_Milestones() {
        
        Test.startTest();

        pse__Proj__c testProj2 = [
            SELECT Id, Name, pse__Project_Phase__c, Closure_Reason__c, pse__Stage__c,Local_Channel__c,BUID__c
            FROM pse__Proj__c 
            WHERE DP__c = '2'
        ];

        testProj2.pse__Project_Phase__c = 'Close';
        testProj2.pse__Stage__c = 'Closure';
        testProj2.Closure_Reason__c = 'Services Delivered';
        //testProj2.Local_Channel__c = '1212';
       // testProj2.BUID__c = '1212';
        
        List<OrderItem> orderItemsPrj = [
            SELECT Id, SKU_Number__c, Order.Id, Order.Milestone__c 
            FROM OrderItem
        ];

        System.debug('orderItemsPrj Test ===> '  + orderItemsPrj);
        
        update testProj2;
     
        Test.stopTest();
        
        List<pse__Milestone__c> milestones = [
            SELECT Id, Name 
            FROM pse__Milestone__c 
            WHERE pse__Project__c = :testProj2.Id 
                AND pse__Status__c = 'Approved'
        ];
        
        System.assert(milestones != null);

        System.debug('Milestones: ' + milestones);
    }

    @isTest
    static void should_Cancelled_Milestone_When_Service_Is_Not_Delivered() {

        // arrange
        // project standard not 30 Day
        pse__Proj__c project = [SELECT Id FROM pse__Proj__c WHERE Name = 'Test Proj 1'];
        project.Closure_Reason__c = 'Services Not Delivered';
        project.pse__Project_Phase__c = 'Close';
        //project.Local_Channel__c = '1212';
        //project.BUID__c = '1212';

        UPDATE project;

        // project closed

        Test.startTest();

        project.pse__Stage__c = 'Closure'; 
        UPDATE project;

        Test.stopTest();

        // assert
        // milestone canceled
        pse__Milestone__c milestone = [SELECT Id, pse__Status__c FROM pse__Milestone__c WHERE pse__Project__c = :project.Id LIMIT 1];
        System.assertEquals('Canceled', milestone.pse__Status__c, 'The Milestone Status should be Canceled.');

        // project service not delivered yet
        pse__Proj__c projectResult = [SELECT Id FROM pse__Proj__c WHERE Id = :project.Id];
        System.assertEquals('Services Not Delivered', project.Closure_Reason__c, 'The Project Closure Reason should be Services Not Delivered');
    }
    
    @isTest
    static void IdsProjectTrigger_Should_Cancel_Milestones() {

        Test.startTest();
        
        pse__Proj__c testProj2 = [
            SELECT Id, Name, pse__Project_Phase__c, Closure_Reason__c, pse__Stage__c,BUID__c,Local_Channel__c
            FROM pse__Proj__c 
            WHERE DP__c = '2'
        ];
        
        pse__Milestone__c milestone = new pse__Milestone__c(
            Name = '30 Day Support',
            pse__Status__c = 'Open',
            pse__Target_Date__c = Date.today().addDays(30),
            pse__Project__c = testProj2.Id
         );
        insert milestone;
        
        testProj2.pse__Project_Phase__c = 'Close';
        testProj2.pse__Stage__c = 'Closure';
        //testProj2.Local_Channel__c = '1212';
        //testProj2.BUID__c = '1212';
        // testProj2.Closure_Reason__c = 'Services Not Delivered';

        update testProj2;
        
        Test.stopTest();
        
        List<pse__Milestone__c> milestones = [
            SELECT Id 
            FROM pse__Milestone__c 
            WHERE pse__Project__c = :testProj2.Id 
                AND pse__Status__c = 'Canceled'
        ];
        
        System.assert(milestones != null);
        
        System.assertEquals('30 Day Support',milestone.Name);
    }
   
    @isTest
    static void IdsProjectTrigger_Should_Update_Proj_To_OnHold() {

        List<SKU_Number__c> skuNumber = [
            SELECT Id, SKU_to_Effort_Mapping__r.X30_Day_Support__c
            FROM SKU_Number__c
            WHERE SKU_Number__c = '777-1000'
        ];
        
        // SKU_Effort_Map__c skuEffortMap = [
        //     SELECT Id, SKU_Number__c 
        //     FROM SKU_Effort_Map__c 
        //     WHERE SKU_Number__c = '777-1000'
        // ];
        
        if(skuNumber.size() > 0){

            skuNumber[0].SKU_to_Effort_Mapping__r.X30_Day_Support__c = true;
            update skuNumber[0].SKU_to_Effort_Mapping__r; 

        }        
        
        Test.startTest();
        
        pse__Proj__c testProj1 = [
            SELECT Id, Name, pse__Project_Phase__c, Closure_Reason__c, pse__Stage__c,On_Hold_Date__c, On_Hold_Reason__c 
            FROM pse__Proj__c 
            WHERE DP__c = '1'
        ];
        
        pse__Milestone__c milestone = new pse__Milestone__c(
            Name = '30 Day Support',
            pse__Status__c = 'Open',
            pse__Target_Date__c = Date.today().addDays(30),
            pse__Project__c = testProj1.Id
        );
        insert milestone;
        
        testProj1.pse__Stage__c = 'On Hold';
        testProj1.On_Hold_Reason__c='30 Day Support';
        testProj1.Closure_Reason__c = 'Services Delivered';
        update testProj1;

        Test.stopTest();
        
        List<pse__Milestone__c> milestones = [
            SELECT Id, Name, pse__Status__c, pse__Target_Date__c 
            FROM pse__Milestone__c 
            WHERE pse__Project__c = :testProj1.Id
        ];

        pse__Proj__c updatedTestProj1 = [
            SELECT Name, pse__Project_Phase__c, Closure_Reason__c, pse__Stage__c, On_Hold_Reason__c, On_Hold_Date__c
            FROM pse__Proj__c
            WHERE DP__c = '1'
        ];

        // Not necessary soql
        // Order order = [
        //     SELECT Id, Milestone__c 
        //     FROM Order 
        //     WHERE project__c = :testProj1.Id
        // ];
        
        System.assert(milestones != null);

        System.assertEquals(testProj1.pse__Project_Phase__c, updatedTestProj1.pse__Project_Phase__c);
        System.assertEquals('On Hold', updatedTestProj1.pse__Stage__c);
        System.assertEquals('30 Day Support', updatedTestProj1.On_Hold_Reason__c);

        System.assertEquals(date.newInstance(2019, 6, 29), updatedTestProj1.On_Hold_Date__c);
    }    

    @isTest
    static void shouldNotUpdateProjectClosureReasonField() {

        pse__Proj__c project = [
            SELECT Id, Closure_Reason__c 
            FROM pse__Proj__c 
            WHERE Name = 'Test Proj 1'
        ];
        
        pse__Milestone__c milestone = new pse__Milestone__c(
            Name = 'Milestone Test',
            pse__Target_Date__c = Date.today(),
            pse__Project__c = project.Id
        );
        insert milestone;
        
        milestone.pse__Status__c = 'Approved';
        update milestone;
        
        List<pse__Milestone__c> milestoneList = [
            SELECT Id
            FROM pse__Milestone__c
            WHERE pse__Project__c =:project.Id
        ];

        System.assertEquals(3, milestoneList.size(), 'Setup data must have created 3 milestone for the project');
        
        Test.startTest();

        try {
            project.Closure_Reason__c = 'Services Not Delivered';
            UPDATE project;
            System.assert(false, 'The system should throw a DML exception before to arrive on this assert.');
        } 
        catch (Exception ex) {
            System.assert(ex.getMessage().contains('Projects with Milestones Approved can not be set as "Services Not Delivered".'), 'The system should throw an alert Message to the user.');
        }

        Test.stopTest();
        
        project = [
            SELECT Id, Closure_Reason__c 
            FROM pse__Proj__c 
            WHERE Name = 'Test Proj 1'
        ];
        
        System.assertEquals(null, project.Closure_Reason__c, 'Project cannot be set as "Services Not Delivered."');
    } 
    
    @isTest
    //User cannot update project status to "Services Delivered"
    static void shouldNotUpdateProjectClosureReasonToDelivered() {
        pse__Proj__c project = [
            SELECT Id, Closure_Reason__c 
            FROM pse__Proj__c 
            WHERE Name = 'Test Proj 1'
        ];
        
        List<pse__Milestone__c> milestoneList = [
            SELECT Id, pse__Status__c 
            FROM pse__Milestone__c
            WHERE pse__Project__c =:project.Id
        ];

        for(pse__Milestone__c milestoneStatus : milestoneList){
            milestoneStatus.pse__Status__c = 'Canceled';
        }
        update milestoneList;
        System.debug('@milestoneList: ' +  JSON.serialize(milestoneList));

        Test.startTest();

        try {
            project.Closure_Reason__c = 'Services Delivered';
            UPDATE project;
            System.assert(false, 'The system should throw a DML exception before to arrive on this assert.');
        }
        catch (Exception ex) {
            System.assert(ex.getMessage().contains('Projects with all Milestones canceled can not be set as "Services Delivered".'), 'The system should throw an alert Message to the user.');
        }

        Test.stopTest();
        project = [
            SELECT Id, Closure_Reason__c 
            FROM pse__Proj__c 
            WHERE Name = 'Test Proj 1'
        ];
        System.assertEquals(null, project.Closure_Reason__c, 'Project cannot be set as "Services Delivered".');
    }
    
    @isTest
    static void shouldReturnMilestonesFromProject(){
        
        List<pse__Proj__c> projectList = [
            SELECT Id, Closure_Reason__c 
            FROM pse__Proj__c 
            WHERE Name = 'Test Proj 1' OR Name = 'Test Proj 2'
        ];
        
        Set<Id> projectIds = new Set<Id>();
        for(pse__Proj__c project: projectList){
            projectIds.add(project.Id);
        }
        
        Test.startTest();
        
        Map<Id, List<pse__Milestone__c>> returnMap = IdsProjectClosureHandler.getMilestonesFromProjects(projectIds);
        
        Test.stopTest();
        
        System.assertEquals(2, returnMap.keySet().size(), 'It should return 2 projects from map');
               
    }
}