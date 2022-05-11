@IsTest
private class OrderItemGroupingDataContextTest {
    
    @IsTest
    static void shouldRefreshAndSaveContext() {
        //Login with Integration User Profile to create Test Data
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
            pse__Practice__c practiceIDS = new pse__Practice__c(Name = 'IDS', Standard_Project_Template__c = projectTemplate.Id);
            insert practiceIDS;
            
            pse__Practice__c practice = new pse__Practice__c(Name = 'EIS', pse__Parent_Practice__c = practiceIDS.Id, Standard_Project_Template__c = projectTemplate.Id);
            insert practice;
            
            List<Account> listAcc = new List<Account>();
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '111'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '123'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '234'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '345'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '456'));
            INSERT listAcc;
            
            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','5555555555');
            INSERT contact;
            
            List<Contact> lstContact = new List<Contact>();
            for(Contact contact1 :[SELECT Id, Mailing_Country__c From Contact]){
                contact1.MailingCountry = contact1.Mailing_Country__c;
                lstContact.add(contact1);
            }
            update lstContact;
            
            // Create sku numbers and effort mappings
            List<String> skuNumbersToMap1 = new List<String>{'101-1010'};
                Map<String, String> phaseByTask = new Map<String, String>();
            phaseByTask.put('Scoping', 'Initiate');
            
            SKU_Effort_Map__c skuEffort1 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap1, 10, false, phaseByTask, true);
            
            pse__Proj__c engagement1 = new pse__Proj__c(
                Name = 'Engagement Test ',
                RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId()
            );
            
            pse__Proj__c engagement2 = new pse__Proj__c(
                Name = 'Engagement Test 2',
                RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId()
            );
            
            insert new List<pse__Proj__c>{engagement1, engagement2};
                
                
                pse__Proj__c project1 = new pse__Proj__c(
                    Name = 'project Test',
                    pse__parent_project__c = engagement1.Id,
                    pse__practice__c = practice.Id,
                    pse__End_Date__c = Date.Today().addDays(30),
                    pse__Start_Date__c = Date.Today()
                );
            
            pse__Proj__c project2 = new pse__Proj__c(
                Name = 'project Test 2',
                pse__parent_project__c = engagement2.Id,
                pse__practice__c = practice.Id,
                pse__End_Date__c = Date.Today().addDays(30),
                pse__Start_Date__c = Date.Today()
            );
            
            Order order1 = OPRTestFactory.newOrderWithItem('123123', listAcc[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                                                           listAcc[1].Id,
                                                           listAcc[2].Id,
                                                           listAcc[3].Id,
                                                           listAcc[4].Id);
            
            Order order2 = OPRTestFactory.newOrderWithItem('123123', listAcc[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                                                           listAcc[1].Id,
                                                           listAcc[2].Id,
                                                           listAcc[3].Id,
                                                           listAcc[4].Id);
            
            
            
            
            insert new List<pse__Proj__c>{project1, project2};
                
            Product2 product = new Product2(Name='Product Test');
            insert product;
            
           /** PricebookEntry pricebookEntry = [Select Id, Pricebook2Id, Product2Id FROM PricebookEntry
                                         WHERE Product2Id =:product.Id]; **/
            //[Deloitte: Abhishek Kawle] - Commented this code as Product gets associated to Pricebook automatically.
            
                PricebookEntry pricebookEntry = new PricebookEntry(
                    Pricebook2Id = Test.getStandardPricebookId(),
                    Product2Id = product.Id,
                    UseStandardPrice = false,
                    UnitPrice = 1
                );
                insert pricebookEntry; 
            
            OrderItem orderItem1 = new OrderItem(
                SKU_Description__c = 'SKU1',
                SKU_Number__c = '101-1010',
                Quantity = 1,
                Item_Class_Description__c = 'SVC EIS',
                OrderId = order1.Id,
                PriceBookEntryId = priceBookEntry.Id,
                UnitPrice = 1
            );
            insert orderItem1;
            
            OrderItem orderItem2 = [SELECT Id, OrderId FROM OrderItem Where OrderId =: order2.Id Limit 1];
            orderItem2.SKU_Description__c = 'SKU1';
            orderItem2.SKU_Number__c = '101-1010';
            orderItem2.Item_Class_Description__c = 'SVC EIS';
            update orderItem2;   
            
            Map<Id, Id> ordersToEngagement = new Map<Id, Id>();
            ordersToEngagement.put(order1.Id, engagement1.Id);
            
            OrderItemGroupingDataContext context = new OrderItemGroupingDataContext(ordersToEngagement);
            OrderItemGroupingDataContext.ProjectToCreate projectToCreate = new OrderItemGroupingDataContext.ProjectToCreate('123', order1.Id, orderItem1.Id, engagement1.Id, practice.Id);
            context.projectsToCreate.add(projectToCreate);
            
            context.orderItemToAssociate.put(orderItem2, project2.Id);
            
            //Test.startTest();        
            context.Save();
            //Test.stopTest();
            
            System.assertEquals(projectToCreate.groupingkey, context.createProjectEventList[0].Grouping_key__c);
            System.assertEquals(project2.Id, context.orderItemEventList[0].Project_ID__c);
            
        }
    }
}