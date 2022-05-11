/*
*@ Class Name                                                    : FBE_Test_MultiSelectServerController 
*@ Description                                                   : Test Class to create test the methods in FBE_Test_MultiSelectServerController 
*@ CreatedBy                                                     : Deloitte Consulting
*@ CreatedOn                                                     : 25-07-2017 [Namita Verma]
*@ Modification Log                                              :                     
*/
@isTest(seeAllData = False)
public without sharing class FBE_Test_MultiSelectServerController {
    static testMethod void FBE_Test_MultiSelectServerController() {
        //Create a User
        /*List < User > lUsr = FBE_Test_Utility.createUser('System Administrator', 1, 'ab');
lUsr[0].FBE_Integration_User__c = True;
update lUsr;
system.assertNotEquals(null, lUsr[0].id);
*/
        test.startTest();
        List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        system.debug('User Size:'+lUsr.size());    
        //Create an Account
        
        List < Account > lAcc = FBE_Test_utility.createAccount(3);
        lAcc[0].FBE_Partner_Type__c = 'System Integrator';//Added for test class failure fix-Abhijeet Kharatmol.
        lAcc[1].FBE_Partner_Type__c = 'Distributor';//Added for test class failure fix-Abhijeet Kharatmol.
        lAcc[2].FBE_Partner_Type__c = 'Reseller';//Added for test class failure fix-Abhijeet Kharatmol.
        system.runAs(lUsr[0]){
            insert lAcc;
        }
        system.assertNotEquals(null, lAcc[0].id,'Null Check');
        
        //Create Products
        List <Product2> lProd = FBE_Test_Utility.createProducts(3);
        lProd[0].Name = 'DCS 7150';
        lProd[1].Name = 'B1165NFW';
        lProd[2].Name = 'pqr';
        insert lProd;
        system.assertNotEquals(null, lProd[0].id,'Null Check');
        
        //Create Opportunity
        List < Opportunity > lOpp = FBE_Test_Utility.createOpportunity(1, lAcc[0].id);
        lOpp[0].FBE_FSI_Account__c = lAcc[0].id;//Added for test class failure fix-Abhijeet Kharatmol.
        lOpp[0].FBE_Distributor__c = lAcc[1].id;//Added for test class failure fix-Abhijeet Kharatmol.
        lOpp[0].FBE_VAR_Seller__c = lAcc[2].id;//Added for test class failure fix-Abhijeet Kharatmol.
        insert lOpp;
        system.assertNotEquals(null, lOpp[0].id,'Null Check');
        
        /*Create Opportunity Line Item
List <OpportunityLineItem> lOppProducts = FBE_Test_Utility.createOpptyProducts(1, lOpp[0].id, lProd[0].id);
insert lOppProducts; 
system.assertNotEquals(null, lOppProducts[0].id);*/
        
        //Create Task from Oppty
        List< Task > lTask = FBE_Test_Utility.createTask(1, lOpp[0].id);
        lTask[0].FBE_Task_Products__c = 'abc; pqr';
        insert lTask;
        List< Task > lTask1 = FBE_Test_Utility.createTask(1, lOpp[0].id);
        
        FBE_MultiSelectServerCloneController.getAllAvailValues(lTask[0].id);
        FBE_MultiSelectServerCloneController.getAllSelectValues(lTask[0].id);
        String[] s = new String[]{'abc','pqr'};
            String[] es = new String[]{};
                FBE_MultiSelectServerCloneController.updateTaskRec(s, lTask[0].id);
        FBE_MultiSelectServerCloneController.updateTaskRec(es, lTask[0].id);
        test.stopTest();
    }
}