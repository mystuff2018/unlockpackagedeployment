/**************
*@ Class Name                                                    : FBE_slaBatch
*@ Description                                                   : This class is written to escalate tasks and send escalation emails when SLA Time is breached. 
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 12-19-2019 [Rakesh Reddy Mula]
*@ Modification Log                                              : 
***************/   
public class FBE_slaBatch implements Database.Batchable<sObject>
{
    public static string taskRecordType = System.Label.Task_Support_Request_record_type;
    public static string statusAssigned = System.Label.taskStatus_Assigned;
    Id recTypeId = FBE_Utility.getSupportReqrecTypeId(taskRecordType);
    
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        
        if(Test.isRunningTest()){
            List<Task> qry = [select id,FBE_SLA_Timer__c,FBE_Escalated__c, RecordTypeId,Status, Type, FBE_Team_Assignment__c, CreatedDate from Task];
            return Database.getQueryLocator([select id,FBE_SLA_Timer__c,FBE_Escalated__c, RecordTypeId,Status, Type, FBE_Team_Assignment__c, CreatedDate from Task]);                                           
        }
        else{
            return Database.getQueryLocator([select id, FBE_SLA_Timer__c, FBE_Escalated__c, RecordTypeId, Status, Type, FBE_Team_Assignment__c, CreatedDate from Task where FBE_SLA_Timer__c!=null AND RecordTypeId=:recTypeId  AND status=:statusAssigned AND FBE_Escalated__c= false AND DAY_ONLY(ConvertTimeZone(FBE_SLA_Timer__c)) = :Date.today()]); 
            
        }
    }
    
    public void execute(Database.BatchableContext BC, List<Task> taskList) {
        
        Map<Id, Task> taskMap = new Map<Id, Task>();
        system.debug('Tasks being Processed==> ' +taskList.size());
        for(Task tsk : taskList)
        {   
            if(tsk.FBE_SLA_Timer__c.time() <= system.now().time() && tsk.FBE_SLA_Timer__c.time() >= system.now().time().addHours(-1))
            {      
                tsk.FBE_Escalated__c = true;
                taskMap.put(tsk.Id, tsk);
            } 
        }
        try {
            if(taskMap != null)
            {
                update taskMap.values();
                boolean emailresult = FBE_Utility.EscalateEmail(taskMap.values());
            }
                        
        } catch(Exception e) {
            System.debug(e);
        }        
    }      
    public void finish(Database.BatchableContext BC) {}  
}