/**************
 * @ Class Name        : OrderCreatedGroupingRules
 * @ Description       : 
 * @ Modification Log  : Version 1.0 - [Deloitte - Abhishek Kawle] : Modified code as per Multi-Tower Hierarchy Feature #6476862.
 * 						 Removed the criteria to matchByDealId for DFN - IDS and changed logic to matchbyDPId prior to PO Number.
*********/
public class OrderCreatedGroupingRules {

    public static void associateOrderToEngagement(OrderCreatedDataContext context) {
        findEngagements(context);
        matchByDPID(context);
        matchByPoNumber(context);
        //matchByDealId(context);  
    }

    public static void findEngagements(OrderCreatedDataContext context){
        Set<String> poNumberSet = new Set<String>();
        Set<String> dealIdSet = new Set<String>();
        Set<String> dpIdSet = new Set<String>();
		List<Order> installAtOrderList;
		List<Order> shippingAddressOrderList;
        
        for(Id orderId :context.orderMap.keySet())
        {    
            Order order = context.orderMap.get(orderId);
            if(order != null) {
                if(order.PoNumber != null) {
                    poNumberSet.add(order.PoNumber);
                }
                /*if(order.Deal_ID__c != null) {
                    dealIdSet.add(order.Deal_ID__c);
                } */
                if(order.DPID__c != null) {
                    dpIdSet.add(order.DPID__c);
                }
            }
            
        }
        
        
        context.projectMap = DAL_Project.getEngagementForOrderGrouping(poNumberSet, dealIdSet, dpIdSet);       

        //[Deloitte - Abhishek Kawle]: Added new code for grouping based on Order > Install At and Shipping Address fields.
        context.orderGroupingMap = DAL_Order.getAllOrderForGrouping(poNumberSet);
        if(context.orderGroupingMap != null){
            for(Id orderId : context.orderGroupingMap.keyset()){
                Order order = context.orderGroupingMap.get(orderId);
                if(order != null){
                    String poNumber = order.PoNumber;                
                    if(order.FBE_Install_At_City__c != null && (order.FBE_Install_At_Street__c != null || order.FBE_Install_At_Postal_Code__c != null)){
                        String installAtAddress = order.FBE_Install_At_City__c + '_' + order.FBE_Install_At_Street__c + '_' + order.FBE_Install_At_Postal_Code__c + '' + (poNumber != null ? '_' + poNumber : '');
                        installAtOrderList = context.installAtAddressOrdersMap.get(installAtAddress);
                        if(installAtOrderList == null)
                            installAtOrderList = new List<Order>();
                        
                        installAtOrderList.add(order);
                        context.installAtAddressOrdersMap.put(installAtAddress,installAtOrderList);
                    }
                    
                    if(order.ShippingCity != null && (order.ShippingStreet != null || order.ShippingPostalCode != null)){
                        String shippingAddress = order.ShippingCity + '_' + order.ShippingStreet + '_' + order.ShippingPostalCode + '' + (poNumber != null ? '_' + poNumber : '');
                        shippingAddressOrderList = context.shippingAddressOrdersMap.get(shippingAddress);
                        if(shippingAddressOrderList == null)
                            shippingAddressOrderList = new List<Order>();
                        
                        shippingAddressOrderList.add(order);
                        context.shippingAddressOrdersMap.put(shippingAddress, shippingAddressOrderList);
                    }
                }
            }
        }
    }

    public static void matchByPoNumber(OrderCreatedDataContext context) {
        for(Id orderId :context.orderMap.keySet())
        {
            Order order = context.orderMap.get(orderId);

            if(order != null) {
                if(order.PoNumber != null) {
                    String installAtAddress;
                    String shippingAddress;
                    String poNumber = order.PoNumber;
                    //Get a list of all customer numbers related to the order by it's type so we can iterate and apply filter respecting customer type precedence (listed below)
                   /* List<String> orderCustomers = new List<String>();
                    if(order.Install_At_Customer_Number__c != null) {
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
                        installAtAddress = order.FBE_Install_At_City__c + '_' + order.FBE_Install_At_Street__c + '_' + order.FBE_Install_At_Postal_Code__c;
                    }
                    if(order.ShippingCity != null && (order.ShippingStreet != null || order.ShippingPostalCode != null)){
                        shippingAddress = order.ShippingCity + '_' + order.ShippingStreet + '_' + order.ShippingPostalCode;
                    }                   
					
                    Boolean foundProject = false;
                    Id projectId;
                    if(installAtAddress != null){
                        String installAtAddressKey = installAtAddress + '_' + poNumber;
                        if(context.installAtAddressOrdersMap != null && context.installAtAddressOrdersMap.get(installAtAddressKey) != null){
                            List<Order> orders = context.installAtAddressOrdersMap.get(installAtAddressKey);
                            if(orders.size() > 0){
                                foundProject = true;
                                projectId = orders[0].Project__c;
                                context.orderToProjectAssociate.put(orderId, projectId);
                            }
                        }
                    }
                    if(shippingAddress != null && !foundProject){
                        String shippingAddressKey = shippingAddress + '_' + poNumber;
                        if(context.shippingAddressOrdersMap != null && context.shippingAddressOrdersMap.get(shippingAddressKey) != null){
                            List<Order> orders = context.shippingAddressOrdersMap.get(shippingAddressKey);
                            if(orders.size() > 0){
                                foundProject = true;
                                projectId = orders[0].Project__c;
                                context.orderToProjectAssociate.put(orderId, projectId);
                            }
                        }
                    }
                    
                    /*if (orderCustomers.size() > 0) {
                        for(String customerNumber :orderCustomers) {
                            Boolean projectFound = false;
                            for (Id projectId : context.projectMap.keySet()) {
                                pse__Proj__c project = context.projectMap.get(projectId);
                                
                                if (project != null) {
                                    if (project.Customer_Number_Account__c == customerNumber &&
                                        project.Po_Number__c == order.PoNumber &&
                                        project.pse__Stage__c != 'Closure' &&
                                        project.pse__Stage__c != 'Cancelled')
                                    {
                                        projectFound = true;
                                        context.orderToProjectAssociate.put(orderId, projectId);
                                        
                                        break;
                                    }
                                }
                            }
                            
                            if(projectFound){
                                break;
                            }
                        }
                    } */
                }
            }
        }
    }

    /*public static void matchByDealId(OrderCreatedDataContext context) {
        for(Id orderId :context.orderMap.keySet())
        {
            Order order = context.orderMap.get(orderId);

            if(order != null) {
                if(order.Deal_ID__c != null) {
                    for (Id projectId : context.projectMap.keySet()) {
                        pse__Proj__c project = context.projectMap.get(projectId);
                        if (project != null) {
                            if (project.Deal__c == order.Deal_ID__c &&
                                project.pse__Stage__c != 'Closure' &&
                                project.pse__Stage__c != 'Cancelled')
                            {
                                context.orderToProjectAssociate.put(orderId, projectId);
                                break;
                            }
                        }
                    }
                }
            }
        }
    } */

    public static void matchByDPID(OrderCreatedDataContext context) {
        for(Id orderId :context.orderMap.keySet())
        {
            Order order = context.orderMap.get(orderId);

            if(order != null) {
                if(order.DPID__c != null) {
                    for (Id projectId : context.projectMap.keySet()) {
                        pse__Proj__c project = context.projectMap.get(projectId);
                        if (project != null) {
                            if (project.DP__c == order.DPID__c &&
                                project.pse__Stage__c != 'Closure' &&
                                project.pse__Stage__c != 'Cancelled')
                            {
                                context.orderToProjectAssociate.put(orderId, projectId);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}