@isTest
public class WorkOrderUtil_Test {
    
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

            
            	WorkType objWorkType = TestDataGenerator.createWorkType();
			insert objWorkType;
            
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


        pse__Proj__c testProj2 = MDF_ProjectTemplateFactory.start()
            .name('Test Proj 2')
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

            

        Project_Contact__c testProjectContact1 = MDF_ProjectContactFactory.start()
            .contactRole('Other')
            .relatedProject(testProj2)
            .relatedContact(objContact)
            .contactRoleMultiPicklist('Other')
            .contactType('Customer')
            .create();

     
        pse__Budget__c budget = MDF_BudgetFactory.start(testProj2)
                .create();

        List<pse__Milestone__c> milestones = new List<pse__Milestone__c>();



        pse__Milestone__c milestone3 = new pse__Milestone__c(
                Name = 'Milestoine Planned 1',
                pse__Status__c = 'Planned',
                pse__Target_Date__c = Date.today(),
                pse__Project__c = testProj2.Id, Current__c = true
        );

        milestones.add(milestone3);
       insert milestones;


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
        LocationDefaultAddressTrue.Project__c = testProj2.Id;
        LocationDefaultAddressTrue.Order__c = order2.Id;
        LocationDefaultAddressTrue.Default_Address__c = true;
        

       lstLocation.add(LocationDefaultAddressTrue);

       }

    
        for(Integer count = 0; count<10; count++){
        
        Schema.Location LocationDefaultAddressFalse = new Schema.Location();
        LocationDefaultAddressFalse.OwnerId = UserInfo.getUserId();
        LocationDefaultAddressFalse.Name = '233 N Michigan Ave_Chicago'+ count;
        LocationDefaultAddressFalse.CurrencyIsoCode = 'USD';
        LocationDefaultAddressFalse.LocationType = 'Site';
        LocationDefaultAddressFalse.Project__c = testProj2.Id;
        LocationDefaultAddressFalse.Order__c = order2.Id;
        LocationDefaultAddressFalse.IsMobile = false;
        LocationDefaultAddressFalse.IsInventoryLocation = false;
        
        

       lstLocation.add(LocationDefaultAddressFalse);

       }
        
        insert lstLocation;

        List<pse__Project_Task__c> tasks = new List<pse__Project_Task__c>();
        tasks.add(new pse__Project_Task__c(Name='Setup', pse__Project__c=testProj2.Id, pse__Start_Date_Time__c=System.now(), pse__End_Date_Time__c=System.now()));
        tasks.add(new pse__Project_Task__c(Name='Initiate', pse__Project__c=testProj2.Id, pse__Start_Date_Time__c=System.now(), pse__End_Date_Time__c=System.now()));
        tasks.add(new pse__Project_Task__c(Name='Configuration', pse__Project__c=testProj2.Id, pse__Start_Date_Time__c=System.now(), pse__End_Date_Time__c=System.now(), pse__Parent_Task__c = tasks[1].Id));
        tasks.add(new pse__Project_Task__c(Name='Test Project Task', pse__Project__c=testProj2.Id, pse__Start_Date_Time__c=System.now(), pse__End_Date_Time__c=System.now()));
        insert tasks;

            
            Id workrecordtypeId1 = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Installation Field').getRecordTypeId();
            WorkOrder wo1 = new WorkOrder();
            wo1.Status = 'FF - New';
            wo1.AccountId = account.Id;
            wo1.Project__c = testProj2.Id;
            wo1.Project_Task__c = tasks[0].Id;
            wo1.WorkTypeId = objWorkType.Id;
            wo1.Duration = 20;
            wo1.RecordTypeId = workrecordtypeId1; 
            
            insert wo1;
 			
        
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


        SKU_Effort_Map_Entry__c effortMapEntry = new SKU_Effort_Map_Entry__c(project__c=testProj2.Id,
                Name__c='Remote Config',
                SKU_Effort_Map__c=skuEffortMap.Id,
                Phase__c=tasks.get(1).Id,
                Role__c= 'Project Manager',
                Project_Complexity_Tier__c='Tier 1',
                Estimated_Hours__c=10);


        insert effortMapEntry;

        SKU_Effort_Map_Entry__c differentEffortMapEntry = new SKU_Effort_Map_Entry__c(project__c=testProj2.Id,
                Name__c='Remote Config',
                SKU_Effort_Map__c=skuEffortMap.Id,
                Phase__c=tasks.get(1).Id,
                Role__c= 'Project Manager',
                Project_Complexity_Tier__c='Tier 1',
                Estimated_Hours__c=10);

        insert differentEffortMapEntry;



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
            	.template(testProj2.Id)
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

        
        WorkType resale = new WorkType();
        resale.EstimatedDuration = 60;
        resale.Name = 'FSE Task';
        insert resale;

        Order_Item_Sku_Effort_Map__c orderItemSkuEffortMap = new Order_Item_Sku_Effort_Map__c(
                Order_Product__c = orderItems2.get(0).Id,
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

       
        }
    }
    
     
      @isTest()
    public static void testBuildOnDemandWOMethod()
    {
        
        pse__Proj__c proj = [SELECT Id, pse__Account__c FROM pse__Proj__c WHERE Name = 'Test Proj 2'];
        WorkOrder selectWorkOrders = [SELECT Id, Project_Task__c,  Duration FROM WorkOrder WHERE Project__c = :proj.Id ];
        Id workrecordtypeId1 = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Installation Field').getRecordTypeId();
        WorkOrder wo = new WorkOrder();
        wo.id = selectWorkOrders.Id;
        wo.RecordTypeId = workrecordtypeId1;
        Update wo;
                
        WO_SKU_Effort_Map__c woSkuEfrtMap = [Select id, Duration__c, Threshold_Value__c,High_Threshold_Duration__c, Delivery_Method__c,WO_Record_Type__c, Calculation_Type__c, 
                                             Description__c,Resource_Type__c, SKU_Effort_Mapping_Entry__r.SKU_Effort_Map__c,
                                             Schedule_Type__c, Auto_Dispatch__c, DPS_Type__r.Name, Phase__r.Name, SR_Type__c, WO_Type__c
                                             FROM WO_SKU_Effort_Map__c
                                             WHERE Delivery_Method__c = 'OnSite'  AND Calculation_Type__c = 'By Threshold' LIMIT 1];
         
       /* pse__Project_Task__c tasks = [Select id, Name, pse__Project__c from pse__Project_Task__c Where pse__Project__c = :proj.Id Limit 1];  */
        
        pse__Project_Task__c tasks = TestDataGenerator.createParentProjectTask(proj.Id);
            tasks.Id = null;
            tasks.Name = 'Test Project Task';
			tasks.pse__Project__c = proj.id;
			insert tasks;
        
        Map<Id,pse__Project_Task__c> taskMap = new Map<Id,pse__Project_Task__c>([Select id,pse__Estimated_Hours__c, Name from pse__Project_Task__c Where Name = 'Test Project Task']);   
        Map<string, Id> taskNameToTaskId = new Map<string,id>();
        taskNameToTaskId.put(tasks.Name, tasks.Id);
        
        Project_Task_SKU_Effort_Mapping_Entry__c projTaskSkuEntry = [Select id,SKU_Quantity__c, Project_Task__r.pse__Estimated_Hours__c,
                                                                     SKU_Effort_Mapping_Entry__c, Project_Task__c From  
                                                                           Project_Task_SKU_Effort_Mapping_Entry__c
                                                                           LIMIT 1];

        WorkType objWorkType = TestDataGenerator.createWorkType();
        insert objWorkType;
        
        Test.startTest();
      
        WorkOrderUtils.buildOnDemandWO(woSkuEfrtMap, proj, objWorkType,taskNameToTaskId,taskMap);
        WorkOrderUtils.calculateDurationBySKUQuantity(selectWorkOrders,projTaskSkuEntry, woSkuEfrtMap);
        WorkOrderUtils.calculateDurationByThreshold(selectWorkOrders,projTaskSkuEntry, woSkuEfrtMap);
        WorkOrderManualCreation.getWorkOrderManualCreation(proj.Id);
        Test.stopTest();
        
        List<Schema.Location> selectOnSiteProjectLocations = [SELECT Id FROM Location WHERE Project__c = :proj.Id AND Default_Address__c = true];
        List<WorkOrder> selectWorkOrdersCreated = [SELECT Id, Project_Task__c FROM WorkOrder WHERE Project__c = :proj.Id];
        List<Work_Order_Skill__c> selectWorkOrderSkills = [SELECT Id FROM Work_Order_Skill__c WHERE Work_Order__c IN :selectWorkOrdersCreated];
        List<Work_Order_Relationship__c> selectWorkOrderRelationShip = [SELECT Id FROM Work_Order_Relationship__c WHERE Work_Order__c IN :selectWorkOrdersCreated];
        

    }
    
       @isTest()
    public static void testMethodforWorkOrderCreation()
    {
        pse__Proj__c proj = [Select id, Name, pse__Account__c, Primary_Contact__c from pse__Proj__c WHERE Name = 'Test Proj 2'];
        Contact con = [Select id, LastName from Contact WHERE LastName = 'Smith'];
        Project_Contact__c primaryCont =  [Select id, Project__c from Project_Contact__c WHERE Project__c = :proj.id];        
        List<SKU_Effort_Map_Entry__c> skuEffrtMap = [Select id, Name__c From SKU_Effort_Map_Entry__c WHERE Name__c ='Remote Config'];
        List<WO_SKU_Effort_Map__c> woSkuEfrtMap = [Select id, Delivery_Method__c,WO_Record_Type__c, Calculation_Type__c,Duration__c, 
                                                   Description__c,Resource_Type__c, SKU_Effort_Mapping_Entry__r.SKU_Effort_Map__c,
                                                   Schedule_Type__c, Auto_Dispatch__c, DPS_Type__r.Name, Phase__r.Name, SR_Type__c, WO_Type__c
                                                   From  WO_SKU_Effort_Map__c 
                                                   WHERE Delivery_Method__c = 'OnSite'  AND Calculation_Type__c = 'By Threshold' LIMIT 1];
        List<OrderItem> orderItems = [Select id, SKU_Description__c,SKU_Number__c  From OrderItem WHERE SKU_Description__c = 'SKU Desc 1'];
        List<Project_Task_SKU_Effort_Mapping_Entry__c> projTaskSkuEntry = [Select id,SKU_Quantity__c, SKU_Effort_Mapping_Entry__c, Project_Task__c From  
                                                                           Project_Task_SKU_Effort_Mapping_Entry__c
                                                                           LIMIT 1];
        List<pse__Project_Task__c>  task = [Select id, pse__Project__c from pse__Project_Task__c WHERE pse__Project__c = :proj.Id];
        Map<Id,pse__Project_Task__c> taskMap = New Map<Id, pse__Project_Task__c>(task);
        List<Order_Item_Sku_Effort_Map__c> ordItemSku = [Select id, Order_Product__c, SKU_to_Effort_Mapping__c  From Order_Item_Sku_Effort_Map__c Limit 1 ];
        Map<id,OrderItem> orderItemsMap  = new Map<id,OrderItem>(orderItems);
        List<Schema.Location> selectOnSiteProjectLocations = [SELECT Id, Default_Address__c, Project__c, Order__c FROM Location WHERE Project__c = :proj.Id AND Default_Address__c = true];
        WorkOrder selectWorkOrdersCreated = [SELECT Id, Project_Task__c, Duration FROM WorkOrder WHERE Project__c = :proj.Id];
        Id workrecordtypeId1 = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Installation Field').getRecordTypeId();
        WorkOrder wo = new WorkOrder();
        wo.id = selectWorkOrdersCreated.Id;
        wo.RecordTypeId = workrecordtypeId1;
        Update wo;
        Set<WO_SKU_Effort_Map__c> woSkueffortmap = new Set<WO_SKU_Effort_Map__c>();
        woSkueffortmap.addAll(woSkuEfrtMap);
        Set<Project_Task_SKU_Effort_Mapping_Entry__c> projTaskSkuEntryids = new  Set<Project_Task_SKU_Effort_Mapping_Entry__c>();
        projTaskSkuEntryids.addAll(projTaskSkuEntry);
        WorkType objWorkType = TestDataGenerator.createWorkType();
        insert objWorkType;
        Map<Id,Id> onSiteContIdByProjIdMap = new Map<Id,Id>();
        onSiteContIdByProjIdMap.put(proj.Id, proj.Id);
       // List<Schema.Location> locations = [Select Id, Default_Address__c From Location WHERE Default_Address__c = true];
        List<Schema.Address>  addresByLocation = [Select Id, AddressType, Street From Address WHERE Street = '233 North Michigan Avenue'];
        Map<Id,List<Schema.Address>> addresByLocationMap = new Map<Id,List<Schema.Address>>();
        addresByLocationMap.put(addresByLocation[0].Id, addresByLocation);

        
        Test.startTest();
        WorkOrderUtils.buildWO(proj,proj,woSkueffortmap,projTaskSkuEntryids, ordItemSku,orderItems,onSiteContIdByProjIdMap, selectOnSiteProjectLocations, objWorkType, addresByLocationMap);
        WorkOrderUtils.getFirstWOEffortMap(woSkueffortmap);
        WorkOrderUtils.defineDeliveryMethod(woSkueffortmap);
        WorkOrderUtils.getWODescriptionMap(woSkuEfrtMap);
        WorkOrderUtils.buildOrderItemMap(orderItems);
        WorkOrderUtils.getTaskWithoutChild(task[0].id, taskMap);
        WorkOrderUtils.fillProblemSummaryFromWoSkuEfforMap(ordItemSku,woSkueffortmap,orderItems);
        WorkOrderUtils.fillProblemSummaryFromWoSkuEfforMap(ordItemSku,woSkueffortmap, orderItemsMap);  
        WorkOrderUtils.getFirstProjectTaskSKUEffortMap(projTaskSkuEntryids); 
        WorkOrderUtils.calculateWODuration(selectWorkOrdersCreated, woSkueffortmap,projTaskSkuEntryids); 
        Test.stopTest();
   
        
    }
   
        
}