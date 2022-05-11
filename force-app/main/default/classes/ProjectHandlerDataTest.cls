@isTest()
public class ProjectHandlerDataTest {
     @testSetup
    static void testDataSetup(){
        
        User loginUser =  [Select Id from User where FBE_Integration_User__c = true];
          system.runAs(loginUser){ 
              
              Account account = MDF_AccountFactory.start()
                  .siteAccessRequired('Yes')
                  .create();
              
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
      
              pse__Time_Period__c testTimePeriod = TestDataGenerator.createTimePeriod();
              insert testTimePeriod;
              
              pse__Proj__c projToPractice = MDF_ProjectTemplateFactory.start()
                  .projectPhase('Setup')
                  .projectType('Standard')
                  .stage('Draft')
                  .isActive(true)
                  .create();
              
              pse__Practice__c testPractice = TestDataGenerator.createPractice(testTimePeriod.Id, projToPractice.Id);
              testPractice.Id = null;
              testPractice.Standard_Project_Template__c = projToPractice.Id;
              insert testPractice;
              
              pse__Region__c region = MDF_RegionFactory.start()
                  .isoCountryCode('R1')
                  .create();
              
              pse__Work_Calendar__c workCalendar = MDF_WorkCalendarFactory.start()
                  .name('Test Work Calendar')
                  .create();

              
        pse__Region__c r1 = [
                SELECT Id
                FROM pse__Region__c
        ];

              
         Contact contactIns = MDF_ContactFactory.start()
            .relatedAccount(account)
            .relatedSalesforceUser(userIns.Id)
            .relatedRegion(region)
            .relatedWorkCalendar(workCalendar)
            .isResourceActive(true)
            .isResource(true)
            .create();
            
           
            pse__Proj__c testProj1 = MDF_ProjectTemplateFactory.start()
            .name('Test project')
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
            .relatedAccount(account)
            .create();
              
                        
           
               Order order2 = new Order(
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

        insert order2;
    }
    }
      
     @isTest
     static void testProjectInfo(){ 
      
        pse__Proj__c projects = [select Id, Name, Site_ID__c FROM pse__Proj__c WHERE Name = 'Test project'];
      
         set<id> projids = new set<id>();
         projids.add(projects.id);
         ProjectHandlerData.getProjectInformation(projids);
         ProjectHandlerData.getProjectTaskSkuEffortMappingEntriesByProjectsId(projids);
        
     }
    
    
    @isTest
    static void testWOSkuEfforMapEntryMethod(){
        
        List<pse__Proj__c> projList = new List<pse__Proj__c>();   
        pse__Proj__c projects = [select Id, Name, Site_ID__c FROM pse__Proj__c WHERE Name = 'Test project'];
        set<id> projids = new set<id>();
        projids.add(projects.id);
        projList.add(projects);
      
        List<pse__Project_Task__c> tasks = new List<pse__Project_Task__c>();
        tasks.add(new pse__Project_Task__c(Name='Setup', pse__Project__c=projects.Id, pse__Start_Date_Time__c=System.now(), pse__End_Date_Time__c=System.now()));
        tasks.add(new pse__Project_Task__c(Name='Initiate', pse__Project__c=projects.Id, pse__Start_Date_Time__c=System.now(), pse__End_Date_Time__c=System.now()));
        tasks.add(new pse__Project_Task__c(Name='Configuration', pse__Project__c=projects.Id, pse__Start_Date_Time__c=System.now(), pse__End_Date_Time__c=System.now(), pse__Parent_Task__c = tasks[1].Id));
        
        insert tasks;
        
      
        
        SKU_Effort_Map__c skuEffortMap = MDF_SKUEffortMapFactory.start()
        .create();
        
       
         SKU_Effort_Map_Entry__c effortMapEntry = new SKU_Effort_Map_Entry__c(project__c=projects.Id,
                Name__c='Remote Config',
                SKU_Effort_Map__c=skuEffortMap.Id,
                Phase__c=tasks.get(1).Id,
                Role__c= 'Project Manager',
                Project_Complexity_Tier__c='Tier 1',
                Estimated_Hours__c=10);


        insert effortMapEntry;
        
        List<WO_SKU_Effort_Map__c> woSkuList = New List<WO_SKU_Effort_Map__c>();
        
         WO_SKU_Effort_Map__c woSkuEffortMapOnSiteOnDemandFalse = MDF_WOSKUEffortMapFactory.start()
                .calculationType('By Threshold')
                .deliveryMethod('OnSite')
                .description('Scoping Appointment')
                .duration(20)
                .relatedSKUEffortMappingEntry(effortMapEntry)
                .woRecordType('FF - Unknown')
                .autoDispatch(true)
                .woType('Install')
                .OnDemand(false)
                .create();
        
        woSkuList.add(woSkuEffortMapOnSiteOnDemandFalse);
        
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
            	.template(projects.Id)
                .create();
        
    woSkuList.add(woSkuEffortMapOnSiteOnDemandTrue);
        
        set<id> skuEntryid = new set<id>();
        skuEntryid.add(effortMapEntry.id);
        set<id> taskids = new set<id>();
        taskids.add(tasks[0].id);
        
        ProjectHandlerData.getWoSkuEffortMapByEntry(skuEntryid);
        ProjectHandlerData.getProjectTaskSillsByProjectTasks(taskids);
        ProjectHandlerData.getOrderItemSkuEffortMapsBySkuEffortMappingsAndProject(woSkuList, projids);
        ProjectHandlerData.getPseMilestonesByPseProjects(projList);
        ProjectHandlerData.getOrderItemByProject(projids);
        ProjectHandlerData.getProjectsWithChildrenProjectContacts(projList);
        ProjectHandlerData.getskuEffortMapWithChildrenSkills(skuEntryid);
        
        
     
    }
    
    @isTest
    Static void testLocationByProj(){
    
          pse__Proj__c projects = [select Id, Name, Site_ID__c FROM pse__Proj__c WHERE Name = 'Test project'];
          Order orders = [Select id, Project__c, OrderNumber__c from Order WHERE OrderNumber__c = '555666' ];
          set<id> locationid = new set<id>();
             List<Schema.Location> lstLocation = new List<Schema.Location>();
        for(Integer count = 0; count<10; count++){
        
        Schema.Location LocationDefaultAddressTrue = new Schema.Location();
        LocationDefaultAddressTrue.OwnerId = UserInfo.getUserId();
        LocationDefaultAddressTrue.Name = '233 N Michigan Ave_Chicago'+ count;
        LocationDefaultAddressTrue.CurrencyIsoCode = 'USD';
        LocationDefaultAddressTrue.LocationType = 'Site';
        LocationDefaultAddressTrue.IsMobile = false;
        LocationDefaultAddressTrue.IsInventoryLocation = false;
        LocationDefaultAddressTrue.Project__c = projects.Id;
        LocationDefaultAddressTrue.Order__c = orders.Id;
        LocationDefaultAddressTrue.Default_Address__c = true;
        
        lstLocation.add(LocationDefaultAddressTrue);
        locationid.add(LocationDefaultAddressTrue.id);
        }    
            insert lstLocation;
            
            set<id> projids = new set<id>();
            projids.add(projects.id);
          
            ProjectHandlerData.getlocationsByProjectsId(projids);
            ProjectHandlerData.getAddressesByLocations(locationid);
            ProjectHandlerData.getOrdersByProject(projids);
            
        }
    
/* @isTest()
    Static void testWorkordersMethod(){
        
     pse__Proj__c projects = [select Id, Name, Site_ID__c FROM pse__Proj__c WHERE Name = 'Test project'];
     Id workrecordtypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Installation DSP').getRecordTypeId();
            WorkOrder wo = new WorkOrder();
            wo.Status = 'FF - New';
            wo.AccountId = account.Id;
            wo.Project__c = testProj1.Id;
            wo.Project_Task__c = objProjectTask.Id;
            wo.WorkTypeId = objWorkType.Id;
            wo.RecordTypeId = workrecordtypeId;
            insert wo;
        
    }*/
           
}