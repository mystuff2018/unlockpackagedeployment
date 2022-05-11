/**
* @description : FEATURE 9745204 STORY 10822324 : 24hr and 48hr reminder batch test class for deal extensions
* @author      : Dipanshu Parakh
* @created on  : 29-01-2022
**/

@istest
public class FBE_FPRMDealExtApprovalReminderBatchTest {
    
    @testSetup
    static void testDataSetup(){
        List<Product2> prodList = FBE_UtilityFactory_Test.createProducts(1);
        prodList[0].Name = 'APOS';
        prodList[0].FBE_BU_Category__c = 'CSG Hardware';
        INSERT prodList;
                
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        UPDATE standardPricebook;
        
        List<PriceBookEntry> pbe = [Select id from PriceBookEntry where Product2Id =: prodList[0].id and Pricebook2Id =: standardPricebook.id LIMIT 1];        
        if(pbe.size() > 0){
            pbe[0].UnitPrice = 99;
            pbe[0].IsActive = true;
        }else{
            PriceBookEntry pbeTmp = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prodList[0].Id, UnitPrice = 500, isActive = true);
            pbe.add(pbeTmp);
        }
        UPSERT pbe;
        
        INSERT new FBE_FPRM_Notification_Switch__c(Send_Deal_Extn_Approval_Emails__c = true, Send_Deal_Extn_Rejection_Emails__c = true, FBE_FPRM_Cut_Over_Switch__c = True);
        List<Account> accountList = FBE_UtilityFactory_Test.createAccount(3,null);
        accountList[0].FBE_Partner_Type__c = 'Distributor';
        accountList[1].FBE_Partner_Type__c = 'Reseller';
        accountList[2].FBE_Partner_Type__c = 'System Integrator';
        
        List <User> nonIntUsers = FBE_UtilityFactory_Test.createUser('System Administrator', 5, 'ab',null);
        User intUser = FBE_UtilityFactory_Test.getIntegrationUser();
        
        System.runAs(intUser){
            accountList[0].FBE_AE_ISR__c = intUser.Id;
            INSERT accountList;
            AccountTeamMember distiMem1 = new AccountTeamMember(AccountId = accountList[0].Id, TeamMemberRole = 'AE', UserId = intUser.Id);
            AccountTeamMember distiMem2 = new AccountTeamMember(AccountId = accountList[0].Id, TeamMemberRole='CLIENT_OSS', UserId = nonIntUsers[0].Id);
            AccountTeamMember distiMem3 = new AccountTeamMember(AccountId = accountList[0].Id, TeamMemberRole='SVC_APOS_SR', UserId = nonIntUsers[1].Id);
            AccountTeamMember fsiMem1 = new AccountTeamMember(AccountId = accountList[2].Id, TeamMemberRole='AE', UserId = nonIntUsers[2].Id);
			AccountTeamMember fsiMem2 = new AccountTeamMember(AccountId = accountList[2].Id, TeamMemberRole='CLIENT_TSR', UserId = nonIntUsers[3].Id);
            AccountTeamMember resMem = new AccountTeamMember(AccountId = accountList[1].Id, TeamMemberRole='SR', UserId = nonIntUsers[4].Id);

            INSERT new List<AccountTeamMember>{distiMem1, distiMem2, distiMem3, fsiMem1, fsiMem2, resMem};       
        }
        
        FBE_Test_Utility.createTransferDealCheckCustomSetting(false);              
        Deal_Registration__c deal = FBE_UtilityFactory_Test.createDeal(1)[0];
        deal.FBE_Deal_Justification_Statement__c = 'test statement';
        deal.Name = 'test 1234';
        deal.FBE_Account__c = accountList[0].Id;
        deal.FBE_End_User_Account__c = accountList[0].Id;
        deal.FBE_Distributor_Account__c = accountList[0].Id;
        deal.FBE_Reseller_VAR_Account__c = accountList[1].Id;
        deal.FBE_FSI_Account__c = accountList[2].Id;
        deal.FBE_Is_this_going_through_an_FSI__c='yes';
        deal.FBE_FSI_Internal_Use__c='Sell-out';
        deal.FBE_Price_Book_Id__c = Test.getStandardPricebookId();
        deal.FBE_Submission_Date__c = system.now();
        deal.FBE_Book_Date__c = system.now().date();
        deal.FBE_Deal_Product_Classification__c = 'EMC Products';
        deal.FBE_AE_ManagerID__c = UserInfo.getUserId();//lUsr[0].ManagerID;
        deal.FBE_Deal_Registration_Status__c ='New';
        INSERT deal;
        
        List<Deal_Product__c> dealProduct = FBE_UtilityFactory_Test.createDealProducts(1, deal.id, prodList[0].id);
        dealProduct[0].FBE_Quantity__c = 2;
        dealProduct[0].FBE_Sales_price__c = 2000;
        INSERT dealProduct; 
        
        Test.startTest();
        deal.FBE_Deal_Registration_Status__c = 'Approved';
        deal.FBE_Decline_Comments__c = 'Deal Approved';
        deal.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
        deal.FBE_Solution_Domain__c = 'Business Solutions'; 
        deal.Sales_Stage__c = 'Plan - 1%';
        UPDATE deal;
        deal.FBE_Expiration_Date__c = date.today();
        UPDATE deal;
        Test.stopTest();
        
        Deal_Extension__c dealExt = new Deal_Extension__c();       
        dealExt.FBE_Deal_Registration__c = deal.id;
        dealExt.FBE_Extension_Request_Reason__c = 'Approved by me';
        dealExt.FBE_Sequence_Number__c = 1;
        INSERT dealExt;  
        
        Group testGroupFSI = new Group(Name='FSI Exnt Team',Type='Queue');
        Group testGroupEU =  new Group(Name='EU Exnt Team', Type='Queue');
        INSERT new List<Group>{testGroupFSI, testGroupEU};     
    }
   
    @istest
    static void testRemindersForDealExtension(){        
        //Auto Approved Scenario
        Deal_Extension__c dealExt = [select id, FBE_Sequence_Number__c, FBE_Deal_Registration__c, FBE_Extension_Request_Status__c, FBE_Deal_Registration_Status__c,FBE_PMO_Substatus__c, FBE_Secondary_Status__c from Deal_Extension__c];
        dealExt.FBE_Extension_Request_Status__c='Submitted';
        dealExt.FBE_PMO_Substatus__c = 'Under Review';           
        update dealExt;
        
        Test.startTest();

        Deal_Registration__c deal = [select id, FBE_Expiration_Date__c from Deal_Registration__c where Name='test 1234'];        
        deal.FBE_Expiration_Date__c=date.today() + 3;
        update deal;
        
        Deal_Extension__c dealExt2 = new Deal_Extension__c();       
        dealExt2.FBE_Deal_Registration__c = deal.id;
        dealExt2.FBE_Extension_Request_Reason__c = 'ext 2';
        dealExt2.FBE_Sequence_Number__c = 2;
        INSERT dealExt2;  
        
        dealExt2.FBE_Extension_Request_Status__c='Submitted';
        dealExt2.FBE_PMO_Substatus__c = 'Under Review';
        dealExt2.FBE_Secondary_Status__c = 'Pending Sales Review';
        UPDATE dealExt2;
      
        dealExt2.FBE_First_Reminder__c = system.now();
        dealExt2.FBE_Second_Reminder__c = system.now();
        UPDATE dealExt2;
        
        FBE_FPRMDealExtApprovalReminderBatch batch = new FBE_FPRMDealExtApprovalReminderBatch();
        Id batchJobId = Database.executeBatch(batch);
        FBE_FPRMDealExtApprovalReminderScheduler reminder = new FBE_FPRMDealExtApprovalReminderScheduler();
        String sch = '20 30 8 10 2 ?';
        String jobID = System.schedule('Deal Ext batch', sch, reminder);
        Test.stopTest();
        
        AsyncApexJob job = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchJobId ];
        System.assertEquals('Completed', job.Status, 'Batch did not run');
    }   
}