/**
 * @File Name          : ProjectEndDateConfigurationTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 12/12/2019 17:19:10
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/12/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 * 1.2    12/01/2021        YaminiK1                
**/
@isTest
public class ProjectEndDateConfigurationTest {
     @testSetup 
     public static void setup() {
        //[Deloitte : Abhishek Kawle] : Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
        Account account = new Account(
            Name = 'Test Account'
        );
        insert account;

        Product2 product = new Product2( Name = 'Test product');
        insert product;
            
            //V1.2 [Yamini_K1]Commented pricebookEntry query and uncommented pricebookEntry insert as pricebookEntry is not creating automatically,due to which test class is failing
       /* PricebookEntry pricebookEntry = [Select Id, Pricebook2Id, Product2Id FROM PricebookEntry
                                             WHERE Product2Id =:product.Id];*/
        //[Deloitte: Abhishek Kawle] - Commented this code as Product gets associated to Pricebook automatically.
       
        PriceBookEntry priceBookEntry = new PriceBookEntry(
        PriceBook2Id = Test.getStandardPricebookId(),
        Product2Id = product.Id,
        IsActive = true,
        UnitPrice = 1
        );    
        insert priceBookEntry; 
            
         pse__Proj__c projectTemplate = TestDataUtility.createProject(true);

        pse__Practice__c practice00 = new pse__Practice__c(Name = 'Test Practice 0', Standard_Project_Template__c = projectTemplate.Id);
        pse__Practice__c practice30 = new pse__Practice__c(Name = 'Test Practice 30', Default_Duration__c = 30, Standard_Project_Template__c = projectTemplate.Id);
        pse__Practice__c practice60 = new pse__Practice__c(Name = 'Test Practice 60', Default_Duration__c = 60, Standard_Project_Template__c = projectTemplate.Id);
        
        List<pse__Practice__c> lstPractices = new List<pse__Practice__c>{practice00, practice30,practice60};
        insert lstPractices;
        }
     }
    

    /***
    SCENARIO 1: Projects Creator Manually
     */
    @isTest
    public static void setProjectEndDateFromPractice_success() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<pse__Practice__c> lstPractices = [SELECT Id, Default_Duration__c FROM pse__Practice__c];
        Id smallProjectTierRecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Tier_1').getRecordTypeId();
        List<pse__Proj__c> lstProjects = new List<pse__Proj__c>();
        Date dtStart = Date.today();
        for(Integer i=0; i < 4; i++){
            Id practiceId = (i < 3) ? lstPractices[i].Id : lstPractices[0].Id;  
            pse__Proj__c project = new pse__Proj__c(
                Name = 'Test Project '+i,
                pse__Is_Active__c = true,
                pse__Is_Template__c = false,
                pse__Start_Date__c = dtStart, 
                pse__Account__c = account.Id,
                pse__Practice__c =  practiceId,
                recordTypeId = smallProjectTierRecordTypeId,
                    buid__c = '11',
                    local_channel__c = '11'
            );
            if(i == 3){
                project.Created_Automatically__c = true;
            }
            lstProjects.add(project);
        }
        Test.startTest();
        insert lstProjects;
        Test.stopTest();
        
        Integer i = 0;
       	for(pse__Proj__c project : [SELECT Id, Name, pse__Start_Date__c, pse__End_Date__c FROM pse__Proj__c WHERE Id IN:lstProjects]){
               Integer days = (i < 3 && lstPractices[i].Default_Duration__c != null) ? Integer.valueof(lstPractices[i].Default_Duration__c) : 0;
               if(i < 3){
                   System.assertEquals(project.pse__End_Date__c, project.pse__Start_Date__c.addDays(days));
               }
               else {
                   System.assertEquals(project.pse__End_Date__c, null);
               }
               i++;
        }
    }

    /**
    SCENARIO 2 And SCENARIO 4:  SKU Duration not available on the Sku Effort Mapping
     */
    @isTest
    public static void setProjectEndDateBySkuEffortMap_SKUDurationNotAvailable_success(){
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<pse__Practice__c> lstPractices = [SELECT Id, Default_Duration__c FROM pse__Practice__c];
        
        Order order1 = new Order(
            OrderNumber__c = '4393426',
            EffectiveDate = Date.valueOf('2018-08-06'),
            AccountId = account.Id,
            CurrencyIsoCode = 'USD',
            BUID__c = '11',
            Status = 'IP',
            Pricebook2Id = Test.getStandardPricebookId(),
            FF_Feed__c = true
        );

        Order order2 = new Order(
            OrderNumber__c = '4393427',
            EffectiveDate = Date.valueOf('2018-08-06'),
            AccountId = account.Id,
            CurrencyIsoCode = 'USD',
            BUID__c = '11',
            Status = 'IP',
            Pricebook2Id = Test.getStandardPricebookId(),
            FF_Feed__c = true
        );
        
        insert new List<Order>{order1, order2};
        PriceBookEntry priceBookEntry = [SELECT Id FROM PriceBookEntry LIMIT 1];
        OrderItem orderItem1 = new OrderItem(
            OrderId = order1.Id,
            PricebookEntryId = priceBookEntry.Id,
            Quantity = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            SKU_Number__c = '444-9998',
            SKU_Description__c = 'Order Item 1',
            UnitPrice = 99.9
        );

        OrderItem orderItem2 = new OrderItem(
            OrderId = order1.Id,
            PricebookEntryId = priceBookEntry.Id,
            Quantity = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            SKU_Number__c = '555-9998',
            SKU_Description__c = 'Order Item 2',
            UnitPrice = 99.9
        );

        OrderItem orderItem3 = new OrderItem(
            OrderId = order2.Id,
            PricebookEntryId = priceBookEntry.Id,
            Quantity = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            SKU_Number__c = '666-9998',
            SKU_Description__c = 'Order Item 3',
            UnitPrice = 99.9
        );
        
        insert new List<OrderItem>{orderItem1,orderItem2,orderItem3};

        SKU_Effort_Map__c effortMap1 = new SKU_Effort_Map__c(Description__c='SKU 1', Duration_Days__c = 30, X30_Day_Support__c = true);
        SKU_Effort_Map__c effortMap2 = new SKU_Effort_Map__c(Description__c='SKU 2', Duration_Days__c = 0);
        
        insert new List<SKU_Effort_Map__c>{effortMap1,effortMap2};
        
        SKU_Number__c SKUNumber1 = new SKU_Number__c(
            SKU_to_Effort_Mapping__c = effortMap1.Id,
            SKU_Number__c = '777-9998'
        );

        SKU_Number__c SKUNumber2 = new SKU_Number__c(
            SKU_to_Effort_Mapping__c = effortMap1.Id,
            SKU_Number__c = '888-9998'
        );

        SKU_Number__c SKUNumber3 = new SKU_Number__c(
            SKU_to_Effort_Mapping__c = effortMap2.Id,
            SKU_Number__c = '555-9998'
        );

        insert new List<SKU_Number__c>{SKUNumber1,SKUNumber2,SKUNumber3};    
        Id smallProjectTierRecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Tier_1').getRecordTypeId();
        Date dtStart = Date.today();
        pse__Proj__c project1 = new pse__Proj__c(
            Name = 'Test Project 1',
            pse__Is_Active__c = true,
            pse__Is_Template__c = false,
            pse__Start_Date__c = dtStart, 
            pse__Account__c = account.Id,
            Created_Automatically__c = true,
            pse__Practice__c = lstPractices[0].Id,
            recordTypeId = smallProjectTierRecordTypeId,
                buid__c = '11',
                local_channel__c = '11'
        );
        pse__Proj__c project2 = new pse__Proj__c(
            Name = 'Test Project 2',
            pse__Is_Active__c = true,
            pse__Is_Template__c = false,
            pse__Start_Date__c = dtStart, 
            pse__Account__c = account.Id,
            Created_Automatically__c = true,
            pse__Practice__c = lstPractices[1].Id,
            recordTypeId = smallProjectTierRecordTypeId,
                buid__c = '11',
                local_channel__c = '11'
        );
        insert new List<pse__Proj__c>{project1,project2};
        Map<Id, pse__Proj__c> mapOrderIdProject = new Map<Id, pse__Proj__c>{
            order1.Id => project1,
            order2.Id => project2
        };
            
        Test.startTest();
        List<pse__Proj__c>  lstProjects = ProjectEndDateConfiguration.setProjectEndDateBySkuEffortMap(mapOrderIdProject);    
        Test.stopTest();
        
        System.assertEquals(project1.pse__End_Date__c, project1.pse__Start_Date__c);
        System.assertEquals(project2.pse__End_Date__c, project2.pse__Start_Date__c.addDays(30));
    }

    /**
    SCENARIO 3 And SCENARIO 4:  SKU Duration Available And 30 Days Support
     */
    @isTest
    public static void setProjectEndDateBySkuEffortMap_SKUDuration_success(){
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<pse__Practice__c> lstPractices = [SELECT Id, Default_Duration__c FROM pse__Practice__c];
        
        Order order1 = new Order(
            OrderNumber__c = '4393426',
            EffectiveDate = Date.valueOf('2018-08-06'),
            AccountId = account.Id,
            CurrencyIsoCode = 'USD',
            BUID__c = '11',
            Status = 'IP',
            Pricebook2Id = Test.getStandardPricebookId(),
            FF_Feed__c = true
        );

        Order order2 = new Order(
            OrderNumber__c = '4393427',
            EffectiveDate = Date.valueOf('2018-08-06'),
            AccountId = account.Id,
            CurrencyIsoCode = 'USD',
            BUID__c = '11',
            Status = 'IP',
            Pricebook2Id = Test.getStandardPricebookId(),
            FF_Feed__c = true
        );
        
        insert new List<Order>{order1, order2};
        PriceBookEntry priceBookEntry = [SELECT Id FROM PriceBookEntry LIMIT 1];
        OrderItem orderItem1 = new OrderItem(
            OrderId = order1.Id,
            PricebookEntryId = priceBookEntry.Id,
            Quantity = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            SKU_Number__c = '444-9998',
            SKU_Description__c = 'Order Item 1',
            UnitPrice = 99.9
        );

        OrderItem orderItem2 = new OrderItem(
            OrderId = order1.Id,
            PricebookEntryId = priceBookEntry.Id,
            Quantity = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            SKU_Number__c = '555-9998',
            SKU_Description__c = 'Order Item 2',
            UnitPrice = 99.9
        );

        OrderItem orderItem3 = new OrderItem(
            OrderId = order2.Id,
            PricebookEntryId = priceBookEntry.Id,
            Quantity = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            SKU_Number__c = '666-9998',
            SKU_Description__c = 'Order Item 3',
            UnitPrice = 99.9
        );
        
        insert new List<OrderItem>{orderItem1,orderItem2,orderItem3};

        SKU_Effort_Map__c effortMap1 = new SKU_Effort_Map__c(Description__c='SKU 1', Duration_Days__c = 30, X30_Day_Support__c = true);
        SKU_Effort_Map__c effortMap2 = new SKU_Effort_Map__c(Description__c='SKU 2', Duration_Days__c = 10);
        
        insert new List<SKU_Effort_Map__c>{effortMap1,effortMap2};
        
        SKU_Number__c SKUNumber1 = new SKU_Number__c(
            SKU_to_Effort_Mapping__c = effortMap1.Id,
            SKU_Number__c = '444-9998'
        );

        SKU_Number__c SKUNumber2 = new SKU_Number__c(
            SKU_to_Effort_Mapping__c = effortMap1.Id,
            SKU_Number__c = '555-9998'
        );

        SKU_Number__c SKUNumber3 = new SKU_Number__c(
            SKU_to_Effort_Mapping__c = effortMap2.Id,
            SKU_Number__c = '666-9998'
        );

        insert new List<SKU_Number__c>{SKUNumber1,SKUNumber2,SKUNumber3};    
        Id smallProjectTierRecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Tier_1').getRecordTypeId();
        Date dtStart = Date.today();
        pse__Proj__c project1 = new pse__Proj__c(
            Name = 'Test Project 1',
            pse__Is_Active__c = true,
            pse__Is_Template__c = false,
            pse__Start_Date__c = dtStart, 
            pse__Account__c = account.Id,
            Created_Automatically__c = true,
            pse__Practice__c = lstPractices[0].Id,
            recordTypeId = smallProjectTierRecordTypeId,
                buid__c = '11',
                local_channel__c = '11'
        );
        pse__Proj__c project2 = new pse__Proj__c(
            Name = 'Test Project 2',
            pse__Is_Active__c = true,
            pse__Is_Template__c = false,
            pse__Start_Date__c = dtStart, 
            pse__Account__c = account.Id,
            Created_Automatically__c = true,
            pse__Practice__c = lstPractices[1].Id,
            recordTypeId = smallProjectTierRecordTypeId,
                buid__c = '11',
                local_channel__c = '11'
        );
        insert new List<pse__Proj__c>{project1,project2};
        Map<Id, pse__Proj__c> mapOrderIdProject = new Map<Id, pse__Proj__c>{
            order1.Id => project1,
            order2.Id => project2
        };
        Test.startTest();
        List<pse__Proj__c>  lstProjects = ProjectEndDateConfiguration.setProjectEndDateBySkuEffortMap(mapOrderIdProject);    
        Test.stopTest();
        
        System.assertEquals(project1.pse__Start_Date__c.addDays(60), project1.pse__End_Date__c);
        System.assertEquals(project2.pse__Start_Date__c.addDays(10), project2.pse__End_Date__c);
    }
    
    /**
    To do
     */
    @isTest
    public static void setProjectEnddateByProjectId_success(){
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<pse__Practice__c> lstPractices = [SELECT Id, Default_Duration__c FROM pse__Practice__c];
        Id smallProjectTierRecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Tier_1').getRecordTypeId();
        Date dtStart = Date.today();
        pse__Proj__c project1 = new pse__Proj__c(
            Name = 'Test Project 1',
            pse__Is_Active__c = true,
            pse__Is_Template__c = false,
            pse__Start_Date__c = dtStart,
            pse__End_Date__c = dtStart,
            pse__Account__c = account.Id,
            Created_Automatically__c = true,
            pse__Practice__c = lstPractices[0].Id,
            recordTypeId = smallProjectTierRecordTypeId,
                buid__c = '11',
                local_channel__c = '11'
        );
        
        insert project1;
        
        Order order1 = new Order(
            OrderNumber__c = '4393426',
            EffectiveDate = Date.valueOf('2018-08-06'),
            AccountId = account.Id,
            CurrencyIsoCode = 'USD',
            BUID__c = '11',
            Status = 'IP',
            Pricebook2Id = Test.getStandardPricebookId(),
            FF_Feed__c = true,
            Project__c = project1.Id
        );

        Order order2 = new Order(
            OrderNumber__c = '4393427',
            EffectiveDate = Date.valueOf('2018-08-06'),
            AccountId = account.Id,
            CurrencyIsoCode = 'USD',
            BUID__c = '11',
            Status = 'IP',
            Pricebook2Id = Test.getStandardPricebookId(),
            FF_Feed__c = true,
            Project__c = project1.Id
        );
        
        insert new List<Order>{order1, order2};
        PriceBookEntry priceBookEntry = [SELECT Id FROM PriceBookEntry LIMIT 1];
        OrderItem orderItem1 = new OrderItem(
            OrderId = order1.Id,
            PricebookEntryId = priceBookEntry.Id,
            Quantity = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            SKU_Number__c = '444-9998',
            SKU_Description__c = 'Order Item 1',
            UnitPrice = 99.9
        );

        OrderItem orderItem2 = new OrderItem(
            OrderId = order1.Id,
            PricebookEntryId = priceBookEntry.Id,
            Quantity = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            SKU_Number__c = '555-9998',
            SKU_Description__c = 'Order Item 2',
            UnitPrice = 99.9
        );

        OrderItem orderItem3 = new OrderItem(
            OrderId = order2.Id,
            PricebookEntryId = priceBookEntry.Id,
            Quantity = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            SKU_Number__c = '666-9998',
            SKU_Description__c = 'Order Item 3',
            UnitPrice = 99.9
        );
        
        insert new List<OrderItem>{orderItem1,orderItem2,orderItem3};

        SKU_Effort_Map__c effortMap1 = new SKU_Effort_Map__c(Description__c='SKU 1', Duration_Days__c = 15);
        SKU_Effort_Map__c effortMap2 = new SKU_Effort_Map__c(Description__c='SKU 2', Duration_Days__c = 10);
        
        insert new List<SKU_Effort_Map__c>{effortMap1,effortMap2};
        
        SKU_Number__c SKUNumber1 = new SKU_Number__c(
            SKU_to_Effort_Mapping__c = effortMap1.Id,
            SKU_Number__c = '444-9998'
        );

        SKU_Number__c SKUNumber2 = new SKU_Number__c(
            SKU_to_Effort_Mapping__c = effortMap1.Id,
            SKU_Number__c = '555-9998'
        );

        SKU_Number__c SKUNumber3 = new SKU_Number__c(
            SKU_to_Effort_Mapping__c = effortMap2.Id,
            SKU_Number__c = '666-9998'
        );

        insert new List<SKU_Number__c>{SKUNumber1,SKUNumber2,SKUNumber3};    
        
        List<Id> projectIds = new List<Id>{project1.Id};  
            
        Test.startTest();
        List<pse__Proj__c> projects = ProjectEndDateConfiguration.setProjectEnddateByProjectId(projectIds);    
        Test.stopTest();
        
        System.assertEquals(project1.pse__Start_Date__c.addDays(15), projects[0].pse__End_Date__c);
    }
    
    @isTest
    static void populateProjectEndDate_Success(){
        Account account = [SELECT Id FROM Account LIMIT 1];
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'PSA Project Manager'];
        
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
            External_ID__c = '22334466',
            Organization__c = 'Test Org',
            File_Source__c = 'AMS - System Admin',
            Service_User_Type__c='Service Account',
            EmployeeNumber='12345' //Added due to DFN Validation Rule on User > Employee Number field.
        );
        
        insert userIns;

        pse__Region__c region = new pse__Region__c (
            Name = 'Test United States',
            ISO_Country_Code__c = 'US'
        );
        
        insert region;

        pse__Work_Calendar__c workCalendar = new pse__Work_Calendar__c(Name = 'Test Work Calendar');
        insert workCalendar;
        
        Contact contactIns = new Contact(
            FirstName = 'Test',
            LastName = 'Test',
            Email = 'pm_test_user@dell.com',
            AccountId = account.Id,
            pse__Salesforce_User__c = userIns.Id,
            pse__Region__c = region.Id,
            pse__Work_Calendar__c = workCalendar.Id,
            pse__Is_Resource_Active__c = true,
            pse__Is_Resource__c = true,
            phone='1234567890'
        );
        
        insert contactIns;

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

        projComplexityMappings.add(new Project_Complexity_Mapping__c (
            Overall_Project_Complexity__c = 'High',
            PM_Complexity__c = 'High',
            Revenue_Threshold__c = 'Medium'
        ));
        
        insert projComplexityMappings;

        List<pse__Skill__c> skills = new List<pse__Skill__c>();
        pse__Skill__c lowSkill = new pse__Skill__c(Name = 'Project Management (Low)', pse__External_Id__c='9321');
        skills.add(lowSkill);
        pse__Skill__c mediumSkill = new pse__Skill__c(Name = 'Project Management (Medium)', pse__External_Id__c='9322');
        skills.add(mediumSkill);
        pse__Skill__c highSkill = new pse__Skill__c(Name = 'Project Management (High)', pse__External_Id__c='9324');

        skills.add(highSkill);
        insert skills;

        // Setup Project Complexity Threshold
        List<Project_Complexity_Threshold__c> projComplexities = new List<Project_Complexity_Threshold__c>();

        projComplexities.add(new Project_Complexity_Threshold__c (
            Name = 'US',
            Low_Threshold__c = 3500,
            High_Threshold__c = 11500
        ));

        insert projComplexities; 
        
        List<pse__Practice__c> lstPractices = [SELECT Id, Default_Duration__c FROM pse__Practice__c];


        lstPractices[0].Order_Association_Approval_Phase__c = 'Plan';
        lstPractices[0].Default_Duration__c = 30;
        lstPractices[1].Order_Association_Approval_Phase__c = 'Plan';
        update lstPractices;

        
        Order order1 = new Order(
            OrderNumber__c = '4393426',
            EffectiveDate = Date.valueOf('2018-08-06'),
            AccountId = account.Id,
            CurrencyIsoCode = 'USD',
            BUID__c = '11',
            Status = 'IP',
            Pricebook2Id = Test.getStandardPricebookId(),
            FF_Feed__c = true
        );

        Order order2 = new Order(
            OrderNumber__c = '4393427',
            EffectiveDate = Date.valueOf('2018-08-06'),
            AccountId = account.Id,
            CurrencyIsoCode = 'USD',
            BUID__c = '11',
            Status = 'IP',
            Pricebook2Id = Test.getStandardPricebookId(),
            FF_Feed__c = true
        );
        
        insert new List<Order>{order1, order2};
        PriceBookEntry priceBookEntry = [SELECT Id FROM PriceBookEntry LIMIT 1];
        OrderItem orderItem1 = new OrderItem(
            OrderId = order1.Id,
            PricebookEntryId = priceBookEntry.Id,
            Quantity = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            SKU_Number__c = '444-9998',
            SKU_Description__c = 'Order Item 1',
            UnitPrice = 99.9
        );

        OrderItem orderItem2 = new OrderItem(
            OrderId = order1.Id,
            PricebookEntryId = priceBookEntry.Id,
            Quantity = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            SKU_Number__c = '555-9998',
            SKU_Description__c = 'Order Item 2',
            UnitPrice = 99.9
        );

        OrderItem orderItem3 = new OrderItem(
            OrderId = order2.Id,
            PricebookEntryId = priceBookEntry.Id,
            Quantity = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            SKU_Number__c = '666-9998',
            SKU_Description__c = 'Order Item 3',
            UnitPrice = 99.9
        );
        
        insert new List<OrderItem>{orderItem1,orderItem2,orderItem3};

        SKU_Effort_Map__c effortMap1 = new SKU_Effort_Map__c(Description__c='SKU 1', Duration_Days__c = 30, X30_Day_Support__c = true);
        SKU_Effort_Map__c effortMap2 = new SKU_Effort_Map__c(Description__c='SKU 2', Duration_Days__c = 0);
        
        insert new List<SKU_Effort_Map__c>{effortMap1,effortMap2};
        
        SKU_Number__c SKUNumber1 = new SKU_Number__c(
            SKU_to_Effort_Mapping__c = effortMap1.Id,
            SKU_Number__c = '777-9998'
        );

        SKU_Number__c SKUNumber2 = new SKU_Number__c(
            SKU_to_Effort_Mapping__c = effortMap1.Id,
            SKU_Number__c = '888-9998'
        );

        SKU_Number__c SKUNumber3 = new SKU_Number__c(
            SKU_to_Effort_Mapping__c = effortMap2.Id,
            SKU_Number__c = '555-9998'
        );

        insert new List<SKU_Number__c>{SKUNumber1,SKUNumber2,SKUNumber3};    
        Id smallProjectTierRecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Tier_1').getRecordTypeId();
        Date dtStart = Date.today();
        pse__Proj__c project1 = new pse__Proj__c(
            Name = 'Test Project 1',
            pse__Is_Active__c = true,
            pse__Is_Template__c = false,
            pse__Start_Date__c = dtStart, 
            pse__Account__c = account.Id,
            Created_Automatically__c = true,
            pse__Practice__c = lstPractices[0].Id,
            recordTypeId = smallProjectTierRecordTypeId,
            pse__Stage__c = 'In Progress',
            Closure_Reason__c = 'Services Delivered',
            pse__Project_Phase__c = 'Setup',
            Project_Complexity__c = 'Low',
            pse__Project_Manager__c = contactIns.Id,
            pse__Region__c = region.id,
                buid__c = '11',
                local_channel__c = '11'

        );
        pse__Proj__c project2 = new pse__Proj__c(
            Name = 'Test Project 2',
            pse__Is_Active__c = true,
            pse__Is_Template__c = false,
            pse__Start_Date__c = dtStart, 
            pse__Account__c = account.Id,
            Created_Automatically__c = true,
            pse__Practice__c = lstPractices[1].Id,
            recordTypeId = smallProjectTierRecordTypeId,
            pse__Stage__c = 'In Progress',
            Closure_Reason__c = 'Services Delivered',
            pse__Project_Phase__c = 'Setup',
            Project_Complexity__c = 'Low',
            pse__Project_Manager__c = contactIns.Id,
            pse__Region__c = region.id,
                buid__c = '11',
                local_channel__c = '11'

        );
        List<pse__Proj__c> lstProjct = new List<pse__Proj__c>{project1,project2};
        insert lstProjct;

        project1.Association_flag__c = true;
        project2.Association_flag__c = true;
        project1.pse__Project_Phase__c = 'Initiate';
        project2.pse__Project_Phase__c = 'Initiate';

        update lstProjct;




        
        Order_Association__e event1 = new Order_Association__e(
            Order_ID__c = order1.Id,
            Project_ID__c = project1.Id,
            Order_Item_Id__c = orderItem1.Id
        );
        
        Order_Association__e event2 = new Order_Association__e(
            Order_ID__c = order1.Id,
            Project_ID__c = project1.Id,
            Order_Item_Id__c = orderItem2.Id
        );
        
        Order_Association__e event3 = new Order_Association__e(
            Order_ID__c = order2.Id,
            Project_ID__c = project2.Id,
            Order_Item_Id__c = orderItem3.Id
        );
        
        List<Order_Association__e> eventList = new List<Order_Association__e>{event1, event2, event3};
        OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
       
        Test.startTest();
        ProjectEndDateConfiguration.populateProjectEndDate(context);
        Test.stopTest();
        
        for(pse__Proj__c project : context.projectMap.values()){
            System.assertEquals(project.pse__End_Date__c, project.pse__Start_Date__c.addDays(30));
        }
        

    }

    @IsTest
    public static void setProjectEndDateByOrderItem_Success(){
        Account account = [SELECT Id FROM Account LIMIT 1];
        List<pse__Practice__c> lstPractices = [SELECT Id, Default_Duration__c FROM pse__Practice__c];
        
        Order order1 = new Order(
            OrderNumber__c = '4393426',
            EffectiveDate = Date.valueOf('2018-08-06'),
            AccountId = account.Id,
            CurrencyIsoCode = 'USD',
            BUID__c = '11',
            Status = 'IP',
            Pricebook2Id = Test.getStandardPricebookId(),
            FF_Feed__c = true
        );

        Order order2 = new Order(
            OrderNumber__c = '4393427',
            EffectiveDate = Date.valueOf('2018-08-06'),
            AccountId = account.Id,
            CurrencyIsoCode = 'USD',
            BUID__c = '11',
            Status = 'IP',
            Pricebook2Id = Test.getStandardPricebookId(),
            FF_Feed__c = true
        );
        
        insert new List<Order>{order1, order2};
        PriceBookEntry priceBookEntry = [SELECT Id FROM PriceBookEntry LIMIT 1];

        SKU_Effort_Map__c effortMap1 = new SKU_Effort_Map__c(Description__c='SKU 1', Duration_Days__c = 30, X30_Day_Support__c = false, active__c = true);
        
        insert effortMap1;
        
        SKU_Number__c SKUNumber1 = new SKU_Number__c(
            SKU_to_Effort_Mapping__c = effortMap1.Id,
            SKU_Number__c = '777-9998'
        );

        SKU_Number__c SKUNumber2 = new SKU_Number__c(
            SKU_to_Effort_Mapping__c = effortMap1.Id,
            SKU_Number__c = '888-9998'
        );

        SKU_Number__c SKUNumber3 = new SKU_Number__c(
            SKU_to_Effort_Mapping__c = effortMap1.Id,
            SKU_Number__c = '555-9998'
        );

        insert new List<SKU_Number__c>{SKUNumber1,SKUNumber2,SKUNumber3};    
        Id smallProjectTierRecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Tier_1').getRecordTypeId();
        Date dtStart = Date.today();
        pse__Proj__c project = new pse__Proj__c(
            Name = 'Test Project 1',
            pse__Is_Active__c = true,
            pse__Is_Template__c = false,
            pse__Start_Date__c = dtStart,
            pse__End_Date__c = dtStart, 
            pse__Account__c = account.Id,
            Created_Automatically__c = true,
            pse__Practice__c = lstPractices[0].Id,
            recordTypeId = smallProjectTierRecordTypeId,
                buid__c = '11',
                local_channel__c = '11'
        );

        insert project;

        OrderItem orderItem1 = new OrderItem(
            OrderId = order1.Id,
            PricebookEntryId = priceBookEntry.Id,
            Quantity = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            SKU_Number__c = '444-9998',
            SKU_Description__c = 'Order Item 1',
            UnitPrice = 99.9,
            Project__c = project.Id
        );

        OrderItem orderItem2 = new OrderItem(
            OrderId = order1.Id,
            PricebookEntryId = priceBookEntry.Id,
            Quantity = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            SKU_Number__c = '555-9998',
            SKU_Description__c = 'Order Item 2',
            UnitPrice = 99.9,
            Project__c = project.Id
        );

        OrderItem orderItem3 = new OrderItem(
            OrderId = order2.Id,
            PricebookEntryId = priceBookEntry.Id,
            Quantity = 2,
            Item_Class_Description__c = 'SVC EDT INSTLN',
            SKU_Number__c = '666-9998',
            SKU_Description__c = 'Order Item 3',
            UnitPrice = 99.9,
            Project__c = project.Id
        );

        insert new List<orderItem>{orderItem1,orderItem2, orderItem3}; 

        List<OrderItem> orderItemList = new List<OrderItem>{orderItem1, orderItem2, orderItem3};

        Map<pse__Proj__c, List<OrderItem>> orderItemsByProjectMap = new Map<pse__Proj__c, List<OrderItem>>{
            
            project => orderItemList

        };
            
        Test.startTest();
        ProjectEndDateConfiguration.setProjectEndDateByOrderItem(orderItemsByProjectMap);    
        Test.stopTest();
        
        System.assertEquals(project.pse__Start_Date__c.addDays(30), project.pse__End_Date__c, 'End date should match with start date...');
    }
}