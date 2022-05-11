global class FBE_FPRM_PartnerAccountAccessBatch implements  Database.Batchable<sObject>, Schedulable {
    global Database.QueryLocator Start(Database.BatchableContext BC){
        String query = 'SELECT Id, FBE_Start_Date__c, FBE_End_Date__c, FBE_Account__c, FBE_Affilitated_Account__c, FBE_FPRM_isProcessed__c, FBE_Relationship__c FROM Account_Affiliation__c WHERE (FBE_End_Date__c < TODAY AND FBE_FPRM_isProcessed__c = true) OR  (FBE_Start_Date__c <= Today AND FBE_FPRM_isProcessed__c = false AND ( FBE_End_Date__c >= Today  OR FBE_End_Date__c = null))';
       //String query = 'SELECT Id, FBE_Start_Date__c, FBE_End_Date__c, FBE_Account__c, FBE_Affilitated_Account__c, FBE_FPRM_isProcessed__c, FBE_Relationship__c FROM Account_Affiliation__c WHERE (FBE_End_Date__c < TODAY AND FBE_FPRM_isProcessed__c = true) AND  (FBE_Start_Date__c <= Today AND ( FBE_End_Date__c >= Today  OR FBE_End_Date__c = null))';
        return Database.getQueryLocator(query);

    }
    
    global void execute(Database.BatchableContext BC, List<Account_Affiliation__c> aafList){
        System.debug('Account Affiliations List in Batch: '+aafList);
        
        Set<Id> affAccountIdSet = new Set<Id>();
        Set<Id> userIdSet = new Set<Id>();
        List<ID> lstAffiliation = new List<ID> ();
        List<Id> endDatedAff = new List<Id>();
        
        Map<Id, List<User>> userMap = new Map<Id, List<User>>();
        
        List<Account_Affiliation__c> accountAffiliationList = new List<Account_Affiliation__c>();
        List<AccountShare> accShareList = new List<AccountShare>();
        List<AccountShare> delAccShareList = new List<AccountShare>();
        //Abhishek : Modifying the script based on observed issues
        for(Account_Affiliation__c eaAff: aafList){
            affAccountIdSet.add(eaAff.FBE_Account__c);
            System.debug(eaAff.FBE_Start_Date__c+'Dates check:'+eaAff.FBE_End_Date__c+System.today()+'Affiliations to process: '+eaAff.FBE_Account__c);
        }
        
        for(User eaUser : [SELECT Id, ContactId, Contact.AccountId, AccountId, Contact.FBE_FPRM_Reseller_Account__c FROM User WHERE User.Contact.AccountId IN:affAccountIdSet ]){
            if(userMap.containsKey(eaUser.Contact.AccountId)){
                List<User> lstUser = userMap.get(eaUser.Contact.AccountId);
                lstUser.add(eaUser);
                userMap.put(eaUser.Contact.AccountId, lstUser);                
            }
            else{
                userMap.put(eaUser.Contact.AccountId, new List<User>{eaUser});
            }
            userIdSet.add(eaUser.Id); 
        }
        
        for(Account_Affiliation__c eaAff: aafList){
            if(eaAff.FBE_End_Date__c < System.today() && eaAff.FBE_FPRM_isProcessed__c == true){
                //These are affiliations which have reached / crossed their End Dates, hence Users on Account can be unassociated from Affiliated Account
                endDatedAff.add(eaAff.FBE_Affilitated_Account__c);
                lstAffiliation.add(eaAff.Id);
            }
            
            if(eaAff.FBE_Start_Date__c <= System.today() && eaAff.FBE_FPRM_isProcessed__c == false && (eaAff.FBE_End_Date__c >= System.today() || eaAff.FBE_End_Date__c == null)){
              accountAffiliationList.add(eaAff);
            }
        }
        //List<Account_Affiliation__c> toBeCreatedAfflSharesList= [select FBE_Account__c from Account_Affiliation__c where FBE_Account__c In : affAccountIdSet AND FBE_Affilitated_Account__c IN : endDatedAff];
            Map<Id,List<Account_Affiliation__c>> AffMap = new Map<Id, List<Account_Affiliation__c>>();
            if(endDatedAff.size()>0)
            {
                for(Account_Affiliation__c affln : [select FBE_Account__c,FBE_Relationship__c,FBE_FPRM_isProcessed__c,FBE_Affilitated_Account__c,FBE_Start_Date__c,FBE_End_Date__c from Account_Affiliation__c where FBE_Account__c In : affAccountIdSet AND FBE_Affilitated_Account__c IN:endDatedAff])
                    {
                         if(AffMap.containsKey(affln.FBE_Account__c))
                         {
                            List<Account_Affiliation__c> lstAffl = AffMap.get(affln.FBE_Account__c);
                            lstAffl.add(affln);
                            AffMap.put(affln.FBE_Account__c, lstAffl);                
                         }
                        else{
                            AffMap.put(affln.FBE_Account__c, new List<Account_Affiliation__c>{affln});
                            system.debug('Affl Map:'+AffMap.keyset());
                        }
                        
                    }
                    for(Id affACtId : AffMap.keySet())
                    {
                        for(Account_Affiliation__c affln: AffMap.get(affACtId) )
                        {
                            system.debug(affln.FBE_Start_Date__c+'Before if:'+affln.FBE_End_Date__c);
                            if(affln.FBE_Start_Date__c <=System.Today() && (affln.FBE_End_Date__c== null || affln.FBE_End_Date__c >=System.Today())) 
                            {
                                 accountAffiliationList.add(affln);
                                system.debug('Fetch the Affl:'+accountAffiliationList);
                            }
                        }
                    } 
            }
                   
            
            
        System.debug('End Date Affiliations: '+endDatedAff);
        System.debug('Affiliations to be processed: '+accountAffiliationList);
        
        //Get List of Account Share Records to be deleted
        delAccShareList = [SELECT Id
                          FROM AccountShare
                          WHERE AccountId IN :endDatedAff
                          AND UserOrGroupId IN :userIdSet
                          AND RowCause = 'Manual'];
        
        if(!delAccShareList.isEmpty()){
            try{
                delete delAccShareList;
                System.debug('Successfully deleted affiliations data for: '+delAccShareList);
                
                //Reset isProcessed Flag once Affiliation Sharing records are deleted successfully.
                if(!lstAffiliation.isEmpty()){
                    List<Account_Affiliation__c> updAffList = new List<Account_Affiliation__c>();
                    for(Id eaRecord : lstAffiliation){
                        Account_Affiliation__c eaAff = new Account_Affiliation__c(
                            Id = eaRecord,
                            FBE_FPRM_isProcessed__c = false
                        );
                        updAffList.add(eaAff);
                    }
                    try{
                    update updAffList;    
                    }
                    catch(Exception e){
                        System.debug('FBE_FPRM_PartnerAccountAccessBatch : Error occured during Account-Affiliation Update: '+e);
                    }
                }
            }
            catch (Exception e){
                System.debug('FBE_FPRM_PartnerAccountAccessBatch : Exception occured in deleting the Account Share Records: '+e);
            }
        }
        
        if(!accountAffiliationList.isEmpty()){
            //system.debug('Invoke Method:');
            FBE_FPRM_ShareAccountWithPartnesHandler.shareAccountWithPartner(accountAffiliationList, userMap);
        }
        
      /*  for(Account_Affiliation__c aaf: aafList){
        //    if((aaf.FBE_Start_Date__c <= System.today() && aaf.FBE_FPRM_isProcessed__c == false)
        //      || (aaf.FBE_End_Date__c == System.today() && aaf.FBE_FPRM_isProcessed__c == true)) { 
                    
                    accoutAffiliationList.add(aaf);
                    lstAffiliation.add(aaf.FBE_Account__c);
                    affAccountIdSet.add(aaf.FBE_Affilitated_Account__c);      
            //}
        }
        
       List<User> userList =[SELECT Id,
                              ContactId,Contact.AccountId,
                              AccountId,
                              contact.FBE_FPRM_Reseller_Account__c 
                              FROM User 
                              WHERE AccountId IN:lstAffiliation];

        for(User user: userList){
            if(userMap.containsKey(user.AccountId)){
                List<User> lstUser = userMap.get(user.AccountId);
                lstUser.add(user);
                userMap.put(user.AccountId, lstUser);                
            }
            else{
                userMap.put(user.AccountId, new List<User>{user});
            }
            userIdSet.add(user.Id);         
        }

        accShareList = [SELECT Id,
                            AccountId,
                            AccountAccessLevel,
                            UserOrGroupId 
                            FROM AccountShare 
                            WHERE AccountId IN: affAccountIdSet 
                            AND UserOrGroupId IN: userIdSet]; 


        if(!accShareList.isEmpty()){
            try{
                delete accShareList;  
            }
            catch(dmlexception e){
            } 

        } 

        
        if(!accoutAffiliationList.isEmpty()){
            FBE_FPRM_ShareAccountWithPartnesHandler.shareAccountWithPartner(accoutAffiliationList, userMap);
        } */
    
    }
    global void finish(Database.BatchableContext BC) {
        
    }
    global void execute(SchedulableContext sc) {
        FBE_FPRM_PartnerAccountAccessBatch batch = new FBE_FPRM_PartnerAccountAccessBatch();
        Database.executeBatch(batch, 5);
       }
}