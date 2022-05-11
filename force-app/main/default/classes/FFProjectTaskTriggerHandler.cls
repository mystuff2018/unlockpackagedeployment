public class FFProjectTaskTriggerHandler extends TriggerHandler{
    
    public override void beforeInsert() {
        ProjectTaskTriggerHandler.PupulateRateCard(Trigger.New,null);
        if(!ProjectTaskHandler.preventProjectTaskCreationBelowWorkOrderLevelCreated){
            ProjectTaskHandler.PreventProjectTaskCreationBelowWorkOrderLevel(Trigger.new);
        }
    }
    public override void beforeDelete(){
        if(!ProjectTaskHandler.preventDeletionOfPhaseLevelTasksCreated){
        	ProjectTaskHandler.preventDeletionOfPhaseLevelTasks((Map<Id, pse__Project_Task__c>) Trigger.oldMap);
        }
    }
    public override void afterInsert() {
        Map<Id, pse__Proj__c> projectMap = new Map<Id, pse__Proj__c>();
        ProjectTaskTriggerHandler.rollUpPlannedCostAndActualCostOnProject(projectMap,Trigger.New,null);
        updateProject(projectMap);
    }    
    public override void beforeUpdate() {
        map<id,pse__Proj__c> mapUpdatedProject = new map<id,pse__Proj__c>();
        ProjectTaskTriggerHandler.PupulateRateCard((list<pse__Project_Task__c>)Trigger.new,(Map<Id, pse__Project_Task__c>)Trigger.oldMap);
        ProjectTaskTriggerHandler.popualateActualCostAndPlanedCost((list<pse__Project_Task__c>)Trigger.new,(Map<Id, pse__Project_Task__c>)Trigger.oldMap);
        ProjectTaskTriggerHandler.clearRateCardAndRateData((list<pse__Project_Task__c>)Trigger.new,(Map<Id, pse__Project_Task__c>)Trigger.oldMap);
        if(!ProjectTaskHandler.preventProjectTaskCreationBelowWorkOrderLevelCreated){
            ProjectTaskHandler.PreventProjectTaskCreationBelowWorkOrderLevel(Trigger.new);
        }
    }
    public override void afterUpdate(){
        Map<Id, pse__Proj__c> projectMap = new Map<Id, pse__Proj__c>();
        ProjectTaskTriggerHandler.rollUpPlannedCostAndActualCostOnProject(projectMap,(list<pse__Project_Task__c>)Trigger.new,(Map<Id, pse__Project_Task__c>)Trigger.oldMap);
    	updateProject(projectMap);
    }
    public override void afterDelete(){
        map<id,pse__Proj__c> projectMap = new map<id,pse__Proj__c>();
        ProjectTaskTriggerHandler.rollUpPlannedCostAndActualCostOnProject(projectMap,Trigger.Old,null);
        updateProject(projectMap);
    }
    public override void afterUnDelete(){
        map<id,pse__Proj__c> projectMap = new map<id,pse__Proj__c>();
        ProjectTaskTriggerHandler.rollUpPlannedCostAndActualCostOnProject(projectMap,Trigger.New,null);
        updateProject(projectMap);
    }
    public static void updateProject(Map<Id, pse__Proj__c> projectMap)
    {
        if (!projectMap.isEmpty()){
            try
            {
                //TriggerHandler.bypass(FFProjectTriggerHandler.class.getName());
                //TriggerHandler.bypass(ESProjectTriggerHandler.class.getName());
                update projectMap.values();
            }
            catch (Exception e)
            {
                ExceptionLogger__c exceptionLogger = new ExceptionLogger__c(Apex_Class__c = 'ProjectTaskDateRollupHandler',Method_Name__c = 'rollupDatesToProject()',External_System_Name__c = 'FinancialForce',Description__c = e.getMessage() + '\n' + e.getStackTraceString() + '\n' +e.getCause() + '\n' + e.getLineNumber());

                insert exceptionLogger;
            }
            /*finally {
                TriggerHandler.clearBypass(FFProjectTriggerHandler.class.getName());
                TriggerHandler.clearBypass(ESProjectTriggerHandler.class.getName());
            }*/
        }
    }
}