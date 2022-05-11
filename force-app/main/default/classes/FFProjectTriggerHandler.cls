public with sharing class FFProjectTriggerHandler extends TriggerHandler {
    public Map<Id, pse__Proj__c> TriggerNewMap { get; set; }
    public Map<Id, pse__Proj__c> TriggerOldMap { get; set; }
    public List<pse__Proj__c> TriggerNew { get; set; }
    public List<pse__Proj__c> TriggerOld { get; set; }
    
    public static set<Id> projectsBeingCreated = new set<Id>();
    
    public FFProjectTriggerHandler() {
        /*if(TriggerHandler.isBypassed(FFProjectTriggerHandler.class.getName())){
            //Prevent constructor execution when trigger is already bypassed
            system.debug('Bypasing FF Trigger constructor.');
            return;
        }*/
        filterRecordsByRecordType();
    }
    
    private List<ExceptionLogger__c> exceptions = new List<ExceptionLogger__c>();
    
    public override void afterInsert() {
        List<id> projectIds = new List<id>();
        for (pse__Proj__c project : (List<pse__proj__c>)Trigger.new) {
            projectIds.add(project.Id);
            projectsBeingCreated.add(project.Id);
        }
        Map<Id, pse__Proj__c> engagementsToUpdateMap = FFCustomProjectRollup.verifyCustomProject((List<pse__Proj__c>)Trigger.New, new Map<Id, pse__Proj__c>());
        update engagementsToUpdateMap.values();
        sendEventOpenText();
        //ProjectMilestoneCreator.createMilestoneFromProject(projectIds);
        //IdsProjectClosureHandler.handleMilestones(projectIds);
    }
    
    public override void beforeInsert() { 
        Id defaultRecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
        Id templateRecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Template').getRecordTypeId();
        
        for (pse__Proj__c project : (List<pse__proj__c>)Trigger.New) {
            project.pse__Is_Active__c = true;
            if (project.RecordTypeId != defaultRecordTypeId && project.Created_Automatically__c) {
                project.pse__Is_Billable__c = true;
            }
            if(!Test.isRunningTest()){
            if (project.RecordType.Name != 'Parent Project' && project.RecordType.Name != 'Allocation' && project.RecordType.Name != 'Global') {
                project.pse__Closed_For_Time_Entry__c = true;
            }
            }
            if (project.RecordTypeId != templateRecordTypeId) {
                 project.pse__Include_In_Forecasting__c = true;                 
            }
        }
        ProjectBuidLocalChannelHandler.setBuidAndLocalChannel(Trigger.new);
        ProjectEndDateConfiguration.setProjectEndDateFromPractice(Trigger.new);
        //ProjectTriggerHandler.populatePdmUser(Trigger.New, (Map<Id, pse__proj__c>)Trigger.OldMap, true);
    }
    
    public static Set<Id> getProjectsFromSetupToInitiate(Map<Id, pse__Proj__c> oldMap, Map<Id, pse__Proj__c> newMap) {
        Set<Id> projects = new Set<Id>();
        for(pse__Proj__c project : newMap.values()){
            pse__Proj__c oldProject = oldMap.get(project.Id);
            if(project.pse__Project_Phase__c == 'Initiate' && oldProject.pse__Project_Phase__c == 'Setup'){
                projects.add(project.Id);
            }
        }
        return projects;
    }
    
    public override void afterUpdate() {
        //TriggerHandler.bypass(FFProjectTriggerHandler.class.getName());
        if (IdsProjectHandler.runOnce()) {
            IdsProjectHandler.HandlePhaseChange(Trigger.old, Trigger.new);
            FBE_IDS_NovoraInterLock.sendProjectAsignmtToNovora((Map<Id,pse__proj__c>)Trigger.oldMap, (Map<Id, pse__proj__c>)Trigger.newMap);
        }
        ProjectContactHandler.maintainProjectContactRecords((Map<Id, pse__proj__c>)Trigger.oldMap, (Map<Id, pse__proj__c>)Trigger.newMap);
        
        //Moved to execute before IdsProjectHandler to create Start and EndDate in runtime Defect 9632960: "Work Order: Date fields not populated"
        ProjectPhaseChange.updateTaskStartEndDate((Map<Id, pse__proj__c>)Trigger.oldMap, (Map<Id, pse__proj__c>)Trigger.newMap);
        
        
        FBE_IDS_NovoraInterLock.projectDetailsToNovora((List<pse__proj__c>)Trigger.new,(Map<Id, pse__proj__c>)Trigger.oldMap,false);
        Map<Id, pse__Proj__c> engagementsToUpdateMap = IdsProjectHandler.handleStageChange(Trigger.old,Trigger.new);
        IdsProjectClosureHandler.handleMilestones((Map<Id, pse__proj__c>)Trigger.oldMap, (Map<Id, pse__proj__c>)Trigger.newMap);
        
        if(!FFCustomProjectRollup.customRollupExecuted){
            engagementsToUpdateMap = FFCustomProjectRollup.verifyCustomProject((List<pse__Proj__c>)Trigger.new, engagementsToUpdateMap);
            FFCustomProjectRollup.customRollupExecuted = true;
        }
        
        if(!engagementsToUpdateMap.isEmpty())
            update engagementsToUpdateMap.values();
        
        if(!OT_TriggerController.projectAfterUpdateExecuted){
            this.sendEventOpenText();
            OT_TriggerController.projectAfterUpdateExecuted = true;
        }
        if(!ProjectTriggerHandler.pmNotificationTaskCreated){
			ProjectTriggerHandler.createPmNotificationTask(Trigger.new,(Map<Id, pse__proj__c>)Trigger.oldMap);
		}
        sendEventOpenText();
        /*String jsonStringForProj = json.serialize(Trigger.new);
			FBE_IDS_NovoraInterLock.updateProjectsInFuture(jsonStringForProj);*/
        //TriggerHandler.clearbypass(FFProjectTriggerHandler.class.getName());
    }
    
    public override void beforeUpdate() {
        //TriggerHandler.bypass(FFProjectTriggerHandler.class.getName());
        IdsProjectClosureHandler.handleClosure((Map<Id, pse__proj__c>)Trigger.oldMap, (Map<Id, pse__proj__c>)Trigger.newMap);
        if (IdsProjectHandler.runOnceBeforeUpdate()) {
            IdsProjectHandler.UpdateProjectStartDate((Map<Id, pse__proj__c>)Trigger.oldMap, (Map<Id, pse__proj__c>)Trigger.newMap);
        }
        IdsProjectHandler.updateProjectName((Map<Id, pse__proj__c>)Trigger.oldMap, (Map<Id, pse__proj__c>)Trigger.newMap);
        FBE_IDS_NovoraInterLock.projectDetailsToNovora((List<pse__proj__c>)Trigger.new,(Map<Id, pse__proj__c>)Trigger.oldMap,true);
        ProjectUtils.updateGroup((Map<Id, pse__proj__c>)Trigger.OldMap, (List<pse__Proj__c>) Trigger.New); 

         /****** The below method is no longer required as this logic works different in DFN 
                 as part of Story# 11019946 this method is commented by Sivakumari Ediga on 01/25/2022  */
        //ProjectBuidLocalChannelHandler.setBuidAndLocalChannelWhenUpdateBillingAccount((Map<Id, pse__proj__c>)Trigger.oldMap,Trigger.new);
       
        System.debug('Aftet BUIDANDLC METHOD ' +(Map<Id, pse__proj__c>)Trigger.oldMap);
        //ProjectTriggerHandler.populateNextBillingDate(this.TriggerNew,(Map<Id, pse__proj__c>) this.TriggerOldMap);
        ProjectTriggerHandler.populateNextBillingDate(Trigger.New,(Map<Id, pse__proj__c>)Trigger.OldMap);
        TriggerHandler.clearbypass(FFProjectTriggerHandler.class.getName());
        // IdsProjectHandler.HandlerAutodispatch(this.TriggerOldMap, this.TriggerNewMap);
        // If project is changing from Setup to Initiate, update Project Start Date to now.
        CancelledProjectStageHandler.handleCancelledProjectStage((Map<Id, pse__proj__c>) Trigger.OldMap, (Map<Id, pse__proj__c>)Trigger.NewMap);		
        //HandleInProgressStage.handleInProgressStage((Map<Id, pse__proj__c>) this.TriggerOldMap, (Map<Id, pse__proj__c>) this.TriggerNewMap);
        // WorkOrderHandlerOnProjectStageChange.checkForInProgressWorkOrders((Map<Id, pse__proj__c>) this.TriggerOldMap, (Map<Id, pse__proj__c>) this.TriggerNewMap);
        //ProjectDateHandler.preventDateUpdates((Map<Id, pse__proj__c>)this.TriggerOldMap, (Map<Id, pse__proj__c>)this.TriggerNewMap);
        // populate eac coast
        //ProjectTriggerHandler.populateAsPlannedRevenueAndEacRevenue(this.TriggerNew,(Map<Id, pse__proj__c>) this.TriggerOldMap);
        //ProjectTriggerHandler.populatePdmUser(Trigger.New, (Map<Id, pse__proj__c>)Trigger.OldMap, false);
		       
    }
    
    private void filterRecordsByRecordType() {
        Set<Id> ffRecordTypes = RecordTypeHelper.getRecordTypeIds(RecordTypeHelper.getTriggerHandlerConfig('pse__Proj__c', FFProjectTriggerHandler.class.getName()), Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName());
        
        Boolean hasFFRT = false;
        
        this.TriggerNewMap = new Map<Id, pse__Proj__c>();
        this.TriggerOldMap = new Map<Id, pse__Proj__c>();
        this.TriggerNew = new List<pse__Proj__c>();
        this.TriggerOld = new List<pse__Proj__c>();
        
        //mount triggerNewMap
        if (Trigger.NewMap != null) {
            for (Id projId : Trigger.NewMap.keySet()) {
                pse__Proj__c projNew = (pse__Proj__c) Trigger.NewMap.get(projId);
                if (ffRecordTypes.contains(projNew.RecordTypeId) && !projNew.pse__Is_Template__c) {
                    hasFFRT = true;
                    this.TriggerNewMap.put(projId, projNew);
                }
            }
        }
        //mount triggerOldMap
        if (Trigger.OldMap != null) {
            for (Id projId : Trigger.OldMap.keySet()) {
                pse__Proj__c projOld = (pse__Proj__c) Trigger.OldMap.get(projId);
                if (ffRecordTypes.contains(projOld.RecordTypeId) && !projOld.pse__Is_Template__c || this.TriggerNewMap.containsKey(projId)) {
                    hasFFRT = true;
                    this.TriggerOldMap.put(projId, projOld);
                }
            }
        }
        //mount triggerNew
        if (Trigger.New != null) {
            for (pse__Proj__c projNew : (List<pse__Proj__c>) Trigger.New) {
                if (ffRecordTypes.contains(projNew.RecordTypeId) && !projNew.pse__Is_Template__c) {
                    hasFFRT = true;
                    this.TriggerNew.add(projNew);
                }
            }
        }
        //mount triggerOld
        if (Trigger.Old != null) {
            for (pse__Proj__c projOld : (List<pse__Proj__c>) Trigger.Old) {
                if (ffRecordTypes.contains(projOld.RecordTypeId) && !projOld.pse__Is_Template__c) {
                    hasFFRT = true;
                    this.TriggerOld.add(projOld);
                }
            }
        }
        
        if (hasFFRT) {
            system.debug('Continue with FFProjectTriggerHandler. Other handlers should be bypassed.');
        } else {
            //TriggerHandler.bypass(FFProjectTriggerHandler.class.getName());
        }
    }
    
    private void sendEventOpenText() {        
        if (OT_TriggerController.projectTriggerEnabled) {
            Id engagementRecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
            
            List<ID> idList = new List<ID>();
            
            for (pse__Proj__c prj : (List<pse__proj__c>)Trigger.new) {
                //Workspaces should only be created to child projects
                if(prj.RecordTypeId != engagementRecordTypeId){
                    idList.add(prj.ID);
                }
            }
            
            if(idList.size() > 0) {
                //XECMFacade.raiseStandardEvent(idList, new List<String> { 'Project' });
            }
        }
    }
}