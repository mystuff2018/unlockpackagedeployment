/**************
 *@ Class Name        : FBE_SyncTeamComparator
 *@ Description       : This Apex class compares team member records between AccountTeamMember and FBE_AccountTeamMember__c object. It has two parts :
						1) Receive Account Id Set as part of Batch class execution and query Team Member records for these Accounts from AccountTeamMember and FBE_AccountTeamMember__c Object.
                        2) Compare the team member records and insert / delete the differentiating records from FBE_AccountTeamMember__c so that these two objects remain in sync. 
						Invoke a Handler class for any Accounts in which team member information has changed. Handler class will cascade team member info to related Open Opportunities.
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 04-09-2019
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script to compare team member records between AccountTeamMember and FBE_AccountTeamMember__c object.
***************/
public with sharing class FBE_SyncTeamComparator {
    public void compareTeamMembers(set <Id> accountIdSet){
        try{
        	set<Id> setAccIds = new set<id>(accountIdSet);
            list<FBE_AccountTeamMember__c> accTeamCustomList = new list<FBE_AccountTeamMember__c>();
            list<FBE_AccountTeamMember__c> accTeamCustomListInsert = new list<FBE_AccountTeamMember__c>();
            list<FBE_AccountTeamMember__c> accTeamCustomListDelete = new list<FBE_AccountTeamMember__c>();
            list<AccountTeamMember> accTeamList = new list<AccountTeamMember>();
            Map<Id,List<AccountTeamMember>> accTeamMap = new Map<Id,List<AccountTeamMember>>();
            Map<Id,List<FBE_AccountTeamMember__c>> accTeamMapCustom = new Map<Id,List<FBE_AccountTeamMember__c>>();
            Set<Id> accIdSyncSet = new Set<Id>();
            
          	//System.debug('Account Id Set Size - Comparator: '+setAccIds.size());
            //Query Account Team Members from AccountTeamMember object for Account Id Set received as part of Batch class. These are stored in a map accTeamMap
            accTeamList = [SELECT Id, AccountAccessLevel, AccountId, TeamMemberRole, UserId
                           FROM AccountTeamMember
                           WHERE AccountId IN: setAccIds];
            
          	//System.debug('AccTeamList: ' + accTeamList);
            
            //Query Account Team Members from FBE_AccountTeamMember__c object for Account Id Set received as part of Batch class. These are stored in a map accTeamMapCustom
            accTeamCustomList = [SELECT Id,FBE_Account_Team_Member_Id__c, FBE_Account_Access_Level__c, FBE_Account_Id__c, FBE_Team_Member_Role__c, FBE_User_Id__c
                                 FROM FBE_AccountTeamMember__c
                                 WHERE FBE_Account_Id__c IN: setAccIds];
            
           //System.debug('AccTeamCustomList: ' + accTeamCustomList);
            
            for(AccountTeamMember accTeam : accTeamList){
                List<AccountTeamMember> memberList = accTeamMap.get(accTeam.Id);
                if(memberList == null){
                    memberList = new List<AccountTeamMember>();
                    memberList.add(accTeam);
                    accTeamMap.put(accTeam.Id, memberList);
                }
            }
            
            for(FBE_AccountTeamMember__c accMemCustom : accTeamCustomList){
                List<FBE_AccountTeamMember__c> customMemberList = accTeamMapCustom.get(accMemCustom.FBE_Account_Team_Member_Id__c);
                if(customMemberList == null){
                    customMemberList = new List<FBE_AccountTeamMember__c>();
                    customMemberList.add(accMemCustom);
                    accTeamMapCustom.put(accMemCustom.FBE_Account_Team_Member_Id__c,customMemberList);
                }
            }
            
            //Compare Two Maps (accTeamMap, accTeamMapCustom) and Add / Delete records from FBE_AccountTeamMember__c Object
            for(Id accTeam : accTeamMap.keySet()){
                List<AccountTeamMember> accTeamList_1 = accTeamMap.get(accTeam);
                //System.debug('accTeamList_1 : ' + accTeamList_1);
                //System.debug('Acc Team Member: '+accTeam+ ' exists in custom map: '+accTeamMapCustom.containsKey(accTeam));
                if(!(accTeamMapCustom.containsKey(accTeam))){
                    //Logic to add Team Member into custom object
                    for(AccountTeamMember accMem : accTeamList_1){
                        FBE_AccountTeamMember__c accMemCustom = new FBE_AccountTeamMember__c(FBE_Account_Team_Member_Id__c = accMem.Id,
                                                                                             FBE_Account_Access_Level__c = accMem.AccountAccessLevel,
                                                                                             FBE_Account_Id__c = accMem.AccountId,
                                                                                             FBE_Team_Member_Role__c = accMem.TeamMemberRole,
                                                                                             FBE_User_Id__c = accMem.UserId);
                        accTeamCustomListInsert.add(accMemCustom);
                        accIdSyncSet.add(accMem.AccountId);
                    }
                  //  System.debug('Member would be added in Custom Obj: '+ accTeamCustomListInsert);
                }
            }
            
            for(Id accTeamCustom : accTeamMapCustom.keySet()){
                List<FBE_AccountTeamMember__c> accTeamListCustom_1 = accTeamMapCustom.get(accTeamCustom);             
                if(!(accTeamMap.containsKey(accTeamCustom))){
                    //Logic to Delete Team Member from Custom Object
                    for(FBE_AccountTeamMember__c accMem: accTeamListCustom_1){
                        FBE_AccountTeamMember__c accMemCustom = new FBE_AccountTeamMember__c(Id = accMem.Id);
                        accTeamCustomListDelete.add(accMemCustom);
                        accIdSyncSet.add(accMem.FBE_Account_Id__c);
                    }
                  //  System.debug('Member would be Deleted from Custom Obj: '+ accTeamCustomListDelete);
                }
            }
            
            //Insert into FBE_AccountTeamMember__c
            if(!accTeamCustomListInsert.isEmpty()){
                Database.SaveResult[] srList = Database.insert(accTeamCustomListInsert, false);
                
                for(Database.SaveResult sr : srList){
                    if(sr.isSuccess()){
                        System.debug('Successfully inserted Account Team Member in Custom Object. Team Member ID: ' + sr.getId());
                    }
                    else{
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
            }
            
            //Delete from FBE_AccountTeamMember__c
            if(!accTeamCustomListDelete.isEmpty()){
                //delete accTeamCustomListDelete;
                Database.DeleteResult[] drList = Database.delete(accTeamCustomListDelete, false);
                
                for(Database.DeleteResult dr : drList){
                    if(dr.isSuccess()){
                        System.debug('Successfully deleted Account Team Member from Custom Object. Team Member ID: ' + dr.getId());
                    }
                    else{
                        // Operation failed, so get all errors
                        for(Database.Error err : dr.getErrors()) {
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            //System.debug('FBE_AccountTeamMember__c fields that affected this error: ' + err.getFields());
                        }
                    } 
                }
            }
            accTeamCustomListInsert = null;
            accTeamCustomListDelete = null;
           // System.debug('Account Id Set: '+accIdSyncSet);
            
            if(!accIdSyncSet.isEmpty()){
                FBE_SyncTeamHandler handler = new FBE_SyncTeamHandler();
                handler.syncAccountTeam(accIdSyncSet);
                // System.debug('Invoke Handler');
                // Sync Deal Reg Teams - Handler
                FBE_SyncAccountToDealRegTeams dealHandler = new FBE_SyncAccountToDealRegTeams();
                dealHandler.syncDealRegTeams(accIdSyncSet);
                
               
            } 
        }
        
        catch(Exception e){
            System.debug('Error Occurred : ' +e.getMessage() + ' at line ' + e.getLineNumber().format());
        }
    }
}