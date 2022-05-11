/**
* @description       : Defect : 12192105 test class for FBE_FPRM_RecallDealApprlProcessBatch & FBE_FPRM_RecallDealApprlProcessScheduler
* @author            : Dipanshu Parakh
* @created on        : 11-03-2022
**/
@isTest
public class FBE_FPRM_RecallDealApprlProcessBatchTest {
    
    @testSetup
    static void testDataSetup(){
        Product2 prod = new Product2(Name = 'APOS', ProductCode = 'Pro-X', isActive = true, FBE_BU_Category__c = 'CSG Hardware');
        INSERT prod;
       
        Id pricebookId = Test.getStandardPricebookId();        
        List <PriceBookEntry> pbe = [Select id from PriceBookEntry where Product2Id =: prod.id and Pricebook2Id =: pricebookId LIMIT 1];       
        if (pbe.size() > 0) {
            pbe[0].UnitPrice = 99;
            pbe[0].IsActive = true;
        } else {
            PriceBookEntry pbeTmp = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 500, isActive = true);
            pbe.add(pbeTmp);
        }
        UPSERT pbe;
        
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();    
        List <User> lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'ab',null);       
        
        List <Account> lAcc = FBE_UtilityFactory_Test.createAccount(2,null);
        system.runAs(lUsr){
            lAcc[0].FBE_AE_ISR__c = lUsr.Id;
            lAcc[0].FBE_Partner_Type__c = 'Distributor';            
            lAcc[1].FBE_AE_ISR__c = lUsr.Id;
            lAcc[1].FBE_Partner_Type__c = 'System Integrator';            
            INSERT lAcc;
            
            List <Account> accnt = [select id from account WHERE ID =:lAcc[0].Id];
            AccountTeamMember mem = new AccountTeamMember(AccountId=lAcc[0].Id, TeamMemberRole='AE', UserId=lUsr.Id);
            AccountTeamMember mem1 = new AccountTeamMember(AccountId=lAcc[0].Id, TeamMemberRole='CLIENT_OSS', UserId=lUsrNonIntegration[0].Id);
            INSERT new List<AccountTeamMember>{mem, mem1};
                
            FBE_Test_Utility.createTransferDealCheckCustomSetting(false); 
            
            Deal_Registration__c Deal = FBE_UtilityFactory_Test.createDeal(1)[0];
            Deal.FBE_Deal_Justification_Statement__c = 'test statement';
            Deal.Name = 'test 1234';
            Deal.FBE_Account__c = accnt[0].Id;
            Deal.FBE_End_User_Account__c = lAcc[0].Id;
            Deal.FBE_Distributor_Account__c = lAcc[0].Id;
            Deal.FBE_Reseller_VAR_Account__c = lAcc[0].Id;
            Deal.FBE_FSI_Account__c = lAcc[1].Id;
            Deal.FBE_Price_Book_Id__c = pricebookId;
            Deal.FBE_Submission_Date__c = system.now();
            Deal.FBE_Book_Date__c = system.now().date();
            Deal.FBE_Deal_Product_Classification__c = 'EMC Products';
            Deal.FBE_AE_ManagerID__c = UserInfo.getUserId();
            Deal.FBE_Deal_Registration_Status__c ='New';
            INSERT Deal;
            
            List <Deal_Product__c> lDealProduct = FBE_UtilityFactory_Test.createDealProducts(1, Deal.id, prod.id);
            lDealProduct[0].FBE_Quantity__c = 2;
            lDealProduct[0].FBE_Sales_price__c = 2000;
            INSERT lDealProduct; 
            
            Deal.FBE_Deal_Registration_Status__c = 'Submitted';
            Deal.FBE_Secondary_Status__c = 'Pending Sales Review';
            Deal.FBE_PMO_Substatus__c = 'Under Review';
            UPDATE Deal; 
            
            Group testGroup = new Group(Name='EU Team',Type='Regular');
            INSERT testGroup;
            
            GroupMember member = new GroupMember();
            member.UserOrGroupId = Userinfo.getUserId();
            member.GroupId = testGroup.id;
            INSERT member;               
        }
    }
    
    static testmethod void testRecallApprovalProcessViaFPRM(){        
        Deal_Registration__c deal = [Select FBE_Deal_Registration_Status__c,FBE_Secondary_Status__c,FBE_PMO_Substatus__c from Deal_Registration__c LIMIT 1];     	        
        deal.FBE_Deal_Registration_Status__c = 'Recalled';
        UPDATE deal;
        
        Group testGroup = [Select Id from Group where name = 'EU Team' limit 1];
        Approval.ProcessSubmitRequest req =  new Approval.ProcessSubmitRequest();        
        req.setObjectId(deal.Id);
        req.setNextApproverIds(new Id[] {testGroup.Id});
        req.setProcessDefinitionNameOrId('FBE_DealRegSalesApproval');
        req.setSkipEntryCriteria(true);       
        Approval.ProcessResult result = Approval.process(req); 
        
        Test.startTest();
        FBE_FPRM_RecallDealApprlProcessScheduler job = new FBE_FPRM_RecallDealApprlProcessScheduler();
        String sch = '20 30 8 10 2 ?';
        String jobID = System.schedule('Recall deal approval batch', sch, job);
        
        FBE_FPRM_RecallDealApprlProcessBatch batch = new FBE_FPRM_RecallDealApprlProcessBatch();
        Id batchJobId  = Database.executeBatch(batch);
        Test.stopTest();
        
        AsyncApexJob batchJob = [SELECT Id, Status, JobItemsProcessed FROM AsyncApexJob WHERE ID =: batchJobId ];
        System.assertEquals('Completed', batchJob.Status, 'Recall batch did not run');        
    }    
}