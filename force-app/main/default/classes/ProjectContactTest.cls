/*
      Purpose:
            Test ProjectContactTrigger and ProjectContactHandler

      Initiative: Dell Thunderbolt PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    8/30/18
*/

 @IsTest
 private class ProjectContactTest {
    @IsTest
    static void whenProjectContactIsInsertedWithCeSurveyCheckboxCheckedLookupIsSetOnProject() {
        Contact testContact = createContact('Test','Contact','test.contact@dell.com','1234567890');
        insert testContact;
        pse__Proj__c testProject = new pse__Proj__c(Name='Test Project',pse__Is_Active__c = true);
        insert testProject;
        Project_Contact__c testProjContact = new Project_Contact__c(Project__c=testProject.Id,Contact__c=testContact.Id,CE_Survey_Contact__c=true,Contact_Role__c='Distributor/ Reseller',Contact_Type__c='Customer', Language_Preference__c = 'English');
        insert testProjContact;
        testProject = [SELECT CE_Survey_Contact__c FROM pse__Proj__c WHERE Id = :testProject.Id];
        // System.assertEquals(testContact.Id,testProject.CE_Survey_Contact__c);
    }
    @IsTest
    static void whenProjectContactIsUpdatedWithCeSurveyCheckboxCheckedLookupIsSetOnProject() {
        Contact testContact = createContact('Test','Contact','test.contact@dell.com','1234567890');
        insert testContact;
        pse__Proj__c testProject = new pse__Proj__c(Name='Test Project',pse__Is_Active__c = true);
        insert testProject;
        Project_Contact__c testProjContact = new Project_Contact__c(Project__c=testProject.Id,Contact__c=testContact.Id,Contact_Role__c='Distributor/ Reseller',Contact_Type__c='Customer', Language_Preference__c = 'English');
        insert testProjContact;
        testProjContact.CE_Survey_Contact__c = true;
        update testProjContact;
        testProject = [SELECT CE_Survey_Contact__c FROM pse__Proj__c WHERE Id = :testProject.Id];
        // System.assertEquals(testContact.Id,testProject.CE_Survey_Contact__c);
    }
    @IsTest
    static void whenProjectContactIsInsertedWithPrimaryContactCheckboxCheckedLookupIsSetOnProject() {
        Contact testContact = createContact('Test','Contact','test.contact@dell.com','1234567890');
        insert testContact;
        pse__Proj__c testProject = new pse__Proj__c(Name='Test Project',pse__Is_Active__c = true);
        insert testProject;
        Project_Contact__c testProjContact = new Project_Contact__c(Project__c=testProject.Id,Contact__c=testContact.Id,Primary_Contact__c=true,CE_Survey_Contact__c=true,Contact_Role__c='Distributor/ Reseller',Contact_Type__c='Customer', Language_Preference__c = 'English');
        insert testProjContact;
        testProject = [SELECT Primary_Contact__c FROM pse__Proj__c WHERE Id = :testProject.Id];
        // System.assertEquals(testContact.Id,testProject.Primary_Contact__c);
    }
    @IsTest
    static void whenProjectContactIsInsertedWithBothCheckboxCheckedLookupsAreSetOnProject() {
        Contact testContact = createContact('Test','Contact','test.contact@dell.com','1234567890');
        insert testContact;
        pse__Proj__c testProject = new pse__Proj__c(Name='Test Project',pse__Is_Active__c = true);
        insert testProject;
        Project_Contact__c testProjContact = new Project_Contact__c(Project__c=testProject.Id,Contact__c=testContact.Id,Primary_Contact__c=true,CE_Survey_Contact__c=true,Contact_Role__c='Distributor/ Reseller',Contact_Type__c='Customer', Language_Preference__c = 'English');
        insert testProjContact;
        testProject = [SELECT Primary_Contact__c,CE_Survey_Contact__c FROM pse__Proj__c WHERE Id = :testProject.Id];
        // System.assertEquals(testContact.Id,testProject.CE_Survey_Contact__c);
        // System.assertEquals(testContact.Id,testProject.Primary_Contact__c);
    }
    @IsTest
    static void whenPrimaryContactIsUncheckedLookupIsClearedOnProject() {
        Contact testContact = createContact('Test','Contact','test.contact@dell.com','1234567890');
        insert testContact;
        pse__Proj__c testProject = new pse__Proj__c(Name='Test Project',pse__Is_Active__c = true);
        insert testProject;
        Project_Contact__c testProjContact = new Project_Contact__c(Project__c=testProject.Id,CE_Survey_Contact__c = true, Contact__c=testContact.Id,Primary_Contact__c=true,Contact_Role__c='Distributor/ Reseller',Contact_Type__c='Customer', Language_Preference__c = 'English' );
        insert testProjContact;
        testProjContact.Primary_Contact__c = false;
        update testProjContact;
        testProject = [SELECT Primary_Contact__c FROM pse__Proj__c WHERE Id = :testProject.Id];
        // System.assertEquals(null,testProject.Primary_Contact__c);
    }
    @IsTest
    static void whenPrimaryContactIsDeletedLookupIsClearedOnProject() {
        Contact testContact = createContact('Test','Contact','test.contact@dell.com','1234567890');
        insert testContact;
        pse__Proj__c testProject = new pse__Proj__c(Name='Test Project',pse__Is_Active__c = true);
        insert testProject;
        Project_Contact__c testProjContact = new Project_Contact__c(Project__c=testProject.Id,Contact__c=testContact.Id,Primary_Contact__c=true,Contact_Role__c='Distributor/ Reseller',Contact_Type__c='Customer');
        insert testProjContact;
        delete testProjContact;
        testProject = [SELECT Primary_Contact__c FROM pse__Proj__c WHERE Id = :testProject.Id];
        // System.assertEquals(null,testProject.Primary_Contact__c);
    }
    @IsTest
    static void whenSecondProjectContactIsUpdatedWithCeSurveyCheckboxCheckedLookupIsSetOnProjectAndOtherPcIsCleared() {
        List<Contact> testContacts = new List<Contact>();
        testContacts.add(createContact('Test1', 'Contact', 'test1.contact@dell.com','1234567890'));
        testContacts.add(createContact('Test2', 'Contact', 'test2.contact@dell.com','1234567890'));
         //testContacts.Phone='1234567890';
        insert testContacts;
        pse__Proj__c testProject = new pse__Proj__c(Name='Test Project',pse__Is_Active__c = true);
        insert testProject;
        List<Project_Contact__c> testPcs = new List<Project_Contact__c>();
        testPcs.add(new Project_Contact__c(Project__c=testProject.Id, Contact__c=testContacts[0].Id, CE_Survey_Contact__c=true,Contact_Role__c='Distributor/ Reseller',Contact_Type__c='Customer', Language_Preference__c = 'English'));
        testPcs.add(new Project_Contact__c(Project__c=testProject.Id, Contact__c=testContacts[1].Id, CE_Survey_Contact__c=false,Contact_Role__c='Distributor/ Reseller',Contact_Type__c='Customer', Language_Preference__c = 'English'));
        insert testPcs;
        testPcs[1].CE_Survey_Contact__c = true;
        update testPcs[1];
        testProject = [SELECT CE_Survey_Contact__c FROM pse__Proj__c WHERE Id = :testProject.Id];
        Map<Id,Project_Contact__c> testPcMap = new Map<Id,Project_Contact__c>([SELECT CE_Survey_Contact__c FROM Project_Contact__c WHERE Id in :testPcs]);
        // System.assertEquals(testContacts[1].Id,testProject.CE_Survey_Contact__c);
        // System.assertEquals(false, testPcMap.get(testPcs[0].Id).CE_Survey_Contact__c);
    }

    private static Contact createContact(String firstName, String lastName, String emailAddress, String phone) {
        return new Contact(FirstName = firstName, LastName = lastName, Email = emailAddress, Phone=phone);
    }
 }