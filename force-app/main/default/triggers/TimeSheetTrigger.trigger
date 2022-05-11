trigger TimeSheetTrigger on TimeSheet (after insert, before update) {
    List<TimeSheet> tsForSharingList = new List<TimeSheet>();
    List<TimeSheet> tsCheckForZeroHoursList = new List<TimeSheet>();
    List<Id> tsAfterSubmittedList = new List<Id>();
    Set<Id> serviceResourceIdList = new Set<Id>();
 
        if(Trigger.isAfter && Trigger.isInsert){
            System.debug('Inside After & Insert');
            for(TimeSheet ts : Trigger.new){
                tsForSharingList.add(ts);
                serviceResourceIdList.add(ts.ServiceResourceId);
            }
            Map<Id, ServiceResource> serviceResourceMap = new Map<Id, ServiceResource>([SELECT Id,RelatedRecordId 
                                                                                        FROM ServiceResource where Id IN: serviceResourceIdList]);
            if(!tsForSharingList.isEmpty() && !serviceResourceMap.isEmpty() ){
                 System.debug('Inside After & Insert List');
                TimeSheetTriggerHandler.shareTimeSheetWithServiceResource(tsForSharingList, serviceResourceMap);   
            }
            
        }
    
    
   /**   if(Trigger.isBefore && Trigger.isUpdate){
         System.debug('Inside Before & Update');
        for(TimeSheet ts : Trigger.new){
            if(ts.Status == 'Submitted'){
               tsCheckForZeroHoursList.add(ts);                
            }            
        }
        if(!tsCheckForZeroHoursList.isEmpty()){
            System.debug('Inside Before & Update List');
           TimeSheetTriggerHandler.checkTSEWithZeroHours(tsCheckForZeroHoursList); 
        }        
    }
   
   if(Trigger.isAfter && Trigger.isUpdate){
        System.debug('Inside after & Update List');
        for(TimeSheet ts : Trigger.new){
            if(ts.Status == 'Submitted'){
               tsAfterSubmittedList.add(ts.Id); 
            } 
        }
        if(!tsAfterSubmittedList.isEmpty()){
            System.debug('Inside after & Update List');
           FBE_SetTimeCard.createUpdateTimecard(tsAfterSubmittedList); 
        }
    } **/
}