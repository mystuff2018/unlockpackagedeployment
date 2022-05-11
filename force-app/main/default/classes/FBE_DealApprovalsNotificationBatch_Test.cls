/************    
* @ClassName    : FBE_DealApprovalsNotificationBatch_Test 
* @BaseClassName : FBE_DealApprovalsNotificationBatch
* @Description   : Send First & Second reminders for EU/FSI & Disti/VAR_Reseller Approvers
* @CreatedBy     : DeLL Team
* @CreatedOn     : 12-13-2019 [Sai]
* @UpdatedOn     : 09-03-2021 [Siva Kumar Valluru]
*********************/

@isTest
private class FBE_DealApprovalsNotificationBatch_Test {
    @testSetup
    static void testDataSetup()
    {
        Product2 prod = new Product2(
            Name = 'APOS',
            ProductCode = 'Pro-X',
            isActive = true,
            FBE_BU_Category__c = 'CSG Hardware'
        );
        insert prod;
        
        Test.startTest();
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();    
        List < User > lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 4, 'ab',null);
        
        
        Id pricebookId = Test.getStandardPricebookId();
        
        
        List < PriceBookEntry > pbe = [Select id from PriceBookEntry where Product2Id =: prod.id and Pricebook2Id =: pricebookId LIMIT 1];
        
        if (pbe.size() > 0) {
            pbe[0].UnitPrice = 99;
            pbe[0].IsActive = true;
        } else {
            PriceBookEntry pbeTmp = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = prod.Id,
                UnitPrice = 500,
                isActive = true
            );
            pbe.add(pbeTmp);
        }
        upsert pbe;
        
        
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(2,null);
        system.runAs(lUsr){
            lAcc[0].FBE_AE_ISR__c = lUsr.Id;
            lAcc[0].FBE_Partner_Type__c = 'Distributor';
            
            lAcc[1].FBE_AE_ISR__c = lUsr.Id;
            lAcc[1].FBE_Partner_Type__c = 'System Integrator';
            
            insert lAcc;
            
            
            List < Account > accnt = [select id from account WHERE ID =:lAcc[0].Id ];
            AccountTeamMember mem = new AccountTeamMember(
                AccountId=lAcc[0].Id, TeamMemberRole='AE', UserId=lUsr.Id
            );
            AccountTeamMember mem1 = new AccountTeamMember(
                AccountId=lAcc[0].Id, TeamMemberRole='CLIENT_OSS', UserId=lUsrNonIntegration[0].Id
            );
            AccountTeamMember mem2 = new AccountTeamMember(
                AccountId=lAcc[0].Id, TeamMemberRole='SVC_APOS_SR', UserId=lUsrNonIntegration[1].Id
            );
            insert mem;
            insert mem1;
            insert mem2;
            
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
            insert Deal;
            
            List <Deal_Product__c> lDealProduct = FBE_UtilityFactory_Test.createDealProducts(1, Deal.id, prod.id);
            //Update revenue for this deal product
            lDealProduct[0].FBE_Quantity__c = 2;
            lDealProduct[0].FBE_Sales_price__c = 2000;
            insert lDealProduct; 
            
            
            Deal.FBE_Deal_Registration_Status__c = 'Submitted';
            Deal.FBE_Secondary_Status__c = 'Pending Sales Review';
            Deal.FBE_PMO_Substatus__c = 'Under Review';
            update Deal; 
            
            Group testGroup = new Group(Name='EU Team',Type='Regular');
            insert testGroup;
            
            GroupMember member = new GroupMember();
            member.UserOrGroupId = Userinfo.getUserId();
            member.GroupId = testGroup.id;
            insert member;   
            
            Approval.ProcessSubmitRequest req =  new Approval.ProcessSubmitRequest();
            
            req.setObjectId(Deal.Id);
            req.setNextApproverIds(new Id[] {testGroup.Id});
            req.setProcessDefinitionNameOrId('FBE_DealRegSalesApproval');
            req.setSkipEntryCriteria(true);
            
            Approval.ProcessResult result = Approval.process(req); 
            
            
            for(ProcessInstance pi : [SELECT TargetObjectId, Status, (SELECT  StepStatus,TargetObjectId,Actor.name,OriginalActor.name,
                                                                      ProcessInstanceId,CreatedDate FROM StepsAndWorkitems WHERE stepstatus='Pending')
                                      FROM ProcessInstance WHERE TargetObjectId =: Deal.id AND status='Pending'])
            {
                for(ProcessInstanceHistory pih : pi.StepsAndWorkitems){
                    if(pih.Actor.name != null && !pih.Actor.name.contains('PSPPMO')) {
                    }
                }                   
            }
            
            
            Deal.FBE_First_Reminder__c = system.now();
            Deal.FBE_Second_Reminder__c = system.now();
            update Deal;
            Test.stopTest();
        }
        
        
    }
    static testmethod void testMethod1()
    {
        Test.startTest();
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        Group testGroup = [Select id from Group where Name='EU Team'][0];
        GroupMember member = new GroupMember(GroupId = testGroup.Id, UserOrGroupId=lUsr.Id);
        insert member;
        GroupMember member2 = new GroupMember(GroupId = testGroup.Id, UserOrGroupId=UserInfo.getUserId());
        insert member2;
        FBE_DealApprovalsNotificationBatch job = new FBE_DealApprovalsNotificationBatch();
        Id batchJobId=Database.executeBatch(job, 8);
        FBE_DealApprovalsNotification_Schedule reminder = new FBE_DealApprovalsNotification_Schedule();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String sch = '20 30 8 10 2 ?';
        String jobID = System.schedule('Remind Opp', sch, reminder);
        Test.stopTest();
        
        AsyncApexJob apexjob = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchJobId ];
        System.assertEquals('Completed', apexjob.Status, 'Batch did not run');
    }
}