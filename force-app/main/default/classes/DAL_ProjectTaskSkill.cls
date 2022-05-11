/*
 * @test DAL_ProjectTaskSkillTest
 * @authors Pablo Dunke and Romulo Spier
 * @date 05/04/2020
 * @description Data access layer for the Project Task Skill Object
 */

public with sharing class DAL_ProjectTaskSkill 
{
    public static Map<Id, Project_Task_Skill__c> getMapByProjectTaskSetId(Set<Id> pSetProjectTaskId)
    {
        Map<Id, Project_Task_Skill__c> mapSkill = new Map<Id, Project_Task_Skill__c>([
            SELECT Id 
                FROM Project_Task_Skill__c 
                WHERE Project_Task__c IN: pSetProjectTaskId]);

        return mapSkill;
    }
}