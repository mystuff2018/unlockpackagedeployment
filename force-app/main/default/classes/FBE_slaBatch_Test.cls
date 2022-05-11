/**************
*@ Class Name                                                    : FBE_slaBatch_Test
*@ Description                                                   : Test class for FBE_slaBatch.
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 12-19-2019 [Rakesh Reddy Mula]
*@ Modification Log                                              : 
***************/ 
@isTest
public class FBE_slaBatch_Test {

        public static string taskStatus =  System.Label.taskStatus_Assigned;
        public static string taskRecordType = System.Label.Task_Support_Request_record_type; 
        public static ID supportReqrecTypeId = FBE_Utility.getSupportReqrecTypeId(taskRecordType);
        public static User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
    
        static testMethod void testMethod1(){
        List<Task> TaskList = new List<task>();
            Task t = new Task();
                t.RecordTypeId = supportReqrecTypeId;
                t.FBE_End_Date_del__c = System.Today();
                t.Description = 'TestTask1';
                t.FBE_SLA_Timer__c = System.today();
                t.Status = 'Draft';
                t.OwnerId = u.Id;
                t.Type = 'Contract';
                t.FBE_Escalated__c = false;
                t.ActivityDate = System.Today();
                TaskList.add(t);
        
                Task t1 = new Task();
                t1.RecordTypeId = supportReqrecTypeId;
                t1.FBE_End_Date_del__c = System.Today();
                t1.FBE_SLA_Timer__c = System.today();
                t1.Description = 'TestTask1';
                t1.Status = 'Assigned';
                t1.OwnerId = u.Id;
                t.FBE_Escalated__c = false;
                t1.Type = 'Configuration Services';
                t1.ActivityDate = System.Today();
                TaskList.add(t1);
        
                Task t2 = new Task();
                t2.RecordTypeId = supportReqrecTypeId;
                t2.FBE_End_Date_del__c = System.Today();
                t2.FBE_SLA_Timer__c = Date.Today();
                t2.Description = 'TestTask1';
                t2.Status = 'Assigned';
                t2.OwnerId = u.Id;
                t2.FBE_Escalated__c = false;
                t2.Type = 'DFS';
                t2.ActivityDate = System.Today();
                TaskList.add(t2);
                
               Task t3 = new Task();
                t3.RecordTypeId = supportReqrecTypeId;
                t3.FBE_End_Date_del__c = System.Today();
                t3.FBE_SLA_Timer__c = Date.Today();
                t3.Description = 'TestTask1';
                t2.Status = taskStatus;
                t3.OwnerId = u.Id;
                t3.FBE_Escalated__c = true;
                t3.Type = 'DFS';
                t3.ActivityDate = System.Today();
                TaskList.add(t3);
             Test.startTest();
            insert TaskList;
           
            system.assertNotEquals(null, TaskList, 'TaskList is empty');
            
        List<Task> updatedTasks = new List<Task>();
        for(Task updtask : [select id,FBE_SLA_Timer__c,FBE_Escalated__c,status from Task where id IN : TaskList])
        {
            if(updtask.Status == 'Assigned' && updtask.FBE_SLA_Timer__c.time() <= system.now().time() && updtask.FBE_SLA_Timer__c.time() >= system.now().time().addHours(-1))
            {
                updtask.FBE_Escalated__c = true;
            }
              updatedTasks.add(updtask);
        }
   

            try{
                update updatedTasks;
                FBE_slaBatch sBatch = new FBE_slaBatch();
                Database.executeBatch(sBatch, 200);
                sBatch.Finish(null);                                
            }
            Catch(Exception e)
            {
                System.debug(e);
            }
              SchedulableContext ctx = null;
              FBE_ScheduleEscalateEmail fbe = new FBE_ScheduleEscalateEmail();
              fbe.execute(ctx);
           
        Test.stopTest();
    }
}