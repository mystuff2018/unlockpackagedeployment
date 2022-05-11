/**************
 * @ Class Name        : SkillCertificationRatingTriggerTest
 * @ Description       : This class is created to test code coverage for SkillCertificationRating Trigger and handler classes.
 *                       Created as part of Feature #7946971.
 * @ CreatedBy         : Deloitte
 * @ CreatedOn         : 08-31-2020
 * @ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script
*********/
@IsTest
private class SkillCertificationRatingTriggerTest {
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
            
            //Insert a new test Skill record based on one present in system.
            List<Skill> skills = [SELECT Id, MasterLabel FROM Skill Limit 1];
            System.assertNotEquals(null, skills, 'Skill records do not exist in the system.');
            
            pse__Skill__c testSkill = new pse__Skill__c();
            testSkill.Name = skills[0].MasterLabel;//'Test Skill 1';
            testSkill.pse__External_Id__c='9321';
            insert testSkill;
            
            //Insert PSA Account and User, User Related Data
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
            
            List<ServiceResource> objResource = [SELECT Id FROM ServiceResource WHERE RelatedRecordId =: users[0].Id];
        }
    }
    
    @isTest
    static void shouldInsertServiceResourceSkill(){
        List<Contact> objContact = [SELECT Id, pse__Salesforce_User__c FROM Contact LIMIT 1];
        
        List<pse__Skill__c> skillCertification = [SELECT Id, Name from pse__Skill__c LIMIT 1];
        
        //Insert a Skill Certification Rating Record.
        List<pse__Skill_Certification_Rating__c> SCRList = new List<pse__Skill_Certification_Rating__c>();
        pse__Skill_Certification_Rating__c scrObj1 = new pse__Skill_Certification_Rating__c();
        scrObj1.pse__Skill_Certification__c = skillCertification[0].Id;
        scrObj1.pse__Resource__c = objContact[0].Id;
        scrObj1.pse__Evaluation_Date__c = Date.today();
        scrObj1.pse__Expiration_Date__c = Date.today() + 60;
        scrObj1.pse__Rating__c = '2 - Some Familiarity';
        scrObj1.External_Id__c = '133024-compt000000000014323';
        SCRList.add(scrObj1);
        
        Test.startTest();
        	insert SCRList;
        Test.stopTest();
        
        List<ServiceResource> srList = [SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1];
        List<ServiceResourceSkill> srsList = [SELECT Id, ServiceResourceId, ServiceResource.RelatedRecordId, SkillId, Skill.MasterLabel
                                              FROM ServiceResourceSkill LIMIT 1];
        
        System.assertEquals(objContact[0].pse__Salesforce_User__c, srList[0].RelatedRecordId, 'Service Resource User does not match with Contact.');
        System.assertEquals(skillCertification[0].Name, srsList[0].Skill.MasterLabel, 'Service Resource Skill is incorrect.');
    }
    
    @isTest
    static void shouldUpdateServiceResourceSkill(){
        List<Contact> objContact = [SELECT Id, pse__Salesforce_User__c FROM Contact LIMIT 1];
        
        List<pse__Skill__c> skillCertification = [SELECT Id, Name from pse__Skill__c LIMIT 1];
        
        //Insert a Skill Certification Rating Record.
        List<pse__Skill_Certification_Rating__c> SCRList = new List<pse__Skill_Certification_Rating__c>();
        pse__Skill_Certification_Rating__c scrObj1 = new pse__Skill_Certification_Rating__c();
        scrObj1.pse__Skill_Certification__c = skillCertification[0].Id;
        scrObj1.pse__Resource__c = objContact[0].Id;
        scrObj1.pse__Evaluation_Date__c = Date.today();
        scrObj1.pse__Expiration_Date__c = Date.today() + 60;
        scrObj1.pse__Rating__c = '2 - Some Familiarity';
        scrObj1.External_Id__c = '133024-compt000000000014323';
        SCRList.add(scrObj1);
        
        insert SCRList;
        
        //Test Update
        SCRList[0].pse__Rating__c = '3 - Comfortable';
        
        Test.startTest();
        update SCRList;
        Test.stopTest();
        
        List<ServiceResource> srList = [SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1];
        List<ServiceResourceSkill> srsList = [SELECT Id, ServiceResourceId, ServiceResource.RelatedRecordId, SkillId, Skill.MasterLabel, SkillLevel
                                              FROM ServiceResourceSkill LIMIT 1];
        System.assertEquals(3, srsList[0].SkillLevel, 'Service Resource Skill Update Failed');
    }
    @isTest
    static void shouldDeleteServiceResourceSkill(){
        List<Contact> objContact = [SELECT Id, pse__Salesforce_User__c FROM Contact LIMIT 1];
        
        List<pse__Skill__c> skillCertification = [SELECT Id, Name from pse__Skill__c LIMIT 1];
        
        //Insert a Skill Certification Rating Record.
        List<pse__Skill_Certification_Rating__c> SCRList = new List<pse__Skill_Certification_Rating__c>();
        pse__Skill_Certification_Rating__c scrObj1 = new pse__Skill_Certification_Rating__c();
        scrObj1.pse__Skill_Certification__c = skillCertification[0].Id;
        scrObj1.pse__Resource__c = objContact[0].Id;
        scrObj1.pse__Evaluation_Date__c = Date.today();
        scrObj1.pse__Expiration_Date__c = Date.today() + 60;
        scrObj1.pse__Rating__c = '2 - Some Familiarity';
        scrObj1.External_Id__c = '133024-compt000000000014323';
        SCRList.add(scrObj1);
        
        insert SCRList;
        
        
        Test.startTest();
        Delete SCRList;
        Test.stopTest();
        
        List<ServiceResource> srList = [SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1];
        List<ServiceResourceSkill> srsList = [SELECT Id, ServiceResourceId, ServiceResource.RelatedRecordId, SkillId, Skill.MasterLabel, SkillLevel
                                              FROM ServiceResourceSkill LIMIT 1];
        //System.assertEquals(3, srsList[0].SkillLevel, 'Service Resource Skill Delete Failed');
    }
}