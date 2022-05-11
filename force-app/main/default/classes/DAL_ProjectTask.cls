/**
 * @File Name          : DAL_ProjectTask.cls
 * @Description        : Data access layer for Project Tasks related objects.
 * @Author             : Leonardo Santos | 2/18/2020
**/

public with sharing class DAL_ProjectTask {
   
    public static Map<Id, List<pse__Project_Task__c>> getProjectTasks(Set<Id> projectIds){

        Map<Id, List<pse__Project_Task__c>> tasksByProjectId = new Map<Id, List<pse__Project_Task__c>>();

        if(projectIds.size() > 0){

            // Initialize the map with empty lists
            for(Id projectId : projectIds){
                tasksByProjectId.put(projectId, new List<pse__Project_Task__c>());
            }

            List<pse__Project_Task__c> projectTasks = [
                SELECT Id, Name , pse__Project__c, pse__Estimated_Hours__c,  pse__Parent_Task__c, pse__Status__c, pse__Parent_Task__r.Name, EmptyHoursCounter__c 
                FROM pse__Project_Task__c 
                WHERE pse__Project__c IN :projectIds
            ];

            for(pse__Project_Task__c task: projectTasks){

                List<pse__Project_Task__c> taskList = tasksByProjectId.get(task.pse__Project__c);
                taskList.add(task);

                tasksByProjectId.put(task.pse__Project__c, taskList);
            }
        }
        
        return tasksByProjectId;
        
    }

    public static Map<String, Project_Task_Skill__c> getProjectTaskSkill(Set<Id> projectIds){

        // KEY: Project Id + Task Name + Skill Certification Id

        Map<String, Project_Task_Skill__c> taskSkillsByKey = new Map<String, Project_Task_Skill__c>();

        if(projectIds.size() > 0){

            List<Project_Task_Skill__c> projectTaskSkills = [
                SELECT Id, Project_Task__r.pse__Project__c, Project_Task__c, Skill_Certification__c, Project_Task__r.Name
                FROM Project_Task_Skill__c 
                WHERE Project_Task__r.pse__Project__c  IN :projectIds
            ];

            for(Project_Task_Skill__c taskSkill: projectTaskSkills){
                String key = taskSkill.Project_Task__r.pse__Project__c + taskSkill.Project_Task__r.Name + taskSkill.Skill_Certification__c;
                taskSkillsByKey.put(key, taskSkill);

            }
        }
		System.debug('taskSkillsByKey'+taskSkillsByKey);
        return taskSkillsByKey;
    }

    public static Map<Id, pse__Project_Task__c> getMapProjectTaskBySetId(Set<Id> pSetProjectTaskId)
    {
        Map<Id, pse__Project_Task__c> mapProjectTask = new Map<Id, pse__Project_Task__c>([
            SELECT Id 
                    , pse__Estimated_Hours__c
                    , pse__Parent_Task__c
                FROM pse__Project_Task__c 
                WHERE Id IN: pSetProjectTaskId]);

        return mapProjectTask;
    }
}