public class OrderItemGroupingPracticeRules {
    private static Order_Grouping_Configuration__c orderGroupingConfiguration = Order_Grouping_Configuration__c.getInstance();
    public static final String DEAL_TYPE_CUSTOM = 'Custom';
    public static final String DEAL_TYPE_STANDARD = 'Standard';
    
    private class Grouping{
        
        public Grouping(String groupingKey, String practiceChain, pse__Proj__c project, Id engagementId, Id orderId, List<OrderItem> orderItemList){
            this.groupingKey = groupingKey;
            this.practiceChain = practiceChain;
            this.project = project;
            this.engagementId = engagementId;
            this.orderId = orderId;
            this.orderItemList = orderItemList == null ? new List<OrderItem>() : orderItemList;
        }
        
        String groupingKey;
        String practiceChain;
        pse__Proj__c project;
        Id engagementId;
        Id orderId;
        List<OrderItem> orderItemList; // This list should be populated just with order items from incoming orders
    }
    
    public static void groupingOrderItemByPractice(OrderItemGroupingDataContext context){

        // Tranform to set because the map can have more than one item class description mapped to the same practice
        //Set<pse__Practice__c> uniquePractices = new Set<pse__Practice__c>(context.mapPracticesByDescription.values());
        //Map<Id, pse__Practice__c> practiceMap = new Map<Id, pse__Practice__c>(new List<pse__Practice__c>(uniquePractices));
        
        Map<String, Grouping> allGroupings = buildExistingGroupingFromProjectsMap(context);  

        for(Id orderId : context.orderItemsByOrderId.keyset()){
            Order order = context.orderMap.get(orderId);
            Id engagementId = context.ordersToEngagement.get(orderId);
            
            Map<String, Grouping> groupingForIncomingOrderItems = new Map<String, Grouping>();
            // Searching related practices for the new orders items
			
			Boolean residencyFlag = false;
			
            for(OrderItem item : context.orderItemsByOrderId.get(orderId)){

                String projectType = calculateProjectType(order, item);
                
                Boolean foundProjectToGroup = false;
                
                // Get practice by Order Item Class Desciption 
                pse__Practice__c practice = context.mapPracticesByDescription.get(item.Item_Class_Description__c);
                
                if(practice == null){
                    continue;
                }
                
                String orderItemPracticeChain = practice.pse__Practice_ID_Chain__c;
                system.debug('item.SKU_Number__c '+item.SKU_Number__c);
                Sku_Effort_Map__c skuEffort = context.skuNumberToSkuEffortMap.get(item.SKU_Number__c);
                String orderItemType;
                if(skuEffort?.Id == context.customSku?.Id) {
                    orderItemType = DEAL_TYPE_CUSTOM;
                } else {
                    orderItemType = DEAL_TYPE_STANDARD;
                }
				
				if (skuEffort != null)
                    residencyFlag = skuEffort.Residency__c ? true : residencyFlag;
                    //residencyFlag = skuEffort?.Residency__c ? true : residencyFlag; TODO Temp fix? It was causing null pointer exception
                
                // Find the lowest ancestor practice between this order item and others order items from the same order
                // and verify if the keys are compatible
                for(Grouping grouping: allGroupings.values()) {
                    
                    if(grouping.engagementId != engagementId){
                        continue;
                    }
                    
                    String newChain = compareChains(orderItemPracticeChain, grouping.practiceChain);
                    
                    if(newChain != null) {
                        
                        OrderItemGroupingCompositeKey orderItemCompositeKey = new OrderItemGroupingCompositeKey(newChain.split(',')[0], order, skuEffort, engagementId, projectType, orderItemType, residencyFlag);
                        OrderItemGroupingCompositeKey comparingCompositeKey = new OrderItemGroupingCompositeKey(grouping.groupingKey);
                        
                        if(orderItemCompositeKey.isKeyCompatible(comparingCompositeKey)) {
                            
                            // If the keys are compatibles, replace the key into map for the order items
                            grouping.groupingKey = orderItemCompositeKey.toString();
                            grouping.orderItemList.add(item);
                            grouping.orderId = orderId;
                            
                            allGroupings.put(grouping.groupingKey, grouping);

                            
                            if(newChain != grouping.practiceChain) {
                                // Update practice of existing project if phase is setup
                                if(grouping.project != null){
                                    if (grouping.project.pse__Project_Phase__c == orderGroupingConfiguration.Project_Phase__c) {
                                        grouping.project.pse__Practice__c = newChain.split(',')[0];
                                        context.projects.add(grouping.project);
                                    }
                                } else {
                                    grouping.practiceChain = newChain;
                                }
                                
                                allGroupings.remove(grouping.groupingKey);
                            }
                            
                            foundProjectToGroup = true;
                            break;
                        }
                    }
                }
                
                if(!foundProjectToGroup){
					Boolean flagResidency = skuEffort != null ? skuEffort.Residency__c : false;
                    OrderItemGroupingCompositeKey compositeKey = new OrderItemGroupingCompositeKey(context.mapPracticesByDescription.get(item.Item_Class_Description__c).Id, order, skuEffort, engagementId, projectType, orderItemType, flagResidency);
                    String practiceChain = context.mapAllPractices.get(compositeKey.practice).pse__Practice_ID_Chain__c;
                    Grouping newGrouping = new Grouping(compositeKey.toString(), practiceChain, null, engagementId, orderId, new List<OrderItem>{item});
                    allGroupings.put(compositeKey.toString(), newGrouping);
                }
            }
        }
        
        for(Grouping grouping: allGroupings.values()){
            for(OrderItem item: grouping.orderItemList){
                if(grouping.project != null){
                    pse__Practice__c practice =  context.mapAllPractices.get(grouping.project.pse__Practice__c);
                    //Added OR condition for a story 10778904
                    if(grouping.project.Phase_Number__c > practice.Order_Association_Approval_Phase_Number__c || grouping.project.Phase_Number__c < practice.Order_Association_Approval_Phase_Number__c){
                    
                        if(!(context.orderItemsByOrderIdFromRejectedProjects.size() > 0 && !context.orderItemsByOrderIdFromRejectedProjects.contains(item))){
                            context.orderItemToAssociate.put(item, grouping.project.Id);
                        } 
                    }
                                
                    else {
                        if(item.OrderItemToProjectApproval__r.Project__c != null) {
                            fillProjectsToCreateList(context, grouping, item);
                        }
                        else {
                            context.mapOrdemItemProject.put(item, grouping.project);
                        }    
                    }
               }
                else{
                    fillProjectsToCreateList(context, grouping, item);
                }
            }
        }
    }

    private static void fillProjectsToCreateList(OrderItemGroupingDataContext context, Grouping grouping, OrderItem item) {
        OrderItemGroupingDataContext.ProjectToCreate projectToCreate = new OrderItemGroupingDataContext.ProjectToCreate(
                grouping.groupingkey, item.OrderId, item.Id, grouping.engagementId, grouping.practiceChain.split(',')[0]
        );
        context.projectsToCreate.add(projectToCreate);
    }
    
    private static Map<String, Grouping> buildExistingGroupingFromProjectsMap(OrderItemGroupingDataContext context){
        Map<String, Grouping> allGroupings = new Map<String, Grouping>();
        
        // Create a map of existing projects and their composite key of engagements
        for(Id engagementId : context.mapEngagementIdProjectList.keyset()){ 
            for(pse__Proj__c project : context.mapEngagementIdProjectList.get(engagementId)){

                if(isOrderItemProjectApprovalRejected(context, project)){
                    continue;
                }

                OrderItemGroupingCompositeKey compositeKey = new OrderItemGroupingCompositeKey(project);
                String practiceChain = project.pse__Practice__r.pse__Practice_ID_Chain__c;
                Grouping existingGrouping = new Grouping(compositeKey.toString(), practiceChain, project, engagementId, null, null);
                
                allGroupings.put(compositeKey.toString(), existingGrouping);
            }
        }  

        return allGroupings;
    }

    private static Boolean isOrderItemProjectApprovalRejected(OrderItemGroupingDataContext context, pse__Proj__c project){
        for (Id orderId : context.ordersToEngagement.keySet()) {
            for (OrderItem orderItem : context.orderItemsByOrderId.get(orderId)) {
                if(orderItem.OrderItemToProjectApproval__r?.Approval_Status__c == 'Rejected' && project.Id == orderItem.OrderItemToProjectApproval__r?.Project__c ){
                    return true;
                }
            }
        }
        return false;
    }
    
    //this method compare two practice chains and returns the full path of the higher commom parent practice
    //if the two chains do not share parents, the method returns null
    public static String compareChains(String chainA, String chainB){
        //practice chains are strings that storage the complete path of each practice in the following format:
        // practiceLevel5,practiceLevel4,practiceLevel3,practiceLevel2,practiceLevel1
        
        // split by , to determine de depth of each practice chain
        List<String> listA = chainA.split(',');
        List<String> listB = chainB.split(',');
        
        //then we determine the minimum size between the two chains
        Integer min = listA.size();
        if(min > listB.size()){
            min = listB.size();
        }
        
        
        // Level of practices to not consider when comparing chains of practices of a project. Ex: Level = 2 because we have 2 levels (Global Practice and Dell Services) should not be taken into account when doing a comparison.
        Integer level = Integer.valueOf(orderGroupingConfiguration.Practice_Level__c);
        
        //at this point we iterate from minimum size until variable 'level' to ignore those levels on the comparison 
        for(Integer x=min; x > level; x--){
            //we remove the index 0 of the chain A, until we reach the minimum size
            for(Integer i=0 ; i < listA.size(); i++){
                if(listA.size() > x){
                    listA.remove(0);
                }
            }
            //we remove the index 0 of the chain A, until we reach the minimum size
            for(Integer i=0 ; i < listB.size(); i++){
                if(listB.size() > x){
                    listB.remove(0);
                }
            }
            
            //if the two chains share the same chain, we return it
            if(String.join(listA, ',') == String.join(listB, ',')){
                return String.join(listA, ',');
            }
        }
        //if we reach this point, than the two chains does not share the same parents, then return null
        return null;
    }

    @testVisible
    public static String calculateProjectType(Order order, OrderItem orderItem){  

        String projectType;
            
        if((order.Order_Processing_Code__c == 'I' || order.Order_Processing_Code__c == 'O') && orderItem.Unit_Selling_Price_USD__c == 0 && order.TotalAmount == 0) {
            // Omega Order (Concession)
            projectType = 'Concession Delivery';
        }
        else if((order.Payment_Term__c == 'N' || order.Payment_Term__c == 'Z') && order.TotalAmount == 0) {
            // DOMS Order (Concession)
            projectType = 'Concession Delivery';
        }
        else if(order.Order_Processing_Code__c == 'E') {
            // DOMS/Omega Order (PoC Investment)
            projectType = 'Proof Of Concept Investment';
        }
        else {
            // DOMS/Omega Order (Revenue Generating)
            projectType = 'Revenue Generating';
        }

        return projectType;
    }
}