/* -----------------------------------------------------------------------------------------------------------------------
Trigger Name:       ContactTrigger
Description:        To Skip trigger make 'Skip_Contact_Trigger__c' to true,in custom setting 'Trigger_Execution_Control__c'
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
01/23/2018     1.0            Prasanth              Initial Release
07/09/2020     1.1            Deloitte - Abhishek K Updated script for Contact Management TFS Feature #7868086.
                              Added code to invoke logic to create Service Resource records
-------------------------------------------------------------------------------------------------------------------------- 
*/

trigger ContactTrigger on Contact (before Insert, before Update, after insert, after update) { 
        
    if(trigger.isBefore){
        if(trigger.isupdate){
             ContactTriggerHandler.updateSharingAccount(Trigger.OldMap,Trigger.NewMap);
             ContactTriggerHandler.preventCDLfieldupdate(Trigger.OldMap,Trigger.New);
        }
       
        if(!Trigger_Execution_Control__c.getInstance().Skip_Contact_Trigger__c) {
            ContactTriggerHandler.callBeforeMethods(Trigger.New);
        }        
    }
    
    if(trigger.isAfter){
        if(!Trigger_Execution_Control__c.getInstance().Skip_Contact_Trigger__c) {
            if(trigger.isinsert){
            	ContactTriggerHandler.createServiceResource(Trigger.New);    
            }            
            if(trigger.isupdate){
                ContactTriggerHandler.callAfterUpdate(Trigger.OldMap,Trigger.NewMap);
            }                
        }
        
        //[Deloitte Consulting : Abhishek Kawle] 02/05/2021: Added new as part of Story #9911522
        if(trigger.isinsert){
            	ContactTriggerHandler.accountContactRelOnInsert(Trigger.New);    
            }
        if(trigger.isupdate){
                ContactTriggerHandler.accountContactRelOnUpdate(Trigger.OldMap,Trigger.NewMap);
            }
    }
 
}