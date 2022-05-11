/*
*@ Trigger Name      : FBE_OpportunityTrigger  
*@ Description       : This trigger is created on Opportunity Object. This is executed
every time an opportunity is Inserted & Updated. The method executed is called under the class 'FBE_OpportunityTrigger'.

*@ CreatedBy         : Deloitte Consulting
*@ CreatedOn         : 09-12-2018
*@ Modification Log  : Yogesh 2/22/2019 - Deactivated Proces Builder (Update End User On Oppty) and moved logic here to conflict with Trigger.

DEFECT 10986244 - Sireesha Myla Aug 3rd 2021 - Reduced the SOQL count from 101 exception to 52, make sure the SOQL count to not hit the Governor limits which will impact the dependencies.
*/
trigger FBE_OpportunityTrigger on Opportunity (before insert, before update,after insert, after update) {
    Boolean triggerValidation = false;
    FBE_TriggerHandler handler = new FBE_TriggerHandler(Trigger.isExecuting, Trigger.size);  
    //Added logic to set End User Account if Main Account class type is Direct & Record Type is Standard
    if(Trigger.isBefore && (Trigger.isInsert||Trigger.isUpdate)){
        for(Opportunity opty:trigger.new)
        {
            if(opty.FBE_Direct_Account_Cls_Flg__c == True){//system.debug('Calling Opty Trigger...');
                opty.FBE_End_User__c = opty.AccountId;             
            }         
        }
    }
    if(Trigger.isBefore){
        if(Trigger.isInsert){  
            FBE_OpportunityTriggerHandler.userRoleInsertValidation(trigger.new);//Story-11910344
        }else if(Trigger.isUpdate){
            if(test.isRunningTest()) {
                triggerValidation = true;   
            }
            if(FBE_CheckRecursive.runBeforeOnce() || triggerValidation == true) 
            {	
                FBE_OpportunityTriggerHandler.directTeamMemValidation(trigger.new,Trigger.oldMap);
                FBE_OpportunityTriggerHandler.userRoleValidation(trigger.new,Trigger.oldMap);//Story-11910344      
                
            }
            
            FBE_OpportunityTriggerHandler.updateRevenueAlert(trigger.new , trigger.oldMap);//Story-8330877
        }
    }
    //calling Trigger Handler class method to sync Opportunity Team Members
    if (Trigger.isAfter && Trigger.isUpdate) {   
        List<Opportunity> newOpptyList = new List <Opportunity>();
        Map<Id, Opportunity> oldOpptyMap =  new Map<Id, Opportunity>();
        Boolean ownerUpdated = false; 
        System.debug('update trigger'); 
        //Added below code to give deal reg record access to partner user where online role = My Oppty
        for(Opportunity newOppty: Trigger.new){
            Opportunity oldOppty = Trigger.oldMap.get(newOppty.Id);
            if(oldOppty.FBE_FPRM_Partner_Owner_Lookup__c != newOppty.FBE_FPRM_Partner_Owner_Lookup__c    
               || oldOppty.FBE_FPRM_Partner_Sales_Rep__c != newOppty.FBE_FPRM_Partner_Sales_Rep__c
               || oldOppty.OwnerId != newOppty.OwnerId){
                   newOpptyList.add(newOppty);
                   oldOpptyMap.put(oldOppty.Id, oldOppty); 
                   ownerUpdated = true;
               }    
        } 
        if(ownerUpdated || (!newOpptyList.isEmpty() && !oldOpptyMap.isEmpty()) ){
            FBE_OpportunityTriggerHandler.shareOpptyRecordWithPartnerUser(newOpptyList, oldOpptyMap); 
        }
        //if(FBE_CheckRecursive.runOptyInsertOnce()) - DEFECT 10986244 - Sireesha Myla
        handler.syncOptyTeamMembers(Trigger.oldMap,Trigger.new,'Update');
    }   
    //calling Trigger Handler class method to sync Opportunity Team Members
    if (Trigger.isAfter && Trigger.isInsert) {
        FBE_OpportunityTriggerHandler.shareOpptyRecordWithPartnerUser(Trigger.new, null);
        if(FBE_CheckRecursive.runOptyUpdateOnce())
            handler.syncOptyTeamMembers(Trigger.oldMap,Trigger.new,'Insert');
    }   
}