@isTest (seeAllData = false)
public class FBE_FPRM_UserTriggerHandlerTest {
    @isTest
    static void testAccountSharing(){
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        Profile adminProfile = [Select Id,Name from profile where Name='System Administrator' limit 1];
         FBE_FPRM_Transfer_Deal_Check__c test = new FBE_FPRM_Transfer_Deal_Check__c(
                                      SetupOwnerId = adminProfile.Id, Name = 'Test',Is_Transfer_Deal__c = false); 
        insert test;
        FBE_FPRM_Update_Child_Cases__c cstest = new FBE_FPRM_Update_Child_Cases__c(SetupOwnerId = adminProfile.Id, Name = 'Test1',Is_Disty_Account__c = false);
        Insert cstest;
        FBE_FPRM_Notification_Switch__c cms = new FBE_FPRM_Notification_Switch__c (FBE_FPRM_Cut_Over_Switch__c = false);
        insert cms;
        system.runAs(loginUser[0]){

            List<Account> accountList = FBE_Test_Utility.createAccount(4);
            insert accountList;
            accountList[0].FBE_Partner_Type__c = 'Distributor';
            accountList[0].FBE_FPRM_Partner_Reg_Status__c ='Registered';
            accountList[1].FBE_Partner_Type__c = 'Reseller';
            accountList[1].FBE_FPRM_Partner_Reg_Status__c ='Registered';
            accountList[2].FBE_FPRM_Partner_Reg_Status__c ='Registered';
            accountList[2].FBE_Partner_Type__c = 'Disty Managed';
            accountList[2].FBE_Partner_Relationship__c = 'Titanium';
            accountList[3].FBE_Partner_Type__c = 'System Integrator';
            accountList[3].Type = 'Customer';
            update accountList;

            
            List<Contact> contactList = FBE_Test_Utility.createContact(1, accountList[0].Id);
            contactList[0].Email = 'genelia.dsouza@gmail.com';
            insert contactList;
            
            List<contact> contactList2= FBE_Test_Utility.createContact(1, accountList[1].Id);
            contactList2[0].Email = 'genelia.dsouza@gmail.com';
            contactList2[0].FBE_FPRM_Reseller_Account__c = accountList[2].Id;
            insert contactList2;
            
             Id partnercaseid = [SELECT id, name from Recordtype where name='Partner Support Request' limit 1].Id;
            List<case> lstcs = new List<case>(); 
            Case cs = new Case();
            cs.RecordTypeId = partnercaseid;
            cs.Subject = 'test';
            cs.Description = 'test';
            cs.Priority = 'Medium';
            cs.Type = 'Training';
            cs.Status = 'Open';
            cs.AccountId= accountList[0].id;
            cs.contactId = contactList[0].id;
            lstcs.add(cs);
            
            system.assertEquals(cs.Status, 'Open');
           
            Case cs1 = new Case();
            cs1.RecordTypeId = partnercaseid;
            cs1.Subject = 'test1';
            cs1.Description = 'test1';
            cs1.Priority = 'Medium';
            cs1.Type = 'Training';
            cs1.Status = 'Open';
            cs1.AccountId= accountList[1].id;
            cs1.contactId = contactList2[0].id;
             lstcs.add(cs1);
            
            Case cs2 = new Case();
            cs2.RecordTypeId = partnercaseid;
            cs2.Subject = 'test1';
            cs2.Description = 'test1';
            cs2.Priority = 'Medium';
            cs2.Type = 'Quote Support';
            cs2.FBE_End_User_Email__c  = '';
            cs2.Status = 'Open';
            cs2.AccountId= accountList[1].id;
            cs2.contactId = contactList2[0].id;
             lstcs.add(cs2);
             
             Insert lstcs;
        
            system.assertEquals(cs1.Type, 'Training');
            
            List<Profile> p = [SELECT Id FROM Profile WHERE Name in('FBE FPRM Partner Distributor','FBE FPRM Partner Disty Managed')];
            User u1 = new User( email='genelia.dsouza@gmail.com',
                profileid = p[0].id, 
                UserName='trfouser@testorg.com'+'.fprm' , 
                Alias = 'GDS',
                TimeZoneSidKey='America/New_York',
                EmailEncodingKey='ISO-8859-1',
                LocaleSidKey='en_US', 
                LanguageLocaleKey='en_US',
                ContactId = contactList[0].Id,               
                PortalRole = 'Manager',
                FirstName = 'Genelia',
                LastName = 'Dsouza',
                EmployeeNumber ='1234',
                FBE_FPRM_OnlineRole__c = 'Site Admin');
            
                insert u1; 
            
            User u2 = new User( email='genelia.dsouza@gmail.com',
                profileid = p[1].id, 
                UserName='trfouser67@testorg.com'+'.fprm' , 
                Alias = 'GDS1',
                TimeZoneSidKey='America/New_York',
                EmailEncodingKey='ISO-8859-1',
                LocaleSidKey='en_US', 
                LanguageLocaleKey='en_US',
                ContactId = contactList2[0].Id,               
                PortalRole = 'Manager',
                FirstName = 'Genelia1',
                LastName = 'Dsouza1',
                EmployeeNumber ='1234789',
                FBE_FPRM_OnlineRole__c = 'Disty Managed Site Admin');
            
                insert u2; 

            list<Account_Affiliation__c> lstaff = new list<Account_Affiliation__c>();
            Account_Affiliation__c aff = new Account_Affiliation__c();
            aff.FBE_Account__c = accountList[0].Id;
            aff.FBE_Affilitated_Account__c = accountList[1].Id;
            aff.FBE_Relationship__c ='Reseller';
            aff.FBE_Start_Date__c = System.today();
            aff.FBE_End_Date__c = aff.FBE_Start_Date__c+2;
            lstaff.add(aff);
            
            Account_Affiliation__c aff2 = new Account_Affiliation__c();
            aff2.FBE_Account__c = accountList[1].Id;
            aff2.FBE_Affilitated_Account__c = accountList[0].Id;
            aff2.FBE_Relationship__c ='Distributor';
            aff2.FBE_Start_Date__c = System.today();
            aff2.FBE_End_Date__c = aff2.FBE_Start_Date__c+2;
            lstaff.add(aff2);
            
            Account_Affiliation__c aff3 = new Account_Affiliation__c();
            aff3.FBE_Account__c = accountList[0].Id;
            aff3.FBE_Affilitated_Account__c = accountList[1].Id;
            aff3.FBE_Relationship__c ='Disty Managed';
            aff3.FBE_Start_Date__c = System.today();
            lstaff.add(aff3); 
            
            Insert lstaff;
            
            Deal_Registration__c Deal = FBE_UtilityFactory_Test.createDeal(1)[0];
            Deal.FBE_Deal_Justification_Statement__c = 'test statement';
            Deal.Name = 'test 1234';
            Deal.FBE_Account__c = accountList[0].Id;
            Deal.FBE_End_User_Account__c = accountList[0].Id;
            Deal.FBE_Distributor_Account__c = accountList[0].Id;
            Deal.FBE_Reseller_VAR_Account__c = accountList[0].Id;
            Deal.FBE_Partner_Sales_Rep_Email__c = 'genelia.dsouza@gmail.com';
            Deal.FBE_Partner_Owner_Email__c = 'genelia.dsouza@gmail.com';
            Deal.FBE_Book_Date__c = system.now().Date();
            Deal.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            Deal.Sales_Stage__c = 'Plan - 1%';
            Deal.FBE_Solution_Domain__c = 'Business Solutions';
            //Deal.First_Reminder__c = system.now();  
            //Deal.Second_Reminder__c = system.now();
            Deal.FBE_Deal_Product_Classification__c = 'EMC Products';
            //Deal.AE_Manager_Id__c = lUsr[0].ManagerID;
            Deal.FBE_Deal_Registration_Status__c ='New';
            Deal.FBE_Submission_Date__c = system.now();
           // Deal.FBE_PMO_Substatus__c = '';
            Deal.FBE_Analyst_Observations_History__c = 'test';
            insert Deal;
                      
                      
            System.debug('aaf2===='+aff2);
            Map<Id, User> userMap = new Map<Id, User>([SELECT Id,ContactId,Contact.AccountId,AccountId,contact.FBE_FPRM_Reseller_Account__c FROM User where AccountId =:accountList]); //where contactId =:contactList]);
            List<Id> userIdList = new List<Id>(userMap.keySet()); 
            List<User> u = new List<User>();
            u.add(u2);
             String jsonString = JSON.serializePretty(u);
            system.debug('u'+u);
            System.debug('jsonString'+jsonString);
            String jas = '"recentItems" : ['+'"attributes" : {'+
      '"type" : "User",'+'"url" : "/services/data/v51.0/sobjects/User/005t0000005BGiuAAG"'+'},'+'"Id" : "005t0000005BGiuAAG",'+'"Name" : "Amanpal Anand"'+'}]';
            
            
            List<Account_Affiliation__c> affList = new List<Account_Affiliation__c>([SELECT Id,
                                                                                             FBE_Account__c,
                                                                                             FBE_Affilitated_Account__c,
                                                                                             FBE_Relationship__c,
                                                                                             FBE_Account__r.FBE_Partner_Type__c,
                                                                                             FBE_Start_Date__c,
                                                                                             FBE_End_Date__c
                                                                                             FROM Account_Affiliation__c ]);

            
            FBE_FPRM_UserTriggerHandler.updateDealRegDetailsonUserInsert(JSON.serialize(userMap.values()));
            
            FBE_FPRM_UserTriggerHandler.shareRelatedDistributorAccountWithPartner(userIdList);
            
         
            List<Id> newListIds = new List<Id>();
            newListIds.addAll(userMap.keySet());
           FBE_FPRM_UserTriggerHandler.UpdateContactInfo(newListIds ,JSON.serialize(userMap));
        }

    }

}