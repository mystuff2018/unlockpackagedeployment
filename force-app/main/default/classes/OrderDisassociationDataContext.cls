/**
 * @File Name          : OrderDisassociationDataContext.cls
 * @Description        : Load all data used on disassociation order from project flow.
 * @Author             : Leonardo Santos | 2/19/2020
**/
public without sharing class OrderDisassociationDataContext extends DataContext{

    public Map<Id, List<OrderItem>> projectOrderItemsToBeDissociateMap { get; set; }
    public Map<Id, List<OrderItem>> InactiveprojectToOrderItems { get; set; }                                                              
    public Map<Id, List<OrderItem>> projectWithAllOrderItemsMap { get; set; }
    public Map<Id, List<OrderItem>> projectWithRemainingOrderItemsMap { get; set; }
    public Map<Id, Order> ordersByIds  { get; set; }
    public List<OrderItem> orderItemsToBeDissociateList  { get; set; }
    public List<Order> ordersToBeDissociateList  { get; set; }
    public Map<Id, pse__Proj__c> projectMap { get; set; }
    public Sku_Effort_Map__c customSku  { get; set; }
    public Map<String, Sku_Effort_Map__c> skuEffortMapForRemainingItems { get; set; }
    public Map<Id, List<pse__Budget__c>> projectWithAllBudgetMap {get; set;}
    public Map<Id, List<pse__Budget__c>> projectWithRemainingBudgetMap {get; set;}
    public Map<Id, pse__Budget__c> mapBudgetToDelete {get; set;}
    public Map<Id, OrderItemMilestoneAssociation__c> orderItemApprovedMilestoneAssociationMap { get; set; }
    public Map<Id, OrderItemMilestoneAssociation__c> orderItemMilestoneAssociationMap { get; set; }
    public Map<Id, pse__Milestone__c> milestonesToDelete { get; set; }
    public Map<Id, pse__Milestone__c> milestonesToUpdate { get; set; }
    public Map<Id, OrderItemMilestoneAssociation__c> milestoneOrderItemAssociationToDelete { get; set; }
    public Map<Id, pse__Project_Task__c> projectTasksToDelete { get; set; }
    public Map<Id, pse__Project_Task__c> projectTasksToUpdate { get; set; }
    public Map<Id, Project_Task_SKU_Effort_Mapping_Entry__c> projectTaskSkuEffortMappingEntryToDelete { get; set; }
    public Map<Id, Order_Item_Sku_Effort_Map__c> orderItemTaskSkuToDelete { get; set; }
    public Map<Id, Project_Task_Skill__c> projectTaskSkillToDelete { get; set; }
    public List<String> listItemClassDescription {get;set;}
    public Map<Id, List<Skill_SKU_Effort_Map_Entry__c>> skillsSKUByProjectId {get;set;}
    public Map<Id, pse__Proj__c> engagementsToUpdateMap {get;set;}
    public FFProcessExecutionControl executionControl;

    public Map<Id, List<String>> orderIdToPreventReason { get; set; }

    public List<ExceptionLogger__c> exceptionLoggers {get;set;}
    public Map<Id, List<OrderItem>> orderIdToOrderItems {get; set;}
    public List<OrderItemToProjectApproval__c> orderItemToProjectApprovalToRemove {get; set;}
    public Map<Id, Id> approvalProcessByOrderItemToProjectApproval {get; set;}
    public Map<Id, List<Id>> orderByProjectWithoutOrderItemsMap {get;set;}
    
    public Map<Id, pse__Proj__c> inactiveProjectMap { get; set; }

    public OrderDisassociationDataContext(Set<Id> orderId) { 
        orderIdToPreventReason = new Map<Id, List<String>>();
        exceptionLoggers = new List<ExceptionLogger__c>();
        milestonesToDelete = new Map<Id, pse__Milestone__c>();
        milestonesToUpdate = new Map<Id, pse__Milestone__c>();
        milestoneOrderItemAssociationToDelete = new Map<Id, OrderItemMilestoneAssociation__c>();
        projectWithRemainingBudgetMap = new Map<Id, List<pse__Budget__c>>();
        mapBudgetToDelete = new Map<Id, pse__Budget__c>();
        projectTasksToDelete = new Map<Id, pse__Project_Task__c>();
        projectTasksToUpdate = new Map<Id, pse__Project_Task__c>();
        projectTaskSkuEffortMappingEntryToDelete = new Map<Id, Project_Task_SKU_Effort_Mapping_Entry__c>();
        orderItemTaskSkuToDelete = new Map<Id, Order_Item_Sku_Effort_Map__c>();
        projectTaskSkillToDelete = new Map<Id, Project_Task_Skill__c>();
        skillsSKUByProjectId = new Map<Id, List<Skill_SKU_Effort_Map_Entry__c>>();
        orderIdToOrderItems = new Map<Id, List<OrderItem>>();
        orderItemToProjectApprovalToRemove = new List<OrderItemToProjectApproval__c>();
        approvalProcessByOrderItemToProjectApproval = new Map<Id, Id>();
        engagementsToUpdateMap = new Map<Id, pse__Proj__c>();
        orderByProjectWithoutOrderItemsMap = new Map<Id, List<Id>>();
		inactiveProjectToOrderItems = new Map<Id, List<OrderItem>> ();
        refresh(orderId);
    }

    public override void refresh(Set<Id> orderIdSet) {
        executionControl = new FFProcessExecutionControl(orderIdSet);
        ordersByIds = DAL_Order.getOrdersByIds(orderIdSet);
        projectOrderItemsToBeDissociateMap = getProjectOrderItemsToBeDissociateMap(orderIdSet);
        projectWithAllOrderItemsMap = DAL_OrderItem.getOrderItensByProjectIds(projectOrderItemsToBeDissociateMap.keySet());
        projectWithRemainingOrderItemsMap = getRemainingProjects();
        projectMap = DAL_Project.getProjectByIds(projectWithAllOrderItemsMap.keySet());
        DAL_Sku.SkuMap skuMap = DAL_Sku.getSkuEffortByOrderItens(projectWithAllOrderItemsMap);
        skuEffortMapForRemainingItems = skuMap.skuNumberToSkuEffortMap;
        customSku = skuMap.customSku;
        orderItemApprovedMilestoneAssociationMap = getApprovedMilestoneOrderItemMap();
        orderItemMilestoneAssociationMap = getMilestoneOrderItemMap();
        projectWithAllBudgetMap = DAL_Budget.getBudgetsByProjectIds(projectWithAllOrderItemsMap.keySet());
        listItemClassDescription = DAL_ItemClass.getListItemClassDescription();
        skillsSKUByProjectId = getSkillsSKUByProjectIdMap();
        orderIdToOrderItems = DAL_OrderItem.getOrderItemByOrderId(orderIdSet);
        approvalProcessByOrderItemToProjectApproval = getApprovalProcessByOrderItemToProjectApproval();        
        orderByProjectWithoutOrderItemsMap = getProjectsWithAllOrders();
        inactiveProjectMap = DAL_Project.getProjectByIds(inactiveProjectToOrderItems.keySet());
    }

    private Map<Id, List<Id>> getProjectsWithAllOrders(){
        Map<Id, List<Id>> orderByProjectOrderItemsMap = new Map<Id, List<Id>>();
    
        for (Id projectId : projectOrderItemsToBeDissociateMap.keySet()){
            List<Id> ordersId = new List<Id>();

            for(OrderItem orderItem : projectOrderItemsToBeDissociateMap.get(projectId)){
                if (!ordersId.contains(orderItem.OrderId)){
                    ordersId.add(orderItem.OrderId);    
                }
            }            

            if (!orderByProjectOrderItemsMap.containsKey(projectId)){
                orderByProjectOrderItemsMap.put(projectId, ordersId);
            }
        }
        
        return orderByProjectOrderItemsMap;
    }

    public override void save() {
        //The only responsability for the OrderTrigger is to handler statuses updates, no reason to execute here
        TriggerHandler.bypass(FFOrderTriggerHandler.class.getName());
        TriggerHandler.bypass(FFProjectTaskTriggerHandler.class.getName());

        Set<Id> IdsToSend = new Set<Id>();
        if(ordersByIds != null && ordersByIds.size() > 0)
        {
            IdsToSend = ordersByIds.keySet();
        }

        if (orderItemsToBeDissociateList != null) {
            List<Database.SaveResult> orderItemUpdateResults = Database.update(orderItemsToBeDissociateList);
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(IdsToSend, null, orderItemUpdateResults, OrderDisassociationDataContext.class.getName()));
        }

        if (ordersToBeDissociateList != null) {
            cleanMilestoneLookup();
            List<Database.SaveResult> orderUpdateResults = Database.update(ordersToBeDissociateList);
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(IdsToSend, null, orderUpdateResults, OrderDisassociationDataContext.class.getName()));
        }

        if(orderItemToProjectApprovalToRemove != null){
            List<Database.DeleteResult> orderItemToApprovalProcessDeleteResults = Database.delete(orderItemToProjectApprovalToRemove);
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(IdsToSend, orderItemToApprovalProcessDeleteResults, OrderDisassociationDataContext.class.getName()));
        }

        executionControl.insertControls();
        SaveResultExceptionLogger.systemDebugLog(IdsToSend, Database.upsert(exceptionLoggers, false));
    }

    public void saveAsync() {
        //The only responsability for the OrderTrigger is to handler statuses updates, no reason to execute here
        TriggerHandler.bypass(FFOrderTriggerHandler.class.getName());
        TriggerHandler.bypass(FFProjectTaskTriggerHandler.class.getName());

        Set<Id> IdsToSend = new Set<Id>();
        if(ordersByIds != null && ordersByIds.size() > 0)
        {
            IdsToSend = ordersByIds.keySet();
        }

        if(milestoneOrderItemAssociationToDelete != null)
        {
            List<Database.DeleteResult> milestoneAssociationDeleteRes = Database.delete(milestoneOrderItemAssociationToDelete.values());
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(IdsToSend, milestoneAssociationDeleteRes, OrderDisassociationDataContext.class.getName()));
        }
        if(milestonesToDelete != null)
        {
            List<Database.DeleteResult> milestoneDeleteRes = Database.delete(milestonesToDelete.values());
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(IdsToSend, milestoneDeleteRes, OrderDisassociationDataContext.class.getName()));
        }

        if(milestonesToUpdate != null){
            List<Database.SaveResult> milestonesToUpdateResults = Database.update(milestonesToUpdate.values());
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(IdsToSend, null, milestonesToUpdateResults, OrderDisassociationDataContext.class.getName()));
        }
        
        if(projectTasksToUpdate != null)
        {
            List<Database.SaveResult> projectTasksUpdateResults = Database.update(projectTasksToUpdate.values());
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(IdsToSend, null, projectTasksUpdateResults, OrderDisassociationDataContext.class.getName()));
        }

        if(projectTasksToDelete != null)
        {
            List<Database.DeleteResult> projectTasksDeleteRes = Database.delete([SELECT Id FROM pse__Project_Task__c WHERE Id IN :projectTasksToDelete.keySet()]);
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(IdsToSend, projectTasksDeleteRes, OrderDisassociationDataContext.class.getName()));
        }

        if(projectTaskSkuEffortMappingEntryToDelete != null)
        {
            List<Database.DeleteResult> projectTaskSkuEffortMappingEntryDeleteRes = Database.delete(projectTaskSkuEffortMappingEntryToDelete.values());
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(IdsToSend, projectTaskSkuEffortMappingEntryDeleteRes, OrderDisassociationDataContext.class.getName()));
        }
        if(orderItemTaskSkuToDelete != null)
        {
            List<Database.DeleteResult> orderItemTaskSkuDeleteRes = Database.delete(orderItemTaskSkuToDelete.values());
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(IdsToSend, orderItemTaskSkuDeleteRes, OrderDisassociationDataContext.class.getName()));
        }
        if(projectTaskSkillToDelete != null)
        {
            List<Database.DeleteResult> projectTaskSkillDeleteRes = Database.delete(projectTaskSkillToDelete.values());
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(IdsToSend, projectTaskSkillDeleteRes, OrderDisassociationDataContext.class.getName()));
        }

        List<Database.DeleteResult> budgetDeleteResults = Database.delete(mapBudgetToDelete.values());
        exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(IdsToSend, budgetDeleteResults, OrderDisassociationDataContext.class.getName()));

        // Projects
        List<Database.SaveResult> projectUpdateResults = Database.update(projectMap.values());
        exceptionLoggers.addAll(
                SaveResultExceptionLogger.saveResultsLog(projectUpdateResults, null, IdsToSend, OrderDisassociationDataContext.class.getName(), 'Project Update')
        );

        // Engagements
        List<Database.SaveResult> engagementUpdateResults = Database.update(engagementsToUpdateMap.values());
        exceptionLoggers.addAll(
                SaveResultExceptionLogger.saveResultsLog(engagementUpdateResults, null, IdsToSend, OrderDisassociationDataContext.class.getName(), 'Engagement Update')
        );

        executionControl.insertControls();
        SaveResultExceptionLogger.systemDebugLog(IdsToSend, Database.upsert(exceptionLoggers, false));
    }

    private void cleanMilestoneLookup(){
        //If any order relates to a milestone that is listed to be deleted, set the field blank
        if(milestonesToDelete.size() > 0){
            for(Order order :ordersToBeDissociateList){
                if(order.Milestone__c != null && milestonesToDelete.containsKey(order.Milestone__c)){
                    order.Milestone__c = null;
                }
            }
        }
    }

    private Map<Id, List<OrderItem>> getProjectOrderItemsToBeDissociateMap (Set<Id> orderIds) {
        Map<Id, List<OrderItem>> orderItemByOrderId = DAL_OrderItem.getOrderItemByOrderId(orderIds);

        Map<Id, List<OrderItem>> projectOrderItemsToBeDissociateMap = new Map<Id, List<OrderItem>>();
        
        for (Id ordId : orderItemByOrderId.keySet()) {
            List<OrderItem> listOrderItems = orderItemByOrderId.get(ordId);
            for (OrderItem item : listOrderItems) {
                if (item.Project__c != null) {
                    //Added a validation to block Orders to be dissociated from Inactive Projects - TFS STORY 10466018
                   if(!item.Project__r.pse__Is_Active__c){
                        if(!orderIdToPreventReason.containsKey(item.OrderId)) {
                            orderIdToPreventReason.put(item.OrderId, new List<String>());
                        	System.debug('Inactive check'+orderIdToPreventReason);
                            List<String> orderMessages = orderIdToPreventReason.get(item.OrderId);
                            orderMessages.add('The Order is associated to an Inactive Project, thus the Order cannot be dissociated.');
                            
                            orderIdToPreventReason.put(item.OrderId, orderMessages);
                        }
                       //Added as a part of story 10466018 for InActive Notification
                       system.debug('orderIdToPreventReason...'+orderIdToPreventReason);
                       system.debug('OrderDisassociationHandler.sendInactiveProjectNotification...'+FFOrderTriggerHandler.sendInactiveProjectNotification);
                      if (FFOrderTriggerHandler.sendInactiveProjectNotification) {
                           if (!inactiveProjectToOrderItems.containsKey(item.Project__c)) {
                               inactiveProjectToOrderItems.put(item.Project__c, new List<OrderItem> ());
                           }
                           inactiveProjectToOrderItems.get(item.Project__c).add(item);
                       }

                        continue;
                    }

                    if(!projectOrderItemsToBeDissociateMap.containsKey(item.Project__c)){
                        projectOrderItemsToBeDissociateMap.put(item.Project__c, new List<OrderItem>());
                    }
                    List<OrderItem> orderItems = projectOrderItemsToBeDissociateMap.get(item.Project__c);
                    orderItems.add(item);
                    orderItemByOrderId.put(item.Project__c, orderItems);
                }
            }
        }

        return projectOrderItemsToBeDissociateMap;
    }
    
    private Map<Id, OrderItemMilestoneAssociation__c> getMilestoneOrderItemMap() {
    	Set<Id> orderItemIdsSet = new Set<Id>();
        if(projectWithAllOrderItemsMap != null && projectWithAllOrderItemsMap.size() > 0)
        {
            for(Id projectId : projectWithAllOrderItemsMap.keySet()) {
                orderItemIdsSet.addAll(new Map<Id, OrderItem>(projectWithAllOrderItemsMap.get(projectId)).keySet());
            }
        }

        return DAL_Milestone.getMilestonesByOrderItemIds(orderItemIdsSet);
    }
    
    private Map<Id, OrderItemMilestoneAssociation__c> getApprovedMilestoneOrderItemMap() {
    	Set<Id> orderItemIdsSet = new Set<Id>();
        if(projectWithAllOrderItemsMap != null && projectWithAllOrderItemsMap.size() > 0)
        {
            for(Id projectId : projectWithAllOrderItemsMap.keySet()) {
                orderItemIdsSet.addAll(new Map<Id, OrderItem>(projectWithAllOrderItemsMap.get(projectId)).keySet());
            }
        }

        return DAL_Milestone.getApprovedMilestonesByOrderItemIds(orderItemIdsSet);
    }

    private  Map<Id, List<OrderItem>> getRemainingProjects() { 
        this.projectWithRemainingOrderItemsMap = new Map<Id, List<OrderItem>>();
        
        for (Id projectId : projectWithAllOrderItemsMap.keySet()) {
            Map<Id, OrderItem> orderItems = new Map<Id, OrderItem>(projectWithAllOrderItemsMap.get(projectId));
            Map<Id, OrderItem> orderItemsToBeDissociate = new Map<Id, OrderItem>(projectOrderItemsToBeDissociateMap.get(projectId));
            for (Id orderItemId : orderItems.keySet()) {
               if (!orderItemsToBeDissociate.containsKey(orderItemId)) {
                    if(!projectWithRemainingOrderItemsMap.containsKey(projectId)) {
                        projectWithRemainingOrderItemsMap.put(projectId, new List<OrderItem>());
                    }
                    List<OrderItem> orderItemsRemainingList = projectWithRemainingOrderItemsMap.get(projectId);
                    orderItemsRemainingList.add(orderItems.get(orderItemId));
                    projectWithRemainingOrderItemsMap.put(projectId, orderItemsRemainingList);
               }
            }
        }
        return projectWithRemainingOrderItemsMap;
    }

    private Map<Id, List<Skill_SKU_Effort_Map_Entry__c>> getSkillsSKUByProjectIdMap(){

        Map<Id, List<Skill_SKU_Effort_Map_Entry__c>> allEntrySkills = DAL_Sku.getSkillSkuBySkuEntry(skuEffortMapForRemainingItems.values());

        for(Id projectId: projectWithRemainingOrderItemsMap.keySet()){
            List<Skill_SKU_Effort_Map_Entry__c> existingSkillSKUFromProject = skillsSKUByProjectId.get(projectId);
            if(existingSkillSKUFromProject == null){
                existingSkillSKUFromProject = new List<Skill_SKU_Effort_Map_Entry__c>();
            }
            
            List<OrderItem> orderItemList = projectWithRemainingOrderItemsMap.get(projectId);

            if(orderItemList != null){
                for(OrderItem orderItem: orderItemList){
                    Sku_Effort_Map__c skuEffort = skuEffortMapForRemainingItems.get(orderItem.Sku_Number__c);
                
                    if(skuEffort != null){
    
                        List<SKU_Effort_Map_Entry__c> entryList = skuEffort.SKU_Effort_Map_Entries__r;
                        
                        for(SKU_Effort_Map_Entry__c entry: entryList){
                            List<Skill_SKU_Effort_Map_Entry__c> skillSkuList = allEntrySkills.get(entry.Id);
                            if(skillSkuList != null){
                                existingSkillSKUFromProject.addAll(skillSkuList);
                                skillsSKUByProjectId.put(projectId, existingSkillSKUFromProject);
                            }
                        }
                    }
                }
            }
            
        }

        return skillsSKUByProjectId;
    }

    private Map<Id, Id> getApprovalProcessByOrderItemToProjectApproval(){
        Set<Id> orderItemToProjectApprovalIds = new Set<Id>();
        for(List<OrderItem> orderItems : orderIdToOrderItems.values()) {
            for(OrderItem orderItem : orderItems) {
                if(orderItem.OrderItemToProjectApproval__c != null)
                    orderItemToProjectApprovalIds.add(orderItem.OrderItemToProjectApproval__c);
            }
        }
    
        return DAL_ProcessInstanceWorkitem.approvalProcessByOrderItemToProjectApproval(orderItemToProjectApprovalIds);
    }
}