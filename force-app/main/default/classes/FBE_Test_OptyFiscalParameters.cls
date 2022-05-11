/**************
 *@ Class Name        : FBE_Test_OptyFiscalParameters
 *@ Description       : Test class to create test data and test for FBE_OptyFiscalParameters. The test class covers below scenarios :
                        1. Creates an account and associates it to a new opportunity. Script extracts fiscal parameters for newly created oppty and compares
                        it with values from Salesforce Period Object. Assert that values have been updated correctly on Opportunity after Opty creation.
                        2. Test error handling code in FBE_OptyFiscalParameters - setFiscalParameters method. 
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 01-23-2019
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script to create test data and test for FBE_OptyFiscalParameters Apex Class
 ***************/
@isTest(seeAllData = false)
public class FBE_Test_OptyFiscalParameters {
        /**************
     * @MethodName    : testOptyFiscalParams
     * @Trigger       : -
     * @Description   : This method asserts values for fiscal parameters set on Opportunity as part of Opty creation are same as values from Salesforce Period Object.
     ***************/
    static TestMethod void testOptyFiscalParams(){
        List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        Integer stringLength;
        
        system.runAs(lUser[0]){
            Test.startTest();
            
            List<Account> lAcc = FBE_Test_Utility.createAccount(1);
            insert lAcc;
            system.assertNotEquals(null, lAcc[0].id,'Null check');
            
            List<Opportunity> lOpp1 = FBE_Test_Utility.createOpportunity(1, lAcc[0].id);
            insert lOpp1;
            system.assertNotEquals(null, lOpp1[0].id,'Null check');
            
            try{
                FBE_OptyFiscalParameters.setFiscalParameters(lOpp1);
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            
            Opportunity opp = [SELECT Id,Name, CloseDate, FBE_Fiscal_Year__c, FBE_Fiscal_Quarter__c, FBE_Fiscal_Week__c, FBE_Fiscal_Period__c
                               FROM Opportunity 
                               WHERE Id =:lOpp1[0].Id];
            system.assertEquals(Date.today(), opp.CloseDate,'Date check');
            
            for(Period per : [SELECT Type, FullyQualifiedLabel FROM Period Where startDate <=: opp.CloseDate AND EndDate >=: opp.CloseDate]){
                if(per.Type == 'Year'){
                    System.assertEquals(per.FullyQualifiedLabel.substring(3), opp.FBE_Fiscal_Year__c,'Message check');
                }
                if(per.Type == 'Quarter'){
                    stringLength = per.FullyQualifiedLabel.length();
                    System.assertEquals(per.FullyQualifiedLabel.substring(0,stringLength-10), opp.FBE_Fiscal_Quarter__c,'Message check');
                    stringLength = null;
                }
                if(per.Type == 'Week'){
                    stringLength = per.FullyQualifiedLabel.length();
                    System.assertEquals(per.FullyQualifiedLabel.substring(0,stringLength-10), opp.FBE_Fiscal_Week__c,'Message check');
                    stringLength = null;
                }
                if(per.Type == 'Month'){
                    stringLength = per.FullyQualifiedLabel.length();
                    System.assertEquals(per.FullyQualifiedLabel.substring(0,stringLength-10),opp.FBE_Fiscal_Period__c,'Message check');
                    stringLength = null;
                }
            }
            Test.stopTest();
        }
    }
    
        /**************
        * @MethodName    : testOptyFiscalParamsError
        * @Trigger       : -
        * @Description   : This method tests error handling code in FBE_OptyFiscalParameters - setFiscalParameters method.
        ***************/
    
        static TestMethod void testOptyFiscalParamsError(){
        List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        Integer stringLength;
        
        system.runAs(lUser[0]){
            Test.startTest();
            
            List<Account> lAcc = FBE_Test_Utility.createAccount(1);
            insert lAcc;
            system.assertNotEquals(null, lAcc[0].id,'Null check');
            
            List<Opportunity> lOpp1 = FBE_Test_Utility.createOpportunity(1, lAcc[0].id);
            insert lOpp1;
            lOpp1[0].id = '006r0000002bMp7AAD'; //Dummy Opportunity Id so that FBE_OptyFiscalParameters errors out in Update step.
            system.assertNotEquals(null, lOpp1[0].id,'Null check');
            
            try{
                FBE_OptyFiscalParameters.setFiscalParameters(lOpp1);
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            Test.stopTest();
        }
    }
}