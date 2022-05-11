/*
* @class DAL_OrderItemSKUEffortMap
* @authors Pablo Dunke and Romulo Spier
* @date 04/29/2020
*/

@IsTest
private class DAL_OrderItemSKUEffortMapTest 
{
    @IsTest
    static void testGetBySetsId() 
    {
        // Create the data
       
        pse__Proj__c project = OPRTestFactory.createProject();
        Order order = OPRTestFactory.createSimpleOrder();
        List<OrderItem> listOrderItem = [SELECT Id FROM OrderItem WHERE OrderId =: order.Id];
        pse__Project_Task__c projectTask = new pse__Project_Task__c();
        projectTask.pse__Project__c = project.Id;
        projectTask.Name = 'Initiate';
        insert projectTask;
        Order_Item_Sku_Effort_Map__c orderItemSkuEffortMap = new Order_Item_Sku_Effort_Map__c();
        orderItemSkuEffortMap.Order_Product__c = listOrderItem.get(0).Id;
        orderItemSkuEffortMap.Project_Task__c = projectTask.Id;
        insert orderItemSkuEffortMap;
        Set<Id> setOrderItemId = new Set<Id>();
        setOrderItemId.add(listOrderItem.get(0).Id);
        
        Set<Id> setProjectTaskId = new Set<Id>();
        setProjectTaskId.add(projectTask.Id);
        
        // Action
        Test.startTest();
        List<Order_Item_Sku_Effort_Map__c> listEffortMap = DAL_OrderItemSKUEffortMap.getBySetOrderItemId(setOrderItemId);
        Map<Id, Order_Item_Sku_Effort_Map__c> mapEffortMap = DAL_OrderItemSKUEffortMap.getMapByProjectTaskSetId(setProjectTaskId);
        Test.stopTest();
        
        // Assertion
        System.assertEquals(1, listEffortMap.size());
        System.assertEquals(1, mapEffortMap.size());
    }
}