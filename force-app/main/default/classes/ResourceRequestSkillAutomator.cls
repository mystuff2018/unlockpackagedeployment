public class ResourceRequestSkillAutomator {

    private static final String PM_COMPLEXITY = 'Project Management Complexity';
    private static final Map<String, Integer> SKILL_HOURS = new Map<String, Integer>{'Low' => 20, 'Medium' => 30, 'High' => 40};
    private static final String PROJECT_MANAGER = 'Project Manager';
    private static final String DEFAULT_MINIMUM_RATING = '1';
    private static Map<Id, List<pse__Resource_Request__c>> resourceRequestFromProject;
    private static Map<Id, List<pse__Resource_Skill_Request__c>> skillRequestFromResourceRequest;
    private static Map<Id, List<pse__Resource_Skill_Request__c>> skillRequestFromProject;
    private static Map<String, pse__Skill__c> skillByComplexity;

    /**
    * @deion recreate resource skill requests based on project entries skills.
    * @author Leonardo Santos & Elson Paim | 5/25/2020 
    * @return void
    **/
     public static void recalculateResourceSkillRequest(Map<Id, pse__Proj__c> projectMap, Map<Id, List<Skill_SKU_Effort_Map_Entry__c>> skillsSKUFromProject){

        buildResourceRequestFromProjectMap(projectMap.keySet());
        buildSkillRequestFromResourceRequestMap();

        List<pse__Resource_Skill_Request__c> skillsToDelete = new List<pse__Resource_Skill_Request__c>();
        List<pse__Resource_Request__c> resourceRequestToUpdate = new List<pse__Resource_Request__c>();
        Map<String, pse__Resource_Skill_Request__c> skillRequestToCreate = new Map<String, pse__Resource_Skill_Request__c>();

        if(skillsSKUFromProject == null){
            skillsSKUFromProject = new Map<Id, List<Skill_SKU_Effort_Map_Entry__c>>();
        }

        String externalID = ResourceRequestCustomSetting__c.getOrgDefaults().SabaID__c;

        List<pse__Skill__c> complexitySkillToCreate = [SELECT Id, Name, pse__External_Id__c FROM pse__Skill__c WHERE pse__External_Id__c = :externalID  LIMIT 1];

        if (complexitySkillToCreate.size() != 0) {
        
            for(pse__Proj__c project : projectMap.values()){

                //pse__Skill__c complexitySkillToCreate = skillByComplexity.get(project.Project_Complexity__c);
                List<pse__Resource_Request__c> resourceRequestList = resourceRequestFromProject.get(project.Id);
    
                if(resourceRequestList != null){
    
                    for(pse__Resource_Request__c resourceRequest: resourceRequestList){
                        
                        List<pse__Resource_Skill_Request__c> existingSkillRequest = skillRequestFromResourceRequest.get(resourceRequest.Id);
                        if(existingSkillRequest != null){
                            skillsToDelete.addAll(existingSkillRequest);
                        }
                        
                        List<Skill_SKU_Effort_Map_Entry__c> entrySkillToCreateSkilRequest = skillsSKUFromProject.get(project.Id);
                        if(entrySkillToCreateSkilRequest == null){
                            entrySkillToCreateSkilRequest = new List<Skill_SKU_Effort_Map_Entry__c>();
                        }
    
                        // Mock a Skill_SKU_Effort_Map_Entry__c to create the skill request from project complexity
                         String testMinimumRating = '3';
                        
                            if (project.Project_Complexity__c == 'Low'){
                                testMinimumRating = '3';
    
                            }else if (project.Project_Complexity__c == 'Medium'){
                                testMinimumRating = '4';
    
                            }else if (project.Project_Complexity__c == 'High'){
                                testMinimumRating = '5';
                            }   
                        
                        Skill_SKU_Effort_Map_Entry__c entryFromComplexity = new Skill_SKU_Effort_Map_Entry__c(
                            Minimum_Rate__c = testMinimumRating,
                            Skill_Certification__c = complexitySkillToCreate.get(0).id
                        );
                        entrySkillToCreateSkilRequest.add(entryFromComplexity);
    
                        for(Skill_SKU_Effort_Map_Entry__c skillEntry: entrySkillToCreateSkilRequest){
    
                            if(skillEntry.Skill_Certification__c == null){
                                continue;
                            }
    
                            pse__Resource_Skill_Request__c resourceSkillRequest = new pse__Resource_Skill_Request__c(
                                pse__Resource_Request__c = resourceRequest.Id,
                                pse__Minimum_Rating__c = skillEntry.Minimum_Rate__c != null ? skillEntry.Minimum_Rate__c : DEFAULT_MINIMUM_RATING,
                                pse__Skill_Certification__c = skillEntry.Skill_Certification__c,
                                pse__Is_Primary__c = false
                            );
    
                            String uniqueSkillPerProjectKey = project.Id + ':' + resourceRequest.Id + ':' + resourceSkillRequest.pse__Skill_Certification__c;
                            skillRequestToCreate.put(uniqueSkillPerProjectKey, resourceSkillRequest);
                        }
                        
                        resourceRequest.pse__SOW_Hours__c = SKILL_HOURS.get(project.Project_Complexity__c);
                        resourceRequest.pse__Start_Date__c = project.pse__Start_Date__c;
                        resourceRequest.pse__End_Date__c = project.pse__End_Date__c;
                        resourceRequestToUpdate.add(resourceRequest);
                        
                    }
                }
            }
        
        }
              delete skillsToDelete;
              update resourceRequestToUpdate;
      
        if(!skillRequestToCreate.isEmpty()) { 
            insert skillRequestToCreate.values();
        }
    }
       /* system.debug('skillRequestToCreate '+skillRequestToCreate);
        system.debug('resourceRequestToUpdate '+resourceRequestToUpdate);
    }**/

    /**
    * @deion return a map of resource request tied to the project
    * @author Magaiver Oliveira | 2/20/2020 
    * @return Map<Id,pse__Resource_Request__c>
    **/
    private static void buildResourceRequestFromProjectMap(Set<Id> projects) {

        resourceRequestFromProject = new Map<Id, List<pse__Resource_Request__c>>();

        List<pse__Resource_Request__c> resourceRequestList = [
            SELECT Id, pse__Project__c 
            FROM pse__Resource_Request__c 
            WHERE pse__Project__c IN :projects
                AND pse__Resource_Role__c = :PROJECT_MANAGER 
                AND pse__Staffer_Resource__c = NULL
        ];

        for(pse__Resource_Request__c resourceRequest : resourceRequestList){
            List<pse__Resource_Request__c> resourceRequestFromMap = resourceRequestFromProject.get(resourceRequest.pse__Project__c);
            if(resourceRequestFromMap == null){
                resourceRequestFromMap = new List<pse__Resource_Request__c>();
            }
            resourceRequestFromMap.add(resourceRequest);
            resourceRequestFromProject.put(resourceRequest.pse__Project__c, resourceRequestFromMap);
        }      
    }

    /**
    * @deion return a map of resource skill request of projects resource requests
    * @author Magaiver Oliveira | 2/20/2020 
    * @return Map<Id,pse__Resource_Skill_Request__c>
    **/
    private static void buildSkillRequestFromResourceRequestMap() {
        
        skillRequestFromResourceRequest = new Map<Id, List<pse__Resource_Skill_Request__c>>();


        List<pse__Resource_Request__c> allResourceRequest = new List<pse__Resource_Request__c>();
        for(List<pse__Resource_Request__c> resourceRequestFromMap: resourceRequestFromProject.values()){
            allResourceRequest.addAll(resourceRequestFromMap);
        }
        
        List<pse__Resource_Skill_Request__c> skillRequestList = [
            SELECT Id, pse__Resource_Request__c, pse__Skill_Certification__c, pse__Is_Primary__c, 
            pse__Match_All__c, pse__Minimum_Rating__c
            FROM pse__Resource_Skill_Request__c 
            WHERE pse__Resource_Request__c IN :allResourceRequest
        ];
        
        for(pse__Resource_Skill_Request__c skillRequest: skillRequestList){
            List<pse__Resource_Skill_Request__c> skillRequestFromMap = skillRequestFromResourceRequest.get(skillRequest.pse__Resource_Request__c);
            if(skillRequestFromMap == null){
                skillRequestFromMap = new List<pse__Resource_Skill_Request__c>();
            }
            skillRequestFromMap.add(skillRequest);
            skillRequestFromResourceRequest.put(skillRequest.pse__Resource_Request__c, skillRequestFromMap);
        }
    }

    // Method is not used anymore - just let the signature to avoid errors in other classes
    public static void UpdateResourceRequestSkills(List<Id> projectIds) {}

    // Method is not used anymore - just let the signature to avoid errors in other classes
    public static void UpdateSkillsFromSkuMapping(List<Id> addedUpdatedOrders, List<Id> removedCancelledOrders, List<Id> projectIds) {}
}