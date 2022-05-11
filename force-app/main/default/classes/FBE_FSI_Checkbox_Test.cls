@isTest
public class FBE_FSI_Checkbox_Test {
    static TestMethod void FBE_FSI_Checkbox_Test_AccountNotNull() {
        //List < User > UserCreate = [Select Id from User where FBE_Integration_User__c = true];
        User UserCreate = FBE_UtilityFactory_Test.getIntegrationUser();
        List < User > lUserTeam = FBE_UtilityFactory_Test.createUser('System Administrator', 3, 'ab',null);


        Test.startTest();
        system.runAs(UserCreate) {
            List < Account > a = FBE_UtilityFactory_Test.createAccount(5,null);
            insert a;
            List < Opportunity > Opr = FBE_UtilityFactory_Test.createOpportunity(1, a[0].id,null,null,null,null,null);
            Opr[0].ownerid = lUserTeam[0].id;
            insert Opr;
            
            UPDATE new Opportunity(Id=Opr[0].Id , FBE_Win_Loss_Reason__c= 'Pricing/ROI' ,FBE_Win_Loss_Summary__c ='TestSummary', stageName='Lost - 0%');
            System.debug('Opr[0].stageName : '+[SELECT stageName from Opportunity WHERE Id =: Opr[0].Id ].stageName);
            
            try {
                FBE_FSI_Checkbox ffc = new FBE_FSI_Checkbox();
                Database.executeBatch(ffc, 20);
            } catch (Exception e) {
                system.debug(e.getMessage());
            }
        }
        Test.stopTest();
    }
    
}