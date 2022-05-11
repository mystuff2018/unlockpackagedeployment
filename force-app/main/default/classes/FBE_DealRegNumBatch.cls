/**************
 *@ Class Name        : FBE_DealRegNumBatch
 *@ Description       : This Batch Apex class invokes handler class for Deal Registration object. 
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 08-28-2019
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created Batch Class to invoke handler class for Deal Registrations.
***************/
public class FBE_DealRegNumBatch implements Database.Batchable<sObject> {
	public String query = 'Select Id, FBE_Deal_Reg__c, FBE_Deal_Reg_Num__c, FBE_Siebel_Deal_Id__c from Deal_Registration__c';
    public Integer recordsProcessed = 0;
    public Integer totalRecords = 0;
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        List<Deal_Registration__c> dealToUpdateList = new List<Deal_Registration__c>();
        for(Deal_Registration__c deal : (list<Deal_Registration__c>) scope){
            totalRecords = totalRecords + 1;
            if((deal.FBE_Deal_Reg_Num__c == '' || deal.FBE_Deal_Reg_Num__c == null) && (deal.FBE_Siebel_Deal_Id__c == '' || deal.FBE_Siebel_Deal_Id__c == null)) {
                //System.debug('Found Deal Record: '+deal.Id);
                Deal_Registration__c dealRecord = new Deal_Registration__c();
                dealRecord.Id = deal.Id;
                dealRecord.FBE_Deal_Reg_Num__c = deal.FBE_Deal_Reg__c;
                dealToUpdateList.add(dealRecord);
            }  
        }	
        
        if(!(dealToUpdateList.isEmpty())){
            System.debug('Deal Record Update List:' + dealToUpdateList + ' No of records processed: '+ recordsProcessed);
            //update dealToUpdateList;
            Database.SaveResult[] srList = Database.update(dealToUpdateList, false);
            for(Database.SaveResult sr : srList){
                if(sr.isSuccess()){
                    //System.debug('Successfully updated Deal Reg Num for Deal Registration record: ' + sr.getId());
                    recordsProcessed = recordsProcessed + 1;
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
    }
    
    public void finish(Database.BatchableContext BC){
        //System.debug(recordsProcessed + ' records processed '+ 'out of total records in batch '+totalRecords);
    }
}