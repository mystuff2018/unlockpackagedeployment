/*
 *@ Batch Apex Name   : "FBE_FPRM_DistyTransferBatch_Handler"                 
 *@ CreatedBy         : Dell Team -FPRM
 *@ CreatedOn         : 24th May 2021
 *@ Modification Log  :  Sireesha Myla - 27th May 2021[Story#10466879]        
 *@ Description       : This is a Handler class for 'FBE_FPRM_DistyTransferBatch'
 */
public class FBE_FPRM_DistyTransferBatch_Handler 
{
    public class AfflliationWrap
    {
        public  Map<Id,Account_Affiliation__c> dmpIdWithNewAff {get; set;}
        public  Map<Id,Account_Affiliation__c> dmpIdWithOldAff {get; set;}
    }
    public class resultsWrap
    {
        public  List<String> successDeals {get; set;}
        public  List<String> failedDeals {get; set;}
        public  List<String> successOpties {get; set;}
        public  List<String> failedOpties {get; set;}
        public String message {get; set;}
    }
    public static AfflliationWrap affWrap = new AfflliationWrap();

    public static AfflliationWrap getValidAfliations( List<Account_Affiliation__c> oldAffl , String relationType)
    {
        Map<Id,Account_Affiliation__c> dmpIdWithOldAffliation = new Map<Id,Account_Affiliation__c>();
        for(Account_Affiliation__c aff : oldAffl)
        {
            dmpIdWithOldAffliation.put(aff.FBE_Affilitated_Account__c, aff);
        }

        Map<Id,Account_Affiliation__c> allDMPEligibleAffl = new Map<Id,Account_Affiliation__c>();
       
       for(Account_Affiliation__c aff : [SELECT FBE_Account__c,FBE_Account__r.FBE_FPRM_Disti_Switch_Contact__c,FBE_Affilitated_Account__c,FBE_End_Date__c,
                                            FBE_FPRM_Transfer_Status__c,FBE_Relationship__c,FBE_Start_Date__c,Id,Name FROM Account_Affiliation__c 
                                            WHERE FBE_Relationship__c =: relationType AND FBE_FPRM_Transfer_Status__c = '' AND FBE_Start_Date__c <= Today 
                                            AND (FBE_End_Date__c >= today OR FBE_End_Date__c = null ) AND FBE_Affilitated_Account__c IN : dmpIdWithOldAffliation.keySet() 
                                            ORDER BY FBE_Start_Date__c DESC])
       {
            allDMPEligibleAffl.put(aff.FBE_Affilitated_Account__c , aff);                             
       }

       Map<Id,Account_Affiliation__c> dmpIdWithNewAff = new Map<Id,Account_Affiliation__c>();
        Map<Id,Account_Affiliation__c> dmpIdWithOldAff = new Map<Id,Account_Affiliation__c>();
       Account_Affiliation__c newAff = new Account_Affiliation__c();
        for(Id dmpId : dmpIdWithOldAffliation.keySet())
        {
            if(allDMPEligibleAffl.containsKey(dmpId))
            {
                newAff = allDMPEligibleAffl.get(dmpId);
                    dmpIdWithNewAff.put(dmpId, newAff);
                    affWrap.dmpIdWithNewAff = dmpIdWithNewAff;
                    System.debug('dmpIdWithOldAffliation:  '+ dmpIdWithOldAffliation);
                     System.debug('dmpIdWithOldAffliation:  '+ dmpIdWithOldAffliation.get(dmpId));
                    dmpIdWithOldAff.put(dmpId, dmpIdWithOldAffliation.get(dmpId));
                    affWrap.dmpIdWithOldAff = dmpIdWithOldAff;
            }
        }
        System.debug('JSK - affWrap: '+affWrap);
        return affWrap;
    }

    public static Map<Id,resultsWrap> getDealResultsWrap(List<Deal_Registration__c> updList , Map<Id,String> successDealMap , Map<Id,String> failedDealMap , Map<Id,Account_Affiliation__c> dmpIdWithOldAff)
    {
        Map<Id,resultsWrap> returnMap = new Map<Id,resultsWrap>();
        Id oldAffId;
        String s;String f;
        resultsWrap retWrap;
        for(Deal_Registration__c deal : updList)
        {
            if(dmpIdWithOldAff.containsKey(deal.FBE_Reseller_VAR_Account__c))
            {
                oldAffId = dmpIdWithOldAff.get(deal.FBE_Reseller_VAR_Account__c).Id;
            }
            if(!returnMap.containsKey(oldAffId))
            {
                retWrap = new  resultsWrap();
                retWrap.successDeals = new List<String>();
                retWrap.failedDeals = new List<String>();
                returnMap.put(oldAffId, retWrap);
            }
            if(successDealMap.containsKey(deal.Id))
            {
                    s = successDealMap.get(deal.Id);
                    returnMap.get(oldAffId).successDeals.add(s);
                    
            }
            if(failedDealMap.containsKey(deal.Id))
            {
                f = failedDealMap.get(deal.Id);
                returnMap.get(oldAffId).failedDeals.add(f);
            }
            oldAffId=null;s='';f='';
        }
        return returnMap;
    }

    public static Map<Id,resultsWrap> getOptyResultsWrap(List<Opportunity> updOptyList , Map<Id,String> successOptyMap , Map<Id,String> failedOptyMap , Map<Id,Account_Affiliation__c> dmpIdWithOldAff)
    {
        System.debug('JSK - successOptyMap ' + successOptyMap);
        System.debug('JSK - failedOptyMap ' + failedOptyMap);
        Map<Id,resultsWrap> returnMap = new Map<Id,resultsWrap>();
        Id oldAffId;
        String s;String f;
        resultsWrap retWrap2;
        for(Opportunity opp : updOptyList)
        {
            if(dmpIdWithOldAff.containsKey(opp.FBE_VAR_Seller__c))
            {
                oldAffId = dmpIdWithOldAff.get(opp.FBE_VAR_Seller__c).Id;
            }
            if(!returnMap.containsKey(oldAffId))
            {
                retWrap2 = new resultsWrap();
                retWrap2.successOpties = new List<String>();
                retWrap2.failedOpties = new List<String>();
                returnMap.put(oldAffId, retWrap2);
            }
            if(successOptyMap.containsKey(opp.Id))
            {
                    s = successOptyMap.get(opp.Id);
                    returnMap.get(oldAffId).successOpties.add(s);
                    
            }
            if(failedOptyMap.containsKey(opp.Id))
            {
                f = failedOptyMap.get(opp.Id);
                returnMap.get(oldAffId).failedOpties.add(f);
            }
            oldAffId=null;s='';f='';
        }
        return returnMap;
    }

    public static void updateTransferResult(Map<Id, resultsWrap> batchReseultMap, String transferType)
    {
        Id configRecTypeId = Schema.getGlobalDescribe().get('FBE_Configurator__c').getDescribe().getRecordTypeInfosByName().get('Disty Transfer Logs').getRecordTypeId();
        List<Account_Affiliation__c> affUpdList = new List<Account_Affiliation__c>();
        List<FBE_Configurator__c> InsertConfigList = new List<FBE_Configurator__c>();
        FBE_Configurator__c distyConfig;
        if(!batchReseultMap.isEmpty())
        {
        for(Id affId : batchReseultMap.keySet())
        {
            System.debug('batchReseultMap : sDeals : '+ batchReseultMap.get(affId).successDeals);
            System.debug('batchReseultMap : fDeals : '+ batchReseultMap.get(affId).failedDeals);
            System.debug('batchReseultMap : sOpties : '+ batchReseultMap.get(affId).successOpties);
            System.debug('batchReseultMap : fOpties : '+ batchReseultMap.get(affId).failedOpties);

            distyConfig = new FBE_Configurator__c();
            distyConfig.recordtypeId = configRecTypeId; 
            distyConfig.Account_Affiliation__c = affId;
            String sdString ='';
            if(batchReseultMap.get(affId).successDeals != null &&  batchReseultMap.get(affId).successDeals.size() >0)
            {
                for(String s : batchReseultMap.get(affId).successDeals)
                {
                    sdString = sdString + s;
                }
            }
            String fdString = '';
            if(batchReseultMap.get(affId).failedDeals != null && batchReseultMap.get(affId).failedDeals.size() > 0)
            {
                for(String f : batchReseultMap.get(affId).failedDeals)
                {
                    fdString = fdString + f;
                }
            }
            
            String sOString='';
            if(batchReseultMap.get(affId).successOpties != null && batchReseultMap.get(affId).successOpties.size() > 0)
            {
                for(String s : batchReseultMap.get(affId).successOpties)
                {
                    sOString = sOString + s;
                }
            }
            
            String fOString='';
            if(batchReseultMap.get(affId).failedOpties != null && batchReseultMap.get(affId).failedOpties.size() > 0)
            {
                for(String f : batchReseultMap.get(affId).failedOpties)
                {
                    fOString = fOString + f;
                }
            }

            if(batchReseultMap.get(affId).message != null && batchReseultMap.get(affId).message.length() > 0){
                distyConfig.FBE_FPRM_Transfer_Comments__c = batchReseultMap.get(affId).message;
                distyConfig.Transfer_Status__c = 'Configuration Error';
                System.debug('Config error:'+batchReseultMap.get(affId).message);
                affUpdList.add(new Account_Affiliation__c(Id =affId, FBE_FPRM_Transfer_Status__c ='Configuration Error'));
            }
            distyConfig.Success_Deals__c = sdString;
            distyConfig.Failure_Deals__c = fdString;
            distyConfig.Success_Opportunities__c = sOString;
            distyConfig.Failure_Opportunities__c = fOString;
            distyConfig.Name = transferType + ' - '+ affId;
            InsertConfigList.add(distyConfig);
            System.debug('JSK : batchReseultMap.get(affId).successDeals '+ batchReseultMap.get(affId).successDeals);
            System.debug('JSK : batchReseultMap.get(affId).failedDeals '+ batchReseultMap.get(affId).failedDeals);

            if( (sdString.length() >0 && sOString.length() >0 && fdString.length() == 0 && fOString.length() == 0) || 
                (sdString.length() >0 && sOString.length() ==0 && fdString.length() == 0 && fOString.length() == 0) ||
                (sdString.length() ==0 && sOString.length() >0 && fdString.length() == 0 && fOString.length() == 0)){
                    affUpdList.add(new Account_Affiliation__c(Id =affId, FBE_FPRM_Transfer_Status__c ='Completed'));
                    distyConfig.Transfer_Status__c = 'Completed';
            }
            if((sdString.length() ==0 && sOString.length() ==0 && fdString.length() > 0 && fOString.length() > 0) || 
                (sdString.length() ==0 && sOString.length() ==0 && fdString.length() > 0 && fOString.length() == 0) || 
                ((sdString.length() ==0 && sOString.length() ==0 && fdString.length() == 0 && fOString.length() > 0))){
                    affUpdList.add(new Account_Affiliation__c(Id =affId, FBE_FPRM_Transfer_Status__c ='Error'));
                    distyConfig.Transfer_Status__c = 'Error';
            }
            if((sdString.length() >0 || sOString.length() >0) && (fdString.length() > 0 || fOString.length() > 0)){
                    affUpdList.add(new Account_Affiliation__c(Id =affId, FBE_FPRM_Transfer_Status__c ='Completed with Errors'));
                    distyConfig.Transfer_Status__c = 'Completed with Errors';
            }
            // Update status to complete even if there are no deals/opties available to transfer for the affliation.
            if(sdString.length() ==0 && sOString.length() ==0 && fdString.length() == 0 && fOString.length() == 0 && batchReseultMap.get(affId).message == null){
                System.debug('inside no deals/opties to transfer or already been transferred');
                    affUpdList.add(new Account_Affiliation__c(Id =affId, FBE_FPRM_Transfer_Status__c ='Completed'));
                    //distyConfig.FBE_FPRM_Transfer_Comments__c = 'No deals/opportunites to transfer or already been transferred';
                    distyConfig.Transfer_Status__c = 'Completed';
                    distyConfig.Success_Deals__c= '0';
                    distyConfig.Success_Opportunities__c='0';
                    distyConfig.Failure_Deals__c = '0';
                    distyConfig.Failure_Opportunities__c = '0';
            }
        }
    }
        if(affUpdList.size() >0 ) UPDATE affUpdList;
        if(InsertConfigList.size() >0){
            FBE_Configurator__c con ;
            List<String> oldConfigList = new List<String>();
            List<Id> affAccountIds = new List<Id>();
            for(FBE_Configurator__c config: InsertConfigList){
                affAccountIds.add(config.Account_Affiliation__c);
            }
            // The below is to avoid duplicate entries in Configurator Object if the affliation is failed and already logged 
            //with 'No new Valid aff' or 'No disty switch Contact' message.
            for(FBE_Configurator__c config :  [SELECT id,Account_Affiliation__c,FBE_FPRM_Transfer_Comments__c FROM FBE_Configurator__c WHERE 
                                                Account_Affiliation__c IN : affAccountIds  AND FBE_FPRM_Transfer_Comments__c !=null]){
                    System.debug('JSK - has already logged in Config');
                    oldConfigList.add(config.Account_Affiliation__c + config.FBE_FPRM_Transfer_Comments__c);
            }
            System.debug('JSK - oldConfigList: '+oldConfigList);
            System.debug('JSK - InsertConfigList: '+InsertConfigList);
            for(Integer i = (InsertConfigList.size()-1) ; i>= 0 ; i--){
                con = InsertConfigList[i];
                if(oldConfigList.contains(con.Account_Affiliation__c + con.FBE_FPRM_Transfer_Comments__c)){
                    System.debug('JSK - removing the item as it is already logged');
                    InsertConfigList.remove(i);
                }
            }
            INSERT InsertConfigList;
        }
    }

    public static Map<Id, resultsWrap> trasferDeals(List<Deal_Registration__c> updDealList ,  Map<Id,Account_Affiliation__c> dmpIdWithOldAff){
            Map<Id,String> successDealMap = new Map<Id,String>();
            Map<Id,String> failedDealMap = new Map<Id,String>();
            Database.SaveResult[] srList = Database.update(updDealList,false);
            for(Integer i=0;i<srList.size();i++){
                if (srList.get(i).isSuccess()){
                    successDealMap.put(srList.get(i).Id , srList.get(i).Id + ', ');
                }else if (!srList.get(i).isSuccess()){
                    Database.Error error = srList.get(i).getErrors().get(0);
                    String errMsg = error.getMessage();
                    failedDealMap.put(updDealList.get(i).Id, updDealList.get(i).Id + ': {Message: '+ errMsg + '}'+ ' \n');
                    system.debug('Failed ID : '+updDealList.get(i).Id + ' errMsg : '+errMsg);
                 }
            }    
            Map<Id, resultsWrap> dealresultMap = new Map<Id, resultsWrap>();
            dealresultMap = getDealResultsWrap(updDealList, successDealMap , failedDealMap, dmpIdWithOldAff);
            System.debug('JSK - dealresultMap: '+ dealresultMap);
        return dealresultMap;
       }
    
    public static Map<Id, resultsWrap> trasferOptys(List<Opportunity> updOptyList ,  Map<Id,Account_Affiliation__c> dmpIdWithOldAff){
        Map<Id,String> successOptyMap = new Map<Id,String>();
        Map<Id,String> failedOptyMap = new Map<Id,String>();
         Database.SaveResult[] srList = Database.update(updOptyList,false);
         for(Integer i=0;i<srList.size();i++){
            if (srList.get(i).isSuccess()){
                successOptyMap.put(srList.get(i).Id , srList.get(i).Id + ', ');
            }else if (!srList.get(i).isSuccess()){
                Database.Error error = srList.get(i).getErrors().get(0);
                String errMsg = error.getMessage();
                failedOptyMap.put(updOptyList.get(i).Id, updOptyList.get(i).Id + ': {Message: '+ errMsg + '}'+ ' \n');
                system.debug('Failed ID : '+updOptyList.get(i).Id + ' errMsg : '+errMsg);
             }
        } 
        Map<Id, resultsWrap> optyresultMap = new Map<Id, resultsWrap>();
        optyresultMap = getOptyResultsWrap(updOptyList, successOptyMap , failedOptyMap, dmpIdWithOldAff);
        System.debug('JSK - optyresultMap: '+ optyresultMap);
        return optyresultMap;
    }
}