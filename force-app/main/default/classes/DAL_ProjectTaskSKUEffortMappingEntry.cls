/*
 * @test DAL_ProjectTaskSKUEffortMappingEntryTest
 * @authors Pablo Dunke and Romulo Spier
 * @date 05/04/2020
 * @description Data access layer for the Project Task SKU Effort Mapping Entry Object
 */

public with sharing class DAL_ProjectTaskSKUEffortMappingEntry 
{
    public static Map<Id, Project_Task_SKU_Effort_Mapping_Entry__c> getMapByProjectTaskSetId(Set<Id> pSetProjectTaskId)
    {
        Map<Id, Project_Task_SKU_Effort_Mapping_Entry__c> mapEntry = new Map<Id, Project_Task_SKU_Effort_Mapping_Entry__c>([
            SELECT Id 
                FROM Project_Task_SKU_Effort_Mapping_Entry__c 
                WHERE Project_Task__c IN: pSetProjectTaskId]);

        return mapEntry;
    }
}