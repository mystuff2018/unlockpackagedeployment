/*
 *@ Trigger Name      : FBE_DealRegTrigger  
 *@ Description       : This trigger is created on Deal Registration Object. This is executed
                        every time an deal is Inserted & Updated. The method executed is called under the class 'FBE_DealRegTrigger'.
                        
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 05-08-2019
 *@ Modification Log  :  Sireesha Myla - May 13th 2021[Story#10382458]   
 *@ Modification Log  :  Siva kumar Valluru - Jun 25th 2021[Defect #10580424]            
 */
trigger FBE_DealRegTrigger on Deal_Registration__c (before insert, before update,after insert, after update) {
    FBE_TriggerHandler handler = new FBE_TriggerHandler(Trigger.isExecuting, Trigger.size);  
    FBE_DealReg_ApproveDealsHandler handlers = new FBE_DealReg_ApproveDealsHandler(Trigger.isExecuting, Trigger.size);
    Boolean executeAfterInsert = false;
    Boolean executeAfterUpdate = false;
    
    //calling Trigger Handler class method to sync Deal Team Members
    if (Trigger.isAfter && Trigger.isUpdate) {
    system.debug('Inside Trigger');
    //Added below code to give deal reg record access to partner user where online role = My Oppty
    
        if(FBE_CheckRecursive.runAfterUpdate()){
            FBE_FPRM_DealHandler.shareDealRecordWithPartnerUser(Trigger.new, Trigger.oldMap);  
            FBE_FPRM_DealHandler.rejectionFromUI(Trigger.new, Trigger.oldMap);
        }
        
        if(FBE_CheckRecursive.runDealInsertOnce()){
            handler.syncDealTeamMembers(Trigger.oldMap,Trigger.new,'Update');
        }
        handlers.allMethodscall(Trigger.newMap, Trigger.OldMap);
        
    }   
    //calling Trigger Handler class method to sync Deal Team Members
    if (Trigger.isAfter && Trigger.isInsert) {
        
            if(FBE_CheckRecursive.runAfterInsert())
            FBE_FPRM_DealHandler.shareDealRecordWithPartnerUser(Trigger.new, null);
        
        
        FBE_FPRM_DealHandler.changeDefaultPartnerOwner(Trigger.new);
        
        if(FBE_CheckRecursive.runDealUpdateOnce())
        handler.syncDealTeamMembers(Trigger.oldMap,Trigger.new,'Insert');
    }
    
    if (Trigger.isBefore && Trigger.isUpdate) {
    //Defect #10580424   
        handlers.UpdateCreated_Submissiondate(Trigger.new, trigger.oldMap); 
        
        handlers.updateApproveDeclineComments(trigger.new , trigger.oldMap);
        FBE_FPRM_DealHandler.checkDealthresholdAmount(trigger.new , trigger.oldMap);
        FBE_FPRM_DealHandler.updateDeclinedComments(trigger.new , trigger.oldMap);
        
        if(FBE_CheckRecursive.runBeforeOnce())
        FBE_FPRM_DealHandler.populateEU(Trigger.newMap, Trigger.oldMap);// Added by Sireesha Myla - Story#10382458
        
                //Added by uttam on 19-Apr--2021
        List<Deal_Registration__c> lstLookupDeals = new List<Deal_Registration__c>();
        
        for(Deal_Registration__c objDR : trigger.new){
            Deal_Registration__c oldDealReg = Trigger.oldMap.get(objDR.Id);
            if((oldDealReg.FBE_Partner_Sales_Rep_Email__c != objDR.FBE_Partner_Sales_Rep_Email__c && objDR.FBE_Partner_Sales_Rep_Email__c !=  null)
               || (oldDealReg.FBE_Partner_Owner_Email__c != objDR.FBE_Partner_Owner_Email__c  && objDR.FBE_Partner_Owner_Email__c != null) ){
                lstLookupDeals.add(objDR); 
            }
        }  
        if(!lstLookupDeals.isEmpty()){
            User usr = [Select Id,Name,ContactId,Email from User where Id =: UserInfo.getUserId() limit 1];
            FBE_FPRM_DealHandler.populateLookupsBasedOnEmail(lstLookupDeals,usr,true);
        }
    }
    
    //Added by Uttam Kavitkar as a part of FPRM Story #10273037
    //populate partner owner and email field if logged in user is partner user
    //Populate Partner Owner and Sales Rep Lookup value for sharing Deal Reg record with My Opty role.
    if (Trigger.isBefore && Trigger.isInsert) {
        
     List<Deal_Registration__c> lstLookupDeals = new List<Deal_Registration__c>();
        User usr = [Select Id,Name,ContactId,Email from User where Id =: UserInfo.getUserId() limit 1];
        if(usr.ContactId != null){
        //For Partner user
            for(Deal_Registration__c objDR : trigger.new){
                objDR.FBE_FPRM_Partner_Owner__c = usr.Id;
                objDR.FBE_Partner_Owner__c = usr.Name;
                objDR.FBE_Partner_Owner_Email__c = usr.Email;
                if(objDR.FBE_Partner_Sales_Rep_Email__c !=  null){
                    lstLookupDeals.add(objDR);
                }
            }
        }
        else{
            //For Internal PSP/PMO user
            for(Deal_Registration__c objDR : trigger.new){
                if(objDR.FBE_Partner_Sales_Rep_Email__c !=  null || objDR.FBE_Partner_Owner_Email__c != null){
                    lstLookupDeals.add(objDR);
                }
             }
         }
         if(!lstLookupDeals.isEmpty()){
            FBE_FPRM_DealHandler.populateLookupsBasedOnEmail(lstLookupDeals,usr,false);
         }
      }
}