/**
 * Created by Bruno_Frosi on 1/13/2020.
 *
 * This class will manipulate the context to remove projects that should or shouldn't create projects.
 */

public class OrderCreatedClassification {
    public static void ClassificateOrders(OrderCreatedDataContext context) {
        Map<String, Custom_Order_Status_to_Order_Status_Map__mdt> orderStatusMap = getOrderStatusMap();
        Set<Id> ordersOnSkuEffortMap = getOrdersOnSkuEffortMap(context);
        Set<Id> shouldCreateProject = new Set<Id>();
        Set<Id> customOrders = new Set<Id>();

        for (Id orderId : context.orderMap.keySet()) {
            Order order = context.orderMap.get(orderId);
            Boolean isCustomOrder = false;
            
            //If BUID is set as SAP number, bypass the execution (don't create project)
            if(order.BUID__c == '99901'){
                continue;
            }

            Custom_Order_Status_to_Order_Status_Map__mdt mapping = orderStatusMap.get(order.Order_Status__c);
            if(orderStatusMap != null && mapping != null){
                order.Status = mapping.Order_Status__c;
            }

            if (order.OrderItems.size() > 0) {
                boolean hasClassDescriptionMatch = false;

                // check the OrderItem class description
                for (OrderItem item : order.OrderItems) {
                    if (context.listItemClassDescription.contains(item.Item_Class_Description__c)) {
                        hasClassDescriptionMatch = true;

                        if (!ordersOnSkuEffortMap.contains(orderId)) {
                            //if the Order have at last one orderItem that is not found on Sku to Effort Mapping, it have to be set as true
                            isCustomOrder = true;
                            context.executionControl.setProcessLog(item.OrderId, 'OrderClassification - isCustomOrder = true','OrderCreatedClassification: IsCustomOrder');
							context.orderMap.remove(item.OrderId);
                            customOrders.add(item.orderId);
                            break;
                        }
                    }
                }

                if (!isCustomOrder) {
                    if (hasClassDescriptionMatch) {
                        shouldCreateProject.add(orderId);
                    } else {
                        //should create project IF project has at least on item on Sku Effort Map
                        if (ordersOnSkuEffortMap.contains(orderId)) {
                            shouldCreateProject.add(orderId);
                        }
                    }
                }
            }
        }

        //Remove from OrderMap all the project that should not create project
        for (Id orderId : context.orderMap.keySet()) {
            if(!shouldCreateProject.contains(orderId) && !customOrders.contains(orderId)) {
                context.hardwareOrders.add(orderId);
            }
        }

        for (Id orderId : customOrders){
            context.customOrdersToUpdate.add(new Order(Id=orderId, isCustomOrder__c=true,Custom_Order_Status__c='Waiting for a Deal'));
        }
    }

    //this method returns a Set of OrderId listed on Sku Effort Map by skuNumbers on orderItems
    public static Set<Id> getOrdersOnSkuEffortMap(OrderCreatedDataContext context)
    {
        Set<Id> listReturn = new Set<Id>();

        Set<String> skus = new Set<String>();

        for (Id orderId : context.orderMap.keySet()) {
            Order order = context.orderMap.get(orderId);
            for (OrderItem item : order.OrderItems) {
                skus.add(item.SKU_Number__c);
            }
        }

        Map<String, SKU_Number__c> skuNumberMap = new Map<String, SKU_Number__c>();
                
        for(SKU_Number__c skuNumberEffort :[SELECT Id, SKU_Number__c FROM SKU_Number__c WHERE SKU_Number__c IN :skus AND SKU_to_Effort_Mapping__r.Active__c = true])
        {
            skuNumberMap.put(skuNumberEffort.SKU_Number__c, skuNumberEffort);
        }

        for (Id orderId : context.orderMap.keySet()) {
            Order order = context.orderMap.get(orderId);
            Set<String> skuNumberSet = new Set<String>();
            for (OrderItem item : order.OrderItems) {
                if(context.listItemClassDescription.contains(item.Item_Class_Description__c)) {
                    skuNumberSet.add(item.SKU_Number__c);
                }
            }

            Boolean isCustom = false;
            for (String skuNumber : skuNumberSet) {
                //Verify if the skuNumber is not in SkuEffortMap AND if the order item has a listed ItemClassDescription
                if(!skuNumberMap.containsKey(skuNumber)){
                    isCustom = true;
                    break;
                }
            }
            if(!isCustom && skuNumberSet.size() > 0)
                listReturn.add(orderId);
        }

        return listReturn;
    }

    private static Map<String, Custom_Order_Status_to_Order_Status_Map__mdt> getOrderStatusMap()
    {
        Map<String, Custom_Order_Status_to_Order_Status_Map__mdt> mapReturn = new Map<String, Custom_Order_Status_to_Order_Status_Map__mdt>();
        for(Custom_Order_Status_to_Order_Status_Map__mdt mapping :[SELECT Custom_Status__c, Order_Status__c FROM Custom_Order_Status_to_Order_Status_Map__mdt])
        {
            mapReturn.put(mapping.Custom_Status__c, mapping);
        }

        if(mapReturn.size() > 0)
            return mapReturn;
        return null;
    }
    
    public static void verifyOrderImportQueue(OrderCreatedDataContext context) 
    {
        Map<Id, Id> setImportedProjects = new Map<Id, Id>();
        for (Id orderId : context.orderMap.keySet()) {
            Order order = context.orderMap.get(orderId);

            Order_Import_Queue__c importedOrderProjectId = context.orderImportMap.get(order.OrderNumber__c + '|' + order.BUID__c);

            if(importedOrderProjectId != null)
            {
                setImportedProjects.put(orderId, importedOrderProjectId.Project__c);
            }
        }

        context.projectMap.putAll(DAL_Project.getProjectsForImportQueue(setImportedProjects.values()));

        for(Id orderId :setImportedProjects.keySet())
        {
            Order order = context.orderMap.get(orderId);
            Id projectId = setImportedProjects.get(orderId);
            pse__Proj__c project = context.projectMap.get(projectId);

            if (project.Project_Visibility__c == order.OPR_Is_Federal__c)
            {
                context.orderToProjectAssociate.put(orderId, projectId);
                context.orderMap.remove(orderId);

                context.listUpdateImportQueue.add(context.orderImportMap.get(order.OrderNumber__c + '|' + order.BUID__c));
            }
        }
    }

    public static void removeOrdersWithoutOrderItems(OrderCreatedDataContext context) {
        for (Id orderId : context.orderMap.keySet()) {
            Order order = context.orderMap.get(orderId);
            
            //If the Order doesn't have any Order Item, we need to discard it
            if (order.OrderItems.size() == 0) {
                context.orderMap.remove(orderId);

                ExceptionLogger__c exceptionLogger = new ExceptionLogger__c(
                    Apex_Class__c = 'OrderCreatedClassification',
                    Method_Name__c = 'removeOrdersWithoutOrderItems',
                    Description__c = 'Order ' + order.OrderNumber__c + ' has no OrderItems',
                    API_PayLoad__c = order.Id,
                    External_System_Name__c = 'FinancialForce'
                );

                context.exceptionLoggers.add(exceptionLogger);
            }
        }
    }

    public static void removeNonFFOrder(OrderCreatedDataContext context) {
        for (Id orderId : context.orderMap.keySet()) {
            Order order = context.orderMap.get(orderId);
            
            if (order.FF_Feed__c == false) {
                context.orderMap.remove(orderId);

                ExceptionLogger__c exceptionLogger = new ExceptionLogger__c(
                    Apex_Class__c = 'OrderCreatedClassification',
                    Method_Name__c = 'removeNonFFOrder',
                    Description__c = 'Order ' + order.OrderNumber__c + ' is not an FF Order',
                    API_PayLoad__c = order.Id,
                    External_System_Name__c = 'FinancialForce'
                );

                context.exceptionLoggers.add(exceptionLogger);
            }
        }
    }
}