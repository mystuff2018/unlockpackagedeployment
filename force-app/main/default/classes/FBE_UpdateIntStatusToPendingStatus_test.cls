@isTest
public class FBE_UpdateIntStatusToPendingStatus_test {
    
    static TestMethod void FBE_UpdateIntgrationStatusToPendingStatus_test(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing1212', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1212@testorg.com',
            FBE_Siebel_User_Id__c = '121212',EmployeeNumber = '99999');
        Insert u;
    }
	
}