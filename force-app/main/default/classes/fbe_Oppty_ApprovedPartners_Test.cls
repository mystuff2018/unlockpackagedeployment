/****************************************************************************************************
* Author         : Dell Team - Oppty [Nirmal Kumar Ravi - STORY 11970896]
* Description    : Previously Approved Partners. 
* Date Created   : 10/2/2022
* Version        : 1.0
* Modification Log           Developer          Last Modified Date           Description
* 1.0                        Nirmal Kumar Ravi       
* 
****************************************************************************************************/
@isTest
public class fbe_Oppty_ApprovedPartners_Test {
    @isTest
    Public static void getApporvedPartners(){
        List<BD_Opportunity_Partner__c> approvedPartnersList = new List<BD_Opportunity_Partner__c>();
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
        
        //create Opportunity
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BD Capture Team Record Type').getRecordTypeId();
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
            Pricebook2Id = standardPricebook.id,
            RecordTypeId = devRecordTypeId
        );
        Insert opp; 
        BD_Opportunity_Partner__c opptyPartners = new BD_Opportunity_Partner__c();
        opptyPartners.Name='Test Partner'; 
        opptyPartners.TA_Discussion_Approved_Status__c='Completed';
        opptyPartners.Opportunity__c=opp.id;
        approvedPartnersList.add(opptyPartners);
        insert approvedPartnersList;
        Test.startTest();
        FBE_Oppty_ApprovedPartnersListController.getApprovedPartnersList(approvedPartnersList[0].Id);
        System.assertEquals(1,approvedPartnersList.size());
        Test.stopTest();
    }   
}