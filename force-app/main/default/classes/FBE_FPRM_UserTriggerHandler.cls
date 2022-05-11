/**************
* @ Class Name        : FBE_FPRM_UserTriggerHandler
* @ Description       : This class is created to automatically share Account record with Partner Users based on different criterias 
*                       Created as part of Feature #9912110.
* @ CreatedBy         : Deloitte
* @ Modification Log  : Version 1.0 - [Namrata] : 
*   ==================================================================================  
Modfications :
Purpose : Nullify the account in contact and update it with resellar Account on User Deactivation
Transfer Deals and opties to transfered User.
Date    : 24-05-2021
Author  : Soumiithri Rekha
Company : Dell Technologies
=================================================================================== 
*********/
public class FBE_FPRM_UserTriggerHandler {
    @future
    public static void shareRelatedDistributorAccountWithPartner(  List<Id> lstUser){
        List<AccountShare> toShareAccount = new List<AccountShare>();
        List<Account_Affiliation__c> affiliatioIdList = new List<Account_Affiliation__c>();
        Map<Id, Account_Affiliation__c> updateAffiliationIdsList = new Map<Id, Account_Affiliation__c>();
        Map<Id, List<Account_Affiliation__c>> affiliationMap = new Map<Id, List<Account_Affiliation__c>>();       
        List<Id> lstAccountId = new List<Id>();
        List<Id> lstDistributorAccountId = new List<Id>();
        Map<Id, List<User>> userMap = new Map<Id, List<User>>();
        List<User> lstUser2 = new List<User>();
        //List<User> lstUser3 = new List<User>();
        lstUser2 = [SELECT Id,AccountId,ContactId,Contact.FBE_FPRM_Reseller_Account__c,Account.name FROM User WHERE Contact.FBE_FPRM_Reseller_Account__c = null AND Id IN: lstUser];
        
        for(User user: lstUser2){
            lstAccountId.add(user.AccountId );
            if(userMap.containsKey(user.AccountId)){
                List<User> userList = userMap.get(user.AccountId);
                userList.add(user);
                userMap.put(user.AccountId, userList);    
            }
            else{
                userMap.put(user.AccountId, new List<User> {user}); 
            }
        }
        
        List< Account_Affiliation__c> affiliatioList = new List< Account_Affiliation__c>([SELECT Id,
                                                                                          FBE_Account__c,
                                                                                          FBE_Affilitated_Account__c,
                                                                                          FBE_Relationship__c,
                                                                                          FBE_Account__r.FBE_Partner_Type__c,
                                                                                          FBE_Start_Date__c,
                                                                                          FBE_End_Date__c,
                                                                                          FBE_FPRM_isProcessed__c
                                                                                          FROM Account_Affiliation__c 
                                                                                          WHERE FBE_Account__c IN: lstAccountId
                                                                                          AND FBE_Start_Date__c <= Today
                                                                                          AND (FBE_End_Date__c >= Today OR FBE_End_Date__c = null) ]);
        if(!affiliatioList.isEmpty()){
            for(Account_Affiliation__c aff: affiliatioList){
                if(affiliationMap.containsKey(aff.FBE_Account__c)){
                    List<Account_Affiliation__c> aafList = affiliationMap.get(aff.FBE_Account__c);
                    aafList.add(aff);
                    affiliationMap.put(aff.FBE_Account__c, aafList);               
                }
                else{
                    affiliationMap.put(aff.FBE_Account__c, new List <Account_Affiliation__c> {aff});
                }
            }
            
        }
        
        if(!affiliationMap.isEmpty() && !lstUser2.isEmpty()){
            for(User user: lstUser2){
                if(affiliationMap.get(user.AccountId) != null){
                    for(Account_Affiliation__c aff: affiliationMap.get(user.AccountId)){ 
                        //if(user.AccountId == aff.FBE_Account__c && user.Contact.FBE_FPRM_Reseller_Account__c == null && aff.FBE_Account__r.FBE_Partner_Type__c == System.Label.FBE_FPRM_Distributor ){}
                        if(user.AccountId == aff.FBE_Account__c && aff.FBE_Relationship__c ==System.Label.FBE_FPRM_Disty_Managed){
                            AccountShare accShare = new AccountShare();
                            accShare.AccountId = aff.FBE_Affilitated_Account__c;
                            accShare.UserOrGroupId = user.Id;
                            accShare.AccountAccessLevel = 'Edit';
                            accShare.OpportunityAccessLevel='None';
                            toShareAccount.add(accShare);         
                        } 
                        
                        // add reseller null check
                        //else if(user.AccountId == aff.FBE_Account__c && aff.FBE_Relationship__c ==System.Label.FBE_FPRM_Distributor && aff.FBE_Account__r.FBE_Partner_Type__c == System.Label.FBE_FPRM_Reseller && user.Contact.FBE_FPRM_Reseller_Account__c == null){} 
                        else if(user.AccountId == aff.FBE_Account__c && (aff.FBE_Relationship__c ==System.Label.FBE_FPRM_Distributor || aff.FBE_Relationship__c ==System.Label.FBE_FPRM_Reseller)){     
                            AccountShare accShare = new AccountShare();
                            accShare.AccountId = aff.FBE_Affilitated_Account__c;
                            accShare.UserOrGroupId = user.Id;
                            accShare.AccountAccessLevel = 'Read';
                            accShare.OpportunityAccessLevel='None';
                            toShareAccount.add(accShare);  
                            lstDistributorAccountId.add(aff.FBE_Affilitated_Account__c);
                        }
                    } 
                }
            }
            /*lstUser3 = [SELECT Id,AccountId,ContactId,Contact.FBE_FPRM_Reseller_Account__c,Account.name FROM User WHERE AccountId IN: lstDistributorAccountId];

for( List<Account_Affiliation__c> affList: affiliationMap.values() ){
for(Account_Affiliation__c aff2 : affList){
if(aff2.FBE_Relationship__c ==System.Label.FBE_FPRM_Distributor && aff2.FBE_Account__r.FBE_Partner_Type__c == System.Label.FBE_FPRM_Reseller){
for(User user2: lstUser3){
AccountShare accShare3 = new AccountShare();
accShare3.AccountId = aff2.FBE_Account__c;
accShare3.UserOrGroupId = user2.Id;
accShare3.AccountAccessLevel = 'Read';
toShareAccount.add(accShare3);                            
}                        
}
}
}*/
        } 
        
        
        if(toShareAccount.size()>0 && toShareAccount != null){
            
            Set<Id> successIds = new Set<Id>();
            Database.SaveResult[] result = Database.insert(toShareAccount, false);
            for (Database.SaveResult sr : result) {
                if (sr.isSuccess()) {
                    successIds.add(sr.getId());
                    System.debug('sr===='+sr);
                }
            }
            if(!successIds.isEmpty()){
                Set<Id> affilatedId = new Set<Id>();
                List<AccountShare> accShareList = [SELECT Id,AccountId,UserOrGroupId FROM AccountShare WHERE ID IN:successIds ];
                for(AccountShare accShare: accShareList){
                    affilatedId.add(accShare.AccountId);
                }
                List<Account_Affiliation__c> aafList = [SELECT Id,FBE_FPRM_isProcessed__c,FBE_Affilitated_Account__c,FBE_Account__c FROM Account_Affiliation__c WHERE FBE_Affilitated_Account__c IN: affilatedId];
                for(Account_Affiliation__c aaf: aafList){ 
                    if(userMap.get(aaf.FBE_Account__c) != null){
                        for( User user: userMap.get(aaf.FBE_Account__c)){ 
                            if(user.AccountId == aaf.FBE_Account__c ){
                                aaf.FBE_FPRM_isProcessed__c = true;
                                updateAffiliationIdsList.put(aaf.Id, aaf);
                            }
                            
                        } 
                    }
                }         
            }
        }
        
        if(!updateAffiliationIdsList.isEmpty()){
            update updateAffiliationIdsList.values();
        }
    }
    //Nullify the account in contact and update it with resellar Account on User Deactivation
    @future
    public static void UpdateContactInfo(  List<id> lstUser,String jsonOldUserMap){
        List<User> lstNewUser = [Select Id,IsActive,Username,Name,Profile.Name,FBE_FPRM_Contact_Reseller_Account__c,ContactId,Contact.AccountId,contact.FBE_FPRM_Reseller_Account__c
                                 From User where Id IN : lstUser];
        User u = [Select id from user where name = 'Boomi Prod IntUser Boomi Prod IntUser'];
        Map<Id,user> oldUserMap = (Map<Id,user>)System.JSON.deserialize(jsonOldUserMap, Map<Id,user>.class);
        system.debug('lstNewUser'+lstNewUser);
        List<contact> lstContact = new List<contact>();
        for(User listU : lstNewUser){
            User oldUser = oldUserMap.get(listU.Id);
            if(oldUser.FBE_FPRM_Contact_Reseller_Account__c != null && oldUser.FBE_FPRM_Contact_Reseller_Account__c != ''){
                system.debug('olduser'+ oldUser.FBE_FPRM_Contact_Reseller_Account__c + 'contact'+ oldUser.ContactId);
                Contact con = new Contact(Id = oldUser.ContactId,AccountId = oldUser.FBE_FPRM_Contact_Reseller_Account__c,
                                          FBE_FPRM_Reseller_Account__c = null,ownerid=u.Id);
                lstContact.add(con);
            }
        }
        system.debug('lstContact'+lstContact);
        if(!lstContact.isEmpty()){
            update lstContact; 
        }  
    }
    //Transfer Deals and opties to transfered User.
    @future
    public static void updateDealRegDetailsonUserInsert(  String newList){
        
        
        System.debug('updateDealRegDetailsonUserInsert');
        //Map<String,Id> inactiveUserMap = new Map<String,Id>();
        List<Id> inactiveUserIds = new List<Id>();
        List<String> inactiveUserEmails = new List<String>();
        Map<String,Id> activeUserMap = new Map<String,Id>();
        List<User> lstUser = (List<User>) JSON.deserialize(newList, List<User>.class);
        List<String> userEmails = new List<String>();
        for(User u : lstUser){
            System.debug('user: '+u);
            userEmails.add(u.Email);
        }
        List<Deal_Registration__c> updList = new List<Deal_Registration__c>();
        byPassValidation(true);
        for(User u : [SELECT Id,IsActive,FirstName,LastName,Username,email,Name,Profile.Name,FBE_FPRM_Contact_Reseller_Account__c,ContactId,Contact.AccountId,contact.FBE_FPRM_Reseller_Account__c From User WHERE Email IN : userEmails]){
            System.debug('for user : '+u);
            if(u.isActive == false){
                //inactiveUserMap.put(u.Email, u.Id);
                inactiveUserIds.add(u.Id);
                inactiveUserEmails.add(u.email);
            }else{
                activeUserMap.put(u.Email, u.Id);
            }
        }
        System.debug('inactiveUserIds: '+ inactiveUserIds);
        System.debug('activeUserMap: '+ activeUserMap);
        for(Deal_Registration__c deal : [SELECT id,FBE_FPRM_Partner_Owner__c,FBE_Partner_Owner_Email__c,FBE_FPRM_Partner_Sales_Rep__c, FBE_Partner_Sales_Rep_Email__c,FBE_Deal_Registration_Status__c,FBE_Partner_Opportunity_Stage__c 
                                         FROM Deal_Registration__c WHERE (FBE_Partner_Sales_Rep_Email__c IN : inactiveUserEmails or FBE_Partner_Owner_Email__c in: inactiveUserEmails)
                                         AND FBE_Deal_Registration_Status__c IN ('New','Submitted','Approved','Hold for Review')]){
            system.debug('deal reg: '+ deal);
            if(deal.FBE_Partner_Opportunity_Stage__c != 'Cancelled - 0%' && deal.FBE_Partner_Opportunity_Stage__c !='Lost - 0%' && deal.FBE_Partner_Opportunity_Stage__c !='Won - 100%'){
                 if(activeUserMap.containsKey(deal.FBE_Partner_Owner_Email__c)){
                System.debug('in FBE_Partner_Owner_Email__c');
                deal.FBE_FPRM_Partner_Owner__c = activeUserMap.get(deal.FBE_Partner_Owner_Email__c);
            }
            if(activeUserMap.containsKey(deal.FBE_Partner_Sales_Rep_Email__c)){
                System.debug('in FBE_Partner_Sales_Rep_Email__c');
                deal.FBE_FPRM_Partner_Sales_Rep__c = activeUserMap.get(deal.FBE_Partner_Sales_Rep_Email__c);
            } 
            updList.add(deal);                                 
            }
        }
        System.debug('updList: '+ updList);
        try{
            if(updList.size()> 0){
                List<Database.SaveResult> result = Database.update(updList ,false);
                System.debug('saveResult: '+ result);
            }
            byPassValidation(false);
        }catch(Exception e){
            byPassValidation(false);
            System.debug('Exception in updateDealRegDetailsonUserInsert : '+ e);
        }
        
    }
    
    private static void byPassValidation(Boolean isBypass){
        //system.debug('==byPassValidation is called==');
        FBE_FPRM_Transfer_Deal_Check__c csTD = FBE_FPRM_Transfer_Deal_Check__c.getInstance(UserInfo.getProfileId());
        csTD.Is_Transfer_Deal__c = isBypass; 
        update csTD; 
    }
    
    @future
    Public static void UpdatecasesonUserInsert(String newUserList){
       
    List<Id> contIds = new List<Id>();
    List<Case> cases_with_NewDisty = new List<Case>();
    list<case> caselst = new list<case>();
    Map<Id,Id> map_NewDistyIds = new Map<Id,Id>();
    Map<Id,Id> conUserMap = new Map<Id,Id>();
    Map<Id,Set<Id>> userCasesMap = new Map<Id,Set<Id>>();    

    String profileId =[Select Id,Name from Profile where Name = 'FBE FPRM Partner Disty Managed'].Id;
     List<User> lstUser = (List<User>) JSON.deserialize(newUserList, List<User>.class);
       //system.debug('lstUser#####'+lstUser.size());
       // system.debug('lstUser#####'+lstUser[0].ContactId + 'profile name#####'+lstUser[0].ProfileId + 'Reseller####'+lstUser[0].FBE_FPRM_Contact_Reseller_Account__c);
        for(User user : lstUser){
           if(user.ContactId != null && user.ProfileId == profileId && String.isNotBlank(user.FBE_FPRM_Contact_Reseller_Account__c)) {
                    contIds.add(user.contactId);
                    conUserMap.put(user.contactId,user.Id); 
                }
        }            
        if(contIds.size()>0){
            list<contact> parentcons = [SELECT id,AccountId,(SELECT id,ContactId,AccountId,FBE_Assign_using_active_assignment_rules__c from Cases) from contact where id =:contIds];
            if(parentcons.size()>0){  
                for(contact con: parentcons){
                    map_NewDistyIds.put(con.Id,con.AccountId);
                    if(con.cases.size()>0){
                        for(case cs : con.cases){
                            if(cs.id != null){
                                caselst.add(cs);
                            }
                        }
                    }   
                }
            } 
        }   
           system.debug('caselst size ######'+caselst.size());     
             if(caselst.size() > 0){       
                    for(case cs: caselst){
                         if(map_NewDistyIds.containskey(cs.ContactId)){
                            cs.AccountId = map_NewDistyIds.get(cs.ContactId);
                             cs.FBE_Assign_using_active_assignment_rules__c = false;
                            cases_with_NewDisty.add(cs);
                        }   
                        if(conUserMap.containsKey(cs.ContactId)){
                             if(userCasesMap.containsKey(conUserMap.get(cs.ContactId))){
                                Set<Id> caseIdSet = userCasesMap.get(conUserMap.get(cs.ContactId));
                                caseIdSet.add(cs.Id);
                                userCasesMap.put(conUserMap.get(cs.ContactId), caseIdSet);
                             }                                                 
                             else{
                                 userCasesMap.put(conUserMap.get(cs.ContactId), new Set<Id>{cs.Id});
                             }
                        }
                    }
                }     
              
         system.debug('casesSize######'+cases_with_NewDisty.size());   
           system.debug('cases_with_NewDisty######'+cases_with_NewDisty);   
            if(cases_with_NewDisty.size()>0){
                skipValidation(true);
                List<Database.SaveResult> results = Database.update(cases_with_NewDisty,false);
                system.debug('results######' + results);
                skipValidation(false);
                //update cases_with_NewDisty;
                for (Database.SaveResult result : results) {
                    if (result.isSuccess()) {
                        //Successfully updated
                        system.debug('Cases Successfully updated, Case Id is: ' + result.getId());
                    }
                else {
                    //Error ecountered              
                    for(Database.Error error : result.getErrors()) {
                        //Handle error
                         System.debug(error.getStatusCode() + ': ' + error.getMessage() + 
                                      ' Fields that affected the error: ' + error.getFields());

                        }
                    }
                }
                logResults(results, userCasesMap); 
            }   
    }
    // To skip the Validations on cases while updating the Account
    private static void skipValidation(Boolean isBypass){
        system.debug('==byPassValidation is called==');
        FBE_FPRM_Update_Child_Cases__c csUpdtcases = [SELECT Name,Is_Disty_Account__c FROM FBE_FPRM_Update_Child_Cases__c LIMIT 1];
        csUpdtcases.Is_Disty_Account__c = isBypass; 
        upsert csUpdtcases; 
    }
    
    private static void logResults(List<Database.SaveResult> results, Map<Id,Set<Id>> userCasesMap){
        Map<Id,String> successCasesMap = new Map<Id,String>();
        Map<Id,String> failedCasesMap = new Map<Id,String>();
        for(Integer i=0; i<results.size(); i++){
            if (results.get(i).isSuccess()){
                successCasesMap.put(results.get(i).Id , results.get(i).Id + ', ');
            }else if (!results.get(i).isSuccess()){
                Database.Error error = results.get(i).getErrors().get(0);
                String errMsg = error.getMessage();
                failedCasesMap.put(results.get(i).Id, results.get(i).Id + ': {Message: '+ errMsg + '}'+ ' \n');
            }
        } 
        List<FBE_Configurator__c> insertConfigList = new List<FBE_Configurator__c>();
        FBE_Configurator__c caseConfig;
        for(Id userId : userCasesMap.keySet()){
            Set<Id> casesSet = userCasesMap.get(userId);
            String successIds = 'Cases : '; 
            String failureIds = 'Case Failures : ';
            for(Id caseId : casesSet){
                if(!successCasesMap.isEmpty() && failedCasesMap.isEmpty()){     
                    if(successCasesMap.containsKey(caseId)){
                        successIds += successCasesMap.get(caseId);
                    }
                    caseConfig = createConfigurator('Completed',successIds,'0',userId);                                    
                } else if(successCasesMap.isEmpty() && !failedCasesMap.isEmpty()){                
                    if(failedCasesMap.containsKey(caseId)){
                        failureIds += failedCasesMap.get(caseId);
                    }                   
                    caseConfig = createConfigurator('Error','0',failureIds,userId);                                             
                } else if(!successCasesMap.isEmpty() && !failedCasesMap.isEmpty()){               
                    if(successCasesMap.containsKey(caseId)){
                        successIds += successCasesMap.get(caseId);
                    }
                    if(failedCasesMap.containsKey(caseId)){                                                  
                        failureIds += failedCasesMap.get(caseId);
                    }
                    caseConfig = createConfigurator('Completed with Errors',successIds,failureIds,userId);                 
                } else if(successCasesMap.isEmpty() && failedCasesMap.isEmpty()){
                    caseConfig = createConfigurator('Completed','0','0',null);                
                }               
            }
            insertConfigList.add(caseConfig);
        }
        if(insertConfigList.size() > 0){
            Insert insertConfigList;
        }            
    }

    private static FBE_Configurator__c createConfigurator(String transferStatus, String successDeals, String failureDeals, Id userId){
        Id configRecTypeId = Schema.getGlobalDescribe().get('FBE_Configurator__c').getDescribe().getRecordTypeInfosByName().get('Disty Transfer Logs').getRecordTypeId();
        FBE_Configurator__c caseConfig = new FBE_Configurator__c();
        caseConfig.recordtypeId = configRecTypeId;
        caseConfig.Transfer_Status__c = transferStatus;
        caseConfig.Success_Deals__c = successDeals;
        caseConfig.Name = 'Case Transfer Log : ' + userId;                    
        caseConfig.Failure_Deals__c = failureDeals;
        return caseConfig;
    }
}