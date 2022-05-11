/**************
* @BatchName    : FBE_FSI_Checkbox
* @Description   : When viewing existing Opps that do not have an FSI account listed, the user expects that the FSI Not Applicable box will be checked as true.VF template has no classes involved
* @CreatedBy     : DeLL Team
* Requirement Deletion    : Please delete this batch after successfull operation it is only for one time
* @CreatedOn     : 10-17-2019 [Soumithri Rekha]
******/

public class FBE_FSI_Checkbox implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        String query;
        string StageName = System.Label.StageNames;
        set<string> stages = new set<String>();
        stages.addAll(StageName.split(';'));
        
             query = 'select id, name,FBE_Pursuit_Type__c,FBE_FSI_Account__c,FBE_FSI_Not_Applicable__c,FBE_Distributor__c,FBE_VAR_Seller__c,FBE_Reseller_VAR_Not_Applicable__c,FBE_Distributor_Not_Applicable__c from Opportunity where StageName not in: stages';
        
        system.debug('query'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> opptyList) {
       system.debug('opptyList'+opptyList);
        // process each batch of records
        if(opptyList.size() > 0){
                                           Map<id,opportunity> opptyToUpdate = new Map<id,opportunity>();
                                                          for(opportunity opp : opptyList){
                                                                          if(opp.FBE_FSI_Account__c == NULL){
                                                                                      opp.FBE_FSI_Not_Applicable__c = TRUE;
                                                                          }else{
                                                                                      opp.FBE_FSI_Not_Applicable__c = FALSE;
                                                                          }
                                                                          if(opp.FBE_Distributor__c == NULL){
                                                                                      opp.FBE_Distributor_Not_Applicable__c = TRUE;
                                                                          }else{
                                                                                      opp.FBE_Distributor_Not_Applicable__c =FALSE;
                                                                          }
                                                                          if(opp.FBE_VAR_Seller__c == NULL){
                                                                                      opp.FBE_Reseller_VAR_Not_Applicable__c = TRUE;
                                                                          }else{
                                                                                      opp.FBE_Reseller_VAR_Not_Applicable__c = FALSE;
                                                                          }
              opptyToUpdate.put(opp.id,opp);
              system.debug('opptyToUpdate'+opptyToUpdate);
             
                                          
        }
            if(opptyToUpdate.values().size() > 0){                              
                Database.SaveResult[] UpdateResults = Database.update(opptyToUpdate.Values(),false);
             
        
                        for (Database.SaveResult sr : UpdateResults) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully updated  ' + sr.getId());
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
    }
    
    public void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
  }
}