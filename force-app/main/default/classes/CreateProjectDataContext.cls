/**
* Created by Bruno_Frosi on 1/20/2020.
*/

public with sharing class CreateProjectDataContext extends DataContext {
    
    public Map<String, Set<Id>>  listOfGroupedOrderItens {get;set;}
    
    public Set<Id> orderIds {get;set;}
    public Map<Id, OrderItem> orderItemMap {get;set;} //changed by Elson
    public Map<Id, Order> orderMap {get;set;}
    public Map<Id, Account> accountMap {get;set;}
    public Map<Id, pse__Proj__c> projectMap {get;set;}
    public List<Clone_Project_Info__c> cloneProjectInfo {get;set;}
    public Map<String,List<pse__Region__c>> buidToRegion {get;set;}
    public Map<Id,pse__Region__c> mapRegion {get;set;}
    public Map<String, String> regionNameToQueueNames {get;set;}
    public Map<String, Group> queueNameToQueue {get;set;}
    public List<pse__Resource_Request__c> listResourceRequest {get;set;}
    public Map<Id, Set<Id>> projectToOrderItemMap {get;set;}
    public List<List<Id>> listOfGroupedOrders {get;set;}
    public List<Order_Association__e> projectAssociationEventList{get;set;}
    public Set<String> groupingKeys{get;set;}
    public Map<pse__Proj__c, List<OrderItem>> orderItemsByProjectMap{get;set;}
    public Map<Id, pse__Proj__c> practiceIdToTemplate {get;set;}
    public Map<Id, String> practiceIdToBusinessSegment {get;set;}
    public Map<Id, pse__Region__c> regionStatesMap {get;set;}
    public Id defaultProjectManager {get;set;}
    public pse__Region__c globalRegion {get;set;}
    public List<ExceptionLogger__c> exceptionLoggers {get;set;}
    public FFProcessExecutionControl executionControl;
    
    public CreateProjectDataContext(Set<Id> orderIds, Map<Id, Id> orderItemToPracticeIds, Map<Id, Id> orderItemToEngagementIds, Map<Id, String> orderItemToGroupingKeyIds) {
        refresh(orderIds, orderItemToPracticeIds, orderItemToEngagementIds, orderItemToGroupingKeyIds);
    }
    
    public void refresh(Set<Id> orderIds, Map<Id, Id> orderItemToPracticeIds, Map<Id, Id> orderItemToEngagementIds, Map<Id, String> orderItemToGroupingKeyIds) {
        
        executionControl = new FFProcessExecutionControl(orderIds);
        
        listOfGroupedOrderItens = new Map<String, Set<Id>>();
        projectMap = new Map<Id, pse__Proj__c>(); 
        listOfGroupedOrders = new List<List<Id>>();
        queueNameToQueue = new Map<String, Group>();
        orderMap = DAL_Order.getOrdersByIds(orderIds);
        orderItemMap = DAL_OrderItem.getOrderItensByIds(orderItemToEngagementIds.keySet()); //changed by Elson
        mapRegion = new Map<Id,pse__Region__c>();
        //groupOrders();
        groupOrderItens(orderItemToGroupingKeyIds);
        accountMap = DAL_Account.getAccountsByIds(getAccountIds());
        practiceIdToTemplate = DAL_Project.getTemplateByPracticeId(orderItemToPracticeIds.values());
        system.debug('@@practiceIdToTemplate2@@'+practiceIdToTemplate);
        practiceIdToBusinessSegment = DAL_Practice.getBusinessSegmentByPracticeId(orderItemToPracticeIds.values());
        system.debug('@@practiceIdToBusinessSegment@@'+practiceIdToBusinessSegment);
        buidToRegion = DAL_Region.getBuidToRegionMap(orderMap);
        regionStatesMap = DAL_Region.getStateRegions(orderMap);
        getMapRegion();
        system.debug('@@regionStatesMap@@'+regionStatesMap);
        globalRegion = DAL_Region.getGlobalRegion();
        defaultProjectManager = getdefaultProjectManager();
        getQueueByRegionName();
        
        listResourceRequest = new List<pse__Resource_Request__c>();
        projectToOrderItemMap = new Map<Id, Set<Id>>();
        cloneProjectInfo = new List<Clone_Project_Info__c>();
        exceptionLoggers = new List<ExceptionLogger__c>();
    }
    
    private void groupOrderItens(Map<Id, String> orderItemToGroupingKeyIds) {
        groupingKeys = new Set<String>();
        Set<Id> groupedList;
        
        for (String groupingKey : orderItemToGroupingKeyIds.values()) {
            groupingKeys.add(groupingKey);  
        }
        
        for (Id orderItemId : orderItemToGroupingKeyIds.keySet()) {
            String grouping = orderItemToGroupingKeyIds.get(orderItemId);
            
            if(!listOfGroupedOrderItens.containsKey(grouping)){
                listOfGroupedOrderItens.put(grouping, new Set<Id>());
            }
            
            groupedList = listOfGroupedOrderItens.get(grouping);
            groupedList.add(orderItemId);
            listOfGroupedOrderItens.put(grouping, groupedList);
        }
        
    }
    
    public void populateOrderItemsByProjectMap(){
        
        orderItemsByProjectMap = new Map<pse__Proj__c, List<OrderItem>>();
        
        for(Id projectId: projectToOrderItemMap.keySet()){
            List<OrderItem> orderItemList = new List<OrderItem>();
            pse__Proj__c project = projectMap.get(projectId);
            
            for(Id orderItemId: projectToOrderItemMap.get(projectId)){
                OrderItem orderItem = orderItemMap.get(orderItemId);
                orderItemList.add(orderItem);
            }
            
            orderItemsByProjectMap.put(project, orderItemList);
            
        }
    }
    
    private void getQueueByRegionName() {	
        regionNameToQueueNames = new Map<String, String>();	
        for(Id regionId :mapRegion.keySet()){	
            pse__Region__c region = mapRegion.get(regionId);	
            if(region.pse__Parent_Region__c != null) {	
                regionNameToQueueNames.put('ISG'+region.pse__Parent_Region__r.Name.toLowerCase(), 'ISG_' + region.pse__Parent_Region__r.Name + '_Projects');	
                regionNameToQueueNames.put('CSG'+region.pse__Parent_Region__r.Name.toLowerCase(), 'CSG_' + region.pse__Parent_Region__r.Name + '_Projects');	
            	System.debug('@@CPTHregionNameToQueueNames'+regionNameToQueueNames);
            }	
        }	
        if(globalRegion != null) {	
            regionNameToQueueNames.put(globalRegion.Name.toLowerCase(), 'ISG_' + globalRegion.Name + '_Projects');	
        }	
        for(Group queue : [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND ((DeveloperName IN :regionNameToQueueNames.values()))]){	
            queueNameToQueue.put(queue.DeveloperName.toLowerCase(), queue);	
        }	
    }
    
    private void getMapRegion() {
        for (String buid : buidToRegion.keySet()) {
            List<pse__Region__c> listRegions = buidToRegion.get(buid);
            mapRegion.putAll(listRegions);
        }        
    }
    
    private Id getdefaultProjectManager() {
        string projectManagerId = IDS_Default_Project_Manager__c.getOrgDefaults().value__c;
        List<Contact> pm = [SELECT Id FROM Contact where Id = :projectManagerId LIMIT 1];
        return pm.size() > 0 ? pm[0].Id : null;
    }
    
    private Set<Id> getAccountIds()
    {
        Set<Id> accountIds = new Set<Id>();
        System.debug('getAccountIds - OrderMap - ' + orderMap);
        if(orderMap.size() > 0) {
            for (Id orderid : orderMap.keySet()) {
                Order order = orderMap.get(orderId);
                if(order.AccountId != null)
                    accountIds.add(order.AccountId);
            }
        }
        
        if(accountIds != null)
            return accountIds;
        return null;
    }
    
    public override void save()
    {
        System.debug('projectMap...' + projectMap);
        
        if(cloneProjectInfo != null && cloneProjectInfo.size() > 0) {
            List<Database.UpsertResult> saveResults = Database.upsert(cloneProjectInfo, false);
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(orderMap.keySet(), saveResults, CreateProjectDataContext.class.getName()));
        }
        if(projectMap != null && projectMap.size() > 0) {
            system.debug('projectMap.values() - ' + projectMap.values());
            List<Database.UpsertResult> saveResults = Database.upsert(projectMap.values(), false);
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(orderMap.keySet(), saveResults, CreateProjectDataContext.class.getName()));
        }
        if(listResourceRequest != null && listResourceRequest.size() > 0) {
            List<Database.UpsertResult> saveResults = Database.upsert(listResourceRequest, false);
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(orderMap.keySet(), saveResults, CreateProjectDataContext.class.getName()));
        }
        // Delete the default budgets created by the FF API
        if(projectMap != null && projectMap.size() > 0) {					//if - Checkmarks update
            List<Database.DeleteResult> deleteResults = Database.delete([SELECT Id FROM pse__Budget__c WHERE pse__Project__c IN :projectMap.keySet()], false);
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(orderMap.keySet(), deleteResults, CreateProjectDataContext.class.getName()));
        }
        insertOrderAssociationEvents();
        SaveResultExceptionLogger.systemDebugLog(orderMap.keySet(), Database.upsert(exceptionLoggers, false));
        executionControl.insertControls();
    }
    
    private void insertOrderAssociationEvents()
    {
        projectAssociationEventList = new List<Order_Association__e>();
        
        for(Id projectId :projectToOrderItemMap.keySet())
        {
            Set<Id> groupedOrderItems = projectToOrderItemMap.get(projectId);
            if(groupedOrderItems != null && groupedOrderItems.size() > 0) {
                for(Id orderItemId :groupedOrderItems) {
                    OrderItem orderItem = orderItemMap.get(orderItemId);
                    Order_Association__e event = new Order_Association__e(Project_ID__c = projectId, Order_ID__c = orderItem.OrderId, Order_Item_Id__c = orderItemId);
                    projectAssociationEventList.add(event);
                }
            }
        }
        List<Database.SaveResult> saveResults = Eventbus.publish(projectAssociationEventList);
        exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(orderMap.keySet(), saveResults, OrderCreatedDataContext.class.getName()));
    }
}