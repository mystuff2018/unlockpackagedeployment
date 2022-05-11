@isTest
public class FBE_Manager_Tree_Test {
    static TestMethod void FBEManagerTreeTest() {
        //List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List < User > lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('Federal Core Sales Group', 4, 'ab',null);
    List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(3,null);
     lAcc[0].FBE_Partner_Type__c = 'System Integrator';
     lAcc[1].FBE_Partner_Type__c = 'Reseller';
     lAcc[2].FBE_Partner_Type__c = 'Distributor';
    
        system.runAs(lUsr) {
            //Create an Account
            
            insert lAcc;
            lUsrNonIntegration[1].managerId = lUsrNonIntegration[0].id;
            Update lUsrNonIntegration[1];
            system.assertNotEquals(null, lAcc[0].id);

            list < AccountTeamMember > accTeamMemberList = new list < AccountTeamMember > ();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel = 'Edit', UserId = lUsrNonIntegration[0].id, TeamMemberRole = 'SR', AccountId = lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel = 'Edit', UserId = lUsrNonIntegration[1].id, TeamMemberRole = 'SR', AccountId = lAcc[1].id));
            insert accTeamMemberList;
        }
        system.runAs(lUsrNonIntegration[0]) {
            
            System.debug('inside profile user');
            //create Opportunity
         
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
              
              //Create your product
                   Product2 prod = new Product2(
                        Name = 'Product X',
                        ProductCode = 'Pro-X',
                        isActive = true
                    );
                    insert prod;
              
               //Create the PricebookEntry
                PricebookEntry pbe = new PricebookEntry(
                 Pricebook2Id = standardPricebook.Id,
                 Product2Id = prod.Id,
                 UnitPrice = 1020,
                 IsActive = true
                );
                Insert pbe;
         
            List<Opportunity> oppList =  new List<Opportunity>();
           
            Opportunity opp = new Opportunity(
                Name = 'Opportunité Test',
                AccountId = lAcc[0].Id,
                StageName = 'Plan - 1%',
                FBE_Pursuit_Type__c = 'Indirect',
                FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover',
                CloseDate = System.today(),
                FBE_FSI_Account__c = lAcc[0].Id,
                FBE_VAR_Seller__c = lAcc[1].Id,
                FBE_Distributor__c = lAcc[2].Id,
                Amount = 1000.9,   
                Pricebook2Id=  standardPricebook.id
            );
             oppList.add(opp);
            Opportunity opp2 = new Opportunity(
                Name = 'Opportunité Test2',
                AccountId = lAcc[1].Id,
                StageName = 'Plan - 1%',
                FBE_Pursuit_Type__c = 'Indirect',
                FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover',
                CloseDate = System.today(),
                FBE_FSI_Account__c = lAcc[0].Id,
                FBE_VAR_Seller__c = lAcc[1].Id,
                FBE_Distributor__c = lAcc[2].Id, 
                Amount = 1000.9,
                Pricebook2Id =  standardPricebook.id
            );
            oppList.add(opp2);
            Insert oppList;
            Test.starttest();
            FBE_Manager_Tree.getTreeGridData();
            Test.stoptest();
        }
    }
}