/**************
* @ Class Name        : FBE_SetDealExpiredBatch
* @ Description       : This is a batch class to update Deal Registration Status to 'Expired' for any deals with a past Expiration Date value.
*                       Created as part of TFS Defect #7756375.
* @ CreatedBy         : Deloitte Consulting
* @ CreatedOn         : 12-11-2019
* @ Modification Log  : Version 1.0 - [Ankita Shingvi] : Initially created script to update Deal Registration Status to 'Expired' for any deals with a past Expiration Date value and updated Linked Open Opportunity to Cancelled if Deal is expired
*                       Version 2.0 - 12-11-2019 - [Abhishek Kawle] : Moved logic to Cancel Linked Open Opportunity to Process Builder - FBE Opportunity Update Process.
*                       Version 3.0 - 02-March-2021 - [Uttam Kavitkar] : Update Deal Registration Status to 'Expired' for any deals with a past Expiration Date value and not with Closed-Won,Closed-Lost status
*********/

public with sharing class FBE_SetDealExpiredBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) { 
        String todayDate = String.valueOf(system.today());        
        String strQuery = 'SELECT Id, FBE_Deal_Registration_Status__c,FBE_Expiration_Date__c,FBE_Related_Opportunity__c ' +
            'FROM Deal_Registration__c WHERE FBE_Deal_Registration_Status__c NOT IN (\'Expired\',\'Closed-Won\',\'Closed-Lost\') ' + 
            'AND FBE_Expiration_Date__c <'+ todayDate; 
        
        if(!Test.isRunningTest()){
            return Database.getQueryLocator(strQuery);
        }
        else{
            return Database.getQueryLocator(strQuery+' Limit 3');
        }
    }
    
    public void execute(Database.BatchableContext bc, List<Deal_Registration__c> scope) {       
        for(Deal_Registration__c dealRec : scope){
            dealRec.FBE_Deal_Registration_Status__c = 'Expired';
        }
        Database.SaveResult[] lsr = Database.update(scope, false);       
    }
    
    public void finish(Database.BatchableContext bc) {
        system.debug('In Finish Method');
    }
}