/*
 * @class DAL_ProjectTaskSkill
 * @authors Pablo Dunke and Romulo Spier
 * @date 05/04/2020
 */

@IsTest
private class DAL_ProjectTaskSkillTest 
{
    // @IsTest
    // static void testGetMapByProjectTaskSetId()
    // {
    //     // Create the data
    //     pse__Proj__c project = OPRTestFactory.createProject();

    //     pse__Project_Task__c projectTask = new pse__Project_Task__c();
    //     projectTask.pse__Project__c = project.Id;
    //     projectTask.Name = 'Initiate';
    //     insert projectTask;

    //     Project_Task_Skill__c projectTaskSkill = new Project_Task_Skill__c();
    //     projectTaskSkill.Project_Task__c = projectTask.Id;
    //     projectTaskSkill.Minimum_Rate__c = '1';
    //     insert projectTaskSkill;

    //     Set<Id> setProjectTaskId = new Set<Id>();
    //     setProjectTaskId.add(projectTask.Id);

    //     // Action
    //     Test.startTest();
    //     Map<Id, Project_Task_Skill__c> mapEntry = DAL_ProjectTaskSkill.getMapByProjectTaskSetId(setProjectTaskId);
    //     Test.stopTest();

    //     // Assertion
    //     System.assertEquals(1, mapEntry.size());
    // }
}