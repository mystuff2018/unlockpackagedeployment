@isTest(IsParallel = true)
public class DAL_PracticeTest {
    @isTest
    static void testGetBusinessSegmentByPracticeId() {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            Account account = new Account(Name = 'Test1', AccountNumber = '123');
            insert account;
            pse__Proj__c projectTemplate = MDF_ProjectTemplateFactory.start().relatedAccount(account).poNumber('4535634').deal('324325').dp('23542543').create();
            pse__Practice__c practice2 = new pse__Practice__c(Name = 'Custom Practice Test', Standard_Project_Template__c = projectTemplate.Id, Order_Association_Approval_Phase__c = 'Execute');
            // pse__Practice__c practice1 = MDF_PracticeFactory.start(projectTemplate).orderAssociationApprovalPhase('Execute').overrideName('Custom Practice Test').create();
            Item_Class__c itemClass = MDF_ItemClassFactory.start().relatedPractice(practice2).tower('ISG').create();
            List<Id> practiceList = new List<Id>{practice2.Id};
                Test.startTest();
            Map<Id, String> mapPractice = DAL_Practice.getBusinessSegmentByPracticeId(practiceList);
            Test.stopTest();
            System.assert(mapPractice.size() > 0);
        }
    }
}