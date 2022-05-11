public class OrderItemGroupingDataContext extends DataContext {
    public List<ExceptionLogger__c> exceptionLoggers {get;set;}
    public Map<Id, Id> ordersToEngagement{get;set;}
	public Map<Id, Order> orderMap{get;set;}
    public Map<Id, List<OrderItem>> orderItemsByOrderId{get;set;}
    public Map<String, pse__Practice__c> mapPracticesByDescription{get;set;}
    public Map<Id, pse__Practice__c> mapAllPractices{get;set;}
    public Map<Id, List<pse__Proj__c>> mapEngagementIdProjectList{get;set;}
    public Map<OrderItem, Id> orderItemToAssociate{get;set;}
    public List<ProjectToCreate> projectsToCreate {get;set;}
    public List<Create_Project__e> createProjectEventList{get;set;}
    public List<Order_Association__e> orderItemEventList{get;set;}
    public Map<String,Sku_Effort_Map__c> skuNumberToSkuEffortMap {get;set;}
    public Set<pse__proj__c> projects {get;set;}  
    public Map<OrderItem, pse__proj__c> mapOrdemItemProject {get;set;}
    Map<OrderItem, OrderItemToProjectApproval__c> mapOrderItemApproval {get;set;}
    Map<Id,OrderItemToProjectApproval__c> mapProjectOrderItemToProjectApproval {get;set;}
    public Sku_Effort_Map__c customSku  {get;set;}
    private FFProcessExecutionControl executionControl;
    public List<OrderItem> orderItemsByOrderIdFromRejectedProjects {get;set;}

    // On constructing retrieve all order data necessary
    public OrderItemGroupingDataContext(Map<Id, Id> ordersToEngagement){
        this.ordersToEngagement = ordersToEngagement;
        refresh(ordersToEngagement);
    }

    public override void refresh(Map<Id, Id> ordersToEngagement){
        executionControl = new FFProcessExecutionControl(ordersToEngagement.keySet());
        exceptionLoggers = new List<ExceptionLogger__c>();
        
        orderItemsByOrderId = new Map<Id, List<OrderItem>>();
        orderItemsByOrderId = DAL_OrderItem.getOrderItemByOrderId(ordersToEngagement.keySet());
        orderItemsByOrderIdFromRejectedProjects = new List<OrderItem>();
        orderItemsByOrderIdFromRejectedProjects = DAL_OrderItem.getOrderItensByOderIdForRejectedProjects(ordersToEngagement.keySet());
		orderMap = DAL_Order.getOrdersByIds(orderItemsByOrderId.keySet());
        mapPracticesByDescription = getPracticesByDescription(orderItemsByOrderId);
        mapEngagementIdProjectList = DAL_Project.getNotCanceledProjectByEngamentId(ordersToEngagement.values());

        orderItemToAssociate = new Map<OrderItem, Id>();
        projectsToCreate = new List<ProjectToCreate>();
        DAL_Sku.SkuMap skuMap = DAL_Sku.getSkuMapBySkuNumber(orderMap);
        skuNumberToSkuEffortMap = skuMap.skuNumberToSkuEffortMap;
		customSku = skuMap.customSku;
        projects = new Set<pse__Proj__c>();
        
        mapOrdemItemProject = new Map<OrderItem, pse__proj__c>();
        mapOrderItemApproval = new Map<OrderItem, OrderItemToProjectApproval__c>();
    	mapProjectOrderItemToProjectApproval = new Map<Id,OrderItemToProjectApproval__c>();

        mapAllPractices = DAL_ItemClass.getAllPractices();
    }

    public override void save(){
        update new List<pse__Proj__c>(projects);
        
        sendToProjectCreateEvent();

        sendToOrderItemAssociationEvent();

        sendOrderItemsToProjectToApprovalProcess();

        executionControl.insertControls();
        UPSERT exceptionLoggers;
    }

    public void sendToProjectCreateEvent(){
        Map<String, List<ProjectToCreate>> groupingKeyToProjects = new Map<String, List<ProjectToCreate>>();
        for(ProjectToCreate data: projectsToCreate){
            List<ProjectToCreate> projectList = groupingKeyToProjects.get(data.groupingKey);
            if(projectList == null){
                projectList = new List<ProjectToCreate>(); 
            }
            projectList.add(data);
            groupingKeyToProjects.put(data.groupingKey, projectList);
        }

        createProjectEventList = new List<Create_Project__e>();

        for(String groupingkey : groupingKeyToProjects.keySet()){
            
            List<ProjectToCreate> projectList = groupingKeyToProjects.get(groupingKey);
            
            if(projectList != null && projectList.size() >  0){
                ProjectToCreate data = projectList[0];
         
                String projectListStr = '';
                for(ProjectToCreate project : projectList){
                    if (projectListStr != '') {
                        projectListStr += ';';
                    }
                    projectListStr+= project.orderItemId;
                }

                Create_Project__e e = new Create_Project__e(
                    Grouping_key__c = data.groupingkey,
                    Order_ID__c = data.orderId,
                    OrderItemList__c = projectListStr,
                    Engagement_Id__c = data.engagementeId,
                    Practice_Id__c = data.practiceId
                );

                createProjectEventList.add(e);

                String payload = 'GroupingKey: ' + data.groupingKey;
                executionControl.setProcessLog(data.orderId, payload, 'Sending to project create event');
            }
        }

        List<Database.SaveResult> srList = Eventbus.publish(createProjectEventList);
        exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(createProjectEventList, srList, OrderItemGroupingDataContext.class.getName(), 'Sending create project event'));  
    }

    private void sendToOrderItemAssociationEvent(){
        orderItemEventList = new List<Order_Association__e>();
        for(OrderItem orderItem: orderItemToAssociate.keySet()){
            Order_Association__e e = new Order_Association__e(
                Project_ID__c = orderItemToAssociate.get(orderItem),
                Order_Item_Id__c = orderItem.Id, 
                Order_ID__c = orderItem.OrderId
            );

            orderItemEventList.add(e);

            String payload = 'Order Item: ' + orderItem + ' - Project: ' +  orderItemToAssociate.get(orderItem);
            executionControl.setProcessLog(orderItem.orderId, payload, 'Sending to association event');
        }

        List<Database.SaveResult> srList = Eventbus.publish(orderItemEventList);
        exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(createProjectEventList, srList, OrderItemGroupingDataContext.class.getName(), 'Sending project association event'));
    }

    private static Map<String, pse__Practice__c> getPracticesByDescription(Map<Id, List<OrderItem>> orderItemsByOrderId){

        Set<String> itemDescriptions = new Set<String>();
        for(Id orderId :orderItemsByOrderId.keySet()){

            for(OrderItem orderItem :orderItemsByOrderId.get(orderId)){
                itemDescriptions.add(orderItem.Item_Class_Description__c);
            }
        }

        return DAL_ItemClass.getPracticeByDescription(itemDescriptions);
    }
    
    //Approval process methods
    private void sendOrderItemsToProjectToApprovalProcess(){
        createOrderItemToProjectToApprovalProcess();
        updateOrderItemProjectApprovalInfo();
        sendOrderItemToProjectToApprovalProcess();
    }
    
    private void createOrderItemToProjectToApprovalProcess(){
        Set<Id> setOrderItemIds = new Set<Id>();
        
        for(OrderItem orderItem : mapOrdemItemProject.keyset()){
            setOrderItemIds.add(orderItem.Id);
            pse__Proj__c project = mapOrdemItemProject.get(orderItem);
            if(mapProjectOrderItemToProjectApproval.containsKey(project.Id)){
                OrderItemToProjectApproval__c orderItemToProjectApproval = mapProjectOrderItemToProjectApproval.get(project.Id);
                mapOrderItemApproval.put(orderItem, orderItemToProjectApproval);
            }
            else{
                OrderItemToProjectApproval__c orderItemToProjectApproval = new OrderItemToProjectApproval__c(
                    Name = 'Order ' + orderItem.Order.OrderNumber__c + ' pending Approval Request',
                    Approver__c = project.pse__Project_Manager__r.pse__Salesforce_User__c,
                    Project__c = project.Id
                );

                mapOrderItemApproval.put(orderItem, orderItemToProjectApproval);
                mapProjectOrderItemToProjectApproval.put(project.Id, orderItemToProjectApproval);
            }

            String payload = 'OrderItem: ' + orderItem + ' - Project: ' + project.Id;
            executionControl.setProcessLog(orderItem.OrderId, payload, 'Sending order to approval proccess');
        }
        List<Database.SaveResult> projectOrderItemToProjectApprovalResults = Database.insert(mapProjectOrderItemToProjectApproval.values());
        exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(setOrderItemIds, null, projectOrderItemToProjectApprovalResults, OrderItemGroupingDataContext.class.getName()));
    }
    
    private void updateOrderItemProjectApprovalInfo(){
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        Set<Id> listOrderItemId = new Set<Id>();
        for(OrderItem orderItem : mapOrderItemApproval.keyset()){
            orderItem.OrderItemToProjectApproval__c = mapOrderItemApproval.get(orderItem).Id;
            lstOrderItem.add(orderItem);
            listOrderItemId.add(orderItem.Id);
        }
        
        List<Database.SaveResult> orderItemUpdateResults = Database.update(lstOrderItem);
        exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(listOrderItemId, null, orderItemUpdateResults, OrderItemGroupingDataContext.class.getName()));
    }
    
    private void sendOrderItemToProjectToApprovalProcess(){
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();

        for(OrderItemToProjectApproval__c item : mapProjectOrderItemToProjectApproval.values()){
            Approval.ProcessSubmitRequest orderItemToApprovalProcess = new Approval.ProcessSubmitRequest();
            String comment = item.Name;
            orderItemToApprovalProcess.setComments(comment);
            
            orderItemToApprovalProcess.setObjectId(item.Id);

            // Submit the record to specific process
            orderItemToApprovalProcess.setProcessDefinitionNameOrId('Order_Item_Association_Approval_Process');

            requests.add(orderItemToApprovalProcess);
        }      
        
        Approval.ProcessResult[] processResults = Approval.process(requests, true);
    }

    public class ProjectToCreate {
        public String groupingkey {get;set;}
        public Id orderId {get;set;} 
        public Id orderItemId {get;set;}
        public Id engagementeId {get;set;}
        public Id practiceId {get;set;} 
      
        public ProjectToCreate (String groupingkey, Id orderId, Id orderItemId, Id engagementeId, Id practiceId){
            this.groupingkey = groupingkey;
            this.orderId = orderId;
            this.orderItemId = orderItemId;
            this.engagementeId = engagementeId;
            this.practiceId = practiceId;
        }
    }
}