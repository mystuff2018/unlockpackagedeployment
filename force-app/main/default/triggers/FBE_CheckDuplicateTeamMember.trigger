/*
 *@ Trigger Name      : FBE_CheckDuplicateTeamMember
 *@ Description       : This trigger is created on Deal Registration Team Object. This is executed
                        every time an opportunity is Inserted & Updated. 
                        
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 21-1-2019
 *@ Modification Log  :                     
 */
trigger FBE_CheckDuplicateTeamMember on FBE_Deal_Registration_Team__c (before insert, after insert, after delete,before delete) {
    system.debug('Inside Trigger');
    FBE_TriggerHandler handler = new FBE_TriggerHandler(Trigger.isExecuting, Trigger.size);
    //added as part of defect 9460993
    FBE_DealHelper handler1 = new FBE_DealHelper();
    //system.debug('Trigger.old'+Trigger.old);
    //List<FBE_Deal_Registration_Team__c> dealteams;
    //List<FBE_Deal_Registration_Team__c> dealteamsold;
    //if(Trigger.new != Null && Trigger.new.size() > 0)
    //dealteams = [select id,CurrencyIsoCode, Access_level__c,Created_From_Batch__c,Deal_Registration__c,FBE_Auto_Created__c,Role__c,Name,User__c,CreatedById from FBE_Deal_Registration_Team__c where id in: Trigger.new and Created_From_Batch__c = False];
    //if(Trigger.old != Null && Trigger.old.size()> 0)
    //dealteamsold = [select id,CurrencyIsoCode, Access_level__c,Created_From_Batch__c,Deal_Registration__c,FBE_Auto_Created__c,Role__c,Name,User__c,CreatedById from FBE_Deal_Registration_Team__c where id in: Trigger.old and Created_From_Batch__c = False];
//calling Trigger Handler class method to check for duplicate Team Members
    //if(dealteams != Null && dealteams.size()>0){
    if (Trigger.isBefore && Trigger.isInsert) {
        system.debug('from Deal Team Trigger Before Insert');
        if(FBE_CheckRecursive.runBeforeOnce()){
            system.debug('from Deal Team Trigger Before Insert Recursive Check');
           // handler.CheckDuplicateDealTeamMember(dealteams);  //
           handler.CheckDuplicateDealTeamMember(Trigger.new); 
        }    
    }    
//calling Trigger Handler class method to create sharing record for manually created Team Members
    if (Trigger.isAfter && Trigger.isInsert) {
        system.debug('from Deal Team Trigger After Insert');
        //if(FBE_CheckRecursive.runAfterOnce()){system.debug('from Deal Team Trigger After Insert Recursive Check');
        List<FBE_Deal_Registration_Team__c> newList = new List<FBE_Deal_Registration_Team__c>();
        for(FBE_Deal_Registration_Team__c dtm : trigger.new){
            if(dtm.Created_From_Batch__c == false)
            {
                newList.add(dtm);
            }
        }
        handler1.createDealTeamMemberShare(newList);  
        // }    
    }   
   // } 
 
    if (Trigger.isAfter && Trigger.isDelete ) {
        system.debug('from Deal Team Trigger before delete');
        //if(FBE_CheckRecursive.runAfterOnce()){system.debug('from Deal Team Trigger After Insert Recursive Check');
        FBE_DealRegRemove.DeleteDealTeam(trigger.old);  
        // }    
    }
    

}