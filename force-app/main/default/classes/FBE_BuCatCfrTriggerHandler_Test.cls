@isTest
public class FBE_BuCatCfrTriggerHandler_Test {
    @isTest
    public static void BuCtgryClsfrtst(){
        //List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(3,null);
        system.runAs(lUsr) {
            lAcc[0].FBE_Partner_Type__c = 'Distributor';
            lAcc[1].FBE_Partner_Type__c = 'System Integrator';
            lAcc[2].FBE_Partner_Type__c = 'Reseller';
            insert lAcc;
            
        }  
  
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
                       FBE_BU_Category__c = 'test123',
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
        
        System.debug('inside profile user');
        //create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Opportunité Test',
            AccountId = lAcc[0].Id,
            StageName = 'Plan - 1%',
            FBE_Pursuit_Type__c = 'Indirect',
            FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover',
            CloseDate = System.today(),
            FBE_FSI_Account__c = lAcc[1].Id,
            FBE_VAR_Seller__c = lAcc[2].Id,
            FBE_Distributor__c = lAcc[0].Id,
            Pricebook2Id = standardPricebook.id
        );
        Insert opp;
        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 5,
            FBE_Quote_Number_Line__c = '123',
            //FBE_BU_Category__c = pbe.prod.FBE_BU_Category__c,
            PricebookEntryId = pbe.Id,
            TotalPrice = pbe.UnitPrice
        );
        insert oli;
    }
    
}