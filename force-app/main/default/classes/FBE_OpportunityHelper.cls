/*
 *@ Trigger Name      : FBE_OpportunityHelper  
 *@ Description       : This apex class created to handle Opportunity Account Team Sync. The method executed from the class 'FBE_TriggerHandler' & method 'syncOptyTeamMembers'.
                        
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 11-12-2019
 *@ Modification Log  : Created Under Opty Account Sync Code Optimization.                    
 */
public without sharing class FBE_OpportunityHelper {
    List<OpportunityTeamMember> optyTeamList = new List<OpportunityTeamMember>();    
    public  void Sync_Opportunity_Team_with_Account_Team(list<Opportunity> optyList,Set<Id> AccountId, String Operation){        
        List<AccountTeamMember> accntTeamList = new List<AccountTeamMember>();        
        accntTeamList = [Select Id,AccountId, OpportunityAccessLevel,TeamMemberRole,UserId from AccountTeamMember 
                         where AccountId IN: AccountId];
        //system.debug('optyList size'+optyList.Size()+'_accntTeamList_'+accntTeamList.Size());
        //system.debug('Operation'+Operation);
        if(Operation == 'Add'){
            addMember(optyList,accntTeamList);
        }
        else if(Operation == 'Delete'){
            Set<Id> OptyId = new Set<Id>();
            List <OpportunityTeamMember> optyTeamtoDelete = new List <OpportunityTeamMember>();
            for(Integer i=0, j= optyList.Size(); i < j; i++){
                OptyId.add(optyList[i].Id);
            }
            optyTeamtoDelete = [Select Id from OpportunityTeamMember 
                                where OpportunityId IN: OptyId AND FBE_Assigned_By_User__c = false];
            
            //system.debug('optyTeamtoDelete'+optyTeamtoDelete);
            try{
                    
                if(optyTeamtoDelete.size() > 0 ) 
                    delete optyTeamtoDelete;
            }catch (Exception ex){
                system.debug('Exception Occurred in Delete Step'+ex.getMessage());
            }         
            addMember(optyList,accntTeamList);
        }     
    }  
    
    public  void createOptyTeamMember(String tmRole, Id userId, Id optyId){
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.OpportunityAccessLevel = 'Edit';
        otm.TeamMemberRole = tmRole;
        otm.OpportunityId = optyId;
        otm.UserId = userId;
        otm.FBE_Assigned_By_User__c = False;
        optyTeamList.Add(otm); 
    }  
    
    public void addMember(list<Opportunity> optyList,List<AccountTeamMember> accntTeamList){
        for(Integer i=0, j= optyList.Size(); i < j; i++){
            for(Integer k=0, l= accntTeamList.Size(); k < l; k++){
                //system.debug('OptyAccntId'+optyList[i].AccountId+'AccntTeamAccntId'+accntTeamList[k].AccountId);
                if(optyList[i].AccountId != null && optyList[i].AccountId == accntTeamList[k].AccountId ){
                    createOptyTeamMember(accntTeamList[k].TeamMemberRole, accntTeamList[k].UserId, optyList[i].Id);
                }
                else if(optyList[i].FBE_End_User__c != null && optyList[i].FBE_End_User__c == accntTeamList[k].AccountId ){
                    createOptyTeamMember(accntTeamList[k].TeamMemberRole, accntTeamList[k].UserId, optyList[i].Id);
                }
                else if(optyList[i].FBE_FSI_Account__c != null && optyList[i].FBE_FSI_Account__c == accntTeamList[k].AccountId ){
                    createOptyTeamMember(accntTeamList[k].TeamMemberRole, accntTeamList[k].UserId, optyList[i].Id);
                }
                else if(optyList[i].FBE_VAR_Seller__c != null && optyList[i].FBE_VAR_Seller__c == accntTeamList[k].AccountId ){
                    createOptyTeamMember(accntTeamList[k].TeamMemberRole, accntTeamList[k].UserId, optyList[i].Id);
                }
                else if(optyList[i].FBE_Distributor__c != null && optyList[i].FBE_Distributor__c == accntTeamList[k].AccountId ){
                    createOptyTeamMember(accntTeamList[k].TeamMemberRole, accntTeamList[k].UserId, optyList[i].Id);
                }
                else if(optyList[i].FBE_Alliance_OEM_Provider__c != null && optyList[i].FBE_Alliance_OEM_Provider__c == accntTeamList[k].AccountId ){
                    createOptyTeamMember(accntTeamList[k].TeamMemberRole, accntTeamList[k].UserId, optyList[i].Id);
                }
            }  
        }
       // system.debug('optyTeamList'+optyTeamList.size());
        try{
            insert optyTeamList;
        }catch(Exception ex){
            system.debug('Exception Occurred'+ex.getMessage());
        }
    }    
}