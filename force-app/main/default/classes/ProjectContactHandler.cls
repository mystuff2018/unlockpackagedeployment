/*
      Purpose:
            Maintain the Contact lookup fields on Project in consistency with the corresponding contact
            checkbox fields on the related Project Contact object
            
      Initiative: Dell Thunderbolt PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    8/30/18
    -------------------------------------
    ----------      ---------------------------     -------------    
    Date            Author                            Description      
    26-07-2019      Orlando Monsalve  (OMS)           Class Updated, added maintainProjectContactFieldsFurture future method, change the logic from
                                                      maintainProjectContactFields to the maintainProjectContactFieldsFurture
*/

public class ProjectContactHandler {
    public static void maintainProjectContactFields(Map<Id, Project_Contact__c> triggerOldMap, Map<Id, Project_Contact__c> triggerNewMap, TriggerOperation operation) 
    {
        String triggerOld = JSON.serialize(triggerOldMap);
        String triggerNew = JSON.serialize(triggerNewMap);
        Map<String, TriggerOperation> operationMap = new Map<String, TriggerOperation>();
        operationMap.put('operation',operation);
        String strOperation = JSON.serialize(operationMap);
        System.debug('----------------CALLING FUTURE METHOD------------>');
        Boolean boolContext = System.isFuture();
        if(!boolContext)
        {
            maintainProjectContactFieldsFurture(triggerOld, triggerNew, strOperation);
        }

    }
    @future 
    public static void maintainProjectContactFieldsFurture(String triggerOld, String triggerNew, String strOperation)
    {
        System.debug('----------------FUTURE------------>');
        Map<Id, Project_Contact__c> triggerOldMap = (Map<Id, Project_Contact__c>) JSON.deserialize(triggerOld.unescapeHtml4(), Map<Id, Project_Contact__c>.class);
        Map<Id, Project_Contact__c> triggerNewMap = (Map<Id, Project_Contact__c>) JSON.deserialize(triggerNew.unescapeHtml4(), Map<Id, Project_Contact__c>.class);
        Map<String, TriggerOperation> operationMap = (Map<String, TriggerOperation>) JSON.deserialize(strOperation.unescapeHtml4(), Map<String, TriggerOperation>.class);
        TriggerOperation operation = operationMap.get('operation');
        Map<Id, Project_Contact__c> projectContactMap = operation == TriggerOperation.BEFORE_DELETE || operation == TriggerOperation.AFTER_DELETE ? triggerOldMap : triggerNewMap;
        List<Project_Contact_Sync__mdt> syncSettings = querySyncSettings();
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        if (syncSettings.size() > 0) {
            Set<Id> projectIds = collectProjectIds(projectContactMap);
            Map<Id, pse__Proj__c> projectMap = queryProjects(syncSettings, projectIds);
            List<Project_Contact__c> projectContacts = queryProjectContacts(syncSettings, projectContactMap);
            System.debug('2.Number of Queries used in this apex code so far: ' + Limits.getQueries());
            Map<Id, pse__Proj__c> projectUpdateMap = new Map<Id, pse__Proj__c>();
            for (Project_Contact__c pc : projectContacts) {
                pse__Proj__c projectToUpdate = projectMap.get(pc.Project__c);
                if (projectToUpdate != null) {
                    Boolean changed = false;
                    for (Project_Contact_Sync__mdt setting : syncSettings) 
                    {
                        Project_Contact__c oldPc = (operation == TriggerOperation.BEFORE_UPDATE || operation == TriggerOperation.AFTER_UPDATE) ?
                                (Project_Contact__c) triggerOldMap.get(pc.Id)
                                :
                                null;
                        changed |= updateProjectFieldIfNecessary(pc, oldPc, setting.Project_Contact_Checkbox_API_Name__c, projectToUpdate, setting.Project_Lookup_API_Name__c, operation);
                    }
                    System.debug('3.Number of Queries used in this apex code so far: ' + Limits.getQueries());
                    if (changed) projectUpdateMap.put(pc.Project__c, projectToUpdate);
                }
            }
            if (!projectUpdateMap.isEmpty()) {
                update projectUpdateMap.values();
            }
        }
    }

    private static List<Project_Contact__c> queryProjectContacts(List<Project_Contact_Sync__mdt> syncSettings, Map<Id, Project_Contact__c> triggerNewMap) {
        SoqlQuery projectContactQuery = buildProjectContactQuery(syncSettings, triggerNewMap);
        List<Project_Contact__c> projectContactMap =
                (List<Project_Contact__c>) Database.query(projectContactQuery.toSoql());
        return projectContactMap;
    }

    private static SoqlQuery buildProjectContactQuery(List<Project_Contact_Sync__mdt> syncSettings, Map<Id, Project_Contact__c> triggerNewMap) {
        SoqlQuery projectContactQuery = new SoqlQuery('Project_Contact__c', getSelectedProjectContactFields(syncSettings), 'Id in ' + SoqlQuery.idCollectionLiteral(triggerNewMap.keySet()));
        return projectContactQuery;
    }

    private static Map<Id, pse__Proj__c> queryProjects(List<Project_Contact_Sync__mdt> syncSettings, Set<Id> projectIds) {
        SoqlQuery projectQuery = buildProjectQuery(syncSettings, projectIds);
        Map<Id, pse__Proj__c> projectMap = new Map<Id, pse__Proj__c>(queryProjects(projectQuery));
        return projectMap;
    }

    private static SoqlQuery buildProjectQuery(List<Project_Contact_Sync__mdt> syncSettings, Set<Id> projectIds) {
        SoqlQuery projectQuery =
                new SoqlQuery('pse__Proj__c',
                        getSelectedProjectFields(syncSettings),
                        'Id in ' + SoqlQuery.idCollectionLiteral(projectIds));
        return projectQuery;
    }

    private static List<pse__Proj__c> queryProjects(SoqlQuery projectQuery) {
        return (List<pse__Proj__c>) Database.query(projectQuery.toSoql());
    }

    private static Set<Id> collectProjectIds(Map<Id, Project_Contact__c> triggerNewMap) {
        Set<Id> projectIds = new Set<Id>();
        for (Project_Contact__c pc : triggerNewMap.values()) {
            projectIds.add(pc.Project__c);
        }
        return projectIds;
    }

    private static List<Project_Contact_Sync__mdt> querySyncSettings() {
        List<Project_Contact_Sync__mdt> syncSettings = [SELECT Project_Contact_Checkbox_API_Name__c,Project_Lookup_API_Name__c FROM Project_Contact_Sync__mdt LIMIT 100];
        return syncSettings;
    }

    private static Set<String> getSelectedProjectContactFields(List<Project_Contact_Sync__mdt> syncSettings) {
        Set<String> selectedPcFields = new Set<String>{
                'Project__c', 'Contact__c'
        };
        for (Project_Contact_Sync__mdt setting : syncSettings) {
            selectedPcFields.add(setting.Project_Contact_Checkbox_API_Name__c);
        }
        return selectedPcFields;
    }

    private static Set<String> getSelectedProjectFields(List<Project_Contact_Sync__mdt> syncSettings) {
        Set<String> selectedProjectFields = new Set<String>();
        for (Project_Contact_Sync__mdt setting : syncSettings) {
            selectedProjectFields.add(setting.Project_Lookup_API_Name__c);
        }
        return selectedProjectFields;
    }

    private static Boolean updateProjectFieldIfNecessary(Project_Contact__c pc, Project_Contact__c oldPc, String projectContactCheckboxApiName, pse__Proj__c projectToUpdate, String projectLookupApiName, TriggerOperation operation) {
        Boolean checkboxValue = (Boolean) pc.get(projectContactCheckboxApiName);
        Id projectContactValue = (Id) projectToUpdate.get(projectLookupApiName);
        if (operation != TriggerOperation.BEFORE_DELETE && operation != TriggerOperation.AFTER_DELETE) {
            if (checkboxValueBecomes(true, pc, oldPc, projectContactCheckboxApiName, operation) && pc.Contact__c != projectContactValue) {
                projectToUpdate.put(projectLookupApiName, pc.Contact__c);
                return true;
            }
            if (checkboxValueBecomes(false, pc, oldPc, projectContactCheckboxApiName, operation) && pc.Contact__c == projectContactValue) {
                projectToUpdate.put(projectLookupApiName, null);
                return true;
            }
        } else {
            if (checkboxValueBecomes(true, pc, oldPc, projectContactCheckboxApiName, operation) && pc.Contact__c == projectContactValue) {
                projectToUpdate.put(projectLookupApiName, null);
                return true;
            }
        }
        return false;
    }
    private static Boolean checkboxValueBecomes(Boolean bool, Project_Contact__c pc, Project_Contact__c oldPc, String projectContactCheckboxApiName, TriggerOperation operation) {
        if (operation == TriggerOperation.AFTER_INSERT || operation == TriggerOperation.BEFORE_INSERT) {
            return pc.get(projectContactCheckboxApiName) == bool;
        }
        if (operation == TriggerOperation.AFTER_UPDATE || operation == TriggerOperation.BEFORE_UPDATE) {
            return oldPc.get(projectContactCheckboxApiName) != pc.get(projectContactCheckboxApiName) && pc.get(projectContactCheckboxApiName) == bool;
        }
        if (operation == TriggerOperation.BEFORE_DELETE || operation == TriggerOperation.AFTER_DELETE) {
            return pc.get(projectContactCheckboxApiName) == bool;
        }
        return false;
    }

    public static void maintainProjectContactRecords(Map<Id, pse__Proj__c> triggerOldMap, Map<Id, pse__Proj__c> triggerNewMap) {
        List<Project_Contact_Sync__mdt> syncSettings = querySyncSettings();
        Set<Id> projectContactChangedProjectIds = new Set<Id>();
        Set<String> projectContactSelectedFieldNames = new Set<String>{
                'Project__c', 'Contact__c'
        };
        for (pse__Proj__c project : triggerNewMap.values()) {
            for (Project_Contact_Sync__mdt setting : syncSettings) {
                projectContactSelectedFieldNames.add(setting.Project_Contact_Checkbox_API_Name__c);
                Id newProjectLookupValue = (Id) project.get(setting.Project_Lookup_API_Name__c);
                Id oldProjectLookupValue = (Id) triggerOldMap.get(project.Id).get(setting.Project_Lookup_API_Name__c);
                if (newProjectLookupValue != oldProjectLookupValue) {
                    projectContactChangedProjectIds.add(project.Id);
                }
            }
        }
        if (!projectContactChangedProjectIds.isEmpty()) {
            SoqlQuery pcQuery = new SoqlQuery('Project_Contact__c', projectContactSelectedFieldNames, 'Project__c in ' + SoqlQuery.idCollectionLiteral(projectContactChangedProjectIds));
            List<Project_Contact__c> pcs = (List<Project_Contact__c>)Database.query(pcQuery.toSoql());
            List<Project_Contact__c> updPcs = new List<Project_Contact__c>();
            for (Project_Contact__c pc:pcs) {
                Boolean changed = false;
                for (Project_Contact_Sync__mdt setting:syncSettings) {
                    pse__Proj__c project = triggerNewMap.get(pc.Project__c);
                    Id projectLookupValue = (Id) project.get(setting.Project_Lookup_API_Name__c);
                    Boolean pcCurrentCheckBoxValue = (Boolean) pc.get(setting.Project_Contact_Checkbox_API_Name__c);
                    Boolean pcTargetCheckboxValue = projectLookupValue == pc.Contact__c;
                    if (pcCurrentCheckBoxValue != pcTargetCheckboxValue) {
                        pc.put(setting.Project_Contact_Checkbox_API_Name__c, pcTargetCheckboxValue);
                        changed = true;
                    }
                }
                if (changed) {
                    updPcs.add(pc);
                }
            }
            if (!updPcs.isEmpty()) {
                update updPcs;
            }
        }
    }
}