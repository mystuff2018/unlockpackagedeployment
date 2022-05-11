public with sharing class CancelledProjectStageHandler {


    public static void handleCancelledProjectStage(Map<Id,pse__Proj__c> oldProjs, Map<Id,pse__Proj__c> newProjs) {
        List<pse__Proj__c> projsToUpdate = new List<pse__Proj__c>();
        for(pse__Proj__c oldProj : oldProjs.values()){
            pse__Proj__c newProj = newProjs.get(oldProj.Id);

            if(oldProj.pse__Stage__c != newProj.pse__Stage__c){
                if(newProj.pse__Stage__c == 'Cancelled'){
                    newProj.Cancelled_Project_Date__c = Date.today();
                    projsToUpdate.add(newProj);
                }
            }
        }
    }
}