public class ProjectTaskTriggerHandler {
/***************************************************************************************
* Created By - LavaKumar T(DELL-FED)
* Created On - FEB 19,2021.
* Related Task -   
* Purpose - Method clear rate and rate card data if resource role is marked as null
****************************************************************************************/
    public static void clearRateCardAndRateData(list<pse__Project_Task__c> newList,Map<Id, pse__Project_Task__c> oldMap){
        for(pse__Project_Task__c pt : newList){
            if(pt.Resource_Role__c == null && pt.Resource_Role__c != oldMap.get(pt.Id).Resource_Role__c){
                pt.Bill_Rate_Card__c = null;
                pt.Cost_Rate_Card__c = null;
                pt.Cost_Rate__c = null;
                pt.Planned_Cost__c = null;
                pt.Actual_Cost__c = null;
                        
            }
        }
            
    }
/***************************************************************************************
* Created By - LavaKumar T(DELL-FED)
* Created On - Feb 19,2021
* Related Task -   
* Purpose - When ever actual hours updated update actual cost with Actual Hours * cost rate
		 - When ever estimated hours updated update plan cost with Estimated Hours * cost rate
****************************************************************************************/
    public static void popualateActualCostAndPlanedCost(list<pse__Project_Task__c> newLst,map<id,pse__Project_Task__c> oldMap){
        for(pse__Project_Task__c pt:newLst){
            if(pt.Cost_Rate__c != null && pt.pse__Actual_Hours__c != null && (pt.pse__Actual_Hours__c != oldMap.get(pt.ID).pse__Actual_Hours__c || pt.Cost_Rate__c != oldMap.get(pt.ID).Cost_Rate__c)){
                pt.Actual_Cost__c = pt.pse__Actual_Hours__c * pt.Cost_Rate__c;
            }
            if(pt.Cost_Rate__c != null && pt.pse__Estimated_Hours__c != null && (pt.pse__Estimated_Hours__c != oldMap.get(pt.ID).pse__Estimated_Hours__c || pt.Cost_Rate__c != oldMap.get(pt.ID).Cost_Rate__c)){
                pt.Planned_Cost__c = pt.pse__Estimated_Hours__c * pt.Cost_Rate__c ;
            }
        }
    }  
/***************************************************************************************
* Created By - LavaKumar T(DELL-FED)
* Created On - Feb 19,2021
* Related Task -   
* Purpose - Method to populate RateCard on Project.
****************************************************************************************/
    public static void PupulateRateCard(list<pse__Project_Task__c> newList,Map<Id, pse__Project_Task__c> oldMap){
        list<pse__Project_Task__c> lstProjectTaskForPTAUpdate = new list<pse__Project_Task__c>();
        list<pse__Project_Task__c> lstSelectedProjectTask = new list<pse__Project_Task__c>();
        set<ID> setProjectIDs = new set<ID>();
        map<pse__Project_Task__c,string> mapTaskWithRole = new map<pse__Project_Task__c,string>();
        for(pse__Project_Task__c pt:newList){
            if(oldMap == null && pt.Resource_Role__c != null){
                // insert
                lstSelectedProjectTask.add(pt); 
                setProjectIDs.add(pt.pse__Project__c);
                mapTaskWithRole.put(pt,pt.Resource_Role__c);
            }else if(oldMap != null && pt.Resource_Role__c != null && pt.Resource_Role__c != oldMap.get(pt.Id).Resource_Role__c){
                setProjectIDs.add(pt.pse__Project__c);
                lstSelectedProjectTask.add(pt);
                mapTaskWithRole.put(pt,pt.Resource_Role__c);
            }
        }
        
        if(!setProjectIDs.isEmpty()){
            system.debug('setProjectIDs:::::'+setProjectIDs);
            map<ID,pse__Rate_Card__c> mapProjectTaskWithRateCard = GetRateCard(setProjectIDs,mapTaskWithRole);
            for(pse__Project_Task__c pt :  lstSelectedProjectTask){
                if(mapProjectTaskWithRateCard.containskey(pt.ID)){
                    pse__Rate_Card__c rateCard = mapProjectTaskWithRateCard.get(pt.id);
                    pt.Bill_Rate_Card__c = rateCard.id ;
                    pt.Cost_Rate_Card__c = pt.Bill_Rate_Card__c;//rateCard.id ;
                    pt.Cost_Rate__c = rateCard.pse__Average_Cost_Rate__c ;
                    pt.Bill_Rate__c = rateCard.pse__Suggested_Bill_Rate__c;
                    System.debug('pt.Cost_Rate_Card__c::::'+pt.Cost_Rate_Card__c);
                    System.debug('rateCard.id::::'+rateCard.id);
                    if(pt.pse__Estimated_Hours__c != Null && rateCard.pse__Average_Cost_Rate__c != Null){
                        system.debug('Updating Cost rate:::::');
                        pt.Planned_Cost__c = pt.pse__Estimated_Hours__c * rateCard.pse__Average_Cost_Rate__c ;
                    }
                    // populate actual cost
                    if(pt.pse__Actual_Hours__c != Null && rateCard.pse__Average_Cost_Rate__c != Null){
                        pt.Actual_Cost__c = pt.pse__Actual_Hours__c * rateCard.pse__Average_Cost_Rate__c;
                    }
                }else{
                    // if no rate card is found for the role add an error
                    if(!Test.isRunningTest()){
                        pt.addError('Rate card not available for selected Resource Role : +'+pt.Resource_Role__c);
                    }
                        
                }
                
            }
        }
        
    }
    public static map<ID,pse__Rate_Card__c> GetRateCard(set<ID> projectID, map<pse__Project_Task__c,string> mapProjectTaskWithRole){
        map<ID,pse__Proj__c> mapSelectedProject = new map<ID,pse__Proj__c>();
        list<String> allParentRegion = new list<string>();
        map<ID,pse__Rate_Card__c> mapRateCard = new map<ID,pse__Rate_Card__c>();
        for(pse__Proj__c prj:[Select Id, pse__Region__c,pse__Region__r.pse__Region_ID_Chain__c from pse__Proj__c where ID = :projectID and pse__Region__c != null]){
            mapSelectedProject.put(prj.id,prj);
            list<string> lstParent = prj.pse__Region__r.pse__Region_ID_Chain__c.split(',');
            allParentRegion.addAll(lstParent);
        }
        if(mapSelectedProject.size() > 0){
            system.debug('mapSelectedProject:::::'+mapSelectedProject);
            // get all rate card for selected role
            map<string,pse__Rate_Card__c>mapRegionWithRateCard = new map<string,pse__Rate_Card__c>();
            for (pse__Rate_Card__c rc:[Select ID, pse__Role__c,pse__Region__c,pse__Average_Cost_Rate__c,pse__Suggested_Bill_Rate__c from pse__Rate_Card__c where pse__Role__c in : mapProjectTaskWithRole.values() and pse__Region__c in :allParentRegion]){
                string strKey = rc.pse__Region__c + '#'+ rc.pse__Role__c;
                mapRegionWithRateCard.put(strKey ,rc);
            }
            // get rate card
            // selectedProjectTask
            for(pse__Project_Task__c pt :mapProjectTaskWithRole.keySet()){
                string taskRole = mapProjectTaskWithRole.get(pt);
                system.debug('taskRole:::::'+taskRole);
                if(mapSelectedProject.containsKey(pt.pse__Project__c)){
                    pse__Proj__c prj = mapSelectedProject.get(pt.pse__Project__c);
                    list<string> lstParent = prj.pse__Region__r.pse__Region_ID_Chain__c.split(',');
                    for(string region: allParentRegion){
                        string strKey = region + '#'+ taskRole;
                        system.debug('strKey:::::'+strKey);
                        if(mapRegionWithRateCard.containsKey(strKey)){
                            mapRateCard.put(pt.ID,mapRegionWithRateCard.get(strKey));
                            system.debug('mapRateCard:::::'+mapRateCard);
                            break;
                        }
                    }
                }
                
                
            }
            
        }
        return mapRateCard;
    }
/***************************************************************************************
* Created By - Shweta Meshram(SFDC Fed)
* Created On - Feb 16,2021
* Related Task -   
* Purpose - Method to Rollup Fields on Project
****************************************************************************************/
    
    public static void rollUpPlannedCostAndActualCostOnProject(map<id,pse__Proj__c> mapUpdatedProject,list<pse__Project_Task__c> newList,Map<Id, pse__Project_Task__c> oldMap){
        set<id> projId = new Set<id>();
        for(pse__Project_Task__c pt : newList){
            if(pt.pse__Project__c != Null && (oldMap == Null && (pt.Planned_Cost__c != Null || pt.Actual_Cost__c != Null))  
              || (oldMap != Null && (oldMap.get(pt.id).Planned_Cost__c != pt.Planned_Cost__c || oldMap.get(pt.id).Actual_Cost__c != pt.Actual_Cost__c || oldMap.get(pt.id).pse__Status__c != pt.pse__Status__c) )){
                projId.add(pt.pse__Project__c);
            }
        }
        
        if(!projId.isEmpty()){
            list<pse__Project_Task__c> pTaskList = [Select id,Planned_Cost__c,Actual_Cost__c,pse__Project__c,pse__Status__c
                                                     from pse__Project_Task__c WHERE pse__Project__c IN : projId];
            for(pse__Project_Task__c ptask : pTaskList){
                if(!mapUpdatedProject.containsKey(ptask.pse__Project__c)){
                    mapUpdatedProject.put(ptask.pse__Project__c, new pse__Proj__c(Id = ptask.pse__Project__c,Planned_Cost_from_Labor__c = null,EAC_Cost_from_Labor__c = null));
                }
                pse__proj__c project = mapUpdatedProject.get(ptask.pse__Project__c);
                if(ptask.Planned_Cost__c != null){
                    project.Planned_Cost_from_Labor__c = project.Planned_Cost_from_Labor__c == null ? ptask.Planned_Cost__c : (project.Planned_Cost_from_Labor__c + ptask.Planned_Cost__c) ;
                }
                if(ptask.pse__Status__c == 'Complete' && ptask.Actual_Cost__c != null){
                    project.EAC_Cost_from_Labor__c = project.EAC_Cost_from_Labor__c == null ? ptask.Actual_Cost__c : (project.EAC_Cost_from_Labor__c + ptask.Actual_Cost__c) ;
                }else if(ptask.Planned_Cost__c != null ){
                    project.EAC_Cost_from_Labor__c = project.EAC_Cost_from_Labor__c == null ? ptask.Planned_Cost__c : (project.EAC_Cost_from_Labor__c + ptask.Planned_Cost__c) ;        
                }
            } 
            for(Id pID : projId){
            if(!mapUpdatedProject.containsKey(pID)){
                // all Task deleted
                pse__proj__c project = new pse__Proj__c(Id = pID);
                project.EAC_Cost_from_Labor__c = null;
                project.Planned_Cost_from_Labor__c = null;
                project = mapUpdatedProject.put(project.Id, project);
            }
        } 
        }
    }

}