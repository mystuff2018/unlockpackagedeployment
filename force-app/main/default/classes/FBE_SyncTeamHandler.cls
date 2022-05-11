/**************
 *@ Class Name        : FBE_SyncTeamHandler
 *@ Description       : This class is written to synchronize account team member updates to related Open Opportunity teams. 
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 12-18-2018
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script to insert team members from Account to Opportunity
                        Version 1.1 - [Abhishek Kawle] : Added script to delete team members from Opportunity which have been removed from related Accounts.
						Version 1.2 - [Abhishek Kawle] : 03/13/2020 - Added condition to by pass DFS Opportunity records from Team Sync. Feature #7498932
 ***************/
public with sharing class FBE_SyncTeamHandler {
     /*private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public FBE_SyncTeamHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    } */
    
      /**************
     * @MethodName    : syncAccountTeam
     * @Trigger       : -
     * @Description   : This method syncs account team member to related open opportunity team. 
     ***************/
    
    public void syncAccountTeam(set<Id> accIdSet){
        try{      
           // list<Account> updatedAccountList = [Select Id from Account where Id IN ('001r000000ASWrEAAX','001r0000009wVbyAAE')];
            set<id> setAccIds = new set<id>(accIdSet);
            list<Opportunity> relatedOppList = new list<Opportunity>();
            set<id> relatedOppIds = new set<id>();
            map<id,list<AccountTeamMember>> mapAccAccountTeamMember = new map<id,list<AccountTeamMember>>();
            map<id,list<OpportunityTeamMember>> mapOppOpportunityTM = new map<id,list<OpportunityTeamMember>>();
            map<id,list<Id>> mapAccountOpty = new map<id,list<Id>>();
            map<id,list<Id>> mapOptyAcc = new map<id,list<id>>();
            list<String> oppTeamList = new list<String>();
            set<id> relatedAccIds = new set<id>();
            map<id, list<AccountTeamMember>> optyAccTeamMemberMap = new map<id, list<AccountTeamMember>>();
            
           /* for(Account acc : updatedAccountList){
                setAccIds.add(acc.id);
            } */
            
            //System.debug('Account Set' + setAccIds);
            for(Account accObj : [SELECT id, (SELECT id, AccountId, UserId, TeamMemberRole FROM AccountTeamMembers) FROM Account where id IN: setAccIds]){
                mapAccAccountTeamMember.put(accObj.id,accObj.AccountTeamMembers);
            }
            
           // System.debug('Account Team Map' + mapAccAccountTeamMember);
           //Query all related Opportunities in which above account might be present as Account, End User, Sold To, OEM, SI, VAR, Distributor accounts
            for(Opportunity opp : [Select Id, AccountId, FBE_End_User__c, FBE_Alliance_OEM_Provider__c, FBE_Distributor__c, FBE_FSI_Account__c, FBE_VAR_Seller__c
                                   FROM Opportunity WHERE (StageName <> 'Lost - 0%' AND StageName <> 'Cancelled - 0%' AND StageName <> 'Won - 100%')
                                   	AND RecordType.DeveloperName <> 'DFS_Opportunity' 
                                    AND RecordType.DeveloperName <> 'BD_Capture_Team_Record_Type' 
                                    AND (AccountId IN: setAccIds 
                                    OR FBE_FSI_Account__c IN : setAccIds
                                    OR FBE_Alliance_OEM_Provider__c IN : setAccIds
                                    OR FBE_End_User__c IN : setAccIds
                                    OR FBE_VAR_Seller__c IN : setAccIds
                                    OR FBE_Distributor__c IN : setAccIds)]){
                                       relatedOppList.add(opp);
                                       relatedOppIds.add(opp.Id);
                                  }
           System.debug('Related Opty List ' + relatedOppList);
           //System.debug('Related Opty Set ' + relatedOppIds);
           
            //Create a map of Account Ids with related Opportunity Ids. This is used later in script to lookup only those Opportunities where team members must be inserted
            for(Id accObj : setAccIds ){
                //System.debug('Account Id' + accObj);
                list<Id> accRelatedOpty = new List<Id>();
                for(Opportunity oppObj : relatedOppList) {
                    //System.debug('opp List Element'+oppObj.Id +' ' + oppObj.AccountId); //Add code to split opptys based on account
                    if (oppObj.AccountId == accObj || oppObj.FBE_End_User__c == accObj || oppObj.FBE_FSI_Account__c == accObj || oppObj.FBE_Alliance_OEM_Provider__c == accObj || oppObj.FBE_VAR_Seller__c == accObj || oppObj.FBE_Distributor__c == accObj){
                        //System.debug('value found' + oppObj.Id + ' ' + accObj);
                        accRelatedOpty.add(oppObj.Id);
                        //System.debug('Related Opty List' + accRelatedOpty);
                    }
                }
                 if(!accRelatedOpty.isEmpty()){
                        mapAccountOpty.put(accObj,accRelatedOpty);
                        //System.debug('Map of Account Opty' + mapAccountOpty);
                    }                
            }
            
            //Store all Opportunity - related Accounts in a set. Set will store only unique records, these are used later to query Account Team Members. Creates a map of Opportunity Id and related Account Ids. This is used later in script to lookup only those Accounts while deleting team members from Opportunity
            for(Opportunity opp : relatedOppList){
                list<Id> optyRelAcc = new List<Id>();
                relatedAccIds.add(opp.AccountId);
                relatedAccIds.add(opp.FBE_End_User__c);
                relatedAccIds.add(opp.FBE_FSI_Account__c);
                relatedAccIds.add(opp.FBE_Alliance_OEM_Provider__c);
                relatedAccIds.add(opp.FBE_VAR_Seller__c);
                relatedAccIds.add(opp.FBE_Distributor__c);
                //System.debug('Set of Accounts' + relatedAccIds);
                
                optyRelAcc.add(opp.AccountId);
                optyRelAcc.add(opp.FBE_End_User__c);
                optyRelAcc.add(opp.FBE_FSI_Account__c);
                optyRelAcc.add(opp.FBE_Alliance_OEM_Provider__c);
                optyRelAcc.add(opp.FBE_VAR_Seller__c);
                optyRelAcc.add(opp.FBE_Distributor__c);
                mapOptyAcc.put(opp.Id, optyRelAcc);
                //System.debug('Opty Related Acc Map ' + mapOptyAcc); 
            }
                        
            //Create a Map of Account Team Members belonging to Opportunity - related Accounts
            for(Account accObj : [SELECT id, (SELECT id, AccountId, UserId, TeamMemberRole FROM AccountTeamMembers) FROM Account where id IN: relatedAccIds]){
                optyAccTeamMemberMap.put(accObj.id,accObj.AccountTeamMembers);
            }
            
            //Create a Map of Opportunity Team Members
            for(Opportunity oppObj : [Select Id, (Select Id, OpportunityId, UserId, TeamMemberRole, FBE_Assigned_By_User__c FROM OpportunityTeamMembers) FROM Opportunity where Id in : relatedOppIds]){
                mapOppOpportunityTM.put(oppObj.Id, oppObj.OpportunityTeamMembers);
            }
           // System.debug('Opty Team Map ' + mapOppOpportunityTM);
           
            //BEGIN - Insert Team Members to Opportunity script. 
            //For every account - loop over list of related Opportunity Team Members. If Account Team Member is not in Opportunity Team Members List - insert record
            list<OpportunityTeamMember> oppTeamMemberInsert = new list<OpportunityTeamMember>();
            for (Id accObj : mapAccountOpty.keySet()){
                List<AccountTeamMember> accTeamList = mapAccAccountTeamMember.get(accObj);
                List<Id> accOppList =  mapAccountOpty.get(accObj);
                //System.debug('AccTeamList '+ accTeamList);
                //System.debug('AccOptyList '+ accOppList);
                for(Id oppObj :accOppList){
                    Id oppId = oppObj;
                    list<OpportunityTeamMember> oppTeamList_1 = mapOppOpportunityTM.get(oppObj);
                    //System.debug('OpptyTeamList '+ oppTeamList_1);
                    list<String> optyUserId = new list<String>();
                        for(OpportunityTeamMember oppTeamMem : oppTeamList_1){
                            //System.debug('AccTeamList ' + accTeamList + ' Opp Team List ' + oppTeamList_1);
                            //oppId = oppTeamMem.OpportunityId;
                            optyUserId.add(oppTeamMem.UserId);
                            //System.debug('Oppty ID' + oppId + ' Oppty Member Id : '+oppTeamMem.UserId);
                        }
                        for(AccountTeamMember accMem : accTeamList){
                            String accMemUserId = accMem.UserId;
                            //System.debug('Opty User List ' +optyUserId);
                            if(!(optyUserId.contains(accMemUserId))){
                                //System.debug('Member not found in Opty');
                                OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId = oppId,
                                                                                     UserId = accMem.UserId,
                                                                                     TeamMemberRole = accMem.TeamMemberRole,
                                                                                     OpportunityAccessLevel = 'Edit',
                                                                                     FBE_Assigned_By_User__c = false);
                               oppTeamMemberInsert.add(otm);
                            }
                        }
                    optyUserId = null;
                }
            }
            //END - Insert Team Members to Opportunity script
            
            
            //BEGIN - Delete Team Members from Opportunity
            //For every Opportunity - loop over list of related Accounts. If Opportunity Team Member is no longer a part of Account Team Member - delete Opportunity Team Member  
            list<OpportunityTeamMember> oppTeamMemberDelete = new list<OpportunityTeamMember>();
            for(Id opp : mapOptyAcc.keySet()){
                list<OpportunityTeamMember> oppTeamList_2 = mapOppOpportunityTM.get(opp);
                list<Id> oppAccList = mapOptyAcc.get(opp);
                //System.debug('Opp List ' + opp + ' Opp Acc List ' + oppAccList);
                
                //System.debug('Opp '+oppTeamMem.OpportunityId + ' Team Member iD ' + oppTeamMem.UserId);
                list<String> accTeamUserId = new list<String>();
                for(Id accOpty : oppAccList){
                    list<AccountTeamMember> optyAccTeamList = optyAccTeamMemberMap.get(accOpty);
                    if(accOpty != null) {
                        for(AccountTeamMember accTeamMem : optyAccTeamList){
                            String accTeamMemberUserId = accTeamMem.UserId;
                            if(!(accTeamUserId.contains(accTeamMemberUserId))){
                                accTeamUserId.add(accTeamMem.UserId);                                
                            }
                        }
                    }
                }
                //System.debug('List of Account Team Members ' + accTeamUserId);
                for(OpportunityTeamMember oppTeamMem : oppTeamList_2){
                    String oppTeamMemUserId = null;
                    if(oppTeamMem.FBE_Assigned_By_User__c == false){ //Delete only users that were added by Integration user. Retain team members added manually from UI. Flag = false
                        oppTeamMemUserId = oppTeamMem.UserId;
                    }
                    if(oppTeamMemUserId != null) {
                        if(!(accTeamUserId.contains(oppTeamMemUserId))){
                            //System.debug('Opty ' +opp + ' does not have member ' +oppTeamMemUserId);
                            OpportunityTeamMember otm = new OpportunityTeamMember(Id = oppTeamMem.Id);
                            oppTeamMemberDelete.add(otm); 
                        }
                    }
                }
                accTeamUserId = null;
            }
            //END - Delete Team Members from Opportunity
            
            
            //INSERT - DELETE Opportunity Team Members using Database Methods with Partial Success
            System.debug('Opportunity Team Member to insert ' + oppTeamMemberInsert);
            if(!oppTeamMemberInsert.isEmpty()){
                //insert oppTeamMemberInsert;
                Database.SaveResult[] srList = Database.insert(oppTeamMemberInsert, false);
                
                for(Database.SaveResult sr : srList){
                    if(sr.isSuccess()){
                        System.debug('Successfully inserted Opportunity Team Member. Opportunity Team Member ID: ' + sr.getId());
                    }
                    else{
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            //System.debug('Opportunity fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }

            System.debug('Opportunity Team Member to Delete ' + oppTeamMemberDelete);
            if(!oppTeamMemberDelete.isEmpty()){
                //delete oppTeamMemberDelete;
                Database.DeleteResult[] drList = Database.delete(oppTeamMemberDelete, false);
                
                for(Database.DeleteResult dr : drList){
                    if(dr.isSuccess()){
                        System.debug('Successfully deleted Opportunity Team Member. Opportunity Team Member ID: ' + dr.getId());
                    }
                    else{
                        // Operation failed, so get all errors
                        for(Database.Error err : dr.getErrors()) {
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            //System.debug('Opportunity fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
            
            oppTeamMemberInsert = null;
            oppTeamMemberDelete = null;
        }
        catch(Exception e){
            System.debug('Error Occurred : ' +e.getMessage() + ' at line ' + e.getLineNumber().format());
        }
    }
}