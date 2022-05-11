/**************
* @BatchName    : FBE_DealReg_DealConv
* @Description   : This batch copies data from Deal Reg to Deal Extension
* @CreatedBy     : DeLL Team
* Requirement Deletion    : Please delete this batch after successfull operation it is only for one time
* @CreatedOn     : 10-17-2019 [Soumithri Rekha]
******/

public class FBE_DealReg_DealConv implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        String query;
        
             query = 'Select id,(Select id,FBE_Deal_Registration__c,LastModifiedDate from Deal_Extensions__r),FBE_Deal_Product_Classification__c,FBE_Approval_Rejection_Reason__c,FBE_Approved_Rejected_By__c,FBE_Extension_Request_Status__c,FBE_Approver_Email_Address__c,FBE_Extension_Request_Reason__c,LastModifiedById from Deal_Registration__c where id not in (Select FBE_Deal_Registration__c from Deal_Extension__c)' ;
        
        system.debug('query'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Deal_Registration__c> DealList) {
       system.debug('opptyList'+DealList);
        // process each batch of records
        if(DealList.size() > 0){
			List<Deal_Extension__c> deal = new List<Deal_Extension__c>();
			for(Deal_Registration__c d:DealList){
			integer deale = d.Deal_Extensions__r.size();
			system.debug(deale);
			Deal_Extension__c de = new Deal_Extension__c();
				if(deale == 0){
				de.FBE_Deal_Registration__c = d.Id;
				de.FBE_Approval_Rejection_Reason__c = d.FBE_Approval_Rejection_Reason__c;
					if(d.FBE_Extension_Request_Status__c != 'Submitted' ){
						if(d.FBE_Deal_Product_Classification__c == 'Dell Products'){
							system.debug('inside if');
							de.FBE_Approved_Rejected_By__c = Label.FBE_Approved_Or_Rejected_Chris;//chris
						}
						else{
							system.debug('inside else if');
							de.FBE_Approved_Rejected_By__c = Label.FBE_Approved_Or_Rejected_Tocci;//Vanessa Tocci
						}
					}
				de.FBE_Approver_Email_Address__c = d.FBE_Approver_Email_Address__c;
				de.FBE_Extension_Request_Reason__c= d.FBE_Extension_Request_Reason__c;
				de.FBE_Extension_Request_Status__c = d.FBE_Extension_Request_Status__c;
				//de.LastModifiedById = d.LastModifiedById;
				de.FBE_Sequence_Number__c = 1;
				//de.FBE_Siebel_Extension_Id__c = from siebel
				}
				if(!String.isBlank( de.FBE_Deal_Registration__c))
				deal.add(de);
			}

		Database.SaveResult[] srList = Database.insert(deal, false);

		// Iterate through each returned result
			for (Database.SaveResult sr : srList) {
				if (sr.isSuccess()) {
					// Operation was successful, so get the ID of the record that was processed
					System.debug('Successfully inserted  ' + sr.getId());
				}
				else {
					// Operation failed, so get all errors                
					for(Database.Error err : sr.getErrors()) {
						System.debug('The following error has occurred.');                    
						System.debug(err.getStatusCode() + ': ' + err.getMessage());
						System.debug('fields that affected this error: ' + err.getFields());
					}
				}
			} 
                                          
		}
    }
    
    public void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
  }
}