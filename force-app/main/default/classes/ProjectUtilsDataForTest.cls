@IsTest
 public class ProjectUtilsDataForTest {

    public pse__Proj__c testProject;
    public pse__Budget__c testBudget;
    public List<Project_Complexity_Threshold__c> TestProjectComplexities;
    public List<Project_Complexity_Mapping__c> projComplexityMappings;
    public Project_Contact__c testProjectContact;
    public Project_Contact__c testProjectContact2;
    public Project_Location__c testProjectLocation;
    public Schema.Location testLocation;
    public Schema.Address testAddress;
    public Project_Location__c testProjectLocation2;
    public Project_Location__c testProjectLocationNull;
    public Schema.Location testLocation2;
    public Schema.Address testAddress2;
    public pse__Project_Task__c testProjectTask;
    public pse__Project_Task__c testProjectParentTask;
    public pse__Project_Task_Assignment__c testProjectTaskAssignment;
    public pse__Task_Time__c testTaskTime;
    public pse__Timecard_Header__c testTimecard;
    public pse__Assignment__c testAssignment;
    public pse__Schedule__c testSchedule;
    public static Contact testContact;
    public static Contact testContactWithoutManager;
    public Account testAccount;
    public Order testOrder;
    public Order testOrder2;
    public static User testUser;
    public static User testUserWithoutManager;
    public static User testOwner;
    public RecordType testRecordType;
    public static pse__Region__c testRegion;
    public static pse__Practice__c testPracticeIDS;
    public static pse__Practice__c testPracticeEIS;
    public static pse__Practice__c testPractice;
    public static pse__Practice__c testPractice2;
    public Profile testProfile;
    public Group testQueue;
    public pse__Expense_Report__c testExpenseReport;
    public pse__Expense__c testExpense;
    public List<pse__Skill__c> skills;

    public static final Datetime START_DATE = Datetime.now().addDays(1);
    public static final Datetime END_DATE = Datetime.now().addDays(8);

    public static ProjectUtilsDataForTest build() {
        return new ProjectUtilsDataForTest();
    }


    @IsTest
    static void createTestData() {
        ProjectUtilsDataForTest.build()
                .createProject()
                .setupProjectComplexityMappings()
                .setupSkills()
                .CreateProjectComplexities();
    }

    public pse__Proj__c createProjectWithGroup(Group owner) {
        Date startDate = START_DATE.date();
        Date endDate = END_DATE.date();
        return projectTemplate(startDate, endDate, owner.Id, testContact);
    }

    public pse__Proj__c createProjectWithUser(User owner) {
        Date startDate = START_DATE.date();
        Date endDate = END_DATE.date();
        return projectTemplate(startDate, endDate, owner.Id, testContact);
    }

    public ProjectUtilsDataForTest createProject() {
        createContact();
        createRecordType();
        createRegion();
        createPractice();
        if (testProject == null) {
            pse__Proj__c project = createProject(testContact);
            this.testProject = project;
        }
        return this;
    }
 

    public pse__Proj__c createProject(Contact projectMananger) {
        createContact();
        createRecordType();
        createRegion();
        createPractice();
        Date startDate = START_DATE.date() + 1;
        Date endDate = END_DATE.date();

        pse__Proj__c project = projectTemplate(startDate, endDate, testOwner.Id, projectMananger);

        return project;
    }

    private pse__Proj__c projectTemplate(Date startDate, Date endDate, Id ownerId, Contact projectManager) {
        pse__Proj__c pseProject = new pse__Proj__c();
        pseProject.pse__Is_Active__c = true;

        if (projectManager != null) {
            pseProject.pse__Project_Manager__c = projectManager.Id;
            pseProject.pse__Project_Manager__r = projectManager;
        }

        pseProject.RecordTypeId = testRecordType.Id;
        pseProject.pse__Region__c = testRegion.Id;
        pseProject.pse__Practice__c = ProjectUtilsDataForTest.testPractice.Id;
        pseProject.pse__Start_Date__c = startDate;
        pseProject.pse__End_Date__c = endDate;
        pseProject.PM_Complexity__c = 'Low';
        pseProject.pse__Stage__c = 'In Progress';
        pseProject.pse__Project_Phase__c = 'Initiate';
        pseProject.pse__Project_Type__c = 'Custom';
        pseProject.Setup_Project__c = true;
        pseProject.pse__Is_Billable__c = true;
        pseProject.Accounting_Treatment__c = 'Revenue';
        pseProject.Name = 'Project Name';
        pseProject.pse__Is_Template__c = false;
        pseProject.Project_Visibility__c = 'All';
        pseProject.pse__Closed_for_Expense_Entry__c = false;
        pseProject.pse__Allow_Expenses_Without_Assignment__c = true;
        pseProject.Close_Project__c = false;
        if (ownerId != null) {
            pseProject.OwnerId = ownerId;
        }

        insert pseProject;

        pse__Proj__c project = [
                SELECT Id,
                        Name,
                        pse__Notes__c,
                        pse__Project_ID__c,
                        pse__Is_Active__c,
                        pse__Internal_Budget__c,
                        CurrencyIsoCode,
                        pse__Stage__c,
                        pse__Project_Phase__c,
                        pse__Project_Type__c,
                        pse__Project_Manager__c,
                        pse__Project_Manager__r.pse__Salesforce_User__r.External_ID__c,
                        pse__Project_Manager__r.pse__Salesforce_User__r.Manager.External_ID__c,
                        RecordTypeId,
                        pse__Region__c,
                        pse__Practice__c,
                        pse__Is_Billable__c,
                        pse__Start_Date__c,
                        pse__End_Date__c,
                        pse__Closed_for_Expense_Entry__c,
                        pse__Allow_Expenses_Without_Assignment__c,
                        PSA_Project_Created_Date__c,
                        OwnerId
                FROM pse__Proj__c
                WHERE Id = :pseProject.Id
                LIMIT 1
        ];
        return project;
    }

    public ProjectUtilsDataForTest createProjectContact() {
        createProject();
        createContact();

        if (testProjectContact == null) {
            Project_Contact__c projectContact = new Project_Contact__c(
                    Project__c = testProject.Id,
                    Contact__c = testContact.Id,
                    Contact__r = testContact,
                    Contact_Role__c = 'End User',
                    Contact_Type__c = 'Customer',
                    Primary_Contact__c = true
            );

            insert projectContact;

            this.testProjectContact = projectContact;

            Project_Contact__c projectContact2 = new Project_Contact__c(
                    Project__c = testProject.Id,
                    Contact__c = testContactWithoutManager.Id,
                    Contact__r = testContactWithoutManager,
                    Contact_Role__c = 'End User',
                    Contact_Type__c = 'Customer',
                    Primary_Contact__c = false
            );

            insert projectContact2;

            this.testProjectContact2 = projectContact2;
        }

        return this;
    }

    public ProjectUtilsDataForTest createProjectLocation() {
        createProject();
        createAddress();
        createLocation();

        if (testProjectLocation == null) {
            Project_Location__c projectLocation = new Project_Location__c(
                    Address_Type__c = 'Shipping',
                    Name = 'Location name',
                    Project__c = testProject.Id,
                    Location__r = testLocation,
                    Location__c = testLocation.Id,
                    Default_Address__c = true
            );



            this.testProjectLocation = projectLocation;

            Project_Location__c projectLocation2 = new Project_Location__c(
                    Address_Type__c = 'Billing',
                    Name = 'Location 2 name',
                    Project__c = testProject.Id,
                    Location__r = testLocation2,
                    Location__c = testLocation2.Id
            );



            this.testProjectLocation2 = projectLocation2;


            Project_Location__c projectLocationNull = new Project_Location__c(
                    Address_Type__c = 'Billing',
                    Name = 'Location 2 name',
                    Project__c = testProject.Id
            );

            List<Project_Location__c> locations = new List<Project_Location__c>();
            locations.add(projectLocation);
            locations.add(projectLocation2);
            locations.add(projectLocationNull);
            this.testProjectLocationNull = projectLocationNull;

            insert locations;
        }

        return this;
    }

    public ProjectUtilsDataForTest createAddress() {
        createLocation();

        if (testAddress == null) {
            Schema.Address thisAddress = new Schema.Address();
            thisAddress.City = 'Orlando';
            thisAddress.Country = 'United States';
            thisAddress.CountryCode = 'US';
            thisAddress.LocationType = 'Warehouse';
            thisAddress.PostalCode = '32806';
            thisAddress.State = 'Florida';
            thisAddress.StateCode = 'FL';
            thisAddress.Street = '1222 S Orange Ave';
            thisAddress.ParentId = testLocation.Id;

            insert thisAddress;

            this.testAddress = thisAddress;

            Schema.Address thisAddress2 = new Schema.Address();
            thisAddress2.City = 'Tijuana';
            thisAddress2.Country = 'Mexico';
            thisAddress2.CountryCode = 'MX';
            thisAddress2.LocationType = 'Warehouse';
            thisAddress2.PostalCode = '22117';
            thisAddress2.State = 'Baja California';
            thisAddress2.StateCode = 'BCN';
            thisAddress2.Street = 'Blvd. Gustavo Diaz Ordaz 137';
            thisAddress2.ParentId = testLocation2.Id;
            insert thisAddress2;

            this.testAddress2 = thisAddress2;
        }

        return this;
    }

    public ProjectUtilsDataForTest createLocation() {
        if (testLocation == null) {
            Schema.Location thisLocation = new Schema.Location(
                    Name = 'Location'
            );

            insert thisLocation;

            this.testLocation = thisLocation;

            Schema.Location thisLocation2 = new Schema.Location(
                    Name = 'Location 2'
            );

            insert thisLocation2;

            this.testLocation2 = thisLocation2;
        }

        return this;
    }

    public ProjectUtilsDataForTest createProjectTask() {
        createProject();

        if (testProjectTask == null) {
            pse__Project_Task__c pseParentTask = new pse__Project_Task__c();
            pseParentTask.pse__Project__c = testProject.Id;
            pseParentTask.pse__Project__r = testProject;
            pseParentTask.pse__Start_Date_Time__c = START_DATE + 1;
            pseParentTask.pse__End_Date_Time__c = END_DATE;
            pseParentTask.Name = 'Description Parent Task';
            insert pseParentTask;

            List<pse__Project_Task__c> pseParentTasks = [SELECT pse__Project__c, pse__Task_Number__c, Name,pse__Blocked__c, pse__Start_Date__c, pse__End_Date__c, pse__Parent_Task__c FROM pse__Project_Task__c WHERE Id = :pseParentTask.Id];
            pseParentTask = pseParentTasks != null && pseParentTasks.size() > 0 ? pseParentTasks[0] : null;

            this.testProjectParentTask = pseParentTask;

            pse__Project_Task__c pseTask = new pse__Project_Task__c();
            pseTask.pse__Project__c = testProject.Id;
            pseTask.pse__Project__r = testProject;
            pseTask.pse__Start_Date_Time__c = START_DATE;
            pseTask.pse__End_Date_Time__c = END_DATE;
            pseTask.Name = 'Description Child Task';
            pseTask.pse__Parent_Task__c = pseParentTask.Id;
            pseTask.pse__Parent_Task__r = pseParentTask;
            insert pseTask;

            List<pse__Project_Task__c> pseTasks = [SELECT pse__Project__c, pse__Task_Number__c, Name, pse__Blocked__c, pse__Start_Date__c, pse__End_Date__c, pse__Parent_Task__c FROM pse__Project_Task__c WHERE Id = :pseTask.Id];
            pseTask = pseTasks != null && pseTasks.size() > 0 ? pseTasks[0] : null;

            this.testProjectTask = pseTask;
        }

        return this;
    }

    public ProjectUtilsDataForTest createProjectTaskAssignment() {
        createProject();
        createProjectTask();
        createContact();

        if (testProjectTaskAssignment == null) {
            pse__Project_Task_Assignment__c pseTaskAssignment = new pse__Project_Task_Assignment__c();
            pseTaskAssignment.pse__Project_Task__c = testProjectTask.Id;
            pseTaskAssignment.pse__Resource__c = testContact.Id;
            pseTaskAssignment.pse__Resource__r = testContact;

            insert pseTaskAssignment;


            this.testProjectTaskAssignment = [
                    SELECT Name,
                            Id,
                            pse__Project_Task__c,
                            pse__Resource__c,
                            pse__Resource__r.pse__Salesforce_User__r.External_ID__c,
                            pse__Resource__r.pse__Salesforce_User__r.Email,
                            pse__Resource__r.pse__Salesforce_User__r.FirstName,
                            pse__Resource__r.pse__Salesforce_User__r.LastName
                    FROM pse__Project_Task_Assignment__c
                    WHERE Id = :pseTaskAssignment.Id
                    LIMIT 1
            ];
        }

        return this;
    }

    public ProjectUtilsDataForTest createAssignment() {
        createProject();
        createContact();
        createSchedule();
        createPermissionControl();

        if (testAssignment == null) {
            pse__Assignment__c assignment = new pse__Assignment__c();
            assignment.pse__Resource__c = testContact.Id;
            assignment.pse__Resource__r = testContact;
            assignment.pse__Project__c = testProject.Id;
            assignment.pse__Project__r = testProject;
            assignment.pse__Bill_Rate__c = 0;
            assignment.pse__Schedule__c = testSchedule.Id;
            assignment.pse__Schedule__r = testSchedule;
            assignment.pse__Closed_for_Expense_Entry__c = false;


            insert assignment;

            this.testAssignment = assignment;
        }

        return this;
    }

    public ProjectUtilsDataForTest createSchedule() {
        createProject();

        if (testSchedule == null) {
            pse__Schedule__c schedule = new pse__Schedule__c();
            schedule.pse__Start_Date__c = testProject.pse__Start_Date__c;
            schedule.pse__End_Date__c = testProject.pse__End_Date__c;

            insert schedule;

            this.testSchedule = schedule;
        }

        return this;
    }

    public ProjectUtilsDataForTest createAccount() {
        if (testAccount == null) {
            Account pseAccount = new Account();
            pseAccount.BUID__c = '11';
            pseAccount.Name = 'Account Name';
            pseAccount.AccountNumber = '987654321';
            pseAccount.CCN__c = '12';

            insert pseAccount;

            this.testAccount = pseAccount;
        }

        return this;
    }

    public ProjectUtilsDataForTest createOrder() {
        return createOrder(null) ;
    }

    public ProjectUtilsDataForTest createOrder(pse__Practice__c practice) {
        createAccount();
        createProject();

        if (testOrder == null) {
            Order pseOrder = new Order();
            pseOrder.Local_Channel__c = '11';
            pseOrder.Account = testAccount;
            pseOrder.AccountId = testAccount.Id;
            pseOrder.EffectiveDate = Date.newInstance(2008, 11, 15);
            pseOrder.Order_Status__c = 'BK';
            pseOrder.Status = 'BK';
            pseOrder.OrderNumber__c = Datetime.now().millisecond().format();
            pseOrder.DPID__c = '1234567890';
            pseOrder.BUID__c = '22';
            pseOrder.Project__c = testProject.Id;
            pseOrder.Project__r = testProject;

            if(practice != null){
                pseOrder.Practice__c = practice.Id;
                pseOrder.Practice__r = practice;
            }

            insert pseOrder;

            this.testOrder = pseOrder;
        }

        return this;
    }

    public ProjectUtilsDataForTest createOrder2() {
        return createOrder2(null);
    }

    public ProjectUtilsDataForTest createOrder2(pse__Practice__c practice) {
        createAccount();
        createProject();

        if (testOrder2 == null) {
            Order pseOrder = new Order();
            pseOrder.Local_Channel__c = '11';
            pseOrder.Account = testAccount;
            pseOrder.AccountId = testAccount.Id;
            pseOrder.EffectiveDate = Date.newInstance(2008, 11, 15);
            pseOrder.Order_Status__c = 'BK';
            pseOrder.Status = 'BK';
            pseOrder.OrderNumber__c = '33445566778';
            pseOrder.DPID__c = '0123456789';
            pseOrder.BUID__c = '22';
            pseOrder.Project__c = testProject.Id;
            pseOrder.Project__r = testProject;

            if(practice != null){
                pseOrder.Practice__c = practice.Id;
                pseOrder.Practice__r = practice;
            }

            insert pseOrder;

            this.testOrder2 = pseOrder;
        }

        return this;
    }

    public ProjectUtilsDataForTest createPermissionControl() {
        createContact();

        pse__Permission_Control__c permissionControl = new pse__Permission_Control__c(
                pse__Region__c = testRegion.Id,
                pse__User__c = testUser.Id,
                pse__Cascading_Permission__c = true,
                pse__Staffing__c = true,
                pse__Expense_Entry__c = true,
                pse__Expense_Ops_Edit__c = true,
                pse__Team_Edit__c = true,
                pse__Resource_Request_Entry__c = true,
                pse__Billing__c = true,
                pse__Timecard_Entry__c = true,
                pse__Team_View__c = true,
                pse__Team_Create__c = true,
                pse__Skills_And_Certifications_View__c = true,
                pse__Skills_And_Certifications_Entry__c = true
        ) ;

        insert permissionControl;

        pse__Permission_Control__c permissionControlSystemUser = new pse__Permission_Control__c(
                pse__Region__c = testRegion.Id,
                pse__User__c = System.userinfo.getUserId(),
                pse__Cascading_Permission__c = true,
                pse__Staffing__c = true,
                pse__Expense_Entry__c = true,
                pse__Expense_Ops_Edit__c = true,
                pse__Team_Edit__c = true,
                pse__Resource_Request_Entry__c = true,
                pse__Billing__c = true,
                pse__Timecard_Entry__c = true,
                pse__Team_View__c = true,
                pse__Team_Create__c = true,
                pse__Skills_And_Certifications_View__c = true,
                pse__Skills_And_Certifications_Entry__c = true
        ) ;
        insert permissionControlSystemUser;

        return this;
    }

    public ProjectUtilsDataForTest createContact() {
        if(testRegion==null)createRegion();
        createUser();

        User thisUser = [SELECT Id FROM User WHERE Id = :userinfo.getUserId()];
        System.runAs (thisUser) {
            if (testContact == null) {
                /* Contact pseContact = new Contact();
                pseContact.Badge_ID__c = testUser.External_ID__c;
                pseContact.LastName = testUser.LastName;
                pseContact.FirstName = testUser.FirstName;
                pseContact.Email = testUser.Email;
                pseContact.Phone = testUser.Phone;
                pseContact.pse__Salesforce_User__c = testUser.Id;
                pseContact.pse__Salesforce_User__r = testUser;
                pseContact.pse__Is_Resource_Active__c = true;
                pseContact.pse__Is_Resource__c = true;
                pseContact.pse__Region__c = testRegion.Id;

                Contact pseContact2 = new Contact();
                pseContact2.Badge_ID__c = testUserWithoutManager.External_ID__c;
                pseContact2.LastName = testUserWithoutManager.LastName;
                pseContact2.FirstName = testUserWithoutManager.FirstName;
                pseContact2.Email = testUserWithoutManager.Email;
                pseContact2.Phone = testUserWithoutManager.Phone;
                pseContact2.pse__Salesforce_User__c = testUserWithoutManager.Id;
                pseContact2.pse__Salesforce_User__r = testUserWithoutManager;
                pseContact2.pse__Is_Resource_Active__c = true;
                pseContact2.pse__Is_Resource__c = true;
                pseContact2.pse__Region__c = testRegion.Id;


                List<Contact> contacts = new List<Contact>();
                contacts.add(pseContact);
                contacts.add(pseContact2);
                insert contacts; */
                List<Contact> pseContact2 = [select id,firstname, lastname from Contact where firstname = 'Manager' and lastname = 'Contact' limit 1];
                List<Contact> pseContact = [select id,firstname, lastname from Contact where firstname = 'Test' and lastname = 'Contact' limit 1];
                if(pseContact2 != null && pseContact2.size() > 0)
                    ProjectUtilsDataForTest.testContactWithoutManager = pseContact2[0];
                if(pseContact != null && pseContact.size() > 0)
                    ProjectUtilsDataForTest.testContact = pseContact[0];
                
            }
        }

        return this;
    }

    public ProjectUtilsDataForTest createUser() {
        createProfile();

        User thisUser = [SELECT Id FROM User WHERE Id = :userinfo.getUserId()];
        System.runAs (thisUser) {
            if (testUser == null) {
                User pseManagerUser = new User();
                pseManagerUser.FirstName = 'Manager';
                pseManagerUser.LastName = 'Contact';
                pseManagerUser.External_ID__c = '789123';
                pseManagerUser.FederationIdentifier = '789123';
                pseManagerUser.Organization__c = 'Scott Pittman (633976)';
                pseManagerUser.Username = 'usermanager@dell.com.salesforce';
                pseManagerUser.Email = 'usermanager@dell.com';
                pseManagerUser.Phone = '51995632541';
                pseManagerUser.Alias = 'Manager';
                pseManagerUser.CommunityNickname = 'CommunityNicknameManager';
                pseManagerUser.TimeZoneSidKey = 'GMT';
                pseManagerUser.LocaleSidKey = 'en_US';
                pseManagerUser.EmailEncodingKey = 'UTF-8';
                pseManagerUser.ProfileId = testProfile.Id;
                pseManagerUser.LanguageLocaleKey = 'en_US';
                pseManagerUser.OSP__c = 'No';
                pseManagerUser.Dell_NTUserID__c = 'NTUSERIDMANAGER';
                pseManagerUser.File_Source__c = 'GIS - Bulk';
                pseManagerUser.Service_User_Type__c = 'Service Account';
                pseManagerUser.IsActive = true;
                pseManagerUser.EmployeeNumber = '541233';

                insert pseManagerUser;

                ProjectUtilsDataForTest.testUserWithoutManager = pseManagerUser;

                User pseUser = new User();
                pseUser.FirstName = 'Test';
                pseUser.LastName = 'Contact';
                pseUser.External_ID__c = '345678';
                pseUser.FederationIdentifier = '345678';
                pseUser.Organization__c = 'Scott Pittman (633976)';
                pseUser.Username = 'user@dell.com.salesforce';
                pseUser.Email = 'user@dell.com';
                pseUser.Alias = 'Alias';
                pseUser.CommunityNickname = 'CommunityNickname';
                pseUser.TimeZoneSidKey = 'GMT';
                pseUser.LocaleSidKey = 'en_US';
                pseUser.EmailEncodingKey = 'UTF-8';
                pseUser.ProfileId = testProfile.Id;
                pseUser.LanguageLocaleKey = 'en_US';
                pseUser.OSP__c = 'No';
                pseUser.Dell_NTUserID__c = 'NTUSERID';
                pseUser.File_Source__c = 'GIS - Bulk';
                pseUser.Service_User_Type__c = 'Service Account';
                pseUser.IsActive = true;
                pseUser.ManagerId = pseManagerUser.Id;
                pseUser.Manager__c = pseManagerUser.Id;
                pseUser.EmployeeNumber = '981631';

                insert pseUser;
                ProjectUtilsDataForTest.testUser = pseUser;

                User pseOwner = createUser(pseManagerUser, 'OwnerMg');
                ProjectUtilsDataForTest.testOwner = pseOwner;

                if (ProjectUtilsDataForTest.testUserWithoutManager == null) {
                    ProjectUtilsDataForTest.testUserWithoutManager = createUser(null, 'Owner');
                }
            }
        }

        return this;
    }

    private User createUser(User pseManagerUser, String prefix) {

        User thisUser = [SELECT Id FROM User WHERE Id = :userinfo.getUserId()];
        System.runAs (thisUser) {
            User pseOwner = new User();

            pseOwner.FirstName = prefix + 'First Name';
            pseOwner.LastName = prefix + 'Second Name';
            pseOwner.External_ID__c = prefix + '6547891';
            pseOwner.FederationIdentifier = prefix + '6547891';
            pseOwner.Organization__c = 'Scott Pittman (633976)';
            pseOwner.Username = prefix + '@dell.com.salesforce';
            pseOwner.Email = prefix + '@dell.com';
            pseOwner.Alias = prefix;
            pseOwner.CommunityNickname = prefix + 'Nickname';
            pseOwner.TimeZoneSidKey = 'GMT';
            pseOwner.LocaleSidKey = 'en_US';
            pseOwner.EmailEncodingKey = 'UTF-8';
            pseOwner.ProfileId = testProfile.Id;
            pseOwner.LanguageLocaleKey = 'en_US';
            pseOwner.OSP__c = 'No';
            pseOwner.Dell_NTUserID__c = 'OWNERNET';
            pseOwner.File_Source__c = 'GIS - Bulk';
            pseOwner.Service_User_Type__c = 'Service Account';
            pseOwner.IsActive = true;
            pseOwner.EmployeeNumber='981271';
            

            if (pseManagerUser != null) {
                pseOwner.ManagerId = pseManagerUser.Id;
                pseOwner.Manager__c = pseManagerUser.Id;
            }

            insert pseOwner;

            pseOwner = [
                    SELECT Id, FirstName,
                            LastName,
                            External_ID__c,
                            FederationIdentifier,
                            Organization__c,
                            Username,
                            Email,
                            Alias,
                            CommunityNickname,
                            TimeZoneSidKey,
                            LocaleSidKey,
                            EmailEncodingKey,
                            ProfileId,
                            LanguageLocaleKey,
                            OSP__c,
                            Dell_NTUserID__c,
                            File_Source__c,
                            Service_User_Type__c,
                            IsActive,
                            ManagerId,
                            Manager__c,
                            Manager__r.External_ID__c
                    FROM User
                    WHERE Id = :pseOwner.Id
                    LIMIT 1
            ];

            return pseOwner;
        }

        return null;
    }

    public ProjectUtilsDataForTest createRecordType() {
        if (testRecordType == null) {
            this.testRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Small Project Tier' LIMIT 1];
        }

        return this;
    }

    public ProjectUtilsDataForTest createRegion() {
        User thisUser = [SELECT Id FROM User WHERE Id = :userinfo.getUserId()];
        System.runAs (thisUser) {
            if (ProjectUtilsDataForTest.testRegion == null) {
                pse__Region__c pseRegion = new pse__Region__c();
                pseRegion.ISO_Country_Code__c = 'US';
                pseRegion.Name = 'US';
                insert pseRegion;

                ProjectUtilsDataForTest.testRegion = pseRegion;
            }
        }
        return this;
    }

    public ProjectUtilsDataForTest createPractice() {

        User thisUser = [SELECT Id FROM User WHERE Id = :userinfo.getUserId()];
        System.runAs (thisUser) {

            if (ProjectUtilsDataForTest.testPractice == null) {
                TriggerHandler.bypass(FFProjectTriggerHandler.class.getName());
                pse__Proj__c projectTemplate = new pse__Proj__c(
                        Name='Phased Project Template - Custom - Global',
                        pse__Is_Template__c = true,
                        pse__Is_Active__c = true,
                        pse__Start_Date__c = Date.today(),
                        Po_Number__c = '54764648',
                        Deal__c = '54764648',
                        DP__c = '54764648'
                );
                insert projectTemplate;
                TriggerHandler.clearByPass(FFProjectTriggerHandler.class.getName());

                List<pse__Practice__c> practices = new List<pse__Practice__c>();

                pse__Practice__c psePracticeIDS = new pse__Practice__c();
                psePracticeIDS.Name = 'Infrastructure Delivery Service';
                psePracticeIDS.Standard_Project_Template__c = projectTemplate.Id;
                psePracticeIDS.Financial_Alias__c = 'EDT';
                practices.add(psePracticeIDS);

                ProjectUtilsDataForTest.testPracticeIDS  = psePracticeIDS;

                pse__Practice__c psePracticeEIS = new pse__Practice__c();
                psePracticeEIS.Name = 'EIS';
                psePracticeEIS.Standard_Project_Template__c = projectTemplate.Id;
                psePracticeEIS.Financial_Alias__c = 'EIS';
                practices.add(psePracticeEIS);

                ProjectUtilsDataForTest.testPracticeEIS  = psePracticeEIS;

                pse__Practice__c psePractice = new pse__Practice__c();
                psePractice.Name = 'Test Practice';
                psePractice.Standard_Project_Template__c = projectTemplate.Id;
                psePractice.Financial_Alias__c = 'XYZ';
                practices.add(psePractice);

                ProjectUtilsDataForTest.testPractice = psePractice;

                pse__Practice__c psePractice2 = new pse__Practice__c();
                psePractice2.Name = 'Test Practice 2';
                psePractice2.Standard_Project_Template__c = projectTemplate.Id;
                psePractice2.Financial_Alias__c = 'ABC';
                practices.add(psePractice2);

                ProjectUtilsDataForTest.testPractice2 = psePractice2;

                insert practices;
            }
        }
        return this;
    }

    public ProjectUtilsDataForTest createProfile() {
        if (testProfile == null) {
            this.testProfile = [SELECT Id, Name FROM Profile WHERE Name = 'PSA Project Manager' LIMIT 1];
        }

        return this;
    }

    public ProjectUtilsDataForTest createExpenseReport() {
        createAssignment();
        createUser();
        createProject();
        createPermissionControl();

        if (testExpenseReport == null) {
            testExpenseReport = new pse__Expense_Report__c(
                    Name = 'Expense Report Test',
                    CurrencyIsoCode = 'USD',
                    pse__Approved__c = false,
                    pse__Billable__c = true,
                    pse__Include_In_Financials__c = false,
                    pse__Action_Check_Include_In_Financials__c = false,
                    pse__Reimbursement_Currency__c = 'USD',
                    pse__Status__c = 'Draft',
                    pse__Submitted__c = false,
                    pse__Approver__c = testUser.Id,
                    pse__Assignment__c = testAssignment.Id,
                    pse__Project__c = testProject.Id,
                    pse__Project__r = testProject,
                    pse__Resource__c = testAssignment.pse__Resource__c
            );

            insert testExpenseReport;

        }
        return this;
    }
    public ProjectUtilsDataForTest createBudget() {
        if (testBudget == null) {
            pse__Budget__c budget = new pse__Budget__c (
                    Amount_USD__c = 5100,
                    pse__Project__c = testProject.Id
            );
            insert budget;

            testBudget = budget;
        }

        return this;
    }
    public ProjectUtilsDataForTest CreateProjectComplexities() {
        if (TestProjectComplexities == null) {

            TestProjectComplexities = new List<Project_Complexity_Threshold__c>();

            TestProjectComplexities.add(new Project_Complexity_Threshold__c (
                    Name = 'US',
                    Low_Threshold__c = 1000,
                    High_Threshold__c = 2000
            )
            );

            insert(TestProjectComplexities);
        }

        return this;
    }
    public ProjectUtilsDataForTest setupSkills() {
        if (skills == null) {
            pse__Skill__c lowSkill = new pse__Skill__c(Name = 'Project Management (Low)',pse__External_Id__c='9321');
            pse__Skill__c mediumSkill = new pse__Skill__c(Name = 'Project Management (Medium)',pse__External_Id__c='9322');
            pse__Skill__c highSkill = new pse__Skill__c(Name = 'Project Management (High)',pse__External_Id__c='9323');
            skills = new List<pse__Skill__c>();
            skills.add(lowSkill);
            skills.add(mediumSkill);
            skills.add(highSkill);

            insert skills;
        }
        return this;
    }
    public ProjectUtilsDataForTest setupProjectComplexityMappings() {
        if (projComplexityMappings == null) {
            projComplexityMappings = new List<Project_Complexity_Mapping__c>();

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

            insert(projComplexityMappings);
        }
        return this;
    }

    public ProjectUtilsDataForTest createExpense() {
        createAssignment();
        createUser();
        createProject();
        createExpenseReport();

        if (testExpense == null) {
            testExpense = new pse__Expense__c(
                    pse__Expense_Report__c = testExpenseReport.Id,
                    pse__Resource__c = testContact.Id,
                    pse__Assignment__c = testAssignment.Id,
                    pse__Project__c = testProject.Id,
                    pse__Amount__c = 100,
                    pse__Billable__c = true,
                    pse__Submitted__c = true,
                    pse__Approved__c = true
            );

            insert testExpense;
        }
        return this;
    }


    public ProjectUtilsDataForTest createTimecard() {
        createProject();
        createContact();
        createAssignment();

        if (testTimecard == null) {
            testTimecard = new pse__Timecard_Header__c(
                    pse__Project__c = testProject.Id,
                    pse__Status__c = 'Approved',
                    pse__Resource__c = testContact.Id,
                    pse__Approved__c = true,
                    pse__Submitted__c = true,
                    pse__Start_Date__c = START_DATE.date(),
                    pse__End_Date__c = START_DATE.addDays(6).date(),
                    pse__Assignment__c = testAssignment.Id
            );

            insert testTimecard;
        }

        return this;
    }

    public ProjectUtilsDataForTest createQueue() {

        if (testQueue == null) {
            testQueue = new Group();

            testQueue.Name = 'Group Name';
            testQueue.Type = 'Queue';
            testQueue.DeveloperName = 'QueueTestFF';


            insert testQueue;

            QueueSobject mappingObject = new QueueSobject(QueueId = testQueue.Id, SobjectType = 'pse__Proj__c');
            system.runAs(new User(Id = UserInfo.getUserId())) {
                insert mappingObject;
            }

            System.debug('Group Id' + testQueue.Id);

        }

        return this;
    }

    public ProjectUtilsDataForTest createTaskTime() {
        createProjectTask();
        createTimecard();

        if (testTaskTime == null) {
            testTaskTime = new pse__Task_Time__c(
                    pse__Project_Task__c = testProjectTask.Id,
                    pse__Timecard__c = testTimecard.Id,
                    pse__Start_Date__c = START_DATE.date(),
                    pse__Sunday_Hours__c = 1.49,
                    pse__Monday_Hours__c = 2.05,
                    pse__Tuesday_Hours__c = 3.01,
                    pse__Wednesday_Hours__c = 4,
                    pse__Thursday_Hours__c = 5.1,
                    pse__Friday_Hours__c = 6.89,
                    pse__Saturday_Hours__c = 8
            );

            insert testTaskTime;
        }

        return this;
    }

    public ProjectUtilsDataForTest createProjectInInitiate() {
        createProjectTask();
        setupProjectComplexityMappings();
        setupSkills();
        CreateProjectComplexities();
        createBudget(); //Required to change Project Phase

        testProject.pse__Project_Phase__c = 'Initiate';
        testProject.Setup_Project__c = true;
       // update testProject;

        return this;
    }

    public ProjectUtilsDataForTest createFfOrderMonitoring() {
        FF_Order_monitoring__c ffOrder = new FF_Order_monitoring__c(
                Order_Number__c = '33445566778',
                Business_Unit__c = '22'
        );

        insert ffOrder;

        FF_Order_monitoring__c ffOrder2 = new FF_Order_monitoring__c(
                Order_Number__c = '33445566778',
                Business_Unit__c = '21'
        );

        insert ffOrder2;

        return this;
    }
 }