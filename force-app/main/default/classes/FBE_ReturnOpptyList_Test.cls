@isTest
Private class FBE_ReturnOpptyList_Test {

     static testmethod void setup() {
      
        List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        List < User > lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 4, 'ab',null);
        List<Lead> insLeadList = new List<Lead>();
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(2,null);
        for(Integer i=0 ;i <lAcc.size() ; i++){
            lAcc[i].name = 'SFDC Test Account'+i;
        }
        system.runAs(lUsr[0]) {
            //Create an Account
            
            insert lAcc;
            system.assertNotEquals(null, lAcc[0].id, 'Account Record not found');
            system.assertNotEquals(null, lAcc[1].id, 'Account Record not found');
            
            
            List < Campaign > campaignList = FBE_UtilityFactory_Test.createCampaign(1);
            insert campaignList;
            System.assertEquals(1, campaignList.size());
            for(Integer i=0 ;i<=1 ;i ++){
                Lead leadRecord = new Lead();
                leadRecord.Company = 'Company_Test'+i;
                leadRecord.FirstName = 'Lead Fname'+i;
                leadRecord.LastName = 'Lead LName'+i;
                leadRecord.FBE_Lead_Type__c = 'Inbound';
                leadRecord.Email = 'testleadabc@abc.com';
                leadRecord.Phone = '1232789';
                leadRecord.FBE_Sales_Role__c = 'SR';
                leadRecord.FBE_Campaign__c = campaignList[0].Id;
                leadRecord.FBE_Account_Name__c = lAcc[0].id;
                leadRecord.FBE_End_User_Account__c = lAcc[1].id;
                //leadRecord.FBE_End_User__c = lAcc[1].id;
                leadRecord.ownerid = lUsrNonIntegration[0].id;
                leadRecord.Opportunity_Product_Classification__c = 'Dell Products';
                leadRecord.LeadSource = 'Email';
                leadRecord.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
                leadRecord.FBE_Lead_Type__c ='Inbound';
                insLeadList.add(leadRecord);
            }
            insert insLeadList;
        
                  
            
             Set<string> storeAccId = new Set<string>();
            storeAccId.add(insLeadList[0].FBE_End_User_Account__c);
            system.debug('Lead End User #####'+insLeadList[0].FBE_End_User_Account__c);
             List<Product2> lstproducts = FBE_Test_Utility.createProducts(10);
             lstproducts[0].Name = 'Apos';
             lstproducts[1].Name = 'SonicWALL';
             lstproducts[2].Name = 'VMWare';
             lstproducts[3].Name = 'Nutanix';
             lstproducts[4].Name = 'Nutanix';
            insert lstproducts;

       
                Pricebook2 standardPricebook = new Pricebook2(
                 Id = Test.getStandardPricebookId(),
                 IsActive = true
                );
              
                //Execute an update DML on the Pricebook2 record, to make IsStandard to true
                Update standardPricebook;
              
                 //Query for the Pricebook2 record, to check IsStandard field
                standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
                //It should return true
                System.assertEquals(true, standardPricebook.IsStandard);
              
               //Create the PricebookEntry
                PricebookEntry pbe = new PricebookEntry(
                 Pricebook2Id = standardPricebook.Id,
                 Product2Id = lstproducts[0].Id,
                 UnitPrice = 1020,
                 IsActive = true
                );
                Insert pbe;
    Id StandardRecTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Standard Opportunity').RecordTypeId;
            Opportunity opp = new Opportunity(
                Name = 'Opportunit Test',
                AccountId = lAcc[0].Id,
                StageName = 'Plan - 1%',
                FBE_Pursuit_Type__c = 'Indirect',
                FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover',
                CloseDate = System.today(),
                FBE_FSI_Account__c = lAcc[1].Id,
                FBE_VAR_Seller__c = lAcc[0].Id,
                FBE_Distributor__c = lAcc[0].Id,
                FBE_End_User__c = insLeadList[0].FBE_End_User_Account__c,
                Pricebook2Id = standardPricebook.ID,
                RecordtypeId = StandardRecTypeId
            );
            Insert opp;
                  
           
            //create your opportunity line item.  This assumes you already have an opportunity created, called opp
            OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Quantity = 5,
                FBE_Quote_Number_Line__c = '123',
                PricebookEntryId = pbe.Id,
                TotalPrice = pbe.UnitPrice
            );
            insert oli;
            
        
          Test.startTest();
            FBE_ReturnOpptyList.getOpptyList(insLeadList[0].Id);
            FBE_ReturnOpptyList.getRelatedOppty(insLeadList[0].FBE_End_User_Account__c);
            FBE_ReturnOpptyList.getSearchedOppty(insLeadList[0].FBE_End_User_Account__c, 'testString');
            
            List<Lead> insLeadList1 = new List<Lead>(); 
                Lead leadRecord1 = new Lead();
                leadRecord1.Company = 'Company_Test';
                leadRecord1.FirstName = 'Lead Fname';
                leadRecord1.LastName = 'Lead LName';
                leadRecord1.FBE_Lead_Type__c = 'Inbound';
                leadRecord1.Email = 'testleadabc@abc.com';
                leadRecord1.Phone = '1232789';
                leadRecord1.FBE_Sales_Role__c = 'SR';
                leadRecord1.FBE_Campaign__c = campaignList[0].Id;
                leadRecord1.FBE_Account_Name__c = lAcc[0].id;
                leadRecord1.ownerid = lUsrNonIntegration[0].id;
                leadRecord1.Opportunity_Product_Classification__c = 'Dell Products';
                leadRecord1.LeadSource = 'Email';
                leadRecord1.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
                leadRecord1.FBE_Lead_Type__c ='Inbound';
                insLeadList1.add(leadRecord1);
                        
            Insert insLeadList1;  
            FBE_ReturnOpptyList.getOpptyList(insLeadList1[0].Id);
             
         Test.stopTest();
         
     } 
       
    }
      
            
}