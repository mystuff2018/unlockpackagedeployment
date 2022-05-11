@isTest
public with sharing class WorkOrderManualCreationTest {
    @testSetup
    static void setup() {

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

        Profile profile = [
                SELECT Id
                FROM Profile
                WHERE Name = 'PSA Project Manager'
        ];

        User userIns = MDF_UserFactory.start()
            .userName('pm_test_user@dell.com')
            .lastName('One')
            .email('pm_test_user@dell.com')
            .alias('t1')
            .communityNickname('t1')
            .federalAccess(false)
            .federationIdentifier('22334466')
            .timeZoneSidKey('America/Los_Angeles')
            .localeSidKey('en_US')
            .emailEncodingKey('UTF-8')
            .relatedProfile(profile)
            .languageLocaleKey('en_US')
            .osp('No')
            .dellNTUserID('TEST_USER')
            .serviceUserType('IT/Other')
            .externalID('22334466')
            .employeeNumber('934783478')
            .organization('Test Org')
            .fileSource('AMS - System Admin')
            .create();

        pse__Work_Calendar__c workCalendar = MDF_WorkCalendarFactory.start()
            .name('Test Work Calendar')
            .create();

        Account account = MDF_AccountFactory.start()
            .siteAccessRequired('Yes')
            .create();

        pse__Region__c region = MDF_RegionFactory.start()
            .isoCountryCode('R1')
            .create();

        Contact contactIns = MDF_ContactFactory.start()
            .relatedAccount(account)
            .relatedSalesforceUser(userIns.Id)
            .relatedRegion(region)
            .relatedWorkCalendar(workCalendar)
            .isResourceActive(true)
            .isResource(true)
            .create();

        pse__Proj__c projToPractice = MDF_ProjectTemplateFactory.start()
            .projectPhase('Setup')
            .projectType('Standard')
            .stage('Draft')
            .isActive(true)
            .create();

        User objUser = TestDataGenerator.createUser('Degue','Venus','11');
        objUser.Service_User_Type__c = 'IT/Other';
        insert objUser;

        pse__Time_Period__c objTimePeriod = MDF_TimePeriodFactory.start()
            .name('All Time Period TEST')
            .currencyIsoCode('USD')
            .startDate(System.today())
            .endDate(System.today().addYears(2))
            .type('Perpetual')
            .create();

        pse__Practice__c objPractice = TestDataGenerator.createPractice(objTimePeriod.Id, projToPractice.Id);
        objPractice.Id = null;
        objPractice.Standard_Project_Template__c = projToPractice.Id;
        insert objPractice;

        Contact objContact = TestDataGenerator.createContact('Smith','Julian', account.Id, region.Id, objPractice.Id, workCalendar.Id, objUser.Id);
        insert objContact;

        pse__Region__c r1 = [
                SELECT Id
                FROM pse__Region__c
        ];

        pse__Proj__c testProj1 = MDF_ProjectTemplateFactory.start()
            .name('Test Proj 1')
            .projectPhase('Setup')
            .isActive(true)
            .startDate(Date.today())
            .relatedRegion(r1)
            .stage('Draft')
            .projectVisibility('All')
            .pmComplexity('Low')
            .projectComplexity('Low')
            .initiateCustomerContact(true)
            .planningAndDesign(true)
            .deliveryAndImplementation(true)
            .closureReason('Services Delivered')
            .relatedProjectManager(contactIns)
            .relatedProjectSupportAnalyst(objContact)
            .relatedAccount(account)
            .create();

        pse__Proj__c testProj2 = MDF_ProjectFactory.start()
            .withSetupPhase()
            .relatedRegion(r1.Id)
            .projectVisibility('All')
            .pmComplexity('Low')
            .projectComplexity('Low')
            .initiateCustomerContact(true)
            .planningAndDesign(true)
            .deliveryAndImplementation(true)
            .closureReason('Services Delivered')
            .relatedProjectManager(contactIns.Id)
            .relatedAccount(account)
            .isActive(true)
            .create();
            
            

        Project_Contact__c testProjectContact1 = MDF_ProjectContactFactory.start()
            .contactRole('Other')
            .relatedProject(testProj1)
            .relatedContact(objContact)
            .contactRoleMultiPicklist('Other')
            .contactType('Customer')
            .create();

       Project_Contact__c testProjectContact2 = MDF_ProjectContactFactory.start()
                .contactRole('Other')
                .relatedProject(testProj2)
                .relatedContact(objContact)
                .contactRoleMultiPicklist('Other')
                .contactType('Customer')
                .create();

        pse__Budget__c budget = MDF_BudgetFactory.start(testProj1)
                .create();

      /*  pse__Budget__c budget2 = MDF_BudgetFactory.start(testProj2)
                .create();*/

        List<pse__Milestone__c> milestones = new List<pse__Milestone__c>();

        pse__Milestone__c milestone1 = new pse__Milestone__c(
                Name = 'Forecast Completion Date',
                pse__Status__c = 'Open',
                pse__Target_Date__c = Date.today(),
                pse__Project__c = testProj1.Id, Current__c = true
        );

        milestones.add(milestone1);

      /*  pse__Milestone__c milestone2 = new pse__Milestone__c(
                Name = 'Next Follow Up Date',
                pse__Status__c = 'Open',
                pse__Target_Date__c = Date.today(),
                pse__Project__c = testProj1.Id, Current__c = false
        );

        milestones.add(milestone2);

        pse__Milestone__c milestone3 = new pse__Milestone__c(
                Name = 'Milestoine Planned 1',
                pse__Status__c = 'Planned',
                pse__Target_Date__c = Date.today(),
                pse__Project__c = testProj2.Id, Current__c = true
        );

        milestones.add(milestone3);

        pse__Milestone__c milestone4 = new pse__Milestone__c(
                Name = 'Milestone Planned 2',
                pse__Status__c = 'Planned',
                pse__Target_Date__c = Date.today(),
                pse__Project__c = testProj2.Id, Current__c = false
        );

        milestones.add(milestone4);*/

        insert milestones;

        Order order = new Order(
                AccountId = account.Id,
                EffectiveDate = Date.today(),
                Status = 'BK',
                PoNumber = '888999',
                Deal_ID__c = '000111',
                OrderNumber__c = '555666',
                BUID__c = '11',
                PriceBook2Id = Test.getStandardPricebookId(),
                Project__c = testProj1.Id,
                FF_Feed__c = true
        );
        insert order;

        Order order2 = new Order(
                AccountId = account.Id,
                EffectiveDate = Date.today(),
                Status = 'BK',
                PoNumber = '888999',
                Deal_ID__c = '000111',
                OrderNumber__c = '555666',
                BUID__c = '11',
                PriceBook2Id = Test.getStandardPricebookId(),
                Project__c = testProj2.Id,
                FF_Feed__c = true
        );

        insert order2;
        
        List<Schema.Location> lstLocation = new List<Schema.Location>();
        for(Integer count = 0; count<10; count++){
        
        Schema.Location LocationDefaultAddressTrue = new Schema.Location();
        LocationDefaultAddressTrue.OwnerId = UserInfo.getUserId();
        LocationDefaultAddressTrue.Name = '233 N Michigan Ave_Chicago'+ count;
        LocationDefaultAddressTrue.CurrencyIsoCode = 'USD';
        LocationDefaultAddressTrue.LocationType = 'Site';
        LocationDefaultAddressTrue.IsMobile = false;
        LocationDefaultAddressTrue.IsInventoryLocation = false;
        LocationDefaultAddressTrue.Project__c = testProj1.Id;
        LocationDefaultAddressTrue.Order__c = order.Id;
        LocationDefaultAddressTrue.Default_Address__c = true;
        

       lstLocation.add(LocationDefaultAddressTrue);

       }

    
        for(Integer count = 0; count<10; count++){
        
        Schema.Location LocationDefaultAddressFalse = new Schema.Location();
        LocationDefaultAddressFalse.OwnerId = UserInfo.getUserId();
        LocationDefaultAddressFalse.Name = '233 N Michigan Ave_Chicago'+ count;
        LocationDefaultAddressFalse.CurrencyIsoCode = 'USD';
        LocationDefaultAddressFalse.LocationType = 'Site';
        LocationDefaultAddressFalse.Project__c = testProj1.Id;
        LocationDefaultAddressFalse.Order__c = order.Id;
        LocationDefaultAddressFalse.IsMobile = false;
        LocationDefaultAddressFalse.IsInventoryLocation = false;
        
        

       lstLocation.add(LocationDefaultAddressFalse);

       }
        
        insert lstLocation;

       /* List<Project_Location__c> listProjectLocation = new List<Project_Location__c>();
        
        for(Integer count = 0; count < 10; count++){
            
                Project_Location__c projectLocationDefaultAddressTrue = new Project_Location__c(
                        Name = 'Default Address Location ' + count,
                        Address_Type__c = 'Install At Contact',
                        Location__c = objLocation.Id,
                        Project__c = testProj1.Id,
                        Order__c = order.Id,
                        Default_Address__c = true
                );
                listProjectLocation.add(projectLocationDefaultAddressTrue);

        }

        for(Integer count = 0; count < 10; count++){
                Project_Location__c projectLocationDefaultAddressFalse = new Project_Location__c(
                        Name = 'Not Default Address Location ' + count,        
                        Address_Type__c = 'Shipping',
                        Location__c = objLocation.Id,
                        Project__c = testProj1.Id,
                        Order__c = order.Id
                );

                listProjectLocation.add(projectLocationDefaultAddressFalse);
        }

        insert listProjectLocation;
     */

        Product2 product = new Product2(
                Name = 'Test product'
        );

        insert product;

        PriceBookEntry priceBookEntry = new PriceBookEntry(
                PriceBook2Id = order.Pricebook2Id,
                Product2Id = product.Id,
                IsActive = true,
                UnitPrice = 1
        );

        insert priceBookEntry;

        List<pse__Project_Task__c> tasks = new List<pse__Project_Task__c>();
        tasks.add(new pse__Project_Task__c(Name='Setup', pse__Project__c=testProj1.Id, pse__Start_Date_Time__c=System.now(), pse__End_Date_Time__c=System.now()));
        tasks.add(new pse__Project_Task__c(Name='Initiate', pse__Project__c=testProj1.Id, pse__Start_Date_Time__c=System.now(), pse__End_Date_Time__c=System.now()));
        tasks.add(new pse__Project_Task__c(Name='Configuration', pse__Project__c=testProj1.Id, pse__Start_Date_Time__c=System.now(), pse__End_Date_Time__c=System.now(), pse__Parent_Task__c = tasks[1].Id));

        insert tasks;

        List<OrderItem> orderItems = new List<OrderItem>();

        orderItems.Add(new OrderItem(
                SKU_Description__c = 'SKU Desc 1',
                SKU_Number__c = '777-1000',
                Quantity = 1,
                UnitPrice = 2,
                Item_Class_Description__c = 'SVC EDT INSTLN',
                Tie_Number__c = '1',
                OrderId = order.Id,
                Project__c = testProj1.Id,
                PriceBookEntryId = priceBookEntry.Id)
        );

        insert orderItems;

        Product2 product2 = new Product2(
                Name = 'Test product'
        );

        insert product2;

        PriceBookEntry priceBookEntry2 = new PriceBookEntry(
                PriceBook2Id = order2.Pricebook2Id,
                Product2Id = product2.Id,
                IsActive = true,
                UnitPrice = 1
        );

        insert priceBookEntry2;

        List<OrderItem> orderItems2 = new List<OrderItem>();

        orderItems2.Add(new OrderItem(
                SKU_Description__c = 'SKU Desc 1',
                SKU_Number__c = '111-11111',
                Quantity = 1,
                UnitPrice = 2,
                Item_Class_Description__c = 'SVC EDT INSTLN',
                Tie_Number__c = '1',
                OrderId = order2.Id,
                PriceBookEntryId = priceBookEntry2.Id));

        insert orderItems2;

        SKU_Effort_Map__c skuEffortMap = MDF_SKUEffortMapFactory.start()
        .create();
 

        SKU_Number__c skuNumber = new SKU_Number__c();
        skuNumber.SKU_Number__c = '777-1000';
        skuNumber.SKU_to_Effort_Mapping__c = skuEffortMap.Id;
        insert skuNumber;

        List<pse__Skill__c> skills = new List<pse__Skill__c>();

        pse__Skill__c lowSkill = new pse__Skill__c(Name = 'Project Management (Low)',pse__External_Id__c='9321');
        skills.add(lowSkill);

        pse__Skill__c mediumSkill = new pse__Skill__c(Name = 'Project Management (Medium)',pse__External_Id__c='9322');
        skills.add(mediumSkill);

        pse__Skill__c highSkill = new pse__Skill__c(Name = 'Project Management (High)',pse__External_Id__c='9323');
        skills.add(highSkill);

        insert skills;


        SKU_Effort_Map_Entry__c effortMapEntry = new SKU_Effort_Map_Entry__c(project__c=testProj1.Id,
                Name__c='Remote Config',
                SKU_Effort_Map__c=skuEffortMap.Id,
                Phase__c=tasks.get(1).Id,
                Role__c= 'Project Manager',
                Project_Complexity_Tier__c='Tier 1',
                Estimated_Hours__c=10);


        insert effortMapEntry;

        SKU_Effort_Map_Entry__c differentEffortMapEntry = new SKU_Effort_Map_Entry__c(project__c=testProj1.Id,
                Name__c='Remote Config',
                SKU_Effort_Map__c=skuEffortMap.Id,
                Phase__c=tasks.get(1).Id,
                Role__c= 'Project Manager',
                Project_Complexity_Tier__c='Tier 1',
                Estimated_Hours__c=10);

        insert differentEffortMapEntry;

       /* Asset ast = new Asset();
        ast.Order_Number__c = order.OrderNumber__c;
        ast.Order_Tie_Number__c = 1;
        ast.Name = 'AssetName';
        insert ast;*/

        Project_Task_SKU_Effort_Mapping_Entry__c projMapEntry = new Project_Task_SKU_Effort_Mapping_Entry__c();
        projMapEntry.SKU_Effort_Mapping_Entry__c = effortMapEntry.Id;
        projMapEntry.Project_Task__c = tasks[1].Id;
        projMapEntry.SKU_Quantity__c = 2;
        insert projMapEntry;

        //Create on Phase: Project ID EQUALS WO SKU Effort Mapping Entry: Template ID
        WO_SKU_Effort_Map__c woSkuEffortMapOnSiteOnDemandTrue = MDF_WOSKUEffortMapFactory.start()
                .calculationType('By SKU Quantity')
                .deliveryMethod('OnSite')
                .description('Planning Appointment')
                .duration(20)
                .relatedSKUEffortMappingEntry(effortMapEntry)
                .woRecordType('FF - Unknown')
                .autoDispatch(true)
                .woType('Install')
                .OnDemand(true)
                .phase(tasks[1].Id)
            	.template(testProj1.Id)
                .create();

        WO_SKU_Effort_Map__c woSkuEffortMapOnSiteOnDemandFalse = MDF_WOSKUEffortMapFactory.start()
                .calculationType('By Threshold')
                .deliveryMethod('OnSite')
                .description('Scoping Appointment')
                .duration(20)
                .relatedSKUEffortMappingEntry(differentEffortMapEntry)
                .woRecordType('FF - Unknown')
                .autoDispatch(true)
                .woType('Install')
                .OnDemand(false)
                .create();

        WO_SKU_Effort_Map__c woSkuEffortMapRemoteOnDemandFalse = MDF_WOSKUEffortMapFactory.start()
                .calculationType('By SKU Quantity')
                .deliveryMethod('Remote')
                .description('Planning Appointment')
                .duration(20)
                .relatedSKUEffortMappingEntry(effortMapEntry)
                .woRecordType('FF - Unknown')
                .autoDispatch(true)
                .woType('Install')
                .OnDemand(true)
                .create();
        
        WorkType resale = new WorkType();
        resale.EstimatedDuration = 60;
        resale.Name = 'FSE Task';
        insert resale;

        Order_Item_Sku_Effort_Map__c orderItemSkuEffortMap = new Order_Item_Sku_Effort_Map__c(
                Order_Product__c = orderItems.get(0).Id,
                SKU_to_Effort_Mapping__c = skuEffortMap.Id,
                Project_Task__c = tasks.get(1).Id
        );
        insert orderItemSkuEffortMap;

        Project_Task_Skill__c newProjectTaskSkill = new Project_Task_Skill__c(
                Project_Task__c = tasks.get(1).Id,
                Skill_Certification__c = skills.get(0).Id
        );
        insert newProjectTaskSkill;

        List<Project_Complexity_Threshold__c> projComplexities = new List<Project_Complexity_Threshold__c>();

        projComplexities.add(new Project_Complexity_Threshold__c (
                Name = 'R1',
                Low_Threshold__c = 1000,
                High_Threshold__c = 2000
        ));

        insert projComplexities;

        List<Project_Complexity_Mapping__c> projComplexityMappings = new List<Project_Complexity_Mapping__c>();

        projComplexityMappings.add(new Project_Complexity_Mapping__c (
                Overall_Project_Complexity__c = 'Low',
                PM_Complexity__c = 'Low',
                Revenue_Threshold__c = 'Low'
        ));

        projComplexityMappings.add(new Project_Complexity_Mapping__c (
                Overall_Project_Complexity__c = 'Medium',
                PM_Complexity__c = 'Medium',
                Revenue_Threshold__c = 'Medium'
        ));

        projComplexityMappings.add(new Project_Complexity_Mapping__c (
                Overall_Project_Complexity__c = 'High',
                PM_Complexity__c = 'High',
                Revenue_Threshold__c = 'High'
        ));

        insert projComplexityMappings;
        }

        }

    @isTest
    static void createOnDemandWorkOrder(){
            pse__Proj__c selectProject = [SELECT Id FROM pse__Proj__c WHERE Name = 'Test Proj 1'];
            Test.startTest();
            WorkOrderManualCreation.getWorkOrderManualCreation(selectProject.Id);
            Test.stopTest();

            List<Schema.Location> selectOnSiteProjectLocations = [SELECT Id FROM Location WHERE Project__c = :selectProject.Id AND Default_Address__c = true];
            List<WorkOrder> selectWorkOrdersCreated = [SELECT Id, Project_Task__c FROM WorkOrder WHERE Project__c = :selectProject.Id];
            List<Work_Order_Skill__c> selectWorkOrderSkills = [SELECT Id FROM Work_Order_Skill__c WHERE Work_Order__c IN :selectWorkOrdersCreated];
            List<Work_Order_Relationship__c> selectWorkOrderRelationShip = [SELECT Id FROM Work_Order_Relationship__c WHERE Work_Order__c IN :selectWorkOrdersCreated];
            System.assertEquals(selectOnSiteProjectLocations.size(), selectWorkOrdersCreated.size());
            System.assert(!selectWorkOrderRelationShip.isEmpty(), 'Work Order Creation should create Work Order and Order Item Relationship');
            System.assert(selectWorkOrdersCreated[0].Project_Task__c != null, 'Work order should have task');

    }
}