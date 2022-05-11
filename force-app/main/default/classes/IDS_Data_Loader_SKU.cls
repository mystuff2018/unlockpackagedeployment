global class IDS_Data_Loader_SKU implements Database.Batchable<sObject> {
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        String query;
        //if(Test.isRunningTest()){
        //    query = 'SELECT Id,Name,Description__c,IDS_SKU_Combination__c FROM SKU_Effort_Map__c WHERE Lastmodifieddate = TODAY LIMIT 1';
        //}else{
            query = 'SELECT Id,Name,Description__c,IDS_SKU_Combination__c FROM SKU_Effort_Map__c WHERE Lastmodifieddate = TODAY';
        //}
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SKU_Effort_Map__c> skuList) {
       IDS_SKU_Loader_Logic.ids_SKu_Loader(skuList);     
    }   
    
    global void finish(Database.BatchableContext BC) {
    	// execute any post-processing operations
  }
}