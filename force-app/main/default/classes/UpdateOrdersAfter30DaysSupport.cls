global with sharing class UpdateOrdersAfter30DaysSupport implements Database.Batchable<sObject>, Schedulable { //Added with sharing keyword as a part of checkMarx
    global final String query;
    
    global UpdateOrdersAfter30DaysSupport()
    {
        system.debug('UpdateOrdersAfter30DaysSupport.ctor');
        query = 'SELECT Id, pse__Stage__c,On_Hold_Date__C,On_Hold_Reason__c,pse__Project_Phase__c FROM pse__Proj__c ' + 
                    'WHERE pse__Stage__c = \'On Hold\' AND On_Hold_Date__c < '+ String.ValueOf(System.Today()) +' AND Closure_Reason__c != null And On_Hold_Reason__c = \'30 Day Support\'';
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('start UpdateOrdersAfter30DaysSupport');
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext BC, List<pse__Proj__c> scope){
        system.debug('execute UpdateOrdersAfter30DaysSupport');

        for(pse__Proj__c proj : scope)
        {
            proj.pse__Project_Phase__c = 'Close';
            proj.pse__Stage__c = 'Closure';
            //proj.pse__Is_Active__c = false;
            proj.On_Hold_Reason__c = null;
            system.debug('Phase: '+proj.pse__Project_Phase__c);
        }

        // Map<Id, pse__Proj__c> mapProjectsAfter30Days = new Map<Id, pse__Proj__c>();
        // mapProjectsAfter30Days.putAll(scope);
        // Database.DMLOptions dml = new Database.DMLOptions();
        // dml.optAllOrNone = false;
        Database.SaveResult[] srList = Database.update(scope, false);
        
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Successfully update closure project 30 day. project ID: ' + sr.getId());
                system.debug('*** JSON Result: ');
                system.debug(JSON.serialize(sr));
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('finish UpdateOrdersAfter30DaysSupport');
    }

    global void execute(SchedulableContext sc) {
        UpdateOrdersAfter30DaysSupport batch = new UpdateOrdersAfter30DaysSupport();
        system.debug('Just started executing Batch for UpdateOrdersAfter30DaysSupport.');
        Database.executeBatch(batch, 5);
       }
}