@isTest
public class UserHandlerForAddingToGroup_Test {
    
    @testSetup
    static void setupData()
    {
       Group fbeGrp = new Group(
                Name = 'FBE_IDS_AccountSharePM_SL_Test',
                DeveloperName = 'FBE_IDS_AccountSharePM_SL_Test'
        );
       insert(fbeGrp);
       
        
    }
    @isTest
    private static void method1()
    {  
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'PSA Project Manager'];
           Test.startTest();
        User user = new User(
                UserName = 'test251023@dell.com',
                LastName = 'One',
                Email = 'test251023@dell.com',
                Alias = 't1',
                CommunityNickname = 't1',
                Federal_Access__c = true,
                FederationIdentifier = '111222333',
                External_ID__c = '111222333',
                Organization__c = 'Test Organization',
                File_Source__c = 'AMS - System Admin',
                Dell_NTUserID__c = 'TEST',
                Service_User_Type__c = 'Admin',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profile.Id,
                LanguageLocaleKey = 'en_US',
                OSP__c = 'No',
                EmployeeNumber = '234567'
        );

        insert(user);
        system.debug('test user is:::'+user);
    Test.stopTest();
       
        Group testGroup = [SELECT Id FROM Group WHERE Name = 'FBE_IDS_AccountSharePM_SL_Test'];

        List<GroupMember> groupMembers = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :testGroup.Id];

        System.assertNotEquals(1, groupMembers.size());
    } 
    @isTest
    private static void method2()
    {
        Profile profile2 = [SELECT Id FROM Profile WHERE Name = 'PSA Project Manager'];
       
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'PSA Administrator'];
        Profile profile1 = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        Test.startTest();

        User user1 = new User(
                UserName = 'test2510@dell.com',
                LastName = 'One',
                Email = 'test2510@dell.com',
                Alias = 't1',
                CommunityNickname = 't1',
                Federal_Access__c = true,
                FederationIdentifier = '111222333',
                External_ID__c = '111222333',
                Organization__c = 'Test Organization',
                File_Source__c = 'AMS - System Admin',
                Dell_NTUserID__c = 'TEST',
                Service_User_Type__c = 'Admin',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profile.Id,
                LanguageLocaleKey = 'en_US',
                OSP__c = 'No',
                EmployeeNumber = '321'
        );

        insert(user1);
        User user2 ;
        User user3 ;
        //user.Federal_Access__c = false;
        system.runas(user1){
            
              //update(user);
                user2 = new User(
                UserName = 'test2511@dell.com',
                LastName = 'Oneone',
                Email = 'test2511@dell.com',
                Alias = 't2',
                CommunityNickname = 't2',
                Federal_Access__c = true,
                FederationIdentifier = '111222332',
                External_ID__c = '111222332',
                Organization__c = 'Test Organization12',
                File_Source__c = 'AMS - System Admin',
                Dell_NTUserID__c = 'TESTT',
                Service_User_Type__c = 'Admin',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profile2.Id,
                LanguageLocaleKey = 'en_US',
                OSP__c = 'No',
                EmployeeNumber = '322'
        );
             user3 = new User(
                UserName = 'test25112@dell.com',
                LastName = 'Oneone',
                Email = 'test2511@dell.com',
                Alias = 't2',
                CommunityNickname = 't23',
               
                Dell_NTUserID__c = 'TESTT1',
                
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profile1.Id,
                LanguageLocaleKey = 'en_US',
                
                EmployeeNumber = '3225'
        );

        insert(user2);
        insert(user3);

          }
          system.runas(user1){
              user2.ProfileId = profile1.Id;
              user3.ProfileId = profile2.Id;
              update(user2);
              update(user3);
          }

        Test.stopTest();
         
    }
 

}