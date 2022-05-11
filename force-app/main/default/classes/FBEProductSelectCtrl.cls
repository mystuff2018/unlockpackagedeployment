/*
*@ Class Name                                                    : FBEProductSelectCtrl 
*@ Description                                                   : Created for selecting and adding products on Deal Resgitrations
*@ CreatedBy                                                     : Deloitte Consulting
*@ CreatedOn                                                     : 08-01-2019[Prishika Kataria]
*@ Modification Log                                              : 03-08-2019 [YM] Fixed all methods as per new logic for product search & save.                    
*/
public without sharing class FBEProductSelectCtrl{
          
       @AuraEnabled
        public static List<ProductListWrapper> fetchLookUpValues(String searchKeyWord, String ObjectName, Id dealRegId) {
            //System.debug('Deal Reg Id: ' +dealRegId);
            List<ProductListWrapper> lstProductListWrapper = new List<ProductListWrapper>();
            Id dealRegRowId = dealRegId;
            String searchKey = '%' + searchKeyWord + '%';
            List < product2 > returnList = new List < product2 > ();
            List<string> lstExcludeitems = new List<string>();
            set<id> priceBookSet = new set<id>();
            set<id> productIdSet = new set<Id>();
            List<Deal_Registration__c> priceBookIdList = [Select FBE_Price_Book_Id__c FROM Deal_Registration__c WHERE Id =: dealRegRowId]; //deal reg query 
            //System.debug('PriceBook Id : '+ priceBookIdList);
          /*  for(product2 item : ExcludeitemsList ){
                lstExcludeitems.add(item.id);
            }*/
            
            for(Deal_Registration__c dealRegPriceBookId: priceBookIdList){
                priceBookSet.add(dealRegPriceBookId.FBE_Price_Book_Id__c);
            }
            //System.debug('productIdSet : '+ productIdSet);
            
            List<PricebookEntry> productIdList = [SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id =:priceBookSet AND IsActive = true];
            //System.debug('productIdList : '+ productIdList);
            for(PriceBookEntry prodID : productIdList){
                productIdSet.add(prodID.Product2Id);
            }

        String sQuery =  'select Id,Name,FBE_LOB__c,FBE_Product_Type__c,FBE_Business_Unit__c from product2 where (Name LIKE: searchKey OR FBE_LOB__c LIKE: searchKey OR FBE_Product_Type__c LIKE: searchKey OR FBE_Business_Unit__c LIKE: searchKey OR ProductCode LIKE: searchKey) AND Id IN : productIdSet AND IsActive = true order by createdDate DESC limit 50';
        List < product2 > lstOfRecords = Database.query(sQuery);
        
        for (product2 obj: lstOfRecords) {
             lstProductListWrapper.add(new ProductListWrapper(false,obj,''));
        }
        return lstProductListWrapper;
        }
     
    @AuraEnabled(cacheable = true) 
    public static List<ProductListWrapper> fetchProductWrapper(Id dealRegId){ 
        //System.debug('Deal Reg Id: ' +dealRegId);
        List<ProductListWrapper> lstProductListWrapper = new List<ProductListWrapper>();
        List<Product2> productList = new list<Product2>();
        Id dealRegRowId = dealRegId;
       // Id dealRegRowId = 'a00r0000005hMwvAAE';
        String priceBookName;
        System.debug('Deal Reg Id: ' +dealRegRowId);
        List<Deal_Registration__c> priceBookIdList = [Select Id,FBE_Price_Book_Id__c FROM Deal_Registration__c WHERE Id =: dealRegRowId]; //deal reg query 
        System.debug('PriceBook Id : '+ priceBookIdList[0]);
        //query price book entry to get product id
        set<id> priceBookSet = new set<id>();
        set<id> productIdSet = new set<Id>();
        
        for(Deal_Registration__c dealRegPriceBookId: priceBookIdList){
            priceBookSet.add(dealRegPriceBookId.FBE_Price_Book_Id__c);
            System.debug('PriceBook Id Set1 : '+ dealRegPriceBookId.FBE_Price_Book_Id__c);
        }
        
        for(Pricebook2 priceBook : [SELECT Name FROM PriceBook2 WHERE Id=:priceBookSet]){
            priceBookName = priceBook.Name;
        }
        System.debug('PriceBook Id Set : '+ priceBookSet);
        
        List<PricebookEntry> productIdList = [SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id =:priceBookSet AND IsActive = true];
        //System.debug('productIdList : '+ productIdList);
        for(PriceBookEntry prodID : productIdList){
            productIdSet.add(prodID.Product2Id);
        }
        
        
         //System.debug('productIdSet : '+ productIdSet);
        //query on product

        productList = [SELECT Id,Name,FBE_LOB__c,FBE_Product_Type__c,FBE_Business_Unit__c From Product2 WHERE Id =: productIdSet AND IsActive = true];
        System.debug('products : '+ productList);
        for(Product2 Prod : productList){                            
                               lstProductListWrapper.add(new ProductListWrapper(false,Prod,priceBookName));
                           } 
        
        return lstProductListWrapper; 
    }
    
    /* wrapper class */  
    public class ProductListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public  Product2 ObjProduct2{get;set;}
        @AuraEnabled public String priceBookName{get;set;}
        public ProductListWrapper(boolean isChecked, Product2 ObjProduct2, String priceBookName){
            this.isChecked = isChecked;
            this.ObjProduct2 = ObjProduct2;
            this.priceBookName = priceBookName;
        }
    }
    
     @AuraEnabled 
    
     public static void UpdateDealProduct(String DealRegId, List<String> ProductId) {
       
         try{
             List<Deal_Product__c> DealProductList = new List<Deal_Product__c> ();
                 
            system.debug('Dealid'+ DealRegId);
            for(string ProdId : ProductId){
            Deal_Product__c DealProd = new Deal_Product__c();
            DealProd.FBE_Product__c = ProdId;
            DealProd.Deal_Registration_Name__c =  DealRegId;
            DealProductList.add(DealProd);
            system.debug('Dealid'+ DealRegId);
             system.debug('Prodinfor'+ ProdId);
        }
        //DealProductList = [SELECT Id, Name, FBE_Quantity__c, FBE_Product__r.Name,FBE_Sales_price__c, FBE_Line_Description__c, FBE_Margin_Per__c, FBE_Service_Date__c FROM Deal_Product__c ];            
         // set  Deal_Registration_Name__c =: ParentDealRegId on insert record
         system.debug('Deal'+ DealProductList);
         insert  DealProductList;
         }
         
         catch(DmlException e){
             //Capture Validation Error Messages
             String msg = '';
             for (Integer i = 0; i < e.getNumDml(); i++) {
                 msg =+ e.getDmlMessage(i) +  '\n' ;
             }
             throw new AuraHandledException(msg);
             
         }
         catch(Exception e){
             throw new AuraHandledException(e.getMessage());
         }
    }

 
}