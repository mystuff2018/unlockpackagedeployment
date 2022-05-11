/****************************************************************************************************
* Author         : Dell Team - CPQ [Ravi Sirigiri - STORY 11263048, Sireesha Myla - Story 11648153]
* Description    : Created the class for the purpose of Code Coverage on FBE_CPQ_OptyRelatedListController class. 
* Date Created   : 03-Nov-2021
* Version        : 1.0
* Modification Log           Developer          Last Modified Date           Description
*  1.0                        Ravi Sirigiri      03-Nov-2021
*                           Ravi Sirigiri      12-Dec-2021          StoryNo:11263071
*                           Myla Sireesha      12-Dec-2021          StoryNo:11648153
							Myla Sireesha      18-Mar-2022          StoryNo:12079756
							
****************************************************************************************************/

@isTest
public class FBE_CPQ_OptyRelatedListController_Test {
    
    @testSetup static void setup()
    { 
        list<User> uList = [SELECT Id FROM User WHERE FBE_Integration_User__c=true LIMIT 1];
        Profile adminProfile = [Select Id,Name from profile where Name='System Administrator' limit 1];
        List<FBE_FPRM_Transfer_Deal_Check__c>customSettingList = new List<FBE_FPRM_Transfer_Deal_Check__c>();
        
        FBE_FPRM_Transfer_Deal_Check__c test = new FBE_FPRM_Transfer_Deal_Check__c(
            SetupOwnerId = adminProfile.Id, Name = 'Test',Is_Transfer_Deal__c = true); 
        customSettingList.add(test); 
        
        FBE_FPRM_Transfer_Deal_Check__c settings = FBE_FPRM_Transfer_Deal_Check__c.getOrgDefaults();
        settings.Is_Transfer_Deal__c = false;
        customSettingList.add(settings); 
        
        FBE_FPRM_Notification_Switch__c disty = new FBE_FPRM_Notification_Switch__c(FBE_FPRM_Enable_Disty_Transfer__c = true);
        insert disty;
        
        UPSERT customSettingList;
        system.runAs(uList[0])
        {
            List < Account > lAcc = FBE_Test_utility.createAccount(3);
            lAcc[0].FBE_Partner_Type__c = 'Distributor';
            lAcc[1].FBE_Partner_Type__c = 'Reseller';
            //lAcc[2].FBE_Partner_Type__c = 'Disty Managed';
            insert lAcc;
            system.assertNotEquals(null, lAcc[0]?.id,'Null check');
            
            List<Contact> lCon = FBE_Test_utility.createContact(2,lAcc[0].Id);
            lCon[0].Email = 'test@testnew.com';
            lCon[1].AccountId = lAcc[1].Id;
            lCon[1].Email = 'test@testnewres.com';
            insert lCon;
           /* Contact c3 = new Contact();
            c3.Lastname ='DMP user';
            c3.FirstName = 'test';
            c3.Email = 'test@testnewdmp.com';
            c3.AccountId = lAcc[0].Id;
            c3.FBE_FPRM_Reseller_Account__c = lAcc[2].Id;
            c3.Phone = '9874678378';
            insert c3;*/

            Profile DistProfile = [Select Id from profile where Name='FBE FPRM Partner Distributor'];
            Profile ResellerProfile = [Select Id from profile where Name='FBE FPRM Partner Reseller'];
            //Profile DMPProfile = [Select Id from profile where Name='FBE FPRM Partner Disty Managed'];
            
            //Create unique username 
            String orgId=UserInfo.getOrganizationId(); 
            String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');    
            Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
            String uniqueName=orgId+dateString+RandomId; 
            //Create users
            List<User>usrList = new List<User>();
            
            User usr1 =new User(firstname = 'ABC2', 
                                lastName = 'DistyContact', 
                                email = 'test@testnew.com', 
                                Username = uniqueName + '@test5' + orgId + '.org'+'.fprm', 
                                EmailEncodingKey = 'ISO-8859-1', 
                                Alias = uniqueName.substring(18, 23), 
                                TimeZoneSidKey = 'America/Los_Angeles', 
                                LocaleSidKey = 'en_US', 
                                LanguageLocaleKey = 'en_US', 
                                ProfileId = DistProfile.Id,
                                ContactId = lCon[0].Id,
                                IsActive = true,
                                FBE_FPRM_OnlineRole__c = 'Site Admin' 
                               );  usrList.add(usr1); 
            User usr2 =new User(firstname = 'ABC2', 
                                lastName = 'Reseller', 
                                email = 'test@testnewres.com', 
                                Username = uniqueName + '@test3' + orgId + '.org'+'.fprm', 
                                EmailEncodingKey = 'ISO-8859-1', 
                                Alias = uniqueName.substring(18, 23), 
                                TimeZoneSidKey = 'America/Los_Angeles', 
                                LocaleSidKey = 'en_US', 
                                LanguageLocaleKey = 'en_US', 
                                ProfileId = ResellerProfile.Id,
                                ContactId = lCon[1].Id,
                                IsActive = true,
                                FBE_FPRM_OnlineRole__c = 'Site Admin' 
                               );  usrList.add(usr2); 
            
            Insert usrList;
            List < Opportunity > opp = FBE_UtilityFactory_Test.createOpportunity(2, lAcc[0]?.id,null,null,null,null,null);
            opp[0].FBE_Distributor__c = lAcc[0].Id;
            opp[0].FBE_VAR_Seller__c = lAcc[1].Id ; 
            opp[1].AccountId = lAcc[1].Id;
            insert opp; 
            
            
            Deal_Registration__c Deal = FBE_UtilityFactory_Test.createDeal(1)[0];
            Deal.FBE_Deal_Justification_Statement__c = 'test statement';
            Deal.Name = 'test Dist';
            Deal.FBE_Deal_Product_Classification__c ='';
            Deal.FBE_Account__c = lAcc[0].Id;
            //Deal.FBE_End_User_Account__c = conDist.AccountId;
            Deal.FBE_Distributor_Account__c = lAcc[0].Id;
            // Deal.FBE_FSI_Account__c = lAcc[0].Id;
            Deal.FBE_Related_Opportunity__c = opp[0].Id;
            Deal.FBE_Book_Date__c = system.now().Date();
            Deal.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            deal.Sales_Stage__c = 'Plan - 1%';
            deal.FBE_Solution_Domain__c = 'Business Solutions';
            Deal.FBE_Deal_Registration_Status__c ='New';
            Deal.FBE_Same_as_submitter__c = 'Yes';
            Deal.FBE_Submission_Date__c = system.now();
            Deal.FBE_Fulfilment_Path__c ='Direct Fulfillment';
            Deal.FBE_Deal_Submitter_Phone__c = '0987654321';
            Deal.FBE_Reseller_VAR_Account__c	= lAcc[1].Id;
            insert Deal;
            
            List<Quote> quoteList = new List<Quote>();
            Quote qot=new Quote(Name='test',OpportunityId=opp[0]?.id);
            quoteList.add(qot);
            
            Quote qot1=new Quote(Name='Test reseller',OpportunityId=opp[1]?.id);
            quoteList.add(qot1);
            insert quoteList;
            
            ContentVersion cvPdf = new ContentVersion(
                Title          = 'a pdf',
                PathOnClient   = 'Picpdf.pdf',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true, FirstPublishLocationId = qot.id);
            insert cvPdf;  
            ContentVersion cvHTMl = new ContentVersion(
                Title          = 'b html',
                PathOnClient   = 'Pichtml.html',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true, FirstPublishLocationId = qot.id);
            insert cvHTMl; 
            ContentVersion cvExl = new ContentVersion(
                Title          = 'c excel_x',
                PathOnClient   = 'Picexcel_x.excel_x',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true, FirstPublishLocationId = qot.id);
            insert cvExl;  
            ContentVersion cvXml = new ContentVersion(
                Title          = 'd xml',
                PathOnClient   = 'Picxml.xml',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true, FirstPublishLocationId = qot.id);
            insert cvXml; 
            
            List<Contract> contractList = new List<Contract>();
            Contract ctr1 = new Contract();
            ctr1.Name = 'Test1';
            ctr1.Status = 'Active';
            ctr1.AccountId = lAcc[0]?.id;
            ctr1.FBE_CPQ_Contract_Code__c = '276Tsd';
            ctr1.FBE_CPQ_Contract_Code_with_AccountId__c = ctr1.FBE_CPQ_Contract_Code__c + ctr1.AccountId;
            contractList.add(ctr1); 
            Contract ctr2 = new Contract();
            ctr2.Name = 'Test2';
            ctr2.Status = 'Active';
            ctr2.AccountId = lAcc[1]?.id;
            ctr2.FBE_CPQ_Contract_Code__c = '2745Ttd';
            ctr2.FBE_CPQ_Contract_Code_with_AccountId__c = ctr2.FBE_CPQ_Contract_Code__c + ctr2.AccountId;
            contractList.add(ctr2); 
            Contract ctr3 = new Contract();
            ctr3.Name = 'Test3 distributor';
            ctr3.Status = 'Active';
            ctr3.AccountId = lAcc[0]?.id;
            ctr3.FBE_CPQ_Contract_Code__c = '2745Ttd';
            ctr3.FBE_CPQ_Contract_Type__c = 'Distributor';
            ctr3.FBE_CPQ_Contract_Code_with_AccountId__c = ctr3.FBE_CPQ_Contract_Code__c + ctr3.AccountId;
            contractList.add(ctr3); 
            
            insert contractList;
        }
    }    
    static testMethod void testDistMethod() 
    {
        Test.startTest();
        User distUser =[select Id, email,Name from User where name in ('ABC2 DistyContact')];
        List<Quote> quoteList = [SELECT Id, OpportunityId FROM Quote LIMIT 1];
        Quote quoteRec = quoteList.isEmpty() ? new Quote() : quoteList[0];
        
        system.runAs(distUser)
        {
            
            //FBE_CPQ_OptyRelatedListController.getQuoteData(quoteRec.OpportunityId);
            system.assertNotEquals(null, FBE_CPQ_OptyRelatedListController.getQuoteData(quoteRec.OpportunityId));
            system.assertNotEquals(null, FBE_CPQ_OptyRelatedListController.getQuoteFilesData(quoteRec.Id));
        }
        system.assertNotEquals(null, FBE_CPQ_OptyRelatedListController.getQuoteData(quoteRec.OpportunityId));
        system.assertNotEquals(null, FBE_CPQ_OptyRelatedListController.getQuoteFilesData(quoteRec.Id));
        Test.stopTest();
        
        
    }
    
    static testMethod void testMethod1() 
    {
        Test.startTest();
            List<Quote> quoteList = [SELECT Id, OpportunityId FROM Quote LIMIT 1];
            Quote quoteRec = quoteList.isEmpty() ? new Quote() : quoteList[0];
            List<String> fileTypes = new List<String>{'xml','excel_x','excel','html','pdf','xlx'};
                for(String fileType : fileTypes)
            {
                FBE_CPQ_OptyRelatedListController.getFileType(fileType);       
            }
           
            //FBE_CPQ_OptyRelatedListController.getQuoteData(quoteRec.OpportunityId);
            system.assertNotEquals(null, FBE_CPQ_OptyRelatedListController.getQuoteData(quoteRec.OpportunityId));
            //FBE_CPQ_OptyRelatedListController.getQuoteFilesData(quoteRec.Id);
            system.assertNotEquals(null, FBE_CPQ_OptyRelatedListController.getQuoteFilesData(quoteRec.Id));
        Test.stopTest();
    }
    static testMethod void testMethod2()  // Added by Sireesha Myla[STORY 12079756] - Code Coverage for Apex : FBE_CPQ_ContractHandler
    {
        Test.startTest();
           User distUser =[select Id, email,Name from User where name in ('ABC2 DistyContact')];
        
            List<Opportunity> oppList = [SELECT Id from Opportunity limit 1];
            Opportunity optyRec = oppList.isEmpty() ? new Opportunity() : oppList[0];
            List<Contract> contractList = [SELECT Id from Contract limit 2];
       	    Contract contractRec = contractList.isEmpty() ? new Contract() : contractList[0];
        
            system.runAs(distUser)
            {
                system.assertNotEquals(null, FBE_CPQ_ContractHandler.getContracts(optyRec.Id));
    
                system.assertNotEquals(null, FBE_CPQ_ContractHandler.saveOpportunity(optyRec.Id,contractRec.Id));
            }
			User resellerUser =[select Id, email,Name from User where name in ('ABC2 Reseller')];            
        	 system.runAs(resellerUser)
            {
                system.assertNotEquals(null, FBE_CPQ_ContractHandler.getContracts(optyRec.Id));
    
                system.assertNotEquals(null, FBE_CPQ_ContractHandler.saveOpportunity(optyRec.Id,contractRec.Id));
            }
        Test.stopTest();
    }
   
}