/**************
 *@ Class Name        : FBE_SyncTeamScheduler
 *@ Description       : This Apex class is a scheduled job to cascade AccountTeamMember object updates into FBE_AccountTeamMember__c custom object. This script has two parts : 1) As part of initial load (when FBE_AccountTeamMember__c
                        record count is 0) all AccountTeamMember records are copied in custom object. 2) In subsequent scheduled runs, only insertions/deletions are cascaded. 
                        During every run, Account with Team Member updates are maintained in a set which is passed to an Apex Class - FBE_SyncTeamHandler which syncs Account Teams to Related Opportunity Teams
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 01-02-2019
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script to copy AccountTeamMember modifications to FBE_AccountTeamMember__c object
                        Version 2.0 - 04/10/2019 - [Abhishek Kawle] : Updated script to trigger a batch class as part of Scheduled job that would run every hour. Batch Size is determined using a Custom Label - Sync_Team_Batch_Size.
                                                                      Production Hotfix Defect #6476772.
 ***************/
public without sharing class FBE_SyncTeamScheduler implements Schedulable {
    public void execute(SchedulableContext ctx) {
        Integer batchSize = Integer.valueOf(Label.Sync_Team_Batch_Size);
        
        //System.debug('Batch Size: '+batchSize);
        FBE_SyncTeamBatch obj = new FBE_SyncTeamBatch();
        obj.query = 'SELECT Id FROM Account';
        database.executeBatch(obj, batchSize);
    }
   /* global void execute(SchedulableContext ctx) {
        try{
            list<FBE_AccountTeamMember__c> accTeamCustomList = new list<FBE_AccountTeamMember__c>();
            list<FBE_AccountTeamMember__c> accTeamCustomListInsert = new list<FBE_AccountTeamMember__c>();
            list<FBE_AccountTeamMember__c> accTeamCustomListDelete = new list<FBE_AccountTeamMember__c>();
            Integer accntTeamCustomCount = [SELECT COUNT() FROM FBE_AccountTeamMember__c];
            List<AccountTeamMember> accTeamList = [SELECT Id, AccountAccessLevel, AccountId, TeamMemberRole, UserId FROM AccountTeamMember];
            Map<Id,List<AccountTeamMember>> accTeamMap = new Map<Id,List<AccountTeamMember>>();
            Map<Id,List<FBE_AccountTeamMember__c>> accTeamMapCustom = new Map<Id,List<FBE_AccountTeamMember__c>>();
            Set<Id> accIdSet = new Set<Id>();
            
            //Load all the Account Team Members from AccountTeamMember Object into a map of <Id, AccountTeamMember>
            for(AccountTeamMember accTeam : accTeamList){
                List<AccountTeamMember> memberList = accTeamMap.get(accTeam.Id);
                if(memberList == null){
                    memberList = new List<AccountTeamMember>();
                    memberList.add(accTeam);
                    accTeamMap.put(accTeam.Id, memberList);
                }
            }
            //System.debug('accTeamMap: ' +accTeamMap);
            
            if(accntTeamCustomCount == 0){
                for(AccountTeamMember accMem : accTeamList){
                    FBE_AccountTeamMember__c accMemCustom = new FBE_AccountTeamMember__c(FBE_Account_Team_Member_Id__c = accMem.Id,
                                                                                            FBE_Account_Access_Level__c = accMem.AccountAccessLevel,
                                                                                            FBE_Account_Id__c = accMem.AccountId,
                                                                                            FBE_Team_Member_Role__c = accMem.TeamMemberRole,
                                                                                            FBE_User_Id__c = accMem.UserId);
                    accTeamCustomList.add(accMemCustom);
                }
                //System.debug('AccTeamCustomList to be inserted: ' +accTeamCustomList);
                
                //insert into FBE_AccountTeamMember__c
                if(!accTeamCustomList.isEmpty()){
                    Database.SaveResult[] srList = Database.insert(accTeamCustomList, false);
                    
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
                accTeamCustomList = null;
            }
            
            else{
                accTeamCustomList = [SELECT Id,FBE_Account_Team_Member_Id__c, FBE_Account_Access_Level__c, FBE_Account_Id__c, FBE_Team_Member_Role__c, FBE_User_Id__c FROM FBE_AccountTeamMember__c];
                for(FBE_AccountTeamMember__c accMemCustom : accTeamCustomList){
                    List<FBE_AccountTeamMember__c> customMemberList = accTeamMapCustom.get(accMemCustom.FBE_Account_Team_Member_Id__c);
                    if(customMemberList == null){
                        customMemberList = new List<FBE_AccountTeamMember__c>();
                        customMemberList.add(accMemCustom);
                        accTeamMapCustom.put(accMemCustom.FBE_Account_Team_Member_Id__c,customMemberList);
                    }
                }
                //System.debug('accTeamMapCustom: ' +accTeamMapCustom);
                
                //Compare Two Maps and Add / Delete records from FBE_AccountTeamMember__c Object
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
                            accIdSet.add(accMem.AccountId);
                        }
                        //System.debug('Member would be added in Custom Obj: '+ accTeamCustomListInsert);
                    }
                }
                
                for(Id accTeamCustom : accTeamMapCustom.keySet()){
                    List<FBE_AccountTeamMember__c> accTeamListCustom_1 = accTeamMapCustom.get(accTeamCustom);             
                    if(!(accTeamMap.containsKey(accTeamCustom))){
                        //Logic to Delete Team Member from Custom Object
                        for(FBE_AccountTeamMember__c accMem: accTeamListCustom_1){
                            FBE_AccountTeamMember__c accMemCustom = new FBE_AccountTeamMember__c(Id = accMem.Id);
                            accTeamCustomListDelete.add(accMemCustom);
                            accIdSet.add(accMem.FBE_Account_Id__c);
                        }
                        //System.debug('Member would be Deleted from Custom Obj: '+ accTeamCustomListDelete);
                    }
                }
                //insert into FBE_AccountTeamMember__c
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
                //System.debug('Account Id Set: '+accIdSet);
            }
            
            if(!accIdSet.isEmpty()){
                FBE_SyncTeamHandler handler = new FBE_SyncTeamHandler();
                handler.syncAccountTeam(accIdSet);
                //System.debug('Invoke Handler');
            }   
        }
        
        catch(Exception e){
            System.debug('Error Occurred : ' +e.getMessage() + ' at line ' + e.getLineNumber().format());
        }        
    } */
}