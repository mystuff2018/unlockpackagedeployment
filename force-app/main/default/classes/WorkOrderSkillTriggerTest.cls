/**
 * Created by tdavis on 2019-01-28.
 * Modification Log: [Abhishek Kawle - Deloitte] : 08/27/2020 - Updated script to test WorkOrderSkillHandler.syncSkillRequirements
 *            Feature #7946971
 */

 @IsTest
 private class WorkOrderSkillTriggerTest
 {
    
	/*@TestSetup
    static void setup()
    {
        //Login with Integration User Profile to create Account
         List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
         system.runAs(loginUser[0]){
			pse__Skill__c testSkill = new pse__Skill__c(Name = 'Test Skill 1',pse__External_Id__c='9321');
			insert testSkill;

			Account account = new Account();
			account.Name = 'AccountName';
			account.Site_Access_Required__c = 'Yes';
			insert account;

			WorkOrder  testWorkOrder= new WorkOrder(Partner_Name__c = 'Vendor FF',
					Account = account,
					AccountId = account.Id
			);
			insert testWorkOrder;

			Work_Order_Skill__c testWorkOrderSkill = new Work_Order_Skill__c(Skill_Certification__c = testSkill.Id, Work_Order__c = testWorkOrder.Id);
			insert testWorkOrderSkill;
		 }	
    } */
	 @TestSetup
     static void setup()
     {
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
             
             Account account = new Account();
             account.Name = 'AccountName';
             account.Site_Access_Required__c = 'Yes';
             insert account;
             
             WorkOrder  testWorkOrder= new WorkOrder(Partner_Name__c = 'Vendor FF',
                                                     Account = account,
                                                     AccountId = account.Id
                                                    );
             insert testWorkOrder;
             
             Work_Order_Skill__c testWorkOrderSkill = new Work_Order_Skill__c(Skill_Certification__c = testSkill.Id, Work_Order__c = testWorkOrder.Id);
             insert testWorkOrderSkill;
         }
     } 

      @IsTest
     static void shouldAddSkillLongDescriptionToWorkOrderSkill(){
         //Login with Integration User Profile to create Account
         List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
         system.runAs(loginUser[0]){
             //Find a new skill to insert in Work Order Skills
             SkillRequirement skillReq2 = [SELECT Id, SkillId, FBE_IDS_Skill_Long_Description__c FROM SkillRequirement
                                          LIMIT 1];
             
             Account account = new Account();
             account.Name = 'AccountName';
             account.Site_Access_Required__c = 'Yes';
             insert account;
             
             List<Skill> skills = [SELECT Id, MasterLabel FROM Skill 
                                   WHERE Id != :skillReq2.SkillId
                                   ORDER BY CreatedDate DESC
                                   Limit 1];
             System.assertNotEquals(null, skills, 'Skill records do not exist in the system.');
             
             pse__Skill__c skillDescription = new pse__Skill__c();
             skillDescription.Name = skills[0].MasterLabel;
             skillDescription.pse__External_Id__c='955321';
             skillDescription.Long_Description__c='test desc';
             insert skillDescription;
             
             WorkOrder testWorkOrderDesc = new WorkOrder(Partner_Name__c = 'Ava',
                                                         Account = account,
                                                         AccountId = account.Id);
             insert testWorkOrderDesc;
             
             Test.startTest();
             Work_Order_Skill__c testWorkOrderSkill = new Work_Order_Skill__c(Skill_Certification__c = skillDescription.Id, Work_Order__c = testWorkOrderDesc.Id);
             insert testWorkOrderSkill;
             Test.stopTest();
             
             Work_Order_Skill__c WOSkillDescription = [SELECT Id,Skill_Long_Description__c FROM Work_Order_Skill__c WHERE  Skill_Certification__c = : skillDescription.Id];
             System.AssertEquals(WOSkillDescription.Skill_Long_Description__c,'test desc');
             
             //Assert Skill Requirement Record is created based on above Work Order Skill
             SkillRequirement skillReq = [SELECT Id, SkillId, FBE_IDS_Skill_Long_Description__c FROM SkillRequirement
                                         WHERE RelatedRecordId =:testWorkOrderDesc.Id];
             System.assertEquals(skills[0].Id, skillReq.SkillId);
             System.assertEquals(WOSkillDescription.Skill_Long_Description__c, skillReq.FBE_IDS_Skill_Long_Description__c);
         }
     } 
     
     @IsTest
     static void test()
     {
         pse__Skill__c testSkill = [ SELECT Id FROM pse__Skill__c WHERE pse__External_Id__c ='9321' LIMIT  1 ];
         WorkOrder testWorkOrder = [ SELECT Id FROM WorkOrder WHERE Partner_Name__c = 'Vendor FF' LIMIT  1 ];
         
         Test.startTest();
         try
         {
             Work_Order_Skill__c skill = new Work_Order_Skill__c(Skill_Certification__c = testSkill.Id, Work_Order__c = testWorkOrder.Id);
             insert skill;
         }
         catch (Exception e)
         {
             System.debug(e.getMessage());
             System.assert(e.getMessage().contains('You cannot add duplicate skills.'));
         }
         Test.stopTest();
         
     }
     
      @isTest
     static void testWorkOrderSkillReqUpdate(){
         WorkOrder testWorkOrder = [ SELECT Id FROM WorkOrder WHERE Partner_Name__c = 'Vendor FF' LIMIT  1 ];
         
         List<Work_Order_Skill__c> woSkillList = [SELECT Id, Skill_Long_Description__c, Minimum_Rating__c
                                                  FROM Work_Order_Skill__c
                                                  WHERE Work_Order__c = :testWorkOrder.Id];
         
         for(Work_Order_Skill__c eachWOSkill : woSkillList){
             eachWOSkill.Skill_Long_Description__c = 'Updated the description';
             eachWOSkill.Minimum_Rating__c = '3';
         }
         
         Test.startTest();
         upsert woSkillList;
         Test.stopTest();
         
         List<SkillRequirement> skillReqList = [SELECT Id, SkillLevel, FBE_IDS_Skill_Long_Description__c
                                                FROM SkillRequirement];
         
         System.assertEquals(woSkillList[0].Skill_Long_Description__c, skillReqList[0].FBE_IDS_Skill_Long_Description__c);
         System.assertEquals(Integer.valueOf(woSkillList[0].Minimum_Rating__c), skillReqList[0].SkillLevel);
     } 

 }