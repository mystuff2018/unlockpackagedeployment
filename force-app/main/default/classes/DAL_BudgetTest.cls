@isTest(IsParallel = true)
public class DAL_BudgetTest {
    
    @isTest
    static void getBudgetsByProjectIds_Success() {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            Account account = new Account(Name = 'Test Account', BUID__c = '11', CCN__c = '	US_42');
            insert account;
            
            Set<Id> projectIds = new Set<Id>();
            
            pse__proj__c projectTemplate = OPRTestFactory.createProjectTemplate(account.Id, '54543', '65464', '4553');
            insert projectTemplate;
            pse__Practice__c practice = new pse__Practice__c(Name = 'HES', Standard_Project_Template__c = projectTemplate.Id, Default_Duration__c = 30);
            insert practice; 
            
            pse__Proj__c project = new pse__Proj__c(
                Name = 'Project Test',
                pse__Project_Phase__c = 'Setup',
                pse__practice__c = practice.Id,
                pse__End_Date__c = Date.Today().addDays(30),
                pse__Start_Date__c = Date.Today(),
                pse__Account__c = account.Id,
                pse__Is_Active__c = true
            );
            insert project;
            projectIds.add(project.Id);
            System.debug('projectIds'+projectIds);
            
            
            pse__Budget__c budget1 = new pse__Budget__c(pse__Type__c = 'As Sold Revenue', pse__Project__c = project.Id);
            System.debug('budget1'+budget1);
            pse__Budget__c budget2 = new pse__Budget__c(pse__Type__c = 'As Sold Cost', pse__Project__c = project.Id);
            insert new List<pse__Budget__c>{budget1, budget2};
                
                
                Test.startTest();
            Map<Id, List<pse__Budget__c>> budgetsByProjectId = DAL_Budget.getBudgetsByProjectIds(new Set<Id> {project.Id});
            Test.stopTest();
            System.assertEquals(true, budgetsByProjectId.containsKey(project.Id), 'Map should contains key of project Id');
            System.assertEquals(2, budgetsByProjectId.get(project.Id).size(), 'List of budget from map should have 2 budgets');
        }
    }
}