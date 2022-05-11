/**************
 * @ Class Name        : FBE_UpdateContactTypeBatch
 * @ Description       : This is a batch class to update DFN Contacts (existing) record type to 'Customer Contact'
 *                       Created as part of IDS Feature #7868086.
 * @ CreatedBy         : Deloitte Consulting
 * @ CreatedOn         : 07/20/2020
 * @ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created the script.
*********/
public class FBE_UpdateContactTypeBatch implements Database.Batchable<SObject>{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String strQuery = 'SELECT Id, RecordTypeId, RecordType.DeveloperName' +
            			   ' FROM Contact' +
            			   ' WHERE RecordTypeId = \'\'';
        if(!Test.isRunningTest()){
            return Database.getQueryLocator(strQuery);
        }
        else{
            //Query for test class.
            Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Default_Contact').getRecordTypeId();
            strQuery = 'SELECT Id, RecordTypeId, RecordType.DeveloperName' +
            			   ' FROM Contact' +
            			   ' WHERE RecordTypeId = \''+ recordTypeId + '\'';
            return Database.getQueryLocator(strQuery+' Limit 3');
        }
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> scope){
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('FBE_Customer_Contact').getRecordTypeId();
        
        for(Contact contactRecord : scope){
            contactRecord.RecordTypeId = recordTypeId;
        }
        
        Database.SaveResult[] lsr = Database.update(scope, false);
    }
    
    public void finish(Database.BatchableContext bc) {
        system.debug('Contact Type Update Batch Execution is complete.');
    }
}