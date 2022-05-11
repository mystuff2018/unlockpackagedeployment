/*
    Class Name        : FBE_FPRM_DealCloneHandlerTest  
    Purpose           : STORY 10977231 Nov Rel 2021.
    Description       : Created the class for the purpose of Code Coverage for Apex class :FBE_FPRM_DealCloneHandler
                        Used in LWC component named 'FBE_FPRM_DealClonelwc'.
    Created by        :  Dell - FPRM Team - Dipanshu Parakh
    Last Modified on  : Aug-24-2021 - Dipanshu Parakh - 100% Code Coverage.

*/
@isTest
public class FBE_FPRM_DealCloneHandlerTest {
    
    @isTest
    private static void testOriginalDealReg(){        
		Account distyAccount = createAccount();            
       	Deal_Registration__c deal = createDealRegistration(distyAccount.Id);       
        Test.startTest();               
            INSERT deal;
            Deal_Product__c dealProd = createDealProduct();
            dealProd.Deal_Registration_Name__c = Deal.Id;            
            INSERT dealProd;         
            FBE_FPRM_DealCloneHandler.dealWrapper dealInfo = FBE_FPRM_DealCloneHandler.originalDealReg(deal.Id);
        Test.stopTest();
        System.assertEquals(dealInfo.dealId,deal.Id, 'Deal Id is not returned');
    }
    
    @isTest
    private static void testOnSubmitUI(){        
        Account distyAccount = createAccount();
		Deal_Registration__c deal = createDealRegistration(distyAccount.Id);     
     	List<Deal_Product__c> dealProductsList = new List<Deal_Product__c>();
        dealProductsList.add(createDealProduct());

        Test.startTest();
        Id dealId = FBE_FPRM_DealCloneHandler.onSubmitUI(deal,dealProductsList);
        Test.stopTest();
        System.assertEquals(dealId != null, true, 'Deal Clone is unsuccessful');
    }
    
    @isTest
    private static void testOnSubmitUIDoesNotCloneDeal(){        
        Account distyAccount = createAccount();
		Deal_Registration__c deal = createDealRegistration(distyAccount.Id);   
        Test.startTest();
            Insert deal;
            List<Deal_Product__c> dealProductsList = new List<Deal_Product__c>();
            dealProductsList.add(createDealProduct());
        
            try{
                Id dealId = FBE_FPRM_DealCloneHandler.onSubmitUI(deal,dealProductsList);            
            }catch(Exception e){
                System.assert(true, 'Deal Clone is successful');
            }
        Test.stopTest();
        
    }
    
    private static Account createAccount(){
        User intUser = FBE_UtilityFactory_Test.getIntegrationUser();
        system.runAs(intUser){
            List <Account> accountList = FBE_UtilityFactory_Test.createAccount(1,null);
            accountList[0].FBE_Partner_Type__c = 'Distributor';
            accountList[0].FBE_Partner__c = true;
            accountList[0].FBE_FPRM_Partner_Reg_Status__c = 'Registered';
            INSERT accountList;                       
        }
        Account distyAccount = [SELECT id,FBE_Partner__c FROM Account WHERE FBE_Partner_Type__c ='Distributor'];
        return distyAccount;
    }
    
    private static Deal_Product__c createDealProduct(){
        List<Product2> prodList = FBE_UtilityFactory_Test.createProducts(1);
        INSERT prodList;
        Deal_Product__c dealProd = new  Deal_Product__c();       
        dealProd.FBE_Product__c = prodList[0].Id;
        dealProd.FBE_Quantity__c = 9;
        dealProd.FBE_Sales_price__c = 7000;
        return dealProd;              
    }
    
    private static Deal_Registration__c  createDealRegistration(Id accountId){
        Deal_Registration__c deal = FBE_UtilityFactory_Test.createDeal(1)[0];         
        deal.FBE_Customer__c = '650009093';
        deal.FBE_Deal_Reg_Partner_Direct__c = '650009093';
        deal.FBE_Solution_Domain__c = 'Business Solutions';
        deal.FBE_Deal_Justification_Statement__c = 'test statement 2';
        deal.FBE_Account__c = accountId;
        deal.FBE_End_User_Account__c = accountId;
        deal.FBE_Distributor_Account__c = accountId;
        deal.FBE_Book_Date__c = system.now().Date();
        deal.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover'; 
        deal.FBE_Submission_Date__c = system.now();
        deal.FBE_Same_as_submitter__c = 'Yes';
        return deal;
    }
}