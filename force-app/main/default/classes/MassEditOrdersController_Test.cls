/**
 * Thomas Davis
 * 2018-10-10
 * FinancialForce.com, Inc.
 * thdavis@financialforce.com
 *
 * Provides test code coverage for the following classes:
 *
 * MassEditOrdersController.cls
 */
@IsTest
public class MassEditOrdersController_Test
{
     @TestSetup
     static void setup(){
        
         pse__Proj__c project = OPRTestFactory.createSimpleProject();
        
         Order order1 = OPRTestFactory.createSimpleOrder();
         order1.Project__c = project.Id;
         Order order2 = OPRTestFactory.createSimpleOrder();
         order2.Project__c = project.Id;
         update new List<Order>{order1, order2};
        
         List<Contact> lstContact = new List<Contact>();
	 	for(Contact contact :[SELECT Id, Mailing_Country__c From Contact]){
	 		contact.MailingCountry = contact.Mailing_Country__c;
	 		lstContact.add(contact);
	 	}
	 	update lstContact;
        
         pse__Milestone__c mstone = new pse__Milestone__c();
         mstone.pse__Project__c = project.Id;
         mstone.Name = 'Test Milestone';
         mstone.pse__Milestone_Amount__c = 100;
         mstone.pse__Target_Date__c = System.today();
         mstone.Current__c = true;
         insert mstone;

         pse__Milestone__c milestone2 = new pse__Milestone__c(
             pse__Project__c = project.Id,
             Name = 'Milestone 2',
             pse__Milestone_Amount__c = 50,
             pse__Target_Date__c = System.today(),
             Current__c = true
         );
         insert milestone2;

         List<OrderItem> lstItems = [SELECT Id FROM OrderItem WHERE OrderId IN : new List<Id>{order1.Id, order2.Id}];
         for(OrderItem item : lstItems){
             item.Project__c = project.Id;
         }
         update lstItems;

         OrderItemMilestoneAssociation__c orderAssociated1 = new OrderItemMilestoneAssociation__c(
             Order_Product__c = lstItems[0].Id,
             Milestone__c = mstone.Id
         );

         OrderItemMilestoneAssociation__c orderAssociated2 = new OrderItemMilestoneAssociation__c(
             Order_Product__c = lstItems[1].Id,
             Milestone__c = milestone2.Id
         );     

         insert new List<OrderItemMilestoneAssociation__c>{orderAssociated1, orderAssociated2};

     }

     @IsTest
     static void testGetOrderList(){
         pse__Proj__c project = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
         Test.startTest();
         List<Order> orderList = MassEditOrdersController.getOrderList(new List<Id>{project.Id});
         Test.stopTest();
         System.assertEquals(orderList.size(), 0, 'Orders list size should be two');
     }

     @IsTest
     static void testDoAllUpdate(){
         List<Order> orderList = [ SELECT Id, Milestone__c FROM Order];
         Id milestoneId = [SELECT Id FROM pse__Milestone__c WHERE Name = 'Test Milestone'].Id;

         Test.startTest();
         MassEditOrdersController.doAllUpdate(orderList, milestoneId);
         Test.stopTest();
         for(Order order : orderList){
             System.assertEquals(order.Milestone__c, milestoneId);
         }
     }

     @IsTest
     static void searchTest(){
         pse__Proj__c project = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
         Test.startTest();
         List<LookupSearchResult> listReturn = MassEditOrdersController.search('Test Milestone;'+project.Id, null);
         Test.stopTest();
         System.assertEquals(listReturn.size(), 0);
        
     }

     @IsTest
     static void getOrdersToProjectTest(){
         pse__Proj__c project = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
         Test.startTest();
         List<Order> orderToProject = MassEditOrdersController.getOrdersToProject(project.Id);
         Test.stopTest();
         System.assertEquals(orderToProject.size(), 0);
     }

     @IsTest
     static void updateMilestonesToProjectTest(){
         pse__Proj__c project = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
         pse__Milestone__c milestone = [SELECT Id FROM pse__Milestone__c WHERE Name = 'Test Milestone'];
         Test.startTest();
         String result = MassEditOrdersController.updateMilestonesToProject (project.Id, milestone.Id);
         Test.stopTest();
         System.assertEquals(result, 'ok', 'Return should be ok');
     }

     @IsTest
     static void saveSelectedOrdersTest(){
         pse__Proj__c project = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
         pse__Milestone__c milestone = [SELECT Id FROM pse__Milestone__c WHERE Name = 'Test Milestone'];
         List<Id> lstId = new List<Id>();
         for(Order order : [SELECT Id FROM Order]){
             lstId.add(order.Id);
         }
         Test.startTest();
         String result = MassEditOrdersController.saveSelectedOrders(project.Id, milestone.Id, lstId);
         Test.stopTest();
         System.assertEquals(result, 'ok', 'Return should be ok');
     }

    
}