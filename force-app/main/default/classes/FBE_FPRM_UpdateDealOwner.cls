/*
*@ Class Name       : FBE_FPRM_UpdateDealOwner
*@ Description      : This class is used to Transfer Owner on Deal Registration record. It is invoked in system context 
                      to prevent any record locking errors when Partner Users Transfer a Deal Record.
					  Invoked from LWC - 
*@ CreatedBy        : Deloitte Consulting
*@ CreatedOn        : 03-05-2021
*@ Modification Log : [Abhishek] - Initially created script as part of Defect #10544762
*/
public with sharing class FBE_FPRM_UpdateDealOwner {

    @AuraEnabled
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
    }
    
        public class Dealswrapper{
        public set<Id> successIds { get; set;}
        public set<Id> failedIds  { get; set;}
        public Dealswrapper(set<Id> successIds, set<Id> failedIds){
            this.successIds = successIds;
            this.failedIds = failedIds;
        }
    }
}