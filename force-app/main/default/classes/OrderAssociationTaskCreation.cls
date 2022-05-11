/**
 * @File Name          : OrderAssociationTaskCreation.cls
 * @Description        : Create top tasks, child tasks and junction objects into project
 * @Author             : Leonardo Santos | 2/18/2020
 * @Modification Log   : [Deloitte Consulting] - Abhishek Kawle 12/07/2020 - Defect #9727468: Added new method - updateTaskStartEndDateToNull
**/

public with sharing class OrderAssociationTaskCreation {

    private class ProjectTaskSkill{
        private String taskName;
        private Id skuEntryId;
        private Id projectId;
        private pse__Project_Task__c task;
        private Decimal skuQuantity;

        private ProjectTaskSkill(String taskName, Id skuEntryId, Id projectId, pse__Project_Task__c task, Decimal skuQuantity){
            this.taskName = taskName;
            this.skuEntryId = skuEntryId;
            this.projectId = projectId;
            this.task = task;
            this.skuQuantity = skuQuantity;
        }
    }

    private class OrderItemTaskSkuMap{

        private Id orderItem;
        private Id skuEffortMap;
        private pse__Project_Task__c task;

        private OrderItemTaskSkuMap(Id orderItem, Id skuEffortMap, pse__Project_Task__c task){
            this.orderItem = orderItem;
            this.skuEffortMap = skuEffortMap;
            this.task = task;
        }
    }

    private class ProjectTask{

        private Boolean isTopTask;
        private pse__Project_Task__c task;
        private pse__Project_Task__c parentTask;

        private ProjectTask(pse__Project_Task__c task, pse__Project_Task__c parentTask, Boolean isTopTask){
            this.task = task;
            this.parentTask = parentTask;
            this.isTopTask = isTopTask;
        }
    }

    /**
    * @description Create top and child tasks into project 
    * @author Leonardo Santos | 2/18/2020 
    * @param context 
    * @return void 
    **/
    public static void createTasks(OrderAssociationDataContext context){

        // Initialize context
        context.projectWithTasks = new Map<Id, List<pse__Project_Task__c>>();

        // Refresh tasks from project
        context.projectWithTasks = DAL_ProjectTask.getProjectTasks(context.projectMap.keySet());
        
        Map<Id, List<SKU_Effort_Map_Entry__c>> allEntries = new Map<Id, List<SKU_Effort_Map_Entry__c>>();
        Map<String, pse__Project_Task__c> projectTasksMap = new Map<String, pse__Project_Task__c>();
        Map<String, ProjectTask> allProjectTasks = new Map<String, ProjectTask>();
        List<ProjectTaskSkill> projectTaskSkillList = new List<ProjectTaskSkill>();
        List<OrderItemTaskSkuMap> orderItemSkuMapList = new List<OrderItemTaskSkuMap>();
        List<pse__Project_Task__c> projectTasksNullifyList = new List<pse__Project_Task__c>();

        for(Id projectId: context.projectMap.keySet()){

            // Get all order items from orders of project
            List<OrderItem> projectOrderItems = context.projectWithAllOrderItems.get(projectId);	
            if(projectOrderItems.size() == 0 || projectOrderItems == null){
                continue;
            }

            // Get all projects tasksand put into a map by task key
            List<pse__Project_Task__c> projectTasks = context.projectWithTasks.get(projectId);

            for(pse__Project_Task__c task: projectTasks){
                // Using a key to find a task: projectId + taskName + parentTaskName
                String taskKey = (String)task.pse__project__c + task.Name + (task.pse__Parent_Task__c != null ? (String)task.pse__Parent_Task__r.Name : '');
				system.debug('taskKey ----'+taskKey);
                projectTasksMap.put(taskKey, task);
            }
            

            List<SKU_Effort_Map_Entry__c> projectEntries = new List<SKU_Effort_Map_Entry__c>();
            
            for (OrderItem orderItem : projectOrderItems) {

                // Defect 8718064
                if(context.orderItemsToBeAssociated != null && context.orderItemsToBeAssociated.keySet() != null)
                {
                    if(context.orderItemsToBeAssociated.keySet().contains(orderItem.Id))
                    {
                        if(context.skuEffortMap != null) {	

                            Sku_Effort_Map__c skuEffort = context.skuEffortMap.get(orderItem.SKU_Number__c);

                            if (skuEffort != null && skuEffort.SKU_Effort_Map_Entries__r != null && skuEffort.SKU_Effort_Map_Entries__r.size() > 0) {

                                List<SKU_Effort_Map_Entry__c> orderItemEntries = skuEffort.SKU_Effort_Map_Entries__r;
                                projectEntries.addAll(orderItemEntries);  
                                // Create a map list orderItem by entry id
                                for (SKU_Effort_Map_Entry__c entry : orderItemEntries) {
                                    
                                    // Key for top task is: projectId + taskName
                                    // >>>> Top task
                                    String topTaskKey = projectId + entry.Phase__r.Name;
                                    pse__Project_Task__c possibleTopTask = projectTasksMap.get(topTaskKey);
                                    ProjectTask topProjTask;
                                    if(possibleTopTask != null ){
                                        // Top task already exists
                                        topProjTask = new ProjectTask(possibleTopTask, null, true);
                                    }
                                    else{
                                        // Create new top task
                                        pse__Project_Task__c newTopTask = new pse__Project_Task__c();
                                        newTopTask.Name = entry.Phase__r.Name;
                                        newTopTask.pse__project__c = projectId;

                                        topProjTask = new ProjectTask(newTopTask, null, true);
                                        
                                        projectTasksMap.put(topTaskKey, newTopTask);
                                    }
                                    allProjectTasks.put(topTaskKey, topProjTask);

                                    // Key for child task is: projectId + taskName + phaseName
                                    // >>>> Child task
                                    String childTaskKey = projectId + entry.Name__c + entry.Phase__r.Name;
                                    pse__Project_Task__c possibleChildTask = projectTasksMap.get(childTaskKey);
                                    ProjectTask childProjTask;
                                    if(possibleChildTask != null ){ 
                                        // Defect 8908033 (1/2)
                                        Decimal hours = entry.Estimated_Hours__c * orderItem.Quantity;
                                        if(orderItem.Unit_Selling_Price_USD__c < 0 && orderItem.SKU_Cost__c < 0 && orderItem.Quantity > 0)
                                            hours = hours * -1;				
                                        // >> Add hours to existing task
                                        possibleChildTask.pse__Estimated_Hours__c += hours;	
                                        // Defect 8974640 (1/2)
                                        if(hours == 0)
                                        {
                                            Decimal counter = possibleChildTask.EmptyHoursCounter__c;
                                            possibleChildTask.EmptyHoursCounter__c = (counter != null) ? counter + 1 : 1;
                                        }

                                        childProjTask = new ProjectTask(possibleChildTask, topProjTask.task, false);
                                    }
                                    else{
                                        // >> Create new child task
                                        pse__Project_Task__c newChildTask = new pse__Project_Task__c();
                                        newChildTask.Name = entry.Name__c;
                                        newChildTask.pse__project__c = projectId;

                                        // Defect 8908033 (2/2)
                                        Decimal hours = entry.Estimated_Hours__c * orderItem.Quantity; //10
                                        if(orderItem.Unit_Selling_Price_USD__c < 0 && orderItem.SKU_Cost__c < 0 && orderItem.Quantity > 0)
                                            hours = hours * -1;

                                        // Defect 8974640 (2/2)
                                        if(hours == 0)
                                            newChildTask.EmptyHoursCounter__c = 1;

                                        newChildTask.pse__Estimated_Hours__c = hours; //10
                                        childProjTask = new ProjectTask(newChildTask, topProjTask.task, false);
                                        projectTasksMap.put(childTaskKey, newChildTask);
                                    }
                                    allProjectTasks.put(childTaskKey, childProjTask);

                                    // Wrapper object to create project task skill
                                    ProjectTaskSkill projectTaskSkill = new ProjectTaskSkill(
                                        entry.Name__c,
                                        entry.Id,
                                        projectId,
                                        childProjTask.task,
                                        orderItem.Quantity
                                    );
                                    projectTaskSkillList.add(projectTaskSkill);
                                    System.debug('projectTaskSkill'+projectTaskSkill);
                                    // Wrapper object to create order item task sku map
                                    OrderItemTaskSkuMap orderItemSkuMap = new OrderItemTaskSkuMap(
                                        orderItem.Id,
                                        skuEffort.Id,
                                        childProjTask.task
                                    );
                                    orderItemSkuMapList.add(orderItemSkuMap);
                                }
                            }
                        }
                    }
                }
            }

            allEntries.put(projectId, projectEntries);

            // Update the start and end date to all tasks
            pse__Proj__c project = context.projectMap.get(projectId);
            allProjectTasks = updateTaskStartEndDate(allProjectTasks, project);
            projectTasksNullifyList = updateTaskStartEndDateToNull(projectTasksMap, project, projectEntries);
        }

        // First, persist top tasks to get Ids
        List<pse__Project_Task__c> topTasks = createTopTaskList(allProjectTasks, projectTasksNullifyList);
          upsert topTasks;  
        
        // Then, attach child task with top tasks
        List<pse__Project_Task__c> childTasks = createChildTaskList(allProjectTasks);
            upsert childTasks; 
        
        // Alltasks
        List<pse__Project_Task__c> allTasks = new List<pse__Project_Task__c>();
        allTasks.addAll(topTasks);
        allTasks.addAll(childTasks);

        // Refresh the map into context
        for(pse__Project_Task__c task: allTasks){
            
            Set<pse__Project_Task__c> contextTasks = new Set<pse__Project_Task__c>();
            if(context.projectWithTasks.containsKey(task.pse__project__c)){
                contextTasks.addAll(context.projectWithTasks.get(task.pse__project__c));
            }

            contextTasks.add(task);
            
            context.projectWithTasks.put(task.pse__project__c, new List<pse__Project_Task__c>(contextTasks));

        }

        // Find all project task skills from all projects
        Map<String, Project_Task_Skill__c> allProjectTaskSkills = DAL_ProjectTask.getProjectTaskSkill(allEntries.keySet());
        System.debug('allEntries.keySet()'+allEntries.keySet());
        // Find all Skill SKU from all entries
        Map<Id, List<Skill_SKU_Effort_Map_Entry__c>> allEntrySkills = DAL_Sku.getSkillSkuEffortMapEntry(allEntries); //2 entries
		System.debug('allEntries'+allEntries);
        // Build a map of all sku skills from project to use later on creation of resource skill request
        context.skillsFromProject = new Map<Id,List<Skill_SKU_Effort_Map_Entry__c>>();
        for(Id projectId: allEntries.keySet()){
            List<SKU_Effort_Map_Entry__c> projectEntries = allEntries.get(projectId);
            List<Skill_SKU_Effort_Map_Entry__c> projectSkills = context.skillsFromProject.get(projectId);
            
            if(projectSkills == null){
                projectSkills = new List<Skill_SKU_Effort_Map_Entry__c>();
            }
            
            for(SKU_Effort_Map_Entry__c entry: projectEntries){
                List<Skill_SKU_Effort_Map_Entry__c> entrySkills = allEntrySkills.get(entry.Id);
                if(entrySkills != null){
                    projectSkills.addAll(entrySkills);
                }
            }
            
            context.skillsFromProject.put(projectId, projectSkills);  // 2 records 
        }
        
        // Create junction objects
        List<Project_Task_Skill__c> allTaskSkills = createProjectTaskSkills(projectTaskSkillList, allEntrySkills, allProjectTaskSkills);
        system.debug('projectTaskSkillList'+projectTaskSkillList);
        system.debug('allEntrySkills'+allEntrySkills);
        system.debug('allProjectTaskSkills'+allProjectTaskSkills);
        upsert allTaskSkills;
        
        List<Project_Task_SKU_Effort_Mapping_Entry__c> taskSkuEntries = createProjectTaskSkuEntries(projectTaskSkillList);
        upsert taskSkuEntries;
      
        List<Order_Item_Sku_Effort_Map__c> orderItemsSkuEffortMaps = createOrderItemsSkuEffortMaps(orderItemSkuMapList);
        insert orderItemsSkuEffortMaps;
    }

      /**
    
    /**
    * @description Generate a list of top tasks from allProjectTasks to be inserted
    * @author Leonardo Santos | 2/18/2020 
    * @param allProjectTasks 
    * @return List<pse__Project_Task__c> 
    **/
    private static List<pse__Project_Task__c> createTopTaskList(Map<String, ProjectTask> allProjectTasks, List<pse__Project_Task__c> projectTasksNullify){
        
        List<pse__Project_Task__c> topTasks = new List<pse__Project_Task__c>();
        for(ProjectTask topTask: allProjectTasks.values()){
            //system.debug('start date top task-----'+topTask.task.pse__Start_Date_Time__c + 'End date---'+topTask.task.pse__End_Date_Time__c);
            if(topTask.isTopTask){
                topTasks.add(topTask.task);
            }
        }
        
        //Defect #9727468
        if(!projectTasksNullify.isEmpty()){
            //System.debug('Adding tasks to nullify in toptasks list: '+projectTasksNullify);
            topTasks.addAll(projectTasksNullify);
        }
        
        return topTasks;
    }

    /**
    * @description Generate a list of child tasks from allProjectTasks to be inserted
    * @author Leonardo Santos | 2/18/2020 
    * @param allProjectTasks 
    * @return List<pse__Project_Task__c> 
    **/
    private static List<pse__Project_Task__c> createChildTaskList(Map<String, ProjectTask> allProjectTasks){
        
        List<pse__Project_Task__c> childTasks = new List<pse__Project_Task__c>();
        for(ProjectTask childTask: allProjectTasks.values()){
            
            if(!childTask.isTopTask){
                childTask.task.pse__Parent_Task__c = childTask.parentTask.Id;
                childTasks.add(childTask.task);
            }
        }

        return childTasks;
    }

    /**
    * @description Update start and end date for tasks based on the project start/end date
    * @author Leonardo Santos | 2/18/2020 
    * @param allProjectTasks 
    * @param project 
    * @return Map<String, ProjectTask> 
    **/
    private static Map<String, ProjectTask> updateTaskStartEndDate(Map<String, ProjectTask> allProjectTasks, pse__Proj__c project){
        
        for(ProjectTask projectTask: allProjectTasks.values()){
            
            if(project.pse__Project_Phase__c != 'Setup' && projectTask.task.pse__Status__c != 'Complete' && projectTask.isTopTask == false){
				system.debug('In ths If of phase ----'+project.pse__Project_Phase__c);	
                projectTask.task.pse__Start_Date_Time__c = TimezoneHelper.conversionDateToDateTime(project.pse__Start_Date__c, 12);
                projectTask.task.pse__End_Date_Time__c = TimezoneHelper.conversionDateToDateTime(project.pse__End_Date__c, 12);
            }
        }

        return allProjectTasks;
    }
    
    /**
    * @description Defect #9727468. Update start and end date for tasks to null if they do not exist in SKU Effort Mapping Entry
    * @author [Deloitte Consulting] : Abhishek Kawle / 12-07-2020 
    * @param projectTasksMap  
    * @param project
    * @param projectEntries 
    * @return List<pse__Project_Task__c> 
    **/
    private static List<pse__Project_Task__c> updateTaskStartEndDateToNull(Map<String, pse__Project_Task__c> projectTasksMap, pse__Proj__c project, List<SKU_Effort_Map_Entry__c> projectEntries){
        
        List<pse__Project_Task__c> projectTasksNullify = new List<pse__Project_Task__c>();
        for(pse__Project_Task__c projectTask: projectTasksMap.values()){
            
            //System.debug('Project Task Name: ' +projectTask.Name + ' under Project: ' +project.Id);
            if(project.pse__Project_Phase__c == 'Setup' && projectTask.pse__Status__c != 'Complete'){
                boolean taskFound = false;
                
                for(SKU_Effort_Map_Entry__c skuEffortMap : projectEntries){
                    if(projectTask.Name == skuEffortMap.Phase__r.Name){
                        //System.debug('Task: ' +projectTask.Name);
                        taskFound = true;
                    }
                }
                
                if(!taskFound){
                    //System.debug('Nullifying the task dates for: '+projectTask.Name);
                    projectTask.pse__Start_Date_Time__c = null;
                    projectTask.pse__End_Date_Time__c = null;
                    projectTasksNullify.add(projectTask);
                }
            }
        }

        return projectTasksNullify;
    }

    /**
    * @description Create missings junction object Project_Task_Skill__c
    * @author Leonardo Santos | 2/18/2020 
    * @param projectTaskSkillList 
    * @param allEntries 
    * @return List<Project_Task_Skill__c> 
    **/
    private static List<Project_Task_Skill__c> createProjectTaskSkills(List<ProjectTaskSkill> projectTaskSkillList, Map<Id, List<Skill_SKU_Effort_Map_Entry__c>> allEntrySkills, Map<String, Project_Task_Skill__c> allProjectTaskSkills){
        for(ProjectTaskSkill taskSkill: projectTaskSkillList){

            List<Skill_SKU_Effort_Map_Entry__c> entrySkills = allEntrySkills.get(taskSkill.skuEntryId);

            if(entrySkills != null){
                // For each skill from entry, create one project task skill
                for(Skill_SKU_Effort_Map_Entry__c skill: entrySkills){
                    String key = taskSkill.projectId + taskSkill.taskName + skill.Skill_Certification__c;
                    if(allProjectTaskSkills.containsKey(key)){
                        continue;
                    }

                    // Create project task skills
                    Project_Task_Skill__c newProjectTaskSkill = new Project_Task_Skill__c(
                        Project_Task__c = taskSkill.task.Id,
                        Skill_Certification__c = skill.Skill_Certification__c,
                        Minimum_Rate__c = skill.Minimum_Rate__c
                    );

                    allProjectTaskSkills.put(key, newProjectTaskSkill);
                }
            }
        }
		
        return allProjectTaskSkills.values();
    }

    /**
    * @description Create missings junction object Project_Task_SKU_Effort_Mapping_Entry__c
    * @author Leonardo Santos | 2/18/2020 
    * @param projectTaskSkillList 
    * @return List<Project_Task_SKU_Effort_Mapping_Entry__c> 
    **/
    private static List<Project_Task_SKU_Effort_Mapping_Entry__c> createProjectTaskSkuEntries(List<ProjectTaskSkill> projectTaskSkillList){
        
        Map<String, Project_Task_SKU_Effort_Mapping_Entry__c> taskSkuEntries = new Map<String, Project_Task_SKU_Effort_Mapping_Entry__c>();
        for(ProjectTaskSkill taskSkill: projectTaskSkillList){

            String key = taskSkill.skuEntryId + (String)taskSkill.task.Id;
            Project_Task_SKU_Effort_Mapping_Entry__c taskSkuEntry;
            if(taskSkuEntries.containsKey(key)){
                taskSkuEntry = taskSkuEntries.get(key);
                taskSkuEntry.SKU_Quantity__c += taskSkill.skuQuantity;
            }
            else {
                taskSkuEntry = new Project_Task_SKU_Effort_Mapping_Entry__c(
                    SKU_Effort_Mapping_Entry__c = taskSkill.skuEntryId,
                    Project_Task__c = taskSkill.task.Id,
                    SKU_Quantity__c = taskSkill.skuQuantity
                );
            }
            
            taskSkuEntries.put(key, taskSkuEntry);
        }
        return taskSkuEntries.values();
    }

    /**
    * @description Create missings junction object Order_Item_Sku_Effort_Map__c
    * @author Leonardo Santos | 2/18/2020 
    * @param orderItemSkuMapList 
    * @return List<Order_Item_Sku_Effort_Map__c> 
    **/
    private static List<Order_Item_Sku_Effort_Map__c> createOrderItemsSkuEffortMaps(List<OrderItemTaskSkuMap> orderItemSkuMapList){
        
        Map<String, Order_Item_Sku_Effort_Map__c> orderItemsSkuEffortMaps = new Map<String, Order_Item_Sku_Effort_Map__c>();
        
        for(OrderItemTaskSkuMap orderItemTask: orderItemSkuMapList){

            String key = (String)orderItemTask.orderItem + (String)orderItemTask.skuEffortMap + (String)orderItemTask.task.Id;
            if(!orderItemsSkuEffortMaps.containsKey(key)){
                Order_Item_Sku_Effort_Map__c orderItemSkuEffortMap = new Order_Item_Sku_Effort_Map__c(
                    Order_Product__c = orderItemTask.orderItem, 
                    SKU_to_Effort_Mapping__c = orderItemTask.skuEffortMap, 
                    Project_Task__c = orderItemTask.task.Id
                );
                orderItemsSkuEffortMaps.put(key, orderItemSkuEffortMap);
            }
        }

        return orderItemsSkuEffortMaps.values();
    }
}