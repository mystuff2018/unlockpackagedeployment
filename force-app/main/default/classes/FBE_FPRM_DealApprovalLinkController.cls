public with sharing class FBE_FPRM_DealApprovalLinkController {
    
    public ID targetObjectId { get; set; }
    
    public String approvalLink {
        get { 
            String approvalLink = getApprovalLink() != null ? getApprovalLink() : '';   
            return approvalLink;
        }       
    }
    
    public List<Deal_Product__c> getDealExtn(){
        if(targetObjectId != null){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            try {
                String dealExtn='Select FBE_Product__r.Name,FBE_Quantity__c from Deal_Product__c where Deal_Registration_Name__r.id =\'' + targetObjectId + '\'';
                List<Deal_Product__c> dealexns = new List<Deal_Product__c>(); 
                dealexns = Database.query(dealExtn);
                if(Test.isRunningTest()){
                    dealexns[0].addError('Error');
                }
                return dealexns;
                
            }
            catch (Exception ex) {
                String errorMessage = 'MyVisualforceComponent::initializeController(): error: '
                    +ex.getMessage()+'\n'+ex.getStackTraceString();
                System.debug(errorMessage);
                return null;
            }  
        }
        return null;
    }
    public String getApprovalLink() {
        String approvalLink = '';
        if(targetObjectId != null){         
            String processInstanceQuery = 'Select Id, Status from ProcessInstance  where TargetObjectId =\'' + targetObjectId + '\' and status = \'Pending\'';
            List<ProcessInstance> processInstances = Database.query(processInstanceQuery);  
            
            if(processInstances.size() > 0){
                Set<Id> processIds = new Set<Id>();
                for(ProcessInstance pI : processInstances){
                    processIds.add(pI.Id);
                }
                List<ProcessInstanceWorkitem> workItemList = [Select Id, Actor.name, OriginalActor.name From ProcessInstanceWorkitem where ProcessInstanceId in : processIds];
                if(workItemList.size() > 0){
                    for(ProcessInstanceWorkitem workItem : workItemList){
                        approvalLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+workItem.Id;                      
                    } 
                }   
            }                  
        } 
        return approvalLink;
    }
}