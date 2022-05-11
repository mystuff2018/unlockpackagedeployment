/**************
 * @ Class Name        : FBE_CreateDealTeamMemBatch
 * @ Description       : This is a batch class written for one time fix for historical records for Deal Reg Trigger missing from Production under Defect#7877584.
 * @ CreatedBy         : Deloitte Consulting
 * @ CreatedOn         : 12-17-2019
 * @ Modification Log  : 
*********/

public class FBE_CreateDealTeamMemBatch implements Database.Batchable<sObject> {
    DateTime soqlRunDate;
    //constructor 
    public FBE_CreateDealTeamMemBatch(String runDate){
        soqlRunDate = DateTime.valueof(runDate);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Important: soqlRunDate variable should be in Date Time format for example - 2019-12-18 00:00:00
        String strQuery = 'Select Id,FBE_Account__c,FBE_Distributor_Account__c,FBE_End_User_Account__c,FBE_FSI_Account__c,FBE_OEM_Account__c,FBE_Reseller_VAR_Account__c from Deal_Registration__c where createdDate >= :soqlRunDate';
        //String strQuery = 'Select Id,Deal_Registration_Team_Count__c,createdDate ,lastmodifiedDate,FBE_Account__c,FBE_Distributor_Account__c,FBE_End_User_Account__c,FBE_FSI_Account__c,FBE_OEM_Account__c,FBE_Reseller_VAR_Account__c,(Select Id,FBE_Auto_Created__c from Deal_Registration_Team__r) from Deal_Registration__c where createdDate >= :soqlRunDate';
        if(!Test.isRunningTest()){
            return Database.getQueryLocator(strQuery);
        }
        else{
            return Database.getQueryLocator(strQuery+' Limit 3');
         }
    }
    public void execute(Database.BatchableContext bc, List<Deal_Registration__c> scope) {
        Set<Id> DealId = new Set<Id>();
        List <FBE_Deal_Registration_Team__c> dealTeamList = new List <FBE_Deal_Registration_Team__c>();
		Set<Id> newAccntIds = new Set<Id>();
        Map<Id,Deal_Registration__c> dealMap = new Map<Id,Deal_Registration__c>();
        Map<String,Id> dealTeamMap = new Map<String,Id>();
        for(Deal_Registration__c deal : scope){
			DealId.add(deal.Id);            
            newAccntIds.add(deal.FBE_Account__c);
            newAccntIds.add(deal.FBE_End_User_Account__c);
            newAccntIds.add(deal.FBE_FSI_Account__c);
            newAccntIds.add(deal.FBE_Reseller_VAR_Account__c);
            newAccntIds.add(deal.FBE_Distributor_Account__c);
            newAccntIds.add(deal.FBE_OEM_Account__c);            
        }
		
        dealTeamList = [Select Id,Deal_Registration__c,User__c from FBE_Deal_Registration_Team__c where Deal_Registration__c IN: DealId];            
        for(Integer i=0;i<dealTeamList.size();i++){
            dealTeamMap.put(dealTeamList[i].Deal_Registration__c+'_'+dealTeamList[i].User__c,dealTeamList[i].Id);
        }
       //adding team members from all account fields added
        FBE_CreateDealTeamMemBatchHelper obj = new FBE_CreateDealTeamMemBatchHelper();
        obj.Sync_Deal_Team_with_Account_Team(scope,newAccntIds,dealTeamMap,'Add');
        
        

    }
    public void finish(Database.BatchableContext bc) {
    	//nothing to do
    }
}