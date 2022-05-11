/**************
*@ Class Name                                                    : FBE_SObjectAllFieldClonerTest
*@ Description                                                   : This is written as a test class for FBE_SObjectAllFieldCloner class.
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 02-Mar-2020 [Abhijeet Kharatmol]
*@ Modification Log                                              : 15-March-2020
***************/ 
@isTest
public class FBE_SObjectAllFieldClonerTest {
  @isTest
  static void TestUse1()
    {
        //Product2 prod = new Product2(Name = 'APOS', ProductCode = 'Pro-X', isActive = true );
          //INSERT prod;
            Test.startTest();
            try{
         
                //List <User> lUsr = [Select Id, ManagerID from User where FBE_Integration_User__c = true limit 1];// Used existing Integration user because No user has the access to create acount including System Admin also
                User  lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
                List<User> lUserTeam = FBE_UtilityFactory_Test.createUser('System Administrator', 1, 'ab',null);
                /*
                lUsr.ManagerId = Userinfo.getUserId();
                lUsr.EmployeeNumber = '123';
                UPDATE lUsr;
				*/
            
              /* Id pricebookId = Test.getStandardPricebookId();
               system.debug('#########'+pricebookId);
            
               List <PriceBookEntry> pbe = [Select id from PriceBookEntry where Product2Id =: prod.id and Pricebook2Id =: pricebookId LIMIT 1];
               if (pbe.size() > 0) 
               {	
                    pbe[0].UnitPrice = 99;
                    pbe[0].IsActive = true;
                } 
              else{
                   PriceBookEntry pbeTmp = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 500, isActive = true);
                   pbe.add(pbeTmp);
                 }
                UPSERT pbe;*/
               Product2 pro = new Product2(Name = 'iPhone X', Family = 'Mobile');
                Insert pro;
                 
                //Instantiate the Pricebook2 record with StandardPricebookId
                Pricebook2 standardPricebook = new Pricebook2(
                 Id = Test.getStandardPricebookId(),
                 IsActive = true
                );
                 
                //Execute an update DML on the Pricebook2 record, to make IsStandard to true
                Update standardPricebook;
                 
                //Query for the Pricebook2 record, to check IsStandard field
                standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
                //It should return true
                System.assertEquals(true, standardPricebook.IsStandard);
 
 
                //Create the PricebookEntry
                PricebookEntry pbe = new PricebookEntry(
                 Pricebook2Id = standardPricebook.Id,
                 Product2Id = pro.Id,
                 UnitPrice = 1020,
                 IsActive = true
                );
                Insert pbe;
                
                
               List <Account> lAcc = FBE_UtilityFactory_Test.createAccount(1,null);
               System.runAs(lUsr)
               {
                   lAcc[0].FBE_AE_ISR__c = lUsr.Id;
                   INSERT lAcc;
                   System.debug('inside profile user');
                   Opportunity opp = new Opportunity(
                        Name = 'Opportunit Test',
                        AccountId = lAcc[0].Id,
                        RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId(),
                        StageName = 'Plan - 1%',
                        Ownerid = lUserTeam[0].id,
                        FBE_New_Only__c = true,
                        FBE_Siebel_Campaign_Not_Found_Flag__c = true,
                        FBE_MIT_Assessment_Completed__c = true,
                        FBE_MIT_Proposal_Completed__c = true,
                        FBE_Strategic_Opportunity__c = true,
                        FBE_Pursuit_Type__c = 'Indirect',
                        FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover',
                        CloseDate = System.today(),
                        FBE_FSI_Account__c = lAcc[0].Id,
                        FBE_VAR_Seller__c = lAcc[0].Id,
                        Account_Oppty_Duplicate_Check__c = '',
                        FBE_Distributor__c = lAcc[0].Id,
                        Pricebook2Id = standardPricebook.Id,
                        FBE_Appointment_Set__c = true,
                        FBE_Distributor_Not_Applicable__c = true,
                        FBE_FSI_Not_Applicable__c = true,
                        FBE_Reseller_VAR_Not_Applicable__c = true,
                        FBE_Test_Drive_Attended__c = true,
                        DPS_SE_Technical_Win__c =true,
                        FBE_Manager_Endorsed__c = true,
                        FBE_Manager_Requested__c = true,
                        FBE_Rep_Completed__c = true,
                        Mainframe__c = true,
                        FBE_Indirect_Ownership__c = true,
                        FBE_Rated_Order__c = true
                     );
                   INSERT opp;
    
                //create your opportunity line item.  This assumes you already have an opportunity created, called opp
                  OpportunityLineItem oli = new OpportunityLineItem(
                        OpportunityId = opp.Id,
                        Quantity = 5,
                        UnitPrice = 726,
                        FBE_Quote_Number_Line__c = '123',
                        PricebookEntryId = pbe.Id
                     );
                     List<OpportunityLineItem> lstOli = new List<OpportunityLineItem>();
                     lstOli.add(oli);
                     INSERT lstOli;
                     String oppJSON = JSON.serializePretty(opp);
                     
                     try{
                        FBE_OpportunityEditForm_Ctrl.getForm(opp.Id,'Opportunity','FBE_Clone_Opportunity_Field_Set');
                     }Catch(Exception e)
                     {
                         System.debug(e);
                     }
                     FBE_OpportunityEditForm_Ctrl.submitUIValues(oppJSON,opp.Id,lstOli); 
                  }
            }Catch(DMLException e)
            {
                System.debug(e);
               //system.assertNotEquals(e.getMessage(), e.getMessage());  
               //system.assert(false, 'Exceptions should be handled by the method');
            }
            Test.stopTest();
        
    }
    public class MyException extends Exception{}
    /*@isTest
    public static void testScenario1()
    {
        Test.startTest();
        List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        List<User> lUserTeam = FBE_Test_Utility.createUser('System Administrator', 1, 'ab');
        update lUserTeam;
        system.runAs(lUser[0]){
        Id pricebookId = Test.getStandardPricebookId();
            system.debug('abhi:pricebookId='+pricebookId);
        List<Account> acc = FBE_Test_Utility.createAccount(1);
        insert acc;
        List<opportunity> opp = FBE_Test_Utility.createOpportunity(1,acc[0].id);
    
        opp[0].ownerid = lUserTeam[0].id;
        opp[0].Pricebook2Id = pricebookId;
        insert opp;
        String oppJSON = JSON.serializePretty(opp[0]);
	

            //Create your product
            Product2 prod = new Product2(
                Name = 'Product X',
                ProductCode = 'Pro-X',
                isActive = true
            );
            insert prod;

            //Create your pricebook entry
            List < PriceBookEntry > pbe = [Select id, UnitPrice, Pricebook2Id from PriceBookEntry 
                                           where Product2Id =: prod.id and Pricebook2Id =: pricebookId LIMIT 1];
            system.debug('abhi:pbe='+pbe);
    		 if (pbe.size() > 0) {
        	pbe[0].UnitPrice = 99;
            pbe[0].IsActive = true;
              }
        OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = opp[0].Id,
                Quantity = 5,
                FBE_Quote_Number_Line__c = '123',
                PricebookEntryId = pbe[0].Id,
                TotalPrice = pbe[0].UnitPrice
            );
            insert oli;
        List<OpportunityLineItem> lstOli = new List<OpportunityLineItem>();
        lstOli.add(oli);
        FBE_OpportunityEditForm_Ctrl.submitUIValues(oppJSON,opp[0].Id,lstOli);
        }
        Test.stopTest();
    }*/
}