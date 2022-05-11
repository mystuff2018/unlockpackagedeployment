@isTest
public class UserDeactivationTest {
    
   @testSetup
     static void setupTestData(){
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){	
        
        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'PSA Technical Resource']; 
                       
            User u = TestDataUtility.getUser('abcduyr@xyz.com');
                 u.LastName = 'jade';
                 u.ProfileId = p.id;
                 u.FBE_Services_Termination__c = System.today();
                 update u;
            
           
        }   
     }        
        @isTest
     static void updateUserTest(){
 
         user us = [Select Id,LastName,ProfileId, Profile.Name, Email from User where LastName = 'jade' Limit 1 ];
         us.FBE_Services_Termination__c = system.today().addDays(-1); 
         update us;
            
        Test.startTest();
        UserDeactivation deactivate = new UserDeactivation();
        DataBase.executeBatch(deactivate,200);
        Test.stopTest();    
     }
 

}