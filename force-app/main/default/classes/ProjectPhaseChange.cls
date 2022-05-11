public class ProjectPhaseChange {
    public static void updateTaskStartEndDate(Map<Id, pse__Proj__c> oldMap, Map<Id, pse__Proj__c> newMap) {
        List<pse__Proj__c> projects = new List<pse__Proj__c>();
        for(pse__Proj__c project : newMap.values()){
            pse__Proj__c oldProject = oldMap.get(project.Id);
            if(project.pse__Project_Phase__c == 'Initiate' && oldProject.pse__Project_Phase__c == 'Setup'){
                projects.add(project);
            }
        }
        if(projects.size() > 0){
            updateTaskStartEndDate(projects);
        }
    }

    public static void updateTaskStartEndDate(List<pse__Proj__c> projects){
        Map<Id, pse__Proj__c> mapIdProject = new Map<Id, pse__Proj__c>();
        for(pse__Proj__c project : projects){
            mapIdProject.put(project.Id, project);
        }

        List<pse__Project_Task__c> tasksFromProject = [SELECT Name , pse__Estimated_Hours__c, pse__Parent_Task__c, pse__Status__c, pse__Project__c 
                                FROM pse__Project_Task__c WHERE pse__Project__c IN :mapIdProject.keySet() AND pse__Status__c != 'Complete'];
        
        for(pse__Project_Task__c task :tasksFromProject){
            pse__Proj__c project = mapIdProject.get(task.pse__Project__c);     
            task.pse__Start_Date_Time__c = TimezoneHelper.conversionDateToDateTime(project.pse__Start_Date__c, 12);
            task.pse__End_Date_Time__c = TimezoneHelper.conversionDateToDateTime(project.pse__End_Date__c, 12);
        }
        update tasksFromProject;
    }

}