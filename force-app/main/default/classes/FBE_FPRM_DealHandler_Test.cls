/**************
 * @ Class Name        : FBE_FPRM_DealHandler_Test
 * @ Description       : This class is created to test code coverage for -  FBE_FPRM_DealHandler class.
 *                       Created as part of Defect #10461676.
 * @ CreatedBy         : Deloitte
 * @ CreatedOn         : 04-20-2021
 * @ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script
*********/
@isTest
public class FBE_FPRM_DealHandler_Test {
        
        //Method for test data setup
    @TestSetup
    static void setUpData() {
        
        Profile adminProfile = [Select Id,Name from profile where Name='System Administrator' limit 1];
        List<FBE_FPRM_Transfer_Deal_Check__c>customSettingList = new List<FBE_FPRM_Transfer_Deal_Check__c>();
        
        FBE_FPRM_Transfer_Deal_Check__c test = new FBE_FPRM_Transfer_Deal_Check__c(
                                      SetupOwnerId = adminProfile.Id, Name = 'Test',Is_Transfer_Deal__c = true); 
		customSettingList.add(test); 
        
        FBE_FPRM_Transfer_Deal_Check__c settings = FBE_FPRM_Transfer_Deal_Check__c.getOrgDefaults();
        settings.Is_Transfer_Deal__c = false;
        customSettingList.add(settings); 
        UPSERT customSettingList;
        
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        system.runAs(lUsr){
            List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(2,null);
            lAcc[0].FBE_Partner_Type__c = 'Distributor';
            lAcc[0].FBE_Partner__c = true;
            lAcc[0].FBE_FPRM_Partner_Reg_Status__c = 'Registered';
            lAcc[1].FBE_Partner_Type__c = 'Disty Managed';
            lAcc[1].FBE_FPRM_Partner_Reg_Status__c = 'Qualified';
            insert lAcc;
            
            List<Contact> prmContacts = FBE_Test_Utility.createContact(4, lAcc[0].Id);
            prmContacts[2].FBE_FPRM_Reseller_Account__c = lAcc[1].Id;
            prmContacts[3].FBE_FPRM_Reseller_Account__c = lAcc[1].Id;
            prmContacts[3].Email = prmContacts[2].Email;
            prmContacts[0].Phone = '9876896510';
            prmContacts[1].Phone = '9876896511';
            prmContacts[2].Phone = '9876896512';
            prmContacts[3].Phone = '9876896513';
            insert prmContacts;
            
            //Create 2 Users, 1 for each Partner profile 
            Profile distributorProfile = [Select Id, Name from profile where Name='FBE FPRM Partner Distributor'];
            Profile DMPProfile = [Select Id, Name from profile where Name='FBE FPRM Partner Disty Managed'];
            
            List<User> userList = new List<User>();
            String uniqueUserName = 'adminuser' + DateTime.now().getTime();
            User user1 = new User(
                firstname = 'TestDistributor', 
                lastName = 'User1', 
                email = prmContacts[0].Email, 
                Username = uniqueUserName + '@test1.com'+'.fprm', 
                EmailEncodingKey = 'ISO-8859-1', 
                Alias = 'di1user1', 
                TimeZoneSidKey = 'America/Los_Angeles', 
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US', 
                ProfileId = distributorProfile.Id,
                isActive = true,
                ContactId = prmContacts[0].Id,
                FBE_FPRM_OnlineRole__c = 'Sales Rep My Opty',
                phone ='9876896510' //JSK
            );            
            userList.add(user1);
            User user2 = new User(
                firstname = 'TestDMP', 
                lastName = 'User2', 
                email = prmContacts[2].Email, 
                Username = uniqueUserName + '@test2.com'+'.fprm', 
                EmailEncodingKey = 'ISO-8859-1', 
                Alias = 'dm2user2', 
                TimeZoneSidKey = 'America/Los_Angeles', 
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US', 
                ProfileId = DMPProfile.Id,
                ContactId = prmContacts[2].Id,
                FBE_FPRM_OnlineRole__c = 'Disty Managed Sales Rep My Opty'
            );
                User user3 = new User(
                firstname = 'TestDistributor', 
                lastName = 'User3', 
                email = prmContacts[1].Email, 
                Username = uniqueUserName + '@test3.com'+'.fprm', 
                EmailEncodingKey = 'ISO-8859-1', 
                Alias = 'di1user3', 
                TimeZoneSidKey = 'America/Los_Angeles', 
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US', 
                ProfileId = distributorProfile.Id,
                isActive = true,
                ContactId = prmContacts[1].Id,
                FBE_FPRM_OnlineRole__c = 'Sales Rep My Opty'
            );
            User user4 = new User(
                firstname = 'TestDMP', 
                lastName = 'User4', 
                email = prmContacts[2].Email, 
                Username = uniqueUserName + '@test4.com'+'.fprm', 
                EmailEncodingKey = 'ISO-8859-1', 
                Alias = 'dm2user4', 
                TimeZoneSidKey = 'America/Los_Angeles', 
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US', 
                ProfileId = DMPProfile.Id,
                ContactId = prmContacts[3].Id,
                FBE_FPRM_OnlineRole__c = 'Disty Managed Sales Rep My Opty'
            );
            userList.add(user2);
            userList.add(user3);
            userList.add(user4);
            insert userList;            
         
        }
    }
    @isTest
    static void testDeal_FRPM_Submit_Reject(){
        Test.startTest();
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        
        Account distyAccount = [SELECT id,FBE_Partner__c FROM Account WHERE FBE_Partner_Type__c ='Distributor' LIMIT 1];
        
        List<Accountteammember> actteamList =new List<Accountteammember>();
        Accountteammember atm1=new Accountteammember();
        atm1.AccountId=distyAccount.id;
        atm1.UserId= Userinfo.getUserId();
        atm1.TeamMemberRole='SR';
        actteamList.add(atm1);
        
        Accountteammember atm2=new Accountteammember();
        atm2.AccountId=distyAccount.id;
        atm2.UserId= lUsr.Id;
        atm2.TeamMemberRole='SR';
        actteamList.add(atm2);
        
        INSERT actteamList;
        
        Profile distiProfile = [Select Id,Name from profile where Name='FBE FPRM Partner Distributor' limit 1];
        
        FBE_FPRM_Transfer_Deal_Check__c cs = FBE_FPRM_Transfer_Deal_Check__c.getOrgDefaults();
        cs.SetupOwnerId = distiProfile.Id;
        UPDATE cs;
        
        Deal_Registration__c Deal = FBE_UtilityFactory_Test.createDeal(1)[0];
        Deal.FBE_Deal_Justification_Statement__c = 'test statement';
        Deal.Name = 'testdeal@1234';
        Deal.FBE_Account__c = distyAccount.Id;
        Deal.FBE_End_User_Account__c = distyAccount.Id;
        Deal.FBE_Distributor_Account__c = distyAccount.Id;
        Deal.FBE_Book_Date__c = system.now().Date();
        Deal.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover'; 
        deal.Sales_Stage__c = 'Plan - 1%';
        deal.FBE_Solution_Domain__c = 'Business Solutions';
        Deal.FBE_Deal_Registration_Status__c ='New';
        Deal.FBE_Submission_Date__c = system.now();
        Deal.FBE_Same_as_submitter__c = 'Yes';
        Deal.FBE_Deal_Product_Classification__c = '';
        
     
        Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true
        );
        insert prod;
        
        FBE_FPRM_Notification_Switch__c settings = FBE_FPRM_Notification_Switch__c.getOrgDefaults();
        settings.Send_Deal_Approval_Emails__c = true;
        settings.Send_Deal_Rejection_Emails__c = true;
        settings.Send_Deal_Submission_Emails__c = true;
        settings.FBE_FPRM_Cut_Over_Switch__c = true;
        upsert settings;
        
        User prmUser = [SELECT id,isActive,Contact.AccountID,email FROM User WHERE Profile.name ='FBE FPRM Partner Distributor' AND isActive=true AND FirstName ='TestDistributor' AND
                        LastName = 'User1' limit 1];
        System.runAs(prmUser){
            insert Deal;
            UserRecordAccess usrd =[SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess FROM UserRecordAccess WHERE UserId=:prmUser.id AND RecordId =: prod.id];
            Deal_Product__c dealProd = new  Deal_Product__c();
            dealProd.Deal_Registration_Name__c = Deal.Id;            
            dealProd.FBE_Product__c = prod.id;
            dealProd.FBE_Quantity__c = 6;
            dealProd.FBE_Sales_price__c = 10000;
            insert dealProd; 
            
            Deal_Registration__c updDeal = new Deal_Registration__c();
            updDeal.Id = Deal.Id;
            updDeal.FBE_Deal_Registration_Status__c = 'Submitted';
            UPDATE updDeal;
            
        }
        Deal_Registration__c approveDeal = new Deal_Registration__c();
        approveDeal.Id = Deal.Id;
        approveDeal.FBE_Deal_Registration_Status__c = 'Rejected';
        approveDeal.FBE_Declined_Reason__c = 'Reject - Other';
        approveDeal.FBE_Decline_Comments__c = 'test Reject';
        UPDATE approveDeal;
        Test.stopTest();
        
        System.assertEquals(approveDeal.FBE_Deal_Registration_Status__c, 'Rejected');
    }
    
    
	
    
    //[Deloitte : Abhishek Kawle] 04/21/2021 - Method to test Deal Insertion logic
    @isTest
    private static void testDealHandlerMethods(){
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List<User> userList = [SELECT Id, Name, Email FROM User WHERE Alias IN ('di1user1','dm2user2','di1user3','dm2user4')];
        Id distributorAc, distyManagedAc;
        
        for(Account eaAcc : [SELECT Id, FBE_Partner_Type__c FROM Account LIMIT 2]){
            if(eaAcc.FBE_Partner_Type__c == 'Distributor'){
                distributorAc = eaAcc.Id;
            }
            if(eaAcc.FBE_Partner_Type__c == 'Disty Managed'){
                distyManagedAc = eaAcc.Id;
            }
        }
        
        List<Deal_Registration__c> dealList = new List<Deal_Registration__c>();
        Deal_Registration__c Deal = FBE_UtilityFactory_Test.createDeal(1)[0];
            Deal.FBE_Deal_Justification_Statement__c = 'test statement';
            Deal.Name = 'test 1234';
            Deal.FBE_Account__c = distributorAc;
            Deal.FBE_Distributor_Account__c = distributorAc;
        	Deal.FBE_Reseller_VAR_Account__c = distyManagedAc;
            Deal.FBE_Book_Date__c = system.now().Date()+2;
            Deal.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            deal.Sales_Stage__c = 'Plan - 1%';
            deal.FBE_Solution_Domain__c = 'Business Solutions';
            Deal.FBE_Deal_Registration_Status__c ='New';
            Deal.FBE_Submission_Date__c = system.now();
        	Deal.FBE_Partner_Owner__c = userList[0].Name;
        	Deal.FBE_Partner_Owner_Email__c = userList[0].Email;
        	Deal.FBE_Partner_Sales_Rep_Name__c = userList[1].Name;
        	Deal.FBE_Partner_Sales_Rep_Email__c = userList[1].Email;
        	dealList.add(Deal);
        if(!dealList.isEmpty()){
            insert dealList;
        }
        Test.startTest();
        Deal_Registration__c deal2 = new Deal_Registration__c(
            Id = Deal.Id,
        	FBE_Partner_Owner__c = userList[2].Name,
            FBE_Partner_Owner_Email__c = userList[2].Email,
            FBE_Partner_Sales_Rep_Name__c = userList[3].Name,
            FBE_Partner_Sales_Rep_Email__c = userList[3].Email
            
        );
        update deal2;
        
        Test.stopTest();
        
        System.assertEquals(deal2.FBE_Partner_Sales_Rep_Name__c, 'TestDMP User4');
    }

}