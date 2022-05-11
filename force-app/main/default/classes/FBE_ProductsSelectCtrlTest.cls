/**************
*@ Class Name        : FBE_ProductSelectCtrlTest
*@ Description       : Test Class for adding products in Deal Registration
*@ CreatedBy         : Deloitte Consulting
*@ CreatedOn         : 04-03-2019
*@ Modification Log  : Version 1.0 - [Prishika Kataria] : Created Test Script for Adding Products
*@ Modification Log  : Version 1.1 - [Ankita Shingvi] : Removed seeAllData flag
***************/

@isTest
private class FBE_ProductsSelectCtrlTest {
	static testMethod void FBE_ProductsSelectCtrlTest(){         
        //List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
       User lUser =  FBE_UtilityFactory_Test.getIntegrationUser();
        system.runAs(lUser){ 
			//Create Product
			List <Product2> lProd = FBE_UtilityFactory_Test.createProducts(3);
			lProd[0].Name = 'DCS 7150';
			lProd[1].Name = 'B1165NFW';
			lProd[2].Name = 'pqr';
			insert lProd;
			system.assertNotEquals(null, lProd[0].id,'Product insertion check');
			//Instantiate the Pricebook2 record with StandardPricebookId
			Pricebook2 standardPricebook = new Pricebook2(
				Id = Test.getStandardPricebookId(),
				IsActive = true
			);
			//Execute an update DML on the Pricebook2 record, to make IsStandard to true
			update standardPricebook;
            Test.startTest();
            //Query for the Pricebook2 record, to check IsStandard field
			standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
			//It should return true
			System.assertEquals(true, standardPricebook.IsStandard,'Standard Price book');
            //Insert Deal record
            
			FBE_Test_Utility.createTransferDealCheckCustomSetting(false);
			List < Deal_Registration__c > DealList = FBE_UtilityFactory_Test.createDeal(1);
            insert DealList;
            system.assertNotEquals(null, DealList[0].id,'Deal insertion check'); 
            DealList[0].FBE_Price_Book_Id__c = standardPricebook.Id;
            update DealList;
			
            List <String> prodList = new List <String>();
            prodList.add(lProd[0].id);
            //Create Deal Products
            List <Deal_Product__c> lDealProduct = FBE_UtilityFactory_Test.createDealProducts(1, DealList[0].id, lProd[0].id);
            //Update revenue for this deal product
            lDealProduct[0].FBE_Quantity__c = 2;
            lDealProduct[0].FBE_Sales_price__c = 2000;
            insert lDealProduct; 
            system.assertNotEquals(null, lDealProduct[0].id,'Product insertion check');
            
            DealList[0].FBE_Deal_Registration_Status__c = 'Submitted';
            update DealList;
            
            List<FBEProductSelectCtrl.ProductListWrapper> lstMain = new List<FBEProductSelectCtrl.ProductListWrapper>();
            List<FBEProductSelectCtrl.ProductListWrapper> lstSearch = new List<FBEProductSelectCtrl.ProductListWrapper>();
            Boolean check;
            lstMain = FBEProductSelectCtrl.fetchProductWrapper(DealList[0].id);
            system.assertNotEquals(null, lstMain,'Product List check');
            lstSearch = FBEProductSelectCtrl.fetchLookUpValues('DCS','',DealList[0].id);
            system.assertNotEquals(null, lstSearch,'Search results check');
            FBEProductSelectCtrl.UpdateDealProduct(DealList[0].id,prodList);
            Test.stopTest();
        }
        
    }
    
	static testMethod void FBE_ProductsSelectCtrlErrorTest(){         
		List<User> lUser = FBE_UtilityFactory_Test.createUser('FBE Deal Reg Approval Team', 3, 'ab',null);
		system.runAs(lUser[0]){         
			//Create Product
			List <Product2> lProd = FBE_UtilityFactory_Test.createProducts(3);
			lProd[0].Name = 'DCS 7150';
			lProd[1].Name = 'B1165NFW';
			lProd[2].Name = 'pqr';
			insert lProd;
			system.assertNotEquals(null, lProd[0].id,'Product insertion check');
			//Instantiate the Pricebook2 record with StandardPricebookId
			Pricebook2 standardPricebook = new Pricebook2(
				Id = Test.getStandardPricebookId(),
				IsActive = true
			);
			//Execute an update DML on the Pricebook2 record, to make IsStandard to true
			update standardPricebook;
			Test.startTest();	
			//Query for the Pricebook2 record, to check IsStandard field
			standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
			//It should return true
			System.assertEquals(true, standardPricebook.IsStandard,'Standard Price book');
            
			FBE_Test_Utility.createTransferDealCheckCustomSetting(false);
			//Insert Deal record
			List < Deal_Registration__c > DealList = FBE_UtilityFactory_Test.createDeal(1);
			insert DealList;
			system.assertNotEquals(null, DealList[0].id,'Deal insertion check');  
			DealList[0].FBE_Price_Book_Id__c = standardPricebook.Id;
			update DealList;
			
			List <String> prodList = new List <String>();
			prodList.add(lProd[0].id);
			//Create Deal Products
			List <Deal_Product__c> lDealProduct = FBE_UtilityFactory_Test.createDealProducts(1, DealList[0].id, lProd[0].id);
			//Update revenue for this deal product
			lDealProduct[0].FBE_Quantity__c = 2;
			lDealProduct[0].FBE_Sales_price__c = 2000;
			insert lDealProduct; 
			system.assertNotEquals(null, lDealProduct[0].id,'List insertion check');
			
			DealList[0].FBE_Deal_Registration_Status__c = 'Expired';
			update DealList;
			
			List<FBEProductSelectCtrl.ProductListWrapper> lstMain = new List<FBEProductSelectCtrl.ProductListWrapper>();
			List<FBEProductSelectCtrl.ProductListWrapper> lstSearch = new List<FBEProductSelectCtrl.ProductListWrapper>();
			Boolean check;
			lstMain = FBEProductSelectCtrl.fetchProductWrapper(DealList[0].id);
			system.assertNotEquals(null, lstMain,'List insertion check');
			lstSearch = FBEProductSelectCtrl.fetchLookUpValues('DCS','',DealList[0].id);
			system.assertNotEquals(null, lstSearch,'Search results check');
			
			try{
				FBEProductSelectCtrl.UpdateDealProduct(DealList[0].id,prodList);    
            }catch(Exception e){
                system.debug('Exception--'+e.getMessage());
            }
			try{
				FBEProductSelectCtrl.UpdateDealProduct('',prodList);    
            }catch(Exception e){
                system.debug('Exception--'+e.getMessage());
            }
			Test.stopTest();
		}        
	}	
}