trigger FBE_CaseTrigger on Case (before insert,
                             Before Update,
                             Before Delete,
                             After Insert,
                             After Update,
                             After Delete,
                             After undelete) {
    
        if (ServiceCaseHandler.skipCaseTrigger) return; 
        new ServiceCaseHandler().handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);

        if(Trigger.isBefore){
            if(Trigger.isInsert){
                CaseTriggerHelper.emailToCaseFieldsUpdate(trigger.new);
                CaseTriggerHelper.updateAccountField(trigger.new);
                //Sireesha Added emailNotificationifNoCaseModified -[Story#8817647]
                CaseTriggerHelper.emailNotificationifNoCaseModifiedUpdate(Trigger.new, null);
                //Uttam Added for code optimization
                CaseTriggerHelper.updateSubmitter(trigger.new); 
            } 
            if(Trigger.isUpdate)  
            {
                //Sireesha Added emailNotificationifNoCaseModified -[Story#8817647]
               CaseTriggerHelper.emailNotificationifNoCaseModifiedUpdate(Trigger.new, Trigger.old);
            }
        }
        if(Trigger.isAfter){
            if(Trigger.isInsert || Trigger.isUpdate){
                List<Id> lstCaseIds = new List<Id>();
                for(Case cs : Trigger.New){
                    if(cs.FBE_Assign_using_active_assignment_rules__c == true) {
                        lstCaseIds.add(cs.Id);
                    }
                }
                if(!lstCaseIds.isEmpty()){
                     CaseTriggerHelper.fireAssignmentRulesOnCases(lstCaseIds);
                }
            }
            if(Trigger.isUpdate){
                CaseTriggerHelper.shareCaseRecord(trigger.new , trigger.oldMap);
                CaseTriggerHelper.shareCaseToSubmitter(trigger.new , trigger.oldMap);
                
            } 
        }
                    
}