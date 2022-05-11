/*
 * @test OrderDisassociationTaskTest
 * @authors Pablo Dunke and Romulo Spier
 * @date 04/24/2020
 */

public with sharing class OrderDisassociationTask 
{
    public static void disassociateTasks(OrderDisassociationDataContext context) 
    {
        Map<Id, pse__Project_Task__c> mapProjectTaskToDelete = new Map<Id, pse__Project_Task__c>();
        Map<Id, pse__Project_Task__c> mapProjectTaskToUpdate = new Map<Id, pse__Project_Task__c>();

        // Refresh tasks from project
        Map<Id, List<pse__Project_Task__c>> projectWithTasks = DAL_ProjectTask.getProjectTasks(context.projectMap.keySet());

        Map<String, pse__Project_Task__c> projectTasksMap = new Map<String, pse__Project_Task__c>();

        Set<Id> setProjectTasks = new Set<Id>();
        for(List<pse__Project_Task__c> forTaskList: projectWithTasks.values())
        {
            for(pse__Project_Task__c forTask: forTaskList)
            {
                setProjectTasks.add(forTask.Id);
            }
        }

        // Retrieve the work orders
        List<WorkOrder> listWorkOrder = DAL_WorkOrder.getBySetProjectTaskId(setProjectTasks);

        // Populate mapProjectTaskIdSetWorkOrder
        Map<Id, Set<WorkOrder>> mapProjectTaskIdSetWorkOrder = new Map<Id, Set<WorkOrder>>();
        for(WorkOrder forWorkOrder: listWorkOrder) 
        {
            Set<WorkOrder> forSetWorkOrder = mapProjectTaskIdSetWorkOrder.get(forWorkOrder.Project_Task__c);

            if(forSetWorkOrder == null)
            {
                forSetWorkOrder = new Set<WorkOrder>();
            }

            forSetWorkOrder.add(forWorkOrder);
            mapProjectTaskIdSetWorkOrder.put(forWorkOrder.Project_Task__c, forSetWorkOrder);
        }

        for(Id forProjectId: context.projectOrderItemsToBeDissociateMap.keySet()) 
        {
            // Get all projects tasks and put into a map by task key
            List<pse__Project_Task__c> projectTasks = projectWithTasks.get(forProjectId);

            if(projectTasks != null)
            {
                for(pse__Project_Task__c task: projectTasks)
                {
                    // Using a key to find a task: projectId + taskName + parentTaskName
                    String taskKey = (String) task.pse__project__c + task.Name + (task.pse__Parent_Task__c != null ? (String) task.pse__Parent_Task__r.Name : '');
                    projectTasksMap.put(taskKey, task);
                }
    
                List<OrderItem> orderItemList = context.projectOrderItemsToBeDissociateMap.get(forProjectId);
    
                for(OrderItem forOrderItem: orderItemList) 
                {
                    Sku_Effort_Map__c skuEffort = context.skuEffortMapForRemainingItems.get(forOrderItem.SKU_Number__c);
    
                    if(skuEffort != null && skuEffort.SKU_Effort_Map_Entries__r != null && skuEffort.SKU_Effort_Map_Entries__r.size() > 0) 
                    {
                        List<SKU_Effort_Map_Entry__c> orderItemEntries = skuEffort.SKU_Effort_Map_Entries__r;
    
                        for(SKU_Effort_Map_Entry__c forEntry: orderItemEntries) 
                        {
                            String childTaskKey = forProjectId + forEntry.Name__c + forEntry.Phase__r.Name;
                            pse__Project_Task__c childTask = projectTasksMap.get(childTaskKey);
    
                            if(childTask != null)
                            {
                                childTask.pse__Estimated_Hours__c -= (forEntry.Estimated_Hours__c * forOrderItem.Quantity);
    
                                // The task should be updated even if the task will be deleted to rollup parent task Estimated_Hours__c
                                mapProjectTaskToUpdate.put(childTask.Id, childTask);
                                
                                // Defect 8974640
                                if(childTask.pse__Estimated_Hours__c == 0)
                                {
                                    Set<WorkOrder> workOrderFromTask = mapProjectTaskIdSetWorkOrder.get(childTask.Id);
                                    
                                    // If task has work order, don't delete it
                                    if(workOrderFromTask == null)
                                    {
                                        if(forEntry.Estimated_Hours__c == 0)
                                        {
                                            // Defect 8974640
                                            // Only delete if last entry with estimated hours equal to zero
                                            childTask.EmptyHoursCounter__c = childTask.EmptyHoursCounter__c - 1;
                                            if(childTask.EmptyHoursCounter__c == 0)
                                            {
                                                mapProjectTaskToDelete.put(childTask.Id, childTask);
                                            }
                                        }
                                        else 
                                        {
                                            mapProjectTaskToDelete.put(childTask.Id, childTask);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        context.projectTasksToDelete.putAll(mapProjectTaskToDelete);
        context.projectTasksToUpdate.putAll(mapProjectTaskToUpdate);
        
        // Retrieve the junction objects to be deleted
        context.projectTaskSkuEffortMappingEntryToDelete.putAll(DAL_ProjectTaskSKUEffortMappingEntry.getMapByProjectTaskSetId(mapProjectTaskToDelete.keySet()));
        context.projectTaskSkillToDelete.putAll(DAL_ProjectTaskSkill.getMapByProjectTaskSetId(mapProjectTaskToDelete.keySet()));
        context.orderItemTaskSkuToDelete.putAll(DAL_OrderItemSkuEffortMap.getMapByProjectTaskSetId(mapProjectTaskToDelete.keySet()));
    }
}