/*
*@ Class Name     : FBE_FPRM_Deal_Transfer_Controller
*@ Test Class     : FBE_FPRM_Deal_Transfer_ControllerTest
*@ Description      : This class is used for Transfer Deal Functionality Story#10273041 .
*@ CreatedBy        : Deloitte Consulting
*@ CreatedOn        : 12-Mar-2021 [Uttam Kavitkar]
*@ Modification Log :                     
*/

public with sharing class FBE_FPRM_Deal_Transfer_Controller {
     
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getDealRegs(String ownerEmail,String submitterEmail, String regNumber,String dealRegStatus,String partnerSalesEmail) {
        
        String currentUserAccountId = [Select Id,AccountId from user where Id =: Userinfo.getUserId() limit 1].AccountId;
        String query = 'SELECT Id,Name,Owner.Name,FBE_Deal_Reg_Num__c,FBE_Related_Opportunity__r.Name,' +
            'FBE_Partner_Sales_Rep_Name__c,FBE_Partner_Sales_Rep_Email__c,FBE_Partner_Sales_Rep_Phone__c,' +
            'FBE_Deal_Submitter_Name__c,FBE_Partner_Owner__c FROM Deal_Registration__c where FBE_Deal_Reg_Num__c != NULL';
            //'where FBE_Distributor_Account__c =:currentUserAccountId';
        
        if(ownerEmail != null && ownerEmail != '') {
            String partnerOwnerEmail = '%' + ownerEmail + '%'; 
            query += ' AND FBE_Partner_Owner_Email__c LIKE :partnerOwnerEmail';
        }
        if(submitterEmail != null && submitterEmail != '') {
            String key1 = '%' + submitterEmail + '%'; 
            query += ' AND FBE_Deal_Submitter_Email_Phone__c LIKE :key1';
        }
        if(regNumber != null && regNumber != '') {
            String key2 = '%' + regNumber + '%';
            query += ' AND FBE_Deal_Reg_Num__c LIKE :key2';
        }
        if(dealRegStatus != null && dealRegStatus != '') {
            String key3 = '%' + dealRegStatus + '%';
            query += ' AND FBE_Deal_Registration_Status__c LIKE :key3';
        }
        if(partnerSalesEmail != null && partnerSalesEmail != '') {
            String key4 = '%' + partnerSalesEmail + '%';
            query += ' AND FBE_Partner_Sales_Rep_Email__c LIKE :key4';
        } 
        query += ' Limit 50'; 
        
        system.debug('query---'+Database.query(query));
        return Database.query(query); 
    }
     
   /* @AuraEnabled
    public static String updateDealOwner(List<Deal_Registration__c> lstDeals,String ownerId){
        
        try{
            //By pass validation while transfer owner 
        	byPassValidation(true);
            
            system.debug('lstDeals==' + lstDeals);
        	system.debug('ownerId==' + ownerId);
            User selectedUser = [Select Id,Name,Email from User where Id =: ownerId limit 1];
            List<Deal_Registration__c> lstDealsUpdate = new List<Deal_Registration__c>();
            if(!lstDeals.isEmpty() && selectedUser != null){
                for(Deal_Registration__c deal : lstDeals){
                    deal.FBE_FPRM_Partner_Owner__c = selectedUser.Id;
                    deal.FBE_Partner_Owner__c = selectedUser.Name;
                    deal.FBE_Partner_Owner_Email__c = selectedUser.Email;
                    lstDealsUpdate.add(deal);
                }
            }
            
            set<Id> allSuccessId  = new set<Id>();
            set<Id> allFailedId  = new set<Id>();
            if(!lstDealsUpdate.isEmpty()){
                database.SaveResult[] myResult = database.update(lstDealsUpdate,false);
                for(Integer i=0; i < myResult.size(); i++) {
                    if(myResult.get(i).isSuccess()) {
                        system.debug('successID == ' + myResult.get(i).Id);
                        allSuccessId.add(myResult.get(i).Id);
                    } 
                    else if(!myResult.get(i).isSuccess()) {
                        system.debug('failedID == ' + lstDealsUpdate.get(i).Id);
                        //allFailedId.add(myResult.get(i).Id);
                        allFailedId.add(lstDealsUpdate.get(i).Id);
                    }
                }
            }
            String returnString = '';
            if(!allSuccessId.isEmpty() || !allFailedId.isEmpty()){
                Dealswrapper objwrapper = new Dealswrapper(allSuccessId,allFailedId);
                returnString = JSON.serialize(objwrapper);
            }
            //make it false once transfer owner is done, So validation will run normally.
        	byPassValidation(false);
            return returnString;
        }
        catch(Exception ex){
            //make it false once transfer owner is done, So validation will run normally.
        	byPassValidation(false);
            return 'Exception occured at FBE_FPRM_Deal_Transfer_Controller -->> updateDealOwner' + ex.getMessage();
        }
    }
    
    private static void byPassValidation(Boolean isBypass){
        //system.debug('==byPassValidation is called==');
        FBE_FPRM_Transfer_Deal_Check__c csTD = FBE_FPRM_Transfer_Deal_Check__c.getInstance(UserInfo.getProfileId());
        csTD.Is_Transfer_Deal__c = isBypass; 
        update csTD; 
    } */

    @AuraEnabled(cacheable=true)  
    public static List<sobject> findUserRecords(String searchKey, String objectName) {  
        
        User usr = [Select Id,AccountId,ContactId,Profile.Name,Contact.FBE_FPRM_Reseller_Account__c from user where Id =: Userinfo.getUserId() limit 1];
        string searchText = '\'%' + String.escapeSingleQuotes(searchKey) + '%\'';
        
        //Flag used to exclude the users have case submission online role 
        String roleCheck = '\'%Case%\'';
        string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE ContactId != NULL AND (NOT FBE_FPRM_OnlineRole__c LIKE ' + roleCheck + ') AND Name LIKE '+searchText;
        if(usr.ContactId != null){   
            if(usr.Profile.Name == 'FBE FPRM Partner Disty Managed'){  
                 Id resellerAccId = usr.Contact.FBE_FPRM_Reseller_Account__c;
            	 query += ' AND Contact.FBE_FPRM_Reseller_Account__c =:resellerAccId';
            }
            else{
                Id accId = usr.AccountId;
                query += ' AND AccountId =:accId';
            }
        }
        return Database.query(query);  
    } 
    
    /*public class Dealswrapper{
        public set<Id> successIds { get; set;}
        public set<Id> failedIds  { get; set;}
        public Dealswrapper(set<Id> successIds, set<Id> failedIds){
            this.successIds = successIds;
            this.failedIds = failedIds;
        }
    } */

}