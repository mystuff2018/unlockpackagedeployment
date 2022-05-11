/*
 * @class EngagementCreation
 * @authors Pablo Dunke
 * @date 03/05/2020
 * @Modification Log: [Deloitte- Abhishek Kawle] : Modified code to include Order > Install At, Shipping Address fields for compare methods.
 */

@IsTest
private class EngagementCreationTest 
{
     @IsTest
     static void testEngagementCreation() 
     {
         // Create the data
         Account account = OPRTestFactory.createSimpleAccount();

         pse__Proj__c project = OPRTestFactory.createSimpleProject();

         Order order = OPRTestFactory.createOrderStateCountry(null, null, null, null, 'United States', 'Texas');
         order.Shipping_Account__c = account.Id;
         order.Project__c = project.Id;
         order.PoNumber = '555';
         order.ShippingPostalCode = '10800';
         order.ShippingStreet = '2nd Street';
         order.ShippingCity = 'Los Angeles';
         order.ShippingState = 'California';
         order.ShippingCountry = 'United States';
         
         order.FBE_Install_At_Postal_Code__c = '18730';
         order.FBE_Install_At_Street__c = '3rd Street';
         order.FBE_Install_At_City__c = 'Dallas';
         order.FBE_Install_At_State__c = 'Alabama';
         order.FBE_Install_At_Country__c = 'United States';
         
         update order;
        
         Order order2 = OPRTestFactory.createSimpleOrder();
         order2.Shipping_Account__c = account.Id;
         order2.Project__c = project.Id;
         order2.PoNumber = '999';
         
         order2.ShippingPostalCode = '10800';
         order2.ShippingStreet = '2nd Street';
         order2.ShippingCity = 'Los Angeles';
         order2.ShippingState = 'California';
         order2.ShippingCountry = 'United States';
         
         order2.FBE_Install_At_Postal_Code__c = '18730';
         order2.FBE_Install_At_Street__c = '3rd Street';
         order2.FBE_Install_At_City__c = 'Dallas';
         order2.FBE_Install_At_State__c = 'Alabama';
         order2.FBE_Install_At_Country__c = 'United States';
         update order2;

         // Set the data
         Set<Id> setId = new Set<Id>();
         setId.add(order.Id);
         setId.add(order2.Id);
        
         OrderCreatedDataContext context = new OrderCreatedDataContext(setId);

         // Action
         Test.startTest();
         EngagementCreation.createEngagementBySetOrderId(context);
         Test.stopTest();

         // Assertion
         Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
         List<pse__Proj__c> result = [SELECT Id FROM pse__Proj__c WHERE DP__c =: order.DPID__c AND RecordTypeId =: recordTypeId];
         System.assertEquals(2, result.size());
     }
    
         @IsTest
     static void testEngagementCreationAndGrouping() 
     {
         // Create the data
         Account account = OPRTestFactory.createSimpleAccount();

         pse__Proj__c project = OPRTestFactory.createSimpleProject();

         Order order = OPRTestFactory.createOrderStateCountry(null, null, null, null, 'United States', 'Texas');
         order.Shipping_Account__c = account.Id;
         order.Project__c = project.Id;
         order.DPID__c = '11123';
         order.ShippingPostalCode = '10800';
         order.ShippingStreet = '2nd Street';
         order.ShippingCity = 'Los Angeles';
         order.ShippingState = 'California';
         order.ShippingCountry = 'United States';
         
         order.FBE_Install_At_Postal_Code__c = '18730';
         order.FBE_Install_At_Street__c = '3rd Street';
         order.FBE_Install_At_City__c = 'Dallas';
         order.FBE_Install_At_State__c = 'Alabama';
         order.FBE_Install_At_Country__c = 'United States';
         
         update order;
        
         Order order2 = OPRTestFactory.createSimpleOrder();
         order2.Shipping_Account__c = account.Id;
         order2.Project__c = project.Id;
         order2.DPID__c = '11123';
         
         order2.ShippingPostalCode = '10800';
         order2.ShippingStreet = '2nd Street';
         order2.ShippingCity = 'Los Angeles';
         order2.ShippingState = 'California';
         order2.ShippingCountry = 'United States';
         
         order2.FBE_Install_At_Postal_Code__c = '18730';
         order2.FBE_Install_At_Street__c = '3rd Street';
         order2.FBE_Install_At_City__c = 'Dallas';
         order2.FBE_Install_At_State__c = 'Alabama';
         order2.FBE_Install_At_Country__c = 'United States';
         update order2;

         // Set the data
         Set<Id> setId = new Set<Id>();
         setId.add(order.Id);
         setId.add(order2.Id);
        
         OrderCreatedDataContext context = new OrderCreatedDataContext(setId);

         // Action
         Test.startTest();
         EngagementCreation.createEngagementBySetOrderId(context);
         Test.stopTest();

         // Assertion
         Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
         List<pse__Proj__c> result = [SELECT Id FROM pse__Proj__c WHERE DP__c =: order.DPID__c AND RecordTypeId =: recordTypeId];
         System.assertEquals(1, result.size());
     }

}