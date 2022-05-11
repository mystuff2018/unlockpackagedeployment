/*
*@ Class Name     : FBE_FPRM_DistyTransferBatchTest
*@ Description      : This class covers code the coverage for the below classes
FBE_FPRM_DistyTransferBatch, FBE_FPRM_DistyTransferBatch_Handler,
FBE_FPRM_DistyTransferScheduler, FBE_FPRM_ShareAccountWithPartnesHandler(Method:distyManualTransfer),
FBE_FPRM_DistyConfigAfflScheduler.

*@ CreatedBy        : Dell team - FPRM
*@ CreatedOn        : 1-June-2021 [Sai Kumar, Sireesha Myla]
*@ Modification Log :  15th June 2021                   
*/
@isTest
public class FBE_FPRM_DistyTransferBatchTest
{
    @testSetup static void setup() 
    {
        User usr = [Select Id from user where Userrole.Name  = 'Integration Role'];
        Profile adminProfile = [Select Id,Name from profile where Name='System Administrator' limit 1];
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        List<FBE_FPRM_Transfer_Deal_Check__c>customSettingList = new List<FBE_FPRM_Transfer_Deal_Check__c>();
        
        FBE_FPRM_Transfer_Deal_Check__c test = new FBE_FPRM_Transfer_Deal_Check__c(
            SetupOwnerId = adminProfile.Id, Name = 'Test',Is_Transfer_Deal__c = true); 
        customSettingList.add(test); 
        
        FBE_FPRM_Transfer_Deal_Check__c settings = FBE_FPRM_Transfer_Deal_Check__c.getOrgDefaults();
        settings.Is_Transfer_Deal__c = false;
        customSettingList.add(settings); 
        
        FBE_FPRM_Notification_Switch__c disty = new FBE_FPRM_Notification_Switch__c(FBE_FPRM_Enable_Disty_Transfer__c = true);
        //disty.FBE_FPRM_Enable_Disty_Transfer__c = true;
        insert disty;
        
        UPSERT customSettingList;
        Id recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
        
        system.runAs(usr)
        {
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
            accList.add(acc);
            
            Account acc2 = new Account();
            acc2.Name = 'TestDMPAccount01';
            acc2.Type = 'Customer';
            acc2.FBE_Account_Class__c = 'Indirect';
            acc2.FBE_Status__c = 'Active';
            acc2.FBE_Partner__c = true;
            acc2.FBE_Partner_Type__c = 'Disty Managed';
            acc2.FBE_Partner_Relationship__c = 'Titanium';
            accList.add(acc2); 
            
            Account acc3 = new Account();
            acc3.Name = 'TestResellerAccount01';
            acc3.Type = 'Customer';
            acc3.FBE_Account_Class__c = 'Indirect';
            acc3.FBE_Status__c = 'Active';
            acc3.FBE_Partner__c = true;
            acc3.FBE_Partner_Type__c = 'Reseller';
            acc3.FBE_Partner_Relationship__c = 'Titanium';
            accList.add(acc3); 
            insert accList;
            
            Account newDist = new Account();
            newDist.Name = 'TestNewDistributorAccount01';
            newDist.Type = 'Customer';
            newDist.FBE_Account_Class__c = 'Direct';
            newDist.FBE_Status__c = 'Active';
            newDist.FBE_Partner__c = true;
            newDist.FBE_Partner_Type__c = 'Distributor';
            newDist.FBE_Partner_Relationship__c = 'Titanium';
            newDist.FBE_FPRM_Partner_Reg_Status__c = 'Registered';
            insert newDist;
            Contact cnew = new Contact();
            cnew.AccountId = newDist.Id;
            cnew.FirstName = 'testnewDistributor';
            cnew.LastName = 'newContact01';
            cnew.email = 'test@testnew.com';
            cnew.Phone = '9999999999';
            cnew.RecordTypeId = recordTypeIdContact; 
            cnew.FBE_FPRM_Partner_Online_Role__c = 'Site Admin';
            cnew.FBE_FPRM_Sharing_Account__c = newDist.Id;
            insert cnew;
            
            newDist.FBE_FPRM_Disti_Switch_Contact__c = cnew.id;
            update newDist;
            
            Account accDMP = new Account();
            accDMP.Name = 'TestDMPAccount02';
            accDMP.Type = 'Customer';
            accDMP.FBE_Account_Class__c = 'Indirect';
            accDMP.FBE_Status__c = 'Active';
            accDMP.FBE_Partner__c = true;
            accDMP.FBE_Partner_Type__c = 'Disty Managed';
            accDMP.FBE_Partner_Relationship__c = 'Titanium';
            insert accDMP;  
            
            List<Account> accounts = [select Id,Name,FBE_Partner_Type__c from Account where id in:accList];
            Account distAcc = [select id from Account where name in ('TestDistributorAccount01')];
            //Create Contacts
            for(Account accnt: accounts)
            {
                if(accnt.FBE_Partner_Type__c == 'Distributor' )
                {
                    Contact c = new Contact();
                    c.AccountId = accnt.Id;
                    c.FirstName = 'testDistributor';
                    c.LastName = 'Contact01';
                    c.email = 'test@test.com';
                    c.Phone = '9999999999';
                    
                    c.RecordTypeId = recordTypeIdContact;
                    c.FBE_FPRM_Sharing_Account__c = accnt.Id;
                    conList.add(c);
                    
                    
                    Contact c2 = new Contact();
                    c2.AccountId = accnt.Id;
                    c2.FirstName = 'testDMP';
                    c2.LastName = 'Contact01';
                    c2.Phone = '9999999999';
                    c2.email = 'test@test02.com';
                    c2.RecordTypeId = recordTypeIdContact;
                    c2.FBE_FPRM_Reseller_Account__c = accDMP.Id;
                    c2.FBE_FPRM_Sharing_Account__c = accDMP.Id;
                    conList.add(c2);
                }
                if(accnt.FBE_Partner_Type__c == 'Reseller')
                {
                    Contact c3 = new Contact();
                    c3.AccountId = accnt.Id;
                    c3.FirstName = 'testReseller';
                    c3.LastName = 'Contact01';
                    c3.email = 'test@test03.com';
                    c3.Phone = '9999999999';
                    c3.RecordTypeId = recordTypeIdContact;
                    //c3.FBE_FPRM_Sharing_Account__c = accnt.Id;
                    conList.add(c3);
                }
            }
            insert conList;
            
            
            Contact con2 = [Select Id,Name,AccountId,FBE_FPRM_Reseller_Account__c from Contact where Name = 'testDMP Contact01'];
            Contact conDist = [Select Id,Name,AccountId,FBE_FPRM_Reseller_Account__c from Contact where Name = 'testDistributor Contact01'];
            Contact conRes = [Select Id,Name,AccountId,FBE_FPRM_Reseller_Account__c from Contact where Name = 'testReseller Contact01'];
            Contact conNewDist = [Select Id,Name,AccountId,FBE_FPRM_Reseller_Account__c from Contact where Name = 'testnewDistributor newContact01'];
            
            
            Profile DMPProfile = [Select Id from profile where Name='FBE FPRM Partner Disty Managed'];
            Profile DistProfile = [Select Id from profile where Name='FBE FPRM Partner Distributor'];
            Profile ResellerProfile = [Select Id from profile where Name='FBE FPRM Partner Reseller'];
            
            //Create unique username 
            String orgId=UserInfo.getOrganizationId(); 
            String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');    
            Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
            String uniqueName=orgId+dateString+RandomId; 
            //Create users
            List<User>usrList = new List<User>();
            User usr2 =new User(firstname = 'ABC2', 
                                lastName = 'DMP', 
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
                               );  usrList.add(usr2); 
            User usr5 =new User(firstname = 'ABC2', 
                                lastName = 'DistyContact', 
                                email = 'test@testnew.com', 
                                Username = uniqueName + '@test5' + orgId + '.org'+'.fprm', 
                                EmailEncodingKey = 'ISO-8859-1', 
                                Alias = uniqueName.substring(18, 23), 
                                TimeZoneSidKey = 'America/Los_Angeles', 
                                LocaleSidKey = 'en_US', 
                                LanguageLocaleKey = 'en_US', 
                                ProfileId = DistProfile.Id,
                                ContactId = cnew.Id,
                                IsActive = true,
                                FBE_FPRM_OnlineRole__c = 'Site Admin' 
                               );  usrList.add(usr5); 
            User usr3 =new User(firstname = 'ABC2', 
                                lastName = 'Reseller', 
                                email = 'test@test03.com', 
                                Username = uniqueName + '@test3' + orgId + '.org'+'.fprm', 
                                EmailEncodingKey = 'ISO-8859-1', 
                                Alias = uniqueName.substring(18, 23), 
                                TimeZoneSidKey = 'America/Los_Angeles', 
                                LocaleSidKey = 'en_US', 
                                LanguageLocaleKey = 'en_US', 
                                ProfileId = ResellerProfile.Id,
                                ContactId = conRes.Id,
                                IsActive = true,
                                FBE_FPRM_OnlineRole__c = 'Site Admin' 
                               );   usrList.add(usr3);
            User usr4 =new User(firstname = 'ABC2', 
                                lastName = 'Dist', 
                                email = 'test@test.com', 
                                Username = uniqueName + '@test4' + orgId + '.org'+'.fprm', 
                                EmailEncodingKey = 'ISO-8859-1', 
                                Alias = uniqueName.substring(18, 23), 
                                TimeZoneSidKey = 'America/Los_Angeles', 
                                LocaleSidKey = 'en_US', 
                                LanguageLocaleKey = 'en_US', 
                                ProfileId = DistProfile.Id,
                                ContactId = conDist.Id,
                                IsActive = true,
                                FBE_FPRM_OnlineRole__c = 'Site Admin' 
                               );usrList.add(usr4);   
            
            Insert usrList;
            Account updateAcc = [select Id, Name,FBE_FPRM_Disti_Switch_Contact__c from Account where name=:'TestNewDistributorAccount01'];
            Account DMPAcc = [select Id,Name from Account where name in ('TestDMPAccount02')];
            
            List<Account_Affiliation__c> affList = new List<Account_Affiliation__c>();
            List<Account_Affiliation__c> updateAffList = new List<Account_Affiliation__c>();
            // Ready for Transfer
            Account_Affiliation__c resellerOldAffl= new Account_Affiliation__c(FBE_Account__c = conDist.AccountId,FBE_Affilitated_Account__c = conRes.AccountId,FBE_Relationship__c = 'Reseller',FBE_FPRM_Transfer_Status__c = 'Ready for Transfer');   
            Account_Affiliation__c resellerNewAffl= new Account_Affiliation__c(FBE_Account__c = conNewDist.AccountId,FBE_Affilitated_Account__c = conRes.AccountId,FBE_Relationship__c = 'Reseller',FBE_Start_Date__c = System.today());
            
            Account_Affiliation__c dmpOldAffl= new Account_Affiliation__c(FBE_Account__c = conDist.AccountId,FBE_Affilitated_Account__c = DMPAcc.Id,FBE_Relationship__c = 'Disty Managed',FBE_FPRM_Transfer_Status__c = 'Ready for Transfer', FBE_Start_Date__c = System.today()-10);   
            Account_Affiliation__c dmpNewAffl= new Account_Affiliation__c(FBE_Account__c = conNewDist.AccountId,FBE_Affilitated_Account__c = DMPAcc.Id,FBE_Relationship__c = 'Disty Managed',FBE_Start_Date__c = System.today());   
            
            affList.add(resellerOldAffl);affList.add(dmpOldAffl);affList.add(resellerNewAffl);affList.add(dmpNewAffl);
            
            // Initiate Manual Transfer
            Account_Affiliation__c resellerOldAfflManual= new Account_Affiliation__c(FBE_Account__c = conDist.AccountId,FBE_Affilitated_Account__c = conRes.AccountId,FBE_Relationship__c = 'Reseller',FBE_FPRM_Transfer_Status__c='Initiate Manual Transfer');   
            Account_Affiliation__c resellerNewAfflManual= new Account_Affiliation__c(FBE_Account__c = conNewDist.AccountId,FBE_Affilitated_Account__c = conRes.AccountId,FBE_Relationship__c = 'Reseller',FBE_Start_Date__c = System.today()); 
            
            Account_Affiliation__c dmpOldAfflManual= new Account_Affiliation__c(FBE_Account__c = conDist.AccountId,FBE_Affilitated_Account__c = DMPAcc.Id,FBE_Relationship__c = 'Disty Managed', FBE_FPRM_Transfer_Status__c='Initiate Manual Transfer',FBE_Start_Date__c= System.today()-10);   
            Account_Affiliation__c dmpNewAfflManual= new Account_Affiliation__c(FBE_Account__c = conNewDist.AccountId,FBE_Affilitated_Account__c = DMPAcc.Id,FBE_Relationship__c = 'Disty Managed',FBE_Start_Date__c = System.today());
            
            affList.add(resellerOldAfflManual);affList.add(dmpOldAfflManual);affList.add(resellerNewAfflManual);affList.add(dmpNewAfflManual);
            
            Insert affList;
            
        }// system.runas()
        
    }
    static testMethod void getDealData1()
    {
        Contact conDist = [Select Id,AccountId,Name,FBE_FPRM_Reseller_Account__c from Contact where Name = 'testDistributor Contact01'];
        Contact conDMP = [Select Id,AccountId,Name,FBE_FPRM_Reseller_Account__c from Contact where Name = 'testDMP Contact01'];
        
        Account DMPAcc = [select Id,Name from Account where name in ('TestDMPAccount02')];
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        //Create your product
        Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true
        );
        Test.startTest();
        insert prod;
        
        //Create the PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = prod.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        Insert pbe;
        
        Opportunity opp = new Opportunity(
            Name = 'Opportunit Test',
            AccountId = conDist.AccountId,
            StageName = 'Plan - 1%',
            FBE_Pursuit_Type__c = 'Indirect',
            FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover',
            CloseDate = System.today(),
            FBE_VAR_Seller__c = DMPAcc.Id,
            FBE_Distributor__c = conDist.AccountId,
            FBE_FSI_Not_Applicable__c = true,
            //FBE_Linked_DealReg__c = Deal.id,
            Pricebook2Id = standardPricebook.ID
        );
        Insert opp;
        
        Deal_Registration__c Deal = new Deal_Registration__c();
        User DistributorUser =[select Id, email,Name from User where name in ('ABC2 Dist')];
        system.runAs(DistributorUser)
        {
            Deal = FBE_UtilityFactory_Test.createDeal(1)[0];
            Deal.FBE_Deal_Justification_Statement__c = 'test statement';
            Deal.Name = 'test Dist'+ DistributorUser.Id;
            Deal.FBE_Deal_Product_Classification__c ='';
            Deal.FBE_Account__c = conDist.AccountId;
            //Deal.FBE_End_User_Account__c = conDist.AccountId;
            Deal.FBE_Distributor_Account__c = conDist.AccountId;
            // Deal.FBE_FSI_Account__c = lAcc[0].Id;
            Deal.FBE_Related_Opportunity__c = opp.Id;
            Deal.FBE_Book_Date__c = system.now().Date();
            Deal.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            deal.Sales_Stage__c = 'Plan - 1%';
            deal.FBE_Solution_Domain__c = 'Business Solutions';
            Deal.FBE_Deal_Registration_Status__c ='New';
            Deal.FBE_Same_as_submitter__c = 'Yes';
            Deal.FBE_Submission_Date__c = system.now();
            Deal.FBE_Fulfilment_Path__c ='Distribution';
            Deal.FBE_Deal_Submitter_Phone__c = '0987654321';
            Deal.FBE_Reseller_VAR_Account__c	= DMPAcc.Id;
            insert Deal;
        }
        
        Id resellerBatchJobId = null;                           
        try{
            // Ready for Transfer
            FBE_FPRM_DistyTransferBatch DMPbatch = new FBE_FPRM_DistyTransferBatch('Disty Managed',false,'Ready for Transfer');
            Database.executebatch(DMPbatch, 10);
            DMPbatch.Finish(null); 
            
            FBE_FPRM_DistyTransferBatch Resellerbatch = new FBE_FPRM_DistyTransferBatch('Reseller',false,'Ready for Transfer');
            Database.executebatch(Resellerbatch, 10);
            Resellerbatch.Finish(null);
            // Manual Transfer     
            FBE_FPRM_DistyTransferBatch DMPManual = new FBE_FPRM_DistyTransferBatch('Disty Managed',true,'Initiate Manual Transfer');
            Database.executebatch(DMPManual, 10);
            DMPManual.Finish(null); 
            
            FBE_FPRM_DistyTransferBatch ResellerManual = new FBE_FPRM_DistyTransferBatch('Reseller',true,'Initiate Manual Transfer');
            resellerBatchJobId = Database.executebatch(ResellerManual, 10);
            ResellerManual.Finish(null);
        }
        Catch(Exception e)
        {
            System.debug(e);
        }
        SchedulableContext ctx = null;
        FBE_FPRM_DistyTransferScheduler fbe = new FBE_FPRM_DistyTransferScheduler();
        fbe.execute(ctx);
        
        FBE_Configurator__c config = createConfig();
        config.Success_Opportunities__c ='1';
        config.Success_Deals__c ='1';
        config.Transfer_Status__c = 'Completed';
        insert config;
       
        Test.stopTest();
        AsyncApexJob job = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: resellerBatchJobId ];
        System.assertEquals('Completed', job.Status, 'Disty transfer batch did not run');
        
    }
    static testMethod void getDealData2()
    {
        Id dmpBatchId = null;
        try{
            // Ready for Transfer
            FBE_FPRM_DistyTransferBatch DMPbatch = new FBE_FPRM_DistyTransferBatch('Disty Managed',false,'Ready for Transfer');
            dmpBatchId = Database.executebatch(DMPbatch, 10);
            DMPbatch.Finish(null); 
            
            FBE_FPRM_DistyTransferBatch Resellerbatch = new FBE_FPRM_DistyTransferBatch('Reseller',false,'Ready for Transfer');
            Database.executebatch(Resellerbatch, 10);
            Resellerbatch.Finish(null);
            // Manual Transfer     
            FBE_FPRM_DistyTransferBatch DMPManual = new FBE_FPRM_DistyTransferBatch('Disty Managed',true,'Initiate Manual Transfer');
            Database.executebatch(DMPManual, 10);
            DMPManual.Finish(null); 
            
            FBE_FPRM_DistyTransferBatch ResellerManual = new FBE_FPRM_DistyTransferBatch('Reseller',true,'Initiate Manual Transfer');
            Database.executebatch(ResellerManual, 10);
            ResellerManual.Finish(null);
        }
        Catch(Exception e)
        {
            System.debug(e);
        }
        
        FBE_Configurator__c config = createConfig();
        config.Success_Opportunities__c ='0';
        config.Success_Deals__c ='0';
        config.Transfer_Status__c = 'Completed';
        Test.startTest();
        insert config;
        Test.stopTest();
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE ID =: dmpBatchId];
        System.assertEquals('Completed', job.Status, 'Disty transfer batch did not run');
        
    }
    static testMethod void getDealData3()
    {
        
        Account newDistAcc = [select Id,name from Account where name in ('TestNewDistributorAccount01')];  
        newDistAcc.FBE_FPRM_Disti_Switch_Contact__c = null;
        Test.startTest();
        update newDistAcc; 
        
        List<Account_Affiliation__c> affList = new List<Account_Affiliation__c>();
        List<Account_Affiliation__c> affiliationsListConfig = [select id,FBE_Affilitated_Account__c,FBE_Relationship__c,FBE_FPRM_Transfer_Status__c,FBE_Start_Date__c from Account_Affiliation__c where FBE_FPRM_Transfer_Status__c In('Initiate Manual Transfer','Ready For Transfer')];
        for(Account_Affiliation__c affls :affiliationsListConfig)
        {
            affls.FBE_FPRM_Transfer_Status__c = 'Configuration Error';
            affList.add(affls);
        }update affList;
        
        Id manualBatchId = null;
        try{
            // Ready for Transfer
            FBE_FPRM_DistyTransferBatch DMPbatch = new FBE_FPRM_DistyTransferBatch('Disty Managed',false,'Configuration Error');
            Database.executebatch(DMPbatch, 10);
            DMPbatch.Finish(null); 
            
            FBE_FPRM_DistyTransferBatch Resellerbatch = new FBE_FPRM_DistyTransferBatch('Reseller',false,'Configuration Error');
            Database.executebatch(Resellerbatch, 10);
            Resellerbatch.Finish(null);
            // Manual Transfer     
            FBE_FPRM_DistyTransferBatch DMPManual = new FBE_FPRM_DistyTransferBatch('Disty Managed',false,'Configuration Error');
            manualBatchId = Database.executebatch(DMPManual, 10);
            DMPManual.Finish(null); 
            
            FBE_FPRM_DistyTransferBatch ResellerManual = new FBE_FPRM_DistyTransferBatch('Reseller',false,'Configuration Error');
            Database.executebatch(ResellerManual, 10);
            ResellerManual.Finish(null);
        }
        Catch(Exception e)
        {
            System.debug(e);
        }
        SchedulableContext ctx = null;
        FBE_FPRM_DistyConfigAfflScheduler fbe = new FBE_FPRM_DistyConfigAfflScheduler();
        fbe.execute(ctx);
        
        FBE_Configurator__c config = createConfig();
        config.FBE_Error_Message__c = 'Test Error';
        config.Transfer_Status__c = 'Configuration Error';
        config.FBE_FPRM_Transfer_Comments__c ='test';
        config.FBE_Status__c = 'Error';
        insert config;
        Test.stopTest();
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE ID =: manualBatchId];
        System.assertEquals('Completed', job.Status, 'Disty transfer batch did not run');
        
    }
    static testMethod void getDealData4()
    {
        
        Contact conDist = [Select Id,AccountId,Name,FBE_FPRM_Reseller_Account__c from Contact where Name = 'testDistributor Contact01'];
        Contact conDMP = [Select Id,AccountId,Name,FBE_FPRM_Reseller_Account__c from Contact where Name = 'testDMP Contact01'];
        
        Account DMPAcc = [select Id,Name from Account where name in ('TestDMPAccount02')];
        
        Deal_Registration__c Deal = new Deal_Registration__c();
        User DistributorUser =[select Id, email,Name from User where name in ('ABC2 Dist')];
        system.runAs(DistributorUser)
        {
            Deal = FBE_UtilityFactory_Test.createDeal(1)[0];
            Deal.FBE_Deal_Justification_Statement__c = 'test statement';
            Deal.Name = 'test Dist'+ DistributorUser.Id;
            Deal.FBE_Deal_Product_Classification__c ='';
            Deal.FBE_Account__c = conDist.AccountId;
            //Deal.FBE_End_User_Account__c = conDist.AccountId;
            Deal.FBE_Distributor_Account__c = conDist.AccountId;
            // Deal.FBE_FSI_Account__c = lAcc[0].Id;
            //Deal.FBE_Related_Opportunity__c = opp.Id;
            Deal.FBE_Book_Date__c = system.now().Date();
            Deal.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            deal.Sales_Stage__c = 'Plan - 1%';
            deal.FBE_Solution_Domain__c = 'Business Solutions';
            Deal.FBE_Deal_Registration_Status__c ='New';
            Deal.FBE_Same_as_submitter__c = 'Yes';
            Deal.FBE_Submission_Date__c = system.now();
            Deal.FBE_Fulfilment_Path__c ='Distribution';
            Deal.FBE_Deal_Submitter_Phone__c = '0987654321';
            Deal.FBE_Reseller_VAR_Account__c	= DMPAcc.Id;
            //Deal.FBE_Related_Opportunity__c = opp.id;
            Test.startTest();
            insert Deal;
        }
        
        Id resellerBatchJobId = null;
        try{
            Deal.FBE_Book_Date__c = system.Today()-2;   
            update Deal;
            // Ready for Transfer
            FBE_FPRM_DistyTransferBatch DMPbatch = new FBE_FPRM_DistyTransferBatch('Disty Managed',false,'Ready for Transfer');
            Database.executebatch(DMPbatch, 10);
            DMPbatch.Finish(null); 
            
            FBE_FPRM_DistyTransferBatch Resellerbatch = new FBE_FPRM_DistyTransferBatch('Reseller',false,'Ready for Transfer');
            resellerBatchJobId = Database.executebatch(Resellerbatch, 10);
            Resellerbatch.Finish(null);
            // Manual Transfer     
            FBE_FPRM_DistyTransferBatch DMPManual = new FBE_FPRM_DistyTransferBatch('Disty Managed',true,'Initiate Manual Transfer');
            Database.executebatch(DMPManual, 10);
            DMPManual.Finish(null); 
            
            FBE_FPRM_DistyTransferBatch ResellerManual = new FBE_FPRM_DistyTransferBatch('Reseller',true,'Initiate Manual Transfer');
            Database.executebatch(ResellerManual, 10);
            ResellerManual.Finish(null);
        }
        Catch(Exception e)
        {
            System.debug(e);
        }
        FBE_Configurator__c config = createConfig();
        config.FBE_Error_Message__c = 'Test Error';
        config.Transfer_Status__c = 'Error';
        config.FBE_FPRM_Transfer_Comments__c ='test';
        config.FBE_Status__c = 'Error';
        config.Transfer_Status__c = 'Error';
        insert config;
        Test.stopTest();
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE ID =: resellerBatchJobId];
        System.assertEquals('Completed', job.Status, 'Disty transfer batch did not run');
        
    }
    public static FBE_Configurator__c createConfig()
    {
        Id configRecTypeId = Schema.getGlobalDescribe().get('FBE_Configurator__c').getDescribe().getRecordTypeInfosByName().get('Disty Transfer Logs').getRecordTypeId();  
        FBE_Configurator__c config = new FBE_Configurator__c();
        config.RecordTypeId = configRecTypeId;
        return config;
    }
    
}