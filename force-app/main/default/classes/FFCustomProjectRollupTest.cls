@IsTest
public class FFCustomProjectRollupTest {

	@IsTest
	static void shouldFlagHasActiveCustomProject(){

		Id parent_Project = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
		Id tier_1 = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Tier_1').getRecordTypeId();

		pse__Proj__c engagement = new pse__Proj__c(Name = 'Engagement Test', RecordTypeId = parent_Project);
		insert engagement;
		List<pse__Proj__c> projectList = new List<pse__Proj__c>();
		pse__Proj__c project = new pse__Proj__c();
		project.pse__Parent_Project__c = engagement.Id;
		project.pse__Stage__c = 'Draft';
		project.Deal_Type__c = 'Custom';
		project.RecordTypeId = tier_1;	
        projectList.add(project);
        pse__Proj__c project1 = new pse__Proj__c();
		project1.pse__Parent_Project__c = engagement.Id;
		project1.pse__Stage__c = 'Draft';
		project1.Deal_Type__c = 'Custom';
		project1.RecordTypeId = tier_1;
		projectList.add(project1);
		Test.startTest();
		insert projectList;
		Test.stopTest();

		engagement = [SELECT Id, HasActiveCustomProject__c FROM pse__Proj__c WHERE Name = 'Engagement Test'];

		System.assertEquals(true, engagement.HasActiveCustomProject__c, 'Engagements with Active Custom Projects as it\'s children must have the flag HasActiveCustomProject__c checked');

	}
	@IsTest
	static void shouldUncheckHasActiveCustomProject(){

		Id parent_Project = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
		Id tier_1 = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Tier_1').getRecordTypeId();

		pse__Proj__c engagement = new pse__Proj__c(Name = 'Engagement Test', RecordTypeId = parent_Project);
		insert engagement;

		pse__Proj__c project = new pse__Proj__c();
		project.pse__Parent_Project__c = engagement.Id;
		project.pse__Stage__c = 'Cancelled';
		project.Deal_Type__c = 'Custom';
		project.RecordTypeId = tier_1;

		insert project;

		project.pse__Stage__c = 'Cancelled';

		Test.startTest();
		FFCustomProjectRollup.customRollupExecuted = false;
		update project;
		Test.stopTest();

		engagement = [SELECT Id, HasActiveCustomProject__c FROM pse__Proj__c WHERE Name = 'Engagement Test'];

		System.assertEquals(false, engagement.HasActiveCustomProject__c, 'When a custom project become inactive, it\'s HasActiveCustomProject__c flag must be unchecked');
        
	}

}