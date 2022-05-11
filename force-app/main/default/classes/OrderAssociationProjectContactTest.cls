/*
 * @class OrderAssociationProjectContact
 * @authors Pablo Dunke and Tiago Ferreira
 * @date 02/10/2020
 */

@IsTest
private class OrderAssociationProjectContactTest 
{
    @IsTest
    static void testCompleteCreation() 
    {
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // Create the data
            pse__Proj__c project = OPRTestFactory.createProject();
            
            //Replaced Sold To Contact with Install At Contact in DFN.
            //Contact soldToContact = OPRTestFactory.createSimpleContact();
            Contact installAtContact = OPRTestFactory.createSimpleContact();
            Contact directContact = OPRTestFactory.createSimpleContact();
            Contact billToContact = OPRTestFactory.createSimpleContact();
            Contact shipToContact = OPRTestFactory.createSimpleContact();
            
            Order order = OPRTestFactory.createSimpleOrder();
            order.Install_At_Contact__c = installAtContact.Id;
            //order.Sold_to_Contact__c = soldToContact.Id;
            order.Direct_Contact__c = directContact.Id;
            order.BillToContactId = billToContact.Id;
            order.ShipToContactId = shipToContact.Id;
            update order;
            
            OrderItem item = [SELECT Id FROM OrderItem WHERE OrderId =: order.Id LIMIT 1];
            
            // Create the event
            Order_Association__e event = new Order_Association__e();
            event.Order_ID__c = order.Id;
            event.Project_ID__c = project.Id;
            event.Order_Item_Id__c = item.Id;
            
            List<Order_Association__e> listEvent = new List<Order_Association__e>();
            listEvent.add(event);
            
            OrderAssociationDataContext context = new OrderAssociationDataContext(listEvent);
            
            // Action
            Test.startTest();
            OrderAssociationProjectContact.populateProjectContacts(context);
            Test.stopTest();
            
            // Assertion
            List<Project_Contact__c> result = context.newProjectContact;
            System.assertEquals(result.size(), 4);
            System.assertEquals(result.get(0).Primary_Contact__c, true);
            //System.assertEquals(result.get(0).Contact__c, order.Sold_to_Contact__c);
            System.assertEquals(result.get(0).Contact__c, order.Install_At_Contact__c);
            System.assertEquals(result.get(1).Contact__c, order.Direct_Contact__c);
            System.assertEquals(result.get(2).Contact__c, order.BillToContactId);
            System.assertEquals(result.get(3).Contact__c, order.ShipToContactId); 
        }
    }
    
    @IsTest
    static void testNoDuplication() 
    {
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // Create the data
            pse__Proj__c project = OPRTestFactory.createProject();
            
            Contact contact = OPRTestFactory.createSimpleContact();
            
            Order order = OPRTestFactory.createSimpleOrder();
            order.Install_At_Contact__c = contact.Id;
            //Replaced Sold To Contact with Install At Contact in DFN.
            //order.Sold_to_Contact__c = contact.Id;
            order.Direct_Contact__c = contact.Id;
            order.BillToContactId = contact.Id;
            order.ShipToContactId = contact.Id;
            update order;
            
            OrderItem item = [SELECT Id FROM OrderItem WHERE OrderId =: order.Id LIMIT 1];
            
            // Create the event
            Order_Association__e event = new Order_Association__e();
            event.Order_ID__c = order.Id;
            event.Project_ID__c = project.Id;
            event.Order_Item_Id__c = item.Id;
            
            List<Order_Association__e> listEvent = new List<Order_Association__e>();
            listEvent.add(event);
            
            OrderAssociationDataContext context = new OrderAssociationDataContext(listEvent);
            
            // Action
            Test.startTest();
            OrderAssociationProjectContact.populateProjectContacts(context);
            Test.stopTest();
            
            // Assertion
            List<Project_Contact__c> result = context.newProjectContact;
            System.assertEquals(result.size(), 1);
            System.assertEquals(result.get(0).Primary_Contact__c, true);
            System.assertEquals(result.get(0).Contact__c, contact.Id);
        }
    }
    
    @IsTest
    static void testNoContacts() 
    {
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // Create the data
            pse__Proj__c project = OPRTestFactory.createProject();
            
            Order order = OPRTestFactory.createSimpleOrder();
            order.Install_At_Contact__c = null;
            //order.Sold_to_Contact__c = null;
            order.Direct_Contact__c = null;
            order.BillToContactId = null;
            order.ShipToContactId = null;
            update order;
            
            OrderItem item = [SELECT Id FROM OrderItem WHERE OrderId =: order.Id LIMIT 1];
            
            // Create the event
            Order_Association__e event = new Order_Association__e();
            event.Order_ID__c = order.Id;
            event.Project_ID__c = project.Id;
            event.Order_Item_Id__c = item.Id;
            
            List<Order_Association__e> listEvent = new List<Order_Association__e>();
            listEvent.add(event);
            
            OrderAssociationDataContext context = new OrderAssociationDataContext(listEvent);
            
            // Action
            Test.startTest();
            OrderAssociationProjectContact.populateProjectContacts(context);
            Test.stopTest();
            
            // Assertion
            List<Project_Contact__c> result = context.newProjectContact;
            System.assertEquals(result.size(), 0);
        }
    }
}