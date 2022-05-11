/**************
 *@ Class Name        : FBE_LogHandler
 *@ Description       : This class is written for error Handling on Sync Account deal Reg teams. 
 *@ CreatedBy         : Dell Team
 *@ CreatedOn         : 05-06-2020
 *@ Modification Log  : [Sireesha Myla] :  STORY 8358218 - 
                        Created script to INSERT 'Error logs' for as part of error handling
                        This handler invoked in 'FBE_SyncAccountToDealRegTeams'.
 ***************/
public with sharing class FBE_LogHandler
{
       public static RecordType rt = [select Id,Name from RecordType where SObjectType in ('FBE_Configurator__c') AND Name in ('Error logs')];
       
       // Method to log Database.SaveResult FAILED records and will not get the RECORDID untill the record got INSERTED
       public static FBE_Configurator__c databaseSaveLogInformation(Database.SaveResult saveError, String logName)
       {
          		
               FBE_Configurator__c log = new FBE_Configurator__c();
               log.Name = logName;
               log.FBE_Error_Message__c = String.valueOf(saveError.getErrors()[0].getMessage());
               log.RecordTypeId = rt.Id; 
               
             return log;
                       
        }
       
       // Method to Log Database.DeleteResult FAILED records 
       public static FBE_Configurator__c databaseDeleteLogInformation(Database.DeleteResult deleteError, String logName)
       {
                        
                   FBE_Configurator__c log = new FBE_Configurator__c();
                   log.Name = logName + deleteError.getId();
                   log.RecordTypeId = rt.Id;
                   log.FBE_Error_Message__c = deleteError.getErrors()[0].getMessage();
                   log.FBE_Record_Id__c = deleteError.getId();
                   
                   
             return log;
        }
       // Method to Log Catch Exceptions
       public static void LogException(Exception e, String logName)
       {
            try
            {
                    String stackTrace = e.getStackTraceString().substringBefore('\n');
                    String className = stackTrace.substringAfter('.').substringBefore('.');	
                    String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
                    
                    //Log information in object
                    FBE_Configurator__c exc = new FBE_Configurator__c();
                    exc.Name = logName;
                    exc.FBE_Error_Message__c = e.getMessage();
                    exc.FBE_Line_Number__c = e.getLineNumber();
                    exc.FBE_Stack_Trace__c = e.getStackTraceString();
                    exc.FBE_Method_Name__c= methodName;
                    exc.FBE_Class_Name__c= className;
                    exc.RecordTypeId = rt.Id;
                    database.insert(exc);            
            }
            finally{}
                   
     	} 
    
}