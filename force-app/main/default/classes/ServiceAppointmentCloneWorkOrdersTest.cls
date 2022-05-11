/*
      Purpose:
            Clone related work orders and work order skills from Service Appointment when status is 'Cannot Complete'
            
      Author	: Pawan Kumar
      Company	: OAC Services INC.
      Created	: 1/10/19

	=============================================================================================================
	Modification History:
	----------------------------------------------------------------------------
	Name		Date		Company				Description
	----------------------------------------------------------------------------
	
	----------------------------------------------------------------------------
*/

@isTest
public class ServiceAppointmentCloneWorkOrdersTest 
{
	@testSetup
    static void setupData()
    {
        Map<Id, String> workOrderIdToScheduleTypeMap = new Map<Id, String> ();
        List<WorkOrder> wolist = new List<WorkOrder>();
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
        Trigger_Execution_Control__c triggerToggle = new Trigger_Execution_Control__c(
            Skip_Work_Order_Cloning__c = false
        );
        insert triggerToggle;
        
        Account Acc = new Account(
       		name = 'Dell TestAccount'
        );
        insert Acc;
        
        Asset objAsset = new Asset(
        	name='Dell TestAsset',
        	AccountId= Acc.Id
        );
        insert objAsset;
        
        Contact objContact = new Contact(
        	LastName='DellTest',
         	FirstName='Test Contact',
            AccountId= Acc.Id,
         	Country_Code__c = 'Bermuda (441)',
         	email='DellTestContact@gmail.com',
         	Primary_Phone__c='7584930578',
            phone='1234567890'
        );
        insert objContact;
        
        Case objCase = new Case(
            AccountId= Acc.Id,
            AssetId= objAsset.Id,
            ContactId= objContact.Id,
            status= 'In Progress',
            Priority= 'Low',
            //Service_Tag__c='Dell Test',
            Origin= 'web',
            Subject= 'Test Subject',
            Description= 'Test Description for unit test'
            
        );
        //insert objCase;
        
        pse__Region__c testRegion = new pse__Region__c(
                Name = 'Test Region'
        );
        insert testRegion;
            
        pse__Proj__c projectTemplate = TestDataUtility.createProject(true);

        pse__Practice__c testPractice = new pse__Practice__c(
                Name = 'Test Practice',
            Standard_Project_Template__c = projectTemplate.Id
        );
        insert testPractice;
        
         pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = objContact.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
        );
        insert testProject;
        
        pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id,
                pse__Started__c = true
        );
        insert testProjectTask;

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

        Project_Location__c projectSite = new Project_Location__c(
            Address_Type__c = 'Install At Contact',
            // Site__c = site.Id,
            Location__c = objLocation.Id,
            Project__c = testProject.Id
            // Order__c = order.Id
        );
        
        insert(projectSite);
        
        Id recordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Installation Badge').getRecordTypeId();
        
        WorkOrder objWorkOrder= new WorkOrder(
            AccountId = Acc.Id,
            AssetId = objAsset.Id,
            ContactId = objContact.Id,
            AddressBUID__c='2121',
            Entitlement_Details__c = 'KYHD',
            KYHD__c = true,
            City = 'Round Rock',
            Country = 'United States',
            State = 'Texas',
            Street = 'Dell Way123',
            PostalCode  = '78664',
            RecordTypeId = recordTypeId,
            Project_Task__c = testProjectTask.Id,
            Project_Location__c = projectSite.Id
        );
        insert objWorkOrder;
		
        wolist.add(objWorkOrder);
            
        pse__Skill__c testSkill = new pse__Skill__c(
                Name = 'Test Skill 1',pse__External_Id__c='12345678123'
        );
        insert testSkill;
        
        Work_Order_Skill__c WOSkill = new Work_Order_Skill__c(
        	Work_Order__c = objWorkOrder.Id,
            CurrencyIsoCode = 'USD',
                Skill_Certification__c = testSkill.Id
        );
        insert WOSkill;
            
        for(WorkOrder wo : wolist){
        	workOrderIdToScheduleTypeMap.put(wo.Id, 'Appointment');  
        }
            
        ServiceAppointmentCloneWorkOrders.cloneWorkOrders(workOrderIdToScheduleTypeMap);
        
      /*  ServiceAppointment objSA = new ServiceAppointment(
            ContactId = objContact.Id,
            ParentRecordId = Acc.Id,
            EarliestStartTime = system.now(),
            DueDate = system.now().addDays(5),
            Status = 'Scheduled',
            Work_Order__c = objWorkOrder.Id
        );
        insert objSA; */
    }
        
    }
    
    public static testMethod void ServiceAppointmentCloneWorkOrders()
    {
        Test.startTest();
        /*ServiceAppointment objSA = [select Id,Status, Additional_Effort__c from ServiceAppointment where Work_Order__c != NULL];
        system.debug(objSA);
        objSA.Status = 'Click_Complete';
        objSA.Additional_Effort__c = 'Activity for Doc/Admin Time';
        update objSA; */
        Test.stopTest();
        
    }
}