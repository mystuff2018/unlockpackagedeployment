public class FBE_IDS_LeadStateCodeUpdateLogic {
    @future
    public static void leadStateCodeUpdate(string leadListString){
        List<Lead> leadList = (List<Lead>)System.JSON.deserialize(leadListString, List<Lead>.class);
        List<Lead> leadsToUpdate = new List<Lead>();
		Map<STRING,STRING> stateWithStateCodes = new Map<STRING,STRING>();
		for(FBE_IDS_LeadStateCodeAndState__mdt states: [select id,FBE_IDS_State__c,FBE_IDS_StateCode__c from FBE_IDS_LeadStateCodeAndState__mdt]){
			stateWithStateCodes.put(states.FBE_IDS_State__c,states.FBE_IDS_StateCode__c);
		}
        for(Lead l : leadList){
            if(l.FBE_IDS_Dell_Main_State__c != NULL){
				string leadState = l.FBE_IDS_Dell_Main_State__c.toUpperCase();
				if(leadState.length() == 2 && stateWithStateCodes.values().size() > 0 && stateWithStateCodes.values().contains(leadState)){
					l.statecode = leadState;
                    leadsToUpdate.add(l);
				}else if(stateWithStateCodes.keySet().size() > 0 && stateWithStateCodes.containsKey(leadState)){
					l.StateCode = stateWithStateCodes.get(leadState);
                    leadsToUpdate.add(l);
				}else{
					l.statecode = 'Invalid';
                    leadsToUpdate.add(l);
				}
			}
        }
        if(leadsToUpdate.size() > 0){
            system.debug(leadsToUpdate);
            UPDATE leadsToUpdate;
        }
    }
}