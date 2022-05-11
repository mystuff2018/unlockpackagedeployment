/*
*@ Class Name                                                    : FBEWorkloadSelectCtrl 
*@ Description                                                   : Created for selecting and adding Workload on Opportunity Workload
*@ CreatedBy                                                     : Deloitte Consulting
*@ CreatedOn                                                     : 11-28-2019[Yogesh Mishra]
*@ Modification Log                                              :                    
*/
public without sharing class FBEWorkloadSelectCtrl {
    
    @AuraEnabled
    public static OppWorkloadWrapper fetchWorkload(Id optyId){ 
        Set<Id> owIds = new Set<Id>();
        List<Opportunity> opty = [Select Id,accountId FROM Opportunity WHERE Id =: optyId];system.debug(opty);
        List<FBE_Opportunity_Workload__c> optyWorkloadList = [Select Id,FBE_Workloads__c FROM FBE_Opportunity_Workload__c WHERE FBE_Opportunity__c =: optyId];system.debug(optyWorkloadList);
        for(Integer j=0;j<optyWorkloadList.size();j++){
            owIds.add(optyWorkloadList[j].FBE_Workloads__c);
        }
        Id accountId = opty[0].accountId;
        RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='FBE_Workloads__c' and name = 'Master' LIMIT 1];
        Id workloadRecordTypeId =  rt.Id;
        List<FBE_Workloads__c> workloadList = [Select Id,FBE_Workload_Name__c,FBE_Account__c FROM FBE_Workloads__c WHERE FBE_Account__c =: accountId and Id not in: owIds];
        OppWorkloadWrapper oppWrapper = new OppWorkloadWrapper(accountId,workloadList,workloadRecordTypeId);
        return oppWrapper;
    }   
    
    public class OppWorkloadWrapper {    
        @AuraEnabled
        public Id accountId { get; set; }
        
        @AuraEnabled
        public List<FBE_Workloads__c> workloadList { get; set; }
        
        @AuraEnabled
        public String workloadRecordTypeId {get; set;}
        
        public OppWorkloadWrapper(Id accID, List<FBE_Workloads__c> OppWorkloadList, Id recTypeID) {
            this.accountId = accID;
            this.workloadList = OppWorkloadList;
            this.workloadRecordTypeId = recTypeID;
        }        
    }
    
    @AuraEnabled
     public static void AddToOpportunity(String OptyId, List<String> WorkloadId) {
       try{
             List<FBE_Opportunity_Workload__c> OptyWrkldList = new List<FBE_Opportunity_Workload__c> ();
                 
            system.debug('OptyId'+ OptyId);
            for(string WrkldId : WorkloadId){
            FBE_Opportunity_Workload__c OptyWrkld = new FBE_Opportunity_Workload__c();
            OptyWrkld.FBE_Workloads__c = WrkldId;
            OptyWrkld.FBE_Opportunity__c =  OptyId;
            OptyWrkldList.add(OptyWrkld);
            system.debug('WrkldId'+ WrkldId);
        }
        system.debug('OptyWrkldList'+ OptyWrkldList);
         insert  OptyWrkldList;
         }
         
      /*   catch(DmlException e){
             //Capture Validation Error Messages
             String msg = '';
             for (Integer i = 0; i < e.getNumDml(); i++) {
                 msg =+ e.getDmlMessage(i) +  '\n' ;
             }
             throw new AuraHandledException(msg);
             
         }*/
         catch(Exception e){
             system.debug('Exception Occurred'+e.getMessage());
             //throw new AuraHandledException(e.getMessage());
         }
    }    

}