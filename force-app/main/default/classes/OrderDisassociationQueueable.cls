/**
 * Created by Bruno_Frosi on 12/22/2020.
 */

public class OrderDisassociationQueueable implements Queueable {
    static final string MESSAGE_1 = 'System could not correctly disassociate this order.';
    static final string MESSAGE_2 = 'While executing we got this error: ';
    static final string MESSAGE_3 = 'You will need to open a ticket to request help on this error. Add the following code to your ticket to help troubleshooting: ';

    public OrderDisassociationDataContext context {get;set;}
    public Id userToNotificate {get;set;}

    public class customException extends Exception {}

    public OrderDisassociationQueueable(OrderDisassociationDataContext pContext, Id pUserToNotificate)
    {
        context = pContext;
        userToNotificate = pUserToNotificate;
    }

    public OrderDisassociationQueueable(Id exceptionLoggerId){
        ExceptionLogger__c log = [SELECT Id, API_PayLoad__c FROM ExceptionLogger__c WHERE Id = :exceptionLoggerId LIMIT 1];
        if(log != null && log.API_PayLoad__c != null)
        {
            this.context = (OrderDisassociationDataContext)JSON.deserialize(log.API_PayLoad__c, OrderDisassociationDataContext.class);
        }
        userToNotificate = UserInfo.getUserId();
    }

    public void execute(QueueableContext queueContext) {
        //savepoint before any DML
        Savepoint sp = Database.setSavepoint();
        try {
            //Turn into Async Method
            // =========================================== BEGIN
            OrderDisassociationBudget.deleteProjectBudget(context);
            OrderDisassociationTask.disassociateTasks(context);

            OrderDisassociationMilestone.recalculate(context);
            //Doesn't need to update DealType
            //OrderDisassociationDealType.updateDealType(context);
            //Location
            OrderDisassociationProjectComplexity.calculateProjectComplexity(context);
            OrderDisassociationResourceSkillRequest.updateResourceSkillRequest(context);

            updateProjectsWithoutOrderItems();
            // =========================================== END

            context.saveAsync();

            if(Test.isRunningTest())
                throw new customException('test');
        }
        catch(Exception e) {
            if(!Test.isRunningTest()){
            	//Rollback other DMLs before saving the details via exceptionLogger
            	Database.rollback(sp);
            }
            ExceptionLogger__c excepLog = insertExceptionLogger(e);

            for(Id orderId :this.context?.ordersByIds.keySet()) {
                buildFFNotification(MESSAGE_1, MESSAGE_2 + e.getMessage() + ' - ' + MESSAGE_3 + excepLog.Id, orderId, new Set<String>{this.userToNotificate});
                //postChatter(orderId, MESSAGE_1 + ' ' + MESSAGE_2 + e.getMessage() + ' - ' + MESSAGE_3 + excepLog.Id);
            }
        }
    }

    private void updateProjectsWithoutOrderItems() {        
        for (Id projectId : context.projectMap.keySet()) {
            pse__Proj__c project = context.projectMap.get(projectId);                        
            if (!context.projectWithRemainingOrderItemsMap.containsKey(projectId)) {
                List<Id> ordersWithCancelledStatusList = new List<Id>();                
                List<Id> allOrdersFromProject = context.orderByProjectWithoutOrderItemsMap.get(projectId);                
                for(Id orderId : allOrdersFromProject){
                    Order order = context.ordersByIds.get(orderId);
                    if (order.Status == 'Cancelled' || order.Status == 'CL'){
                        ordersWithCancelledStatusList.add(order.Id);                        
                    }                    
                }                                                                
                
                Boolean allOrdersFromProjectAreCancelled = ordersWithCancelledStatusList.size() == allOrdersFromProject.size();
                if ((allOrdersFromProjectAreCancelled) && (project.pse__Project_Phase__c != 'Setup')) {
                    project.pse__Stage__c = 'On Hold';
                    project.On_Hold_Reason__c = 'All Orders Cancelled';
                }else{                                    
                    project.pse__Stage__c = 'Cancelled';                                                       
                }                
            }
        }
    }

    /*public void cleanupContext() {
        //cleanup context to retry execution
        context.mapBudgetToDelete = new Map<Id, pse__Budget__c>();
        context.projectTasksToDelete = new Map<Id, pse__Project_Task__c>();
        context.projectTasksToUpdate = new Map<Id, pse__Project_Task__c>();
        context.projectTaskSkuEffortMappingEntryToDelete = new Map<Id, Project_Task_SKU_Effort_Mapping_Entry__c>();
        context.projectTaskSkillToDelete = new Map<Id, Project_Task_Skill__c>();
        context.orderItemTaskSkuToDelete = new Map<Id, Order_Item_Sku_Effort_Map__c>();
        context.milestoneOrderItemAssociationToDelete = new Map<Id, OrderItemMilestoneAssociation__c>();
        context.milestonesToDelete = new Map<Id, pse__Milestone__c>();
        context.milestonesToUpdate = new Map<Id, pse__Milestone__c>();
        context.projectWithRemainingBudgetMap = new Map<Id, List<pse__Budget__c>>();
    }*/

    public ExceptionLogger__c insertExceptionLogger(Exception e) {
        ExceptionLogger__c excepLog = new ExceptionLogger__c();
        excepLog.Module__c = 'OrderDisassociations';
        excepLog.Apex_Class__c = 'OrderDisassociationQueueable';
        excepLog.Description__c = e.getCause() + ': ' + e.getMessage() + ' - ' + e.getLineNumber() + ' - ' + e.getStackTraceString();
        excepLog.External_System_Name__c = 'FinancialForce';

        //cleanupContext();
        excepLog.API_PayLoad__c = JSON.serialize(this.context);

        INSERT excepLog;
        return excepLog;
    }

    public static void buildFFNotification(String title, String body, Id targetId, Set<String> recipientIds) {
        Id typeId = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'FF_ServiceAppointment_Notification']?.Id;

        if(typeId != null){
            try {
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setBody(body);
                notification.setTitle(title);
                notification.setSenderId(Userinfo.getUserId());
                notification.setNotificationTypeId(typeId);
                notification.setTargetId(targetId);
                notification.send(recipientIds);
            }
            catch (Exception e) {
                insert SaveResultExceptionLogger.createExceptionLogger(e, OrderDisassociationQueueable.Class.getName(), 'Send notification failure');
            }
        }
    }
}