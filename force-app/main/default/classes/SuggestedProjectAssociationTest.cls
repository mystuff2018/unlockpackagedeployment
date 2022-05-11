@IsTest
public class SuggestedProjectAssociationTest {
	
    @testSetup 
    static void testSetup(){      
    	pse__Proj__c proj = new pse__Proj__c();
        proj.Name = '0Test Project';
        proj.pse__Is_Active__c = true;
        proj.Project_Visibility__c = 'All'; 
        proj.pse__Stage__c = 'On Hold';
		insert(proj);
        
        pse__Proj__c proj1 = new pse__Proj__c();
        proj1.Name = '1Test Project';
        proj1.pse__Is_Active__c = true;
        proj1.Project_Visibility__c = 'All';
        proj1.pse__Stage__c = 'In Progress';
		insert(proj1);
        
        pse__Proj__c proj2 = new pse__Proj__c();
        proj2.Name = '2Test Project';
        proj2.pse__Is_Active__c = true;
        proj2.Project_Visibility__c = 'All';
        proj2.pse__Stage__c = 'In Progress';
		insert(proj2);
    }
    
    @IsTest static void stageTest(){
    	Test.startTest();
        
       	SuggestedProjectAssociation  suggestedProjectAssociation = new SuggestedProjectAssociation();
        suggestedProjectAssociation.project = [select pse__Stage__c from pse__Proj__C WHERE Name ='0Test Project'];
        Map<string, integer> stageorder = suggestedProjectAssociation.stageOrder;
		String stage = suggestedProjectAssociation.stage;
        
        Test.stopTest();
        
        system.assertEquals(false, stageorder.isEmpty());
        System.assertEquals('OnHold', stage);
    }
    
    @isTest
	static void stageTestEquals() {
		Test.startTest();
       	SuggestedProjectAssociation  suggestedProjectAssociation1 = new SuggestedProjectAssociation();
       	suggestedProjectAssociation1.project = [select pse__Stage__c from pse__Proj__C WHERE Name = '0Test Project'];
        
       	SuggestedProjectAssociation  suggestedProjectAssociation2 = new SuggestedProjectAssociation();
       	suggestedProjectAssociation2.project = [select pse__Stage__c from pse__Proj__C WHERE Name = '0Test Project'];
        
       	Integer result = suggestedProjectAssociation1.compareTo(suggestedProjectAssociation2);
       	Test.stopTest();
        System.assertEquals(0, result);
    }
    
    @isTest
    static void stageTestBigger() {
		Test.startTest();
       
       	SuggestedProjectAssociation  suggestedProjectAssociationB1 = new SuggestedProjectAssociation();
       	suggestedProjectAssociationB1.project = [select pse__Stage__c from pse__Proj__C WHERE Name = '2Test Project'];
        
		SuggestedProjectAssociation  suggestedProjectAssociationB2 = new SuggestedProjectAssociation();
        suggestedProjectAssociationB2.project = [select pse__Stage__c from pse__Proj__C WHERE Name = '0Test Project'];
        
        Integer result = suggestedProjectAssociationB1.compareTo(suggestedProjectAssociationB2);
		
        Test.stopTest();
        
        System.assertEquals(1, result);
    }
    
	@isTest
    static void stageTestSmaller() {
    	Test.startTest();
       	SuggestedProjectAssociation  suggestedProjectAssociationS1 = new SuggestedProjectAssociation();
        suggestedProjectAssociationS1.project = [select id,pse__Stage__c from pse__Proj__C WHERE Name = '0Test Project'];
        
        SuggestedProjectAssociation  suggestedProjectAssociationS2 = new SuggestedProjectAssociation();
        suggestedProjectAssociationS2.project = [select id,pse__Stage__c from pse__Proj__C WHERE Name = '2Test Project'];
        
        Integer result = suggestedProjectAssociationS1.compareTo(suggestedProjectAssociationS2);
        
        Test.stopTest();
        
        System.assertEquals(-1, result);
    }  
    
	@IsTest static void matchReasonTest(){
		Test.startTest();
       	SuggestedProjectAssociation  suggestedProjectAssociation = new SuggestedProjectAssociation();
        suggestedProjectAssociation.project = [select pse__Stage__c from pse__Proj__C WHERE Name ='0Test Project'];
        suggestedProjectAssociation.addReason('Test Reason 1');
		suggestedProjectAssociation.addReason('Test Reason 2');
         
        String reason = suggestedProjectAssociation.matchReason;
        
        Test.stopTest();
         
		System.assertEquals('Test Reason 1, Test Reason 2', reason);
	}

    
   }