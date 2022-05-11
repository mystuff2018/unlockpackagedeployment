public with sharing class WorkOrderManualCreation {
    @AuraEnabled(cacheable=true)
    public static void getWorkOrderManualCreation(Id projectId) {
        WorkOrderManualCreationBatch workOderCreationBatch = new WorkOrderManualCreationBatch(projectId, UserInfo.getUserId());
        Database.executeBatch(workOderCreationBatch, 15);
        
    }
}