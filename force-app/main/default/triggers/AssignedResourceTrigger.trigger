trigger AssignedResourceTrigger on AssignedResource ( after insert, after update) {
    Map <Id,AssignedResource> mapAppointmentVsResource = new Map <Id,AssignedResource>();
    Set<Id> deleteARList = new Set<Id>();
    Set<Id> CreadtedByUserId = new Set<Id>();
    Map<Id, String> mapPMUser = new Map<Id, String>();
   /** for(AssignedResource ar : Trigger.new ){
         mapAppointmentVsResource.put(ar.ServiceAppointmentId, ar);
    } **/
    
    //added below code for book appointment testing
   if(Trigger.isInsert || Trigger.isUpdate){
       for(AssignedResource ar : Trigger.New){
           CreadtedByUserId.add(ar.CreatedById);
       }
       for(User user : [SELECT Profile_Name__c,id FROM User WHERE Id IN: CreadtedByUserId]){
           mapPMUser.put(user.Id, user.Profile_Name__c);    
       }
        for(AssignedResource ar : Trigger.New){
            if(mapPMUser.containsKey(ar.CreatedById) && mapPMUser.get(ar.CreatedById) == 'PSA Project Manager'){
                deleteARList.add(ar.Id);
            }
            else{
                if(Trigger.isInsert || (Trigger.isUpdate && (ar.ServiceResourceId != Trigger.oldmAp.get(ar.Id).ServiceResourceId))){
                    mapAppointmentVsResource.put(ar.ServiceAppointmentId, ar);
                }
                 
            }
        }
       System.debug('deleteARList'+deleteARList);
       
		//Added as part of Defect #9746815
		AssignedResourceTriggerHandler.createProjectSharing(Trigger.new);
       
    }
    if(!deleteARList.isEmpty()){
        System.debug('deleteARList'+deleteARList);
        AssignedResourceTriggerHandler.deleteRecords(deleteARList);
    }  
    if(!mapAppointmentVsResource.isEmpty()){
        AssignedResourceTriggerHandler.populateAssignee(mapAppointmentVsResource);
    }
    

}