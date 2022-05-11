@isTest
public class FBE_FPRM_Deal_Exp_Notif_Partner_Test {
    
    @testSetup
    static void testDataSetup(){
        Product2 prod = new Product2(
            Name = 'APOS',
            ProductCode = 'Pro-X',
            isActive = true
        );
        insert prod;
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();        
        
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
      
        List < PriceBookEntry > pbe = [Select id from PriceBookEntry where Product2Id =: prod.id and Pricebook2Id =: standardPricebook.id LIMIT 1];
        
        if (pbe.size() > 0) {
            pbe[0].UnitPrice = 99;
            pbe[0].IsActive = true;
        } else {
            PriceBookEntry pbeTmp = new PricebookEntry(
                Pricebook2Id = standardPricebook.id,
                Product2Id = prod.Id,
                UnitPrice = 500,
                isActive = true
            );
            pbe.add(pbeTmp);
        }
        upsert pbe;
                
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(5,null);
        lAcc[0].FBE_Partner_Type__c = 'Distributor';
        lAcc[1].FBE_Partner_Type__c = 'Reseller';
        lAcc[2].FBE_Partner_Type__c = 'System Integrator';
        lAcc[3].FBE_Partner_Type__c = 'Disty Managed';
        lAcc[4].FBE_Partner_Type__c = 'OEM';
        system.runAs(lUsr){
            lAcc[0].FBE_AE_ISR__c = lUsr.Id;
            insert lAcc;
            
            List < Account > accnt = [select id from account WHERE ID =:lAcc[0].Id ];
            System.debug('inside profile user');
            //create Opportunity
            AccountTeamMember mem = new AccountTeamMember(
                AccountId=lAcc[0].Id, TeamMemberRole='AE', UserId=lUsr.Id
            );
            insert mem;
            insert new FBE_FPRM_Notification_Switch__c(Send_Deal_Extn_Exp_Notification__c = true, Send_Deal_Extn_Exp_0_Notification__c = true,Send_Deal_Extn_Exp_10_Notification__c= true, Send_Deal_Extn_Exp_30_Notification__c = true, FBE_FPRM_Cut_Over_Switch__c = true);
            
            Opportunity opp = new Opportunity(
                Name = 'Opportunit Test',
                AccountId = accnt[0].Id,
                StageName = 'Plan - 1%',
                FBE_Pursuit_Type__c = 'Indirect',
                FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover',
                CloseDate = System.today(),
                FBE_FSI_Account__c = accnt[0].Id,
                FBE_VAR_Seller__c = accnt[0].Id,
                FBE_Distributor__c = accnt[0].Id,
                Pricebook2Id = standardPricebook.id
            );
            Insert opp;
            
            //create your opportunity line item.  This assumes you already have an opportunity created, called opp
            OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Quantity = 5,
                FBE_Quote_Number_Line__c = '123',
                PricebookEntryId = pbe[0].Id,
                TotalPrice = pbe[0].UnitPrice
            );
            insert oli;
            
            List < Opportunity > opr = new List < Opportunity > ();
            opp.StageName = 'Lost - 0%';
            opp.FBE_Win_Loss_Reason__c = 'Relationship';
            opp.FBE_Win_Loss_Summary__c = 'Opp Lost';
            opr.add(opp);
            DmlException expectedException;
            try{
                update opr;
            }catch (DmlException dmx){
                expectedException = dmx;
                system.debug(expectedException);
            }
            FBE_Test_Utility.createTransferDealCheckCustomSetting(false); 
            List<Deal_Registration__c> insertDealList = new List<Deal_Registration__c>();
            List<Deal_Registration__c> updateDealList = new List<Deal_Registration__c>();
            List<Deal_Registration__c> updateDealList2 = new List<Deal_Registration__c>();
            
            List<Deal_Registration__c> Deal = FBE_UtilityFactory_Test.createDeal(3);
            Deal[0].FBE_Deal_Justification_Statement__c = 'test statement';
            Deal[0].Name = 'test 1234';
            Deal[0].FBE_Account__c = accnt[0].Id;
            Deal[0].FBE_End_User_Account__c = lAcc[0].Id;
            Deal[0].FBE_Distributor_Account__c = lAcc[0].Id;
            Deal[0].FBE_Reseller_VAR_Account__c = lAcc[1].id;
            Deal[0].FBE_FSI_Account__c = lAcc[2].id;
            Deal[0].FBE_Related_Opportunity__c = opp.Id;
            Deal[0].FBE_Price_Book_Id__c = standardPricebook.id;
            Deal[0].FBE_Submission_Date__c = system.now();
            Deal[0].FBE_Book_Date__c = system.now().date();
            Deal[0].FBE_Deal_Product_Classification__c = 'EMC Products';
            //Deal[0].FBE_AE_ManagerID__c = lUsr[0].ManagerID;
            Deal[0].FBE_Deal_Registration_Status__c ='New';
            Deal[0].FBE_Partner_Sales_Rep_Email__c = 'test@test.com';
            Deal[0].FBE_Partner_Team_Mailbox__c = 'ab@nc.com';
            insertDealList.add(Deal[0]);
            
            //10 Days Expiration
            Deal[1].FBE_Deal_Justification_Statement__c = 'test statement';
            Deal[1].Name = 'test 12345';
            Deal[1].FBE_Account__c = accnt[0].Id;
            Deal[1].FBE_End_User_Account__c = lAcc[0].Id;
            Deal[1].FBE_Distributor_Account__c = lAcc[0].Id;
            Deal[1].FBE_Reseller_VAR_Account__c = lAcc[1].id;
            Deal[1].FBE_Partner_Sales_Rep_Email__c = 'test@test.com';
            Deal[1].FBE_Partner_Team_Mailbox__c = 'ab@nc.com';
            Deal[1].FBE_FSI_Account__c = lAcc[2].id;
            Deal[1].FBE_Related_Opportunity__c = opp.Id;
            Deal[1].FBE_Price_Book_Id__c = standardPricebook.id;
            Deal[1].FBE_Submission_Date__c = system.now();
            Deal[1].FBE_Book_Date__c = system.now().date();
            Deal[1].FBE_Deal_Product_Classification__c = 'EMC Products';
            //Deal[1].FBE_AE_ManagerID__c = lUsr[0].ManagerID;
            Deal[1].FBE_Deal_Registration_Status__c ='New';
            insertDealList.add(Deal[1]);            
            
            //30 Days Expiration
            Deal[2].FBE_Deal_Justification_Statement__c = 'test statement';
            Deal[2].Name = 'test 123456';
            Deal[2].FBE_Account__c = accnt[0].Id;
            Deal[2].FBE_End_User_Account__c = lAcc[0].Id;
            Deal[2].FBE_Distributor_Account__c = lAcc[0].Id;
            Deal[2].FBE_Reseller_VAR_Account__c = lAcc[1].id;
            Deal[2].FBE_FSI_Account__c = lAcc[2].id;
            Deal[2].FBE_Related_Opportunity__c = opp.Id;
            Deal[2].FBE_Partner_Sales_Rep_Email__c = 'test@test.com';
            Deal[2].FBE_Partner_Team_Mailbox__c = 'ab@nc.com';
            Deal[2].FBE_Price_Book_Id__c = standardPricebook.id;
            Deal[2].FBE_Submission_Date__c = system.now();
            Deal[2].FBE_Book_Date__c = system.now().date();
            Deal[2].FBE_Deal_Product_Classification__c = 'EMC Products';
            //Deal[2].FBE_AE_ManagerID__c = lUsr[0].ManagerID;
            Deal[2].FBE_Deal_Registration_Status__c ='New';
            insertDealList.add(Deal[2]);
            
            Test.startTest();
            INSERT insertDealList;
            
            List <Deal_Product__c> lDealProduct = FBE_UtilityFactory_Test.createDealProducts(1, Deal[0].id, prod.id);
            //Update revenue for this deal product
            lDealProduct[0].FBE_Quantity__c = 2;
            lDealProduct[0].FBE_Sales_price__c = 2000;
            insert lDealProduct; 
            
            Deal[0].FBE_Deal_Registration_Status__c = 'Approved';
            Deal[0].FBE_Decline_Comments__c = 'Deal Approved';
            Deal[0].FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            Deal[0].FBE_Solution_Domain__c = 'Business Solutions'; 
            Deal[0].FBE_PMO_Substatus__c = 'Under Review';
            Deal[0].Sales_Stage__c = 'Plan - 1%';
            Deal[0].FBE_Partner_Owner_Email__c = 'abc@abc.com';
            updateDealList.add(Deal[0]);

            Deal[1].FBE_Deal_Registration_Status__c = 'Approved';
            Deal[1].FBE_Decline_Comments__c = 'Deal Approved';
            Deal[1].FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            Deal[1].FBE_Solution_Domain__c = 'Business Solutions'; 
            // Deal[1].FBE_PMO_Substatus__c = 'Under Review';
            Deal[1].FBE_Partner_Owner_Email__c = 'abc@abc.com';
            Deal[1].Sales_Stage__c = 'Plan - 1%';
            updateDealList.add(Deal[1]);
            //update Deal[1];
  
            Deal[2].FBE_Deal_Registration_Status__c = 'Approved';
            Deal[2].FBE_Decline_Comments__c = 'Deal Approved';
            Deal[2].FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            Deal[2].FBE_Partner_Owner_Email__c = 'abc@abc.com';
            Deal[2].FBE_Solution_Domain__c = 'Business Solutions'; 
            // Deal[2].FBE_PMO_Substatus__c = 'Under Review';
            Deal[2].Sales_Stage__c = 'Plan - 1%';
            updateDealList.add(Deal[2]);            
           
            UPDATE updateDealList;
            Deal[0].FBE_Expiration_Date__c = date.today();
            Deal[1].FBE_Expiration_Date__c = date.today().addDays(10);
            Deal[2].FBE_Expiration_Date__c = date.today().addDays(30);
            updateDealList2.addAll( new List<Deal_Registration__c>{Deal[0],Deal[1],Deal[2]});
            UPDATE updateDealList2;
            
            Test.stopTest();
        }        
    }
    
    @isTest
    static void testMethod1(){
        Test.startTest();
        FBE_FPRM_Deal_Exp_Notif_Partner job = new FBE_FPRM_Deal_Exp_Notif_Partner();
        Id batchJobId = Database.executeBatch(job, 200);        
        FBE_DealExpiryNotifications_sch reminder = new FBE_DealExpiryNotifications_sch();
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String sch = '0 0 * * * ?';
        String jobID = System.schedule('Remind Opp', sch, reminder);   
        Test.stopTest(); 
        
        AsyncApexJob batchJob = [SELECT Id, Status, JobItemsProcessed FROM AsyncApexJob WHERE ID =: batchJobId ];
        System.assertEquals('Completed', batchJob.Status, 'Deal Exp batch did not run'); 
    }
}