public class SuggestedProjectAssociation implements Comparable {
    
    @AuraEnabled
    public pse__proj__c project { get; set; }
    
    @AuraEnabled
    public String matchReason { get{return reason;} }
	
    @AuraEnabled
    public String stage { 
        get{
            return project.pse__Stage__c.replace(' ','');
        } 
    }
    
    public Map<string,Integer> stageOrder{get{
        	if(SuggestedProjectAssociation.staticStageOrder == null){
            	Schema.DescribeFieldResult fieldResult = pse__proj__c.pse__Stage__c.getDescribe();
				List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            	SuggestedProjectAssociation.staticStageOrder = new Map<string,Integer>();
   				for( Schema.PicklistEntry f : ple)
   				{
      				SuggestedProjectAssociation.staticStageOrder.put(f.getValue(), SuggestedProjectAssociation.staticStageOrder.keySet().size());
   				}
        	}
        	return SuggestedProjectAssociation.staticStageOrder;
    	}
    }
    
    private String reason;
    private static Map<string,Integer> staticStageOrder;
    
    public void addReason(String newReason){
        if(!string.isBlank(reason) && !string.isBlank(newReason))
            reason+=', '+newReason;
        else if(string.isBlank(reason))
        	reason=newReason;
    }
    
    public Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        SuggestedProjectAssociation compareToAsso = (SuggestedProjectAssociation)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        
        if (stageOrder.get(project.pse__Stage__c) > stageOrder.get(compareToAsso.project.pse__Stage__c)) {
            returnValue = 1;
        } else if (stageOrder.get(project.pse__Stage__c) < stageOrder.get(compareToAsso.project.pse__Stage__c)) {
            returnValue = -1;
        }
                
        if (project.Id > compareToAsso.project.Id) {
            returnValue = 1;
        } else if (project.Id < compareToAsso.project.Id) {
            returnValue = -1;
        }
        
        return returnValue;       
    }
}