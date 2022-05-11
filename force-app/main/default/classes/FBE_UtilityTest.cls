@isTest
public class FBE_UtilityTest 
{
    public static string emailbody =  System.Label.Email_Body;
    public static string taskRecordType = System.Label.Task_Support_Request_record_type; //Getting the Task Recordtype 'Support Request' from the Custom Label
    public static string taskTypeConfig =  System.Label.Task_Type;
    public static User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
    public static Map<String, FBE_SLA_Setting__mdt> slaMetaMap = FBE_Utility.getSLAMetadata();
    public static Map<String, FBE_SLA_Breach_Setting__mdt> escalateMetaMap = FBE_Utility.getEscalateMetadata();
    public static List<Task> tasksList = new List<Task>();
    
    static testMethod void utilityTesting1()
    {
        
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Task' AND Name =:taskRecordType];
        
        FBE_Utility.getSupportReqrecTypeId(taskRecordType);
        FBE_Utility.getSLAMetadata();
        
        tasksList = FBE_UtilityFactory.createTasks();
        system.assertNotEquals(null, tasksList[0].Id,'Null check');
         Test.startTest();   
        try{
                FBE_Utility.sendInitialNotifyEmail(tasksList);
                FBE_Utility.EscalateEmail(tasksList);
                DMLException dmlEx = new DMLException('Test Ex Email');
           }catch(DMLException  e)
           { 
                system.debug(e.getMessage());
           }
        Test.stopTest();
        
            
    }
    
}