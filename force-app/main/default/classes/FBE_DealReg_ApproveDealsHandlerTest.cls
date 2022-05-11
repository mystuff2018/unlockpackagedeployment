/**************
* @ClassName    : FBE_DealReg_ApproveDealsHandlerTest
* @Description  : This class is to maintain test methods for all Deal Approve/Reject/Recall logics.
* @CreatedBy     : DeLL Team
* @CreatedOn     : 11-28-2020 
* @LastModified  : May-09-2021 [Siva Kumar Valluru] - Optimized the code to fix the Too Many SOQL Queries 101 error
***************/


@isTest
private class FBE_DealReg_ApproveDealsHandlerTest {
    @TestSetup
    static void testDataSetup()
    {    
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        
        List < User > lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 4, 'ab',null);
        
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(3,null);
        system.runAs(lUsr){
            lAcc[0].FBE_AE_ISR__c = lUsr.Id;
            lAcc[0].FBE_Partner_Type__c = 'Distributor';
            lAcc[1].FBE_Partner_Type__c ='System Integrator';    
            insert lAcc;
            AccountTeamMember mem = new AccountTeamMember(
                AccountId=lAcc[0].Id, TeamMemberRole='AE', UserId=lUsr.Id
            );            
            AccountTeamMember mem1 = new AccountTeamMember(
                AccountId=lAcc[0].Id, TeamMemberRole='SR', UserId=lUsrNonIntegration[0].Id
            );
            AccountTeamMember mem2 = new AccountTeamMember(
                AccountId=lAcc[0].Id, TeamMemberRole='CLIENT_OSS', UserId=lUsrNonIntegration[1].Id
            );
            AccountTeamMember mem3 = new AccountTeamMember(
                AccountId=lAcc[0].Id, TeamMemberRole='SVC_APOS_SR', UserId=lUsrNonIntegration[2].Id
            );
             AccountTeamMember mem4 = new AccountTeamMember(
                AccountId=lAcc[1].Id, TeamMemberRole='CLIENT_TSR', UserId=lUsrNonIntegration[3].Id
            );
            Insert new List<AccountTeamMember>{mem, mem1, mem2, mem3, mem4};
            List<Product2> lstproducts = FBE_Test_Utility.createProducts(10);
            lstproducts[0].Name = 'Apos';
            lstproducts[1].Name = 'SonicWALL';
            lstproducts[2].Name = 'VMWare';
            lstproducts[3].Name = 'Nutanix';
            lstproducts[4].Name = 'Nutanix';
            lstproducts[5].Name = 'CSG test product';
            lstproducts[5].FBE_BU_Category__c = 'CSG Hardware';
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
            Test.startTest();
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
                Pricebook2Id = standardPricebook.ID
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
            opp.StageName = 'Plan - 1%';
            //opp.FBE_Win_Loss_Reason__c = 'Relationship';
            opr.add(opp);
            update opr;
            Test.stopTest();
            
            FBE_Test_Utility.createTransferDealCheckCustomSetting(false);
            Deal_Registration__c Deal = FBE_UtilityFactory_Test.createDeal(1)[0];
            Deal.FBE_Deal_Justification_Statement__c = 'test statement';
            Deal.Name = 'test 1234';
            Deal.FBE_Account__c = lAcc[0].Id;
            Deal.FBE_End_User_Account__c = lAcc[0].Id;
            Deal.FBE_Distributor_Account__c = lAcc[0].Id;
            Deal.FBE_Reseller_VAR_Account__c = lAcc[0].Id;
            Deal.FBE_FSI_Account__c = lAcc[1].Id;
            Deal.FBE_Related_Opportunity__c = opp.Id;
            Deal.FBE_Price_Book_Id__c = standardPricebook.ID;
            Deal.FBE_Book_Date__c = system.now().Date();
            Deal.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            deal.Sales_Stage__c = 'Plan - 1%';
            deal.FBE_Solution_Domain__c = 'Business Solutions';

            Deal.FBE_Deal_Product_Classification__c = 'EMC Products';
            Deal.FBE_Deal_Registration_Status__c ='New';
            Deal.FBE_Submission_Date__c = system.now();
            Deal.FBE_Analyst_Observations_History__c = 'test';
            Deal.Analyst_Observations__c = 'testing';
            
            Deal_Registration__c Deal1 = new Deal_Registration__c();
            Deal1.FBE_Deal_Justification_Statement__c = 'test statement';
            Deal1.Name = 'testdeal';
            Deal1.FBE_Account__c = lAcc[0].Id;
            Deal1.FBE_End_User_Account__c = lAcc[0].Id;
            Deal1.FBE_Distributor_Account__c = lAcc[0].Id;
            Deal1.FBE_Reseller_VAR_Account__c = lAcc[0].Id;
            Deal1.FBE_FSI_Account__c = lAcc[1].Id;
            Deal1.FBE_Is_this_going_through_an_FSI__c = 'Yes';
            Deal1.FBE_FSI_Internal_Use__c = 'Sell-out'; 	
            Deal1.FBE_Related_Opportunity__c = opp.Id;
            Deal1.FBE_Price_Book_Id__c = standardPricebook.ID;
            Deal1.FBE_Book_Date__c = system.now().Date();
            Deal1.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            Deal1.Sales_Stage__c = 'Plan - 1%';
            Deal1.FBE_Solution_Domain__c = 'Business Solutions';

            Deal1.FBE_Deal_Registration_Status__c ='New';
            Deal1.FBE_Submission_Date__c = system.now();
            Deal1.FBE_Analyst_Observations_History__c = 'test';
            insert new List<Deal_Registration__c>{Deal, Deal1};
                
            
            List <Deal_Product__c> lstDealProducts = new List<Deal_Product__c>();          
            
            List<Deal_Product__c> lDealProduct = FBE_UtilityFactory_Test.createDealProducts(1, Deal.id, lstproducts[0].id);
            //lDealProduct[0].Name = 'Apos';
            lDealProduct[0].FBE_Quantity__c = 2;
            lDealProduct[0].FBE_Sales_price__c = 2000;
            lstDealProducts.addAll(lDealProduct);
            
            List<Deal_Product__c> lDealProduct1 = FBE_UtilityFactory_Test.createDealProducts(1, Deal.id, lstproducts[1].id);
            lDealProduct1[0].FBE_Quantity__c = 2;
            lDealProduct1[0].FBE_Sales_price__c = 2000;
            lstDealProducts.addAll(lDealProduct1);
            List<Deal_Product__c> lDealProduct2 = FBE_UtilityFactory_Test.createDealProducts(1, Deal.id, lstproducts[2].id);
            lDealProduct2[0].FBE_Quantity__c = 2;
            lDealProduct2[0].FBE_Sales_price__c = 2000;
            lstDealProducts.addAll(lDealProduct2);

            List<Deal_Product__c> lDealProduct3 = FBE_UtilityFactory_Test.createDealProducts(1, Deal.id, lstproducts[3].id);
            lDealProduct3[0].FBE_Quantity__c = 2;
            lDealProduct3[0].FBE_Sales_price__c = 2000;
            lstDealProducts.addAll(lDealProduct3);

            List<Deal_Product__c> lDealProduct4 = FBE_UtilityFactory_Test.createDealProducts(1, Deal1.id, lstproducts[4].id);
            lDealProduct4[0].FBE_Quantity__c = 2;
            lDealProduct4[0].FBE_Sales_price__c = 2000;
            lstDealProducts.addAll(lDealProduct4);
            List<Deal_Product__c> lDealProduct5 = FBE_UtilityFactory_Test.createDealProducts(1, Deal1.id, lstproducts[5].id);
            lDealProduct5[0].FBE_Quantity__c = 2;
            lDealProduct5[0].FBE_Sales_price__c = 2000;
            lstDealProducts.addAll(lDealProduct5);
            
            insert lstDealProducts;
            Group eug = new Group(Type='Queue', Name='EUQueue'); // Change the Queue name
            insert eug;
            List<GroupMember> insertMemberList = new List<GroupMember>();
            GroupMember member = new GroupMember();
            member.UserOrGroupId = lUsr.ID;
            member.GroupId = eug.id;
            insertMemberList.add(member);
            insert insertMemberList;         
        }
    }
    
    static testmethod void Approvalprocess(){         
        List<User> userdetails = [Select Id from user where Profile.Name = 'System Administrator' Limit 2];
        List<Id> UserId = new List<Id>();
        List<String> UserString = new List<String>();
        for(User u : userdetails){
            userID.add(u.ID);
        }
        
        List<Deal_Registration__c> dealDetails = [Select FBE_Deal_Registration_Status__c,FBE_Secondary_Status__c,FBE_FSI_Account__c,FBE_Reseller_VAR_Account__c,FBE_Distributor_Account__c,FBE_Submission_Date__c,FBE_Formatted_Submission_Date__c,FBE_Deal_Createddate__c,Analyst_Observations__c,CreatedDate,FBE_PMO_Substatus__c from Deal_Registration__c where name = 'test 1234'];
        dealDetails[0] = updateDeal(dealDetails[0], 'Under Review', 'analyst', 'test Observation');
        set<id> dealid = new set<id>();
        dealid.add(dealDetails[0].id);
        system.assertNotEquals(null, dealDetails, 'DealRegistration Records not found');
        map<id,Deal_Registration__c> oldmap = new map<id,Deal_Registration__c>();
        for(Deal_Registration__c dl:  dealDetails){
            oldmap.put(dl.id, dl);
        }
        List<Group> grp = [Select ID from Group where Type='Queue'and Name='EUQueue'];
        
        Test.startTest();
        List<Deal_Registration__c> dealDetails1 = [Select FBE_Deal_Registration_Status__c,FBE_Submission_Date__c,FBE_Formatted_Submission_Date__c,FBE_Deal_Createddate__c,Analyst_Observations__c,CreatedDate,FBE_PMO_Substatus__c from Deal_Registration__c where name = 'testdeal'];
        dealDetails1[0] = updateDeal(dealDetails1[0], 'PMO Approved', '', '');
        set<id> dealid1 = new set<id>();
        dealid1.add(dealDetails1[0].id);
        
        
        
        Queueable q2 = new FBE_CreateQueueForApproval(dealDetails[0].ID,grp[0],null,grp[0],userID,userID,UserString);
        q2.execute(null); 
        boolean flag = true;
        //integer i = 1;
        FBE_DealReg_ApproveDealsHandler fbhandler = new FBE_DealReg_ApproveDealsHandler (flag,1);
        FBE_DealReg_ApproveDealsHandler.callEUApproval(dealid);
        fbhandler.checkDealthresholdAmount(dealDetails,oldmap);
        fbhandler.UpdateCreated_Submissiondate(dealDetails,oldmap);
        fbhandler.updateApproveDeclineComments(dealDetails,oldmap);
        FBE_DealReg_ApproveDealsHandler.callEUAndFSIApproval(dealid);
        FBE_DealReg_ApproveDealsHandler.callPSPPMOApproval(dealid1);
        dealDetails[0].FBE_Approval_Fired__c = true;
        update dealDetails[0];
        
        set<id> approved_dealid = new set<id>();
        approved_dealid.add(dealDetails[0].id);
        FBE_DealReg_ApproveDealsHandler.ChangeStatus(approved_dealid);
        dealDetails[0].FBE_Deal_Registration_Status__c = 'Recalled';
        update dealDetails[0];
        set<id> recall_dealid = new set<id>();
        recall_dealid.add(dealDetails[0].id);
        String recall = 'Recalled as Requested';
        string remove = 'Removed';
        FBE_DealReg_ApproveDealsHandler.RecallOrRejectStatus(recall_dealid,recall,remove);
        ProcessInstance processInstance= [select Id,Status from ProcessInstance where TargetObjectId =: dealDetails1[0].id and status = 'Pending' LIMIT 1];
        ProcessInstanceWorkitem workItem = [select id, Actor.name, OriginalActor.name from ProcessInstanceWorkitem where ProcessInstanceId  =: processInstance.Id LIMIT 1];
        
        String result = FBE_FPRM_GetObject_Name_Approval_Cls.getobjectnameofapprovalrecord(workItem.Id);
        
        Test.stopTest();
    }
    
    static testmethod void getObjectNameOfApprovalRecordNegativeTest(){ 
        List<Deal_Registration__c> dealList = [Select FBE_Deal_Registration_Status__c,FBE_Secondary_Status__c,FBE_FSI_Account__c,FBE_Reseller_VAR_Account__c,FBE_Distributor_Account__c,FBE_Submission_Date__c,FBE_Formatted_Submission_Date__c,FBE_Deal_Createddate__c,Analyst_Observations__c,CreatedDate,FBE_PMO_Substatus__c from Deal_Registration__c where name = 'test 1234'];
        dealList[0] = updateDeal(dealList[0], 'Under Review', 'analyst', 'test Observation');
        set<id> dealid = new set<id>();
        dealid.add(dealList[0].id);
        
        Test.startTest();
        boolean flag = true;
        FBE_DealReg_ApproveDealsHandler fbhandler = new FBE_DealReg_ApproveDealsHandler (flag,1);
        FBE_DealReg_ApproveDealsHandler.callEUApproval(dealid);
        
        dealList[0].FBE_Approval_Fired__c = true;
        update dealList[0];

        Id param = null;
        String result1 = FBE_FPRM_GetObject_Name_Approval_Cls.getobjectnameofapprovalrecord(param);
        try{            
            String result2 = FBE_FPRM_GetObject_Name_Approval_Cls.getobjectnameofapprovalrecord(dealList[0].id);
        }catch(Exception e){
            System.debug('exception:' + e);
        }
        Test.stopTest();
        
    }
    
    private static Deal_Registration__c updateDeal(Deal_Registration__c deal, String pmoSubstatus, String analystHistory, String analystObservation){
        deal.FBE_Deal_Registration_Status__c = 'Submitted';
       	deal.FBE_PMO_Substatus__c = pmoSubstatus;
        deal.FBE_End_User_Mailing_Street__c = 'test';
        deal.FBE_End_User_Mailing_City__c = 'test';
        deal.FBE_End_User_Last_Name__c = 'test';
        deal.FBE_End_User_First_Name__c = 'test';
        deal.FBE_Deal_Createddate__c = '';
        deal.FBE_Formatted_Submission_Date__c = '';
        deal.FBE_Analyst_Observations_History__c = analystHistory;
        deal.Analyst_Observations__c = analystObservation;
        return deal;
    }
    
}