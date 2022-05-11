@isTest
public class ResourceRequestSkillAutomatorTest {
    
    @testSetup
    static void setup(){
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            
        // Create Account
        Account account = new Account();
        account.Name = 'Create Account Test';
        insert account;

        // create order
        Order order = new Order();
        order.OrderNumber__c = '6543200';
        order.EffectiveDate = Date.today();
        order.AccountId = account.Id;
        order.CurrencyIsoCode = 'USD';
        order.BUID__c = '11';
        order.Status = 'BK';
        order.Order_Status__c = 'EC';
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.OCI_Order_Type__c = 'US Order';
        order.FF_Feed__c = true;
        insert order;
        
        // Order Product
        Product2 product = new Product2();
        product.Name='Product Test';
        insert product;

        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.UseStandardPrice = false; 
        pricebookEntry.UnitPrice = 1;
        insert pricebookEntry;

        // Order Item
        OrderItem oi = new OrderItem();
        oi.SKU_Description__c = 'SKU Desc 1';
        oi.SKU_Number__c = '777-1000';
        oi.Quantity = 1;
        oi.UnitPrice = 1;
        oi.Item_Class_Description__c = 'SVC EDT INSTLN';
        oi.Tie_Number__c = '1';
        oi.OrderId = order.Id;
        oi.PriceBookEntryId = priceBookEntry.Id;
        oi.SKU_Cost__c = 1;
        oi.Unit_Selling_Price_USD__c = 1;
        oi.SKU_Cost_USD__c = 1;
        insert oi;
        
        // create project
        pse__Proj__c project = new pse__Proj__c(
            Name = 'Project Test',
            pse__Is_Active__c = true,
          //  CreatedDate = Date.today().addDays(-11),
            pse__Start_Date__c = Date.today().addDays(-10),
            pse__End_Date__c = Date.today().addDays(60),
            Project_Complexity__c = 'Low'
        );
        insert project;
           
        // create region
        pse__Region__c region = new pse__Region__c(
            Name = 'Global'
        );
        insert region;   

        // permission control
        pse__Permission_Control__c permissionControl = new pse__Permission_Control__c(
            pse__User__c = UserInfo.getUserId(),
            pse__Region__c = region.Id,
            pse__Staffing__c = true,
            pse__Resource_Request_Entry__c = true
        );
        insert permissionControl; 

        SKU_Effort_Map__c skuEffortMap = new SKU_Effort_Map__c(
                Active__c = true,
                Description__c = 'ProDeploy Dell Storage SC Series vXXXX SAN - Deployment Verification',
                X30_Day_Support__c = true
        );
        insert skuEffortMap;

        SKU_Number__c skuNumber1 = new SKU_Number__c();
        skuNumber1.SKU_Number__c = '777-1000';
        skuNumber1.SKU_to_Effort_Mapping__c = skuEffortMap.Id;
        insert skuNumber1;

        pse__Proj__c globalProject = new pse__Proj__c();
        Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
        globalProject.Name = 'Global project';
        globalProject.RecordTypeId = recordTypeId;
        globalProject.pse__Is_Template__c = true;
        insert globalProject;

        pse__Project_Task__c phase = new pse__Project_Task__c(Name = 'Test', pse__Project__c = globalProject.Id);
        insert phase;
        
        SKU_Effort_Map_Entry__c entry = new SKU_Effort_Map_Entry__c();
        entry.SKU_Effort_Map__c = skuEffortMap.Id;
        entry.project__c = globalProject.Id;
        entry.Phase__c = phase.Id;
        entry.Estimated_Hours__c = 16;
        insert entry;  

        pse__Skill__c skill = new pse__Skill__c();
        skill.Name = 'Project Management';
        skill.pse__External_Id__c = '12346';
        insert skill;

        Skill_SKU_Effort_Map_Entry__c skillSku = new Skill_SKU_Effort_Map_Entry__c();
        skillSku.SKU_Effort_Map_Entry__c = entry.Id;
        skillSku.Skill_Certification__c = skill.Id;
        insert skillSku;  
        
        // resource request
        insert new ResourceRequestCustomSetting__c(SabaID__c = '12346');
        
        pse__Resource_Request__c resourceRequest = new pse__Resource_Request__c();
        resourceRequest.pse__Project__c = project.id;
        resourceRequest.pse__Resource_Role__c = 'Project Manager';
        resourceRequest.pse__Start_Date__c = Date.today();
        resourceRequest.pse__End_Date__c = Date.today().addDays(30);
        resourceRequest.pse__SOW_Hours__c = 30;
        resourceRequest.pse__Region__c = region.Id;
        resourceRequest.pse__Staffer_Resource__c = null;
        insert resourceRequest;

        // Skills
        pse__Skill__c lowSkill = new pse__Skill__c(Name = 'Project Management (Low)', pse__External_Id__c = '001');
        pse__Skill__c mediumSkill = new pse__Skill__c(Name = 'Project Management (Medium)', pse__External_Id__c = '002');
        pse__Skill__c highSkill = new pse__Skill__c(Name = 'Project Management (High)', pse__External_Id__c = '003');
        
        insert new List<pse__Skill__c>{ lowSkill, mediumSkill, highSkill };
            }
    }
    
    @isTest
    static void shouldRecalculateResourceSkillRequestFromProject(){

        List<Id> projectIds = new List<Id>();
        Map<Id, pse__Proj__c> projectMap = new Map<Id, pse__Proj__c>([
            SELECT Id, Project_Complexity__c, pse__Start_Date__c, pse__End_Date__c
            FROM pse__Proj__c 
            WHERE pse__Is_Template__c = false
        ]);

        List<pse__Resource_Skill_Request__c> skillRequestsBeforeTest = [
            SELECT Id
            FROM pse__Resource_Skill_Request__c
        ];

        System.assertEquals(0, skillRequestsBeforeTest.size());
        
        Test.startTest();
        
        ResourceRequestSkillAutomator.recalculateResourceSkillRequest(projectMap, null);
        
        Test.stopTest();

        List<pse__Resource_Skill_Request__c> skillRequestsAfterTest = [
            SELECT Id
            FROM pse__Resource_Skill_Request__c
        ];

        System.assertEquals(1, skillRequestsAfterTest.size());
    }
}