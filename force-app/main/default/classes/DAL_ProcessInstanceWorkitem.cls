public class DAL_ProcessInstanceWorkitem {
    public static Map<Id, Id> approvalProcessByOrderItemToProjectApproval(Set<Id> orderItemToProjectApprovalIds) {
        Map<Id, Id> oritaToApprovalProcess = new Map<Id, Id>();

        if(orderItemToProjectApprovalIds.size() > 0){
            for(ProcessInstanceWorkitem approvalProcess : [SELECT Id, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: orderItemToProjectApprovalIds]){
                oritaToApprovalProcess.put(approvalProcess.ProcessInstance.TargetObjectId, approvalProcess.Id);
            }
        }
        
        return oritaToApprovalProcess;
    }
}