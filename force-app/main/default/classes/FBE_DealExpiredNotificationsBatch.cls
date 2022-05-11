/**************
*@ Class Name                                                    : FBE_DealExpiredNotificationsBatch
*@ Description                                                   : This batch class runs as a nightly job which 
                                                                   retrives the List of UserIds present in all the Account Teams and 
                                                                   calls an FBE_DealRegEmailUtility Class for Sending Expiry Notifications. 
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 05-15-2020 [Rakesh Reddy Mula]
*@ Modification Log                                              : 09-09-2020 [Rakesh Reddy Mula] Moved Messaging.SendEmail to this class from FBE_DealRegEmailUtility
***************/

public with sharing class FBE_DealExpiredNotificationsBatch implements database.Batchable<sObject>,Database.Stateful{
    
    Date ExpiryDate10 = Date.Today().addDays(10);
    Date ExpiryDate30 = Date.Today().addDays(30);
    
    Map<ID,List<ID>> dealWithUserIds30Days = new Map<ID,List<ID>>();
    Map<ID,List<ID>> dealWithUserIds10Days = new Map<ID,List<ID>>();
    Map<ID,List<ID>> dealWithUserIdsAfterExp = new Map<ID,List<ID>>();
    Map<ID,Deal_Registration__c> dealRegMap = new Map<ID,Deal_Registration__c>();
    set<Id> allUserIds = new set<Id>();
    List<AccountTeamMember> allATMs = new List<AccountTeamMember>();
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT id,
                                         Name,
                                         FBE_Account__c,
                                         FBE_Distributor_Account__c,
                                         FBE_End_User_Account__c,
                                         FBE_FSI_Account__c,
                                         FBE_Reseller_VAR_Account__c,
                                         FBE_Related_Opportunity__c,
                                         FBE_Deal_Registration_Status__c,
                                         FBE_Expiration_Date__c,
                                         FBE_Deal_Reg_Num__c,
                                         Sales_Stage__c,
                                         FBE_Account__r.Name,
                                         FBE_Related_Opportunity__r.ownerid,
                                         FBE_Related_Opportunity__r.Name,
                                         FBE_Related_Opportunity__r.FBE_Opportunity_Number__c
                                         FROM Deal_Registration__c
                                         WHERE FBE_Deal_Registration_Status__c = 'Approved' AND
                                         FBE_Partner_Opportunity_Stage__c IN ('Plan - 1%', 'Discover - 10%','Qualify - 30%','Propose - 60%','Commit - 90%') AND
                                         (FBE_Expiration_Date__c =:ExpiryDate10 OR
                                          FBE_Expiration_Date__c =:ExpiryDate30 OR
                                          FBE_Expiration_Date__c = Today)]);
        
    }     
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('scope' +scope);
        if(Scope.size() > 0){
            Set<string> roles = new Set<string>();
            roles.addAll(system.label.FBE_EndUserAccountRoles.split(','));
            roles.addAll(system.label.FBE_FSIAccountRoles.split(','));
            roles.addAll(system.label.FBE_DistributorAccountRoles.split(','));
            roles.addAll(system.label.FBE_VARResellerAccountRoles.split(','));
            system.debug('roles from custom labels==>' +roles);
            Set<Id> accIds = new set<Id>();
            for(Deal_Registration__c dealRg : (List<Deal_Registration__c>)scope){
                accIds.add(dealRg.FBE_End_User_Account__c);
                accIds.add(dealRg.FBE_FSI_Account__c);
                accIds.add(dealRg.FBE_Reseller_VAR_Account__c);
                accIds.add(dealRg.FBE_Distributor_Account__c);
                dealRegMap.put(dealRg.ID,dealRg);             
            }
            system.debug('accIds===>' +accIds);
            system.debug('dealRegMap===>' +dealRegMap);
            if(accIds.size() > 0){
                Map<ID,List<AccountTeamMember>> accTeamMembers = new Map<ID,List<AccountTeamMember>>();
                for(AccountTeamMember accTeam : [select id,TeamMemberRole,userid,AccountId from accountteammember where AccountId IN : accIds AND TeamMemberRole in : roles]){
                    if(accTeamMembers.get(accTeam.AccountId) == NULL){
                        accTeamMembers.put(accTeam.AccountId,new List<AccountTeamMember>{accTeam});
                    }else{
                        accTeamMembers.get(accTeam.AccountId).add(accTeam);
                    }
                    system.debug('accTeam' +accTeam);
                }
                system.debug('accTeamMembers' +accTeamMembers);
                set<ID> userIdsToCheckDups = new set<ID>();
                for(Deal_Registration__c deal : dealRegMap.values()){
                    
                    if(deal.FBE_Expiration_Date__c == Date.Today().addDays(30)){
                        if(deal.FBE_Related_Opportunity__r.ownerid != NULL){
                            userIdsToCheckDups.add(deal.FBE_Related_Opportunity__r.ownerid);
                        }
                        dealWithUserIds30Days.put(deal.ID,new List<ID>());
                        if(accTeamMembers.get(deal.FBE_End_User_Account__c) != NULL){
                            for(AccountTeamMember accTeam : accTeamMembers.get(deal.FBE_End_User_Account__c)){
                                if(! userIdsToCheckDups.contains(accTeam.UserId) && system.label.FBE_EndUserAccountRoles.split(',').contains(accTeam.TeamMemberRole)){
                                    userIdsToCheckDups.add(accTeam.UserId);
                                }
                            }
                        }
                        
                        if(accTeamMembers.get(deal.FBE_FSI_Account__c) != NULL){
                            for(AccountTeamMember accTeam : accTeamMembers.get(deal.FBE_FSI_Account__c)){
                                if(! userIdsToCheckDups.contains(accTeam.UserId) && system.label.FBE_FSIAccountRoles.split(',').contains(accTeam.TeamMemberRole)){
                                    userIdsToCheckDups.add(accTeam.UserId);
                                }
                            }
                        }
                        if(accTeamMembers.get(deal.FBE_Reseller_VAR_Account__c) != NULL){
                            for(AccountTeamMember accTeam : accTeamMembers.get(deal.FBE_Reseller_VAR_Account__c)){
                                if(! userIdsToCheckDups.contains(accTeam.UserId) && system.label.FBE_VARResellerAccountRoles.split(',').contains(accTeam.TeamMemberRole)){
                                    userIdsToCheckDups.add(accTeam.UserId);
                                }
                            }
                        }
                        if(accTeamMembers.get(deal.FBE_Distributor_Account__c) != NULL){
                            for(AccountTeamMember accTeam : accTeamMembers.get(deal.FBE_Distributor_Account__c)){
                                if(! userIdsToCheckDups.contains(accTeam.UserId) && system.label.FBE_DistributorAccountRoles.split(',').contains(accTeam.TeamMemberRole)){
                                    userIdsToCheckDups.add(accTeam.UserId);
                                }
                            }
                        }
                        if(dealWithUserIds30Days.containsKey(deal.ID)){
                            dealWithUserIds30Days.get(deal.ID).addAll(userIdsToCheckDups);
                            userIdsToCheckDups.clear();
                        }
                    }else if(deal.FBE_Expiration_Date__c == Date.Today().addDays(10)){
                        if(deal.FBE_Related_Opportunity__r.ownerid != NULL){
                            userIdsToCheckDups.add(deal.FBE_Related_Opportunity__r.ownerid);
                        }
                        dealWithUserIds10Days.put(deal.ID,new List<ID>());
                        if(accTeamMembers.get(deal.FBE_End_User_Account__c) != NULL){
                            for(AccountTeamMember accTeam : accTeamMembers.get(deal.FBE_End_User_Account__c)){
                                if(! userIdsToCheckDups.contains(accTeam.UserId) && system.label.FBE_EndUserAccountRoles.split(',').contains(accTeam.TeamMemberRole)){
                                    userIdsToCheckDups.add(accTeam.UserId);
                                }
                            }
                        }
                        if(accTeamMembers.get(deal.FBE_FSI_Account__c) != NULL){
                            for(AccountTeamMember accTeam : accTeamMembers.get(deal.FBE_FSI_Account__c)){
                                if(! userIdsToCheckDups.contains(accTeam.UserId) && system.label.FBE_FSIAccountRoles.split(',').contains(accTeam.TeamMemberRole)){
                                    userIdsToCheckDups.add(accTeam.UserId);
                                }
                            }
                        }
                        if(accTeamMembers.get(deal.FBE_Reseller_VAR_Account__c) != NULL){
                            for(AccountTeamMember accTeam : accTeamMembers.get(deal.FBE_Reseller_VAR_Account__c)){
                                if(! userIdsToCheckDups.contains(accTeam.UserId) && system.label.FBE_VARResellerAccountRoles.split(',').contains(accTeam.TeamMemberRole)){
                                    userIdsToCheckDups.add(accTeam.UserId);
                                }
                            }
                        }
                        if(accTeamMembers.get(deal.FBE_Distributor_Account__c) != NULL){
                            for(AccountTeamMember accTeam : accTeamMembers.get(deal.FBE_Distributor_Account__c)){
                                if(! userIdsToCheckDups.contains(accTeam.UserId) && system.label.FBE_DistributorAccountRoles.split(',').contains(accTeam.TeamMemberRole)){
                                    userIdsToCheckDups.add(accTeam.UserId);
                                }
                            }
                        }
                        if(dealWithUserIds10Days.containsKey(deal.ID)){
                            dealWithUserIds10Days.get(deal.ID).addAll(userIdsToCheckDups);
                            userIdsToCheckDups.clear();
                        }
                    } else {
                        if(deal.FBE_Related_Opportunity__r.ownerid != NULL){
                            userIdsToCheckDups.add(deal.FBE_Related_Opportunity__r.ownerid);
                        }
                        dealWithUserIdsAfterExp.put(deal.ID,new List<ID>());
                        if(accTeamMembers.get(deal.FBE_End_User_Account__c) != NULL){
                            for(AccountTeamMember accTeam : accTeamMembers.get(deal.FBE_End_User_Account__c)){
                                if(! userIdsToCheckDups.contains(accTeam.UserId) && system.label.FBE_EndUserAccountRoles.split(',').contains(accTeam.TeamMemberRole)){
                                    userIdsToCheckDups.add(accTeam.UserId);
                                }
                            }
                        }
                        if(accTeamMembers.get(deal.FBE_FSI_Account__c) != NULL){
                            for(AccountTeamMember accTeam : accTeamMembers.get(deal.FBE_FSI_Account__c)){
                                if(! userIdsToCheckDups.contains(accTeam.UserId) && system.label.FBE_FSIAccountRoles.split(',').contains(accTeam.TeamMemberRole)){
                                    userIdsToCheckDups.add(accTeam.UserId);
                                }
                            }
                        }
                        if(accTeamMembers.get(deal.FBE_Reseller_VAR_Account__c) != NULL){
                            for(AccountTeamMember accTeam : accTeamMembers.get(deal.FBE_Reseller_VAR_Account__c)){
                                if(! userIdsToCheckDups.contains(accTeam.UserId) && system.label.FBE_VARResellerAccountRoles.split(',').contains(accTeam.TeamMemberRole)){
                                    userIdsToCheckDups.add(accTeam.UserId);
                                }
                            }
                        }
                        if(accTeamMembers.get(deal.FBE_Distributor_Account__c) != NULL){
                            for(AccountTeamMember accTeam : accTeamMembers.get(deal.FBE_Distributor_Account__c)){
                                if(! userIdsToCheckDups.contains(accTeam.UserId) && system.label.FBE_DistributorAccountRoles.split(',').contains(accTeam.TeamMemberRole)){
                                    userIdsToCheckDups.add(accTeam.UserId);
                                }
                            }
                        }
                        if(dealWithUserIdsAfterExp.containsKey(deal.ID)){
                            dealWithUserIdsAfterExp.get(deal.ID).addAll(userIdsToCheckDups);
                            userIdsToCheckDups.clear();
                        }
                    }
                }
            }
        }
    } 
    
    public void finish(Database.BatchableContext BC){
		if(!Test.isRunningTest()){
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address =:System.label.FBE_Approval_OWD  limit 1];
        for(ID dealId : dealRegMap.keySet()){
            if(dealWithUserIds30Days.containsKey(dealId)){
                message = FBE_DealRegEmailUtility.ThirtyDaysNotification(dealRegMap.get(dealId),dealWithUserIds30Days.get(dealId),owea.id);
                messages.add(message);
            }else if(dealWithUserIds10Days.containsKey(dealId)){
                message = FBE_DealRegEmailUtility.TenDaysNotification(dealRegMap.get(dealId),dealWithUserIds10Days.get(dealId),owea.id);
                messages.add(message);
            }else if(dealWithUserIdsAfterExp.containsKey(dealId)){
                message = FBE_DealRegEmailUtility.ExpiryNotification(dealRegMap.get(dealId),dealWithUserIdsAfterExp.get(dealId),owea.id);
                messages.add(message);
            }
        } 
        
         try {
            if(messages.size() > 0){
                system.debug('Messages Size ' +messages.size());
                Messaging.sendEmail(messages);
            }
            
        } catch(Exception e) {
            System.debug(e);
        }
		} 
	}
    
}