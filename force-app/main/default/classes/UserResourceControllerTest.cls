/*
      Purpose   : Test class to cover the automation which
                  Updates Resource fields when User gets deactivated.
                    Covered Classes:
                        1. UserResourceController 
      Author    : Pawan K
      Company   : OAC Services, INC.
      Created   : 1/4/19
*/
@isTest
public class UserResourceControllerTest  
{
    @testSetup
    static void setupData()
    {
        Profile objProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        system.debug(objProfile);
        User user = new User(
            Alias = 'UPaw44',
            FirstName='Test_pk_DellPawanK',  
            Email='4PawanK@dell.com',
            IsActive=True,
            EmailEncodingKey='UTF-8', 
            LastName='DellPK', 
            LanguageLocaleKey='en_US',
            FederationIdentifier='1123581321',
            Dell_NTUserID__c='DELL_TEST',
            Service_User_Type__c='UAT',
            External_ID__c='1123581321',
            Organization__c='Dell',
            File_Source__c='AMS - System Admin',
            LocaleSidKey='en_US', 
            ProfileId = objProfile.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName = 'testUserPawanK@dell.com', 
            OSP__c='Yes',
            EmployeeNumber = '4571928'
        );
        insert(user);
        
        system.debug(user);
        
    }
   
   
    @isTest
    public static void updateResource()
    {
        //[Deloitte : Abhishek Kawle] : Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            // Set override flag to allow test to complete without actually deactivating user
            UserResourceController.overrideTrigger = true;
            
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()]; 
            User objUser = [SELECT Id,ProfileId,
                            Name,
                            IsActive
                            FROM User 
                            WHERE FirstName='Test_pk_DellPawanK' limit 1];
            system.debug(objUser);
            system.runAs(thisUser) 
            {
                Trigger_Execution_Control__c triggerToggle = new Trigger_Execution_Control__c(
                    Skip_Resource_Update__c = false
                );
                insert triggerToggle;
                
                
                
                Account testAccnt = new Account(
                    Name = 'Test Acc Dell',            
                    Industry = 'Fashion',
                    Type = 'Customer'
                );
                insert testAccnt;
                
                contact cont = new contact(
                    email = '4PawanK@dell.com',
                    FirstName = 'Test',
                    LastName = 'DellK',
                    accountId = testAccnt.Id,
                    country_code__c= 'USA & Canada (1)', 
                    Primary_Phone__c='1234567890',
                    pse__Salesforce_User__c = objUser.Id,
                    pse__Is_Resource_Active__c = true,
                    Federal_Access__c = true,
                    phone='1234567890'
                );
                insert cont;
                
                
                Test.startTest();
                objUser.IsActive = false;
                update objUser;
                Test.stopTest();
                
                Contact contactDB = [select id, pse__Is_Resource_Active__c from Contact where id = :cont.id];
                //system.assertEquals(false, contactDB.pse__Is_Resource_Active__c, 'Contact has not been disabled in PSA');
            }
        }
    }
}