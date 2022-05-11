/**
 * Created by Bruno_Frosi on 2/19/2020.
 */

public with sharing class SaveResultExceptionLogger {
    public static List<ExceptionLogger__c> saveResultsLog(Set<Id> setOrderId, List<Database.SaveResult> saveResults, String className) {
        return saveResultsLog(setOrderId, null, saveResults, className);
    }

    public static List<ExceptionLogger__c> saveResultsLog(Set<Id> setOrderId, Set<Id> setprojectId, List<Database.SaveResult> saveResults, String className)
    {
        List<ExceptionLogger__c> exceptionLoggers = new List<ExceptionLogger__c>();
        for(Database.SaveResult sr :saveResults)
        {
            if (!sr.isSuccess())
            {
                for(Database.Error err : sr.getErrors())
                {
                    ExceptionLogger__c excepLog = new ExceptionLogger__c();
                    excepLog.Module__c = 'ProjectCreation';
                    excepLog.Apex_Class__c = className;

                    excepLog.API_PayLoad__c = 'setOrderId: ' + setOrderId;
                    if(setprojectId != null)
                        excepLog.API_PayLoad__c += ' | ' + 'setprojectId: ' + setprojectId;

                    excepLog.Description__c = sr.getId() + ' - ' + err.getStatusCode() + ': ' + err.getMessage();

                    exceptionLoggers.add(excepLog);
                }
            }
        }
        return exceptionLoggers;
    }

    public static List<ExceptionLogger__c> saveResultsLog(Set<Id> setOrderId, List<Approval.ProcessResult> saveResults, String className)
    {
        List<ExceptionLogger__c> exceptionLoggers = new List<ExceptionLogger__c>();
        for(Approval.ProcessResult sr :saveResults)
        {
            if (!sr.isSuccess())
            {
                for(Database.Error err : sr.getErrors())
                {
                    ExceptionLogger__c excepLog = new ExceptionLogger__c();
                    excepLog.Module__c = 'ProjectCreation';
                    excepLog.Apex_Class__c = className;

                    excepLog.API_PayLoad__c = 'setOrderId: ' + setOrderId;

                    excepLog.Description__c = sr.getEntityId() + ' - ' + err.getStatusCode() + ': ' + err.getMessage();

                    exceptionLoggers.add(excepLog);
                }
            }
        }
        return exceptionLoggers;
    }

    public static List<ExceptionLogger__c> saveResultsLog(Set<Id> setOrderId, List<Database.UpsertResult> saveResults, String className)
    {
        List<ExceptionLogger__c> exceptionLoggers = new List<ExceptionLogger__c>();
        for(Database.UpsertResult sr :saveResults)
        {
            if (!sr.isSuccess())
            {
                for(Database.Error err : sr.getErrors())
                {
                    ExceptionLogger__c excepLog = new ExceptionLogger__c();
                    excepLog.Module__c = 'ProjectCreation';
                    excepLog.Apex_Class__c = className;

                    excepLog.API_PayLoad__c = 'setOrderId: ' + setOrderId;

                    excepLog.Description__c = sr.getId() + ' - ' + err.getStatusCode() + ': ' + err.getMessage();

                    exceptionLoggers.add(excepLog);
                }
            }
        }
        return exceptionLoggers;
    }

    public static List<ExceptionLogger__c> saveResultsLog(Set<Id> setOrderId, List<Database.DeleteResult> saveResults, String className)
    {
        List<ExceptionLogger__c> exceptionLoggers = new List<ExceptionLogger__c>();
        for(Database.DeleteResult sr :saveResults)
        {
            if (!sr.isSuccess())
            {
                for(Database.Error err : sr.getErrors())
                {
                    ExceptionLogger__c excepLog = new ExceptionLogger__c();
                    excepLog.Module__c = 'ProjectCreation';
                    excepLog.Apex_Class__c = className;

                    excepLog.API_PayLoad__c = 'setOrderId: ' + setOrderId;

                    excepLog.Description__c = sr.getId() + ' - ' + err.getStatusCode() + ': ' + err.getMessage();

                    exceptionLoggers.add(excepLog);
                }
            }
        }
        return exceptionLoggers;
    }

    public static List<ExceptionLogger__c> saveResultsLog(List<SObject> objectList, List<Database.SaveResult> saveResults, String className, String context)
    {
        List<ExceptionLogger__c> exceptionLoggers = new List<ExceptionLogger__c>();
        for(Database.SaveResult sr :saveResults) {

            if (!sr.isSuccess()) {

                for(Database.Error err : sr.getErrors()) {
                    ExceptionLogger__c excepLog = new ExceptionLogger__c();
                    excepLog.Module__c = context;
                    excepLog.Apex_Class__c = className;
                    excepLog.API_PayLoad__c = JSON.serialize(objectList);
                    excepLog.Description__c = sr.getId() + ' - ' + err.getStatusCode() + ': ' + err.getMessage();

                    exceptionLoggers.add(excepLog);
                }
            }
        }
        return exceptionLoggers;
    }

    public static List<ExceptionLogger__c> saveResultsLog(List<SObject> objectList, List<Database.UpsertResult> saveResults, String className, String context)
    {
        List<ExceptionLogger__c> exceptionLoggers = new List<ExceptionLogger__c>();
        for(Database.UpsertResult sr :saveResults) {

            if (!sr.isSuccess()) {

                for(Database.Error err : sr.getErrors()) {
                    ExceptionLogger__c excepLog = new ExceptionLogger__c();
                    excepLog.Module__c = context;
                    excepLog.Apex_Class__c = className;
                    excepLog.API_PayLoad__c = JSON.serialize(objectList);
                    excepLog.Description__c = sr.getId() + ' - ' + err.getStatusCode() + ': ' + err.getMessage();

                    exceptionLoggers.add(excepLog);
                }
            }
        }
        return exceptionLoggers;
    }

    public static List<ExceptionLogger__c> saveResultsLog(List<Database.SaveResult> saveResults, List<Database.UpsertResult> upsertResults, Set<Id> objectList, String className, String context) {
        List<ExceptionLogger__c> exceptionLoggers = new List<ExceptionLogger__c>();

        List<Database.Error> errorList = new List<Database.Error>();
        if(saveResults != null){
            for(Database.SaveResult sr :saveResults) {
                if (!sr.isSuccess()) {
                    errorList.addAll(sr.getErrors());
                }
            }
        }

        if(upsertResults != null){
            for(Database.UpsertResult ur :upsertResults) {
                if (!ur.isSuccess()) {
                    errorList.addAll(ur.getErrors());
                }
            }
        }

        for(Database.Error err : errorList) {
            ExceptionLogger__c excepLog = new ExceptionLogger__c();
            excepLog.Module__c = context;
            excepLog.Apex_Class__c = className;
            excepLog.Description__c = err.getFields() + ' : ' + err.getStatusCode() + ' : ' + err.getMessage();
            excepLog.API_PayLoad__c = JSON.serialize(objectList);
            exceptionLoggers.add(excepLog);
        }

        return exceptionLoggers;
    }

    public static ExceptionLogger__c createExceptionLogger(Exception e, String className, String context) {

        ExceptionLogger__c excepLog = new ExceptionLogger__c(
                Module__c = context,
                Apex_Class__c = className,
                Description__c = e.getLineNumber() + ' - ' + e.getTypeName() + ' - ' + e.getMessage() + ' - ' + e.getStackTraceString()
        );

        return excepLog;
    }

    public static ExceptionLogger__c createExceptionLogger(System.DmlException e, String className, String context) {
        string exceptionDescription = '';

        for (Integer i = 0; i < e.getNumDml(); i++) {
            exceptionDescription += 'Row Num: ' + i + ' -- Fields: ' + e.getDmlFieldNames(i) + ' - DmlId: ' + e.getDmlId(i) + ' - Message: '
                    + e.getDmlMessage(i) + ' - DmlType: ' + e.getDmlType(i);
        }

        ExceptionLogger__c excepLog = new ExceptionLogger__c(
                Module__c = context,
                Apex_Class__c = className,
                Description__c = exceptionDescription + ' | Exception info: ' + e.getLineNumber() + ' - ' + e.getTypeName() + ' - ' + e.getMessage() + ' - ' + e.getStackTraceString()
        );

        return excepLog;
    }

    public static void systemDebugLog(Set<Id> setOrderId, List<Database.UpsertResult> saveResults) {
        systemDebugLog(setOrderId, null, saveResults);
    }
    public static void systemDebugLog(Set<Id> setOrderId, Set<Id> setProjectId, List<Database.UpsertResult> saveResults)
    {
        system.debug('setOrderId: ' + setOrderId);
        system.debug('setProjectId: ' + setProjectId);
        for(Database.UpsertResult sr :saveResults)
        {
            if (!sr.isSuccess())
            {
                system.debug('UpsertResult: ' + sr);
                for (Database.Error err : sr.getErrors())
                {
                    system.debug('Database.Error: ' + err);
                }
            }
        }
    }
}