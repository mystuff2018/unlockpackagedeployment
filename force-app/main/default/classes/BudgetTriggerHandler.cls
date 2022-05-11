/***************************************************************************************
* Created By - Vinod Kumar ( Appirio JDC)
* Created On - November 06, 2020
* Related Task - S-677105
* Purpose - Handler class for pse__Budget__c object trigger
****************************************************************************************/
public class BudgetTriggerHandler extends TriggerHandler{
    public Map<Id, pse__Budget__c> triggerNewMap { get; set; }
    public Map<Id, pse__Budget__c> triggerOldMap { get; set; }
    public List<pse__Budget__c> triggerNew { get; set; }
    public List<pse__Budget__c> triggerOld { get; set; }
    
    public BudgetTriggerHandler(){
        if(TriggerHandler.isBypassed(BudgetTriggerHandler.class.getName()))
           return;
        filterRecordsByRecordType();
    }
    private void filterRecordsByRecordType() {
        
        this.triggerNewMap = new Map<Id, pse__Budget__c>();
        this.triggerOldMap = new Map<Id, pse__Budget__c>();
        this.triggerNew = new List<pse__Budget__c>();
        this.triggerOld = new List<pse__Budget__c>();
        
        //mount triggerNewMap
        if (Trigger.NewMap != null) {
            this.triggerNewMap = (Map<Id, pse__Budget__c>)Trigger.NewMap;
        }
        //mount triggerOldMap
        if (Trigger.OldMap != null) {
            this.triggerOldMap = (Map<Id, pse__Budget__c>)Trigger.OldMap;
        }
        //mount triggerNew
        if (Trigger.New != null) {
            this.triggerNew = (List<pse__Budget__c>) Trigger.New;
        }
        //mount triggerOld
        if (Trigger.Old != null) {
            this.triggerOld = (List<pse__Budget__c>) Trigger.Old;
        }
        
    }
    public override void beforeInsert() {
        
    }
    public override void afterInsert() {
        map<id,pse__Proj__c> mapUpdatedProject = new map<id,pse__Proj__c>();
        rollUpAmountOnProject(mapUpdatedProject,this.triggerNew,null);
        updateProjects(mapUpdatedProject);
        setTransactionAmount(triggerNew,null);
    }
    public override void beforeUpdate() {
       
    }
    public override void afterUpdate() {
        map<id,pse__Proj__c> mapUpdatedProject = new map<id,pse__Proj__c>();
        rollUpAmountOnProject(mapUpdatedProject,this.triggerNew,this.triggerOldMap);
        updateProjects(mapUpdatedProject);
        setTransactionAmount(triggerNew,null);
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
        /*TriggerHandler.bypass(FFProjectTriggerHandler.class.getName()); 
        TriggerHandler.bypass(ESProjectTriggerHandler.class.getName());*/
        TriggerHandler.bypass(FFProjectTriggerHandler.class.getName()); 
        update mapUpdatedProject.values(); 
        /*TriggerHandler.clearBypass(FFProjectTriggerHandler.class.getName()); 
        TriggerHandler.clearBypass(ESProjectTriggerHandler.class.getName()); */
        TriggerHandler.clearBypass(FFProjectTriggerHandler.class.getName()); 
    }
/************************************************************************************
* Created By - Vinod Kumar ( Appirio JDC)
* Created On - November 06, 2020
* Related Task - T-910090
* Purpose - Roll Up  Budget.Amount where Status=Approved, Type=Expense on Project.Planned_Cost_from_Expenses__c 
          - and Project.EAC_Cost_from_Expenses__c
*         - 
***********************************************************************************/
    public static void rollUpAmountOnProject(map<id,pse__Proj__c> mapUpdatedProject,list<pse__Budget__c> newList,Map<Id, pse__Budget__c> oldMap){
        set<id> projId = new Set<id>();
        for(pse__Budget__c bg : newList){
            if(bg.pse__Project__c != Null && 
             (oldMap == Null && bg.pse__Status__c == 'Approved' && bg.pse__Type__c == 'Expense' && bg.pse__Amount__c != Null)
             || (oldMap != Null  && bg.pse__Status__c == 'Approved' && bg.pse__Type__c == 'Expense' 
                 && (bg.pse__Amount__c != oldMap.get(bg.Id).pse__Amount__c  || bg.pse__Status__c != oldMap.get(bg.Id).pse__Status__c || bg.pse__Type__c != oldMap.get(bg.Id).pse__Type__c
                    || bg.Actual_Expenses__c != oldMap.get(bg.Id).Actual_Expenses__c))){
                projId.add(bg.pse__Project__c);
            }
        }
        
        if(!projId.isEmpty()){
            for(pse__Budget__c budget : [Select id,pse__Amount__c,pse__Project__c,pse__Billable__c ,Actual_Expenses__c from pse__Budget__c 
                                          WHERE pse__Project__c IN : projId 
                                        and pse__Status__c = 'Approved' and pse__Type__c = 'Expense']){
                if(!mapUpdatedProject.containsKey(budget.pse__Project__c)){
                    mapUpdatedProject.put(budget.pse__Project__c, new pse__Proj__c(Id = budget.pse__Project__c,Planned_Expenses__c = null , EAC_Cost_from_Expenses__c = null));
                    System.debug('mapUpdatedProject'+mapUpdatedProject);
                }
                pse__proj__c project = mapUpdatedProject.get(budget.pse__Project__c);
                if(budget.pse__Amount__c != null){
                    // planned cost from expense sum of billable bidget Amount
                    if(budget.pse__Billable__c && budget.pse__Amount__c != null){
                       project.Planned_Expenses__c = project.Planned_Expenses__c == null ? budget.pse__Amount__c : (project.Planned_Expenses__c + budget.pse__Amount__c) ; 
                    	System.debug('Planned_Expenses__c'+project.Planned_Expenses__c);
                    }    
                    // sum of Actual_Expenses__c
                    if(budget.Actual_Expenses__c != null){
                        project.Actual_Expenses__c = project.Actual_Expenses__c == null ? budget.Actual_Expenses__c : (project.EAC_Cost_from_Expenses__c + budget.Actual_Expenses__c) ;
                        System.debug('Planned_Expenses__c'+project.Planned_Expenses__c);
                        project.EAC_Cost_from_Expenses__c = project.EAC_Cost_from_Expenses__c == null ? budget.Actual_Expenses__c : (project.EAC_Cost_from_Expenses__c + budget.Actual_Expenses__c) ;
                        System.debug('Planned_Expenses__c'+project.Planned_Expenses__c);
                    }else if(budget.pse__Amount__c != null){
                        project.EAC_Cost_from_Expenses__c = project.EAC_Cost_from_Expenses__c == null ? budget.pse__Amount__c : (project.EAC_Cost_from_Expenses__c + budget.pse__Amount__c) ;     
                     }
                    //  As planned revenue will be sum of  amount of non billable budget  
                    
                }
            }
            // handle all delete 
            for(Id pID : projId){
                if(!mapUpdatedProject.containsKey(pID)){
                    // all budget deleted
                   pse__proj__c project = new pse__Proj__c(Id = pID);
                   project.Planned_Expenses__c = null;
                   project.EAC_Cost_from_Expenses__c = null;
                   project = mapUpdatedProject.put(project.Id, project);
                }
            }
        }
    }
    
    public static void setTransactionAmount(list<pse__Budget__c> budgetList,Map<Id, pse__Budget__c> oldMap){
        
        set<ID>setBudgetID = new set<ID>();
        for(pse__Budget__c b: budgetList){
            if(b.pse__Type__c == 'Expense'){
                setBudgetID.add(b.ID);
            }
        }
        if(setBudgetID.size() > 0){
            list<pse__Transaction__c> lstTransaction = new list<pse__Transaction__c>();
            
            for(pse__Transaction__c tr: [Select ID,pse__Amount__c from pse__Transaction__c where pse__Budget__c in: setBudgetID and pse__Category__c ='Internal Budget' and pse__Amount__c !=0]){
                tr.pse__Amount__c = 0;
                lstTransaction.add(tr);
            }
            if(!lstTransaction.isEmpty() || lstTransaction.size()>0){ //Added size check as a part of checkMarx 
                update lstTransaction;
            }
        }
    }
    
    
}