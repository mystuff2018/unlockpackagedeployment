/**************
 * @ Trigger Name      : FBE_FPRM_ShareAccountWithPartnerUserTrigger
 * @ Description       : This trigger will get called on creation of Affiliation record and will call the handler method  to automatically  share Account record with Partner Users based on different criterias 
 *                       Created as part of Feature #9912110.
 * @ CreatedBy         : Deloitte
 * @ Modification Log  : Version 1.0 - [Namrata] : 
*********/

trigger FBE_FPRM_ShareAccountWithPartnerUserTrigger on Account_Affiliation__c (after insert,after update) {
    
    if(Trigger.isafter && (Trigger.isInsert || Trigger.isUpdate) 
                    && !FBE_FPRM_ShareAccountWithPartnesHandler.isExecuted) {
         
        FBE_FPRM_ShareAccountWithPartnesHandler.isExecuted = true;                
        set<Id> setAffiliation = new set<Id>();
        Map<Id, List<User>> userMap = new Map<Id, List<User>>();
        for(Account_Affiliation__c aaf : Trigger.New){
            //Update scenario
            if(Trigger.isUpdate){
                Account_Affiliation__c oldAaf = Trigger.oldMap.get(aaf.Id);
                //if((aaf.FBE_Start_Date__c != oldAaf.FBE_Start_Date__c  || aaf.FBE_End_Date__c != oldAaf.FBE_End_Date__c) && aaf.FBE_Start_Date__c<= System.Today() &&(aaf.FBE_End_Date__c>= System.today()|| aaf.FBE_End_Date__c == null) )  {
                if(aaf.FBE_Start_Date__c != oldAaf.FBE_Start_Date__c  || aaf.FBE_End_Date__c != oldAaf.FBE_End_Date__c) {   
                setAffiliation.add(aaf.FBE_Account__c);
                }
                // Added by Sireesha Myla - Disty Manual Transfer method - Story 9912077
                FBE_FPRM_ShareAccountWithPartnesHandler.distyManualTransfer(Trigger.newMap, Trigger.oldMap);
            }
            //Insert scenario
            else if(Trigger.isInsert){
                setAffiliation.add(aaf.FBE_Account__c);
            }
        }
        
        if(!setAffiliation.isEmpty()){
            for(User user: [SELECT Id,ContactId,Contact.AccountId,AccountId,contact.FBE_FPRM_Reseller_Account__c 
                                  FROM User WHERE AccountId IN : setAffiliation]){
                if(userMap.containsKey(user.AccountId)){
                    userMap.get(user.AccountId).add(user);      
                }
                else{
                    userMap.put(user.AccountId, new List<User>{user});
                }        
            }
        }
                         
        if(!setAffiliation.isEmpty() && !userMap.isEmpty()){
        	FBE_FPRM_ShareAccountWithPartnesHandler.shareAccountWithPartner(Trigger.New, userMap);
        }
    }
}