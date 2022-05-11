public class FBE_BuCategoryClassifierTriggerHandler {

Public static void updbucategoryclassifier (list<opportunitylineitem> newLineItem , list<opportunitylineitem> oldLineItem){
set<id> oids = new set<id>();
    if(trigger.new!=null){
    for(OpportunityLineItem Oli : newLineItem){
	if(Oli.OpportunityId != null){
	oids.add(Oli.OpportunityId);
	}
    }
} if(trigger.old!=null){
    for(OpportunityLineItem Oli : oldLineItem){
	if(Oli.OpportunityId != null ){
	oids.add(Oli.OpportunityId);
	}
    }
}
list<Opportunity> Olf = new list<Opportunity>();
list<opportunity> oppl = [select id, FBE_BU_Category_Classifier__c , 
					(select id,OpportunityId, FBE_BU_Category__c from OpportunityLineItems) from Opportunity where id in : oids];
for(Opportunity opp : oppl ){
    if(opp.OpportunityLineItems.size()>0){
        opp.FBE_BU_Category_Classifier__c='';
        for(OpportunityLineItem oLI:opp.OpportunityLineItems){
            if(oLI.FBE_BU_Category__c != null){
            if(!opp.FBE_BU_Category_Classifier__c.Contains(oLI.FBE_BU_Category__c)){
            opp.FBE_BU_Category_Classifier__c+=oLI.FBE_BU_Category__c+', ';
            }   }
        }
         opp.FBE_BU_Category_Classifier__c= opp.FBE_BU_Category_Classifier__c.removeEnd(', ');
        
       
    }
    else{
            opp.FBE_BU_Category_Classifier__c='';
    }     
    Olf.add(opp);
    
                       }
    try{
    database.update ( Olf ) ; }catch (dmlexception e){
        system.debug('An ecxeption has occured  ' + e.getMessage());
    }
}
}