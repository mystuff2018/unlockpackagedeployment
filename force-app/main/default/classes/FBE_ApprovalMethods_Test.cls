/**
* @description       : 
* @author            : Sitaram Teki
* @group             : 
* @last modified on  : 02-04-2022
* @last modified by  : Sitaram Teki
**/
@isTest
private class FBE_ApprovalMethods_Test {
    @TestSetup
    static void setUpData() {
        //get integration User
        List <User> nonIntUsers = FBE_UtilityFactory_Test.createUser('System Administrator', 5, 'ab',null);
        User intUser = FBE_UtilityFactory_Test.getIntegrationUser();
        
        List<Account> accountList = FBE_UtilityFactory_Test.createAccount(6,null);
        system.runAs(intUser){
            accountList[0].FBE_AE_ISR__c = intUser.Id;
            accountList[0].FBE_Partner_Type__c = 'Distributor';
            accountList[1].FBE_Partner_Type__c = 'Reseller';
            accountList[2].FBE_Partner_Type__c = 'System Integrator';
            
            INSERT accountList;
            
            AccountTeamMember distiMem1 = new AccountTeamMember(AccountId = accountList[0].Id, TeamMemberRole = 'AE', UserId = intUser.Id);
            AccountTeamMember distiMem2 = new AccountTeamMember(AccountId = accountList[0].Id, TeamMemberRole='CLIENT_OSS', UserId = nonIntUsers[0].Id);
            AccountTeamMember distiMem3 = new AccountTeamMember(AccountId = accountList[0].Id, TeamMemberRole='SVC_APOS_SR', UserId = nonIntUsers[1].Id);
            AccountTeamMember fsiMem1 = new AccountTeamMember(AccountId = accountList[2].Id, TeamMemberRole='AE', UserId = nonIntUsers[2].Id);
            AccountTeamMember fsiMem2 = new AccountTeamMember(AccountId = accountList[2].Id, TeamMemberRole='CLIENT_OSS', UserId = nonIntUsers[3].Id);
            AccountTeamMember resMem = new AccountTeamMember(AccountId = accountList[1].Id, TeamMemberRole='SR', UserId = nonIntUsers[4].Id);
            AccountTeamMember resMem1 = new AccountTeamMember(AccountId = accountList[1].Id, TeamMemberRole = 'AE', UserId = intUser.Id);
            
            
            INSERT new List<AccountTeamMember>{distiMem1, distiMem2,distiMem3, fsiMem1, fsiMem2,  resMem, resMem1};       
                
                List<Product2> lstproducts = FBE_Test_Utility.createProducts(9);
            lstproducts[0].Name = 'APOS';
            lstproducts[1].Name = 'SonicWALL';
            lstproducts[2].Name = 'VMWare';
            lstproducts[2].FBE_BU_Category__c = 'CSG Other';
            lstproducts[3].Name = 'Nutanix';
            lstproducts[3].FBE_BU_Category__c = 'CSG Other';
            lstproducts[4].Name = 'CSG test product';
            lstproducts[4].FBE_BU_Category__c = 'CSG Other';
            lstproducts[5].Name = 'XC Series';
            lstproducts[5].FBE_BU_Category__c = 'CSG Other';
            lstproducts[6].Name = 'APOS Test';
            lstproducts[7].Name = 'SonicWALL Test';
            lstproducts[8].Name = 'VMWare Test';
            
            insert lstproducts;
            
            FBE_Test_Utility.createTransferDealCheckCustomSetting(false);
            
            Deal_Registration__c Deal1 = new Deal_Registration__c();
            Deal1.FBE_Deal_Justification_Statement__c = 'test statement';
            Deal1.Name = 'TestDealExt No Roles';
            Deal1.FBE_Account__c = accountList[0].Id;
            Deal1.FBE_End_User_Account__c = accountList[0].Id;
            Deal1.FBE_Distributor_Account__c = accountList[0].Id;
            Deal1.FBE_Reseller_VAR_Account__c = accountList[1].Id; 	
            Deal1.FBE_FSI_Account__c = accountList[2].Id;
            Deal1.FBE_Is_this_going_through_an_FSI__c = 'Yes';
            Deal1.FBE_FSI_Internal_Use__c = 'Sell-out'; 
            Deal1.FBE_Book_Date__c = system.now().Date();
            Deal1.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            Deal1.Sales_Stage__c = 'Plan - 1%';
            Deal1.FBE_Solution_Domain__c = 'Business Solutions';
            Deal1.FBE_Deal_Registration_Status__c ='Submitted';
            Deal1.FBE_Submission_Date__c = system.now();
            Deal1.FBE_Analyst_Observations_History__c = 'test';
            insert Deal1;
            
            //Deal Registration Data with Approved Status for EU Extn
            Deal_Registration__c Deal3 = new Deal_Registration__c();
            Deal3.FBE_Deal_Justification_Statement__c = 'test statement';
            Deal3.Name = 'TestDealExt EU';
            Deal3.FBE_Account__c = accountList[0].Id;
            Deal3.FBE_End_User_Account__c = accountList[0].Id;
            Deal3.FBE_Distributor_Account__c = accountList[0].Id;
            Deal3.FBE_Reseller_VAR_Account__c = accountList[1].Id;
            Deal3.FBE_Book_Date__c = system.now().Date();
            Deal3.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            Deal3.Sales_Stage__c = 'Plan - 1%';
            Deal3.FBE_Solution_Domain__c = 'Business Solutions';
            Deal3.FBE_Deal_Registration_Status__c ='Approved';
            Deal3.FBE_Submission_Date__c = system.now();
            Deal3.FBE_Analyst_Observations_History__c = 'test';
            Deal3.FBE_Decline_Comments__c = 'Deal Approved';
            insert Deal3;
            
            //Deal Registration Data with Approved Status for FSI Extn
            Deal_Registration__c Deal4 = new Deal_Registration__c();
            Deal4.FBE_Deal_Justification_Statement__c = 'test statement';
            Deal4.Name = 'TestDealExt FSI';
            Deal4.FBE_Account__c = accountList[0].Id;
            Deal4.FBE_End_User_Account__c = accountList[0].Id;
            Deal4.FBE_Distributor_Account__c = accountList[0].Id;
            Deal4.FBE_Reseller_VAR_Account__c = accountList[1].Id; 	
            Deal4.FBE_FSI_Account__c = accountList[2].Id;
            Deal4.FBE_Is_this_going_through_an_FSI__c = 'Yes';
            Deal4.FBE_FSI_Internal_Use__c = 'Sell-out'; 
            Deal4.FBE_Book_Date__c = system.now().Date();
            Deal4.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            Deal4.Sales_Stage__c = 'Plan - 1%';
            Deal4.FBE_Solution_Domain__c = 'Business Solutions';
            Deal4.FBE_Deal_Registration_Status__c ='Approved';
            Deal4.FBE_Submission_Date__c = system.now();
            Deal4.FBE_Analyst_Observations_History__c = 'test';
            Deal4.FBE_Decline_Comments__c = 'Deal Approved';
            insert Deal4;
            
            
            //Deal Extension with Submitted Status for Extension with EU Account
            Deal_Extension__c dex=new Deal_Extension__c();
            dex.FBE_Analyst_Observations_History__c = 'test894';
            dex.FBE_Deal_Registration__c=Deal3.Id;
            dex.FBE_Sequence_Number__c=2;
            dex.FBE_Extension_Request_Reason__c = 'ext 2';
            insert dex; 
            
            //Deal Extension with Submitted Status for Extension with EUFSI Account
            Deal_Extension__c dex1=new Deal_Extension__c();
            dex1.FBE_Analyst_Observations_History__c = 'test678';
            dex1.FBE_Deal_Registration__c=Deal4.Id;
            dex1.FBE_Sequence_Number__c=2;
            dex1.FBE_Extension_Request_Reason__c = 'ext req';
            insert dex1; 
            
            
            Test.startTest();
            List<Deal_Product__c> dealProduct = FBE_UtilityFactory_Test.createDealProducts(1, Deal3.id, lstproducts[0].id);
            dealProduct[0].FBE_Quantity__c = 2;
            dealProduct[0].FBE_Sales_price__c = 2000;
            INSERT dealProduct; 
            List<Deal_Product__c> dealProduct_1 = FBE_UtilityFactory_Test.createDealProducts(1, Deal3.id, lstproducts[6].id);
            dealProduct_1[0].FBE_Quantity__c = 2;
            dealProduct_1[0].FBE_Sales_price__c = 2000;
            INSERT dealProduct_1; 
            List<Deal_Product__c> dealProduct_2 = FBE_UtilityFactory_Test.createDealProducts(1, Deal3.id, lstproducts[7].id);
            dealProduct_2[0].FBE_Quantity__c = 2;
            dealProduct_2[0].FBE_Sales_price__c = 2000;
            INSERT dealProduct_2; 
            List<Deal_Product__c> dealProduct_3 = FBE_UtilityFactory_Test.createDealProducts(1, Deal3.id, lstproducts[8].id);
            dealProduct_3[0].FBE_Quantity__c = 2;
            dealProduct_3[0].FBE_Sales_price__c = 2000;
            INSERT dealProduct_3; 
            
            List<Deal_Product__c> dealProduct0 = FBE_UtilityFactory_Test.createDealProducts(1, Deal3.id, lstproducts[5].id);
            dealProduct0[0].FBE_Quantity__c = 2;
            dealProduct0[0].FBE_Sales_price__c = 2000;
            INSERT dealProduct0;
            
            
            List<Deal_Product__c> dealProduct1 = FBE_UtilityFactory_Test.createDealProducts(1, Deal3.id, lstproducts[3].id);
            dealProduct1[0].FBE_Quantity__c = 2;
            dealProduct1[0].FBE_Sales_price__c = 2000;
            INSERT dealProduct1;
            
            List<Deal_Product__c> dealProduct2 = FBE_UtilityFactory_Test.createDealProducts(1, Deal3.id, lstproducts[2].id);
            dealProduct2[0].FBE_Quantity__c = 2;
            dealProduct2[0].FBE_Sales_price__c = 2000;
            INSERT dealProduct2;
            
            List<Deal_Product__c> dealProduct3 = FBE_UtilityFactory_Test.createDealProducts(1, Deal3.id, lstproducts[1].id);
            dealProduct3[0].FBE_Quantity__c = 2;
            dealProduct3[0].FBE_Sales_price__c = 2000;
            INSERT dealProduct3;
            
            List<Deal_Product__c> dealProducts = FBE_UtilityFactory_Test.createDealProducts(1, Deal3.id, lstproducts[4].id);
            dealProducts[0].FBE_Quantity__c = 2;
            dealProducts[0].FBE_Sales_price__c = 2000;
            INSERT dealProducts;
            
            List<Deal_Product__c> dealProduct4 = FBE_UtilityFactory_Test.createDealProducts(1, Deal4.id, lstproducts[0].id);
            dealProduct4[0].FBE_Quantity__c = 2;
            dealProduct4[0].FBE_Sales_price__c = 2000;
            INSERT dealProduct4; 
            List<Deal_Product__c> dealProduct_4 = FBE_UtilityFactory_Test.createDealProducts(1, Deal4.id, lstproducts[6].id);
            dealProduct_4[0].FBE_Quantity__c = 2;
            dealProduct_4[0].FBE_Sales_price__c = 2000;
            INSERT dealProduct_4; 
            List<Deal_Product__c> dealProduct_5 = FBE_UtilityFactory_Test.createDealProducts(1, Deal4.id, lstproducts[7].id);
            dealProduct_5[0].FBE_Quantity__c = 2;
            dealProduct_5[0].FBE_Sales_price__c = 2000;
            INSERT dealProduct_5; 
            List<Deal_Product__c> dealProduct_6 = FBE_UtilityFactory_Test.createDealProducts(1, Deal4.id, lstproducts[8].id);
            dealProduct_6[0].FBE_Quantity__c = 2;
            dealProduct_6[0].FBE_Sales_price__c = 2000;
            INSERT dealProduct_6; 
            
            List<Deal_Product__c> dealProduct5 = FBE_UtilityFactory_Test.createDealProducts(1, Deal4.id, lstproducts[3].id);
            dealProduct5[0].FBE_Quantity__c = 2;
            dealProduct5[0].FBE_Sales_price__c = 2000;
            INSERT dealProduct5;
            
            List<Deal_Product__c> dealProduct6 = FBE_UtilityFactory_Test.createDealProducts(1, Deal4.id, lstproducts[2].id);
            dealProduct6[0].FBE_Quantity__c = 2;
            dealProduct6[0].FBE_Sales_price__c = 2000;
            INSERT dealProduct6;
            
            List<Deal_Product__c> dealProduct7 = FBE_UtilityFactory_Test.createDealProducts(1, Deal4.id, lstproducts[1].id);
            dealProduct7[0].FBE_Quantity__c = 2;
            dealProduct7[0].FBE_Sales_price__c = 2000;
            INSERT dealProduct7;
            
            List<Deal_Product__c> dealProduct8 = FBE_UtilityFactory_Test.createDealProducts(1, Deal4.id, lstproducts[4].id);
            dealProduct8[0].FBE_Quantity__c = 2;
            dealProduct8[0].FBE_Sales_price__c = 2000;
            INSERT dealProduct8;
            
            Test.stopTest();
            Group euExtn = new Group(Type='Queue', Name='EU Extn Team'); 
            Group fsiExtn = new Group(Type='Queue', Name='FSI Extn Team'); 
            INSERT new List<Group>{euExtn, fsiExtn}; 
                
                List<GroupMember> insertMemberList = new List<GroupMember>();
            GroupMember member = new GroupMember();
            member.UserOrGroupId = intUser.ID;
            member.GroupId = euExtn.id;
            insertMemberList.add(member);
            insert insertMemberList; 
            
            List<GroupMember> insertMemberList1 = new List<GroupMember>();
            GroupMember member1 = new GroupMember();
            member1.UserOrGroupId = intUser.ID;
            member1.GroupId = fsiExtn.id;
            insertMemberList1.add(member1);
            insert insertMemberList1; 
        }
    }
    
    static testmethod void callEUApprovalDealEXtn(){
        Test.startTest();
        
        Deal_Extension__c dealex = [Select Id,Name,FBE_Deal_Registration__c,FBE_Deal_EndUser_Account__c,FBE_Deal_Distributor_Account__c,FBE_Deal_FSI_Account__c,FBE_Secondary_Status__c,FBE_Deal_Registration_Status__c,
                                    FBE_Extension_Request_Status__c,FBE_PMO_Substatus__c,FBE_Deal_Reseller_Account__c from Deal_Extension__c where FBE_Extension_Request_Reason__c ='ext 2'][0]; 
        
        dealex.FBE_Extension_Request_Status__c='Submitted';
        UPDATE dealex;
        dealex.FBE_PMO_Substatus__c = 'Under Review';
        update dealex;
        
        Test.stopTest();
        
        System.assertEquals(dealex.FBE_PMO_Substatus__c ,'Under Review');
    }
    
    static testmethod void callFSIApprovalDealEXtn(){
        Test.startTest();
        
        Deal_Extension__c dealex = [Select Id,Name,FBE_Deal_Registration__c,FBE_Secondary_Status__c,FBE_Deal_Registration_Status__c,
                                    FBE_Extension_Request_Status__c,FBE_PMO_Substatus__c from Deal_Extension__c where FBE_Extension_Request_Reason__c ='ext req'][0]; 
        
        dealex.FBE_Extension_Request_Status__c='Submitted';
        UPDATE dealex;
        dealex.FBE_PMO_Substatus__c = 'Under Review';
        UPDATE dealex;
        
        Test.stopTest(); 
        
        System.assertEquals(dealex.FBE_PMO_Substatus__c, 'Under Review');
    }
    
    static testmethod void callPSPMOApprovalDealEXtn(){
        Test.startTest();
        Deal_Extension__c dealex = [Select Id,Name,FBE_Deal_Registration__c,FBE_Deal_Distributor_Account__c,FBE_Deal_FSI_Account__c,FBE_Secondary_Status__c,FBE_Deal_Registration_Status__c,
                                    FBE_Extension_Request_Status__c,FBE_PMO_Substatus__c,FBE_Deal_Reseller_Account__c from Deal_Extension__c where FBE_Extension_Request_Reason__c ='ext 2'][0]; 
                
        dealex.FBE_Extension_Request_Status__c='Submitted';
        UPDATE dealex;
        dealex.FBE_PMO_Substatus__c = 'Pending With PMO';
        update dealex;
        
        Test.stopTest();
        System.assertEquals(dealex.FBE_Extension_Request_Status__c, 'Submitted');
        
    }
    
    static testmethod void ChangeStatus(){
        Test.startTest();
        Deal_Extension__c dealex = [Select Id,FBE_Approval_Fired__c,Name,FBE_Deal_Registration__c,FBE_Deal_Distributor_Account__c,FBE_Deal_FSI_Account__c,FBE_Secondary_Status__c,FBE_Deal_Registration_Status__c,
                                    FBE_Extension_Request_Status__c,FBE_PMO_Substatus__c,FBE_Deal_Reseller_Account__c from Deal_Extension__c where FBE_Extension_Request_Reason__c ='ext 2'][0];
        
        dealex.FBE_Approval_Fired__c=true;
        update dealex;
        
        Test.stopTest();
        system.assertNotEquals(null, dealex, 'DealExtension Records not found');
    }
    
    static testmethod void ApprovalLinkNegative(){
        Test.startTest();
        Deal_Extension__c dealex = [Select Id,FBE_Approval_Fired__c,Name,FBE_Deal_Registration__c,FBE_Deal_Distributor_Account__c,FBE_Deal_FSI_Account__c,FBE_Secondary_Status__c,FBE_Deal_Registration_Status__c,
                                    FBE_Extension_Request_Status__c,FBE_PMO_Substatus__c,FBE_Deal_Reseller_Account__c from Deal_Extension__c where FBE_Extension_Request_Reason__c ='ext 2'][0];
        List<Deal_Product__c> dealp = [Select FBE_Product__r.Name,FBE_Quantity__c from Deal_Product__c where Deal_Registration_Name__r.name = 'TestDealExt EU'];
        delete dealp;
        dealex.FBE_Extension_Request_Status__c='Submitted';
        UPDATE dealex;
        dealex.FBE_PMO_Substatus__c = 'Pending With PMO';
        update dealex;
        Test.stopTest();
        system.assertNotEquals(null, dealex, 'DealExtension Records not found');

    }
    
    static testmethod void RecalorRejectStatus(){
        Test.startTest();
        List<Group> EUgrp = [Select ID from Group where Type='Queue'and Name='EU Extn Team'];
        Deal_Extension__c dealex = [Select Id,FBE_Approval_Fired__c,Name,FBE_Deal_Registration__c,FBE_Deal_Distributor_Account__c,FBE_Deal_FSI_Account__c,FBE_Secondary_Status__c,FBE_Deal_Registration_Status__c,
                                    FBE_Extension_Request_Status__c,FBE_PMO_Substatus__c,FBE_Deal_Reseller_Account__c from Deal_Extension__c where FBE_Extension_Request_Reason__c ='ext 2'][0];
        
        Approval.ProcessSubmitRequest req =  new Approval.ProcessSubmitRequest();
        
        req.setObjectId(dealex.Id);
        req.setNextApproverIds(new Id[] {EUgrp[0].Id});
        req.setProcessDefinitionNameOrId('FBEDeal_Extension_Sales_Approval_Process');
        req.setSkipEntryCriteria(true);
        
        Approval.ProcessResult result = Approval.process(req); 
        
        dealex.FBE_Secondary_Status__c='Sales Rejected';
        update dealex;
        Test.stopTest();
        System.assertEquals(dealex.FBE_Secondary_Status__c, 'Sales Rejected');
    }
    
    
    static testmethod void NoRolesEU(){
        Test.startTest();
        List<AccountTeamMember> atmm = [Select id from AccountTeamMember];
        delete atmm;
        Deal_Extension__c dealex = [Select Id,Name,FBE_Deal_Registration__c,FBE_Deal_EndUser_Account__c,FBE_Deal_Distributor_Account__c,FBE_Deal_FSI_Account__c,FBE_Secondary_Status__c,FBE_Deal_Registration_Status__c,
                                    FBE_Extension_Request_Status__c,FBE_PMO_Substatus__c,FBE_Deal_Reseller_Account__c from Deal_Extension__c where FBE_Extension_Request_Reason__c ='ext req'][0]; 
        
        dealex.FBE_Extension_Request_Status__c='Submitted';
        UPDATE dealex;
        dealex.FBE_PMO_Substatus__c = 'Under Review';
        update dealex;
        
        Test.stopTest();
        System.assertEquals(dealex.FBE_Extension_Request_Status__c, 'Submitted');
        
    }
    
    static testmethod void NoRolesEUFSI(){
        Test.startTest();
        List<AccountTeamMember> atmm = [Select id from AccountTeamMember];
        delete atmm;
        Deal_Extension__c dealex = [Select Id,Name,FBE_Deal_Registration__c,FBE_Deal_Distributor_Account__c,FBE_Deal_FSI_Account__c,FBE_Secondary_Status__c,FBE_Deal_Registration_Status__c,
                                    FBE_Extension_Request_Status__c,FBE_PMO_Substatus__c,FBE_Deal_Reseller_Account__c from Deal_Extension__c where FBE_Extension_Request_Reason__c ='ext 2'][0]; 
        
        dealex.FBE_Extension_Request_Status__c='Submitted';
        UPDATE dealex;
        dealex.FBE_PMO_Substatus__c = 'Under Review';
        update dealex;
        
        Test.stopTest();
        System.assertEquals(dealex.FBE_Extension_Request_Status__c, 'Submitted');
        
    }
    
    static testmethod void AutoRecalorRejectStatus(){
        
        Test.startTest();
        List<Group> EUgrp = [Select ID from Group where Type='Queue'and Name='EU Extn Team'];
        Deal_Extension__c dealex = [Select Id,FBE_Approval_Fired__c,Name,FBE_Deal_Registration__c,FBE_Deal_Distributor_Account__c,FBE_Deal_FSI_Account__c,FBE_Secondary_Status__c,FBE_Deal_Registration_Status__c,
                                    FBE_Extension_Request_Status__c,FBE_PMO_Substatus__c,FBE_Deal_Reseller_Account__c from Deal_Extension__c where FBE_Extension_Request_Reason__c ='ext 2'][0];
        
        
        Approval.ProcessSubmitRequest req =  new Approval.ProcessSubmitRequest();
        
        req.setObjectId(dealex.Id);
        req.setNextApproverIds(new Id[] {EUgrp[0].Id});
        req.setProcessDefinitionNameOrId('FBEDeal_Extension_Sales_Approval_Process');
        req.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req);
        
        dealex.FBE_Secondary_Status__c='Passed SLA';
        update dealex;
        
        Test.stopTest();
        
        System.assertEquals(dealex.FBE_Secondary_Status__c, 'Passed SLA');
        
    }
    
    static testmethod void updateApproveDeclineComments(){
        Deal_Extension__c dealex = [Select Id,Name,FBE_Deal_Registration__c,FBE_Deal_Distributor_Account__c,FBE_Deal_FSI_Account__c,FBE_Secondary_Status__c,FBE_Deal_Registration_Status__c,
                                    FBE_Extension_Request_Status__c,FBE_PMO_Substatus__c,FBE_Deal_Reseller_Account__c from Deal_Extension__c where FBE_Extension_Request_Reason__c ='ext 2'][0];
        Test.startTest();
        dealex.FBE_Extension_Request_Status__c='Submitted';
        update dealex;
        dealex.FBE_PMO_Substatus__c='PMO Approved';
        update dealex;
        
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(dealex.id);
        app.setProcessDefinitionNameOrId('FBE_Deal_Extension_PMO_Approval_Process');
        app.setSkipEntryCriteria(true);
        app.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        Approval.ProcessResult result = Approval.process(app);
        
        System.assertEquals('Pending', result.getInstanceStatus(),'Instance Status'+result.getInstanceStatus());
        
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        Approval.ProcessWorkitemRequest req2 =  new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req2.setWorkitemId(newWorkItemIds.get(0));
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        Test.stopTest();
        
    }
    
}