@isTest
public class FBE_OpportunityAuraHandler_Test {
    @isTest
    static void optyAuraHandlerTest(){
        Test.startTest();
        //List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(3,null);
        system.runAs(lUsr) {
            lAcc[0].FBE_Partner_Type__c = 'Distributor';
            lAcc[1].FBE_Partner_Type__c = 'System Integrator';
            lAcc[2].FBE_Partner_Type__c = 'Reseller';
            insert lAcc;
            
        }
        /*****    
Id pricebookId = Test.getStandardPricebookId();

//Create your product
Product2 prod = new Product2(
Name = 'Product X',
ProductCode = 'Pro-X',
isActive = true
);
insert prod;

//Create your pricebook entry
List < PriceBookEntry > pbe = [Select id from PriceBookEntry where Product2Id =: prod.id and Pricebook2Id =: pricebookId LIMIT 1];

if (pbe.size() > 0) {
pbe[0].UnitPrice = 10000000;
pbe[0].IsActive = true;
} else {
PriceBookEntry pbeTmp = new PricebookEntry(
Pricebook2Id = pricebookId,
Product2Id = prod.Id,
UnitPrice = 10000000,
isActive = true
);
pbe.add(pbeTmp);
}
upsert pbe;


****/      
        
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
        
        System.debug('inside profile user');
        //create Opportunity
        String OppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId();
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
            recordTypeId = OppRecordTypeId,
            Pricebook2Id = standardPricebook.id,
            FBE_Storage_Selling_Motion__c = 'Competitive Displacement'
            
        );
        Insert opp;
        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 5,
            FBE_Quote_Number_Line__c = '123',
            PricebookEntryId = pbe.Id,
            TotalPrice = pbe.UnitPrice
        );
        insert oli;
        
        
        List<OpportunityLineItem> optyLineItems = FBE_OpportunityAuraHandler.getOptyLineItems(opp.Id);
        System.debug('getOptyLineItems: '+optyLineItems.size());
        
        Decimal optyAmount = FBE_OpportunityAuraHandler.updateOptyLineItems(new List<OpportunityLineItem>{oli});
        System.debug('optyAmount: '+optyAmount);
        Test.stopTest();
        FBE_OpportunityAuraHandler.updateRevenueCheckBox(opp.Id, false);
        FBE_OpportunityAuraHandler.getOptyId(oli.Id); // added to increase code coverage by Siva
        FBE_OpportunityAuraHandler.deleteOptyLineItem(oli.Id);
        FBE_OpportunityAuraHandler.getRecordTypeName(opp.RecordTypeId,'Opportunity');
        
        
        
    }
    
    @isTest
    static void factoryUtilityTest(){
        List < UserRole > roles = FBE_UtilityFactory_Test.createRoles(2);
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(3,null);
        system.runAs(lUsr) {
            lAcc[0].FBE_Partner_Type__c = 'Distributor';
            lAcc[1].FBE_Partner_Type__c = 'System Integrator';
            lAcc[2].FBE_Partner_Type__c = 'Reseller';
            insert lAcc;
        }
        List < Opportunity > opList =  FBE_UtilityFactory_Test.createOptywithAccounts(1, lAcc[0].Id, lAcc[0].Id, null, null, null, null);
        List<Campaign> campList = FBE_UtilityFactory_Test.createCampaign(2);
        system.assertEquals(true, opList.size() > 0);
    }
    
}