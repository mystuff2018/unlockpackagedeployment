/*
 * This class verifies if a Engagement has custom projects as it's children and sets the flag HasActiveCustomProject__c
 */
public class FFCustomProjectRollup {

	public static Boolean customRollupExecuted = false;

	public static Map<Id, pse__Proj__c> verifyCustomProject(List<pse__Proj__c> triggerNew, Map<Id, pse__Proj__c> engagementsToUpdateMap){
		Set<Id> engagementIds = new Set<Id>();
		List<pse__Proj__c> engagementsToUpdate = new List<pse__Proj__c>();

		for (pse__Proj__c proj : triggerNew){
			if (proj.pse__Parent_Project__c != null){
				engagementIds.add(proj.pse__Parent_Project__c);
			}
		}

		if (!engagementIds.isEmpty()){
			List<pse__Proj__c> engagementList = DAL_Project.getEngagementsWithActiveCustomProjects(engagementIds);
			for (pse__Proj__c eng : engagementList){
				if (eng.pse__ImmediateSubProjects__r.size() > 0 && !eng.HasActiveCustomProject__c){
					if (engagementsToUpdateMap.containsKey(eng.Id)){
						engagementsToUpdateMap.get(eng.Id).HasActiveCustomProject__c = true;
					} else {
						engagementsToUpdateMap.put(eng.Id, new pse__Proj__c(Id = eng.Id, HasActiveCustomProject__c = true));
					}
				} else if (eng.pse__ImmediateSubProjects__r.isEmpty() && eng.HasActiveCustomProject__c){
					if (engagementsToUpdateMap.containsKey(eng.Id)){
						engagementsToUpdateMap.get(eng.Id).HasActiveCustomProject__c = false;
					} else {
						engagementsToUpdateMap.put(eng.Id, new pse__Proj__c(Id = eng.Id, HasActiveCustomProject__c = false));
					}
				}
			}
		}

		customRollupExecuted = true;
		return engagementsToUpdateMap;
	}
}