@isTest(seeAllData=false)
public class FBE_Test_CreateDealTeamMemBatch {

     static TestMethod void testBatch(){
        List < Deal_Registration__c > lDeal;
        List < Account > laccnt;Set<Id> llaccnt = new Set<Id>();
         List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        List<AccountTeamMember> AccntTeamMemList= new List<AccountTeamMember>();
        system.debug('User Size:'+lUsr.size());    
        system.runAs(lUsr[0]){
        test.startTest(); 
          List < User > UsrBulk = FBE_UtilityFactory_Test.createUser('System Administrator', 5, 'ab',null);  
          laccnt = FBE_UtilityFactory_Test.createAccount(5,null); 
            laccnt[0].FBE_Partner_Type__c = 'Distributor';
             laccnt[1].FBE_Partner_Type__c = 'Reseller';
             laccnt[2].FBE_Partner_Type__c = 'System Integrator';
             laccnt[3].FBE_Partner_Type__c = 'Disty Managed';
             laccnt[4].FBE_Partner_Type__c = 'OEM';
            
            insert laccnt;
            
            llaccnt.add(laccnt[0].id);llaccnt.add(laccnt[1].id);
            for(Integer i=0;i<5;i++){               
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
            FBE_Test_Utility.createTransferDealCheckCustomSetting(false);
             lDeal = FBE_UtilityFactory_Test.createDealwithAccnt(1,laccnt[0].Id,null,null,null,null,null);
            
            lDeal[0].FBE_Account__c = laccnt[0].id;
            lDeal[0].FBE_End_User_Account__c = laccnt[0].id;
            lDeal[0].FBE_FSI_Account__c = laccnt[2].id;
            lDeal[0].FBE_Reseller_VAR_Account__c = laccnt[1].id;
            lDeal[0].FBE_Distributor_Account__c = laccnt[0].id;
            lDeal[0].FBE_OEM_Account__c = laccnt[4].id;
            
            
            insert lDeal;
            system.debug('after insert'+lDeal[0]); 
            system.assertNotEquals(null, lDeal[0].id,'Null check');         
    
            Id batchJobId = Database.executeBatch(new FBE_CreateDealTeamMemBatch('2019-12-18 01:02:03'), 200);
            
        Test.stopTest(); 
        }}
}