/**
 * Created by Bruno_Frosi on 1/14/2020.
 */

public with sharing class DAL_Project {
    public static Map<Id, pse__Proj__c> getProjectByIds(Set<Id> projectIds){
        
        Map<Id, pse__Proj__c> mapProjects = new Map<Id,pse__Proj__c>([
                 SELECT Id, 
            			Name,
                        pse__Parent_Project__c,
            			CurrencyIsoCode, 
                        Distinct_Project__c, 
                        Distinct_SKU_Effort_Mapping__c,
                        BUID__c,
                        Local_Channel__c,
                        Association_Flag__c,
                        Project_Visibility__c,
            	   		OwnerId, 
            			Owner.Type,
            			Phase_Number__c,  
            			PM_Complexity__c,  
            			pse__Region__r.Is_State__c,
            			RecordType.Name,
            			Project_Complexity__c,
            			pse__Account__r.Name,
                        pse__End_Date__c,
                        pse__Is_Template__c,
            			pse__Practice__c,
            			pse__Practice__r.Order_Association_Approval_Phase_Number__c,
                        Deal_Type__c, 
                        pse__Project_ID__c,
                        pse__Project_Type__c,
            			pse__Region__c, 
            			pse__Region__r.ISO_Country_Code__c,
                        pse__Start_Date__c, 
                        RecordTypeId,
                        Sales_Rep__c,
                        pse__Stage__c,
                        On_Hold_Reason__c,
                        pse__Project_Phase__c,
                        Delivery_and_Implementation__c,
                		(SELECT Id, 
                         		Name , 
                         		pse__Estimated_Hours__c, 
                         		pse__Parent_Task__c, 
                         		pse__Parent_Task__r.Name,
                         		pse__Project__c, 
                         		pse__Status__c,
                         		EmptyHoursCounter__c
                 		FROM pse__Project_Tasks__r)
            	 FROM pse__Proj__c
            	 WHERE Id IN :projectIds
        ]);

        return mapProjects;
    }

	public static List<pse__Proj__c> getEngagementsWithActiveCustomProjects(Set<Id> engagementIds){
		return [SELECT Id,
					   Name,
					   HasActiveCustomProject__c,
					   (SELECT Id FROM pse__ImmediateSubProjects__r WHERE pse__Stage__c != 'Closure' AND pse__Stage__c != 'Cancelled' AND Deal_Type__c = 'Custom')
				FROM pse__Proj__c
				WHERE id IN :engagementIds];
	}

    public static Map<Id, pse__Proj__c> getProjectsForRulesEngine(Set<String> poNumberSet, Set<String> dealIdSet, Set<String> dpIdSet)
    {
        Map<Id, pse__Proj__c> projectMap = new Map<Id, pse__Proj__c>([
                 SELECT Id, 
            			Name, 
            			Po_Number__c, 
            			Deal__c, 
            			DP__c, 
            			Account_Local_Channel__c,
                        CurrencyIsoCode,
                        Customer_Number_Account__c,
            			Distinct_Project__c,
                        Project_BUID__c,
                        Project_Visibility__c,
                        pse__Stage__c,
                        Phase_Number__c,
                        pse__Project_Manager__c,
                        pse__Project_Manager__r.pse__Salesforce_User__c,
                        pse__Practice__c,
                        pse__Practice__r.Order_Association_Approval_Phase__c,
                        pse__Practice__r.Order_Association_Approval_Phase_Number__c
                 FROM pse__Proj__c
                 WHERE Po_Number__c IN :poNumberSet 
            	 OR Deal__c IN :dealIdSet 
            	 OR DP__c IN :dpIdSet
        ]);

        if(projectMap.size() > 0)
            return projectMap;
        return null;
    }

    public static Map<Id, pse__Proj__c> getEngagementForOrderGrouping(Set<String> poNumberSet, Set<String> dealIdSet, Set<String> dpIdSet) {
        Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
        
        Map<Id, pse__Proj__c> projectMap = new Map<Id, pse__Proj__c>([
                 SELECT Id, 
            			Name, 
            			Po_Number__c, 
            			Deal__c, 
            			DP__c, 
            			Account_Local_Channel__c,
                        CurrencyIsoCode,
                        Customer_Number_Account__c,
            			Distinct_Project__c,
                        Project_BUID__c,
                        Project_Visibility__c,
                        pse__Stage__c,
                        Phase_Number__c,
                        pse__Project_Manager__c,
                        pse__Project_Manager__r.pse__Salesforce_User__c,
                        pse__Practice__c,
                        pse__Practice__r.Order_Association_Approval_Phase__c,
                        pse__Practice__r.Order_Association_Approval_Phase_Number__c
                 FROM pse__Proj__c
                 WHERE RecordTypeId = :recordTypeId 
                 AND (DP__c IN :dpIdSet)
        ]);

        return projectMap;
        
    }

    public static Map<Id, pse__Proj__c> getMapRecommendedEngagementForOrderGrouping(String pPoNumber, String pDealId, String pDpId) 
    {
        Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
        
        Map<Id, pse__Proj__c> mapIdProject = new Map<Id, pse__Proj__c>([SELECT Id, 
                                                                        	   Name, 
                                                                        	   Customer_Number_Account__c, 
                                                                        	   Deal__c, 
                                                                        	   DP__c, 
                                                                        	   Po_Number__c, 
                                                                        	   pse__Account__r.Name, 
                                                                        	   pse__End_Date__c, 
                                                                        	   pse__Stage__c, 
                                                                        	   pse__Start_Date__c
                                                                        FROM pse__Proj__c
                                                                        WHERE RecordTypeId =: recordTypeId 
                                                                        AND pse__Stage__c != 'Closure'
                                                                        AND pse__Stage__c != 'Cancelled'
                                                                        AND ((Po_Number__c =: pPoNumber 
                                                                              AND Po_Number__c != NULL)
                                                                            OR (Deal__c =: pDealId 
                                                                                AND Deal__c != NULL)
                                                                            OR (DP__c =: pDpId 
                                                                                AND DP__c != NULL)
                                                                            )
                                                                       ]);

        return mapIdProject;   
    }
    
    public static Map<Id, pse__Proj__c> getProjectsForImportQueue(List<Id> listProjectsId)
    {
        Map<Id, pse__Proj__c> projectMap = new Map<Id, pse__Proj__c>([
                 SELECT Id, 
            			Name, 
            			Po_Number__c, 
            			Deal__c, DP__c, 
            			Account_Local_Channel__c,
                        CurrencyIsoCode,
                        Customer_Number_Account__c,
                        Project_BUID__c,
                        Project_Visibility__c,
                        pse__Stage__c,
                        Phase_Number__c,
                        pse__Project_Manager__c,
                        pse__Project_Manager__r.pse__Salesforce_User__c,
                        pse__Practice__c,
                        pse__Practice__r.Order_Association_Approval_Phase__c,
                        pse__Practice__r.Order_Association_Approval_Phase_Number__c
                 FROM pse__Proj__c
                 WHERE Id = :listProjectsId
        ]);

        if(projectMap.size() > 0){
            return projectMap;
        }
            
        return new Map<Id, pse__Proj__c>();
    }

    public static Map<Id, pse__Proj__c> getTemplateByPracticeId (List<Id> practiceIds) {
        Map<Id, pse__Proj__c> practiceIdToTemplate = new Map<Id, pse__Proj__c>();
        for(pse__Practice__c practiceId : [SELECT Id, Standard_Project_Template__r.Id, Standard_Project_Template__r.pse__Is_Template__c FROM pse__Practice__c where Id IN :practiceIds]){
            practiceIdToTemplate.put(practiceId.Id, practiceId.Standard_Project_Template__r);
            system.debug('@@practiceId@@'+practiceId);
        }
        system.debug('@@practiceIdToTemplate@@'+practiceIdToTemplate);
        return practiceIdToTemplate;
    }

    public static Map<Id, List<pse__Proj__c>> getProjectByEngamentId(List<Id> engagementId){
        
        Map<Id, List<pse__Proj__c>> mapProjects = new Map<Id, List<pse__Proj__c>>();
        for(pse__Proj__c project :[SELECT Id, Name, pse__Project_Phase__c, pse__Parent_Project__c, pse__Practice__c, pse__Practice__r.pse__Practice_ID_Chain__c ,Billing_Account__r.BUID__c, Billing_Account__r.CCN__c, Distinct_SKU_Effort_Mapping__c, Project_Visibility__c, pse__Stage__c, Delivery_and_Implementation__c, On_Hold_Reason__c, Closure_Reason__c, Initiate_Customer_Contact__c FROM pse__Proj__c WHERE pse__Parent_Project__c =:engagementId]){
        
            if(!mapProjects.containskey(project.pse__Parent_Project__c)){
                mapProjects.put(project.pse__Parent_Project__c, new List<pse__Proj__c>());
            }
            List<pse__Proj__c> projects = mapProjects.get(project.pse__Parent_Project__c);
            projects.add(project);
            mapProjects.put(project.pse__Parent_Project__c, projects);

        }
        

        return mapProjects;
    }

    public static Map<Id, List<pse__Proj__c>> getNotCanceledProjectByEngamentId(List<Id> engagementId){
        
        Map<Id, List<pse__Proj__c>> mapProjects = new Map<Id, List<pse__Proj__c>>();
        for(pse__Proj__c project :[SELECT Id, Name, CurrencyIsoCode, Deal_Type__c, pse__Project_Phase__c, pse__Parent_Project__c, pse__Practice__c, pse__Practice__r.Order_Association_Approval_Phase_Number__c,
                                    pse__Practice__r.pse__Practice_ID_Chain__c ,Billing_Account__r.BUID__c, Phase_Number__c, pse__Project_Manager__r.pse__Salesforce_User__c, 
                                    Billing_Account__r.CCN__c, Distinct_SKU_Effort_Mapping__c, Project_Visibility__c, BUID__c, Local_Channel__c, pse__Project_Type__c
                                    FROM pse__Proj__c WHERE pse__Parent_Project__c =:engagementId AND pse__Stage__c != 'Cancelled' ORDER BY Createddate]){
        
            if(!mapProjects.containskey(project.pse__Parent_Project__c)){
                mapProjects.put(project.pse__Parent_Project__c, new List<pse__Proj__c>());
            }
            List<pse__Proj__c> projects = mapProjects.get(project.pse__Parent_Project__c);
            projects.add(project);
            mapProjects.put(project.pse__Parent_Project__c, projects);

        }
        

        return mapProjects;
    }

    public static pse__Proj__c getEngagementByProjectId(Id projectId){
        pse__Proj__c engagement = [SELECT   Id,
                                            pse__Stage__c,
                                            On_Hold_Reason__c,
                                            pse__Project_Phase__c
                                FROM pse__Proj__c
                                WHERE Id = :projectId limit 1];

        return engagement;
    }

    public static List<pse__Proj__c> getProjectsByEngagementId(Id engagementId){
        List<pse__Proj__c> projects = [SELECT   Id,Name,
                                            pse__Stage__c,
                                            On_Hold_Reason__c,
                                            pse__Project_Phase__c
                                FROM pse__Proj__c
                                WHERE pse__Parent_Project__c = :engagementId];

        return projects;
    }
 

}