/**************
*@ Class Name        : FBE_Test_SyncTeamHandler
*@ Description       : STORY 8358218 - FBE_SyncAccountToDealRegTeams for FBE_SyncAccountToDealRegTeams code coverage
*@ CreatedBy         : DellTeam
*@ CreatedOn         : 05-11-2020
*@ Modification Log  : [Sireesha Myla] [Mike Morgan]
***************/
@isTest 
public class FBE_SyncAccountToDealRegTeamsTest 
{
    public Static List < Opportunity > createOpportunity(Integer count,Id AccID) {
        List < Opportunity > optyList = new List < Opportunity > ();
        for (Integer i = 0; i < count; i++) {
            Opportunity oppty = new Opportunity();
            oppty.Name = 'Test_Opportunity_'+ i;
            oppty.Accountid = AccID;
            oppty.FBE_End_User__c = AccID;
            oppty.FBE_FSI_Account__c = AccID;
            oppty.FBE_VAR_Seller__c = AccID;
            oppty.FBE_Distributor__c = AccID;
            oppty.FBE_Alliance_OEM_Provider__c = AccID;
            oppty.StageName = 'Plan - 1%';
            oppty.CloseDate = System.today();
            oppty.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            oppty.FBE_Opportunity_Classification__c ='Dell Products';
            oppty.FBE_Contracting_Status__c='Funded';
            oppty.FBE_Pursuit_Type__c = 'Direct';
            optyList.add(oppty);
        }
        return optyList;
    }
    
    public static List < Deal_Registration__c > createDealwithAccnt(Integer count,List<Account> actList) {
        List < Deal_Registration__c > DealList = new List < Deal_Registration__c > ();
        for (Integer i = 0; i < count; i++) {
            Deal_Registration__c DealRecord = new Deal_Registration__c();
            DealRecord.Name = 'Test Deal'+i;           
            DealRecord.FBE_Deal_Product_Classification__c = 'Dell Products';
            // DealRecord.FBE_Price_Book_Id__c = '01sr00000004tlYAAQ';
            DealRecord.FBE_Customer__c = '65000909';
            DealRecord.FBE_Deal_Reg_Partner_Direct__c = '65000909'+i;
            DealRecord.FBE_Solution_Domain__c = 'Business Solutions';
            DealRecord.FBE_Account__c = actList[0].Id;
            DealRecord.FBE_Book_Date__c = system.today()+1;
            DealRecord.FBE_End_User_Account__c = actList[0].Id;
            DealRecord.FBE_FSI_Account__c = actList[2].Id;
            DealRecord.FBE_Reseller_VAR_Account__c = actList[1].Id;
            DealRecord.FBE_Distributor_Account__c = actList[0].Id;
            DealRecord.FBE_OEM_Account__c = actList[4].Id;
            DealList.add(DealRecord);
        }
        return DealList;
    }
    
    static testMethod void syncAccDealTeams1()
    {
        List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        List<User> lUserTeam = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'cd',null);//[Select Id from User where Alias IN('vredd','ydawane')];
        List<User> lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'ab',null);
        Set<Id> accIds = new Set<Id>();
        System.runAs(lUser[0]){                       
            List<Account> lAcc = FBE_UtilityFactory_Test.createAccount(5,null); 
            lAcc[0].FBE_Partner_Type__c = 'Distributor';
            lAcc[1].FBE_Partner_Type__c = 'Reseller';
            lAcc[2].FBE_Partner_Type__c = 'System Integrator';
            lAcc[3].FBE_Partner_Type__c = 'Disty Managed';
            lAcc[4].FBE_Partner_Type__c = 'OEM';
            INSERT lAcc;
            for(Account ac: [select Id from Account where Id in:lAcc])
                accIds.add(ac.Id); 
            
            system.assertNotEquals(null, lAcc[0].id, 'Null check');
            system.assertNotEquals(null, lAcc[1].id, 'Null check');
            
            List<AccountTeamMember> accTeamMemberList = new List<AccountTeamMember>();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[0].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[1].id,TeamMemberRole='AE',AccountId=lAcc[1].id));
            INSERT accTeamMemberList;
            
            List<Opportunity> optyList = createOpportunity(2,lAcc[0].Id);
            INSERT optyList;
            Opportunity oppty = [select Id from Opportunity where Id =:optyList[0].Id]; 
            UPDATE oppty;
            
            Test.startTest();
            FBE_Test_Utility.createTransferDealCheckCustomSetting(false);
            List<Deal_Registration__c> dealRegList= createDealwithAccnt(2, lAcc);
            INSERT dealRegList;
            Deal_Registration__c dealReg = [select Id, FBE_Related_Opportunity__r.Id, FBE_Book_Date__c from Deal_Registration__c where Id =:dealRegList[1].Id];
            dealReg.FBE_Distributor_Account__c = lAcc[0].Id;
            dealReg.FBE_Deal_Registration_Status__c = 'Approved';
            dealReg.FBE_Approval_Rejection_Reason__c = 'Test';
            dealReg.FBE_Decline_Comments__c = 'Test';
            dealReg.FBE_Funding_Source__c ='FUNDED-Prior Year Carryover';
            dealReg.FBE_Solution_Domain__c = 'Business Solutions';
            dealReg.FBE_Book_Date__c = system.today()+1;
            dealReg.Sales_Stage__c = 'Won - 100%';
            dealReg.FBE_Related_Opportunity__c = oppty.Id;
            UPDATE dealReg;
            
            List<AccountTeamMember> accTeamMemberList1 = new List<AccountTeamMember>();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[0].id,TeamMemberRole='SE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[1].id,TeamMemberRole='SE',AccountId=lAcc[1].id));
            INSERT accTeamMemberList1;
            
            try{
                FBE_SyncAccountToDealRegTeams handler = new FBE_SyncAccountToDealRegTeams();
                handler.syncDealRegTeams(accIds);                
            }catch(Exception e){
                system.debug(e.getMessage());
            }
            
            Integer dealTeamMemCount,accTeamMemCount;            
            dealTeamMemCount = [SELECT COUNT() FROM FBE_Deal_Registration_Team__c WHERE Deal_Registration__c =:dealRegList[0].Id];
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember WHERE AccountId =:lAcc[0].Id];
            //System.assertEquals(accTeamMemCount, dealTeamMemCount, 'Count check for sysncing team members');
            
            dealTeamMemCount = 0;
            accTeamMemCount = 0;
            //dealTeamMemCount = [SELECT COUNT() FROM FBE_Deal_Registration_Team__c WHERE Deal_Registration__c =:dealRegList[1].Id];
            //accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember WHERE AccountId =:accIds];
            //System.assertEquals(accTeamMemCount, dealTeamMemCount, 'Count check for sysncing team members'); 
            Test.stopTest();            
        }
    }
    
    static testMethod void syncAccDealTeams2(){
        User lUser = FBE_UtilityFactory_Test.getIntegrationUser();
        List<User> lUserTeam = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'cd',null);//[Select Id from User where Alias IN('vredd','ydawane')];
        List<User> lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'ab',null);
        Set<Id> accIds = new Set<Id>();
        System.runAs(lUser){
            Test.startTest();
            List<Account> lAcc = FBE_UtilityFactory_Test.createAccount(5,null);
            lAcc[0].FBE_Partner_Type__c = 'Distributor';
            lAcc[1].FBE_Partner_Type__c = 'Reseller';
            lAcc[2].FBE_Partner_Type__c = 'System Integrator';
            lAcc[3].FBE_Partner_Type__c = 'Disty Managed';
            lAcc[4].FBE_Partner_Type__c = 'OEM';
            INSERT lAcc;
            for(Account ac: [select Id from Account where Id in:lAcc])
                accIds.add(ac.Id);  
            system.assertNotEquals(null, lAcc[0].id, 'Null check');
            system.assertNotEquals(null, lAcc[1].id, 'Null check');
            
            List<AccountTeamMember> accTeamMemberList = new List<AccountTeamMember>();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[0].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[0].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[1].id,TeamMemberRole='AE',AccountId=lAcc[1].id));
            INSERT accTeamMemberList;
            FBE_Test_Utility.createTransferDealCheckCustomSetting(false);
            List<Deal_Registration__c> dealRegList= createDealwithAccnt(2, lAcc);
            INSERT dealRegList;
            Deal_Registration__c dealReg = [select Id,FBE_Account__c,FBE_Distributor_Account__c,FBE_FSI_Account__c from Deal_Registration__c where Id =:dealRegList[1].Id];
            dealReg.FBE_Distributor_Account__c = lAcc[0].Id;
            dealReg.FBE_Deal_Registration_Status__c = 'Submitted';
            UPDATE dealReg;
            
            List<FBE_Deal_Registration_Team__c> dealTeamList = new List<FBE_Deal_Registration_Team__c>();
            dealTeamList.add(new FBE_Deal_Registration_Team__c(Deal_Registration__c = dealRegList[1].Id,User__c = lUserTeam[1].Id,Role__c = 'SE',Access_level__c = 'Read/Write', FBE_Auto_Created__c = 'N'));
            //dealTeamList.add(new FBE_Deal_Registration_Team__c(Deal_Registration__c = dealRegList[1].Id,User__c = lUsrNonIntegration[0].Id,Role__c = 'AE',Access_level__c = 'Read/Write', FBE_Auto_Created__c = 'Y'));
            //dealTeamList.add(new FBE_Deal_Registration_Team__c(Deal_Registration__c = dealRegList[2].Id,User__c = lUsrNonIntegration[1].Id,Role__c = 'AE',Access_level__c = 'Read/Write', FBE_Auto_Created__c = 'Y'));
            
            try{
                FBE_SyncAccountToDealRegTeams handler = new FBE_SyncAccountToDealRegTeams();
                handler.syncDealRegTeams(accIds);                
            }catch(Exception e){
                system.debug(e.getMessage());
            }
            
            Integer dealTeamMemCount,accTeamMemCount;            
            dealTeamMemCount = [SELECT COUNT() FROM FBE_Deal_Registration_Team__c WHERE Deal_Registration__c =:dealRegList[0].Id];
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember WHERE AccountId =:lAcc[0].Id];
            //System.assertEquals(accTeamMemCount, dealTeamMemCount, 'Count check for sysncing team members');
            
            dealTeamMemCount = 0;
            accTeamMemCount = 0;
            //dealTeamMemCount = [SELECT COUNT() FROM FBE_Deal_Registration_Team__c WHERE Deal_Registration__c =:dealRegList[1].Id];
            //accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember WHERE AccountId =:accIds];
            //System.assertEquals(accTeamMemCount, dealTeamMemCount, 'Count check for sysncing team members'); 
            
            Test.stopTest();
        }        
    }
    
    static testMethod void syncAccDealTeams3(){
        User lUser = FBE_UtilityFactory_Test.getIntegrationUser();
        List<User> lUserTeam = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'cd',null);//[Select Id from User where Alias IN('vredd','ydawane')];
        List<User> lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'ab',null);
        Set<Id> accIds = new Set<Id>();
        System.runAs(lUser){
            Test.startTest();
            List<Account> lAcc = FBE_UtilityFactory_Test.createAccount(5,null);
            lAcc[0].FBE_Partner_Type__c = 'Distributor';
            lAcc[1].FBE_Partner_Type__c = 'Reseller';
            lAcc[2].FBE_Partner_Type__c = 'System Integrator';
            lAcc[3].FBE_Partner_Type__c = 'Disty Managed';
            lAcc[4].FBE_Partner_Type__c = 'OEM';
            INSERT lAcc;
            for(Account ac: [select Id from Account where Id in:lAcc])
                accIds.add(ac.Id);  
            system.assertNotEquals(null, lAcc[0].id, 'Null check');
            system.assertNotEquals(null, lAcc[1].id, 'Null check');
            
            List<AccountTeamMember> accTeamMemberList = new List<AccountTeamMember>();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[0].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[0].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[1].id,TeamMemberRole='AE',AccountId=lAcc[1].id));
            INSERT accTeamMemberList;
            FBE_Test_Utility.createTransferDealCheckCustomSetting(false);
            List<Deal_Registration__c> dealRegList= createDealwithAccnt(2, lAcc);
            INSERT dealRegList;
            Deal_Registration__c dealReg = [select Id,FBE_Account__c,FBE_Distributor_Account__c,FBE_FSI_Account__c from Deal_Registration__c where Id =:dealRegList[1].Id];
            dealReg.FBE_Distributor_Account__c = lAcc[0].Id;
            dealReg.FBE_Deal_Registration_Status__c = 'Hold for Review';
            UPDATE dealReg;
            
            List<FBE_Deal_Registration_Team__c> dealTeamList = new List<FBE_Deal_Registration_Team__c>();
            dealTeamList.add(new FBE_Deal_Registration_Team__c(Deal_Registration__c = dealRegList[1].Id,User__c = lUserTeam[1].Id,Role__c = 'AE',Access_level__c = 'Read/Write', FBE_Auto_Created__c = 'Y'));
            //dealTeamList.add(new FBE_Deal_Registration_Team__c(Deal_Registration__c = dealRegList[1].Id,User__c = lUsrNonIntegration[0].Id,Role__c = 'AE',Access_level__c = 'Read/Write', FBE_Auto_Created__c = 'Y'));
            //dealTeamList.add(new FBE_Deal_Registration_Team__c(Deal_Registration__c = dealRegList[2].Id,User__c = lUsrNonIntegration[1].Id,Role__c = 'AE',Access_level__c = 'Read/Write', FBE_Auto_Created__c = 'Y'));
            INSERT dealTeamList;
            
            try{
                FBE_SyncAccountToDealRegTeams handler = new FBE_SyncAccountToDealRegTeams();
                handler.syncDealRegTeams(accIds);                
            }catch(Exception e){
                system.debug(e.getMessage());
            }                        
            Integer dealTeamMemCount,accTeamMemCount;            
            dealTeamMemCount = [SELECT COUNT() FROM FBE_Deal_Registration_Team__c WHERE Deal_Registration__c =:dealRegList[0].Id];
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember WHERE AccountId =:lAcc[0].Id];
            //System.assertEquals(accTeamMemCount, dealTeamMemCount, 'Count check for sysncing team members');
            
            dealTeamMemCount = 0;
            accTeamMemCount = 0;
            dealTeamMemCount = [SELECT COUNT() FROM FBE_Deal_Registration_Team__c WHERE Deal_Registration__c =:dealRegList[1].Id];
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember WHERE AccountId =:accIds];
            //System.assertEquals(accTeamMemCount, dealTeamMemCount, 'Count check for sysncing team members');                         
            Test.stopTest();
        }        
    }
    
    static testMethod void syncAccDealTeams4(){
        User lUser = FBE_UtilityFactory_Test.getIntegrationUser();
        List<User> lUserTeam = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'cd',null);//[Select Id from User where Alias IN('vredd','ydawane')];
        List<User> lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'ab',null);
        Set<Id> accIds = new Set<Id>();
        System.runAs(lUser){
            Test.startTest();
            List<Account> lAcc = FBE_UtilityFactory_Test.createAccount(5,null); 
            lAcc[0].FBE_Partner_Type__c = 'Distributor';
            lAcc[1].FBE_Partner_Type__c = 'Reseller';
            lAcc[2].FBE_Partner_Type__c = 'System Integrator';
            lAcc[3].FBE_Partner_Type__c = 'Disty Managed';
            lAcc[4].FBE_Partner_Type__c = 'OEM';
            INSERT lAcc;
            for(Account ac: [select Id from Account where Id in:lAcc])
                accIds.add(ac.Id);  
            system.assertNotEquals(null, lAcc[0].id, 'Null check');
            system.assertNotEquals(null, lAcc[1].id, 'Null check');
            
            List<AccountTeamMember> accTeamMemberList = new List<AccountTeamMember>();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[0].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[0].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[1].id,TeamMemberRole='AE',AccountId=lAcc[1].id));
            INSERT accTeamMemberList;
            FBE_Test_Utility.createTransferDealCheckCustomSetting(false);
            List<Deal_Registration__c> dealRegList= createDealwithAccnt(2, lAcc);
            INSERT dealRegList;
            Deal_Registration__c dealReg = [select Id,FBE_Account__c,FBE_Distributor_Account__c,FBE_FSI_Account__c from Deal_Registration__c where Id =:dealRegList[1].Id];
            dealReg.FBE_Distributor_Account__c = lAcc[0].Id;
            dealReg.FBE_Declined_Reason__c = 'Not enough information';
            dealReg.FBE_Decline_Comments__c = 'Test';
            dealReg.FBE_Deal_Registration_Status__c = 'Rejected';
            UPDATE dealReg;
            
            List<FBE_Deal_Registration_Team__c> dealTeamList = new List<FBE_Deal_Registration_Team__c>();
            dealTeamList.add(new FBE_Deal_Registration_Team__c(Deal_Registration__c = dealRegList[1].Id,User__c = lUserTeam[1].Id,Role__c = 'AE',Access_level__c = 'Read/Write', FBE_Auto_Created__c = 'Y'));
            //dealTeamList.add(new FBE_Deal_Registration_Team__c(Deal_Registration__c = dealRegList[1].Id,User__c = lUsrNonIntegration[0].Id,Role__c = 'AE',Access_level__c = 'Read/Write', FBE_Auto_Created__c = 'Y'));
            //dealTeamList.add(new FBE_Deal_Registration_Team__c(Deal_Registration__c = dealRegList[2].Id,User__c = lUsrNonIntegration[1].Id,Role__c = 'AE',Access_level__c = 'Read/Write', FBE_Auto_Created__c = 'Y'));
            INSERT dealTeamList;
            
            try{
                FBE_SyncAccountToDealRegTeams handler = new FBE_SyncAccountToDealRegTeams();
                handler.syncDealRegTeams(accIds);                
            }catch(Exception e){
                system.debug(e.getMessage());
            }
                        
            Integer dealTeamMemCount,accTeamMemCount;            
            dealTeamMemCount = [SELECT COUNT() FROM FBE_Deal_Registration_Team__c WHERE Deal_Registration__c =:dealRegList[0].Id];
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember WHERE AccountId =:lAcc[0].Id];
            //System.assertEquals(accTeamMemCount, dealTeamMemCount, 'Count check for sysncing team members');
            
            dealTeamMemCount = 0;
            accTeamMemCount = 0;
            dealTeamMemCount = [SELECT COUNT() FROM FBE_Deal_Registration_Team__c WHERE Deal_Registration__c =:dealRegList[1].Id];
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember WHERE AccountId =:accIds];
            //System.assertEquals(accTeamMemCount, dealTeamMemCount, 'Count check for sysncing team members'); 
                        
            Test.stopTest();
        }        
    }
    
    static testMethod void syncAccDealTeams5(){
        User lUser = FBE_UtilityFactory_Test.getIntegrationUser();
        List<User> lUserTeam = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'cd',null);//[Select Id from User where Alias IN('vredd','ydawane')];
        List<User> lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'ab',null);
        Set<Id> accIds = new Set<Id>();
        System.runAs(lUser){
            Test.startTest();
            List<Account> lAcc = FBE_UtilityFactory_Test.createAccount(5,null); 
            lAcc[0].FBE_Partner_Type__c = 'Distributor';
            lAcc[1].FBE_Partner_Type__c = 'Reseller';
            lAcc[2].FBE_Partner_Type__c = 'System Integrator';
            lAcc[3].FBE_Partner_Type__c = 'Disty Managed';
            lAcc[4].FBE_Partner_Type__c = 'OEM';
            INSERT lAcc;
            for(Account ac: [select Id from Account where Id in:lAcc])
                accIds.add(ac.Id);  
            system.assertNotEquals(null, lAcc[0].id, 'Null check');
            system.assertNotEquals(null, lAcc[1].id, 'Null check');
            
            List<AccountTeamMember> accTeamMemberList = new List<AccountTeamMember>();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[0].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[0].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[1].id,TeamMemberRole='AE',AccountId=lAcc[1].id));
            INSERT accTeamMemberList;
            FBE_Test_Utility.createTransferDealCheckCustomSetting(false);
            List<Deal_Registration__c> dealRegList= createDealwithAccnt(2, lAcc);
            INSERT dealRegList;
            Deal_Registration__c dealReg = [select Id,FBE_Account__c,FBE_Distributor_Account__c,FBE_FSI_Account__c from Deal_Registration__c where Id =:dealRegList[1].Id];
            dealReg.FBE_Distributor_Account__c = lAcc[0].Id;
            dealReg.FBE_Deal_Registration_Status__c = 'Returned';
            UPDATE dealReg;
            
            List<FBE_Deal_Registration_Team__c> dealTeamList = new List<FBE_Deal_Registration_Team__c>();
            dealTeamList.add(new FBE_Deal_Registration_Team__c(Deal_Registration__c = dealRegList[1].Id,User__c = lUserTeam[1].Id,Role__c = 'AE',Access_level__c = 'Read/Write', FBE_Auto_Created__c = 'Y'));
            //dealTeamList.add(new FBE_Deal_Registration_Team__c(Deal_Registration__c = dealRegList[1].Id,User__c = lUsrNonIntegration[0].Id,Role__c = 'AE',Access_level__c = 'Read/Write', FBE_Auto_Created__c = 'Y'));
            //dealTeamList.add(new FBE_Deal_Registration_Team__c(Deal_Registration__c = dealRegList[2].Id,User__c = lUsrNonIntegration[1].Id,Role__c = 'AE',Access_level__c = 'Read/Write', FBE_Auto_Created__c = 'Y'));
            INSERT dealTeamList;
            
            try{
                FBE_SyncAccountToDealRegTeams handler = new FBE_SyncAccountToDealRegTeams();
                handler.syncDealRegTeams(accIds);
                
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            
            Integer dealTeamMemCount,accTeamMemCount;            
            dealTeamMemCount = [SELECT COUNT() FROM FBE_Deal_Registration_Team__c WHERE Deal_Registration__c =:dealRegList[0].Id];
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember WHERE AccountId =:lAcc[0].Id];
            //System.assertEquals(accTeamMemCount, dealTeamMemCount, 'Count check for sysncing team members');
            
            dealTeamMemCount = 0;
            accTeamMemCount = 0;
            dealTeamMemCount = [SELECT COUNT() FROM FBE_Deal_Registration_Team__c WHERE Deal_Registration__c =:dealRegList[1].Id];
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember WHERE AccountId =:accIds];
            //System.assertEquals(accTeamMemCount, dealTeamMemCount, 'Count check for sysncing team members'); 
                        
            Test.stopTest();
        }        
    }    
}