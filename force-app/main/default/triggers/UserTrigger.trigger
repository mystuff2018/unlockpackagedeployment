/*
      Purpose:
            Maintain membership of a group / queue that represents users who should be able to access
            Federal projects, based on the value of the checkbox field User.Federal_Access__c.
            
      Initiative: Thunderbolt PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    8/1/18

    ==================================================================================  
    Modfications :
    Purpose : Updating Resources related to the user when the user is deactivated.
    Date    : 1/3/2019
    Author  : Pawan K
    Company : OAC Services INC.
    ===================================================================================

    ==================================================================================  
    Modfications :
    Purpose : To assign permission to community user.
    Date    : 03-02-2021
    Author  : Uttam Kavitkar
    Company : Deloitte Consulting
    =================================================================================== 
    
    ==================================================================================  
    Modfications :
    Purpose : To create account sharing record based on affiliations.
    Date    : 10-02-2021
    Author  : Namrata Bansode
    Company : Deloitte Consulting
    =================================================================================== 
    ==================================================================================  
    Modfications :
    Purpose : Nullify the account in contact and update it with resellar Account on User Deactivation
    Date    : 24-05-2021
    Author  : Soumiithri Rekha
    Company : Dell Technologies
    =================================================================================== 
    
    ==================================================================================  
    Modfications :
    Purpose : Update with NewDisty in Account on Case when User reactivated post Disty switch
    Date    : 13-08-2021
    Author  : Siva Kumar Valluru
    Company : Dell Technologies
    Method  : UpdateAcc_after_Distyswitch 
    =================================================================================== 

*/
/*
Version    Developer      Comments      
V1.0       Yamini Kayam   As part of Story 10045477: DFN - [PA Queue] Adding or Remove Scope to Custom Projects to add users to group 

*/
trigger UserTrigger on User (after insert, after update, before update) 
{
    if(trigger.isAfter)
    {
        UserHandler.maintainFederalGroupMembership(Trigger.isInsert,Trigger.isUpdate,Trigger.newMap,Trigger.oldMap);
        FBE_CreatePSAContactsBulk.assignPSAContactToUsers(Trigger.new);
        //V1.0 Added by Yamini as part of Story 10045477: DFN - [PA Queue] Adding or Remove Scope to Custom Projects
        UserHandlerForAddingToGroup.addingusersTorespectiveGroups(Trigger.isInsert,Trigger.isUpdate,Trigger.newMap,Trigger.oldMap);
       
        //Added by uttam on 03-02-2021
        if(Trigger.isInsert){
            //Added as part of Story 10449435
            FBE_CreatePSAContactsBulk.assignPermissionControlToUsers(Trigger.new);
            //Added by Namrata
            List<Id> lstUserId = new List<Id>();
            for(User user: Trigger.New){
                if(user.ContactId != null && user.IsPortalEnabled) {
                    lstUserId.add(user.id);
                }
            }
            if(!lstUserId.isEmpty()){
                
               FBE_FPRM_UserTriggerHandler.shareRelatedDistributorAccountWithPartner(lstUserId);
               FBE_PermissionsetAssignmentHandler.assignPermissionsetOnCreate(lstUserId);
               FBE_PermissionsetAssignmentHandler.populateSharingAccountOnContact(lstUserId);
               //Added by uttam for Active Partner User log on 4-Apr-2021
               FBE_PermissionsetAssignmentHandler.createPartnerUserLog(lstUserId,null);
                //added for story#10564520
                FBE_FPRM_UserTriggerHandler.updateDealRegDetailsonUserInsert(JSON.serialize(trigger.new));
                // added for Defect #10978410
                FBE_FPRM_UserTriggerHandler.UpdatecasesonUserInsert(JSON.serialize(trigger.new));
            }
        }
        
        if(Trigger.isUpdate){
            List<Id> lstUserId = new List<Id>();
            List<Id> lstInActivePortalUserId = new List<Id>();
            for(User usr: Trigger.New){
                String roleName = usr.FBE_FPRM_OnlineRole__c;
                String oldRoleName = Trigger.OldMap.get(usr.Id).FBE_FPRM_OnlineRole__c;
                if(usr.ContactId != null && usr.IsPortalEnabled && roleName != null && oldRoleName != roleName) {
                    lstUserId.add(usr.id); 
                }
                if(usr.IsActive == false && roleName != null){
                    system.debug('==usr.Id===' + usr.Id);
                    lstInActivePortalUserId.add(usr.Id);
                }
            }
            if(!lstUserId.isEmpty()){
                FBE_PermissionsetAssignmentHandler.assignPermissionsetOnUpdate(lstUserId);
                FBE_PermissionsetAssignmentHandler.populateSharingAccountOnContact(lstUserId);
                String jsonString = JSON.serialize(Trigger.OldMap);     
                FBE_PermissionsetAssignmentHandler.shareDealOptyWithPartnerUser(lstUserId,jsonString); 
            } 
            if(!lstInActivePortalUserId.isEmpty()){
                FBE_PermissionsetAssignmentHandler.removeUserFromPermissionSetAndGroup(lstInActivePortalUserId);
                String jsonString = JSON.serialize(Trigger.OldMap); 
                FBE_PermissionsetAssignmentHandler.updateContactFieldsToNull(lstInActivePortalUserId,jsonString);
               //added for story#10564520
                FBE_FPRM_UserTriggerHandler.UpdateContactInfo(lstInActivePortalUserId,jsonString);
                //Added by uttam for Inactive Partner User log on 4-Apr-2021
                FBE_PermissionsetAssignmentHandler.createPartnerUserLog(null,jsonString);
               
            } 
        }
    }
     
 
    if(RecursiveTriggerHandler.isFirstTime())
    {    
        if(trigger.isBefore )
        {
            //Update Event
            UserHandler.beforeUpdate(Trigger.isUpdate,Trigger.newMap,Trigger.oldMap);
            
            /********************************************************************/
            if(trigger.isInsert || trigger.isUpdate){
                FBE_TriggerHandler intUserHandler = new FBE_TriggerHandler(Trigger.isExecuting, Trigger.size);
                intUserHandler.CheckOnlyOneIntegrationUser(trigger.oldMap,trigger.new,Trigger.isUpdate);   
                Map<ID,User> oldMap = trigger.oldMap;
                FBE_UpdateIntStatusToPendingStatus.FBE_UpdateIntegrationStatusToPendingStatus(trigger.new,oldMap);
            }
            /********************************************************************/
        }
    }
    
}