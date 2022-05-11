/*
      Purpose:
            Rolls up custom "Standard Hours" field on project task to top of WBS.
            
      Initiative: Dell Thunderbolt PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    9/18/18
*/
/**
 *   
 *  Date             Developer           Tag           Summary of Changes 
 *  *********************************************************************************************************************
 *  05/09/2019       Orlando Monsalve    OM20190905    Changed the query of the object Site for the query of the object
 *                                                     Location (Schema.Location) and the object Address (Schema.Address)
 *  12/10/2019       Luis Campos                       Implemented the prevent deletion for active tasks. 
 *  
 */

public class ProjectTaskHandler {
        public static boolean preventDeletionActiveTasksCreated = false;
        public static boolean preventDeletionOfPhaseLevelTasksCreated = false;
    	public static boolean preventProjectTaskCreationBelowWorkOrderLevelCreated = false;
        
        public static void handleProjectTasks(Map<Id, pse__Project_Task__c> ptNewMap, Map<Id, pse__Project_Task__c> ptOldMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
        Map<Id, pse__Project_Task__c> ptMap = isDelete ? ptOldMap : ptNewMap;
        Set<Id> parentTaskIds = collectParentTaskIds(ptMap, isInsert, isUpdate, isDelete, ptOldMap);
        if (!parentTaskIds.isEmpty()) {
            List<pse__Project_Task__c> parentTasks = queryParentTasks(parentTaskIds);
            List<pse__Project_Task__c> parentsToUpdate = new List<pse__Project_Task__c>();
            for (pse__Project_Task__c parentTask : parentTasks) {
                Decimal totalStandardHours = accumulateTotalStandardHours(parentTask);
                updateParentTask(totalStandardHours, parentTask, parentsToUpdate);
            }
            if (!parentsToUpdate.isEmpty() || parentsToUpdate.size()>0) { //Added size check as a part of checkMarx
                update parentsToUpdate;
            }
        }
    }
    

//Only cahnge when create//or task site is empty, to avoid cahnge too much the behavior
    // public static void updateProjectSite(Map<Id, pse__Project_Task__c> ptNewMap, Map<Id, pse__Project_Task__c> ptOldMap,Boolean isUpdate, Boolean isBefore) {
    //     Map<Id, pse__Project_Task__c> ptMap = new Map<Id, pse__Project_Task__c>();
    //     if(isUpdate && isBefore){
    //         ptMap = ptNewMap;
    //     }
    //     Set<Id> projectId = new Set<Id>();
    //     for (pse__Project_Task__c pt : ptMap.values()) {
    //         projectId.add(pt.pse__Project__c);
    //     }
    //     // List<Project_Site__c> projectSites = [
    //     //         SELECT Id, Site__c,Address_Type__c,Project__c
    //     //         FROM Project_Site__c
    //     //         WHERE Project__c IN :projectId AND (Address_Type__c = 'Install At Contact' OR Address_Type__c = 'Shipping')
    //     // ];
    //     List<Project_Location__c> projectSites = [
    //             SELECT Id, Location__c, Address_Type__c, Project__c
    //             FROM Project_Location__c
    //             WHERE Project__c IN :projectId AND (Address_Type__c = 'Install At Contact' OR Address_Type__c = 'Shipping')
    //     ];
    //     if(!projectSites.isEmpty()) {
    //         for (pse__Project_Task__c pt : ptMap.values()) 
    //         {
    //             if(pt.Project_Site__c == Null)
    //             { 
    //                 for (Project_Location__c ps : projectSites) 
    //                 {
    //                     if (pS.Address_Type__c == 'Install At Contact' && ps.Project__c == pt.pse__Project__c) 
    //                     {
    //                         pt.Project_Site__c = pS.Id;

    //                     } else if (pS.Address_Type__c == 'Shipping' && ps.Project__c == pt.pse__Project__c) 
    //                     {
    //                         pt.Project_Site__c = pS.Id;
    //                     }
    //                     continue;
    //                 }
    //             }
    //         }
    //     }
    //     //update

    // }
    private static void updateParentTask(Decimal totalStandardHours, pse__Project_Task__c parentTask, List<pse__Project_Task__c> parentsToUpdate) {
        if (totalStandardHours != parentTask.PSA_Standard_Hours__c) {
            parentTask.PSA_Standard_Hours__c = totalStandardHours;
            parentsToUpdate.add(parentTask);
        }
    }

    private static Decimal accumulateTotalStandardHours(pse__Project_Task__c parentTask) {
        Decimal totalStandardHours = 0.0;
        for (pse__Project_Task__c childTask : parentTask.pse__Immediate_Sub_Tasks__r) {
            if (childTask.PSA_Standard_Hours__c != null) {
                totalStandardHours += childTask.PSA_Standard_Hours__c;
            }
        }
        return totalStandardHours;
    }

    private static List<pse__Project_Task__c> queryParentTasks(Set<Id> parentTaskIds) {
        List<pse__Project_Task__c> parentTasks = [
                SELECT
                        Name,
                        PSA_Standard_Hours__c,
                        pse__Hierarchy_Depth__c,
                        pse__Parent_Task__c, (
                        SELECT
                                Name,
                                PSA_Standard_Hours__c,
                                pse__Hierarchy_Depth__c,
                                pse__Parent_Task__c
                        FROM pse__Immediate_Sub_Tasks__r
                )
                FROM pse__Project_Task__c
                WHERE Id IN :parentTaskIds
        ];
        return parentTasks;
    }


    private static Set<Id> collectParentTaskIds(Map<Id, pse__Project_Task__c> ptMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Map<Id, pse__Project_Task__c> ptOldMap) {
        Set<Id> parentTaskIds = new Set<Id>();
        for (pse__Project_Task__c pt : ptMap.values()) {
            if (pt.pse__Parent_Task__c != null) {
                if (parentNeedsUpdate(isInsert, isUpdate, isDelete, pt, ptOldMap)) {
                    parentTaskIds.add(pt.pse__Parent_Task__c);
                }
            }
        }
        return parentTaskIds;
    }

    private static Boolean parentNeedsUpdate(Boolean isInsert, Boolean isUpdate, Boolean isDelete, pse__Project_Task__c pt, Map<Id, pse__Project_Task__c> ptOldMap) {
        return isInsert || isDelete ||
                (isUpdate && pt.PSA_Standard_Hours__c != ptOldMap.get(pt.Id).PSA_Standard_Hours__c);
    }

    //omonsalve 01-04-2019
    public static void updateProjectStatus(Map<Id,pse__Project_Task__c> newMap, Map<Id,pse__Project_Task__c> oldMap)
    {
        Set<Id> setIdsPT = new Set<Id>();
        
        // For to identify all project task with status complete
        for (Id ptId : newMap.keySet()) 
        {
            pse__Project_Task__c newPT = newMap.get(ptId);
            if (newPT.pse__Status__c.equals('Complete')) 
            {
                setIdsPT.add(newPT.pse__Project__c);
            }
        }

        Set<Id> setOldComplete = new Set<Id>();
        Set<Id> setProjectId = new Set<Id>();

        for (Id objId : oldMap.keySet()) 
        {
            pse__Project_Task__c oldPT = oldMap.get(objId);
            if (oldPT.pse__Status__c.equals('Complete')) 
            {
                setOldComplete.add(oldPT.Id);
                setProjectId.add(oldPT.pse__Project__c);
            }
            
        }

        if (!setIdsPT.isEmpty()) 
        {
            // map of project id by objproject
            Map<String, pse__Proj__c> mapProjects = new Map<String, pse__Proj__c>();
            for (pse__Proj__c objP : [SELECT Id,
                                         All_Project_Tasks_Complete__c
                                         FROM pse__Proj__c
                                         WHERE Id IN: setIdsPT ]) 
            {
                mapProjects.put(objP.Id,objP);
            }
            // map of project Id by set of project task
            Map<Id, Set<pse__Project_Task__c> > mapIdProjectXsetPT = new Map<Id, Set<pse__Project_Task__c> >();
            for (pse__Project_Task__c objPT : [SELECT pse__Project__c,
                                                        pse__Status__c,
                                                        pse__Summary__c
                                                FROM pse__Project_Task__c
                                                WHERE pse__Project__c IN: mapProjects.keyset() ]) 
            {
                if(mapIdProjectXsetPT.containsKey(objPT.pse__Project__c))
                {
                    mapIdProjectXsetPT.get(objPT.pse__Project__c).add(objPT);

                }
                else 
                {
                    mapIdProjectXsetPT.put(objPT.pse__Project__c, new Set<pse__Project_Task__c>{objPT});
                }
            }
            // validadtion that all project task are complete
            for (Id objId : mapIdProjectXsetPT.keySet()) 
            {
                Boolean boolAllComplete = true;
                for (pse__Project_Task__c objPTAux : mapIdProjectXsetPT.get(objId)) 
                {
                    if(!objPTAux.pse__Status__c.equals('Complete'))
                    {
                        boolAllComplete = false;
                        break;
                    }
                }

                if(boolAllComplete)
                {
                    mapProjects.get(objId).All_Project_Tasks_Complete__c = true;
                }
            }
            update mapProjects.values();
        }

        if (!setOldComplete.isEmpty()) 
        {
            Set<Id> setProjectUpdate = new Set<Id>();
            List<pse__Proj__c> listProjectUpdate = new List<pse__Proj__c>();

            Map<String, pse__Proj__c> mapProjects = new Map<String, pse__Proj__c>();
            for (pse__Proj__c objP : [SELECT Id,
                                         All_Project_Tasks_Complete__c
                                         FROM pse__Proj__c
                                         WHERE Id IN: setProjectId ]) 
            {
                mapProjects.put(objP.Id,objP);
            }
            // validation that a new project task was created and the project was complete
            for (Id objId : setOldComplete) 
            {
                pse__Project_Task__c newObj = newMap.get(objId);
                if (newObj.pse__Status__c.equals('Started') && mapProjects.get(newObj.pse__Project__c).All_Project_Tasks_Complete__c == true) 
                {
                    setProjectUpdate.add(newObj.pse__Project__c);
                }
            }

            for (pse__Proj__c objProject : [SELECT All_Project_Tasks_Complete__c
                                            FROM pse__Proj__c
                                            WHERE Id IN:setProjectUpdate ]) 
            {
                objProject.All_Project_Tasks_Complete__c = false;
                listProjectUpdate.add(objProject);
            }
            if(listProjectUpdate.size()>0){ //Added if and size check as a part of checkMarx
                update listProjectUpdate;
            } 
        }
    }

    /* -----------------------------------------------------------------------------------------------------------------------
    Method Name:  preventDeletionActiveTasks
    Description:  Validate if the task can be deleted. (Tasks with work orders and/or time can not be deleted)
    ----------------------------------------------------------------------------------------------------------------------------
    Date         Version          Author             Summary of Changes 
    -----------  -------  ------------------------  ------------------------------------------------------------------------------
    12/03/2019     1.0          Luis Campos         Initial Release
    -------------------------------------------------------------------------------------------------------------------------- */
    public static void preventDeletionActiveTasks(Map<Id,pse__Project_Task__c> oldMap)
    {
        try
        {
            Map<Id, pse__Project_Task__c> preventDeleteWOTimeTasks = validateTaskDeletionWorkOrderTaskTimeRule(oldMap);
            Map<Id, pse__Project_Task__c> preventDeleteAssignmentTasks = validateTaskDeletionAssignmentRule(oldMap);
            
            if(preventDeleteWOTimeTasks.values().size() > 0)
            {
                for(pse__Project_Task__c taskItem : preventDeleteWOTimeTasks.values())
                {
                    pse__Project_Task__c task = oldmap.get(taskItem.Id);
                    if(task != null) {
                        task.adderror( ' This Project Task cannot be deleted because it has related Work Orders and/or has Time entered against it and/or it has related Assignments.');
                    }
                }
            }

            if(preventDeleteAssignmentTasks.values().size() > 0)
            {
                for(pse__Project_Task__c taskItem : preventDeleteAssignmentTasks.values())
                {
                    pse__Project_Task__c task = oldmap.get(taskItem.Id);
                    if(task != null) {
                        task.adderror( ' This Project Task cannot be deleted because it has related assignments.');
                    }
                }
            }
        }
        catch(Exception e){
            ExceptionHandler.logHandledExceptions(e,'ProjectTaskHandler','preventDeletionActiveTasks',NULL);
        }

        preventDeletionActiveTasksCreated = true;
    }

   
     public static Map<Id, pse__Project_Task__c> validateTaskDeletionWorkOrderTaskTimeRule(Map<Id, pse__Project_Task__c> projTasks){

        Map<Id, pse__Project_Task__c> preventDeletionTasks = new Map<Id, pse__Project_Task__c>();
        

            for(pse__Project_Task__c taskItem : [SELECT Id, Name, (SELECT Id FROM pse__Task_Time__r LIMIT 1), (SELECT Id FROM Work_Orders__r LIMIT 1) FROM pse__Project_Task__c WHERE Id IN :projTasks.keySet()])
            {
                pse__Project_Task__c actualRecord = projTasks.get(taskItem.Id);
                if((taskItem.Work_Orders__r.size() > 0 ||  taskItem.pse__Task_Time__r.size() > 0)){
                    preventDeletionTasks.put(taskItem.Id, taskItem);
                }
            }


        return preventDeletionTasks;
    }

    public static Map<Id, pse__Project_Task__c> validateTaskDeletionAssignmentRule(Map<Id, pse__Project_Task__c> projTasks){

        Map<Id, pse__Project_Task__c> preventDeletionTasks = new Map<Id, pse__Project_Task__c>();



            Map<Id, Boolean> mapProjectTaskAssignments = new Map<Id, Boolean>();

            for(AggregateResult result : [SELECT pse__Project_Task__c FROM pse__Project_Task_Assignment__c WHERE pse__Project_Task__c  IN :projTasks.keyset() GROUP BY pse__Project_Task__c]){

                mapProjectTaskAssignments.put((Id)result.get('pse__Project_Task__c'), true);
            }

            for(pse__Project_Task__c taskItem : projTasks.values())
            {
                pse__Project_Task__c actualRecord = projTasks.get(taskItem.Id);
                if(mapProjectTaskAssignments.containsKey(taskItem.Id) || ProjectTaskAssignmentTriggerHandler.tasksForAssignmentsDeleted.contains(taskItem.Id)){
                    preventDeletionTasks.put(taskItem.Id, taskItem);
                }
            }


        return preventDeletionTasks;
    }
    
    public static void preventProjectTaskCreationBelowWorkOrderLevel(List<pse__Project_Task__c> newList){
        Id recordTypeInstallationBadge = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
        Id recordTypeInstallationDPS = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_DSP').getRecordTypeId();
        Map<Id,pse__Project_Task__c> newMap = new Map<Id,pse__Project_Task__c>();
        try {
            for (pse__Project_Task__c pj : newList) {
                if (pj.pse__Parent_Task__c != null) {
                    newMap.put(pj.pse__Parent_Task__c,pj);
                }
            }
            if (!newMap.isEmpty()) {
                for (WorkOrder wo : [SELECT Id, Project_Task__c, RecordTypeId FROM WorkOrder WHERE (RecordTypeId =: recordTypeInstallationBadge  OR RecordTypeId =: recordTypeInstallationDPS) AND Project_Task__c =: newMap.KeySet()]) {
                    newMap.get(wo.Project_Task__c).addError('Error on Task ' + newMap.get(wo.Project_Task__c).Name +'. You cannot add a Project Task below another Project Task with an existing Work Order.');
                }          
            }       
        } catch (Exception e) {
            ExceptionHandler.logHandledExceptions(e,'ProjectTaskHandler','preventProjectTaskCreationBelowWorkOrderLevel',NULL);
        }
        
        PreventProjectTaskCreationBelowWorkOrderLevelCreated = true;
    }
    
   //Shiva After Update
  public static void sendProjectTaskDetailsToNovoraAfterUpdate(List<pse__Project_Task__c> newTasks){
      list<pse__Project_Task__c> tasksToUpdate = new  list<pse__Project_Task__c>();
      set<id> ProjectIds = new set<id>();
      for(pse__Project_Task__c pt : newTasks ){
          ProjectIds.add(pt.pse__Project__c);
      }
      
      list<pse__Project_Task__c> taskList = [Select id, pse__Project__c,
                                             Project_Phase__c, FBE_IDS_Task_IntegrationStatus__c 
                                             from pse__Project_Task__c WHERE 
                                             pse__Project__c IN : ProjectIds];
       System.debug('@@kkk==soql ' +taskList.size());
      
      for(pse__Project_Task__c ptasks : taskList){
          if(ptasks.Project_Phase__c != 'Setup'){
          ptasks.FBE_IDS_Task_IntegrationStatus__c = 'Pending Sync';
          System.debug('@@kkk ' +ptasks.FBE_IDS_Task_IntegrationStatus__c );
          tasksToUpdate.add(ptasks);
      }
      }
      if(!tasksToUpdate.isEmpty() || tasksToUpdate.size()>0){ //Added size check as a part of checkMarx
          update tasksToUpdate;
      } 
      } 
  
 
    
    /*************************************************/
    
    
    
    public static void insertProjectTaskIntegrationStatus(List<pse__Project_Task__c> pList) {
        System.debug('Inside method'); 
    for (pse__Project_Task__c pt : pList) { 
        if (pt.pse__Project__c != null && pt.Project_Phase__c !='Setup') {
            System.debug('@@353' +pt.pse__Project__c +' Phase ' +pt.Project_Phase__c);
            FBE_IDS_NovoraInterLock.updateProjectTask(pt);
        }
    }
    
}
    
    
    //After Update
    public static void updateProjectTaskIntegrationStatus(List<pse__Project_Task__c> NewTaskList){
    User currentuser = [Select Id,Name,Email,alias from User where Id=:userinfo.getuserId()];
        System.debug('User Info  '+currentuser);
        if(!NewTaskList.isEmpty()){
        for(pse__Project_Task__c pTask: NewTaskList){  
            if(currentuser.Alias != 'boomi' && pTask.Project_Phase__c != 'Setup'){
                System.debug('Before ' + pTask.FBE_IDS_Task_IntegrationStatus__c);
                System.debug(' phase ' +pTask.Project_Phase__c);
                System.debug(' Is Boomi user');
                FBE_IDS_NovoraInterLock.updateProjectTask(pTask);
                System.debug('Boomi Update ' + pTask.FBE_IDS_Task_IntegrationStatus__c);
                System.debug('@@ ' +pTask);
            }        
            
          
            }

        } 
    }
    public static void  preventDeletionOfPhaseLevelTasks(Map<Id,pse__Project_Task__c> projTasks){

    try{


        String profileName = [Select Name from Profile where Id =: userinfo.getProfileid() limit 1].Name;

        for(pse__Project_Task__c taskItem : projTasks.values()){
            if((taskItem.pse__Parent_Task__c == null) &&
                    profileName != 'System Administrator'){
               taskItem.addError(/*'Error deleting Task ' +taskItem.Name+ '.*/ 'You cannot delete a Phase level task.');
            }
        }

    }catch(Exception e){
        ExceptionHandler.logHandledExceptions(e,'ProjectTaskHandler','preventDeletionActiveTasks',NULL);
    }

        preventDeletionOfPhaseLevelTasksCreated = true;
    }
}