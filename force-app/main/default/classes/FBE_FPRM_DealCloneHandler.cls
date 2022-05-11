/*
    Class Name        : FBE_FPRM_DealCloneHandler  
    Purpose           : STORY 10977231 Nov Rel 2021.
    Description       : Created the class for the purpose of Cloning Deal Reg along with Deal Products
                        Used in LWC component named 'FBE_FPRM_DealClonelwc', Test Class name:FBE_FPRM_DealCloneHandlerTest.
    Created by        :  Dell - FPRM Team - Sireesha Myla
    Last Modified on  : Aug-24-2021

*/

public with sharing class FBE_FPRM_DealCloneHandler 
{
    @AuraEnabled(cacheable=true)
     public static dealWrapper originalDealReg(Id dealId)
     {
        dealWrapper dealInfo = new dealWrapper();
        Deal_Registration__c dealReg = [SELECT Name,FBE_Book_Date__c,FBE_Account__c,FBE_Deal_Registration_Status__c from Deal_Registration__c where id =:dealId];
        dealInfo.dealId= dealReg.Id;
        

        List<Deal_Product__c> dealProdList= [select Id,FBE_Quantity__c,FBE_Quote_Num__c,FBE_List_Price__c,FBE_Product__c,FBE_Line_Of_Business__c,FBE_Product__r.name,FBE_Line_Description__c,FBE_Sales_price__c,Deal_Registration_Name__c from Deal_Product__c where Deal_Registration_Name__c=:dealId];

        dealInfo.dealProducts = dealProdList;
       return dealInfo;
     }
     @AuraEnabled
     public static Id onSubmitUI(Deal_Registration__c dealRec,List<Deal_Product__c> lstProducts)
     {
         String msg = '';
         Id returnId= null;
         List<Deal_Product__c> cloneProducts;
         List<Deal_Product__c> dealProdList = new List<Deal_Product__c>();
         try{
                system.debug('deal Red:'+dealRec);
                dealRec.FBE_Deal_Registration_Status__c ='New';
                insert dealRec; 
                returnId =dealRec.Id;
                system.debug('new Deal :'+returnId);
                system.debug('line item:'+lstProducts);
                if(lstProducts.size()>0 && returnId!=null)
                {
                    for(Deal_Product__c dl: lstProducts)
                    {
                        system.debug('single line item:'+dl);
                        Deal_Product__c dli = new Deal_Product__c();
                        dli.FBE_Sales_price__c = dl.FBE_Sales_price__c;
                        dli.FBE_Quantity__c = dl.FBE_Quantity__c;
                        dli.Deal_Registration_Name__c = returnId;
                        dli.FBE_Product__c =dl.FBE_Product__c;
                        
                        system.debug('After modify'+dli);
                        dealProdList.add(dli);

                    }
                }
                if(dealProdList.size()>0)
                insert dealProdList;
        
            }   
            catch(DmlException e)
           {
                //Any type of Validation Rule error message, Required field missing error message, Trigger error message etc..
                //we can get from DmlException
                
                //Get All DML Messages
                for (Integer i = 0; i < e.getNumDml(); i++)
                {
                    //Get Validation Rule & Lookup filter error messages
                    msg =+ e.getDmlMessage(i) +  '\n' ;
                }
                //throw DML exception message
                system.debug('Exception error**message='+msg +e);
                if(msg.contains('a8u') || msg.contains('a8v'))
                {
                    msg='No access to this End User Account and Contact. Update the End User Account and Contact record to proceed.';
                }
                
                throw new AuraHandledException(msg);
          }
           system.debug('return Id:'+returnId);
           return returnId;
     }


    
    public class dealWrapper {
        @auraEnabled
        public Id dealId;
        @auraEnabled
        public list<Deal_Product__c> dealProducts= new list<Deal_Product__c>();
    }

    
}