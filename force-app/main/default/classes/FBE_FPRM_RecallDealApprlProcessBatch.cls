/**
* @description       : Defect : 12192105 Partners were unable to recall a deal in submitted status that is in approval workflow
* @author            : Dipanshu Parakh
* @created on        : 11-03-2022
**/

public with sharing class FBE_FPRM_RecallDealApprlProcessBatch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc){    
        String query = 'SELECT Id, FBE_Deal_Registration_Status__c ' +
            'FROM Deal_Registration__c WHERE FBE_Deal_Registration_Status__c = \'Recalled\' and LastModifiedDate = LAST_90_DAYS';
        return Database.getQueryLocator(query);            
    }
    
    public void execute(Database.BatchableContext bc, List<Deal_Registration__c> scope){
        String state = 'Removed';
        List<Id> dealIds = new List<Id>();
        for(Deal_Registration__c deal : scope){
            dealIds.add(deal.Id);
        }
        if(dealIds.size() > 0){
            Map<Id, List<String>> processStatusMap = new Map<Id, List<String>>();
            Map<Id, List<Id>> processWorkStatusMap = new Map<Id, List<Id>>();
            
            for(ProcessInstanceWorkitem pI  : [Select p.Id,p.ProcessInstance.TargetObjectId,p.ProcessInstance.Status,p.Actor.Name from ProcessInstanceWorkitem p  where p.ProcessInstance.TargetObjectId in: dealIds AND p.ProcessInstance.Status ='Pending']){
                if(!processStatusMap.containsKey(pI.ProcessInstance.TargetObjectId)){
                    processStatusMap.put(pI.ProcessInstance.TargetObjectId,new List<String> {pI.ProcessInstance.Status});
                }else
                    processStatusMap.get(pI.ProcessInstance.TargetObjectId).add(pI.ProcessInstance.Status);               
                if(!processWorkStatusMap.containsKey(pI.ProcessInstance.TargetObjectId)){
                    processWorkStatusMap.put(pI.ProcessInstance.TargetObjectId,new List<String> {pI.Id});
                }else
                    processWorkStatusMap.get(pI.ProcessInstance.TargetObjectId).add(pI.Id);
            }
                       
            List<Deal_Registration__c> updatedeal = new List<Deal_Registration__c> ();
            for(Deal_Registration__c deal : [Select id, FBE_Approval_Fired__c,FBE_Secondary_Status__c,FBE_PMO_Substatus__c from Deal_Registration__c where id in:dealIds]){
                if((processStatusMap.containsKey(deal.id) && processStatusMap.get(deal.id).contains('Pending') )|| test.isRunningTest()) { 
                    Approval.ProcessWorkitemRequest[] requestList = new Approval.ProcessWorkitemRequest[]{};
                    List<Id> workItemIdList = processWorkStatusMap.get(deal.id); 
                    if(workItemIdList != null && workItemIdList.size()>0){
                        for(id itemId : workItemIdList){
                            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                            req.setWorkitemId(itemId);
                            req.setComments(System.label.FBE_Status_Recalled);
                            req.setAction(state);
                            requestList.add(req);
                        }
                        try{
                            Approval.ProcessResult[] result =  Approval.process(requestList);
                        }catch(Exception e){
                            System.debug(e);
                        }
                    }
                }
                deal.FBE_PMO_Substatus__c = 'Sales Review';
                deal.FBE_Secondary_Status__c = '';
                deal.FBE_ApprovalFlowCheck__c = False;
                updatedeal.add(deal);              
            }
            if(updatedeal != null && updatedeal.size()>0){               
                Database.update(updatedeal, false) ;                
            } 
        }        
    }
    public void finish(Database.BatchableContext BC){}   
}