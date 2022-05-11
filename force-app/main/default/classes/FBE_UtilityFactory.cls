/**************
*@ Class Name                                                    : FBE_UtilityFactory
*@ Description                                                   : Test Utility Class for reusable object record insertion 
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 12-19-2019 [Sireesha Myla]
*@ Modification Log                                              : 
***************/
public without sharing class FBE_UtilityFactory 
{
    public static string taskRecordType = System.Label.Task_Support_Request_record_type; //Getting the Task Recordtype 'Support Request' from the Custom Label
    public static string taskTypeConfig =  System.Label.Task_Type;
    public static ID supportReqrecTypeId = FBE_Utility.getSupportReqrecTypeId(taskRecordType);
    
    public static User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
    
    public static Map<String, FBE_SLA_Setting__mdt> slaMetaMap = FBE_Utility.getSLAMetadata();
    
    public static Map<String, Weekend__mdt> weekendMetaMap = FBE_Utility.getWeekendMetadata();
    
    public static List<Task> createTasks()
    {
        
         List<Task>tskList = new List<Task>();
            
                Task t = new Task();
                t.RecordTypeId = supportReqrecTypeId;
                t.FBE_End_Date_del__c = System.Today();
                t.Description = 'TestTask1';
                t.Status = 'Draft';
                t.OwnerId = u.Id;
                t.Type = 'Contract';
                t.ActivityDate = System.Today();
                     t.FBE_Team_Assignment__c = slaMetaMap.get(t.Type).Public_Group__c;
                tskList.add(t);
        
                Task t1 = new Task();
                t1.RecordTypeId = supportReqrecTypeId;
                t1.FBE_End_Date_del__c = System.Today();
                t1.Description = 'TestTask1';
                t1.Status = 'Draft';
                t1.OwnerId = u.Id;
                t1.Type = taskTypeConfig;
                t1.ActivityDate = System.Today();
                     t1.FBE_Team_Assignment__c = slaMetaMap.get(t1.Type).Public_Group__c;
                tskList.add(t1);
        
                Task t2 = new Task();
                t2.RecordTypeId = supportReqrecTypeId;
                t2.FBE_End_Date_del__c = System.Today();
                t2.Description = 'TestTask1';
                t2.Status = 'Draft';
                t2.OwnerId = u.Id;
                t2.Type = 'DFS';
                t2.ActivityDate = System.Today();
                     t2.FBE_Team_Assignment__c = slaMetaMap.get(t2.Type).Public_Group__c;
                tskList.add(t2);
                
                 INSERT tskList;

            return tskList;    
      }
    
  /*  public static List<Task> createProposalTasks(){
        List<Task> pTskList = new List<Task>();
        Task pTsk1 = new Task();
                pTsk1.RecordTypeId = supportReqrecTypeId;
                pTsk1.FBE_End_Date_del__c = System.Today();
                pTsk1.Description = 'TestTask1';
                pTsk1.Status = 'Draft';
                pTsk1.OwnerId = u.Id;
                pTsk1.Type = 'Proposal';
                pTsk1.ActivityDate = System.Today();        
                pTskList.add(pTsk1);
        
                Task pTsk2 = new Task();
                pTsk2.RecordTypeId = supportReqrecTypeId;
                pTsk2.FBE_End_Date_del__c = System.Today();
                pTsk2.Description = 'TestTask2';
                pTsk2.Status = 'Draft';
                pTsk2.OwnerId = u.Id;
                pTsk2.Type = 'Proposal';
                pTsk2.ActivityDate = System.Today();        
                pTskList.add(pTsk2);
        insert pTskList;
        return pTskList;
    } */
}