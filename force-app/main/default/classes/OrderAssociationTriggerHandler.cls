public with sharing class OrderAssociationTriggerHandler extends TriggerHandler {
	
    OrderAssociationDataContext context;

    public OrderAssociationTriggerHandler() {
        try{
            // This need to be refactored because this is spaming events until the FF job finishes.
            List<Order_Association__e> eventsToBeProcessed = OrderAssociationRetryEvent.validateCloneTaskJob(Trigger.new);

            if(!eventsToBeProcessed.isEmpty()){
                context = new OrderAssociationDataContext(eventsToBeProcessed);
            }
        }
        catch(Exception e) {
            insert SaveResultExceptionLogger.createExceptionLogger(e, OrderAssociationTriggerHandler.Class.getName(), 'Order Association');
        }
    }

    public override void afterInsert() {
        try{
            if(context != null){

                System.debug(LoggingLevel.DEBUG, 'afterInsert');
                ProjectEndDateConfiguration.populateProjectEndDate(context);
                OrderAssociationMilestone.updateMilestonesInformation(context);
                OrderAssociationBudget.createProjectBudget(context);
                OrderAssociationTaskCreation.createTasks(context);
                OrderAssociationDealType.updateDealType(context);
                // OrderAssociationForecastDate.calculateForecastCompletionMilestone(context);
                OrderAssociationSalesRep.setProjectSalesRep(context);
                // OrderAssociationProjectType.setProjectType(context);
                OrderAssociationProjectContact.populateProjectContacts(context);
                OrderAssociationProjectLocation.createAndAssociateProjectLocation(context);
                
                OrderAssociationProjectComplexity.calculateProjectComplexity(context);
                OrderAssociationResourceSkillRequest.updateResourceSkillRequest(context);
                ProjectBuidLocalChannelHandler.setBuidAndLocalChannelInProjectWhenOrderAssociated(context);
                ProjectClosedForTimeEntryFlagHandler.setProjectCloseForTimeEntryFlag(context);

                context.save();

                sendNotification();
            }
        }
        catch(Exception e) {
            insert SaveResultExceptionLogger.createExceptionLogger(e, OrderAssociationTriggerHandler.Class.getName(), 'Order Association (After Insert)');
        }
    }
    
    private void sendNotification(){
     
        Map<Id, pse__Proj__c> projectsMap = context.projectMap;   
        Map<Id, OrderItem> orderItemsMap = context.orderItemMap;
        List<OrderItem> listOrderItemsAssociated = context.listOrderItemsAssociated;
        
        if(!projectsMap.isEmpty()){
            Set<String> recipientIds = new Set<String>(); 
            Map<Id, String> notificationListByProjectMap = new Map<Id, String>();
            
            for(pse__Proj__c pj: projectsMap.values()){    
                for(OrderItem orderItem: listOrderItemsAssociated){
                    if(pj.Id == orderItem.Project__c){
                        if(Test.isRunningTest() || string.valueOf(pj.OwnerId).startsWith('005')){
                            recipientIds.add(pj.OwnerId);
                        }
                        notificationListByProjectMap.put(pj.Id, 'Order ' + orderItemsMap.get(orderItem.Id).Dell_Order_Number__c + ' added to the Project' +pj.Name);
                    }
                }
            }
            
            for(Id projectId : notificationListByProjectMap.keySet()){
                Set<String> ownerIdSet = new Set<String>(); 
                
                pse__Proj__c pj = projectsMap.get(projectId);
                
                for(String recipient : recipientIds){
                    if(recipient == pj.OwnerId){
                        ownerIdSet.add(pj.OwnerId);
                        FFNotificationHelper.buildFFNotification('Order was associated', notificationListByProjectMap.get(projectId), projectId, ownerIdSet); 
                    }
                }
            }
            
          //  FFNotificationHelper.postChatter(notificationListByProjectMap);
        }
    }
    
}