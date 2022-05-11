@isTest
public class FBE_RoleBasedRestriction_Test {
    static TestMethod void FBE_RoleBasedRestrictionTestMethod() 
    {
        //List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List < User > lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('Federal Core Sales Group', 4, 'ab',null);
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(3,null);
        lAcc[0].FBE_Partner_Type__c = 'System Integrator';
        lAcc[1].FBE_Partner_Type__c = 'Reseller';
        lAcc[2].FBE_Partner_Type__c = 'Distributor';
        system.runAs(lUsr) 
        {
            //Create an Account
            
            insert lAcc;
            system.assertNotEquals(null, lAcc[0].id , 'Account not Found');
            
            
            
            
            list < AccountTeamMember > accTeamMemberList = new list < AccountTeamMember > ();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel = 'Edit', UserId = lUsrNonIntegration[0].id, TeamMemberRole = 'PROP_MGR', AccountId = lAcc[1].id));
            insert accTeamMemberList;
        }
        system.runAs(lUsrNonIntegration[0]) 
        {
/*****
Id pricebookId = Test.getStandardPricebookId();
            
            //Create your product
            Product2 prod = new Product2(
                Name = 'Product X',
                ProductCode = 'Pro-X',
                isActive = true
            );
            insert prod;
            
            //Create your pricebook entry
            List < PriceBookEntry > pbe = [Select id from PriceBookEntry where Product2Id =: prod.id and Pricebook2Id =: pricebookId LIMIT 1];
            
            if (pbe.size() > 0) {
                pbe[0].UnitPrice = 10000000;
                pbe[0].IsActive = true;
            } else {
                PriceBookEntry pbeTmp = new PricebookEntry(
                    Pricebook2Id = pricebookId,
                    Product2Id = prod.Id,
                    UnitPrice = 10000000,
                    isActive = true
                );
                pbe.add(pbeTmp);
            }
            upsert pbe;
            
 *****/           
            
    //Instantiate the Pricebook2 record with StandardPricebookId
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
            
            System.debug('inside profile user');
            //create Opportunity
            Opportunity opp = new Opportunity(
                Name = 'Opportunité Test',
                AccountId = lAcc[1].Id,
                StageName = 'Plan - 1%',
                FBE_Pursuit_Type__c = 'Indirect',
                FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover',
                CloseDate = System.today(),
                FBE_FSI_Account__c = lAcc[0].Id,
                FBE_VAR_Seller__c = lAcc[1].Id,
                FBE_Distributor__c = lAcc[2].Id,
                Pricebook2Id = standardPricebook.id
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
            
            List < Opportunity > opr = new List < Opportunity > ();
            opp.StageName = 'Lost - 0%';
            opp.FBE_Win_Loss_Reason__c = 'Relationship';
            opp.FBE_Win_Loss_Summary__c='test lost';
            //opp.FBE_Distributor__c = null;
            //opp.FBE_Distributor_Not_Applicable__c = true;
            opr.add(opp);
            update opr;
            
            
            //------------------------------
            
            List<Opportunity> insOptyList = new List<Opportunity>();
                Opportunity opty = new Opportunity();
                opty.Name = 'Opty Test';
                opty.AccountId = lAcc[1].Id;
                opty.StageName = 'Plan - 1%';
                opty.FBE_Pursuit_Type__c = 'Indirect';
                opty.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
                opty.CloseDate = System.today();
                //opp.FBE_FSI_Account__c = lAcc[0].Id;
                //opp.FBE_VAR_Seller__c = lAcc[1].Id;
                //opp.FBE_Distributor__c = lAcc[2].Id;
                opty.Pricebook2Id = standardPricebook.id;
                
              
                    opty.FBE_Distributor__c = lAcc[2].Id;
                    opty.FBE_FSI_Not_Applicable__c = true;
                    opty.FBE_Reseller_VAR_Not_Applicable__c = true;
               
                
                
                insOptyList.add(opty);
            
                Insert insOptyList;
                
                Task t = new Task();
                string taskRecordType = System.Label.Task_Support_Request_record_type;
                t.RecordTypeId = FBE_Utility.getSupportReqrecTypeId(taskRecordType);
                t.FBE_End_Date_del__c = System.Today();
                t.Description = 'TestTask1';
                t.Status = 'Draft';
                t.Type = 'Proposal';
                t.OwnerId = lUsrNonIntegration[0].Id;
                t.WhatId = insOptyList[0].id;
                t.ActivityDate = System.Today();
                Insert t;
                t.FBE_Total_Contract_Value__c = 99999;
                Update t;
        }    

    
}
}