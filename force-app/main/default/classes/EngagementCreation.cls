/*
 * @test EngagementCreationTest
 * @author Pablo Dunke
 * @date 03/02/2020
 * @description Create a new engagement from an order
 * @ Modification Log  : Version 1.0 - [Deloitte - Abhishek Kawle] : Modified code as per Multi-Tower Hierarchy Feature #6476862.
 * 						 Removed the criteria to compareByDealId for DFN - IDS and changed logic to compareByDPId prior to PO Number.
 * 						 Use the Order > AccountId field to determine engagement creation. Commented rest of the account fields.
 * 						 Modified code for 'getCustomersFromOrder' to validate Order Install At / Shipping Address
 */

public with sharing class EngagementCreation {
    
    public static void createEngagementBySetOrderId(OrderCreatedDataContext context) {
        
        List<pse__Proj__c> mapNewEngagement = new List<pse__Proj__c>();
        List<Order_Item_Grouping__e> listEvent = new List<Order_Item_Grouping__e>();

        Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
        
        
        /*
         * Engagement 1 
         * 		- Order 1
         * 		- Order 2
         * Engagement 2
         * 		- Order 3
         * etc...
         * 
         * Each node of this list will create one engagement related to N orders (the orderIds will be in the internal list)
         */
        
        List<List<Id>> separatedListsOfOrders = new List<List<Id>>();
        for(Id orderId: context.orderMap.keySet()) { 
        	Order order = context.orderMap.get(orderId);
            boolean groupFound = false;
            if(!context.orderToProjectAssociate.containsKey(order.Id)){
                for(List<Id> orderIds: separatedListsOfOrders) {
                    
                    for(Id internalOrderId: orderIds) {
                        Order internalOrder = context.orderMap.get(internalOrderId);
                        
                        if(compareByDPId(order, internalOrder)) {
                            orderIds.add(orderId);
                            groupFound = true;
                        }
                        /*else if(compareByDealId(order, internalOrder)) {
                            orderIds.add(orderId);
                            groupFound = true;
                        } */
                        else if(compareByPONumber(order, internalOrder)) {
                            orderIds.add(orderId);
                            groupFound = true;
                        }
                        if(groupFound) {
                            break;
                        }
                    }
                    if(groupFound) {
                        break;
                    }
                }
                
                if(!groupFound) {
                    List<Id> newEngagement = new List<Id>();
                    newEngagement.add(orderId);
                    separatedListsOfOrders.add(newEngagement);
                }
            }
        }
        
        
        
        for(List<Id> orderIds: separatedListsOfOrders) {

            Order order = context.orderMap.get(orderIds[0]);
            Id accountId = null;

            if(order.AccountId != null)         accountId = order.AccountId;//order.Install_At_Account__c;
           /* else if(order.Direct_Account__c != null)        accountId = order.Direct_Account__c;
            else if(order.End_User_Account__c != null)      accountId = order.End_User_Account__c;
            else if(order.Shipping_Account__c != null)      accountId = order.Shipping_Account__c; */

            if(accountId != null) {
                pse__Proj__c engagement = createEngagementObject(order, accountId, recordTypeId);
                mapNewEngagement.add(engagement);
            }
        }
        insert mapNewEngagement;
        Map<Id, List<Id>> engagementIdToOrderIdList = new Map<Id, List<Id>>();
        
        for(Integer i=0; i< mapNewEngagement.size(); i++) {
            engagementIdToOrderIdList.put(mapNewEngagement[i].Id, separatedListsOfOrders[i]);
        }
        
        for(Id engagementId: engagementIdToOrderIdList.keySet()){
            
            for(Id orderId: engagementIdToOrderIdList.get(engagementId)){
            	context.orderToProjectAssociate.put(orderId, engagementId);
            }
        }

        /*
        Map<Id, Id> mapProjectEngagement = new Map<Id, Id>();
        for(Id forOrderId: mapNewEngagement.keySet()){

            Order order = context.orderMap.get(forOrderId);
            pse__Proj__c forEngagement = mapNewEngagement.get(forOrderId);
            
            if(order.Project__c != null){
                mapProjectEngagement.put(order.Project__c, forEngagement.Id);
            }

            // Put into map to associate within context.save
            context.orderToProjectAssociate.put(forOrderId, forEngagement.Id);
                
        }

        List<pse__Proj__c> listProject = new List<pse__Proj__c>();
        for(Id forProjectId: mapProjectEngagement.keySet()){
            pse__Proj__c forProject = new pse__Proj__c();
            forProject.Id = forProjectId;
            forProject.pse__Parent_Project__c = mapProjectEngagement.get(forProjectId);
            listProject.add(forProject);
        }

		update listProject;
		*/
    }
    
    private static boolean compareByPONumber(Order order, Order internalOrder) {
        if(order.PoNumber == null || internalOrder.PoNumber == null)
            return false;
        
        List<String> orderCustomers = getCustomersFromOrder(order);
        List<String> internalOrderCustomers = getCustomersFromOrder(internalOrder);
        
        return compareCustomers(orderCustomers, internalOrderCustomers) && order.PoNumber == internalOrder.PoNumber;
    }
    
  /*  private static boolean compareByDealId(Order order, Order internalOrder) {
        if(order.Deal_ID__c == null || internalOrder.Deal_ID__c == null)
            return false;
        return order.Deal_ID__c == internalOrder.Deal_ID__c;
    } */
    
    private static boolean compareByDPId(Order order, Order internalOrder) {
        if(order.DPID__c == null || internalOrder.DPID__c == null)
            return false;
        return order.DPID__c == internalOrder.DPID__c;
    }
    
    private static boolean compareCustomers(List<String> orderCustomers, List<String> internalOrderCustomers) {
        
        for(String customer : orderCustomers){ 
            boolean equalCustomer = internalOrderCustomers.contains(customer); 
            
            if(equalCustomer) {
                return true;
            }
        }
        
        return false;
    }
    
    private static List<String> getCustomersFromOrder(Order order) {
        
    	List<String> orderAddresses = new List<String>();
       /*() if(order.Install_At_Customer_Number__c != null) {
            orderCustomers.add(order.Install_At_Customer_Number__c);
        }
        if(order.Direct_Customer_Number__c != null) {
            orderCustomers.add(order.Direct_Customer_Number__c);
        }
        if(order.End_User_Customer_Number__c != null) {
            orderCustomers.add(order.End_User_Customer_Number__c);
        }
        if(order.Shipping_Customer_Number__c != null) {
            orderCustomers.add(order.Shipping_Customer_Number__c);
        } */
        if(order.FBE_Install_At_City__c != null && (order.FBE_Install_At_Street__c != null || order.FBE_Install_At_Postal_Code__c != null)){
            orderAddresses.add(order.FBE_Install_At_City__c + '_' + order.FBE_Install_At_Street__c + '_' + order.FBE_Install_At_Postal_Code__c);
        }
        if(order.ShippingCity != null && (order.ShippingStreet != null || order.ShippingPostalCode != null)){
            orderAddresses.add(order.ShippingCity + '_' + order.ShippingStreet + '_' + order.ShippingPostalCode);
        }
    
        return orderAddresses;
    }

    public static pse__Proj__c createEngagementObject(Order order, Id accountId, Id recordTypeId)
    {
        pse__Proj__c engagement = new pse__Proj__c();
        engagement.Name                                 = (order.Name != null) ? order.Name : 'Engagement' + ' ' + Datetime.now().format('MMM dd yyyy HHmmss');
        engagement.pse__Account__c                      = accountId;
        engagement.DP__c                                = order.DPID__c;
        engagement.PO_Number__c                         = order.PoNumber;
        engagement.Deal__c                              = order.Deal_ID__c;
        engagement.Created_Automatically__c = true;
        engagement.Should_Update_Name__c = true;
        
        if(order.Project__c != null)
        {
            engagement.pse__Start_Date__c                   = order.Project__r.pse__Start_Date__c;
            engagement.pse__End_Date__c                     = order.Project__r.pse__End_Date__c;
            engagement.pse__Project_Manager__c              = order.Project__r.pse__Project_Manager__c;
            engagement.pse__Stage__c                        = order.Project__r.pse__Stage__c;
            engagement.pse__Region__c                       = order.Project__r.pse__Region__c;
            engagement.pse__Practice__c                     = order.Project__r.pse__Practice__c;
            engagement.pse__Region__c                       = order.Project__r.pse__Region__c;
            engagement.pse__Notes__c                        = order.Project__r.pse__Notes__c;
            engagement.pse__Is_Active__c                    = order.Project__r.pse__Is_Active__c;
            engagement.pse__Is_Billable__c                  = order.Project__r.pse__Is_Billable__c;
            engagement.pse__Closed_for_Time_Entry__c        = order.Project__r.pse__Closed_for_Time_Entry__c;
            engagement.pse__Closed_for_Expense_Entry__c     = order.Project__r.pse__Closed_for_Expense_Entry__c;
        }

        engagement.RecordTypeId                         = recordTypeId;
        return engagement;
    }
}