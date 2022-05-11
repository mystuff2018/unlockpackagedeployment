public class FBE_TaskTriggerHandler 
{
    public static boolean isAfterInsert = false;
    public static boolean isBeforeInsert = false;
    public static boolean isAfterUpdate = false;
    //public static string taskRecordType = System.Label.Task_FBE_FPS_Task_Request_record_type; //Getting the Task Recordtype 'FPS Task Request' from the Custom Label
    //public static ID FPSsupportReqrecTypeId = FBE_Utility.getSupportReqrecTypeId(taskRecordType);
    public static Id FPSsupportReqrecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('FBE_FPS_Task_Request').getRecordTypeId();
    public static Id ServicesalesrecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Services_Sales_Activity').getRecordTypeId();
    public static void onBeforeInsert(List<Task> newRecords)
    {
        if(newRecords.size()>0)
        {
            isBeforeInsert = true;
            
            String jsonString = json.serialize(Trigger.new);
            FBE_TaskBL.populateTeamAssignment(newRecords);
            FBE_AutoAssignTask.AssignProposalManager(newRecords);
            FBE_CustomNotify_CaseOwner.InsertCaseId(newRecords);
            
            set<Id> caseIdSet = new Set<Id>();
    for(Task t : newRecords){
        if(t.WhatId !=null && String.valueOf(t.WhatId).startsWith('500') && t.Recordtypeid == FPSsupportReqrecTypeId ){caseIdSet.add(t.WhatId);
        } 
    }
    
    if(!caseIdSet.isEmpty()){
        Map<Id,case> caseMap = new Map<Id,case>([Select Id,Status from case where Id IN: caseIdSet AND Recordtype.name = 'FBE Support Request' AND status = 'Closed']);
        if(!caseMap.isEmpty()){
            for(Task tsk:newRecords){
                if(caseMap.containsKey(tsk.whatId)){
                    tsk.addError('This case is already closed. In order to open a task please reopen the case first');
                }
            }
        }
    } 
        }
    }
    Public static void remindersetinsrtupd(list<task> newtask){

    list < task > tl = new list < task > ();
        for (task act: newtask) {
            if (act.recordtypeid == ServicesalesrecTypeId && act.isreminderset == true) {
                act.Reminder_Set__c = act.isreminderset;
                act.Reminder_Date_and_Time__c = string.valueOfGmt(act.ReminderDateTime);
                tl.add(act);
            } else {
                act.Reminder_Set__c = false;
                act.Reminder_Date_and_Time__c = '';
        }
    }
	}
	
    public static void onAfterInsert(Map<Id, Task> newRecords)
    {
        if(newRecords != null)
        {
            isAfterInsert = true;
            
            String jsonString = json.serialize(Trigger.new);
            //FBE_TaskBL.updateSLATimer(jsonString);
            FBE_ProposalTaskEmailNotifications.assignTaskEmail(Trigger.new);
        }
        
    }    
    public static void onafterUpdate(List<Task> newList, Map<Id,Task> oldMap)
    { 
        if(FBE_CheckRecursive.runOnce()){
        FBE_ProposalTaskEmailNotifications.emailOnTaskOwnerChange(newList ,  oldMap);
        FBE_ProposalTaskEmailNotifications.emailOnClosedTask(newList, oldMap);
        }
    }
    public static void onbeforeUpdate(List<Task> newList, Map<Id,Task> oldMap)
    { 
        FBE_RoleBasedRestriction.FBE_TaskFieldRestrictionForProMgr(newList, oldMap);
        FBE_CustomNotify_CaseOwner.UpdateCaseId(newList,oldMap);
    }
}