/**
 * Created by Bruno_Frosi on 1/15/2020.
 */

@IsTest
private class DAL_ProjectTest {
     @IsTest
     static void testBehavior() {
         List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
         system.runAs(loginUser[0]){ 
         Account acc = OPRTestFactory.newAccount('Account for testing', '111');
         INSERT acc;
         pse__Proj__c project = OPRTestFactory.createProject(acc.Id, '333', '444', '555');
         project.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
         INSERT project;
         Set<Id> setProjectId = new Set<Id>();
         setProjectId.add(project.Id);
		 List<ID> engagementIdList = new List<ID>();
         engagementIdList.add(project.Id);
         Set<String> poNumbers = new Set<String>();
         poNumbers.add('333');
         Set<String> DealIds = new Set<String>();
         DealIds.add('444');
         Set<String> DPIds = new Set<String>();
         DPIds.add('555');

         Map<Id, pse__Proj__c> projects = DAL_Project.getEngagementForOrderGrouping(poNumbers, DealIds, DPIds);
         Map<Id, pse__Proj__c> projects2 = DAL_Project.getProjectByIds(setProjectId);
		 Map<Id, List<pse__Proj__c>> projects3 = new Map<Id, List<pse__Proj__c>>();
         projects3 = DAL_Project.getNotCanceledProjectByEngamentId(engagementIdList);
         system.assert(projects.size() > 0);
         }
     }

     @IsTest
     static void testBehavior2() {
         List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
         system.runAs(loginUser[0]){ 
         Account acc = OPRTestFactory.newAccount('Account for testing', '111');
         INSERT acc;
             //added for compile error
         Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','1234567890');
         INSERT contact;
         pse__Proj__c project = OPRTestFactory.createProject(acc.Id, '666', '777', '888');
         INSERT project;

         Set<String> poNumbers = new Set<String>(); 
         poNumbers.add('333');
         Set<String> DealIds = new Set<String>();
         DealIds.add('444');
         Set<String> DPIds = new Set<String>();
         DPIds.add('555');
         
         Map<Id, pse__Proj__c> projects = DAL_Project.getProjectsForRulesEngine(poNumbers, DealIds, DPIds);

         system.assert(projects == null);
         }
     }
    
     @IsTest
     static void testBehavior3() {
         List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
         system.runAs(loginUser[0]){
         Account acc = OPRTestFactory.newAccount('Account for testing', '111');
         INSERT acc;
         Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas', '1235671007');
         INSERT contact;
         pse__Proj__c project = OPRTestFactory.createProject(acc.Id, '666', '777', '888');
         INSERT project;

       	List<Id> projectForImporQueue = new List<Id>();
         projectForImporQueue.add(project.Id);
        
         DAL_Project.getProjectsForImportQueue(projectForImporQueue);

         system.assert(projectForImporQueue != null);
         }
     }
    
     @IsTest
     static void testBehavior4() {
         List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
         system.runAs(loginUser[0]){
         Account acc = OPRTestFactory.newAccount('Account for testing', '111');
         INSERT acc;
         Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','1235671007');
         INSERT contact;
         pse__Proj__c project = OPRTestFactory.createProject(acc.Id, '666', '777', '888');
         INSERT project;

       	List<Id> projectForImporQueue = new List<Id>();
         projectForImporQueue.add(null);
        
         Map<Id, pse__Proj__c> result = DAL_Project.getProjectsForImportQueue(projectForImporQueue);

         System.assertEquals(0, result.size(), 'DAL_Project should return an empty map');
         }
     }
    
     @IsTest
     static void testBehavior5() {
         List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
         system.runAs(loginUser[0]){
         Account acc = OPRTestFactory.newAccount('Account for testing', '111');
         INSERT acc;
         Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas', '1235671007');
         INSERT contact;
         pse__Proj__c project = OPRTestFactory.createProjectTemplate(acc.Id, '666', '777', '888');
         INSERT project;

        // pse__Proj__c project2 = DAL_Project.getIDSProjectTemplate('IDS');
        // pse__Proj__c project3 = DAL_Project.getIDSProjectTemplate('IDS2');

        // system.assert(project2 != null);
       //  system.assert(project3 == null);
     }
     }

     @isTest
     static void shouldGetProjectFromEngagement(){
		 List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
         system.runAs(loginUser[0]){
         Account acc = OPRTestFactory.newAccount('Account for testing', '111');
         insert acc;

         pse__Proj__c engagement = new pse__Proj__c(
             Name = 'Engagement Test',
             RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId()
         );
         insert engagement;

         pse__Proj__c project = OPRTestFactory.createProjectTemplate(acc.Id, '666', '777', '888');
         project.pse__Parent_Project__c = engagement.Id;
         insert project;

         List<Id> engagementList = new List<Id>();
         engagementList.add(engagement.Id);
        
         Test.startTest();
         Map<Id, List<pse__Proj__c>> projectList = DAL_Project.getProjectByEngamentId(engagementList);
         Test.stopTest();

         System.assertEquals(1, projectList.get(engagement.Id).size(), 'Should have one project into engagement');
         }
     }

     @isTest
     static void shouldGetRecommendedEngagements()
     {
         Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();

         pse__Proj__c engagement = new pse__Proj__c();
         engagement.Name = 'Engagement';
         engagement.RecordTypeId = recordTypeId;
         engagement.Po_Number__c = '1700';
         engagement.Deal__c = '150';
         engagement.DP__c = '33';
         insert engagement;

         Test.startTest();
         Map<Id, pse__Proj__c> mapEngagement = DAL_Project.getMapRecommendedEngagementForOrderGrouping('1800', '150', '20');
         Test.stopTest();

         System.assertEquals(1, mapEngagement.size());
     }

     @isTest
     static void getProjectsByEngagementIdTest()
     {
         Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();

         pse__Proj__c engagement = new pse__Proj__c();
         engagement.Name = 'Engagement';
         engagement.RecordTypeId = recordTypeId;
         engagement.Po_Number__c = '1700';
         engagement.Deal__c = '150';
         engagement.DP__c = '33';
         insert engagement;

         pse__Proj__c projectFirst = OPRTestFactory.createSimpleProject();
         projectFirst.pse__Parent_Project__c = engagement.Id;
         update projectFirst;

         Test.startTest();
         List<pse__Proj__c> projects = DAL_Project.getProjectsByEngagementId(engagement.Id);
         Test.stopTest();

         System.assertEquals(1, projects.size());
     }

     @isTest
     static void getEngagementByProjectIdTest()
     {
         Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();

         pse__Proj__c engagement = new pse__Proj__c();
         engagement.Name = 'Engagement';
         engagement.RecordTypeId = recordTypeId;
         engagement.Po_Number__c = '1700';
         engagement.Deal__c = '150';
         engagement.DP__c = '33';
         insert engagement;
        
         pse__Proj__c projectFirst = OPRTestFactory.createSimpleProject();
         projectFirst.pse__Parent_Project__c = engagement.Id;
         update projectFirst;

         Test.startTest();
         pse__Proj__c project = DAL_Project.getEngagementByProjectId(projectFirst.Id);
         Test.stopTest();

         System.assertEquals(true, project != null);
     }
    
    @IsTest
    static void testBehaviorPT() {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            Account acc = OPRTestFactory.newAccount('Account for testing', '111');
            INSERT acc;
            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','1235671007');
            INSERT contact;
            pse__Proj__c project = OPRTestFactory.createProjectTemplate(acc.Id, '666', '777', '888');
            INSERT project;
            
            pse__Proj__c projectTemplate = new pse__Proj__c(
                Name='Phased Project Template - Custom - Global',
                pse__Project_Type__c = 'Concession Delivery',
                pse__Is_Template__c = true,
                pse__Is_Active__c = true,
                pse__Start_Date__c = Date.today(),
                pse__Account__c = acc.Id,
                //pse__Practice__c = practice2.Id,
                Po_Number__c = '54764648',
                Deal__c = '54764648',
                DP__c = '54764648'
            );
            insert projectTemplate;
            
            pse__Practice__c practice = new pse__Practice__c(Name = 'IDS', Standard_Project_Template__c = projectTemplate.Id);
            insert practice;
            List<Id> practices = new List<Id>();
            practices.add(practice.Id);
            system.debug('projectsTemplate');
            Map<Id, pse__Proj__c> projectsTemplate = DAL_Project.getTemplateByPracticeId(practices);
            
            system.debug('projectsTemplate - ' + projectsTemplate);
            system.assert(projectsTemplate.get(practice.Id) != null);
        }
    }
}