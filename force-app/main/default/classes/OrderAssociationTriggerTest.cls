@isTest()
public class OrderAssociationTriggerTest {
    
    private static void setup(string projectPhase){
        // Get Profile
Profile profile = [
                SELECT Id 
                FROM Profile 
                WHERE Name = 'PSA Project Manager'
            ];
        List<User> userlsts = new List<User>();
        
        User yippeuser = new User(
                UserName = 'chamku_user@dell.com',
                LastName = 'Onesta',
                Email = 'chamku_user@dell.com',
                Alias = 'Z1',
                CommunityNickname = 'Z1',
                Federal_Access__c = false,
                FederationIdentifier = '22324466',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profile.Id,
                LanguageLocaleKey = 'en_US',
                OSP__c = 'No',
                Dell_NTUserID__c = 'CHAMKU_USER',
                Service_User_Type__c = 'Service Account',
                External_ID__c = '23234466',
                Organization__c = 'Test Org',
                File_Source__c = 'AMS - System Admin',
                EmployeeNumber='12349789'
            );
            userlsts.add(yippeuser);
        insert userlsts;
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // Create Region
            pse__Region__c region = new pse__Region__c(
                Name = 'Region Test',
                ISO_Country_Code__c = 'US'
            );
            
            insert region;
            
            // Create Account
            Account account = new Account(
                Name = 'Test account'
            );
            
            insert account;
            
            // Create Work Calendar
            pse__Work_Calendar__c workCalendar = new pse__Work_Calendar__c(
                Name = 'Test Work Calendar'
            );
            
            insert workCalendar;
            
            // Create Contact
            Contact cocoon = new Contact(
                FirstName = 'Hyu',
                LastName = 'Bin',
                Email = 'yippe_test_user@dell.com',
                AccountId = account.Id,
                pse__Salesforce_User__c = loginUser[0].Id,
                pse__Region__c = region.Id,
                pse__Work_Calendar__c = workCalendar.Id,
                pse__Is_Resource_Active__c = true,
                pse__Is_Resource__c = true,
                Phone = '3983784569'
            );
            
            insert cocoon;
            
            pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
            
            // Create Practce
            pse__Practice__c practice = new pse__Practice__c(
                Name = 'Infrastructure Delivery Services',
                Order_Association_Approval_Phase__c = 'Setup',
                Standard_Project_Template__c = projectTemplate.Id
            );
            
            insert practice;
            
            pse__Proj__c engagement1 = new pse__Proj__c(
                Name = 'Engagement Project 1',
                RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId(),
                pse__Parent_Project__c = null
            );
            insert engagement1;
            
            // Create Project
            pse__Proj__c project = new pse__Proj__c(
                Name = 'Test Proj 1',
                pse__Project_Phase__c = projectPhase,
                pse__Is_Template__c = true,
                pse__Is_Active__c = true,
                pse__Start_Date__c = Date.today(),
                pse__Region__c = region.Id,
                Project_Visibility__c = 'All',
                PM_Complexity__c = 'Low',
                Project_Complexity__c = 'Low',
                Initiate_Customer_Contact__c = true,
                Planning_and_Design__c = true,
                Delivery_and_Implementation__c = true,
                Closure_Reason__c = 'Services Delivered',
                pse__Project_Manager__c = cocoon.Id,
                Project_Support_Analyst__c = cocoon.Id,
                CurrencyIsoCode = 'USD',
                OwnerId = userlsts[0].Id,
                pse__Practice__c = practice.Id,
                pse__Parent_Project__c = engagement1.Id
            );
            
            insert project;
            
            // Create a Order
            
            Order orderdata = new Order(
                OrderNumber__c = '43215678',
                EffectiveDate = Date.valueOf('2018-07-17'),
                AccountId = account.Id,
                CurrencyIsoCode = 'USD',
                BUID__c = '11',
                Status = 'BK',
                Order_Status__c = 'BK',
                Pricebook2Id = Test.getStandardPricebookId(),
                OCI_Order_Type__c = 'US Order',
                Sales_Rep__c = cocoon.id,
                FF_Feed__c = true,
                Project__c = engagement1.Id);
            insert orderdata;
            System.debug('parentproject'+orderdata.Project__c);
            
            // Create Product
            Product2 product = new Product2(
                Name='Product Test'
            );
            insert product;
         /*   PricebookEntry pricebookEntry = [Select Id, Pricebook2Id, Product2Id FROM PricebookEntry
                                             WHERE Product2Id =:product.Id];*/
            //[Deloitte: Abhishek Kawle] - Commented this code as Product gets associated to Pricebook automatically.
            
            // Create Price Book
            PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UseStandardPrice = false, 
            UnitPrice = 1
            );
            insert pricebookEntry; 
            
            // Create Order Item
            OrderItem oi = new OrderItem(             
                SKU_Description__c = 'SKU Desc 1',
                SKU_Number__c = '777-1000',
                Quantity = 1,
                UnitPrice = 1,
                SKU_Cost__c = 1,
                Unit_Selling_Price_Local__c = 1,
                Unit_Selling_Price_USD__c = 1,
                SKU_Cost_Local__c = 1,
                //Project__c = project.Id,
                SKU_Cost_USD__c = 1,
                Item_Class_Description__c = 'SVC EDT INSTLN',
                Tie_Number__c = '1',
                OrderId = orderdata.Id,
                PriceBookEntryId = priceBookEntry.Id
            );
            insert oi;
            
            // create Skills
            List<pse__Skill__c> skills = new List<pse__Skill__c>();
            skills.add(new pse__Skill__c(Name = 'Project Management (Low)', pse__External_Id__c = 'skill1'));
            skills.add(new pse__Skill__c(Name = 'Project Management (Medium)', pse__External_Id__c = 'skill2'));
            skills.add(new pse__Skill__c(Name = 'Project Management (High)', pse__External_Id__c = 'skill3'));
            
            insert skills;
            
            // Create sku numbers and effort mappings
            List<String> skuNumbersToMap1 = new List<String>{'777-1000'};
                List<String> skuNumbersToMap2 = new List<String>{'CUSTOM SKU'};
                    Map<String, String> phaseByTask = new Map<String, String>();
            phaseByTask.put('Scoping', 'Initiate');
            
            SKU_Effort_Map__c skuEffort1 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap1, 10, false, phaseByTask, true);
            SKU_Effort_Map__c skuEffort2 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap2, 10, false, phaseByTask);
        }
    }


    @isTest              
    static void should_associate_Order_to_Project() {
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // Arrange
            setup('Initiate');
             Test.startTest();
            List<pse__Proj__c> engagementlist = [SELECT Id, Name, pse__Project_Manager__c FROM pse__Proj__c WHERE pse__Parent_Project__c = null];
            System.debug('engagement'+engagementlist);
            Order order = [SELECT Id, Project__c, Association_Approver__c, (select Id, OrderId, Project__c from OrderItems) FROM Order WHERE Project__c In: engagementlist LIMIT 1];
            System.debug('order'+order.Project__c);
            pse__Proj__c project = [SELECT Id, Name, pse__Project_Manager__c FROM pse__Proj__c WHERE pse__Parent_Project__c In: engagementlist LIMIT 1];
            
            List<Order_Association__e> eventList = new List<Order_Association__e>();
            
            for(OrderItem orderItem: order.OrderItems){
                Order_Association__e e = new Order_Association__e(
                    Project_ID__c = project.Id,
                    Order_Item_Id__c = orderItem.Id, 
                    Order_ID__c = orderItem.OrderId
                );
                eventList.add(e);
            }
            
            
            List<Database.SaveResult> sr = Eventbus.publish(eventList);
            Test.stopTest();
            
            // Assert
            // Verify that the publish was successful
            System.assertEquals(true, sr[0].isSuccess());
            
            Order orderResult = [SELECT Id, Project__c, Sales_Rep__c  FROM Order WHERE Project__c In: engagementlist LIMIT 1];
            pse__Proj__c projectResult = [SELECT Id, Sales_Rep__c FROM pse__Proj__c  WHERE pse__Parent_Project__c In: engagementlist LIMIT 1];
            
            pse__Milestone__c milestone = [SELECT Id, pse__Project__c FROM pse__Milestone__c WHERE pse__Project__c = :project.Id LIMIT 1];
            //pse__Budget__c budget = [SELECT Id, pse__Project__c FROM pse__Budget__c WHERE pse__Project__c = :project.Id LIMIT 1];
            List<pse__Budget__c> budgetList = [SELECT Id, pse__Project__c FROM pse__Budget__c WHERE pse__Project__c = :project.Id LIMIT 1];
            
            order = [SELECT Id, Project__c, Association_Approver__c, (select Id, OrderId, Project__c from OrderItems) FROM Order WHERE Project__c In: engagementlist LIMIT 1];
            
            // check milestone
            System.assert(milestone != null);
            System.assertEquals(milestone.pse__Project__c, projectResult.Id);
            
            // check budget
            //System.assert(budget != null);
            //System.assertEquals(budget.pse__Project__c, projectResult.Id);
            
            //System.assertEquals(order.OrderItems[0].Project__c, project.Id);
        }
    }

}