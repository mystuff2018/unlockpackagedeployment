/**************
*@ CreatedBy   	: Dell Team FPRM
*@ CreatedOn   	: 28th May 2021 [Saikumar Jakkam] [Feature # 9912074]
*@ Description  : ->When an Affliation(relationship type of DMP or Reseller) status is 'ready for transfer', then this batch takes this affliation and if it finds a new
                 	Affliation under a new Distributor, then it will transfer the deals/opties of that DMP/Reseller to the New Distributor.
                 ->It mainly updates the deals/opties of DMP/reseller under the old distributor to a new Distributor as follows:
                    Account -> New Distributor Account
                    Reseller Account -> will be same
                    Distributor Account -> New Distributor Account
                    Partner Owner -> (New Distributor Account.Disty Switch Contact)
                    Partner Sales Rep -> (New Distributor Account.Disty Switch Contact), if the partner sales rep is Distributor user. if not the Distributor user then it will be same.
                 -> And Logs the error info to Configurator object with the Batch results.
                 -> This same batch will also be invoked from 'FBE_FPRM_ShareAccountWithPartnerUserTrigger' for Manual Disty Transfer from UI.
***************/  

global with sharing class FBE_FPRM_DistyTransferBatch implements database.Batchable<sObject>,Database.Stateful{
    Map<Id, FBE_FPRM_DistyTransferBatch_Handler.resultsWrap> batchReseultMap = new Map<Id, FBE_FPRM_DistyTransferBatch_Handler.resultsWrap>();
    String relationType =''; 
    Boolean isManualTransfer;
    String affStatus = '';
    global FBE_FPRM_DistyTransferBatch(String type , Boolean manualTransfer, String status) {
        relationType = type;
        affStatus =status;
        if(manualTransfer == true){
            isManualTransfer =manualTransfer;
        }
    }
    
    global Database.QueryLocator start (Database.BatchableContext bc) {
        FBE_FPRM_Transfer_Deal_Check__c cs = FBE_FPRM_Transfer_Deal_Check__c.getInstance(UserInfo.getProfileId());
        cs.Is_Transfer_Deal__c = true;
        UPDATE cs;
        return Database.getQueryLocator([SELECT FBE_Account__c,FBE_Affilitated_Account__c,FBE_End_Date__c,FBE_FPRM_Transfer_Status__c,FBE_Relationship__c,FBE_Start_Date__c,Id,Name FROM Account_Affiliation__c WHERE FBE_FPRM_Transfer_Status__c = :affStatus AND FBE_Relationship__c =: relationType]);
    }
    
    global void execute (Database.BatchableContext bc, List<Account_Affiliation__c> scope) {
      
        Integer startTime = Limits.getCPUTime();
        try{
            FBE_FPRM_DistyTransferBatch_Handler.AfflliationWrap affwrap;
            affwrap = FBE_FPRM_DistyTransferBatch_Handler.getValidAfliations(scope , relationType);
            Map<Id,Account_Affiliation__c> dmpIdWithNewAff = new Map<Id,Account_Affiliation__c>();
            Map<Id,Account_Affiliation__c> dmpIdWithOldAff = new Map<Id,Account_Affiliation__c>();
            dmpIdWithNewAff = affwrap.dmpIdWithNewAff;//check if this could be null
            dmpIdWithOldAff = affwrap.dmpIdWithOldAff;
            List<Deal_Registration__c> updDealList = new List<Deal_Registration__c>();
            List<Opportunity> updOptyList = new List<Opportunity>();
            Account_Affiliation__c newAff = new Account_Affiliation__c();
            Opportunity opty;
            Map<Id,Id> newAffIdWithSiteAdminCon = new Map<Id,Id>();
            Map<Id,USer> contIdWithUser = new Map<Id,User>();
            Map<Id,User> newAffIdWithSiteAdminUser =  new Map<Id,User>();
            FBE_FPRM_DistyTransferBatch_Handler.resultsWrap  msgWrap;
            for(Account_Affiliation__c aff : scope){    
                if(dmpIdWithNewAff != null && dmpIdWithNewAff.containsKey(aff.FBE_Affilitated_Account__c)){
                    newAff = dmpIdWithNewAff.get(aff.FBE_Affilitated_Account__c);
                    System.debug(newAff.FBE_Account__r.FBE_FPRM_Disti_Switch_Contact__c+'New Affl :'+newAff.id);
                    if(newAff.FBE_Account__r.FBE_FPRM_Disti_Switch_Contact__c == null){
                        msgWrap = new FBE_FPRM_DistyTransferBatch_Handler.resultsWrap();
                        msgWrap.message = 'No Disty Switch Contact Available';
                        batchReseultMap.put(aff.Id, msgWrap);
                    }
                }else{
                    msgWrap = new FBE_FPRM_DistyTransferBatch_Handler.resultsWrap();
                    msgWrap.message = 'No New Valid Affliation is available';
                    batchReseultMap.put(aff.Id, msgWrap);
                }
            }
            if(dmpIdWithNewAff != null && !dmpIdWithNewAff.isEmpty()){
                for(Account_Affiliation__c aff : dmpIdWithNewAff.values()){
                    if(aff.FBE_Account__r.FBE_FPRM_Disti_Switch_Contact__c != null){
                        newAffIdWithSiteAdminCon.put(aff.Id,aff.FBE_Account__r.FBE_FPRM_Disti_Switch_Contact__c);
                    }
                }
            }
            for(User u : [SELECT id,isActive,ContactId,FirstName,LastName,Email FROM User WHERE ContactId IN : newAffIdWithSiteAdminCon.values() AND isActive = true]){
                contIdWithUser.put(u.ContactId, u);
            }
            if(!newAffIdWithSiteAdminCon.isEmpty()){
                for(Id affId : newAffIdWithSiteAdminCon.keySet()){
                    if(contIdWithUser.containsKey(newAffIdWithSiteAdminCon.get(affId))){
                        newAffIdWithSiteAdminUser.put(affId, contIdWithUser.get(newAffIdWithSiteAdminCon.get(affId)));
                    }
                    
                }
                
            }
            if(dmpIdWithNewAff != null && !dmpIdWithNewAff.isEmpty()){
                
                for(Deal_Registration__c deal : [SELECT Id,FBE_Deal_Registration_Status__c,FBE_Fulfilment_Path__c,FBE_Account__c, FBE_Distributor_Account__c, FBE_Reseller_VAR_Account__c,
                                                 FBE_FPRM_Partner_Sales_Rep__c,FBE_FPRM_Partner_Sales_Rep_Profile__c,FBE_Partner_Sales_Rep_Name__c,FBE_Partner_Sales_Rep_Email__c,
                                                 FBE_FPRM_Partner_Owner__c,FBE_FPRM_Partner_Owner_Profile__c,FBE_Partner_Owner__c,FBE_Partner_Owner_Email__c,
                                                 FBE_Same_as_submitter__c,FBE_Related_Opportunity__c,FBE_Partner_Opportunity_Stage__c,
                                                 FBE_Related_Opportunity__r.AccountId, FBE_Related_Opportunity__r.FBE_Distributor__c,FBE_Related_Opportunity__r.FBE_VAR_Seller__c
                                                 FROM Deal_Registration__c  WHERE FBE_Fulfilment_Path__c= 'Distribution' AND FBE_Deal_Registration_Status__c 
                                                 IN ('New','Submitted','Approved','Hold for Review') AND FBE_Reseller_VAR_Account__c IN : dmpIdWithNewAff.keySet()])
                {
                    newAff = dmpIdWithNewAff.get(deal.FBE_Reseller_VAR_Account__c);
                    
                    if(newAffIdWithSiteAdminUser.containsKey(newAff.Id) ){
                        if((deal.FBE_Account__c !=  newAff.FBE_Account__c || deal.FBE_Distributor_Account__c != newAff.FBE_Account__c) && 
                           (deal.FBE_Partner_Opportunity_Stage__c != 'Cancelled - 0%' && deal.FBE_Partner_Opportunity_Stage__c !='Lost - 0%' && deal.FBE_Partner_Opportunity_Stage__c !='Won - 100%' )){
                            deal.FBE_Account__c = newAff.FBE_Account__c;
                            deal.FBE_Distributor_Account__c = newAff.FBE_Account__c;
                            
                            if(deal.FBE_FPRM_Partner_Owner_Profile__c == 'FBE FPRM Partner Distributor'){
                                User newDistySiteAdminUser = newAffIdWithSiteAdminUser.get(newAff.Id); 
                                deal.FBE_Partner_Owner__c = newDistySiteAdminUser.FirstName + newDistySiteAdminUser.LastName;
                                deal.FBE_Partner_Owner_Email__c = newDistySiteAdminUser.Email;
                                deal.FBE_FPRM_Partner_Owner__c = newDistySiteAdminUser.Id;
                                
                                if(deal.FBE_FPRM_Partner_Sales_Rep_Profile__c == 'FBE FPRM Partner Distributor'){
                                    deal.FBE_Same_as_submitter__c = 'Yes';
                                    deal.FBE_Partner_Sales_Rep_Name__c = newDistySiteAdminUser.FirstName + newDistySiteAdminUser.LastName;
                                    deal.FBE_Partner_Sales_Rep_Email__c = newDistySiteAdminUser.Email;
                                    deal.FBE_FPRM_Partner_Sales_Rep__c = newDistySiteAdminUser.Id;
                                }
                            }
                          
                            updDealList.add(deal);
                        }
                        if(deal.FBE_Partner_Opportunity_Stage__c == 'Plan - 1%' || deal.FBE_Partner_Opportunity_Stage__c == 'Discover - 10%'||
                           deal.FBE_Partner_Opportunity_Stage__c == 'Qualify - 30%' || deal.FBE_Partner_Opportunity_Stage__c == 'Propose - 60%' || 
                           deal.FBE_Partner_Opportunity_Stage__c == 'Commit - 90%'){
                               if(deal.FBE_Related_Opportunity__r.AccountId != newAff.FBE_Account__c || deal.FBE_Related_Opportunity__r.FBE_Distributor__c != newAff.FBE_Account__c)
                               {
                                   opty = new Opportunity();
                                   opty.Id = deal.FBE_Related_Opportunity__c;
                                   opty.AccountId = newAff.FBE_Account__c;
                                   opty.FBE_Distributor__c = newAff.FBE_Account__c;
                                   opty.FBE_VAR_Seller__c = deal.FBE_Related_Opportunity__r.FBE_VAR_Seller__c;
                                   updOptyList.add(opty);
                               }
                           }
                    }        
                }
            }
            
            Map<Id, FBE_FPRM_DistyTransferBatch_Handler.resultsWrap> dealresultMap = new Map<Id, FBE_FPRM_DistyTransferBatch_Handler.resultsWrap>();
            if(updDealList.size() >0 ){
                dealresultMap = FBE_FPRM_DistyTransferBatch_Handler.trasferDeals(updDealList, dmpIdWithOldAff);
            }
            
            Map<Id, FBE_FPRM_DistyTransferBatch_Handler.resultsWrap> optyresultMap = new Map<Id, FBE_FPRM_DistyTransferBatch_Handler.resultsWrap>();
            if(updOptyList.size() > 0){
                optyresultMap = FBE_FPRM_DistyTransferBatch_Handler.trasferOptys(updOptyList, dmpIdWithOldAff);
            }
            
            FBE_FPRM_DistyTransferBatch_Handler.resultsWrap res;
            for(Account_Affiliation__c aff : scope){
                Id affId = aff.Id;
                if(dealresultMap.containsKey(affId)){
                    batchReseultMap.put(affId, dealresultMap.get(affId));
                    if(optyresultMap.containsKey(affId)){
                        System.debug('JSK - inside, deals and opties available to transfer for Affliation: '+affId);
                        List<String> sOpp =  optyresultMap.get(affId).successOpties;
                        List<String> fOpp =  optyresultMap.get(affId).failedOpties;
                        System.debug('JSK - sOpp: '+ sOpp);
                        System.debug('JSK - fOpp: '+ fOpp);
                        batchReseultMap.get(affId).successOpties = sOpp;
                        batchReseultMap.get(affId).failedOpties = fOpp;
                    }
                }
                if(optyresultMap.containsKey(affId) && !dealresultMap.containsKey(affId)){
                    batchReseultMap.put(affId, optyresultMap.get(affId));
                }
                if(!optyresultMap.containsKey(affId) && !dealresultMap.containsKey(affId)){
                    if(!batchReseultMap.containsKey(affId)){
                        res = new FBE_FPRM_DistyTransferBatch_Handler.resultsWrap();
                        res.successDeals =null;
                        res.failedDeals = null;
                        res.successOpties = null;
                        res.failedOpties = null;
                        res.message = null;
                        batchReseultMap.put(affId, res);
                    }
                }
            }
        }catch(Exception e){
            System.debug('JSK - Exception in execute method: '+ e);
        }
        Integer finishTime = Limits.getCPUTime();
        System.debug('JSK finishTime - '+  finishTime + '  Heap Size: '+ Limits.getHeapSize());
    }
    
    global void finish (Database.BatchableContext bc){
        System.System.debug('JSK - inside finish : '+ batchReseultMap);
        try{
            String logType=' Transfer Log';
            if(isManualTransfer == true){
                logType = ' Manual Transfer Log';
            }
            FBE_FPRM_DistyTransferBatch_Handler.updateTransferResult(batchReseultMap, relationType+ logType);
        }catch(Exception e){
            System.debug('JSK - Exception in Finish method: '+ e);
        }
        FBE_FPRM_Transfer_Deal_Check__c cs = FBE_FPRM_Transfer_Deal_Check__c.getInstance(UserInfo.getProfileId());
        cs.Is_Transfer_Deal__c = false;
        UPDATE cs;
    }    
}