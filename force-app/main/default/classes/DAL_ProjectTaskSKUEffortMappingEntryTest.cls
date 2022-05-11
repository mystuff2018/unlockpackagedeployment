/*
 * @class DAL_ProjectTaskSKUEffortMappingEntry
 * @authors Pablo Dunke and Romulo Spier
 * @date 05/04/2020
 */

@IsTest
private class DAL_ProjectTaskSKUEffortMappingEntryTest 
{
         @IsTest
         static void testGetMapByProjectTaskSetId()
         {
    //     // Create the data
         pse__Proj__c project = OPRTestFactory.createProject();

         pse__Project_Task__c projectTask = new pse__Project_Task__c();
         projectTask.pse__Project__c = project.Id;
         projectTask.Name = 'Initiate';
         insert projectTask;

         List<String> skuNumbersToMap = new List<String>{'111-1111'};
         Map<String, String> phaseByTask = new Map<String, String>();
         phaseByTask.put('Scoping', 'Initiate');
         phaseByTask.put('Planning', 'Plan');

         SKU_Effort_Map__c skuEffortMap = OPRTestFactory.createSkuEffortMap(skuNumbersToMap, 10, false, phaseByTask);

         SKU_Number__c skuNumber = [SELECT SKU_to_Effort_Mapping__c FROM SKU_Number__c WHERE SKU_Number__c = '111-1111'];
         SKU_Effort_Map_Entry__c skuEffortMapEntry = [SELECT Id FROM SKU_Effort_Map_Entry__c WHERE SKU_Effort_Map__c = :skuNumber.SKU_to_Effort_Mapping__c AND Name__c = 'Planning' LIMIT 1];
         Skill_SKU_Effort_Map_Entry__c skillSkuEffortMapEntry = [SELECT Id, Skill_Certification__c FROM Skill_SKU_Effort_Map_Entry__c WHERE SKU_Effort_Map_Entry__c = :skuEffortMapEntry.Id LIMIT 1];

         Project_Task_SKU_Effort_Mapping_Entry__c effortMapEntry = new Project_Task_SKU_Effort_Mapping_Entry__c();
         effortMapEntry.Project_Task__c = projectTask.Id;
         effortMapEntry.SKU_Effort_Mapping_Entry__c = skuEffortMapEntry.Id;
         insert effortMapEntry;

          Set<Id> setProjectTaskId = new Set<Id>();
          setProjectTaskId.add(projectTask.Id);

    //     // Action
           Test.startTest();
             Map<Id, Project_Task_SKU_Effort_Mapping_Entry__c> mapEntry = DAL_ProjectTaskSKUEffortMappingEntry.getMapByProjectTaskSetId(setProjectTaskId);
           Test.stopTest();

    //     // Assertion
         System.assertEquals(1, mapEntry.size());
     }
}