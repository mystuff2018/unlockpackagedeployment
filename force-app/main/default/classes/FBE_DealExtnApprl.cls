/**
* @description       : FBE_DealExtnApprl is entry class for Deal Extension Approval Process called from DealTriggerHandler class
* @author            : Soumithri Rekha v
* @group             : 
* @last modified on  : 01-26-2022
* @last modified by  : 
**/
public without sharing class FBE_DealExtnApprl {
     public static String[] filters = new String[]{'%APOS%','%Nutanix%','%XC Series%', '%Service%','%SonicWALL%', '%VMWare%', '%Maintenance%', '%Warranty Extension%', '%Warranty%', '%Entitlement%', '%Renewal%'};  
     private boolean m_isExecuting = false;
    private integer BatchSize = 0;
     public FBE_DealExtnApprl(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
                /**************
* @MethodName    : allApproveCall
* @Trigger       : FBE_DealExtensionTrigger
* @Description   : This method is called from class== DealTriggerHandler. In this method,we handle Approval Process Entry Criteria 
* @CreatedBy     : DeLL Team
* @CreatedOn     : 01-26-2022 [Soumithri Rekha]
***************/ 
    public void allApproveCall(Map<id,Deal_Extension__c> newDeals,Map<id,Deal_Extension__c> oldDeals){
       MAP<Id,string> aprEuList = new MAP<Id,string>();
        MAP<Id,string> aprFsiList = new MAP<Id,string>();
        MAP<Id,string> aprPSPPmoList = new MAP<Id,string>();
        MAP<Id,id> aprEuList1 = new MAP<Id,id>();
        MAP<Id,id> aprFsiList1 = new MAP<Id,id>();
        MAP<Id,id> aprPSPPmoList1 = new MAP<Id,id>();
        set<Id> change =  new set<Id>();  
        set<Id> rejectstate =  new set<Id>();
        set<Id> rejectstateAuto =  new set<Id>();
        set<Id> RecallStatus =  new set<Id>();
        set<Id> ifNone =  new set<Id>();
        for(Deal_Extension__c dealex : newDeals.Values()){
            
            if((dealex.FBE_Deal_Distributor_Account__c != null && dealex.FBE_Deal_FSI_Account__c == null && dealex.FBE_Extension_Request_Status__c == 'Submitted' && dealex.FBE_PMO_Substatus__c == 'Under Review' && oldDeals.get(dealex.ID).FBE_PMO_Substatus__c != 'Under Review') || 
              (dealex.FBE_Deal_Reseller_Account__c != null && dealex.FBE_Deal_Distributor_Account__c == null && dealex.FBE_Deal_FSI_Account__c == null && dealex.FBE_Extension_Request_Status__c == 'Submitted' && dealex.FBE_PMO_Substatus__c == 'Under Review' && oldDeals.get(dealex.ID).FBE_PMO_Substatus__c != 'Under Review')){
                System.debug('Inside First Approval ');
                  aprEuList.put(dealex.FBE_Deal_Registration__c,dealex.Name);
                  aprEuList1.put(dealex.FBE_Deal_Registration__c,dealex.id);
            }
              if((dealex.FBE_Deal_Distributor_Account__c != null && dealex.FBE_Deal_FSI_Account__c != null && dealex.FBE_Extension_Request_Status__c == 'Submitted' && dealex.FBE_PMO_Substatus__c == 'Under Review' && oldDeals.get(dealex.ID).FBE_PMO_Substatus__c != 'Under Review') || 
                   (dealex.FBE_Deal_Reseller_Account__c != null && dealex.FBE_Deal_Distributor_Account__c == null && dealex.FBE_Deal_FSI_Account__c != null && dealex.FBE_Extension_Request_Status__c == 'Submitted' && dealex.FBE_PMO_Substatus__c == 'Under Review' && oldDeals.get(dealex.ID).FBE_PMO_Substatus__c != 'Under Review')){
                System.debug('Inside Thrid Approval ');
                       aprFsiList.put(dealex.FBE_Deal_Registration__c,dealex.Name);
                       aprFsiList1.put(dealex.FBE_Deal_Registration__c,dealex.id);
            }
            if(dealex.FBE_Secondary_Status__c == 'Sales Rejected' && oldDeals.get(dealex.ID).FBE_Secondary_Status__c != 'Sales Rejected' && dealex.FBE_PMO_Substatus__c != 'Pending With PMO'){
                System.debug('Inside Sales Rejected');
                rejectstate.add(dealex.id);
            }
            if((dealex.FBE_Deal_Distributor_Account__c != null && dealex.FBE_Deal_FSI_Account__c == null ) ||
               (dealex.FBE_Deal_Reseller_Account__c != null && dealex.FBE_Deal_Distributor_Account__c == null && dealex.FBE_Deal_FSI_Account__c == null) ||
               (dealex.FBE_Deal_Distributor_Account__c != null && dealex.FBE_Deal_FSI_Account__c != null ) ||
               (dealex.FBE_Deal_Reseller_Account__c != null && dealex.FBE_Deal_Distributor_Account__c == null && dealex.FBE_Deal_FSI_Account__c != null)
              ){
                  if((dealex.FBE_Extension_Request_Status__c == 'Submitted' && dealex.FBE_PMO_Substatus__c == 'Pending With PMO' && oldDeals.get(dealex.ID).FBE_Secondary_Status__c != 'Sales Approved')||(dealex.FBE_Secondary_Status__c == 'Sales Approved' && oldDeals.get(dealex.ID).FBE_Secondary_Status__c == 'Pending Sales Review' && dealex.FBE_PMO_Substatus__c == 'Under Review'))
                     {
                         System.debug('Inside Pending with PMO');
                         aprPSPPmoList.put(dealex.FBE_Deal_Registration__c,dealex.Name);
                         aprPSPPmoList1.put(dealex.FBE_Deal_Registration__c,dealex.id);
                     }
              }
             if(dealex.FBE_Approval_Fired__c == true){
                 change.add(dealex.id);
                 system.debug('change'+change);
            }
            if(dealex.FBE_Secondary_Status__c == 'Passed SLA' && oldDeals.get(dealex.ID).FBE_Secondary_Status__c != 'Passed SLA'){
                System.debug('Inside Passed SLA');
                rejectstateAuto.add(dealex.id);
            }
        }
        
        if(aprEuList != NULL && aprEuList.size()>0){
            FBE_ApprovalMethods.callEUApproval(aprEuList.keyset(),aprEuList,aprEuList1);
        }
        if(aprFsiList != NULL && aprFsiList.size()>0){
            FBE_ApprovalMethods.callEUAndFSIApproval(aprFsiList.keyset(),aprFsiList,aprFsiList1);
        }
        if(aprPSPPmoList != NULL && aprPSPPmoList.size()>0){
            FBE_ApprovalMethods.callPSPPMOApproval(aprPSPPmoList.keyset(),aprPSPPmoList,aprPSPPmoList1);
        }
        if(change !=NULL && change.size()>0){
           FBE_ApprovalMethods.ChangeStatus(change,'Deal_Extension__c');
        }
        if(rejectstate != NULL && rejectstate.size()>0){
            FBE_ApprovalMethods.RecallOrRejectStatus(rejectstate,System.label.FBE_Rejected_SalesTeam,'Reject','Deal_Extension__c');
        }
        if(rejectstateAuto != NULL && rejectstateAuto.size()>0){
            FBE_ApprovalMethods.RecallOrRejectStatus(rejectstateAuto,System.label.FBE_Rejected_PassedSLA,'Reject','Deal_Extension__c');
        }
       
    }
                    /**************
* @MethodName    : updateApproveDeclineComments
* @Trigger       : FBE_DealExtensionTrigger
* @Description   : This method is called from class== DealTriggerHandler. In this method,we handle before update process of adding comments and resetting the status 
* @CreatedBy     : DeLL Team
* @CreatedOn     : 01-26-2022 [Soumithri Rekha]
***************/
    public void updateApproveDeclineComments(List<Deal_Extension__c> newList, Map<Id, Deal_Extension__c> oldMap){ 
        List<Deal_Extension__c> updList = new List<Deal_Extension__c>();
        List<Deal_Extension__c> dealstobeUpdated = new List<Deal_Extension__c>();
        set<id> pendingdeals = new set<id>();
        string pen = 'Pending';
        string ppquery = 'SELECT TargetObjectId FROM ProcessInstance WHERE TargetObjectId in: newList AND  Status=:pen';
        List<ProcessInstance> inProcess = database.query(ppquery);
        for(ProcessInstance p : inProcess){
            pendingdeals.add(p.TargetObjectId);
        }
        
        for(Deal_Extension__c deal : newList){
            if(deal.FBE_Extension_Request_Status__c == 'Submitted' && (oldMap.get(deal.ID).FBE_Extension_Request_Status__c != 'Submitted')){
                deal.FBE_PMO_Substatus__c = 'Sales Review'; 
                deal.FBE_Secondary_Status__c = '';
                deal.FBE_Approval_Rejection_Reason__c = '';
                deal.FBEApprovalReminderUsers__c = ''; 
            }
            if((deal.FBE_PMO_Substatus__c == 'PMO Approved' && oldMap.get(deal.Id).FBE_PMO_Substatus__c != 'PMO Approved') 
               || (deal.FBE_PMO_Substatus__c == 'PMO Rejected' && oldMap.get(deal.Id).FBE_PMO_Substatus__c != 'PMO Rejected')){
                   System.debug('inside update comments');
                   updList.add(deal);
               }
           
            
        }
        if(updList.size() > 0){
            string app = 'Approved';
            string rej = 'Rejected';
            string psppmo = '%PSPPMO%';	
            id updid = updList[0].id;
            string piquery = 'Select TargetObjectId, CreatedDate ,Status, (Select StepStatus,TargetObjectId,Actor.name,OriginalActor.name,comments, ProcessInstanceId,CreatedDate FROM StepsAndWorkitems where OriginalActor.Name LIKE :psppmo AND (stepstatus =:app OR stepstatus =: rej) ORDER BY createdDate DESC limit 1) FROM ProcessInstance WHERE TargetObjectId = : updid order by createdDate desc limit 1';
            system.debug('piquery'+database.query(piquery));
            for(ProcessInstance pi : database.query(piquery))
            {     
                system.debug('piquery'+pi);
                if(pi.StepsAndWorkitems[0].StepStatus == 'Approved' ){
                    System.debug('inside approved comments');
                    
                    if(pi.StepsAndWorkitems[0].comments != null){
                        if(updList[0].FBE_Secondary_Status__c == null ){
                            updList[0].FBE_Secondary_Status__c = 'PSP PMO Approved';
                        }
                        updList[0].FBE_Approval_Rejection_Reason__c = pi.StepsAndWorkitems[0].comments;
                        
                    }else
                        updList[0].addError('Operation Cancelled: Please provide  Approval Comments!');
                            
                }
                if(pi.StepsAndWorkitems[0].StepStatus == 'Rejected' ){
                    System.debug('inside reject comments');
                    if(pi.StepsAndWorkitems[0].comments != null){
                        if(updList[0].FBE_Secondary_Status__c == null ){
                            updList[0].FBE_Secondary_Status__c = 'PSP PMO Rejected';
                        }
                        updList[0].FBE_Approval_Rejection_Reason__c = pi.StepsAndWorkitems[0].comments;
                        system.debug('updList'+updList[0]);
                    }else{
                        updList[0].addError('Operation Cancelled: Please provide a Rejection Comments!');
                    }
                    
                    
                }
            }
        }
        
    }
}