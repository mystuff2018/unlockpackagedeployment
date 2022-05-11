/**************
*@ Class Name                                                    : FBE_Test_TriggerHandler 
*@ Description                                                   : This Test class is written to cover various scenarios in the class FBE_TriggerHandler
*@ CreatedBy                                                     : Deloitte Consulting
*@ CreatedOn                                                     : 26-04-2017 [Namita Verma]
*@ Modification Log                                             : Added Test Class method for Opty Team sync updates on Opportunity Account update [Prishika Kataria]
****************/
@isTest(seeAllData = false)
public without sharing class FBE_Test_TriggerHandler {
    
    //This method is used to test the scenario for Trigger to modify the Account whenever an Account-Contact Relationship is deleted
    static TestMethod void TestAccContactRelationship() {
        List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        system.debug('User Size:'+lUsr.size());    
        system.runAs(lUsr[0]) {
            //Create an Account            
            List < Account > lAcc = FBE_Test_utility.createAccount(2);
            insert lAcc;
            system.assertNotEquals(null, lAcc[0].id,'Null check');
            system.assertNotEquals(null, lAcc[1].id,'Null check');
                        
            //Associate a Contact to the Account
            List < Contact > lCon = FBE_UtilityFactory_Test.createContact(1, lAcc[0].id);
            insert lCon;
            system.assertNotEquals(null, lCon[0].id,'Null check');
            
            //Add relationship of the Contact with Account
            AccountContactRelation newACR = new AccountContactRelation();
            newACR.AccountId = lAcc[1].Id;
            newACR.ContactId = lCon[0].Id;
            insert newACR;
            
            //Start Test to Delete the Realationship
            test.startTest();
            try {
                delete newACR;
            } catch (Exception ex) {}
            test.stopTest();
       }
    }
    
    //This TestMethod is used to cover the scenario where the Opportunity is modified when a Opportunity Team Member is Deleted
    public static testmethod void opptyTeamMemberDelete() {
       
        List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        system.debug('User Size:'+lUsr.size());    
        system.runAs(lUsr[0]) {
            Test.startTest();
            //Create an Account              
            List < Account > lAcc = FBE_Test_utility.createAccount(2);
            insert lAcc;
            system.assertNotEquals(null, lAcc[0].id,'Null check');
            //Create Account Team Member
            AccountTeamMember AccmemRec = new AccountTeamMember();
            AccmemRec.AccountId = lAcc[0].id;
            AccmemRec.UserId = lUsr[0].id;
            AccmemRec.TeamMemberRole = 'AE';
            AccmemRec.AccountAccessLevel = 'Edit';
            insert AccmemRec;
            system.assertNotEquals(null, AccmemRec.id,'Null check');
            
            //Link Oppty to Account
            List < Opportunity > lOpp = FBE_UtilityFactory_Test.createOpportunity(1, lAcc[0].id,null,null,null,null,null);
            insert lOpp;
            
            Opportunity opp = new Opportunity(Id = lOpp[0].Id);
            opp.AccountId = lAcc[1].id;
            opp.FBE_Distributor__c = lAcc[1].id;
            Update Opp;
            
            system.assertNotEquals(null, lOpp[0].id,'Null check');
            
            /*Create Oppty Team Member
            OpportunityTeamMember opmemRec = new OpportunityTeamMember();
            opmemRec.OpportunityId = lOpp[0].id;
            opmemRec.UserId = lUsr[0].id;
            opmemRec.TeamMemberRole = 'AE';
            opmemRec.OpportunityAccessLevel = 'Edit';
            insert opmemRec;
            system.assertNotEquals(null, opmemRec.id);*/
            
            //Try to delete Team Member 
            try {
                delete AccmemRec;
            } catch (Exception e) {
                system.debug(e.getMessage());
            }
            Test.stopTest();
        }
    }
    
    //This TestMethod is used to cover the scenario where a file is uploaded
    
    public static testmethod void uploadFile() {
        List < User > lUsr = FBE_UtilityFactory_Test.createUser('System Administrator', 1, 'ab',null);
        /*List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        system.debug('User Size:'+lUsr.size());    
        */
        system.runAs(lUsr[0]) {
            Test.startTest();
            string before = 'Testing base 64 encode';
            Blob beforeblob = Blob.valueOf(before);
            
            //Insert contentdocument data
            ContentVersion cv = new ContentVersion();
            cv.title = 'test content trigger';
            cv.PathOnClient = 'test_1';
            cv.VersionData = beforeblob;
            insert cv;
            system.assertNotEquals(cv.id, null, 'Null check');
            ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id =: cv.Id];
            
            //Insert ContentDocumentLink Data
            ContentDocumentLink DocLink = new ContentDocumentLink();
            DocLink.LinkedEntityId = lUsr[0].id;
            DocLink.ShareType = 'I';
            DocLink.ContentDocumentId = testContent.ContentDocumentId;
            try {
                insert DocLink;
            } catch (Exception e) {
                system.debug(e.getMessage());
            }
            Test.stopTest();
            
        }
    }
    
    public static testmethod void integrationUserInsertionTest() {
        //Profile p = [SELECT Id FROM Profile WHERE Name='];
        String prof = 'System Administrator';
        Integer NoOfUsers = 3;
        String add = 'ab';
         
        Profile p = [SELECT Id FROM Profile WHERE Name =: prof];
        List < User > userLst = new List < User > ();
        for (Integer i = 0; i < NoOfUsers; i++) {
            User u = new User(Alias = 'st' + i + add, Email = 'a' + add + i + 'trfouser@testorg.com',EmployeeNumber='123', LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'a' + add + i + 'trfouser@testorg.com',FBE_Integration_User__c = true);
            userLst.add(u);

        }
        try{
            List<Database.SaveResult> result = Database.insert(userLst,false);
            
            //System.assertEquals(System.label.IntegrationUserErrorMessage,String.valueOf(result[0].getErrors()[0].getMessage()),'Error Message check');
        } catch (Exception e) {
                system.debug(e.getMessage());
            }
        
    }
    
    public static testmethod void integrationUserInsertionTest2() {
        User updUser = new User(Id= UserInfo.getUserId() , FBE_Integration_User__c = true);
        try{
            List<Database.SaveResult> result = Database.Update(new List<User>{updUser},false);
            System.assertEquals(System.label.IntegrationUserErrorMessage,String.valueOf(result[0].getErrors()[0].getMessage()),'Error Message check');
        }catch (Exception e) {
            system.debug(e.getMessage());
        }
    }
    
    public static testmethod void integrationUser() {
        List < User > lUsr = FBE_UtilityFactory_Test.createUser('System Administrator', 3, 'ab',null);
        test.startTest();
        lUsr[0].FBE_Integration_User__c = true;
        try{
            List<Database.SaveResult> result = Database.update(lUsr,false);
            System.assertEquals(System.label.IntegrationUserErrorMessage,String.valueOf(result[0].getErrors()[0].getMessage()), 'Error Message check');
        } catch (Exception e) {
                system.debug(e.getMessage());
            }
        
        test.stopTest();
        
    }
    
    public static testmethod void integrationUserElseBlock() {
        test.startTest(); 
        List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        system.debug('User Size:'+lUsr.size());    
        if(lUsr.size()>0){
            lUsr[0].FBE_Integration_User__c = false;
            List<Database.SaveResult> resultUpd = Database.update(lUsr,false);
        }
        
        List < User > UsrBulk = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'ab',null);
        try{
            UsrBulk[0].FBE_Integration_User__c = true;
            UsrBulk[1].FBE_Integration_User__c = true;
            List<Database.SaveResult> resultNew = Database.update(UsrBulk,true);
            
        }
        catch(Exception exc){
            System.assertEquals(true,exc.getMessage().contains(System.label.IntegrationUserErrorMessage),'Error message check');
        }
        test.stopTest();
        
    }
    
    
    
    //This TestMethod is used to cover the scenario where the Account is updated on Opportunity.
    public static testmethod void OptyAccountUpdate() {
        List < Opportunity > lopty;
        List < Account > laccnt;Set<Id> llaccnt = new Set<Id>();
        List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        system.debug('User Size:'+lUsr.size());    
        system.runAs(lUsr[0]){
        test.startTest(); 
   
          laccnt = FBE_UtilityFactory_Test.createAccount(5,null); 
            insert laccnt;
             llaccnt.add(laccnt[0].id);llaccnt.add(laccnt[1].id);
    
            
//Create Account Team Member
            AccountTeamMember AccntTeamMem = new AccountTeamMember();        
            AccntTeamMem.AccountId = laccnt[0].id;
            AccntTeamMem.UserId = lUsr[0].id;
            AccntTeamMem.TeamMemberRole = 'AE';
            AccntTeamMem.AccountAccessLevel = 'Edit';
            insert AccntTeamMem;
            system.assertNotEquals(null, AccntTeamMem.id,'Null check');    

            //Create Account Team Member
            AccountTeamMember AccntTeamMem1 = new AccountTeamMember();        
            AccntTeamMem1.AccountId = laccnt[1].id;
            AccntTeamMem1.UserId = lUsr[0].id;
            AccntTeamMem1.TeamMemberRole = 'ISR';
            AccntTeamMem1.AccountAccessLevel = 'Edit';
            insert AccntTeamMem1;
            system.assertNotEquals(null, AccntTeamMem.id,'Null check');  
            
             lopty = FBE_Test_Utility.createOptywithAccounts(1, laccnt);
             
            insert lopty;
            system.assertNotEquals(null, lopty[0].id,'Null check');
           //Setting all Account Fields on Opportunity Created
            lopty[0].AccountId = laccnt[0].id;
            lopty[0].FBE_End_User__c = laccnt[2].id;
            lopty[0].FBE_FSI_Account__c = laccnt[1].id;
            lopty[0].FBE_VAR_Seller__c = laccnt[2].id;
            lopty[0].FBE_Distributor__c = laccnt[3].id;
            lopty[0].FBE_Alliance_OEM_Provider__c = laccnt[4].id;            
            update lopty[0];
            
            
            //Updating all Account fields
            lopty[0].AccountId = laccnt[1].id;
            lopty[0].FBE_End_User__c = laccnt[1].id;
            lopty[0].FBE_FSI_Account__c = laccnt[1].id;
            lopty[0].FBE_VAR_Seller__c = laccnt[1].id;
            lopty[0].FBE_Distributor__c = laccnt[1].id;
            lopty[0].FBE_Alliance_OEM_Provider__c = laccnt[1].id;
            //FBE_CheckRecursive.runOnce();
           // system.debug('run2'+FBE_CheckRecursive.runOnce());       
            update lopty[0];     
            //Create Oppty Team Member
            OpportunityTeamMember OptyTeamMem = new OpportunityTeamMember();        
            OptyTeamMem.OpportunityId = lopty[0].id;
            OptyTeamMem.UserId = lUsr[0].id;
            OptyTeamMem.TeamMemberRole = 'AE';
            OptyTeamMem.OpportunityAccessLevel = 'Edit';
            insert OptyTeamMem;
            system.assertNotEquals(null, OptyTeamMem.id,'Null check');
            
            //Try to delete Team Member 
            try {
                delete OptyTeamMem;
            } catch (Exception e) {
                system.debug(e.getMessage());
            }
            //Yogesh 12/11/2019 - Called separately to cover Delete scenario 
            try{
              FBE_OpportunityHelper obj = new FBE_OpportunityHelper();        
            obj.Sync_Opportunity_Team_with_Account_Team(lopty,llaccnt,'Delete');  
            }catch(Exception e){
				system.debug(e.getMessage());                
            }
            Test.stopTest();
        }
    }
    @isTest(SeeAllData=false)
    public static void CheckDuplicateDealTeamMember() {

        List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        system.debug('User Size:'+lUsr.size());    
        test.startTest();         
        List <Deal_Registration__c> ldealReg = FBE_UtilityFactory_Test.createDeal(1); 
        insert ldealReg; 
        System.debug('#dp insert deal');
        // Create new Deal_Team.
        FBE_Deal_Registration_Team__c dt = new FBE_Deal_Registration_Team__c();  
        dt.Deal_Registration__c =  ldealReg[0].Id;
        dt.User__c =  lUsr[0].Id;
        dt.Access_level__c = 'Read'; 
        insert dt; 
        System.debug('#dp insert deal team');
        // Create new Deal_Team.
        FBE_Deal_Registration_Team__c dt1 = new FBE_Deal_Registration_Team__c();  
        dt1.Deal_Registration__c =  ldealReg[0].Id;
        dt1.User__c =  lUsr[0].Id;
        dt1.Access_level__c = 'Read'; 
        try{
            insert dt1; 
        } catch (Exception e) {
            system.debug(e.getMessage());
        }            
        Test.stopTest();        
    }
    
    //This TestMethod is used to cover the scenario where the Account is updated on Deal.
    public static testmethod void DealAccountUpdate() {
        FBE_Test_Utility.createTransferDealCheckCustomSetting(false);       
        List < Deal_Registration__c > lDeal;
        List < Account > laccnt;Set<Id> llaccnt = new Set<Id>();
        List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        List<AccountTeamMember> AccntTeamMemList= new List<AccountTeamMember>();
        system.debug('User Size:'+lUsr.size());    
        system.runAs(lUsr[0]){
            test.startTest(); 
            List < User > UsrBulk = FBE_UtilityFactory_Test.createUser('System Administrator', 10, 'ab',null);          
            laccnt = FBE_UtilityFactory_Test.createAccount(10,null); 
            laccnt[0].FBE_Partner_Type__c = 'Distributor';
            laccnt[1].FBE_Partner_Type__c = 'Reseller';
            laccnt[2].FBE_Partner_Type__c = 'System Integrator';
            laccnt[3].FBE_Partner_Type__c = 'Disty Managed';
            laccnt[4].FBE_Partner_Type__c = 'OEM';
            
            laccnt[5].FBE_Partner_Type__c = 'Distributor';
            laccnt[6].FBE_Partner_Type__c = 'Reseller';
            laccnt[7].FBE_Partner_Type__c = 'System Integrator';
            laccnt[8].FBE_Partner_Type__c = 'Disty Managed';
            laccnt[9].FBE_Partner_Type__c = 'OEM';
            insert laccnt;
            llaccnt.add(laccnt[0].id);llaccnt.add(laccnt[1].id);
            for(Integer i=0;i<10;i++){               
                //Create Account Team Member
                AccountTeamMember AccntTeamMem = new AccountTeamMember();        
                AccntTeamMem.AccountId = laccnt[i].id;
                AccntTeamMem.UserId = UsrBulk[i].id;
                AccntTeamMem.TeamMemberRole = 'AE';
                AccntTeamMem.AccountAccessLevel = 'Edit';
                AccntTeamMemList.add(AccntTeamMem);  
                // insert AccntTeamMem;
                // system.assertNotEquals(null, AccntTeamMem.id);    
            }
            insert AccntTeamMemList;
            system.assertNotEquals(null, AccntTeamMemList[0].id,'Null check'); 
            
            lDeal = FBE_Test_Utility.createDealwithAccnt(1,laccnt);
            
            lDeal[0].FBE_Account__c = laccnt[0].id;
            lDeal[0].FBE_End_User_Account__c = laccnt[0].id;
            lDeal[0].FBE_FSI_Account__c = laccnt[2].id;
            lDeal[0].FBE_Reseller_VAR_Account__c = laccnt[1].id;
            lDeal[0].FBE_Distributor_Account__c = laccnt[0].id;
            lDeal[0].FBE_OEM_Account__c = laccnt[4].id;
            insert lDeal;
            system.debug('after insert'+lDeal[0]); 
            system.assertNotEquals(null, lDeal[0].id,'Null check');
            //Setting all Account Fields on Opportunity Created            
            //Updating all Account fields
            lDeal[0].FBE_Account__c = laccnt[5].id;
            lDeal[0].FBE_End_User_Account__c = laccnt[5].id;
            lDeal[0].FBE_FSI_Account__c = laccnt[7].id;
            lDeal[0].FBE_Reseller_VAR_Account__c = laccnt[6].id;
            lDeal[0].FBE_Distributor_Account__c = laccnt[5].id;
            lDeal[0].FBE_OEM_Account__c = laccnt[9].id;
            
            //FBE_CheckRecursive.runOnce();
            // system.debug('run2'+FBE_CheckRecursive.runOnce());       
            update lDeal[0]; 
            system.debug('after update'+lDeal[0]);   

            List<FBE_Deal_Registration_Team__c> dealTeamMem = new List<FBE_Deal_Registration_Team__c>(); 
            for(Integer i=0 ; i<3 ; i++){
                FBE_Deal_Registration_Team__c tempdaalTeam = new FBE_Deal_Registration_Team__c();        
                tempdaalTeam.Deal_Registration__c = lDeal[0].id;
                tempdaalTeam.User__c = lUsr[0].id;
                tempdaalTeam.Role__c = 'AE';
                tempdaalTeam.Access_level__c = 'Read/Write';
                if(i==0){
                    tempdaalTeam.FBE_Auto_Created__c = 'Y';
                }else{
                    tempdaalTeam.FBE_Auto_Created__c = 'N';
                }
                dealTeamMem.add(tempdaalTeam);
            }
            try{
                insert dealTeamMem;
                FBE_TriggerHandler fbt = new FBE_TriggerHandler(false,3);
                fbt.createDealTeamMemberShare(dealTeamMem);
            } catch (Exception e) {
                system.debug(e.getMessage());
            }    
            system.assertNotEquals(null, dealTeamMem[0].id,'Null check');
            
            //Try to delete Team Member 
            try {
                delete dealTeamMem;
            } catch (Exception e) {
                system.debug(e.getMessage());
            }
            //Yogesh 12/11/2019 - Called separately to cover Delete scenario 
            try{
                FBE_DealHelper obj = new FBE_DealHelper();        
                obj.Sync_Deal_Team_with_Account_Team(lDeal,llaccnt,'Delete');  
            }catch(Exception e){       
                system.debug(e.getMessage());
            }
            Test.stopTest();
        }
    }    
    
}