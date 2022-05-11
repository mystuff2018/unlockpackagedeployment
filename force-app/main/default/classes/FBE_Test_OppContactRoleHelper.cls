/*
*@ Class Name                                                    : FBE_Test_OppContactRoleHelper 
*@ Description                                                   : Test Class to create test the methods in FBE_OppContactRoleHelper 
*@ CreatedBy                                                     : Deloitte Consulting
*@ CreatedOn                                                     : 28-04-2017 [Namita Verma]
*@ Modification Log                                              :                     
*/
@isTest(seeAllData = false)
public without sharing class FBE_Test_OppContactRoleHelper {
    static testMethod void FBE_Test_OppContactRoleHelper() {
        //Create a User
        /*List < User > lUsr = FBE_Test_Utility.createUser('System Administrator', 1, 'ab');
//lUsr[0].FBE_Integration_User__c = True;
update lUsr;
system.assertNotEquals(null, lUsr[0].id);*/
        test.startTest();
        //List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        //system.debug('User Size:'+lUsr.size());  
        
        //Create an Account
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(3,null);
        lAcc[0].FBE_Partner_Type__c = 'System Integrator';//Added for test class failure fix-Abhijeet Kharatmol.
        lAcc[1].FBE_Partner_Type__c = 'Distributor';//Added for test class failure fix-Abhijeet Kharatmol.
        lAcc[2].FBE_Partner_Type__c = 'Reseller';//Added for test class failure fix-Abhijeet Kharatmol.
        system.runAs(lUsr){
            insert lAcc;
        }
        system.assertNotEquals(null, lAcc[0].id,'Null check');
        //Link Oppty to Account
        List < Opportunity > lOpp = FBE_UtilityFactory_Test.createOpportunity(1, lAcc[0].id,null,null,null,null,null);
        lOpp[0].FBE_FSI_Account__c = lAcc[0].id;//Added for test class failure fix-Abhijeet Kharatmol.
        lOpp[0].FBE_Distributor__c = lAcc[1].id;//Added for test class failure fix-Abhijeet Kharatmol.
        lOpp[0].FBE_VAR_Seller__c = lAcc[2].id;//Added for test class failure fix-Abhijeet Kharatmol.
        insert lOpp;
        system.assertNotEquals(null, lOpp[0].id,'Null check');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(lopp[0]);
        FBE_OppContactRoleHelper oh = new FBE_OppContactRoleHelper(sc);
        FBE_OppContactRoleHelper.rollupOppContactsFuture(lopp[0].id);
        oh.rollupOppContacts();
        test.stopTest();
    }
}