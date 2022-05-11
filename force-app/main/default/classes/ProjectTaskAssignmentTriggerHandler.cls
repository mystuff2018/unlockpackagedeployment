/***************************************************************************************
* Created By - LavaKumar T
* Created On - Feb 19,2021
* Related Task - 10045691
* Purpose - Handler class for pse__Project_Task_Assignment__c object trigger
****************************************************************************************/
public class ProjectTaskAssignmentTriggerHandler extends TriggerHandler {
    
    public Map<Id, pse__Project_Task_Assignment__c> TriggerNewMap { get; set; }
    public Map<Id, pse__Project_Task_Assignment__c> TriggerOldMap { get; set; }
    public List<pse__Project_Task_Assignment__c> TriggerNew { get; set; }
    public List<pse__Project_Task_Assignment__c> TriggerOld { get; set; }
     
    public static set<Id> tasksForAssignmentsDeleted = new set<Id>();
    
    
    public ProjectTaskAssignmentTriggerHandler(){ 
        if(TriggerHandler.isBypassed(ProjectTaskAssignmentTriggerHandler.class.getName()))
           return;
        filterRecordsByRecordType();
    }
    private void filterRecordsByRecordType() {
        system.debug('INSIDE TRIGGER::::');
        this.TriggerNewMap = new Map<Id, pse__Project_Task_Assignment__c>();
        this.TriggerOldMap = new Map<Id, pse__Project_Task_Assignment__c>();
        this.TriggerNew = new List<pse__Project_Task_Assignment__c>();
        this.TriggerOld = new List<pse__Project_Task_Assignment__c>();
        
        //mount triggerNewMap
        if (Trigger.NewMap != null) {
            this.TriggerNewMap = (Map<Id, pse__Project_Task_Assignment__c>)Trigger.NewMap;
        }
        //mount triggerOldMap
        if (Trigger.OldMap != null) {
        }
        //mount triggerNew
        if (Trigger.New != null) {
            this.TriggerNew = (List<pse__Project_Task_Assignment__c>) Trigger.New ;
            
        }
        //mount triggerOld
        if (Trigger.Old != null) {
        }
        
    }
    public override void beforeInsert(){
        
    }
    public override void afterInsert() {
        map<id,pse__Project_Task__c> mapUpdatedProjectTask = new map<id,pse__Project_Task__c>();
        mapUpdatedProjectTask = popualateRateCardProjectTask(this.TriggerNew,mapUpdatedProjectTask);
        updateProjectTask(mapUpdatedProjectTask);
    } 
    public override void beforeUpdate(){
        
    }
    
    public override void beforeDelete() {
        for(pse__Project_Task_Assignment__c assignment: (List<pse__Project_Task_Assignment__c>) Trigger.Old ){
            tasksForAssignmentsDeleted.add(assignment.pse__Project_Task__c);
        }
    }
    
    public override void afterUpdate(){
        
    }
    
    
    public void updateProjectTask(map<id,pse__Project_Task__c> mapUpdatedProjectTask) {
        //TriggerHandler.bypass(FFProjectTaskTriggerHandler.class.getName()); 
        //TriggerHandler.bypass(CsProjectTaskHandler.class.getName()); 
        update mapUpdatedProjectTask.values();
        //TriggerHandler.clearBypass(FFProjectTaskTriggerHandler.class.getName()); 
        //TriggerHandler.clearBypass(CsProjectTaskHandler.class.getName()); 
        
    }
    public static map<id,pse__Project_Task__c> popualateRateCardProjectTask(list<pse__Project_Task_Assignment__c> newLst,map<id,pse__Project_Task__c> mapUpdatedProjectTask){
        set<Id> projectTaskId = new set<Id>();
        set<string> setSelectedRoles = new set<string>();
        set<ID> selectedResourceIds = new set<ID>();
        map<pse__Project_Task__c,string> mapTaskWithRole = new map<pse__Project_Task__c,string>();
        list<pse__Project_Task__c> lstPrjTskToUpdate = new list<pse__Project_Task__c>();
        list<pse__Project_Task_Assignment__c> selectedPTA = new list<pse__Project_Task_Assignment__c>();
        map<ID,ID> mapPTAIDWithResourceID = new map<ID,ID>();
        for(pse__Project_Task_Assignment__c pta : newLst){
            if(pta.pse__Resource__c != null){
                selectedResourceIds.add(pta.pse__Resource__c);
                projectTaskId.add(pta.pse__Project_Task__c);
                selectedPTA.add(pta);
                mapPTAIDWithResourceID.put(pta.ID,pta.pse__Resource__c);
            }
        }
        if(!projectTaskId.isEmpty()){
            map<ID,String>mapResourceIDWithRole = new map<Id,String>();
            // get selected resource role
            for(Contact c:[Select ID, pse__Resource_Role__c from Contact where ID in: selectedResourceIds and pse__Resource_Role__c != null]){
                setSelectedRoles.add(c.pse__Resource_Role__c); 
                mapResourceIDWithRole.put(c.ID,c.pse__Resource_Role__c);
            }
            map<ID,pse__Project_Task__c> mapSelectedProjectTask = new map<ID,pse__Project_Task__c>([Select id,Resource_Role__c,pse__Project__c,pse__Actual_Hours__c,pse__Estimated_Hours__c,Bill_Rate_Card__c,
                                                                  pse__Project__r.pse__Region__r.pse__Region_ID_Chain__c,
                                                                  Cost_Rate_Card__c,pse__Project__r.pse__Region__c,Bill_Rate__c FROM pse__Project_Task__c
                                                                  where Id In: projectTaskId AND pse__Project__c != null AND pse__Project__r.pse__Region__c != Null AND (pse__Number_of_Assignments__c = Null OR  pse__Number_of_Assignments__c <1)]);
         if(!mapSelectedProjectTask.isEmpty()){
            map<ID,pse__Rate_Card__c> mapProjectTaskWithRateCard = GetRateCard(mapSelectedProjectTask,setSelectedRoles,selectedPTA,mapPTAIDWithResourceID,mapResourceIDWithRole);
             for(pse__Project_Task_Assignment__c pta :selectedPTA){
                 if(mapSelectedProjectTask.ContainsKey(pta.pse__Project_Task__c)){
                     if(mapProjectTaskWithRateCard.containskey(pta.pse__Project_Task__c)){
                        if(!mapUpdatedProjectTask.containsKey(pta.pse__Project_Task__c)){
                            mapUpdatedProjectTask.put(pta.pse__Project_Task__c,mapSelectedProjectTask.get(pta.pse__Project_Task__c));
                        }
                         pse__Project_Task__c updateProjectTask = mapUpdatedProjectTask.get(pta.pse__Project_Task__c);
                        pse__Rate_Card__c rateCard = mapProjectTaskWithRateCard.get(pta.pse__Project_Task__c);
                        updateProjectTask.Bill_Rate_Card__c = rateCard.id ;
                        updateProjectTask.Cost_Rate_Card__c = rateCard.id ;
                        if(mapPTAIDWithResourceID.containsKey(pta.ID)){
                             ID resourceID = mapPTAIDWithResourceID.get(pta.ID);
                             if(mapResourceIDWithRole.containsKey(resourceID)){
                                 updateProjectTask.Resource_Role__c = mapResourceIDWithRole.get(resourceID);
                             }
                         }
                        updateProjectTask.Cost_Rate__c = rateCard.pse__Average_Cost_Rate__c ;
                         updateProjectTask.Bill_Rate__c = rateCard.pse__Suggested_Bill_Rate__c;
                        updateProjectTask.Actual_Cost__c = updateProjectTask.pse__Actual_Hours__c * rateCard.pse__Average_Cost_Rate__c ;
                        if(updateProjectTask.pse__Estimated_Hours__c != Null && rateCard.pse__Average_Cost_Rate__c != Null){
                            system.debug('Updating Cost rate:::::');
                            updateProjectTask.Planned_Cost__c = updateProjectTask.pse__Estimated_Hours__c * rateCard.pse__Average_Cost_Rate__c ;
                        }
                     }else{
                         // if no rate card is found for the role add an error
                        //if(! Test.isRunningTest()){
                            string role = pta.pse__Resource_Role__c;
                            if(mapResourceIDWithRole.containsKey(pta.pse__Resource__c)){
                            	role = mapResourceIDWithRole.get(pta.pse__Resource__c);
                          //  }
                            
                            pta.addError('Rate card not available for selected Resource Role : +'+role);
                        } 
                     }
                 }
                 
             }
             
        }
         
        }
        return mapUpdatedProjectTask;
    }
    
    public static map<ID,pse__Rate_Card__c> GetRateCard(map<ID,pse__Project_Task__c> mapSelectedProjectTask,Set<string> roles,list<pse__Project_Task_Assignment__c> selectedPTA,map<ID,ID> mapPTAIDWithResourceID,map<ID,String>mapResourceIDWithRole){
        list<String> allParentRegion = new list<string>();
        map<ID,pse__Rate_Card__c> mapProjectTaskWithRateCard = new map<ID,pse__Rate_Card__c>();
        for(pse__Project_Task__c pt:mapSelectedProjectTask.values()){
            list<string> lstParent = pt.pse__Project__r.pse__Region__r.pse__Region_ID_Chain__c.split(',');
            allParentRegion.addAll(lstParent);
        }
        system.debug('allParentRegion:::::'+allParentRegion);
        // get all rate card for selected role
        map<string,pse__Rate_Card__c>mapRegionWithRateCard = new map<string,pse__Rate_Card__c>();
        for (pse__Rate_Card__c rc:[Select ID, pse__Role__c,pse__Region__c,pse__Average_Cost_Rate__c,pse__Suggested_Bill_Rate__c from pse__Rate_Card__c where pse__Role__c in : roles and pse__Region__c in :allParentRegion]){
            string strKey = rc.pse__Region__c + '#'+ rc.pse__Role__c;
            mapRegionWithRateCard.put(strKey ,rc);
        }
        // get rate card
        // selectedProjectTask
        for(pse__Project_Task_Assignment__c pta :selectedPTA){
            if(mapSelectedProjectTask.containsKey(pta.pse__Project_Task__c) ){
                pse__Project_Task__c pt = mapSelectedProjectTask.get(pta.pse__Project_Task__c);
                list<string> lstParent = pt.pse__Project__r.pse__Region__r.pse__Region_ID_Chain__c.split(',');
                for(string region: lstParent){
                    string strKey = region + '#';
                    system.debug('mapPTAIDWithResourceID:::::'+mapPTAIDWithResourceID);
                    system.debug('mapResourceIDWithRole:::::'+mapResourceIDWithRole);
                    system.debug('pta.ID:::::'+pta.ID);
                    if(mapPTAIDWithResourceID.containsKey(pta.ID)){
                         ID resourceID = mapPTAIDWithResourceID.get(pta.ID);
                         if(mapResourceIDWithRole.containsKey(resourceID)){
                             strKey = strKey + mapResourceIDWithRole.get(resourceID);
                         }
                         
                     }
                    system.debug('strKey:::::'+strKey);
                    if(mapRegionWithRateCard.containsKey(strKey)){
                        mapProjectTaskWithRateCard.put(pt.ID,mapRegionWithRateCard.get(strKey));
                        system.debug('mapProjectTaskWithRateCard:::::'+mapProjectTaskWithRateCard);
                        break;
                    }
                }
            }
            
            
        }
        return mapProjectTaskWithRateCard;
    }
}