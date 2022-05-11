trigger ResourceAbsenceTrigger on ResourceAbsence (after insert,  before insert,before update,after update,before delete) {
    List<ResourceAbsence> approvedRAList = new List<ResourceAbsence>();
    List<ResourceAbsence> approvedRAList2 = new List<ResourceAbsence>();
    
    if(trigger.isBefore && Trigger.isInsert){
        for(ResourceAbsence raList : Trigger.New){
           // if(raList.Type !='Vacation'){
               raList.FSL__Approved__c =true;         
            //}            
        }
    }
    
    if(trigger.isAfter && Trigger.isInsert){
        System.debug('inside after insert');
            for(ResourceAbsence raList : Trigger.New){
                if(raList.FSL__Approved__c == true){
                    approvedRAList.add(raList);
                    System.debug('approvedRAList1  --'+approvedRAList);
                }           
        }
        if(!approvedRAList.isEmpty()){
           ResourceAbsenceHandler.createTimeSheet(approvedRAList); 
        }   
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        ResourceAbsenceHandler.updateRelatedTimesheets(trigger.oldMap,trigger.new);
    }
    
    if(trigger.isBefore && trigger.isDelete){
        ResourceAbsenceHandler.deleteRelatedTimesheets(trigger.old);    
    }
    
 /**   if(trigger.isBefore && Trigger.isUpdate ){
        for(ResourceAbsence raList2 : Trigger.New){
            ResourceAbsence oldAbsence = Trigger.oldMap.get(raList2.ID);
            if(raList2.FSL__Approved__c == true && raList2.Type == 'Vacation'){
                if(raList2.FSL__Approved__c != oldAbsence.FSL__Approved__c){
                approvedRAList2.add(raList2);
                System.debug('approvedRAList2  --'+approvedRAList2);  
                }
            }           
        }
        if(!approvedRAList2.isEmpty()){
          ResourceAbsenceHandler.createTimeSheet(approvedRAList2);  
        }   
    }   **/
}