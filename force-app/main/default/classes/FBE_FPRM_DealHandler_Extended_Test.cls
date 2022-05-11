/**************
* @ Class Name        : This is a extended class for the "FBE_FPRM_DealHandler_Test" --> FBE_FPRM_DealHandler_Extended_Test
* @ Description       : This class is created to test code coverage for - FBE_FPRM_DealHandler class.rejectionFromUI method.
*                       Created as part of DEFECT# 12036280.
* @ CreatedBy         : Allia Butool
* @ CreatedOn         : 02-14-2022
*********/

@isTest
public class FBE_FPRM_DealHandler_Extended_Test {
    @TestSetup
    static void setUpData() {
        
        Profile adminProfile = [Select Id,Name from profile where Name='System Administrator' limit 1];
        
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        //Prod Data
        List<Product2> prodList = FBE_UtilityFactory_Test.createProducts(1);
        prodList[0].Name = 'APOS';
        prodList[0].FBE_BU_Category__c = 'CSG Hardware';
        INSERT prodList;
        
        system.runAs(lUsr){
            //Account Data
            List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(2,null);
            lAcc[0].FBE_Partner_Type__c = 'Distributor';
            lAcc[0].FBE_Partner__c = true;
            lAcc[0].FBE_FPRM_Partner_Reg_Status__c = 'Registered';
            lAcc[1].FBE_Partner_Type__c = 'Disty Managed';
            lAcc[1].FBE_FPRM_Partner_Reg_Status__c = 'Qualified';
            insert lAcc;
            
            // Deal Data 
            Deal_Registration__c deal = FBE_UtilityFactory_Test.createDeal(1)[0];
            deal.FBE_Deal_Justification_Statement__c = 'test statement';
            deal.Name = 'Deal test 12345';
            deal.FBE_Account__c = lAcc[0].Id;
            deal.FBE_End_User_Account__c = lAcc[0].Id;
            deal.FBE_Distributor_Account__c = lAcc[0].Id;
            deal.FBE_Reseller_VAR_Account__c = lAcc[1].Id;
            deal.FBE_Submission_Date__c = system.now();
            deal.FBE_Book_Date__c = system.now().date();
            deal.FBE_Deal_Product_Classification__c = 'EMC Products';
            deal.FBE_AE_ManagerID__c = UserInfo.getUserId();
            deal.FBE_Deal_Registration_Status__c ='New';
            deal.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            deal.FBE_Solution_Domain__c = 'Business Solutions';
            deal.Sales_Stage__c = 'Plan - 1%';
            INSERT deal;
            
            //Deal Product Data
            List<Deal_Product__c> dealProduct = FBE_UtilityFactory_Test.createDealProducts(1, deal.id, prodList[0].id);
            dealProduct[0].FBE_Quantity__c = 2;
            dealProduct[0].FBE_Sales_price__c = 9000;
            INSERT dealProduct;
            
            deal.FBE_Deal_Registration_Status__c = 'Submitted';
            UPDATE deal;
            
        }
    }
    
    
    @isTest
    static void testDeal_FRPM_Reject_UI(){
        Test.startTest();
        Deal_Registration__c dealDetails1 = [Select Id,FBE_Deal_Registration_Status__c,FBE_Secondary_Status__c,FBE_Reseller_VAR_Account__c,FBE_Declined_Reason__c,
                                             FBE_Distributor_Account__c,FBE_Decline_Comments__c,FBE_Submission_Date__c,FBE_Formatted_Submission_Date__c,FBE_Deal_Createddate__c,
                                             Analyst_Observations__c,CreatedDate,FBE_PMO_Substatus__c from Deal_Registration__c where name = 'Deal test 12345'][0];	   
        dealDetails1.FBE_Declined_Reason__c = 'Reject - Other';
        dealDetails1.FBE_Decline_Comments__c = 'test Reject Allia';
        dealDetails1.FBE_Deal_Registration_Status__c = 'Rejected';
        UPDATE dealDetails1;
        Test.stopTest();
        
        System.assertNotEquals(null, dealDetails1, 'Deal Registration Record is not found');
        
    }
}