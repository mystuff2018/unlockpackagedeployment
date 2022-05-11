@isTest
public class TestDataUtility {
    //Method to create testdata for Account
    public static List<Account> createAccounts(Integer numberOfAccounts, Boolean isInsert){
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        List<Account> testaccountList = new List<Account>();
        for (Integer i = 0; i < numberOfAccounts; i++) {
            Account testaccount = new Account(
                Name = i + ' TestAccount',
                BillingCity = 'testBillingCity',
                Phone = '9876543210',
                Website = 'xyz@dell.com'
            );
            testaccountList.add(testaccount);
        }
        if(isInsert){
            system.runAs(loginUser[0])
    {
            insert testaccountList;
    }
        }
        
        return testaccountList;
    }
    
    //Method to create testdata for Contact
    public static List<Contact> createContacts(Integer numberOfContacts, Id accountId, Boolean isInsert, Boolean isResource) {
        List<Contact> testcontactList = new List<Contact>();
        for (Integer i = 0; i < numberOfContacts; i++) {
            Contact testcontact = new Contact(
                FirstName = 'TestContactF ' + i,
                LastName = 'TestContactL ' + i,
                Email = 'none' + i + '@dell.com',
                phone = '1234567898',
                Accountid = accountId,
                pse__Is_Resource__c = isResource,
                pse__Is_Resource_Active__c = True
                //pse__Work_Calendar__c = wc.id,
                //pse__Region__c = region.id
            );
            testcontactList.add(testcontact);
        }
        if (isInsert) {
            insert testcontactList;
        }
        return testcontactList;
    }
    
    
     
    //Method to create testdata for PM Profile Contact 
    public static List<Contact> createPMContact(Integer numberOfContacts, Id accountId, Boolean isInsert, Boolean isResource) {
        List<Contact> testPMcontactList = new List<Contact>();
        for (Integer i = 0; i < numberOfContacts; i++) {
            Contact testPMcontact = new Contact(
                FirstName = 'Proj ' + i,
                LastName = 'Manager ' + i,
                Email = 'testmail@email.com',
                Accountid = accountId,
                pse__Is_Resource__c = isResource,
                Primary_Phone__c = '9999999999',
                Phone = '1111111111',
                pse__Is_Resource_Active__c = True
               
            );
            testPMcontactList.add(testPMcontact);
        }
        if (isInsert) {
            insert testPMcontactList;
        }
        return testPMcontactList;
    }

    //Method to create testdata for Domain_Settings__c
  /*  public static List<Domain_Settings__c> createDomainSettings(Integer numberOfDomains, Boolean customTrigger, Boolean isInsert) {
        List<Domain_Settings__c> testDomainSettingList = new List<Domain_Settings__c>();
        for (Integer i = 0; i < numberOfDomains; i++) {
            Domain_Settings__c testDomainSetting = new Domain_Settings__c(
                Custom_Triggers__c = customTrigger
            );
            testDomainSettingList.add(testDomainSetting);
        }
        if (isInsert) {
            insert testDomainSettingList;
        }
        return testDomainSettingList;
    }
    */
    //Create Resorce Request Skill
    public static pse__Resource_Skill_Request__c getResourceRequestSkill(Boolean isInserted,id skillId ,id resourceId){
        pse__Resource_Skill_Request__c r = new pse__Resource_Skill_Request__c();
        r.pse__Skill_Certification__c = skillId;
        r.pse__Resource_Request__c = resourceId;
        r.pse__Minimum_Rating__c = '5';
        if(isInserted){
            if(Schema.sObjectType.pse__Resource_Skill_Request__c.fields.pse__Skill_Certification__c.isCreateable() &&
			Schema.sObjectType.pse__Resource_Skill_Request__c.fields.pse__Resource_Request__c.isCreateable()&&
			Schema.sObjectType.pse__Resource_Skill_Request__c.fields.pse__Minimum_Rating__c.isCreateable()){ //Added these checks as a part of checkmarx
            insert r;
			}	
        }
        return r;
    }
    
    //Create Certification
    public static pse__Skill__c getCertification(Boolean isInserted){
        pse__Skill__c r = new pse__Skill__c();
        r.Name = '12345';
        r.pse__External_Id__c = 'abcdef1qw3';
        if(isInserted){
            if(Schema.sObjectType.pse__Skill__c.fields.Name.isCreateable() &&
			Schema.sObjectType.pse__Skill__c.fields.pse__External_Id__c.isCreateable()){ //Added these checks as a part of checkmarx
            insert r; 
			}
        }
        return r;
    }
    
    public static List<pse__Skill__c> getSkills(Integer numberOfskills, Boolean isInserted){
        List<pse__Skill__c> testSkillsList = new List<pse__Skill__c>();
        for (Integer i = 0; i < numberOfskills; i++) {
            pse__Skill__c testskill = new pse__Skill__c();
            testskill.Name = '12345'+i;
            testskill.pse__External_Id__c = 'abcdef1qw3'+i;
            
            testSkillsList.add(testskill);
        }
        if(isInserted){
            if(testSkillsList.size()>0){ //Added size check as a part of checkmarx
            insert testSkillsList; 
			}
        }
        return testSkillsList;
    }
    
    
   
    //Method to create test user
    public static User getUser(String username){
        Profile p = [SELECT Id FROM Profile WHERE Name='system administrator']; 
        User u = new User(Alias = 'tests', Email='standardusertest@dell.com', 
                          EmailEncodingKey='UTF-8', LastName='TestUser1', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', IsActive = True, UserName=username , CommunityNickname  = 'testUsert' ,
                          OSP__c = 'No' , FederationIdentifier= '195', Organization__c = 'testOrgs', Dell_NTUserID__c = '1234', 
                          File_Source__c = 'WorkDay', Service_User_Type__c='Admin',	EmployeeNumber='123684');
        insert u;
        return u;
        
    }
    
    //Method to create Permission Control
    public static pse__Permission_Control__c getPermissionControl(id u,Id rId,Boolean isInserted){
        pse__Permission_Control__c pc = new pse__Permission_Control__c();
        pc.pse__User__c = u;
        pc.pse__Region__c = rId;
        if(isInserted){
            if(Schema.sObjectType.pse__Permission_Control__c.fields.pse__User__c.isCreateable() &&
			Schema.sObjectType.pse__Permission_Control__c.fields.pse__Region__c.isCreateable()){ //Added these checks as a part of checkmarx
            insert pc; 
			}
        }
        return pc;
    }
    
    //Method to create Region 
    public static pse__Region__c getRegion(Boolean isInserted){
        pse__Region__c region = new pse__Region__c();
        region.Name = 'Test';
        if(isInserted){
           if(Schema.sObjectType.pse__Region__c.fields.Name.isCreateable()){ //Added these checks as a part of checkmarx
            insert region;   
        } 
        }
        return region;
    }
    
    // Method to create practice
    public static pse__Practice__c getPractice(Boolean isInserted){
        pse__Proj__c projectTemplate = createProject(true);
        pse__Practice__c practice = new pse__Practice__c();
        practice.Name = 'Test';
        practice.Standard_Project_Template__c = projectTemplate.Id;
        if(isInserted){
           if(Schema.sObjectType.pse__Practice__c.fields.Name.isCreateable()){ //Added these checks as a part of checkmarx
            insert practice; 
        }
        }
        return practice;
    }
    

    //create work calender
    public static pse__Work_Calendar__c createWorkCalender(Boolean isInserted){
        pse__Work_Calendar__c p = new pse__Work_Calendar__c();  
        p.Name = 'tets';
        if(isInserted){
           if(Schema.sObjectType.pse__Work_Calendar__c.fields.Name.isCreateable()){  //Added these checks as a part of checkmarx
            insert p;         
        }          
        }
        return p;
    }
    //create Holiday
    public static void createHoliday (Id wc,Boolean isInserted){
        pse__HolidayObj__c holiday = new pse__HolidayObj__c();
        holiday.Name = 'Test';
        holiday.pse__Work_Calendar__c = wc;
        holiday.pse__Date__c = Date.today() + 7;
        if(isInserted){
           if(Schema.sObjectType.pse__HolidayObj__c.fields.Name.isCreateable() && 
			Schema.sObjectType.pse__HolidayObj__c.fields.pse__Work_Calendar__c.isCreateable() &&
			Schema.sObjectType.pse__HolidayObj__c.fields.pse__Date__c.isCreateable()){  //Added these checks as a part of checkmarx
            insert holiday; 
			}
        }
    }
    
    //Create project  Record
    public static pse__Proj__c createProject(Boolean isInserted){
        pse__Proj__c project = new pse__Proj__c();
        project.Name = 'Test';
        project.pse__Is_Template__c = true;
        if(isInserted){
            if(Schema.sObjectType.pse__Proj__c.fields.Name.isCreateable() && 
			Schema.sObjectType.pse__Proj__c.fields.pse__Is_Template__c.isCreateable()){ //Added these checks as a part of checkmarx
            insert project;  
        }        
        }
        return project;
    }
        public static pse__Skill_Certification_Rating__c getCertification(Id skillId, Id ResourceId, String exeID, Boolean isInserted){   
        pse__Skill_Certification_Rating__c skillRating = new pse__Skill_Certification_Rating__c();
        skillRating.pse__Skill_Certification__c = skillId;
        skillRating.pse__Resource__c = ResourceId;
        skillRating.External_Id__c = exeID;
        if(isInserted){
            if(Schema.sObjectType.pse__Skill_Certification_Rating__c.fields.pse__Skill_Certification__c.isCreateable() && 
			Schema.sObjectType.pse__Skill_Certification_Rating__c.fields.pse__Resource__c.isCreateable() &&
			Schema.sObjectType.pse__Skill_Certification_Rating__c.fields.External_Id__c.isCreateable()){ //Added these checks as a part of checkmarx
            insert skillRating;  
        }
        }
        return skillRating;
    }
    //Create Resource Request 
    public static pse__Resource_Request__c getResourceRequest(Boolean isInserted){
        pse__Resource_Request__c r = new pse__Resource_Request__c();
        r.pse__Start_Date__c = Date.today();
        r.pse__End_Date__c = Date.today()+30;
        r.pse__Resource_Role__c = 'Trainer';
        r.pse__SOW_Hours__c = 10;
        
        
        if(isInserted){
           if(Schema.sObjectType.pse__Resource_Request__c.fields.pse__Start_Date__c.isCreateable() &&
			Schema.sObjectType.pse__Resource_Request__c.fields.pse__End_Date__c.isCreateable() &&
			Schema.sObjectType.pse__Resource_Request__c.fields.pse__Resource_Role__c.isCreateable() &&
			Schema.sObjectType.pse__Resource_Request__c.fields.pse__SOW_Hours__c.isCreateable()){  //Added these checks as a part of checkmarx
            insert r;  
        }
        }
        return r;
        
    }
    public static List<pse__Risk__c> createRiskObj(Integer numberOfRisk, Boolean isInsert){
        List<pse__Risk__c> testdataList = new List<pse__Risk__c>();
        for (Integer i = 0; i < numberOfRisk; i++) {
            pse__Risk__c testRisk = new pse__Risk__c(
                pse__Risk_Name__c = i + ' TestRisk'
            );
            testdataList.add(testRisk);
        }
        if(isInsert){
           if(testdataList.size()>0){  //Added size check as a part of checkMarx
            insert testdataList; 
        }
        }
        return testdataList;
    }

    //Create Assignment Record
    public static pse__Assignment__c getAssignment(id projId,id resourceId,integer billRate,Boolean isInserted){
        pse__Assignment__c assign = new pse__Assignment__c();
        assign.Name = 'Test';
        assign.pse__Project__c = projId;
        assign.pse__Resource__c = resourceId;
        assign.pse__Bill_Rate__c = billRate;
        if(isInserted){
            if(Schema.sObjectType.pse__Assignment__c.fields.Name.isCreateable() &&
			Schema.sObjectType.pse__Assignment__c.fields.pse__Project__c.isCreateable() &&
			Schema.sObjectType.pse__Assignment__c.fields.pse__Resource__c.isCreateable() &&
			Schema.sObjectType.pse__Assignment__c.fields.pse__Bill_Rate__c.isCreateable()){ //Added these checks as a part of checkmarx
            insert assign;  
        }
        }
        return assign;
    }

    //Method to Create Project 
    public static pse__Proj__c createProject(Id accId ,Id regionId,Boolean isInserted){
        pse__Proj__c proj = new pse__Proj__c();
        proj.Name = 'Test';
        proj.pse__Account__c = accId;
        proj.pse__Region__c = regionId;
        
        if(isInserted){
            if(Schema.sObjectType.pse__Proj__c.fields.Name.isCreateable() &&
			Schema.sObjectType.pse__Proj__c.fields.pse__Account__c.isCreateable() &&
			Schema.sObjectType.pse__Proj__c.fields.pse__Region__c.isCreateable()){ //Added these checks as a part of checkmarx
            insert proj;  
        }
        }
        
        return proj;
    }
    
     //Method to Create Rate Card 
    public static pse__Rate_Card__c createRateCard(Id regionId,Boolean isInserted){
        pse__Rate_Card__c rateCard = new pse__Rate_Card__c();
        rateCard.pse__Region__c = regionId;
        rateCard.pse__Suggested_Bill_Rate__c = 100;
        rateCard.pse__Average_Cost_Rate__c = 100;
        rateCard.pse__Role__c = 'Project Manager Analyst';
        if(isInserted){
           if(Schema.sObjectType.pse__Rate_Card__c.fields.pse__Region__c.isCreateable() &&
			Schema.sObjectType.pse__Rate_Card__c.fields.pse__Suggested_Bill_Rate__c.isCreateable() &&
			Schema.sObjectType.pse__Rate_Card__c.fields.pse__Average_Cost_Rate__c.isCreateable() &&
			Schema.sObjectType.pse__Rate_Card__c.fields.pse__Role__c.isCreateable()){ //Added these checks as a part of checkmarx
            insert rateCard;    
        }
        }
        
        return rateCard;
    }
    //Method to Create Rate Card 
    public static pse__Rate_Card__c createRateCard(Id regionId,Boolean isInserted,String Role){
        pse__Rate_Card__c rateCard = new pse__Rate_Card__c();
        rateCard.pse__Region__c = regionId;
        rateCard.pse__Suggested_Bill_Rate__c = 100;
        rateCard.pse__Average_Cost_Rate__c = 100;
        rateCard.pse__Role__c = Role;
        if(isInserted){
           if(Schema.sObjectType.pse__Rate_Card__c.fields.pse__Region__c.isCreateable() && 
			Schema.sObjectType.pse__Rate_Card__c.fields.pse__Suggested_Bill_Rate__c.isCreateable() && 
			Schema.sObjectType.pse__Rate_Card__c.fields.pse__Average_Cost_Rate__c.isCreateable() && 
			Schema.sObjectType.pse__Rate_Card__c.fields.pse__Role__c.isCreateable()){ //Added these checks as a part of checkmarx
            insert rateCard; 
        }
        }
        
        return rateCard;
    }
    
    //Method to Create Project Task 
    public static pse__Project_Task__c getProjectTask(Boolean isInserted, Id projId){
        pse__Project_Task__c projectTask = new pse__Project_Task__c();
        projectTask.Name = 'TestProjectTask';
        projectTask.pse__Project__c = projId;
        
        if(isInserted){
           if(Schema.sObjectType.pse__Project_Task__c.fields.Name.isCreateable() && 
			Schema.sObjectType.pse__Project_Task__c.fields.pse__Project__c.isCreateable()){ //Added these checks as a part of checkmarx
            insert projectTask; 
        }
        }
        
        return projectTask;
    }
    //Create Project task Assignment
    public static pse__Project_Task_Assignment__c getProjectTaskAssignment(Boolean isInserted , Id projTaskId){
        pse__Project_Task_Assignment__c psa = new pse__Project_Task_Assignment__c();
        psa.pse__Project_Task__c = projTaskId;
        if(isInserted){
            if(Schema.sObjectType.pse__Project_Task_Assignment__c.fields.pse__Project_Task__c.isCreateable()){ //Added these checks as a part of checkmarx
            insert psa; 
        }
        }
        return psa;
        
    }
    //Create Request
    public static Request__c getRequest(Id projId , Boolean isInserted){
        Request__c req = new Request__c();
        req.Project__c = projId;
        if(isInserted){
           if(Schema.sObjectType.Request__c.fields.Project__c.isCreateable()){  //Added these checks as a part of checkmarx
            insert req; 
        }
        }
        return req;
    }
    //create PO Expense Line
    public static PO_Expense_Line__c getPoExpenseLine(Boolean isInserted,Id reqId){
        PO_Expense_Line__c po = new PO_Expense_Line__c();
        po.Purchase_Order__c = reqId;
        if(isInserted){
            if(Schema.sObjectType.PO_Expense_Line__c.fields.Purchase_Order__c.isCreateable()){  //Added these checks as a part of checkmarx
            insert po;  
        }
        }
        return po;
    }
    //create Budget
    public static pse__Budget__c getBudget(Boolean isInserted , Id projId){
        pse__Budget__c budget = new pse__Budget__c();
        budget.Name = 'test';
        budget.pse__Amount__c = 100;
        budget.pse__project__c = projId;
        if(isInserted){
           if(Schema.sObjectType.pse__Budget__c.fields.Name.isCreateable() &&
			Schema.sObjectType.pse__Budget__c.fields.pse__Amount__c.isCreateable() &&
			Schema.sObjectType.pse__Budget__c.fields.pse__project__c.isCreateable()){ //Added these checks as a part of checkmarx
            insert budget; 
        }
        }
        return budget;
    }
    
   //ExpenseReport
   
    public static pse__Expense_Report__c getexpenseReport(Boolean isInserted , Id projId, Id conId, Id asmId){
        pse__Expense_Report__c expenseReport = new pse__Expense_Report__c();
        expenseReport.Name = 'test';
        expenseReport.pse__project__c = projId;
        expenseReport.pse__Resource__c = conId;
        expenseReport.pse__Assignment__c = asmId;
        if(isInserted){
            if(Schema.sObjectType.pse__Expense_Report__c.fields.Name.isCreateable() &&
			Schema.sObjectType.pse__Expense_Report__c.fields.pse__project__c.isCreateable() &&
			Schema.sObjectType.pse__Expense_Report__c.fields.pse__Resource__c.isCreateable() &&
			Schema.sObjectType.pse__Expense_Report__c.fields.pse__Assignment__c.isCreateable()){  //Added these checks as a part of checkmarx
            insert expenseReport; 
        }
        }
        return expenseReport;
    } 
    // Create PO_Labor_Line__c 
    public static PO_Labor_Line__c getPoLabourLine(Boolean isInserted , id requestID){
        PO_Labor_Line__c po = new PO_Labor_Line__c();
        po.Purchase_Order__c = requestID;
        if(isInserted){
           if(Schema.sObjectType.PO_Labor_Line__c.fields.Purchase_Order__c.isCreateable()){  //Added these checks as a part of checkmarx
            insert po;  
        }
        }
        return po;
    }
    
    //Create Billing Event
    public static pse__Billing_Event__c CreateBillingEvent(Boolean isInserted , Id projId){
        pse__Billing_Event__c Event = new pse__Billing_Event__c();
        Event.pse__project__c = projId;
        if(isInserted){
            if(Schema.sObjectType.pse__Billing_Event__c.fields.pse__project__c.isCreateable()){  //Added these checks as a part of checkmarx
            insert Event ; 
        }
        }
        return Event;
    }
    //Method to create test user2
    public static User getUser2(String username){
        Profile p = [SELECT Id FROM Profile WHERE Name='Service Integration Profile']; 
        User u = new User(Alias = 'standt', Email='standarduser@dell.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, EmployeeNumber = '847365',
                          TimeZoneSidKey='America/Los_Angeles',IsActive = True, UserName=username , CommunityNickname  = 'testUser' ,
                          OSP__c = 'No' , FederationIdentifier= '123', Organization__c = 'testOrg', Dell_NTUserID__c = '1234', 
                          File_Source__c = 'WorkDay', Service_User_Type__c='Admin');
        insert u;
        return u;
        
    }
    
   
    
}