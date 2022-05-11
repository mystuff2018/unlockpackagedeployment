@IsTest
public with sharing class OrderDisassociationQueueableTest {
@testsetup
static void setup() {
  	Boolean isInsert =True;
	List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
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
            Service_User_Type__c = 'IT/Other',
            External_ID__c = '22334466',
            Organization__c = 'Test Org',
            File_Source__c = 'AMS - System Admin',
        	EmployeeNumber ='123456'
    );

    insert userIns;

    pse__Work_Calendar__c workCalendar = new pse__Work_Calendar__c(
            Name = 'Test Work Calendar'
    );

    insert workCalendar;
  
    /*Account account = new Account(
            Name = 'Test account',
            Site_Access_Required__c = 'Yes'
    );
	 if(isInsert){
            system.runAs(loginUser[0])
    {
             insert account;
    }
     }*/
      //Account account = TestDataGenerator.createAccountPSA();
       Account account = new Account();
        account.Name = 'Dell EMC';
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Master_Account_Profile').getRecordTypeId();
        account.CurrencyIsoCode = 'USD';
        account.OwnerId = UserInfo.getUserId();
        account.pse__Add_BEIs_To_Existing_Batches__c = false;
        account.fferpcore__MaterializedBillingAddressValidated__c = false;
        account.fferpcore__MaterializedShippingAddressValidated__c = false;
        account.Customer_Type__c = 'Inherit';
        account.Site_Visibility__c = 'Open';
    	if(isInsert){
            system.runAs(loginUser[0])
    	{
             insert account;
    	}
     	}
    pse__Region__c region = new pse__Region__c(
            Name = 'Test R1',
            ISO_Country_Code__c = 'R1'
    );

    insert region;

    Contact contactIns = new Contact();
            contactIns.FirstName = 'Test';
            contactIns.LastName = 'Test';
         	contactIns.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PSA_Resource').getRecordTypeId();
            contactIns.Email = 'pm_test_user@dell.com';
            contactIns.AccountId = account.Id;
            contactIns.pse__Salesforce_User__c = userIns.Id;
            contactIns.pse__Region__c = region.Id;
            contactIns.pse__Work_Calendar__c = workCalendar.Id;
            contactIns.pse__Is_Resource_Active__c = true;
            contactIns.pse__Is_Resource__c = true;
   
    insert contactIns;

    //pse__Proj__c projToPractice = TestDataGenerator.createBasicProject();
    pse__Proj__c projToPractice     =   new pse__Proj__c();
        projToPractice.OwnerId = UserInfo.getUserId();
        projToPractice.Name = 'TEST BASIC PROJECT';
        projToPractice.pse__Is_Template__c = true;
        projToPractice.pse__Start_Date__c = System.today() + 1;
        projToPractice.pse__End_Date__c = System.today() + 16;
        projToPractice.pse__Project_Phase__c = 'Setup';
        projToPractice.pse__Project_Type__c = 'Standard';
        projToPractice.pse__Stage__c = 'Draft';
        projToPractice.pse__Is_Active__c = true;
     	projToPractice.BUID__c = '11';
		projToPractice.Local_Channel__c = 'US_42';
        //return objProj;
    insert projToPractice;

    User objUser = TestDataGenerator.createUser('Kiran','naik','9');
    objUser.Service_User_Type__c = 'IT/Other';
    insert objUser;

    pse__Time_Period__c objTimePeriod = TestDataGenerator.createTimePeriod();
    insert objTimePeriod;

    pse__Practice__c objPractice = TestDataGenerator.createPractice(objTimePeriod.Id, projToPractice.Id);
    objPractice.Id = null;
    //objPractice.Standard_Project_Template__c = projToPractice.Id;
    insert objPractice;

    Contact objContact = TestDataGenerator.createContact('Smith','Julian', account.Id, region.Id, objPractice.Id, workCalendar.Id, objUser.Id);
    insert objContact;

    pse__Region__c r1 = [
            SELECT Id
            FROM pse__Region__c LIMIT1
    ];

    pse__Proj__c testProj1 = new pse__Proj__c(
            Name = 'Test Proj 1',
            pse__Project_Phase__c = 'Setup',
            pse__Is_Template__c = true,
            pse__Is_Active__c = true,
            pse__Start_Date__c = Date.today(),
            pse__Region__c = r1.Id,
            pse__Stage__c = 'Draft',
            Project_Visibility__c = 'All',
            PM_Complexity__c = 'Low',
            Project_Complexity__c = 'Low',
            Initiate_Customer_Contact__c = true,
            Planning_and_Design__c = true,
            Delivery_and_Implementation__c = true,
            Closure_Reason__c = 'Services Delivered',
            pse__Project_Manager__c = contactIns.Id,
            Project_Support_Analyst__c = objContact.Id,
            pse__Account__c = account.Id,
            pse__Account__r = account
    );
    insert testProj1;
    
    Project_Contact__c testProjectContact1 = new Project_Contact__c(
            Project__c = testProj1.Id,
            Contact__c = objContact.Id,
            Contact_Role__c = 'End User',
        	Contact_Type__c = 'Customer'
    );
    insert testProjectContact1;

    List<pse__Budget__c> listBudget = new List<pse__Budget__c>();

    pse__Budget__c budget = new pse__Budget__c (
            Amount_USD__c = 100,
            pse__Project__c = testProj1.Id
    );
    listBudget.add(budget);

    List<pse__Milestone__c> milestones = new List<pse__Milestone__c>();

    pse__Milestone__c milestone1 = new pse__Milestone__c(
            Name = 'Forecast Completion Date',
            pse__Status__c = 'Open',
            pse__Target_Date__c = Date.today(),
            pse__Project__c = testProj1.Id, Current__c = true
    );

    milestones.add(milestone1);

    pse__Milestone__c milestone2 = new pse__Milestone__c(
            Name = 'Next Follow Up Date',
            pse__Status__c = 'Open',
            pse__Target_Date__c = Date.today(),
            pse__Project__c = testProj1.Id, Current__c = false
    );

    milestones.add(milestone2);

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

    List<Project_Location__c> listProjectLocation = new List<Project_Location__c>();

    Project_Location__c projectSite = new Project_Location__c(
            Address_Type__c = 'Install At Contact',
            Location__c = objLocation.Id,
            Project__c = testProj1.Id,
            Order__c = order.Id,
            Default_Address__c = true
    );

    listProjectLocation.add(projectSite);

    Project_Location__c projectSite2 = new Project_Location__c(
            Address_Type__c = 'Shipping',
            Location__c = objLocation.Id,
            Project__c = testProj1.Id,
            Order__c = order.Id
    );

    listProjectLocation.add(projectSite2);

    insert listProjectLocation;

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

    SKU_Effort_Map__c skuEffortMap = new SKU_Effort_Map__c(
            Active__c = true,
            Description__c = 'ProDeploy Dell Storage SC Series vXXXX SAN - Deployment Verification'
    );
    insert skuEffortMap;

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

    /*Asset ast = new Asset();
    //ast.Order_Number__c = order.OrderNumber__c;
    //sast.Order_Tie_Number__c = 1;
    ast.Name = 'AssetName';
    insert ast;*/

    Project_Task_SKU_Effort_Mapping_Entry__c projMapEntry = new Project_Task_SKU_Effort_Mapping_Entry__c();
    projMapEntry.SKU_Effort_Mapping_Entry__c = effortMapEntry.Id;
    projMapEntry.Project_Task__c = tasks[1].Id;
    projMapEntry.SKU_Quantity__c = 2;
    insert projMapEntry;

    //Create on Phase: Project ID EQUALS WO SKU Effort Mapping Entry: Template ID
    WO_SKU_Effort_Map__c woSkuEffortMap1 = new WO_SKU_Effort_Map__c(
            Calculation_Type__c = 'By SKU Quantity',
            Delivery_Method__c = 'OnSite',
            Description__c = 'Planning Appointment',
            Duration__c = 20,
            SKU_Effort_Mapping_Entry__c = effortMapEntry.Id,
            Wo_Record_Type__c = 'FF - Unknown',
            Auto_Dispatch__c= True
    );
    insert woSkuEffortMap1;

    WO_SKU_Effort_Map__c woSkuEffortMap2 = new WO_SKU_Effort_Map__c(
            Calculation_Type__c = 'By Threshold',
            Delivery_Method__c = 'OnSite',
            Description__c = 'Scoping Appointment',
            Duration__c = 20,
            SKU_Effort_Mapping_Entry__c = effortMapEntry.Id,
            Wo_Record_Type__c = 'FF - Unknown',
            Auto_Dispatch__c= True
    );
    insert woSkuEffortMap2;

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
    
    Account a = new Account();
    a.Name = 'TestAccount';
    a.BUID__c='11';
    if(isInsert){
            system.runAs(loginUser[0])
    	{
               insert a;
    	}
     	}

    pse__Proj__c proj = new pse__Proj__c(Name='Test Proj', pse__Account__c=a.Id, pse__is_Active__c=true);
    insert proj;
    
    pse__Project_Task__c pTask = new pse__Project_Task__c(Name='Test Task0', pse__project__c=proj.Id);
    
    Partner_Details__c partnerDetails = new Partner_Details__c(Name = 'WISTR', Code__c= 'WISTR', DPS_Type__c = 'WTR', Call_Type__c = 'INSTALL', Country__c = 'US');
    insert partnerDetails;
    
    WorkOrder workOrder = new WorkOrder(Status='FF-New', PartnerName__c = partnerDetails.Id, Country__c = 'US', Partner_Country__c = 'US', CountryCode = 'US', Project__c=proj.Id, Project_Task__c = pTask.Id);
    insert workOrder;

    
    List<IdsProjectHandler.workOrderOrderItemSKUMap> listSkuMap = new List<IdsProjectHandler.workOrderOrderItemSKUMap>();
    List<WorkOrder> workOrderList = [SELECT Id FROM WorkOrder LIMIT 1];
    List<OrderItem> orderItemList = [SELECT Id FROM OrderItem LIMIT 1];
    Map<Id, pse__Proj__c> projectMap = new Map<Id, pse__Proj__c>([SELECT Id FROM pse__Proj__c LIMIT 1]);
    
    List<Order_Item_Sku_Effort_Map__c> orderItemSkuEffortMaps = [SELECT Id,Order_Product__c,Order_Product__r.OrderId, SKU_to_Effort_Mapping__c, Project_Task__c 
                                                                    FROM Order_Item_Sku_Effort_Map__c LIMIT 2];
    
    IdsProjectHandler.workOrderOrderItemSKUMap addworkOrderOrderItemSKUMap = new IdsProjectHandler.workOrderOrderItemSKUMap();
    addworkOrderOrderItemSKUMap.workOrder = workOrderList[0];
    addworkOrderOrderItemSKUMap.orderItemSkuEffortMaps = orderItemSkuEffortMaps[0];
    listSkuMap.add(addworkOrderOrderItemSKUMap);
    listSkuMap.add(addworkOrderOrderItemSKUMap);
    
    List<Order> orders = new List<Order>();
    Set<Id> orderIds = new Set<Id>();
    orders.add(order);
    OrderIds.add(order.Id);
    
}
    @IsTest
    public static void cancelProjectsWithoutOrderItemsTest(){
        // arrange
        List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order];
        pse__Proj__c project = [SELECT Id, pse__Parent_Project__c FROM pse__Proj__c LIMIT 1];

        List<Order_Association__e> eventList = new List<Order_Association__e>();
        for(Order ord: orders){
                OrderItem item = ord.OrderItems[0];
                Order_Association__e event = new Order_Association__e(
                        Order_ID__c = ord.Id,
                        Project_ID__c = project.Id,
                        Order_Item_Id__c = item.Id
                );
                        
                eventList.add(event);
        }	
          Test.startTest();
        OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
        context.save();

        // act
      
        //OrderDisassociationDataContext disassociationContext = new OrderDisassociationDataContext((new Map<Id, Order>(orders)).keySet());
		
        OrderDisassociationHandler orderDisassociation = new OrderDisassociationHandler((new Map<Id, Order>(orders)).keySet());
        orderDisassociation.run();
		
	Test.stopTest();
        
        pse__Proj__c projectAfterDissociation = [SELECT Id, pse__Stage__c, pse__Project_Phase__c FROM pse__Proj__c LIMIT 1];
        System.assertEquals('Setup', projectAfterDissociation.pse__Project_Phase__c, 'Project Should be in Setup phase');
    	System.assertEquals('Cancelled', projectAfterDissociation.pse__Stage__c , 'Project Should not be Cancelled.');                    
    }

    @IsTest
    public static void updateProjectsWithoutOrderItemsToOnHoldTest(){
        // arrange
        List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order];
        Contact contact = [SELECT Id, Name FROM Contact LIMIT 1];                
        pse__Proj__c project = [SELECT Id,pse__Proj__c.Name,pse__Parent_Project__c, pse__Project_Manager__c FROM pse__Proj__c LIMIT 1];
        List<Order_Association__e> eventList = new List<Order_Association__e>();
        for(Order ord: orders){
                OrderItem item = ord.OrderItems[0];
                Order_Association__e event = new Order_Association__e(
                        Order_ID__c = ord.Id,
                        Project_ID__c = project.Id,
                        Order_Item_Id__c = item.Id
                );
                        
                eventList.add(event);
        }	
        Test.startTest();
        OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
        context.save();

        // act
     
        project.Name = 'Test Project';
     	project.pse__Project_Phase__c = 'Initiate';
        project.pse__Project_Manager__c = contact.Id;
        update project;

		for(Order ord: orders){
        ord.Status = 'CL';
        }
        update orders;
       // OrderDisassociationHandler orderDisassociation = new OrderDisassociationHandler((new Map<Id, Order>(orders)).keySet());
        //orderDisassociation.run();
		
		Test.stopTest();
        
        pse__Proj__c projectAfterDissociation = [SELECT Id, pse__Proj__c.Name,pse__Stage__c, pse__Project_Phase__c, On_Hold_Reason__c FROM pse__Proj__c LIMIT 1];
        System.assertEquals('Initiate', projectAfterDissociation.pse__Project_Phase__c, 'Project Should be in Initiate phase');    	
        System.assertEquals('On Hold', projectAfterDissociation.pse__Stage__c , 'Project Should be On Hold.');        
        System.assertEquals('All Orders Cancelled', projectAfterDissociation.On_Hold_Reason__c, 'Project On Hold Reaason Should be All Orders Cancelled');                    
    }
}