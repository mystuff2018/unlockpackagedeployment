/**************
*@ Class Name                                                    : FBE_TriggerHandler
*@ Description                                                   : This class is written to handle the Trigger related updates. The methods related to all the triggers
are referred here. The triggers are basically required to keep the data during Integration between 
Siebel & Salesforce into Sync.
*@ CreatedBy                                                     : Deloitte Consulting
*@ CreatedOn                                                     : 26-04-2017 [Namita Verma]
*@ Modification Log                                              : 18-12-2018 [Yogesh Mishra] => Added method (syncOptyTeamMembers) to sync account (7 fields) team members in Opty Team, calling from Opty Trigger.               
: 22/1/2019 [Yogesh Mishra] => Added method (CheckDuplicateDealTeamMember) to check duplicate Deal Team Members, calling from Deal Reg Team Trigger
***************/                                                 
public with sharing class FBE_TriggerHandler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public FBE_TriggerHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    Set < id > accIdsToBeUpdated = new set < Id > ();
    Set < id > oppIdsToBeUpdated = new set < Id > ();
    
    Set<Id> newAccntIds = new Set<Id>();
    Set<Id> oldAccntIds = new Set<Id>();
    boolean isAccntUpdated = false;
    
    /**************
* @MethodName    : onRelatedConRelationshipDelete
* @Trigger       : FBE_RelatedRelationshipDelete
* @Description   : This method is called in the above trigger. It modifies the Account Record when any Related Contact Relationship is removed.
***************/
    public void onRelatedConRelationshipDelete(AccountContactRelation[] accRelation) {
        for (AccountContactRelation acr: accRelation) {
            accIdsToBeUpdated.add(acr.accountId);
        }
        if (accIdsToBeUpdated.size() > 0) {
            List < Account > accLst = [Select Id from Account where ID in: accIdsToBeUpdated];
            try {
                update accLst;
            } catch (Exception e) {
                system.debug(e.getMessage());
            }
        }
    }
    
    /**************
* @MethodName    : onRelatedOppTeamMemberDelete
* @Trigger       : FBE_RelatedOppTeamMemberDelete   
* @Description   : This method is called in the above trigger. It modifies the Opportunity Record when any Opportunity Team Member is Deleted.
***************/
    
    public void onRelatedOppTeamMemberDelete(OpportunityTeamMember[] opptyTeamMember) {
        for (OpportunityTeamMember otm: opptyTeamMember) {
            oppIdsToBeUpdated.add(otm.opportunityId);
        }
        if (oppIdsToBeUpdated.size() > 0) {
            List < Opportunity > oppLst = [Select Id from Opportunity where ID in: oppIdsToBeUpdated];
            try {
                update oppLst;
            } catch (Exception e) {
                system.debug(e.getMessage());
            }
        }
    }
    /**************
* @MethodName    : FBEContentVersionGenericTrigger 
* @Trigger       : FBEContentVersionGenericTrigger 
* @Description   : This method is called in the above trigger. It shares the file with Integration User automatically every time it's created.
***************/
    public void FBEContentVersionGenericTrigger(ContentVersion[] contentVersion) {
       if ([Select Profile.Name from User where Id =:UserInfo.getUserId()].Profile.Name == 'Dell Federal Services Profile') {
           return;
       }
       List<ContentVersion> cvs = [SELECT ContentDocument.ParentId from 
                                   ContentVersion where Id IN :contentVersion limit 1];
        System.debug('cvs:::' + cvs[0]);
        System.debug('cvs:::' + cvs[0].ContentDocument.ParentId);
        
        ContentDocumentLink[] CDLinkArray = new List < ContentDocumentLink > ();
        Boolean LoggedInUser = [Select FBE_Integration_User__c From User Where Id = :UserInfo.getUserId()][0].FBE_Integration_User__c;
        User IntegrationUser = [Select Id From User Where FBE_Integration_User__c = true];        
        for (ContentVersion CV: contentVersion) {
            if (CV.VersionNumber == '1' && LoggedInUser == false) {
                ContentDocumentLink Link = new ContentDocumentLink(ContentDocumentId = CV.ContentDocumentId, LinkedEntityId = IntegrationUser.Id, ShareType = System.Label.ShareType);
                CDLinkArray.add(Link);
            }
        }       
        try {
            insert CDLinkArray;
        } catch (Exception e) {
            system.debug(e.getMessage());
        }
    }
    
    /**************
* @MethodName    : IntegrationUser
* @Trigger       : FBE_UserTrigger
* @Description   : This method is called by the above trigger. It does not allow multiple integration users in the org.
* @CreatedBy     : Deloitte Consulting
* @CreatedOn     : 22-09-2017 [Nileshwari Patil]
***************/
    public void CheckOnlyOneIntegrationUser(Map<Id,User> oldUserMap,list<User> newUserList, Boolean isUpdate){
        List<User> integrationUserList = new List<User>();
        integrationUserList = [Select Id From User Where FBE_Integration_User__c=true];
        system.debug('integrationUserList'+integrationUserList);
        Set<Id> newIntUserIdSet = new Set<Id>();
        integer count = 0;
        
        if(!integrationUserList.isEmpty() && integrationUserList.size()>0 && newUserList !=null && !newUserList.isEmpty()){  
            for(User newUser : newUserList){  
                
                if(!isUpdate && newUser.FBE_Integration_User__c){
                    newUser.addError(System.label.IntegrationUserErrorMessage); 
                }else if(oldUserMap!=null && !oldUserMap.isEmpty() && !oldUserMap.get(newUser.Id).FBE_Integration_User__c && newUser.FBE_Integration_User__c){
                    system.debug('Old '+oldUserMap.get(newUser.Id).FBE_Integration_User__c+'New '+newUser.FBE_Integration_User__c);
                    //if update trigger is fired
                    newUser.addError(System.label.IntegrationUserErrorMessage);      
                }
            }
        }
        else
            if(newUserList!=null && !newUserList.isEmpty()){
                for(User newUser : newUserList){
                    if(newUser.FBE_Integration_User__c==true){
                        system.debug('newUser::'+newUser.FirstName);
                        count = count+1;
                        if(count>=2){
                            newUser.addError(System.label.IntegrationUserErrorMessage);      
                        }  
                    }
                }
            }
        
        
        
        
    }
    
    /**************
* @MethodName    : syncOptyTeamMembers
* @Trigger       : FBE_OpportunityTrigger
* @Description   : This method is called by the above trigger. In this method, checking for updated account fields and 
do add/delete its Team Members in Opty Team. 
* @CreatedBy     : Deloitte Consulting

***************/
  /*  public void syncOptyTeamMembers(Map<Id,Opportunity> oldOptyMap,list<Opportunity> newOptyList, String tEvent){
        //List<Opportunity> integrationUserList = new List<Opportunity>();
        for (Opportunity opp : newOptyList) {       
            if(tEvent == 'Update'){
                // Access the "old" record by its ID in Trigger.oldMap
                Opportunity oldOpp = oldOptyMap.get(opp.Id);
                //AccountId Field Is Updated  
                checkUpdatedAccount(Opp.Id,oldOpp.AccountId,opp.AccountId);
                //FBE_End_User__c Field Is Updated  
                checkUpdatedAccount(Opp.Id,oldOpp.FBE_End_User__c,opp.FBE_End_User__c);
                //Sold To Account Field Is Updated 
                checkUpdatedAccount(Opp.Id,oldOpp.FBE_FSI_Account__c,opp.FBE_FSI_Account__c); //Pratibha 12/14- Added this for FSI Account team members
                //FSI Account field is Updated
                //  checkUpdatedAccount(Opp.Id,oldOpp.FBE_Sold_To_Account__c,opp.FBE_Sold_To_Account__c);
                //FBE_VAR_Seller__c Field Is Updated  
                checkUpdatedAccount(Opp.Id,oldOpp.FBE_VAR_Seller__c,opp.FBE_VAR_Seller__c);
                //FBE_System_Integrator__c Field Is Updated  
                //   checkUpdatedAccount(Opp.Id,oldOpp.FBE_System_Integrator__c,opp.FBE_System_Integrator__c);
                //FBE_Distributor__c Field Is Updated  
                checkUpdatedAccount(Opp.Id,oldOpp.FBE_Distributor__c,opp.FBE_Distributor__c);
                //FBE_Alliance_OEM_Provider__c Field Is Updated  
                checkUpdatedAccount(Opp.Id,oldOpp.FBE_Alliance_OEM_Provider__c,opp.FBE_Alliance_OEM_Provider__c); 
                
            }else if(tEvent == 'Insert'){
                if(opp.AccountId != null){
                    //call add flow
                    invokeFlow(Opp.Id,Opp.AccountId,'Add');  
                }     
                if(opp.FBE_End_User__c != null){
                    //call add flow
                    invokeFlow(Opp.Id,Opp.FBE_End_User__c,'Add');  
                } 
                if(opp.FBE_FSI_Account__c != null){
                    //Pratibha 12/14- Added this for FSI Account 
                    //call add flow
                    invokeFlow(Opp.Id,Opp.FBE_FSI_Account__c,'Add');  
                }
                if(opp.FBE_Sold_To_Account__c != null){
                    //call add flow
                    // invokeFlow(Opp.Id,Opp.FBE_Sold_To_Account__c,'Add');  
                } 
                if(opp.FBE_VAR_Seller__c != null){
                    //call add flow
                    invokeFlow(Opp.Id,Opp.FBE_VAR_Seller__c,'Add');  
                } 
                if(opp.FBE_System_Integrator__c != null){
                    //call add flow
                    // invokeFlow(Opp.Id,Opp.FBE_System_Integrator__c,'Add');  
                } 
                if(opp.FBE_Distributor__c != null){
                    //call add flow
                    invokeFlow(Opp.Id,Opp.FBE_Distributor__c,'Add');  
                } 
                if(opp.FBE_Alliance_OEM_Provider__c != null){
                    //call add flow
                    invokeFlow(Opp.Id,Opp.FBE_Alliance_OEM_Provider__c,'Add');  
                }           
            }else {
                //do nothing
            }
        }
    }
    public void checkUpdatedAccount(String OptyId, String OldFieldVal, String NewFieldVal){
        if(OldFieldVal != NewFieldVal){
            system.debug('old'+OldFieldVal); 
            system.debug('new'+NewFieldVal); 
            if(NewFieldVal != null){
                //call add flow
                invokeFlow(OptyId,NewFieldVal,'Add');  
                //call delete flow  
                if(OldFieldVal != null){
                    invokeFlow(OptyId,OldFieldVal,'Delete');
                }
            }else{                  
                if(OldFieldVal != null){
                    //call delete flow
                    invokeFlow(OptyId,OldFieldVal,'Delete');
                }
            }        
        }          
    }    */
    
    /**************
* @MethodName    : invokeFlow
* @Trigger       : syncOptyTeamMembers
* @Description   : This method is called by the method=syncOptyTeamMembers. Calling Flow using this method.
* @CreatedBy     : Deloitte Consulting
* @CreatedOn     : 11-12-2018 [Yogesh Mishra]
***************/
    
/*    public void invokeFlow(String OpportunityId, String AccountId, String Operation){
        try{
            //call flow
            Flow.Interview addRecords = new Flow.Interview.Sync_Opportunity_Team_with_Account_Team(new map<String,Object>{'OpportunityId' => OpportunityId,'AccountId'=>AccountId,'Operation'=>Operation});     
            addRecords.start(); 
        }catch(FlowException fex){
            // opty.addError('The problem in updating the contact: ‘+ex.getmessages());
            system.debug('Flow Exception Occurred'+fex.getMessage());
        }catch(Exception ex){
            system.debug('Exception Occurred'+ex.getMessage());
        }finally{
            //optional
        }
    }*/
    
   /**************
* @MethodName    : syncOptyTeamMembers
* @Trigger       : FBE_OpportunityTrigger
* @Description   : This method is called by the above trigger. In this method, checking for updated account fields and 
                    do add/delete its Team Members in Opty Team. 
* @CreatedBy     : Deloitte Consulting
* @Comment     :   Yogesh 12/11/2019 - Revamped this class after optimizing it. 
                    Yogesh 3/17/2020 - Added condition to filter out DFS Opportunities 
***************/
    public void syncOptyTeamMembers(Map<Id,Opportunity> oldOptyMap,list<Opportunity> newOptyList, String tEvent){
        Map<Id,Set<Id>> accMap = new Map<Id,Set<Id>>();
        system.debug('New Opportunities List :'+newOptyList);
        for (Opportunity opp : newOptyList) {     
           if((tEvent == 'Update' && opp.RecordTypeId != Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('DFS Opportunity').getRecordTypeId()) &&
              (tEvent == 'Update' && opp.RecordTypeId != Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BD Capture Team Record Type').getRecordTypeId()) ){
                  system.debug('Not DFS & Not BD');
                // Access the "old" record by its ID in Trigger.oldMap
                Opportunity oldOpp = oldOptyMap.get(opp.Id);
                  system.debug(opp.AccountId+'Opportunity Primary Account , Distributor Account '+opp.FBE_Distributor__c);
                //AccountId Field Is Updated  
                checkUpdatedAccount(Opp.Id,oldOpp.AccountId,opp.AccountId);
                  system.debug(oldOpp.AccountId+'Opportunity Old Account Id, New Account Id'+opp.AccountId);
                //FBE_End_User__c Field Is Updated  
                checkUpdatedAccount(Opp.Id,oldOpp.FBE_End_User__c,opp.FBE_End_User__c);
                //FSI Account Field Is Updated 
                checkUpdatedAccount(Opp.Id,oldOpp.FBE_FSI_Account__c,opp.FBE_FSI_Account__c); 
                //FBE_VAR_Seller__c Field Is Updated  
                checkUpdatedAccount(Opp.Id,oldOpp.FBE_VAR_Seller__c,opp.FBE_VAR_Seller__c);
                //FBE_Distributor__c Field Is Updated  
                checkUpdatedAccount(Opp.Id,oldOpp.FBE_Distributor__c,opp.FBE_Distributor__c);
                  
                //FBE_Alliance_OEM_Provider__c Field Is Updated  
                checkUpdatedAccount(Opp.Id,oldOpp.FBE_Alliance_OEM_Provider__c,opp.FBE_Alliance_OEM_Provider__c);  
                  system.debug('Boolean check :'+isAccntUpdated);
               if(isAccntUpdated==true){
                   
                    newAccntIds.add(opp.AccountId);
                    newAccntIds.add(opp.FBE_End_User__c);
                    newAccntIds.add(opp.FBE_FSI_Account__c);
                    newAccntIds.add(opp.FBE_VAR_Seller__c);
                    newAccntIds.add(opp.FBE_Distributor__c);
                    newAccntIds.add(opp.FBE_Alliance_OEM_Provider__c);    
                   System.debug(isAccntUpdated+'Updated Account Ids:'+newAccntIds);
                   
                }
                
            }else if(tEvent == 'Insert' 
                     && opp.RecordTypeId != Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('DFS Opportunity').getRecordTypeId()
                     && opp.RecordTypeId != Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BD Capture Team Record Type').getRecordTypeId()){
                newAccntIds.add(Opp.AccountId);
                newAccntIds.add(Opp.FBE_End_User__c);
                newAccntIds.add(Opp.FBE_FSI_Account__c);
                newAccntIds.add(Opp.FBE_VAR_Seller__c);
                newAccntIds.add(Opp.FBE_Distributor__c);
                newAccntIds.add(Opp.FBE_Alliance_OEM_Provider__c);                
                   
            }
        }
        FBE_OpportunityHelper obj = new FBE_OpportunityHelper();
        if(isAccntUpdated==true){
            system.debug('Boolean check Inside if:'+isAccntUpdated);
            if(!newAccntIds.isEmpty()){
            obj.Sync_Opportunity_Team_with_Account_Team(newOptyList,newAccntIds,'Delete');
            }
        }else{
            system.debug('Boolean check Inside if Else:'+isAccntUpdated);
            if(!newAccntIds.isEmpty()){
            obj.Sync_Opportunity_Team_with_Account_Team(newOptyList,newAccntIds,'Add');
            }
        }
    }
    public void checkUpdatedAccount(String OptyId, String OldFieldVal, String NewFieldVal){
        if(OldFieldVal != NewFieldVal){
            //System.debug('Some Account was updated, Old Value ' +OldFieldVal+' New FieldValue: '+NewFieldVal);
            isAccntUpdated = true;
        }          
    }        
    
    /**************
* @MethodName    : createDealTeamMemberShare
* @Trigger       : FBE_CheckDuplicateTeamMember 
* @Description   : This method is called from Trigger=FBE_CheckDuplicateTeamMember. In this method, checking for duplicate entries for Team Member and throw error.
* @CreatedBy     : Deloitte Consulting
* @CreatedOn     : 22-1-2019 [Yogesh Mishra]
***************/
    public void createDealTeamMemberShare(List<FBE_Deal_Registration_Team__c > newdealRegTeamList){
        List<FBE_Deal_Registration_Team__c > manualdealRegTeamList = new List<FBE_Deal_Registration_Team__c >();
        FBE_DealHelper dealHelper = new FBE_DealHelper();
        for (FBE_Deal_Registration_Team__c dtnew: newdealRegTeamList)
        {    system.debug('from Deal Team Trigger'+dtnew);
            if(dtnew.FBE_Auto_Created__c  == 'N'){  
                manualdealRegTeamList.add(dtnew);
            }
        }
        if(manualdealRegTeamList.size()>0){
            dealHelper.createDealTeamMemberShare(manualdealRegTeamList);
        }
    } 
    
    /**************
* @MethodName    : CheckDuplicateDealTeamMember
* @Trigger       : FBE_CheckDuplicateTeamMember 
* @Description   : This method is called from Trigger=FBE_CheckDuplicateTeamMember. In this method, checking for duplicate entries for Team Member and throw error.
* @CreatedBy     : Deloitte Consulting
* @CreatedOn     : 22-1-2019 [Yogesh Mishra]
* @ModifiedOn     :21-1-2020 [Ankita Shingvi - PRODUCTION Incident 166331 ]
***************/
    public void CheckDuplicateDealTeamMember(List<FBE_Deal_Registration_Team__c > newdealRegTeamList){
        try{
            Map<Id,Set<String>> existingDealTeam = new Map<Id,Set<String>>();
            List<FBE_Deal_Registration_Team__c > dealRegTeamList = new List<FBE_Deal_Registration_Team__c>();
            List<Id> dealIDs = new List<Id>();
            for (FBE_Deal_Registration_Team__c dtnew: newdealRegTeamList){
                if(dtnew.FBE_Auto_Created__c  == 'N'){  
                    dealIDs.add(dtnew.Deal_Registration__c);
                }
            }
            if(dealIDs != null && dealIDs.size()>0){
                dealRegTeamList = [Select Id, Deal_Registration__c, User__c from FBE_Deal_Registration_Team__c where Deal_Registration__c IN :dealIDs LIMIT 50000]; 
            }
            for(FBE_Deal_Registration_Team__c dt: dealRegTeamList){
                if(existingDealTeam.containsKey(dt.Deal_Registration__c)) {
                    Set<String> combVal = existingDealTeam.get(dt.Deal_Registration__c);
                    combVal.add(''+dt.Deal_Registration__c+dt.User__c);
                    existingDealTeam.put(dt.Deal_Registration__c, combVal);
                } else {
                    existingDealTeam.put(dt.Deal_Registration__c, new Set<String> { ''+dt.Deal_Registration__c+dt.User__c });
                }
            }
            if(existingDealTeam != null && existingDealTeam.size() > 0){
                for (FBE_Deal_Registration_Team__c dtnew: newdealRegTeamList){      
                    if(existingDealTeam.get(dtnew.Deal_Registration__c).contains(''+dtnew.Deal_Registration__c+dtnew.User__c)){
                        dtnew.User__c.addError('Cannot add duplicate team members. Please edit the existing record.');
                    }            
                }
            }   
        }catch(Exception ex){
            system.debug('Exception Occurred'+ex.getMessage());
        }   
    }
    
    /**************
* @MethodName    : syncDealTeamMembers
* @Trigger       : FBE_DealRegTrigger
* @Description   : This method is called by the above trigger. In this method, checking for updated account fields and 
do add/delete its Team Members in Deal Team. 
* @CreatedBy     : Deloitte Consulting

***************/
    public void syncDealTeamMembers(Map<Id,Deal_Registration__c> oldDealMap,list<Deal_Registration__c> newDealList, String tEvent){
        Map<Id,Set<Id>> accMap = new Map<Id,Set<Id>>();
        //List<Opportunity> integrationUserList = new List<Opportunity>();
        //system.debug('newDealList'+newDealList.size());
        for (Deal_Registration__c deal : newDealList) {       
            if(tEvent == 'Update'){
                // Access the "old" record by its ID in Trigger.oldMap 
                Deal_Registration__c oldDeal = oldDealMap.get(deal.Id);
                //FBE_Account__c Field Is Updated  
                checkUpdatedAccount1(deal.Id,oldDeal.FBE_Account__c,deal.FBE_Account__c);
                //FBE_End_User_Account__c Field Is Updated  
                checkUpdatedAccount1(deal.Id,oldDeal.FBE_End_User_Account__c,deal.FBE_End_User_Account__c);
                //Sold To Account Field Is Updated 
                checkUpdatedAccount1(deal.Id,oldDeal.FBE_FSI_Account__c,deal.FBE_FSI_Account__c); //Pratibha 12/14- Added this for FSI Account team members
                checkUpdatedAccount1(deal.Id,oldDeal.FBE_Reseller_VAR_Account__c,deal.FBE_Reseller_VAR_Account__c);
                //FBE_Distributor_Account__c Field Is Updated  
                checkUpdatedAccount1(deal.Id,oldDeal.FBE_Distributor_Account__c,deal.FBE_Distributor_Account__c);
                //FBE_OEM_Account__c Field Is Updated  
                checkUpdatedAccount1(deal.Id,oldDeal.FBE_OEM_Account__c,deal.FBE_OEM_Account__c);  
                
                
                if(isAccntUpdated==true){
                    newAccntIds.add(deal.FBE_Account__c);
                    newAccntIds.add(deal.FBE_End_User_Account__c);
                    newAccntIds.add(deal.FBE_FSI_Account__c);
                    newAccntIds.add(deal.FBE_Reseller_VAR_Account__c);
                    newAccntIds.add(deal.FBE_Distributor_Account__c);
                    newAccntIds.add(deal.FBE_OEM_Account__c);
                    //System.debug('Calling Helper with DELETE Operation');
                    if(!newAccntIds.isEmpty()){
                        accMap.put(deal.Id,newAccntIds); 
                    }
                    // FBE_dealortunityHelper.Sync_dealortunity_Team_with_Account_Team(deal.Id,newAccntIds,'Delete');
                }
                
            }else if(tEvent == 'Insert'){
                newAccntIds.add(deal.FBE_Account__c);
                newAccntIds.add(deal.FBE_End_User_Account__c);
                newAccntIds.add(deal.FBE_FSI_Account__c);
                newAccntIds.add(deal.FBE_Reseller_VAR_Account__c);
                newAccntIds.add(deal.FBE_Distributor_Account__c);
                newAccntIds.add(deal.FBE_OEM_Account__c);
                if(!newAccntIds.isEmpty()){
                    accMap.put(deal.Id,newAccntIds);
                    //FBE_dealortunityHelper.Sync_dealortunity_Team_with_Account_Team(deal.Id,newAccntIds,'Add');
                }
                
            }
        }
        FBE_DealHelper obj = new FBE_DealHelper();
        if(isAccntUpdated==true){
            if(!newAccntIds.isEmpty()){
                obj.Sync_Deal_Team_with_Account_Team(newDealList,newAccntIds,'Delete');
            }
        }else{
            if(!newAccntIds.isEmpty()){
                obj.Sync_Deal_Team_with_Account_Team(newDealList,newAccntIds,'Add');
            }
        }
    }
    public void checkUpdatedAccount1(String DealId, String OldFieldVal, String NewFieldVal){
        System.debug('JK - checkUpdatedAccount1');
        System.debug('OldFieldVal: '+OldFieldVal);
        System.debug('NewFieldVal: '+NewFieldVal);
            
        if(OldFieldVal != NewFieldVal){
             System.debug('JK 2- checkUpdatedAccount1');
            //System.debug('Some Account was updated, Old Value ' +OldFieldVal+' New FieldValue: '+NewFieldVal);
            isAccntUpdated = true;
            
            
        }          
    }
 

    
    /*
    @AuraEnabled
    public static void shareFileToCommunityUser(Id recID2 , Id recID) {
        System.debug('recID :: '+ recID + '   recID2::'+ recID2 );
        List<Id> contentDocIds = new List<Id>{recID2};
        ContentDocumentLink[] CDLinkArray = new List <ContentDocumentLink> ();
        ID dealownerId = [SELECt OwnerID from Deal_Registration__c where id =: recID].OwnerID;
        boolean isPortalUser = [select isPortalEnabled from user where id=:dealownerId].isPortalEnabled;
        System.debug('isPortalUser:: '+isPortalUser);
        if(isPortalUser == true && contentDocIds != null && contentDocIds.size()>0 ){
            for(Id docId : contentDocIds){     
                ContentDocumentLink Link = new ContentDocumentLink(ContentDocumentId = docId , LinkedEntityId = dealownerId, ShareType = 'V');
                CDLinkArray.add(Link);
            }
            try {
                system.debug(CDLinkArray.size());
                insert CDLinkArray;
            } catch (Exception e) {
                system.debug(e.getMessage());
            }
        }
    } */
}