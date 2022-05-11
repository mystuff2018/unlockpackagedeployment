/*
*@ Class Name     : FBE_PermissionsetAssignmentHandlerTest
*@ Description      : Test class of FBE_PermissionsetAssignmentHandler and UserTrigger.
*@ CreatedBy        : Deloitte Consulting
*@ CreatedOn        : 08-02-2017 [Uttam Kavitkar]
*@ Modification Log :                     
*/
@isTest
public class FBE_PermissionsetAssignmentHandlerTest {
    
    
    //setup data for test cases
    @testSetup static void setup() {
        
         Profile adminProfile = [Select Id,Name from profile where Name='System Administrator' limit 1];
        List<FBE_FPRM_Transfer_Deal_Check__c>customSettingList = new List<FBE_FPRM_Transfer_Deal_Check__c>();
        
        FBE_FPRM_Transfer_Deal_Check__c test = new FBE_FPRM_Transfer_Deal_Check__c(
                                      SetupOwnerId = adminProfile.Id, Name = 'Test',Is_Transfer_Deal__c = true); 
		customSettingList.add(test); 
        
        FBE_FPRM_Transfer_Deal_Check__c settings = FBE_FPRM_Transfer_Deal_Check__c.getOrgDefaults();
        settings.Is_Transfer_Deal__c = false;
        customSettingList.add(settings); 
    
        Upsert customSettingList;
        
        
        User usr = [Select Id from user where Userrole.Name  = 'Integration Role'];
        system.runAs(usr){
            //Create Accounts    
            Account acc = new Account();
            acc.Name = 'TestDistributorAccount01';
            acc.Type = 'Customer';
            acc.FBE_Account_Class__c = 'Direct';
            acc.FBE_Status__c = 'Active';
            acc.FBE_Partner__c = true;
            acc.FBE_Partner_Type__c = 'Distributor';
            acc.FBE_Partner_Relationship__c = 'Titanium';
            acc.FBE_FPRM_Partner_Reg_Status__c = 'Registered';
            insert acc;
            
            Account acc2 = new Account();
            acc2.Name = 'TestDMPAccount01';
            acc2.Type = 'Customer';
            acc2.FBE_Account_Class__c = 'Indirect';
            acc2.FBE_Status__c = 'Active';
            acc2.FBE_Partner__c = true;
            acc2.FBE_Partner_Type__c = 'Disty Managed';
            acc2.FBE_Partner_Relationship__c = 'Titanium';
            insert acc2;  
            
            //Create Contacts
            Id recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
            Contact c = new Contact();
            c.AccountId = acc.Id;
            c.FirstName = 'testDistributor';
            c.LastName = 'Contact01';
            c.email = 'test@test.com';
            c.RecordTypeId = recordTypeIdContact; 
            c.Country_Code_CAM__c = '1';
            c.Phone = '9897654634';
            insert c;
            
            Contact c2 = new Contact();
            c2.AccountId = acc.Id;
            c2.FirstName = 'testDMP';
            c2.LastName = 'Contact01';
            c2.email = 'test@test02.com';
            c2.Country_Code_CAM__c = '1';
            c2.Phone = '9897654742';
            c2.RecordTypeId = recordTypeIdContact;
            c2.FBE_FPRM_Reseller_Account__c = acc2.Id;
            insert c2;
            
            Contact c3 = new Contact();
            c3.AccountId = acc.Id;
            c3.FirstName = 'testDistributor';
            c3.LastName = 'Contact03';
            c3.email = 'test@test3.com';
            c3.RecordTypeId = recordTypeIdContact; 
            c3.Country_Code_CAM__c = '1';
            c3.Phone = '9897654667';
            insert c3;
            
        } 
        
    }
    
    static testMethod void testDefaultParterOwner(){
        //Get the contact created in setup method
        
        Contact con2 = [Select Id,Name,FBE_FPRM_Reseller_Account__c,AccountId from Contact where Name = 'testDMP Contact01'];
		//Get the partner user profiles
         Profile DMPProfile = [Select Id from profile where Name='FBE FPRM Partner Disty Managed'];
        
        //Create unique username 
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');    
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        //Create users
       User usr2 =new User(firstname = 'ABC2', 
                         lastName = 'XYZ2', 
                         email = 'test@test02.com', 
                         Username = uniqueName + '@test2' + orgId + '.org'+'.fprm', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = DMPProfile.Id,
                         ContactId = con2.Id,
                         IsActive = true,
                         FBE_FPRM_OnlineRole__c = 'Disty Managed Site Admin'
                          );         
        insert usr2;
        
        system.runAs(usr2){
            
            Deal_Registration__c Deal = FBE_UtilityFactory_Test.createDeal(1)[0];
            Deal.FBE_Deal_Justification_Statement__c = 'test statement';
            Deal.Name = 'TEst 12345729_366';
            //Deal.FBE_Account__c = acct[0].Id;
            Deal.FBE_Account__c = con2.AccountId;
            Deal.FBE_Distributor_Account__c = con2.AccountId;
            Deal.FBE_Reseller_VAR_Account__c = con2.FBE_FPRM_Reseller_Account__c;
           // Deal.FBE_FSI_Account__c = lAcc[0].Id;
            //Deal.FBE_Related_Opportunity__c = opp.Id;
            //Deal.FBE_Price_Book_Id__c = standardPricebook.ID;
            Deal.FBE_Book_Date__c = system.now().Date();
            Deal.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            deal.Sales_Stage__c = 'Plan - 1%';
            deal.FBE_Solution_Domain__c = 'Business Solutions';
            //Deal.First_Reminder__c = system.now();  
            //Deal.Second_Reminder__c = system.now();
            Deal.FBE_Deal_Product_Classification__c = '';
            Deal.FBE_Fulfilment_Path__c = 'Distribution';
            //Deal.AE_Manager_Id__c = lUsr[0].ManagerID;
            Deal.FBE_Deal_Registration_Status__c ='New';
            Deal.FBE_Submission_Date__c = system.now();
            Deal.FBE_Deal_Submitter_Phone__c = '9993933';
            Deal.FBE_Customer__c = '650009091900';
            Deal.FBE_Deal_Reg_Partner_Direct__c = '6500090919001'; 
           // Deal.FBE_PMO_Substatus__c = '';
            insert Deal;
            
        }
        
        //Update user role	
        usr2.FBE_FPRM_OnlineRole__c = 'Disty Managed Sales Rep My Opty';	
        update usr2;
        
    }
    
    static testMethod void validatePermissionSetAssignment(){
        
        //Get the contact created in setup method
        Contact con1 = [Select Id,Name,FBE_FPRM_Reseller_Account__c from Contact where Name = 'testDistributor Contact01'];
        Contact con2 = [Select Id,Name,FBE_FPRM_Reseller_Account__c from Contact where Name = 'testDMP Contact01'];
        Contact con3 = [Select Id,Name,FBE_FPRM_Reseller_Account__c from Contact where Name = 'testDistributor Contact03'];
        
        //Get the partner user profiles
        Profile distributorProfile = [Select Id from profile where Name='FBE FPRM Partner Distributor'];
        Profile DMPProfile = [Select Id from profile where Name='FBE FPRM Partner Disty Managed'];
        
        //Create unique username 
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');    
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        Test.startTest();
        //Create users
        User usr =new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = 'test@test.com', 
                         Username = uniqueName + '@test' + orgId + '.org'+'.fprm', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = distributorProfile.Id,
                         ContactId = con1.Id,
                         FBE_FPRM_OnlineRole__c = 'Site Admin'
                          );         
        insert usr;
        
        User usr2 =new User(firstname = 'ABC2', 
                         lastName = 'XYZ2', 
                         email = 'test@test02.com', 
                         Username = uniqueName + '@test2' + orgId + '.org'+'.fprm', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = DMPProfile.Id,
                         ContactId = con2.Id,
                         IsActive = true,
                         FBE_FPRM_OnlineRole__c = 'Disty Managed Site Admin'
                          );         
        insert usr2;
         
        User usr3 =new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = 'test@test3.com', 
                         Username = uniqueName + '@test03' + orgId + '.org'+'.fprm', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = distributorProfile.Id,
                         ContactId = con3.Id,
                         FBE_FPRM_OnlineRole__c = 'Site Admin'
                          );         
        insert usr3;
        
        //Update user
        usr.FBE_FPRM_OnlineRole__c = 'Sales Rep My Opty';
        update usr;    
        
        usr.FBE_FPRM_OnlineRole__c = 'Site Admin';	
        update usr; 
        
        usr.FBE_FPRM_OnlineRole__c = 'Sales Rep Case';	
        update usr; 
        
        usr3.FBE_FPRM_OnlineRole__c = 'Sales Rep My Opty';	
        update usr3; 
        
        
       String result = FBE_PermissionsetAssignmentHandler.getPartnerUser(con1.Id);
       System.assertNotEquals(null, result);
        
       Test.stopTest();
        
        usr.IsActive = false;
        update usr; 
        
    }
}