@IsTest
public class MilestoneHandlerTest {
    @IsTest
    static void verifyMilestonesProcessWhenCanceled(){

      Order order = OPRTestFactory.createSimpleOrder();

      pse__Proj__c projectTest = new pse__Proj__c(
          Name = 'Test Project 1',
          Project_Complexity__c = 'Low',
          pse__Account__c = order.AccountId,
          pse__Is_Active__c = true);  
      insert(projectTest);
      
      pse__Milestone__c milestone = new pse__Milestone__c(Name='Milestone 1', pse__Project__c = projectTest.Id, pse__Target_Date__c = System.today());
      insert milestone;
      
      OrderItem orderItem = [SELECT Id, Service_Is_Delivered__c, Service_Is_Not_Delivered__c 
                            FROM OrderItem 
                            WHERE OrderId = :order.Id 
                            LIMIT 1];

      OrderItemMilestoneAssociation__c junction = new OrderItemMilestoneAssociation__c();
      junction.Order_Product__c =  orderItem.Id;
      junction.Milestone__c = milestone.Id;
      
      insert junction;

      milestone.pse__Status__c = 'Canceled';     
      
      update milestone;
      
      pse__Proj__c projectUpdate = [SELECT Id, Closure_Reason__c FROM pse__Proj__c WHERE Id = :projectTest.Id];

      orderItem = [SELECT Id, Service_Is_Delivered__c, Service_Is_Not_Delivered__c 
                            FROM OrderItem 
                            WHERE OrderId = :order.Id 
                            LIMIT 1];
       
      System.AssertEquals('Services Not Delivered', projectUpdate.Closure_Reason__c, 'Project reason must be "Services not Delivered".');
      System.AssertEquals(false, orderItem.Service_Is_Delivered__c, 'It must be false'); 
      System.AssertEquals(true, orderItem.Service_Is_Not_Delivered__c, 'It must be true');
      
  } 
    @IsTest
    static void verifyMilestonesProcessWhenApproved(){

      Order order = OPRTestFactory.createSimpleOrder();

      pse__Proj__c projectTest = new pse__Proj__c(
          Name = 'Test Project 1',
          Project_Complexity__c = 'Low',
          pse__Account__c = order.AccountId,
          pse__Is_Active__c = true);  
       insert(projectTest);
      
      pse__Milestone__c milestone = new pse__Milestone__c(Name='Milestone 1', pse__Project__c = projectTest.Id, pse__Target_Date__c = System.today());
      insert milestone;

      OrderItem orderItem = [SELECT Id, Service_Is_Delivered__c, Service_Is_Not_Delivered__c 
                            FROM OrderItem 
                            WHERE OrderId = :order.Id 
                            LIMIT 1];

      OrderItemMilestoneAssociation__c junction = new OrderItemMilestoneAssociation__c();
      junction.Order_Product__c =  orderItem.Id;
      junction.Milestone__c = milestone.Id;
      
      insert junction;

      milestone.pse__Status__c = 'Approved';     
      
      update milestone;
      
      pse__Proj__c projectUpdate = [SELECT Id, Closure_Reason__c FROM pse__Proj__c WHERE Id = :projectTest.Id];

      orderItem = [SELECT Id, Service_Is_Delivered__c, Service_Is_Not_Delivered__c 
                            FROM OrderItem 
                            WHERE OrderId = :order.Id 
                            LIMIT 1];
       
      System.AssertEquals('Services Delivered', projectUpdate.Closure_Reason__c, 'Project reason must be "Service is Delivered".');
      System.AssertEquals(true, orderItem.Service_Is_Delivered__c, 'It must be true'); 
      System.AssertEquals(false, orderItem.Service_Is_Not_Delivered__c, 'It must be false');
      
  } 
  
    @IsTest 
    static void milestonesStatusCanceledTest() { 
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            List<pse__Milestone__c> milestonesList = new List<pse__Milestone__c>(); 
            Account account2 = new Account(Name = 'Test account 2');
            insert(account2);
            String currentNm = null;
            Test.startTest();
            pse__Proj__c project2 = new pse__Proj__c(
                Name = 'Test Project 2',
                Project_Complexity__c = 'Low',
                pse__Account__c = account2.id,
                pse__Is_Active__c = true);  
             insert(project2);
            
           pse__Milestone__c milestone1 = new pse__Milestone__c(Name='Milestone 5', Current__c = false, pse__Project__c = project2.Id, pse__Target_Date__c = System.today(),pse__Status__c = 'Open');
           pse__Milestone__c milestone2 = new pse__Milestone__c(Name='Milestone 6', Current__c = true, pse__Project__c = project2.Id, pse__Target_Date__c = System.today(),pse__Status__c = 'Open');
           milestonesList.add(milestone1);
           milestonesList.add(milestone2);    
           
           insert(milestonesList);
            
           List<pse__Milestone__c> milestonesCurrent = [SELECT Id, Name, Current__c,pse__Status__c FROM pse__Milestone__c WHERE pse__Project__c =: project2.Id ];
           for (pse__Milestone__c miles : milestonesList){
            
             if (miles.Current__c == true){
                 miles.pse__Status__c = 'Approved';
                        update(miles);
                 break;
                }
           }       
            List<pse__Milestone__c> milestonesCurrent1 = [SELECT Id, Name, Current__c,pse__Status__c FROM pse__Milestone__c WHERE pse__Project__c =: project2.Id and Current__c = true];
         
            for (pse__Milestone__c miles : milestonesCurrent1){
                 System.debug('miles Name: '+miles.Name);
                if (miles.Current__c == true){
                  currentNm = miles.Name;
                }
           }
            // System.assertEquals('Milestone 5',currentNm); 
        }
    }       
}