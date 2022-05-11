/**************
 * @ Class Name        : FBE_dealRegShareBatch
 * @ Description       : This is a batch class to update All Manual Reason Deal Registration Sharing records 'RowCause' attribute to 'Deal Team Sharing' from current 'Manual' for all Deal Sharing Records.
 *                       Created as part of TFS Defect #8642038
 * @ CreatedBy         : Deloitte Consulting
 * @ CreatedOn         : 05-21-2020
 * @ Modification Log  : 05-21-2020 [Abhishek Kawle] : Created New for Defect #8642038
*********/
global class FBE_dealRegShareBatch implements Database.Batchable<sObject>, Database.Stateful{
    Integer recordsProcessed = 0;
    public string query;
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
        //return Database.getQueryLocator('Select Id, ParentId, UserOrGroupId, AccessLevel from Deal_Registration__Share WHERE RowCause = \'Manual\'');
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        set<Id> dealSet = new set<Id>();
        List<Deal_Registration__Share> dealTeamShare = new List<Deal_Registration__Share>();
        List<FBE_Deal_Registration_Team__c> dealTeam = new List<FBE_Deal_Registration_Team__c>();
        
        for(Deal_Registration__c eachDeal : (list<Deal_Registration__c>)scope){
            dealSet.add(eachDeal.Id);
        }
        
        if(!dealSet.isEmpty()){

           string query1 = 'SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM Deal_Registration__Share WHERE RowCause =\'Manual\' AND ParentId IN: dealSet';
            dealTeamShare =Database.query(query1);
           /* dealTeamShare = [SELECT Id, ParentId, UserOrGroupId, AccessLevel 
                             FROM Deal_Registration__Share 
                             WHERE RowCause = 'Manual' AND ParentId IN: dealSet];*/
            string query2 = 'SELECT Id, Deal_Registration__c, Access_level__c, User__c FROM FBE_Deal_Registration_Team__c WHERE Deal_Registration__c IN: dealSet';
            dealTeam =Database.query(query2);

           /*dealTeam = [SELECT Id, Deal_Registration__c, Access_level__c, User__c
                       FROM FBE_Deal_Registration_Team__c
                       WHERE Deal_Registration__c IN: dealSet];*/
        }
        
        
        List<Deal_Registration__Share> dealTeamShareInsert = new List<Deal_Registration__Share>();
        for(FBE_Deal_Registration_Team__c shareRec : dealTeam){            
            String access;
            if(shareRec.Access_level__c == 'Read')
            {
                access = shareRec.Access_level__c;
            }
            else{
                access = 'Edit';
            }            
            Deal_Registration__Share ds = new Deal_Registration__Share(
                ParentId = shareRec.Deal_Registration__c,
                AccessLevel = access,
                UserOrGroupId = shareRec.User__c,
                RowCause = Schema.Deal_Registration__Share.RowCause.Deal_Team_Sharing__c
            );
            
            dealTeamShareInsert.add(ds);
            recordsProcessed = recordsProcessed + 1;
        }
        
        System.debug('Total records to delete: '+dealTeamShare.size());
        System.debug('Total records to insert: ' +dealTeamShareInsert.size());
        
        //Delete existing Deal Sharing records
        Database.DeleteResult[] drList = Database.delete(dealTeamShare, false);
        for(Database.DeleteResult dr : drList){
            if(dr.isSuccess()){
                
            }
            else{
                // Operation failed, so get all errors
                for(Database.Error err : dr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            } 
        }
        
        
        //Insert new Deal Sharing records with updated rowcause
        Database.SaveResult[] srList = Database.insert(dealTeamShareInsert, false);
        
        for(Database.SaveResult sr : srList){
            if(sr.isSuccess()){
                
            }
            else{
                // Operation failed, so get all errors
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
       System.debug('Number of records processed: ' +recordsProcessed); 
       Id jobid = bc.getJobId();
       string query3 = 'Select Id,Status,JobItemsProcessed,TotalJobItems,NumberOfErrors from AsyncApexJob where Id =: jobid';
       AsyncApexJob job =Database.query(query3);
       //AsyncApexJob job = [Select Id,Status,JobItemsProcessed,TotalJobItems,NumberOfErrors from AsyncApexJob where Id =: jobid]; 
       System.debug('Job Details: ' +job); 
    
    }
    
}