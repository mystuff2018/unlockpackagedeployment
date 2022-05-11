/**
 * @description OrderAssociationDataContext
 * @author Magaiver_Oliveira | 1/20/2020
 */
public class OrderAssociationDataContext extends DataContext {

    public List<Order_Association__e> eventList{get;set;}
    public Map<Id, Id> orderToBeAssociated{get;set;}
    public Map<Id, Id> orderItemsToBeAssociated{get;set;}
    public Map<Id, Order> orderMap { get; set; }
    public Map<Id, pse__Proj__c> projectMap { get; set; }
    public Map<Id, OrderItem> orderItemMap { get; set; }
    public Map<Id, List<pse__Milestone__c>> projectIdToMilestoneListMap {get;set;}
    public Map<Id, List<pse__Budget__c>> projectIdToBudgetListMap {get;set;}
    public Map<Id, List<pse__Budget__c>> projectIdToExistentBudgetListMap {get;set;} //Create a map with budgets existent in DB
    public Map<Id, List<Project_Contact__c>> projectIdProjectContactMap {get;set;} 
    public Map<Id, Set<Id>> projectWithOrdersMap {get;set;}
    public Map<Id, List<OrderItem>> projectWithAllOrderItems {get;set;}
    public List<pse__Milestone__c> newMilestones {get;set;}
    public List<Project_Contact__c> newProjectContact {get;set;}
    public List<OrderItemMilestoneAssociation__c> newOrderItemsToMilestoneRelationship {get;set;}
    public Map<String, Sku_Effort_Map__c> skuEffortMap {get;set;}
    public Map<Id, List<pse__Project_Task__c>> projectWithTasks {get;set;}
    public Map<Id, List<Skill_SKU_Effort_Map_Entry__c>> skillsFromProject {get;set;}
    
    public List<ExceptionLogger__c> exceptionLoggers {get;set;}
    public List<OrderItem> listOrderItemsAssociated {get;set;}

    public Map<Id, Contact> mapContact {get;set;}
    public Map<Id, Schema.Location> mapContactIdLocation {get;set;}
    public Map<Id, Schema.Location> mapAccountIdLocation {get;set;}
    public Map<Id, List<Schema.Location>> mapAccountIdListLocation {get;set;}
    public Map<Id, List<Schema.Address>> mapLocationIdListAddress {get;set;}
    public Map<Id, List<Project_Location__c>> mapProjectIdListProjectLocation {get;set;}
    public List<Project_Location__c> saveProjectLocation {get;set;}
    public List<Schema.Address> saveAddress {get;set;}
    public Sku_Effort_Map__c customSku  {get;set;}
    public List<String> listItemClassDescription {get;set;}
    public FFProcessExecutionControl executionControl;
    
    public Set<String> existingProjTaskSKUEffortMappingEntry {get;set;}

    public OrderAssociationDataContext(List<Order_Association__e> dataToAssociate) {
        System.debug(LoggingLevel.DEBUG, 'OrderAssociationDataContext');
        this.eventList = dataToAssociate;
        refresh();
    }

    public override void refresh() {
        System.debug(LoggingLevel.DEBUG, 'refresh()');       
        
        
        populateOrderItemAndProjectFromEvent(eventList);
        
        orderMap = DAL_Order.getOrdersByIds(new Set<Id>(orderToBeAssociated.keySet()));
        projectMap = DAL_Project.getProjectByIds(new Set<Id>(orderItemsToBeAssociated.values()));
        projectIdToMilestoneListMap = DAL_Milestone.getMilestonesByProjectId(projectMap);
        orderItemMap = DAL_OrderItem.getOrderItensByIds(orderItemsToBeAssociated.keySet());
        this.projectWithAllOrderItems = populateProjectWithAllOrderItems(orderItemsToBeAssociated);
        DAL_Sku.SkuMap skuMap = DAL_Sku.getSkuEffortByOrderItens(projectWithAllOrderItems);
        skuEffortMap = skuMap.skuNumberToSkuEffortMap;
        customSku = skuMap.customSku;
        projectIdProjectContactMap = DAL_ProjectContact.getMapProjectIdListProjectContact(projectMap.keySet());
        projectIdToExistentBudgetListMap = DAL_Budget.getBudgetsByProjectIds(projectMap.keySet());
        initProjectLocation();
        
        executionControl = new FFProcessExecutionControl(orderMap.keySet());
        
        projectIdToBudgetListMap = new Map<Id, List<pse__Budget__c>>();
        newProjectContact = new List<Project_Contact__c>();
        exceptionLoggers = new List<ExceptionLogger__c>();
        listItemClassDescription = DAL_ItemClass.getListItemClassDescription();
        newOrderItemsToMilestoneRelationship = new List<OrderItemMilestoneAssociation__c>();
        newMilestones = new List<pse__Milestone__c>();
        getExistingProjTaskSKUEffortMapping();
    }

    public override void save() {
        System.debug(LoggingLevel.DEBUG,  'save()');

        Set<Id> objectList = new Set<Id>();
        objectList.addAll(orderMap.keySet());
        objectList.addAll(projectMap.keySet());

        updateOrdersWithProject();

        // Project contacts
        List<Database.UpsertResult> contactsInsertResults = Database.upsert(newProjectContact, false);
        exceptionLoggers.addAll(
            SaveResultExceptionLogger.saveResultsLog(null, contactsInsertResults, objectList, OrderAssociationDataContext.class.getName(), 'Project Contact Upsert')
        );

        // Budgets
        List<Database.UpsertResult> budgetsInsertResults = insertBudgets();
        exceptionLoggers.addAll(
            SaveResultExceptionLogger.saveResultsLog(null, budgetsInsertResults, objectList, OrderAssociationDataContext.class.getName(), 'Budget Upsert')
        );
        
        // Relationship Between OrderItem and Milestone
        List<Database.UpsertResult> newOrderItemsToMilestoneRelationshipResults = Database.upsert(newOrderItemsToMilestoneRelationship, false);
        exceptionLoggers.addAll(
            SaveResultExceptionLogger.saveResultsLog(null, newOrderItemsToMilestoneRelationshipResults, objectList, OrderAssociationDataContext.class.getName(), 'OrderItemMilestoneAssociation__c Upsert')
        );
        
        // Project Location Adress Schema
        List<Database.UpsertResult> addressResults = Database.upsert(saveAddress, false);
        exceptionLoggers.addAll(
            SaveResultExceptionLogger.saveResultsLog(null, addressResults, objectList, OrderAssociationDataContext.class.getName(), 'Project Location Adress Schema Upsert')
        );
        
        // Project Location
        List<Database.UpsertResult> projectLocationResults = Database.upsert(saveProjectLocation, false);
        exceptionLoggers.addAll(
            SaveResultExceptionLogger.saveResultsLog(null, projectLocationResults, objectList, OrderAssociationDataContext.class.getName(), 'Project Location Upsert')
        );
                
        // Projects
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                List<Database.SaveResult> projectUpdateResults = Database.update(projectMap.values());
        exceptionLoggers.addAll(
            SaveResultExceptionLogger.saveResultsLog(projectUpdateResults, null, objectList, OrderAssociationDataContext.class.getName(), 'Project Update')
        );
        
        updateEngagementStage();

        SaveResultExceptionLogger.systemDebugLog(orderMap.keySet(), projectMap.keySet(), Database.upsert(exceptionLoggers, false));

        executionControl.insertControls();
    }
    
    private void getExistingProjTaskSKUEffortMapping(){
        existingProjTaskSKUEffortMappingEntry = new Set<String>();
        for(Project_Task_SKU_Effort_Mapping_Entry__c ptseme :[SELECT Id, Project_Task__c, SKU_Effort_Mapping_Entry__c 
                                                              FROM Project_Task_SKU_Effort_Mapping_Entry__c 
                                                              WHERE Project_Task__r.pse__Project__c IN :projectMap.keySet()])
        {
            existingProjTaskSKUEffortMappingEntry.add(ptseme.SKU_Effort_Mapping_Entry__c +''+ ptseme.Project_Task__c);
        }
    }
    
    private void updateOrdersWithProject(){
        listOrderItemsAssociated = new List<OrderItem>();
        List<OrderItem> listOrderItems = new List<OrderItem>();        
        Set<Id> orderItemsIds = new Set<Id>();
        System.debug('orderItemsToBeAssociated: '+orderItemsToBeAssociated);
        for(Id orderItemId :orderItemsToBeAssociated.keySet()) {
            if(!orderItemsIds.contains(orderItemId)){
                orderItemsIds.add(orderItemId);
                OrderItem orderItem = orderItemMap.get(orderItemId);
    
                String payload = 'OrderItem: ' + orderItemId + '(' + orderItem.SKU_Number__c + ') - Project: ' + orderItemsToBeAssociated.get(orderItemId);
                executionControl.setProcessLog(orderItem.OrderId, payload, 'OrderAssociationDataContext: associate order item to project');
    
                listOrderItems.add(new OrderItem(Id = orderItemId, Project__c = orderItemsToBeAssociated.get(orderItemId)));
                
            }
        }
        System.debug('listOrderItems : '+listOrderItems);
        listOrderItemsAssociated = listOrderItems;
        List<Database.saveResult> listOrderItemsResults = Database.update(listOrderItems, false);
        exceptionLoggers.addAll(
            SaveResultExceptionLogger.saveResultsLog(listOrderItemsResults, null, orderItemsIds, OrderAssociationDataContext.class.getName(), 'Ordem item to project association')
        );
    }

    private List<Database.UpsertResult> insertBudgets(){
        List<pse__Budget__c> budgets = new List<pse__Budget__c>();
        List<pse__Budget__c> budgetsToInsert = new List<pse__Budget__c>();

        for(Id projectId :projectIdToBudgetListMap.keySet()){
            budgets.addAll(projectIdToBudgetListMap.get(projectId));
        }
        
        for(pse__Budget__c budget : budgets){
            if(budget.Id != null)
                continue;
            
            budgetsToInsert.add(budget);
        }

        // Insert budgets
        List<Database.UpsertResult> budgetsInsertResults = Database.upsert(budgetsToInsert, false);
        
        return budgetsInsertResults;
    }

    private void populateOrderItemAndProjectFromEvent(List<Order_Association__e> events) { 

        this.projectWithOrdersMap = new Map<Id, Set<Id>>();
        this.orderToBeAssociated = new Map<Id, Id>();
        this.orderItemsToBeAssociated = new Map<Id, Id>();       

        for(Order_Association__e event: events){

            orderItemsToBeAssociated.put(Id.valueOf(event.Order_Item_Id__c), Id.valueOf(event.Project_ID__c));
            orderToBeAssociated.put(Id.valueOf(event.Order_ID__c), Id.valueOf(event.Project_ID__c));

            if(this.projectWithOrdersMap.get(event.Project_id__c) == null) {
                this.projectWithOrdersMap.put(event.Project_id__c, new Set<Id>());
            }

            Set<Id> orders = this.projectWithOrdersMap.get(event.Project_id__c);
            orders.add(event.Order_id__c);
            this.projectWithOrdersMap.put(event.Project_id__c, orders);
        }
    }

    private Map<Id, List<OrderItem>> populateProjectWithAllOrderItems(Map<Id, Id> orderItems){
        Map<Id, List<OrderItem>> projectWithAllOrderItems = new Map<Id, List<OrderItem>>();
                
        Set<Id> projectIds = new Set<Id>();
        for (Id id : orderItems.keySet()) {
            Id projectId = orderItems.get(id);
            projectIds.add(projectId);
        }
        System.debug('projectWithAllOrderItems Proj Ids: '+ projectIds);
        System.debug('projectWithAllOrderItems orderItems: '+orderItems);

        //Get all order items to be associated
        for (Id id : orderItems.keySet()) {
            Id projectId = orderItems.get(id);
            List<OrderItem> orderItensList = projectWithAllOrderItems.get(projectId);
            if (orderItensList == null) {
                orderItensList = new List<OrderItem>();
            }
            orderItensList.add(orderItemMap.get(id));
            projectWithAllOrderItems.put(projectId, orderItensList);
        }
        System.debug('projectWithAllOrderItems1: '+projectWithAllOrderItems);

        //Add all order items by project if exists
        Map<Id, List<OrderItem>> orderItemsExist = DAL_OrderItem.getOrderItensByProjectIds(projectIds);
        for (Id projectId : orderItemsExist.keySet()) {
            List<OrderItem> orderItensList = projectWithAllOrderItems.get(projectId);
            if (orderItensList == null) {
                orderItensList = new List<OrderItem>();
            }

            for (OrderItem oi : orderItemsExist.get(projectId)) {
                orderItensList.add(oi);
            }
            projectWithAllOrderItems.put(projectId, orderItensList);
        }
        System.debug('projectWithAllOrderItems: '+projectWithAllOrderItems);

        return projectWithAllOrderItems;
    }

    public void initProjectLocation() 
    {
        mapAccountIdListLocation = new Map<Id, List<Schema.Location>>();
        mapContactIdLocation = new Map<Id, Schema.Location>();
        mapLocationIdListAddress = new Map<Id, List<Schema.Address>>();
        mapProjectIdListProjectLocation = new Map<Id, List<Project_Location__c>>();
        saveProjectLocation = new List<Project_Location__c>();
        saveAddress = new List<Schema.Address>();
        
        Set<Id> setAccountId = new Set<Id>();
        Set<Id> setContactId = new Set<Id>();
        
        // Fill the required set of ids
        for(Id forProjectId: projectMap.keySet())
        {
            for(Id forOrderId: projectWithOrdersMap.get(forProjectId))
            {
                Order forOrder = orderMap.get(forOrderId);
                setAccountId.add(forOrder.AccountId);
                setContactId.add(forOrder.Install_At_Contact__c);
                setContactId.add(forOrder.ShipToContactId);
            }
        }

        // Retrieve the values in the database
        mapContact = DAL_Contact.getMapContactIdContactBySetId(setContactId);     
        List<Schema.Location> listLocation = DAL_Location.getListLocationBySetAccountId(setAccountId);
        List<Project_Location__c> listProjectLocation = DAL_ProjectLocation.getListProjectLocationBySetProjectId(projectMap.keySet());

        OrderAssociationProjectLocation.populateSchemaLocation(mapAccountIdListLocation, mapLocationIdListAddress, listLocation);
        OrderAssociationProjectLocation.populateProjectLocation(mapProjectIdListProjectLocation, listProjectLocation);
    }

    public void updateEngagementStage(){
 
        Set<Id> engagementId = new Set<Id>();
        for(pse__Proj__c project : projectMap.values()) {
            if(project.pse__Parent_Project__c != null){
                engagementId.add(project.pse__Parent_Project__c);
            }
        }
        
        RollupEngagementStage.RollupEngagementStage(engagementId);
    }
}