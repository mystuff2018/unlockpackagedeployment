@isTest
public class FBE_OpportunityTriggerHandler_Test {
    static TestMethod void FBE_OpportunityTriggerHandler_NonAcceccedProfile() 
    {
        test.startTest();
        //List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List < User > lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('Federal Core Sales Group', 3, 'ab',null);
        lUsrNonIntegration[0].FBE_FPRM_OnlineRole__c ='Disti Managed Sales Rep My Opty';
        lUsrNonIntegration[1].FBE_FPRM_OnlineRole__c ='Disti Managed Sales Rep My Opty';
        lUsrNonIntegration[2].FBE_FPRM_OnlineRole__c ='Disti Managed Sales Rep My Opty';
        System.debug('lUsrNonIntegration==='+lUsrNonIntegration);
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
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel = 'Edit', UserId = lUsrNonIntegration[0].id, TeamMemberRole = 'SR', AccountId = lAcc[2].id));
            insert accTeamMemberList;
        }
        system.runAs(lUsrNonIntegration[0]) 
        {
            //Instantiate the Pricebook2 record with StandardPricebookId
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            
            //Execute an update DML on the Pricebook2 record, to make IsStandard to true
            Update standardPricebook;
            
            //Query for the Pricebook2 record, to check IsStandard field
            standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
            
            //Create your product
            Product2 prod = new Product2(
                Name = 'Product X',
                ProductCode = 'Pro-X',
                isActive = true
            );
            insert prod;
            
            //Create your pricebook entry
            List < PriceBookEntry > pbe = [Select id from PriceBookEntry where Product2Id =: prod.id and Pricebook2Id =: standardPricebook.id LIMIT 1];
            
            if (pbe.size() > 0) {
                pbe[0].UnitPrice = 10000000;
                pbe[0].IsActive = true;
            } else {
                PriceBookEntry pbeTmp = new PricebookEntry(
                    Pricebook2Id = standardPricebook.id,
                    Product2Id = prod.Id,
                    UnitPrice = 10000000,
                    isActive = true
                );
                pbe.add(pbeTmp);
            }
            upsert pbe;
            
            
            List<Opportunity> insOptyList = new List<Opportunity>();
            for(Integer i= 0 ; i<5 ; i++){
                Opportunity opty = new Opportunity();
                opty.Name = 'Opty Test'+i;
                opty.AccountId = lAcc[1].Id;
                opty.StageName = 'Plan - 1%';
                opty.FBE_Pursuit_Type__c = 'Indirect';
                opty.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
                opty.CloseDate = System.today();
                opty.FBE_Distributor__c = null;
                opty.FBE_VAR_Seller__c = null;
                opty.FBE_FSI_Account__c = null;
                opty.FBE_Reseller_VAR_Not_Applicable__c = true;
                opty.FBE_Distributor_Not_Applicable__c = true;
                opty.FBE_FSI_Not_Applicable__c = true;
                opty.FBE_Storage_Selling_Motion__c = 'Greenfield';

                if(i == 1) {
                    opty.FBE_FSI_Account__c = lAcc[0].Id;
                    opty.FBE_FSI_Not_Applicable__c = false;
                }
                if(i == 2) {
                    opty.FBE_Distributor__c = lAcc[2].Id;
                    opty.FBE_VAR_Seller__c = lAcc[1].Id;
                    opty.FBE_FSI_Account__c = lAcc[0].Id;
                    opty.FBE_Reseller_VAR_Not_Applicable__c = false;
                    opty.FBE_Distributor_Not_Applicable__c = false;
                    opty.FBE_FSI_Not_Applicable__c = false;
                }
                if(i == 3) {
                    opty.FBE_VAR_Seller__c = lAcc[1].Id;
                    opty.FBE_Reseller_VAR_Not_Applicable__c = false;
                }
                if(i == 4) {
                    opty.FBE_Distributor__c = lAcc[2].Id;
                    opty.FBE_Distributor_Not_Applicable__c = false;
                }
                insOptyList.add(opty);
            }
            
            INSERT insOptyList;    
            List<OpportunityLineItem> insLineItems = new List<OpportunityLineItem>();
            
            for(Integer i =0 ; i<5 ; i++){
                OpportunityLineItem opLi = new OpportunityLineItem();
                opLi.OpportunityId = insOptyList[i].Id;
                opLi.Quantity = 5;
                opLi.FBE_Quote_Number_Line__c = '123';
                opLi.PricebookEntryId = pbe[0].Id;
                opLi.TotalPrice = pbe[0].UnitPrice;
                insLineItems.add(opLi);
            }
            try{
                INSERT insLineItems;
            }   
            catch(Exception ex){
                system.debug('ex'+ex);
            }
            List<Opportunity> updList = new List<Opportunity>();
            for(Opportunity oppRec :[SELECT Id FROM Opportunity WHERE ID IN: insOptyList] ){
                System.debug('inside closing');
                Opportunity opty = new Opportunity();
                opty.Id = oppRec.Id;
                opty.StageName = 'Lost - 0%';
                opty.FBE_Win_Loss_Reason__c = SObjectType.Opportunity.Fields.FBE_Win_Loss_Reason__c.PicklistValues[0].getValue();
                opty.FBE_Win_Loss_Summary__c='test lost';
                updList.add(opty);
            }
            
            try  
            {
                
                update updList;
                
            }
            
            catch(Exception e)
                
            {
                
                String expectedExceptionThrown =  e.getMessage();
                
                System.AssertEquals(expectedExceptionThrown.contains('Only account team members of the Distributor Account or the Reseller Account can close or win an Indirect Opportunity'), true);
                
            } 
            
            test.stopTest();
            
        }
    }
    
    static testMethod void shareOpptywithPartnerUser(){
        test.startTest();
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List < User > lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('Federal Core Sales Group', 4, 'ab',null);
        lUsrNonIntegration[0].FBE_FPRM_OnlineRole__c ='Disti Managed Sales Rep My Opty';
        lUsrNonIntegration[1].FBE_FPRM_OnlineRole__c ='Disti Managed Sales Rep My Opty';
        lUsrNonIntegration[2].FBE_FPRM_OnlineRole__c ='Disti Managed Sales Rep My Opty';
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(3,null);
        lAcc[0].FBE_Partner_Type__c = 'System Integrator';
        lAcc[1].FBE_Partner_Type__c = 'Reseller';
        lAcc[2].FBE_Partner_Type__c = 'Distributor';
        system.runAs(lUsr) 
        {
            insert lAcc;
        }
        system.runAs(lUsrNonIntegration[0]) 
        {
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            
            //Execute an update DML on the Pricebook2 record, to make IsStandard to true
            Update standardPricebook;
            
            //Query for the Pricebook2 record, to check IsStandard field
            standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
            List<Opportunity> oppList = new List<Opportunity>();
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
                Pricebook2Id = standardPricebook.id,
                FBE_FPRM_Partner_Owner_Lookup__c = lUsrNonIntegration[0].Id,
                FBE_FPRM_Partner_Sales_Rep__c = lUsrNonIntegration[0].Id
                //FBE_Storage_Selling_Motion__c = 'Greenfield'
            );
            oppList.add(opp);
            Insert oppList;
            //FBE_OpportunityTriggerHandler.shareOpptyRecordWithPartnerUser(oppList, null);
            
            Opportunity updateOppty = new Opportunity(
                Id = oppList[0].Id,
                FBE_FPRM_Partner_Owner_Lookup__c = lUsrNonIntegration[1].Id,
                FBE_FPRM_Partner_Sales_Rep__c = lUsrNonIntegration[2].Id                
            );
            update updateOppty; 
            test.stopTest();
        } 
    }
    
}