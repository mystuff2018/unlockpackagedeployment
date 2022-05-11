@isTest
public class ProjectUtilsTest {
    static testmethod void updateGroupTest() {
        user u1 = TestDataUtility.getUser('Testfinancialforceadmin@dellTest.com');
        System.runAs(u1){
            //Create region
            pse__Region__c region = TestDataUtility.getRegion(True);
            pse__Grp__c grp = new pse__Grp__c();
            grp.name ='Americas';
            insert grp;
            //Create Account
            Account acc = TestDataUtility.createAccounts(1,True)[0];
            Contact con = TestDataUtility.createContacts(1,acc.id,false,true)[0];
            con.pse__Salesforce_User__c = u1.id;
            con.pse__Region__c = region.id;
            con.pse__Resource_Role__c = 'Project Manager Analyst';
            con.pse__Is_Resource__c = true;
            con.pse__Group__c = grp.Id;
            insert con;
            
            Map<Id, pse__Proj__c> oldRecords = new Map<Id, pse__Proj__c>();
            List<pse__Proj__c> newRecords = new List<pse__Proj__c>();
            pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,false);
            proj.pse__Billing_Type__c = 'Time and Materials';
            proj.Deal_Type__c = 'Custom';
            proj.FBE_IDS_Residency__c = true;
            proj.pse__Project_Manager__c = con.id;
            insert proj;
            
            Test.startTest();
            proj.PDM_Resource__c=con.Id;
            update proj;
            ProjectUtils.updateGroup(oldRecords,newRecords);
            Test.stopTest();
        }
    }
}