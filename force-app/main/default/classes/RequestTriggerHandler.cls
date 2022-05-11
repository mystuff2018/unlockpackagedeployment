/***************************************************************************************
* Created By - Shweta Meshram(Fed SFDC)
* Created On - Feb 17, 2021
* Related Task - 
* Purpose - Handler class for Request__c object trigger
****************************************************************************************/
public class RequestTriggerHandler extends TriggerHandler{
    public Map<Id, Request__c> triggerNewMap { get; set; }
    public Map<Id, Request__c> triggerOldMap { get; set; }
    public List<Request__c> triggerNew { get; set; }
    public List<Request__c> triggerOld { get; set; }
    
    public RequestTriggerHandler(){
        if(TriggerHandler.isBypassed(RequestTriggerHandler.class.getName()))
            return;
        filterRecordsByRecordType();
    }
    private void filterRecordsByRecordType() {
        
        this.triggerNewMap = new Map<Id, Request__c>();
        this.triggerOldMap = new Map<Id, Request__c>();
        this.triggerNew = new List<Request__c>();
        this.triggerOld = new List<Request__c>();
        
        //mount triggerNewMap
        if (Trigger.NewMap != null) {
            this.triggerNewMap = (Map<Id, Request__c>)Trigger.NewMap;
        }
        //mount triggerOldMap
        if (Trigger.OldMap != null) {
            this.triggerOldMap = (Map<Id, Request__c>)Trigger.OldMap;
           
        }
        //mount triggerNew
        if (Trigger.New != null) {
            this.triggerNew = (List<Request__c>) Trigger.New;
        }
        //mount triggerOld
        if (Trigger.Old != null) {
            this.triggerOld = (List<Request__c>) Trigger.Old;
        }
    }
    
      public override void beforeInsert() {
        populateProjectMangerFromProject(this.triggerNew);
    }
    
    public override void afterUpdate() {
        system.debug('Inside req afterupdate');
        map<id,pse__Proj__c> mapUpdatedProject = new map<id,pse__Proj__c>();
        rollUpAmountOnProject(mapUpdatedProject,this.triggerNew,this.triggerOldMap);
        updateProjects(mapUpdatedProject);
    }
    public override void afterDelete() {
        map<id,pse__Proj__c> mapUpdatedProject = new map<id,pse__Proj__c>();
        rollUpAmountOnProject(mapUpdatedProject,this.triggerOld,null);
        updateProjects(mapUpdatedProject);
    }
    public override void afterUnDelete() {
        map<id,pse__Proj__c> mapUpdatedProject = new map<id,pse__Proj__c>();
        rollUpAmountOnProject(mapUpdatedProject,this.triggerNew,null);
        updateProjects(mapUpdatedProject);
    }
    public void updateProjects(map<id,pse__Proj__c> mapUpdatedProject) {
        //TriggerHandler.bypass(FFProjectTriggerHandler.class.getName()); 
        //TriggerHandler.bypass(ESProjectTriggerHandler.class.getName());
        TriggerHandler.bypass(ProjectTriggerHandler.class.getName()); 
        update mapUpdatedProject.values(); 
        //TriggerHandler.clearBypass(FFProjectTriggerHandler.class.getName()); 
        //TriggerHandler.clearBypass(ESProjectTriggerHandler.class.getName()); 
        TriggerHandler.clearBypass(FFProjectTriggerHandler.class.getName()); 
    }
/************************************************************************************
* Created By - Shweta Meshram(Fed SFDC)
* Created On - Feb 17, 2021
* Related Task - 
* Purpose - Roll Up  Request.Total_PO_Value_all_line_items__c where RecordType=Purchase Order Request on Project.Planned_Cost_from_POs__c 
		  - and Project.EAC_Cost_from_POs__c
*		  - 
***********************************************************************************/    
    public static void rollUpAmountOnProject(map<id,pse__Proj__c> mapUpdatedProject,list<Request__c> newList,Map<Id, Request__c> oldMap){
        set<id> projId = new Set<id>();
        Id recordTypeId = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('PO_DO_New_Change').getRecordTypeId();
        for(Request__c bg : newList){
            if(bg.Project__c != Null && bg.RecordTypeId == recordTypeId || 
               oldMap == null  || (bg.Total_PO_Labor_Line_Amount__c  != oldMap.get(bg.Id).Total_PO_Labor_Line_Amount__c 
               || bg.Total_PO_Expense_Line_Amount__c  != oldMap.get(bg.Id).Total_PO_Expense_Line_Amount__c ||
                                  bg.Total_PO_Value_all_line_items__c  != oldMap.get(bg.Id).Total_PO_Value_all_line_items__c)){
                       projId.add(bg.Project__c);
                   }
        }
        system.debug('projId::::'+projId);
        if(!projId.isEmpty()){
            for(Request__c request : [Select id,Total_PO_Value_all_line_items__c,Total_PO_Labor_Line_Amount__c,Total_PO_Expense_Line_Amount__c  ,Project__c from Request__c 
                                      WHERE Project__c IN : projId 
                                      and RecordTypeId =: recordTypeId]){
                                          if(!mapUpdatedProject.containsKey(request.Project__c)){
                                              mapUpdatedProject.put(request.Project__c, new pse__Proj__c(Id = request.Project__c,EAC_Cost_from_POs__c = null , Planned_Cost_from_POs__c = null));
                                          }
                                          pse__proj__c project = mapUpdatedProject.get(request.Project__c);
                                          if(request.Total_PO_Value_all_line_items__c != null){
                                              project.Planned_Cost_from_POs__c = project.Planned_Cost_from_POs__c == null ? request.Total_PO_Value_all_line_items__c  : (project.Planned_Cost_from_POs__c + request.Total_PO_Value_all_line_items__c ) ;
                                              
                                          }
                                       /*   if(request.Total_PO_Labor_Line_Amount__c != null){
                                              project.Planned_Cost_from_POs__c = project.Planned_Cost_from_POs__c == null ? request.Total_PO_Labor_Line_Amount__c  : (project.Planned_Cost_from_POs__c + request.Total_PO_Labor_Line_Amount__c ) ;
                                              
                                          }*/
                                          if(request.Total_PO_Value_all_line_items__c != null){
                                              project.EAC_Cost_from_POs__c = project.EAC_Cost_from_POs__c == null ? request.Total_PO_Value_all_line_items__c : (project.EAC_Cost_from_POs__c + request.Total_PO_Value_all_line_items__c) ;
                                          }
                                          system.debug('project.Planned_Cost_from_POs__c::::'+project.Planned_Cost_from_POs__c);
                                          system.debug('project.EAC_Cost_from_POs__c::::'+project.EAC_Cost_from_POs__c);
                                      }
        }
        // handle all delete 
        for(Id pID : projId){
            if(!mapUpdatedProject.containsKey(pID)){
                // all budget deleted
                pse__proj__c project = new pse__Proj__c(Id = pID);
                project.EAC_Cost_from_POs__c = null;
                project.Planned_Cost_from_POs__c = null;
                project = mapUpdatedProject.put(project.Id, project);
            }
        }
    }
    
    /************************************************************************************
* Created By - Sivakumari Ediga
* Created On - February 14, 2022
* Related Task - S-11975860
* Purpose - If request has Project then populate PM from Related Project PM.
*		  - 
***********************************************************************************/    
    public static void populateProjectMangerFromProject(list<Request__c> newList){
        set<ID>setProjectIds = new set<ID>();
        list<Request__c> lstSelectedRequest = new list<Request__c>();
        for(Request__c r:newList){
            if(r.Project__c != null){
                setProjectIds.add(r.Project__c);
                lstSelectedRequest.add(r);
            } 
        }
        if(!lstSelectedRequest.isEmpty()){
            // get selected project's project manager
            map<ID,pse__proj__c>mapProject = new map<ID,pse__proj__c>([Select ID,pse__Project_Manager__c from pse__proj__c where id in :setProjectIds]);
            for(Request__c r:lstSelectedRequest){
                r.Project_Manager__c = mapProject.get(r.Project__c).pse__Project_Manager__c;
            }
        }
    }
    
}