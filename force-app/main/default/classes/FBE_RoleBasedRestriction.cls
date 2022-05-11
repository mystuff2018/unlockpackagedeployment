public class FBE_RoleBasedRestriction {
public static string taskRecordType = System.Label.Task_Support_Request_record_type;    
public static Id recTypeId = FBE_Utility.getSupportReqrecTypeId(taskRecordType);
    public static void FBE_TaskFieldRestrictionForProMgr(List<Task> newList,Map<ID,Task> oldMap){
        List<Task> ProposalTasks = new List<Task>();
        set<ID> oppIds = new set<ID>();
        Id userId = userinfo.getUserId();
        for(Task t : newList){
            if(t.WhatId != NULL && t.Type =='Proposal' && t.RecordTypeId == recTypeId && (t.FBE_Total_Contract_Value__c != oldMap.get(t.id).FBE_Total_Contract_Value__c || t.FBE_Date_of_RFx_Issue__c != oldMap.get(t.id).FBE_Date_of_RFx_Issue__c || t.FBE_Result__c != oldMap.get(t.id).FBE_Result__c  || t.FBE_Capture_Manager__c != oldMap.get(t.id).FBE_Capture_Manager__c)){
                oppIds.add(t.WhatId);
                ProposalTasks.add(t);       
            }
        }
        Map<ID,ID> oppWithAcc = new Map<ID,ID>();
		Map<ID,List<ID>> accIdWithUserOfPropMgr = new Map<ID,List<ID>>();
        if(oppIds.size() > 0){
            
            for(opportunity opp : [select id,AccountId from opportunity where ID in : oppIds]){
                oppWithAcc.put(opp.ID,opp.AccountId);
				accIdWithUserOfPropMgr.put(opp.AccountId, new List<ID>{ID.ValueOf(System.Label.FBE_Default_Task_Assigned_User)});
            }
        }
    
        if(oppWithAcc.values().size() > 0){
            
            for(AccountTeamMember accTeam : [select id,UserID,AccountId from accountTeamMember where TeamMemberRole = 'PROP_MGR' AND AccountId IN : oppWithAcc.values()]){
                if(accIdWithUserOfPropMgr.get(accTeam.AccountId) != NULL){
                    accIdWithUserOfPropMgr.get(accTeam.AccountId).add(accTeam.UserId);
				}
			}
            system.debug('accIdWithUserOfPropMgr '+accIdWithUserOfPropMgr);
            system.debug('oppWithAcc '+oppWithAcc);
            for(Task tsk : ProposalTasks){
                if(! accIdWithUserOfPropMgr.get(oppWithAcc.get(tsk.WhatId)).contains(UserInfo.getUserId())){
                    tsk.addError('Please contact the assigned Proposal Manager to edit this field.');
                }
            }
        }
    }
}