/*
*@ Class Name     : FBE_FPRM_Deal_Transfer_ControllerTest
*@ Description      : Test class of FBE_FPRM_Deal_Transfer_Controller class.
*@ CreatedBy        : Deloitte Consulting
*@ CreatedOn        : 22-Mar-2021 [Uttam Kavitkar]
*@ Modification Log :                     
*/
@isTest
public class FBE_FPRM_Deal_Transfer_ControllerTest {

    //setup data for test cases
    @testSetup static void setup() {
        User usr = [Select Id from user where Userrole.Name  = 'Integration Role'];
        Profile adminProfile = [Select Id,Name from profile where Name='System Administrator' limit 1];
        FBE_FPRM_Transfer_Deal_Check__c test = new FBE_FPRM_Transfer_Deal_Check__c(
                                      SetupOwnerId = adminProfile.Id, Name = 'Test',Is_Transfer_Deal__c = false); 
		insert test;
        
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
            c.Phone = '5122368000';
            c.RecordTypeId = recordTypeIdContact; 
            insert c;
            
            Contact c2 = new Contact();
            c2.AccountId = acc2.Id;
            c2.FirstName = 'testDMP';
            c2.LastName = 'Contact01';
            c2.email = 'test@test02.com';
            c2.Phone = '5122368000';
            c2.RecordTypeId = recordTypeIdContact;
            c2.FBE_FPRM_Reseller_Account__c = acc2.Id;
            insert c2;
            
        } 
        
    }
    
    static testMethod void getUserData(){
        
        //Get the contact created in setup method
        Contact con2 = [Select Id,Name,FBE_FPRM_Reseller_Account__c from Contact where Name = 'testDMP Contact01'];
        
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
        
       Test.startTest();
        
       		List<sobject> conList = FBE_FPRM_Deal_Transfer_Controller.findUserRecords('ABC2', 'User');
       Test.stopTest();
       System.assertEquals(true, conList.size() > 0, 'contact was not returned');
        
    }
    
    static testmethod void getDealsData()
    { 
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
                    insert prod;
        
        //Create the PricebookEntry
                PricebookEntry pbe = new PricebookEntry(
                 Pricebook2Id = standardPricebook.Id,
                 Product2Id = prod.Id,
                 UnitPrice = 1020,
                 IsActive = true
                );
                Insert pbe;
        
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List<ID> usId = new List<Id>();
        List < User > lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 4, 'ab',null);
        
        for(user us : lUsrNonIntegration){
            usId.add(us.Id);
        }
        
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(3,null);
        system.runAs(lUsr){
            lAcc[0].FBE_AE_ISR__c = lUsr.Id;
            lAcc[0].FBE_Partner_Type__c = 'Distributor';
            lAcc[1].FBE_Partner_Type__c ='System Integrator';
            
            insert lAcc;
            List < Account > accnt = [select id from account];
            System.debug('inside profile user');
            
            //Create contact
            List<Contact> lstContact = FBE_UtilityFactory_Test.createContact(1,lAcc[0].Id);
            lstContact[0].email = 'test@test.com';
            insert lstContact;
            
           
            //create Opportunity
            Opportunity opp = new Opportunity(
                Name = 'Opportunit Test',
                AccountId = accnt[0].Id,
                StageName = 'Plan - 1%',
                FBE_Pursuit_Type__c = 'Indirect',
                FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover',
                CloseDate = System.today(),
                FBE_FSI_Account__c = lAcc[1].Id,
                FBE_VAR_Seller__c = lAcc[0].Id,
                FBE_Distributor__c = lAcc[0].Id,
                Pricebook2Id = standardPricebook.ID
            );
            Insert opp;
            //create your opportunity line item.  This assumes you already have an opportunity created, called opp
           Test.startTest();  
            OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Quantity = 5,
                FBE_Quote_Number_Line__c = '123',
                PricebookEntryId = pbe.Id,
                TotalPrice = pbe.UnitPrice
            );
            insert oli;
            
            List < Opportunity > opr = new List < Opportunity > ();
            opp.StageName = 'Plan - 1%';
            opr.add(opp);
            
            update opr;
            Deal_Registration__c Deal = FBE_UtilityFactory_Test.createDeal(1)[0];
            Deal.FBE_Deal_Justification_Statement__c = 'test statement';
            Deal.Name = 'test 1234';
            Deal.FBE_Account__c = accnt[0].Id;
            Deal.FBE_End_User_Account__c = lAcc[0].Id;
            Deal.FBE_Distributor_Account__c = lAcc[0].Id;
            Deal.FBE_Related_Opportunity__c = opp.Id;
            Deal.FBE_Price_Book_Id__c = standardPricebook.ID;
            Deal.FBE_Book_Date__c = system.now().Date();
            Deal.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            deal.Sales_Stage__c = 'Plan - 1%';
            deal.FBE_Solution_Domain__c = 'Business Solutions';
            Deal.FBE_Deal_Product_Classification__c = 'EMC Products';
            Deal.FBE_Deal_Registration_Status__c ='New';
            Deal.FBE_Submission_Date__c = system.now();
            Deal.FBE_Partner_Owner_Email__c = 'test@test.com';
            Deal.FBE_Deal_Submitter_Email_Phone__c = 'test@test.com';
            Deal.FBE_Partner_Sales_Rep_Email__c  = 'test@test.com';
            insert Deal;
        }      
             
            List<Deal_Registration__c> deals = [Select Id,FBE_Deal_Reg_Num__c from Deal_Registration__c where FBE_Deal_Registration_Status__c = 'New'];
            List<Opportunity> opptyList = FBE_FPRM_Deal_Transfer_Controller.getDealRegs('test@test.com','test@test.com',deals[0].FBE_Deal_Reg_Num__c,'New','test@test.com');
        Test.stopTest();
        System.assertEquals(true, opptyList.size() > 0, 'Opportunity is null');
    }
    
}