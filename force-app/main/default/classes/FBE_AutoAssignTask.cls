/**************
*@ Class Name                                                    : FBE_AutoAssignTask
*@ Description                                                   : This class Auto Assigns Proposal Tasks to Proposal Manager present in the related Account Teams of the opportunity. 
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 03-23-2020 [Rakesh Reddy Mula]
*@ Modification Log                                              : 
***************/
public class FBE_AutoAssignTask {
    
    public static string taskRecordType = System.Label.Task_Support_Request_record_type;
    public static string statusAssigned = System.Label.taskStatus_Assigned;
    public static Id recTypeId = FBE_Utility.getSupportReqrecTypeId(taskRecordType);
    public static String opp_prefix = Schema.SObjectType.Opportunity.getKeyPrefix();
    
    public static void AssignProposalManager(List<Task> taskListfromTrigger){ 
        set<Id> oppIds = new set<Id>();
        List<Task> ProposalTasks = new List<Task>();
        for(Task t : taskListfromTrigger){
            if(t.WhatId != NULL && t.Type=='Proposal' && (t.RecordTypeId == recTypeId) && string.valueOf(t.WhatId).startsWith(opp_prefix)){
                oppIds.add(t.WhatId);
                ProposalTasks.add(t);       
            }
        }
        Map<ID,ID> accIdwithOpptyIds;
        Map<ID,ID> opptyWithUser;
        if(oppIds.size() > 0 && ProposalTasks.size() > 0){
            accIdwithOpptyIds = new Map<ID,ID>();
            for(opportunity opp : [select id,accountid from opportunity where ID IN : oppIds]){
                accIdwithOpptyIds.put(opp.id,opp.accountid);
                system.debug('accIdwithOpptyIds==> '+accIdwithOpptyIds);
            }
        }
        if(oppIds.size() > 0 && ! accIdwithOpptyIds.isEmpty()){
            Map<ID,ID> accTeamMemWithUserId = new Map<ID,ID>();
            for(AccountTeamMember accountTeamMemberList : [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember WHERE TeamMemberRole = 'PROP_MGR' AND AccountId IN :accIdwithOpptyIds.values() LIMIT 1]){
                system.debug('accountTeamMemberList===> '+accountTeamMemberList);
                if(! accTeamMemWithUserId.containsKey(accountTeamMemberList.AccountId)){
                    accTeamMemWithUserId.put(accountTeamMemberList.AccountId,accountTeamMemberList.UserId);
                }  
            }
            system.debug('accTeamMemWithUserId===> '+accTeamMemWithUserId);
            
            for(TASK tsk : ProposalTasks){
                if(accIdwithOpptyIds.get(tsk.whatId) != Null && accTeamMemWithUserId.get(accIdwithOpptyIds.get(tsk.whatId)) != NULL){
                    tsk.fbe_assigned_To__c = accTeamMemWithUserId.get(accIdwithOpptyIds.get(tsk.whatId));
                    tsk.OwnerId = accTeamMemWithUserId.get(accIdwithOpptyIds.get(tsk.whatId));
                }
                else{
                   tsk.FBE_Assigned_To__c = ID.valueOf(System.Label.FBE_Default_Task_Assigned_User);  
                   tsk.OwnerId = ID.valueOf(System.Label.FBE_Default_Task_Assigned_User);  
                }
                tsk.Status = statusAssigned;
            }           
        }       
    }
}