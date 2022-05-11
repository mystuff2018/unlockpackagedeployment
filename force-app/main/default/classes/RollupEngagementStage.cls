/**
*   
*  Date             Developer           Tag           Summary of Changes 
*  *********************************************************************************************************************
*  2020-05-15       Filipe Hoffmeister  7622206       Multi projects structure - Project To Engagement Stage Rollup
*
*  *********************************************************************************************************************
*  
*/

public class RollupEngagementStage {
    public static Map<Id, pse__Proj__c> rollupEngagementStage(List<pse__Proj__c> oldProjs, List<pse__Proj__c> newProjs) {
        Map<Id, pse__Proj__c> engagementsToUpdateMap = new Map<Id, pse__Proj__c>();
        List<pse__Proj__c> projs = getProjectsToRollupEngagement(oldProjs, newProjs);
        if (projs != null && projs.size() > 0) {
            Set<Id> engagementIds = new Set<Id>();
            for (pse__Proj__c proj : projs) {
                if (proj.pse__Parent_Project__c != null) { 
                    engagementIds.add(proj.pse__Parent_Project__c);
                }
            }
            engagementsToUpdateMap.putAll(rollupEngagementStage(engagementIds));
            
        }

        return engagementsToUpdateMap;
    }

    public static Map<Id, pse__Proj__c> rollupEngagementStage(Set<Id> engagementIds) {
        Map<Id, pse__Proj__c> engagementsToUpdateMap = new Map<Id, pse__Proj__c>();
        //system.debug('EngagementIds##: '+engagementIds);           
        if (engagementIds != null && engagementIds.size() > 0) {
            Map<Id, List<pse__Proj__c>> projectsByEngagementId =  DAL_Project.getProjectByEngamentId(new List<Id>(engagementIds));
            Map<Id, pse__Proj__c> engagementsMap = DAL_Project.getProjectByIds(projectsByEngagementId.keySet());
            //system.debug('projectsByEngagementId###: '+projectsByEngagementId);
            for (Id engagementId : projectsByEngagementId.keySet()) {
                List<pse__Proj__c> projects = projectsByEngagementId.get(engagementId);
                pse__Proj__c engagement = engagementsMap.get(engagementId);
                for (pse__Proj__c proj : projects) {
                    if (proj.pse__Parent_Project__c != null) {
                        //If 1 child project is "In Progress", then Engagement should be "In Progress) AC01
                        if (proj.pse__Stage__c == 'In Progress' || proj.pse__Stage__c == 'Draft') {
                            engagementsToUpdateMap.put(engagement.Id, updateEngagement(engagement.Id,'In Progress'));
                            break;
                        } else {
                            Boolean shouldUpdateEngagement = isAllChildProjectsSameStage(projects, new List<string>{proj.pse__Stage__c});
                            //If all child projects are in same stage then Engagement should be this state AC02, AC03
                            if (shouldUpdateEngagement) {
                                engagementsToUpdateMap.put(engagement.Id, updateEngagement(engagement.Id, proj.pse__Stage__c));
                                break;
                            } else {
                                //If all child projects are in Cancelled or Closure state, then engagement should be closure AC04
                                Boolean shouldUpdateEngagementCancelledOrClosure = isAllChildProjectsSameStage(projects, new List<string>{ 'Cancelled', 'Closure'});
                                if (shouldUpdateEngagementCancelledOrClosure) {
                                    engagementsToUpdateMap.put(engagement.Id, updateEngagement(engagement.Id,'Closure'));
                                    break;
                                }
                            }
                        }
                    } 
                }
            }
        }

        return engagementsToUpdateMap;
    }    

    private static pse__Proj__c updateEngagement(Id engagementId, String stage) {
        return new pse__Proj__c(Id = engagementId, pse__Stage__c = stage);
        //If is "On hold", needs On Hold reason
        //if (engagement.pse__Stage__c == 'On Hold') {
        //    engagement.On_Hold_Reason__c = proj.On_Hold_Reason__c;
        //} else if (engagement.pse__Stage__c == 'Closure') {
        //    engagement.pse__Project_Phase__c =  proj.pse__Project_Phase__c;
        //    engagement.Delivery_and_Implementation__c =  proj.Delivery_and_Implementation__c;
        //    engagement.Closure_Reason__c = proj.Closure_Reason__c;
        //    engagement.Initiate_Customer_Contact__c = proj.Initiate_Customer_Contact__c;
        //}
    }

    private static Boolean isAllChildProjectsSameStage(List<pse__Proj__c> projects, List<String> stage) {
        if (projects == null || projects.size() == 0) {
            return false;
        }
        for (pse__Proj__c proj : projects) {
            if(!stage.contains(proj.pse__Stage__c)) {    
                return false;
            }
        }
        return true;
    }

    /**
     * Iterate the oldProjs and newProjs list to verify if stage was changed.
     * @return a list of stage changed projects
     */
    private static List<pse__Proj__c> getProjectsToRollupEngagement(List<pse__Proj__c> oldProjs, List<pse__Proj__c> newProjs) {
        List<pse__Proj__c> projs = new List<pse__Proj__c>();
        if (oldProjs != null && newProjs != null) {
            for (pse__Proj__c oldProj : oldProjs) {
                for (pse__Proj__c newProj : newProjs) {
                    if (oldProj.Id == newProj.Id && oldProj.pse__Stage__c != newProj.pse__Stage__c) {
                        projs.add(newProj); 
                    }
                }
            }
        }
        return projs;    
    }
}