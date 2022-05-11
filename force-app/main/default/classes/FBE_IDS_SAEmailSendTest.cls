/**************
 * @ Class Name        : FBE_IDS_SAEmailSendTest
 * @ Description       : This class is created to test code coverage for -  FBE_IDS_SAEmailSend.sendResourceConfirmationEmail() method.
 *                       Created as part of Feature #7946971.
 * @ CreatedBy         : Deloitte
 * @ CreatedOn         : 08-25-2020
 * @ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script
*********/
@IsTest
private class FBE_IDS_SAEmailSendTest {
    /**************
     * @MethodName    : setup
     * @Trigger       : -
     * @Description   : This method creates test data for email send.
     ***************/
	@TestSetup
    static void setup(){
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            Account account = new Account();
            account.Name = System.label.FBE_PSA_Resource_Account_Name;
            insert account;
            
            pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
                     
            List<pse__Practice__c> practiceList = new List<pse__Practice__c>();
            pse__Practice__c practices = new pse__Practice__c();
            practices.Name = 'Infrastructure Delivery Services';
            practices.Standard_Project_Template__c = projectTemplate.Id;
            practiceList.add(practices);
            
            insert practiceList;
            
            pse__Region__c region = new pse__Region__c();
            region.Name = 'United States';
            insert region;
            
            Profile userProfile = [SELECT Id, Name FROM Profile WHERE Profile.Name = 'PSA Technical Resource' LIMIT 1];
            List<User> users = new List<User>();
            User user1 = new User();
            user1.FirstName = 'Test Enable';
            user1.LastName = 'Permission Contact';
            user1.External_ID__c = '1234587';
            user1.FederationIdentifier = '1234587';
            user1.Organization__c = 'Scott Pittman (633976)';
            user1.Username = 'userPermissionEnablamentUser1@dell.com.salesforce';
            user1.Email = 'userPermissionEnablamentUser1@dell.com';
            user1.Alias = 'Alias';
            user1.CommunityNickname = 'EnablePermissionTest1';
            user1.TimeZoneSidKey = 'Asia/Kolkata';
            user1.LocaleSidKey = 'en_US';
            user1.EmailEncodingKey = 'UTF-8';
            user1.ProfileId = userProfile.Id;
            user1.LanguageLocaleKey = 'en_US';
            user1.OSP__c = 'No';
            user1.Dell_NTUserID__c = 'NTUSERID';
            user1.File_Source__c = 'GIS - Bulk';
            user1.Phone = '8899889909';
            user1.Service_User_Type__c = 'Business';
            user1.IsActive = true;
            user1.Agent_Location_Country__c = 'United States';
            user1.Country = 'United States';
            user1.Default_Weekly_Hours__c = '40';
            user1.HR_Job_Title__c = 'Senior Advisor, Engineering Project Management';
            user1.CurrencyIsoCode = 'USD';
            user1.EmployeeNumber = '12345';
            users.add(user1);
            
            insert users;
            
            List<Contact> objContact = [SELECT Id FROM Contact WHERE pse__Salesforce_User__c = :users[0].Id];
            
            FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
            List<ServiceResource> objResource = [SELECT Id FROM ServiceResource WHERE RelatedRecordId =: users[0].Id];
            
            List<pse__Schedule__c> scheduleList = FBE_Test_Utility.createSchedule(1);
            insert scheduleList;
            
            List<pse__Rate_Card__c> rateCardList = FBE_Test_Utility.createRateCard(1);
           // insert rateCardList;
            
            List<pse__Permission_Control__c> pcList = FBE_Test_Utility.createPermissionControlForPractice(1, practiceList, loginUser);
            insert pcList;
            
           // List<pse__Permission_Control__c> pcResourceList = FBE_Test_Utility.createPermissionControlForResource(1, objContact, loginUser);
            //insert pcResourceList;
            
            List<pse__Proj__c> projectList = new List<pse__Proj__c>();
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = objContact[0].Id,
                pse__Region__c = region.Id,
                pse__Practice__c = practiceList[0].Id,
                pse__Is_Active__c = true
            );
            projectList.add(testProject);
            insert projectList;
            
            List<pse__Permission_Control__c> pcProjectList = FBE_Test_Utility.createPermissionControlForProject(1, projectList, loginUser);
            insert pcProjectList;
            
            pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id,
                pse__Started__c = true
            );
            insert testProjectTask;
            
            List<pse__Assignment__c> assignmentList = FBE_Test_Utility.createAssignment(1, objContact, projectList, scheduleList, rateCardList);
            insert assignmentList;

           Schema.Location objLocation = new Schema.Location();
            objLocation.OwnerId = UserInfo.getUserId();
            objLocation.Name = '233 N Michigan Ave_Chicago';
            objLocation.CurrencyIsoCode = 'USD';
            objLocation.LocationType = 'Site';
            objLocation.IsMobile = false;
            objLocation.IsInventoryLocation = false;
            insert objLocation;
            
            /*Schema.Address objAddress = new Schema.Address();
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
            insert objAddress;*/
            
            Project_Location__c projectSite = new Project_Location__c(
                Address_Type__c = 'Install At Contact',
                // Site__c = site.Id,
                Location__c = objLocation.Id,
                Project__c = testProject.Id
                // Order__c = order.Id
            );
            
            insert(projectSite);
            
            Id recordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Installation Badge').getRecordTypeId();
            
            List<WorkOrder> workOrderList = new List<WorkOrder>();
            WorkOrder objWorkOrder= new WorkOrder(
                AccountId = account.Id,
                ContactId = objContact[0].Id,
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
            workOrderList.add(objWorkOrder);
            insert workOrderList;
            
            /*pse__Skill__c testSkill = new pse__Skill__c(
                Name = 'Test Skill 1'
            );
            insert testSkill; 
            
            List<Skill> skillList = [SELECT Id, MasterLabel FROM Skill Limit 1];*/
            
            /*SkillRequirement skillReq = new SkillRequirement();
            skillReq.SkillId = skillList[0].Id;
            skillReq.SkillLevel = 3;
            skillReq.RelatedRecordId = objWorkOrder.Id;
            insert skillReq;*/
            
          /*  List<ServiceAppointment> objSA = FBE_Test_Utility.createServiceAppointment(1, workOrderList, assignmentList, objContact, projectList);
            insert objSA;
            
            /*List<OperatingHours> opList = FBE_Test_Utility.createOperatingHours();
            insert opList;
            
            List<ServiceTerritory> stList = FBE_Test_Utility.createServiceTerritory(opList);
            insert stList;
            
            List<ServiceTerritoryMember> stmList = FBE_Test_Utility.createServiceTerritoryMember(stList, objResource);
            stmList[0].EffectiveStartDate = Date.today()-2;
            insert stmList;*/
            
            //List<AssignedResource> assignedResources = FBE_Test_Utility.createAssignedResource(1, objSA, objResource);
           // insert assignedResources; 
            
           /* List<TitleAndBody> testTextList = new List<TitleAndBody>();
            testTextList.add(new TitleAndBody('Lorem Ipsum Consectetur','This is mny Lorem Ipsum thing.'));
            createNotesAndLinks(objSA,testTextList);*/
			
        }
    }
 
    /**************
     * @MethodName    : testEmailSend
     * @Trigger       : -
     * @Description   : This method tests the code for sendResourceConfirmationEmail.
     ***************/
    @isTest              
    static void testEmailSend(){
        Test.startTest(); 
		List<ServiceAppointment> listSA = [SELECT Id FROM ServiceAppointment
                                          LIMIT 1];
        List<pse__Assignment__c> assignmentList = [SELECT Id FROM pse__Assignment__c LIMIT 1];
        List<WorkOrder> workOrderList = [SELECT Id FROM WorkOrder LIMIT 1];
       	List<Contact> objContact = [SELECT Id FROM Contact LIMIT 1];
        List<pse__Proj__c> projectList = [SELECT Id FROM pse__Proj__c LIMIT 1];
        //System.debug('abhi:projectList[0].pse__Start_Date__c='+projectList[0].pse__Start_Date__c);
        
        List<ServiceResource> objResource = [SELECT Id FROM ServiceResource LIMIT 1];
                                            
         	List<ServiceAppointment> objSA = FBE_Test_Utility.createServiceAppointment(1, workOrderList, assignmentList, objContact, projectList);
        objSA[0].SchedStartTime = System.today().addDays(1);
        System.debug('abhi:objSA.SchedStartTime='+objSA[0].SchedStartTime);    
        insert objSA;
            
            List<OperatingHours> opList = FBE_Test_Utility.createOperatingHours();
            insert opList;
            
           /* List<ServiceTerritory> stList = FBE_Test_Utility.createServiceTerritory2(opList);
            insert stList;
            
            List<ServiceTerritoryMember> stmList = FBE_Test_Utility.createServiceTerritoryMember(stList, objResource);
            stmList[0].EffectiveStartDate = Date.today()-2;
            insert stmList;
            
            List<AssignedResource> assignedResources = FBE_Test_Utility.createAssignedResource(1, objSA, objResource);
            insert assignedResources; */
            
            List<TitleAndBody> testTextList = new List<TitleAndBody>();
            testTextList.add(new TitleAndBody('Lorem Ipsum Consectetur','This is mny Lorem Ipsum thing.'));
            createNotesAndLinks(objSA,testTextList);
			
        
        FBE_IDS_SAEmailSend.sendResourceConfirmationEmail(objSA);
        Integer invocations = Limits.getEmailInvocations();
       // System.assertEquals(1, invocations, 'An email has not been sent');
        
        Test.stopTest();
    }
        
    
    static List<ContentNote> createNotesAndLinks(List<ServiceAppointment> objSA, List<TitleAndBody> testText){
        Test.startTest();
        List<ContentNote> notes = new List<ContentNote>();
        for (TitleAndBody tst : testText) {
            notes.add(new ContentNote(Title=tst.Title,Content=tst.Body != null ? Blob.valueOf(tst.Body) : null));
        }
        insert notes;
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (ContentNote contentNote : notes) {
            links.add(new ContentDocumentLink(ContentDocumentId=contentNote.Id,LinkedEntityId=objSA[0].Id,ShareType='I'));
        }
        insert links;
        Test.stopTest();
        return notes;
    }
    
    class TitleAndBody {
        public TitleAndBody(String title, String body) {
            this.Title = title;
            this.Body = body;
        }
        public String Title {get;set;}
        public String Body {get;set;}
    }
}