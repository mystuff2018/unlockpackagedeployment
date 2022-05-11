/**
 * @File Name          : DAL_SkuTest.cls
 * @Description        : Test class for DAL_Sku apex class.
 * @Author             : Leonardo Santos | 2/21/2020
**/

@isTest
public with sharing class DAL_SkuTest {
    
    @testSetup
    static void makeData(){
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            // Create sku numbers and effort mappings
            List<String> skuNumbersToMap1 = new List<String>{'111-1111'};
                List<String> skuNumbersToMap2 = new List<String>{'CUSTOM SKU'};
                    Map<String, String> phaseByTask = new Map<String, String>();
            phaseByTask.put('Scoping', 'Initiate');
            
            SKU_Effort_Map__c skuEffort1 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap1, 10, false, phaseByTask);
            SKU_Effort_Map__c skuEffort2 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap2, 10, false, phaseByTask);
            
            Order order1 = OPRTestFactory.createSimpleOrder();
            
            OrderItem orderItem = [
                SELECT Id, SKU_Number__c, PriceBookEntryId, Item_Class_Description__c
                FROM OrderItem
                WHERE OrderId = :order1.Id
                LIMIT 1
            ];
            
            orderItem.Quantity = 2;
            orderItem.SKU_Number__c = '111-1111';
            update orderItem;
            
            OrderItem oi = new OrderItem();
            oi.SKU_Description__c = 'SKU Desc 1';
            oi.SKU_Number__c = '444-4444';
            oi.Quantity = 1;
            oi.UnitPrice = 2;
            oi.Item_Class_Description__c = orderItem.Item_Class_Description__c;
            oi.Tie_Number__c = '1';
            oi.OrderId = order1.Id;
            oi.PriceBookEntryId = orderItem.PriceBookEntryId;
            oi.SKU_Cost__c = 2;
            oi.Unit_Selling_Price_USD__c = 85000;
            oi.SKU_Cost_USD__c = 85000;
            insert oi;
        }
    }
    
    @isTest
    static void shouldReturnEffortMapBySkuNumber(){
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            Order order1 = [
                SELECT Id
                FROM Order
                LIMIT 1
            ];
            
            // Get all info for order
            Map<Id,Order> mapOrder = DAL_Order.getOrdersByIds(new Set<Id>{order1.Id});
            
            Test.startTest();
            Map<String,Sku_Effort_Map__c> skuEffortBySkuNumber = DAL_Sku.getSkuEffortBySkuNumber(mapOrder);
            Test.stopTest();
            
            System.debug(skuEffortBySkuNumber);
            
            System.assertEquals(true, skuEffortBySkuNumber.containsKey('444-4444'), 'Map should contain effort map for the custom sku');
            System.assertEquals(true, skuEffortBySkuNumber.containsKey('111-1111'), 'Map should contain effort map for the sku 111-1111');
            System.assertEquals(false, skuEffortBySkuNumber.containsKey('222-2222'), 'Map should not contain effort map for the sku 222-2222');
        }
    }
    
    @isTest
    static void souldReturnTwoSkillSkuEntry(){
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            SKU_Effort_Map__c skuEffort = [
                SELECT Id
                FROM SKU_Effort_Map__c
                WHERE Id IN (
                    SELECT SKU_to_Effort_Mapping__c
                    FROM SKU_Number__c
                    WHERE SKU_Number__c = '111-1111'
                )
                LIMIT 1
            ];
            
            List<SKU_Effort_Map_Entry__c> entries = [
                SELECT Id
                FROM SKU_Effort_Map_Entry__c
                WHERE SKU_Effort_Map__c = :skuEffort.Id
            ];
            
            pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
            
            Map<Id, List<SKU_Effort_Map_Entry__c>> allEntries = new Map<Id, List<SKU_Effort_Map_Entry__c>>();
            allEntries.put(project1.Id, entries);
            
            Test.startTest();
            Map<Id, List<Skill_SKU_Effort_Map_Entry__c>> result = DAL_Sku.getSkillSkuEffortMapEntry(allEntries);
            Test.stopTest();
            
            System.assertEquals(2, result.get(entries[0].Id).size(), 'Should return 2 skill sku effort map entry');
        }
    }
    

}