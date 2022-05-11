public with sharing class OrdersToEngagementController {
    @AuraEnabled
    public static List<Order> getOrders(String orderNumbers){        
        Set<Id> ordersIdSet = getOrdersIdSet(orderNumbers);
        if (ordersIdSet.isEmpty()){
            return null;
        }
        Map<Id, Order> ordersMap = DAL_Order.getOrdersByIds(ordersIdSet);
        List<Order> ordersList = new List<Order>();
        for(Order order : ordersMap.values()){
            ordersList.Add(order);            
        }        

        return ordersList;
    }

    @AuraEnabled
    public static Map<String, String> getAccountNameByAccountIdMap(String accountsId){  
        Map<String, String> accountNameByOrderNumberMap = new Map<String, String>();      
        Set<Id> accountIdSet = getAccountsIdSet(accountsId);

        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id = :accountIdSet];
        
        for(Account account : accounts){
            if (!accountNameByOrderNumberMap.containsKey(account.Id)){
                accountNameByOrderNumberMap.put(account.Id, account.Name);    
            }           
        }        

        return accountNameByOrderNumberMap;
    }

    private static Set<Id> getAccountsIdSet(String accountsId){
        List<String> accountsIdList = accountsId.Split(',');
        Set<Id> accountsIdSet = new Set<Id>();
        for(String accountId : accountsIdList){
            accountsIdSet.add(accountId.trim());
        }
        
        return accountsIdSet;
    }

    private static Set<Id> getOrdersIdSet(String orderNumbers){
        List<String> ordersNumbersList = orderNumbers.Split(',');
        List<Order> ordersIdList = [SELECT Id FROM Order WHERE OrderNumber__c = :ordersNumbersList];
        Set<Id> ordersIdSet = new Set<Id>();
        for(Order order : ordersIdList){
            ordersIdSet.add(order.Id);
        }
        
        return ordersIdSet;
    }

    @AuraEnabled
    public static void associateOrdersToEngagement(List<String> ordersId, Id engagementId)
    {
        List<Order> ordersList = new List<Order>();
        List<Order_Item_Grouping__e> eventList = new List<Order_Item_Grouping__e>();

        for(Id orderId : ordersId){
            Order order = new Order(Id = orderId);
            order.Project__c = engagementId;

            ordersList.add(order);

            Order_Item_Grouping__e event = new Order_Item_Grouping__e(
            Order_ID__c = orderId,
            Engagement_ID__c = engagementId);

            eventList.add(event);
        }

        update ordersList;

        EventBus.publish(eventList);
    }
}