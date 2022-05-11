/**************
 * @ Class Name        : FBE_FPRM_ShareAccountWithPartnesHandler
 * @ Description       : This class is created to automatically share Account record with Partner Users based on different criterias 
 *                       Created as part of Feature #9912110.
 * @ CreatedBy         : Deloitte
 * @ Modification Log  : Version 1.0 - [Namrata] :, Added new Method by Sireesha Myla - 9912077 - 10th June 2021
*********/

public Class FBE_FPRM_ShareAccountWithPartnesHandler{
    
    public static Boolean isExecuted = false; 
    //Share account with partner users
    public static void shareAccountWithPartner(List<Account_Affiliation__c> lstAccountAffliation, Map<Id, List<User>> userMap){
        
        List<AccountShare> toShareAccount = new List<AccountShare>();
        for(Account_Affiliation__c aaf: lstAccountAffliation){
            system.debug('before user check:');
            system.debug(aaf.FBE_Account__c+' Affl Account: '+userMap.keyset());
            if(userMap.containsKey(aaf.FBE_Account__c)){
               system.debug('After user check:');
                for(User user: userMap.get(aaf.FBE_Account__c)){  
                    if(aaf.FBE_Account__c == user.Contact.AccountId && aaf.FBE_Start_Date__c <= System.today() && (aaf.FBE_End_Date__c >= System.today() || aaf.FBE_End_Date__c == null ) ){
                       //system.debug('satisfied to create share:'+user.Id); 
                        AccountShare accShare = new AccountShare();
                        accShare.AccountId = aaf.FBE_Affilitated_Account__c;
                        accShare.UserOrGroupId = user.Id;
                        accShare.OpportunityAccessLevel='None';
                        if( (aaf.FBE_Relationship__c == System.Label.FBE_FPRM_Distributor || aaf.FBE_Relationship__c == System.Label.FBE_FPRM_Reseller) 
                               && user.contact.FBE_FPRM_Reseller_Account__c == null){ 
                            accShare.AccountAccessLevel = 'Read';                        
                        }
                        if(aaf.FBE_Relationship__c == System.label.FBE_FPRM_Disty_Managed && user.contact.FBE_FPRM_Reseller_Account__c == null){
                            accShare.AccountAccessLevel = 'Edit';  
                        } 
                        system.debug('share Rec info'+accShare);
                        toShareAccount.add(accShare);
                    }
                }
            }
        }
        
        System.debug('toShareAccount'+toShareAccount); 
        if(!toShareAccount.isEmpty()){

            Set<Id> successIds = new Set<Id>();
            Map<Id, Account_Affiliation__c> updateAffiliationIdsList = new Map<Id, Account_Affiliation__c>();
            Database.SaveResult[] result = Database.insert(toShareAccount, false);
            for (Database.SaveResult sr : result) {
                if (sr.isSuccess()) {
                    successIds.add(sr.getId());
                }
            }
            if(!successIds.isEmpty()){
                
                Set<Id> affilatedId = new Set<Id>();
                for(AccountShare accShare: [SELECT Id,AccountId,UserOrGroupId FROM AccountShare WHERE ID IN:successIds]){
                    affilatedId.add(accShare.AccountId);
                }
                for(Account_Affiliation__c aaf: [SELECT Id,FBE_FPRM_isProcessed__c,FBE_Affilitated_Account__c,FBE_Account__c 
                                                 FROM Account_Affiliation__c WHERE FBE_Affilitated_Account__c IN: affilatedId AND FBE_Start_Date__c<=Today AND (FBE_End_Date__c>= Today OR FBE_End_Date__c= null)]){ 
                    if(userMap.containsKey(aaf.FBE_Account__c)){
                        for(User user: userMap.get(aaf.FBE_Account__c)){ 
                            if(user.AccountId == aaf.FBE_Account__c ){
                                aaf.FBE_FPRM_isProcessed__c = true;
                                updateAffiliationIdsList.put(aaf.Id, aaf);
                            }
                        } 
                	}
                }
 				system.debug('==updateAffiliationIdsList==' + updateAffiliationIdsList);
                if(!updateAffiliationIdsList.isEmpty()){
                    update updateAffiliationIdsList.values();
                }
            }
        }
    }
    // Added new Method by Sireesha Myla - Story 9912077 - 10th June 2021
    public static void distyManualTransfer(Map<Id, Account_Affiliation__c> newRecords, Map<Id, Account_Affiliation__c> oldRecords)
    {
        if(oldRecords!= null && newRecords!= null)
        {
            for(Account_Affiliation__c newAff: newRecords.values())
            {
                if(newAff.FBE_FPRM_Transfer_Status__c =='Initiate Manual Transfer' && newAff.FBE_FPRM_Transfer_Status__c != oldRecords.get(newAff.id).FBE_FPRM_Transfer_Status__c)
                  {
                      Database.executeBatch(new FBE_FPRM_DistyTransferBatch(newAff.FBE_Relationship__c, true, newAff.FBE_FPRM_Transfer_Status__c)); // Calling batch class.
                  }
            }
        }
    }
    
}