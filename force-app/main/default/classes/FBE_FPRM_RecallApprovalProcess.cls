public without sharing class FBE_FPRM_RecallApprovalProcess {
    
    @InvocableMethod(callout=true label='Recall Approval Process') 
    public static void recallApprovalProcess(List<Id> dealIds){
        String state = 'Removed';
        String comments = 'Recalled as Requested';
        system.debug('#dp Inside recall flow function');
        
        Map<Id, List<String>> ProccesSstatus = new Map<Id, List<String>>();
        Map<Id, List<Id>> ProccessWorkStatus = new Map<Id, List<Id>>();
        Map<Id, List<String>> ProccessActorName = new Map<Id, List<String>>();
        //List<ProcessInstance> pp = [SELECT TargetObjectId, Status, CreatedDate FROM ProcessInstance WHERE TargetObjectId in: dealIds AND  Status='Pending'];
       // system.debug('ProcessInstance query'+pp);
        
        for(ProcessInstanceWorkitem Pl  : [Select p.Id,p.ProcessInstance.TargetObjectId,p.ProcessInstance.Status,p.Actor.Name from ProcessInstanceWorkitem p  where p.ProcessInstance.TargetObjectId in: dealIds AND p.ProcessInstance.Status ='Pending'])
        {
            if(!ProccesSstatus.containsKey(Pl.ProcessInstance.TargetObjectId)){
                ProccesSstatus.put(Pl.ProcessInstance.TargetObjectId,new List<String> {Pl.ProcessInstance.Status});
            }else
                ProccesSstatus.get(Pl.ProcessInstance.TargetObjectId).add(Pl.ProcessInstance.Status);
            
            if(!ProccessWorkStatus.containsKey(Pl.ProcessInstance.TargetObjectId)){
                ProccessWorkStatus.put(Pl.ProcessInstance.TargetObjectId,new List<String> {Pl.Id});
            }else
                ProccessWorkStatus.get(Pl.ProcessInstance.TargetObjectId).add(Pl.Id);
        }
        if(comments == System.label.FBE_Status_Recalled){
            for(ProcessInstanceWorkitem Pl  : [Select p.Id,p.ProcessInstance.TargetObjectId,p.ProcessInstance.Status,p.Actor.Name from ProcessInstanceWorkitem p  where p.ProcessInstance.TargetObjectId in: dealIds AND p.ProcessInstance.Status ='Pending']){
                if(!ProccesSstatus.containsKey(Pl.ProcessInstance.TargetObjectId)){
                    ProccesSstatus.put(Pl.ProcessInstance.TargetObjectId,new List<String> {Pl.ProcessInstance.Status});
                }else
                    ProccesSstatus.get(Pl.ProcessInstance.TargetObjectId).add(Pl.ProcessInstance.Status);
                ProccessWorkStatus.put(Pl.ProcessInstance.TargetObjectId,new List<String> {Pl.Id});
            }
        }
        system.debug('ProccesSstatus'+ProccesSstatus);
        List<Deal_Registration__c> updatedeal = new List<Deal_Registration__c> ();
        for(Deal_Registration__c deal : [Select id, FBE_Approval_Fired__c,FBE_Secondary_Status__c,FBE_PMO_Substatus__c from Deal_Registration__c where id in:dealIds]){
            if((ProccesSstatus.containsKey(deal.id) && ProccesSstatus.get(deal.id).contains('Pending') )|| test.isRunningTest()) { 
                Approval.ProcessWorkitemRequest[] requestList = new Approval.ProcessWorkitemRequest[]{};
                    List<Id> workItemId = ProccessWorkStatus.get(deal.id); 
                if(workItemId != null && workItemId.size()>0)
                {
                    for(id itemid : workItemId){
                        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                        req.setWorkitemId(itemid);
                        req.setComments(comments);
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
           /* if(comments != System.label.FBE_Status_Recalled){
                deal.FBE_Approval_Fired__c = false;
                deal.FBE_PMO_Substatus__c = 'Pending With PMO';
                updatedeal.add(deal);
            }*/
            
                deal.FBE_Approval_Fired__c = false;
                deal.FBE_PMO_Substatus__c = 'Pending With PMO';
                updatedeal.add(deal);
            /*else{
                deal.FBE_PMO_Substatus__c = 'Sales Review';
                deal.FBE_Secondary_Status__c = '';
                deal.FBE_ApprovalFlowCheck__c = False;
                updatedeal.add(deal);
            }*/
            
        }
        if(updatedeal != null && updatedeal.size()>0){
            try{
                update updatedeal;
            }Catch(Exception e){
                system.debug(e);
            }
        }
    }
}