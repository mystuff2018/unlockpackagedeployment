/**************
*@ Class Name                                                    : FBE_DealHelper
*@ Description                                                   : This class is written to handle the Trigger related updates. 
                                                                    All methods realted to Deal Registration added here, getting called from FBE_TriggerHandler.
*@ CreatedBy                                                     : Deloitte Consulting
*@ CreatedOn                                                     : 16-08-2019 [Yogesh Mishra]
*@ Modification Log                                              : 05-19-2020 [Abhishek Kawle] : Added Apex Sharing Reason for Deal Sharing as part of Defect #8642038
***************/ 
public without sharing class FBE_DealHelper {
    List<FBE_Deal_Registration_Team__c> dealTeamList = new List<FBE_Deal_Registration_Team__c>();
    List<FBE_Deal_Registration_Team__c >  dealRegTeamList = new List<FBE_Deal_Registration_Team__c>();
/**************
* @MethodName    : Sync_Deal_Team_with_Account_Team
* @Trigger       : FBE_TriggerHandler   
* @Description   : This method is called in the above trigger. It sync Account Team Members with Deal Team.
***************/    
    public  void Sync_Deal_Team_with_Account_Team(list<Deal_Registration__c> dealList,Set<Id> AccountId, String Operation){        
        List<AccountTeamMember> accntTeamList = new List<AccountTeamMember>();        
        accntTeamList = [Select Id,AccountId, OpportunityAccessLevel,TeamMemberRole,UserId from AccountTeamMember where AccountId IN: AccountId];
        if(Operation == 'Add'){
            addMember(dealList,accntTeamList);
        }
        else if(Operation == 'Delete'){
            Set<Id> DealId = new Set<Id>();
            List <FBE_Deal_Registration_Team__c> dealTeamtoDelete = new List <FBE_Deal_Registration_Team__c>();
            for(Integer i=0, j= dealList.Size(); i < j; i++){
                DealId.add(dealList[i].Id);
            }
            dealTeamtoDelete = [Select Id from FBE_Deal_Registration_Team__c where Deal_Registration__c IN: DealId AND FBE_Auto_Created__c = 'Y'];            
            try{                
                if(dealTeamtoDelete.size() > 0 ) {
                    byPassValidation(true);
                    delete dealTeamtoDelete; 
                    byPassValidation(false);
                }                    
            }catch (Exception ex){
                byPassValidation(false);
                system.debug('Exception Occurred in Delete Step'+ex.getMessage());
            }         
            addMember(dealList,accntTeamList);
        }       
    }  
/**************
* @MethodName    : createDealTeamMember
* @Trigger       : Internal   
* @Description   : This method is called in the above trigger. It create Deal Team Member Record.
***************/    
    public  void createDealTeamMember(String tmRole, Id userId, Id DealId){
        FBE_Deal_Registration_Team__c dtm = new FBE_Deal_Registration_Team__c();
        dtm.Access_level__c = 'Read/Write';
        dtm.Role__c = tmRole;
        dtm.Deal_Registration__c = DealId;
        dtm.User__c = userId;
        dtm.FBE_Auto_Created__c = 'Y';
        dealTeamList.Add(dtm); 
    }   
/**************
* @MethodName    : removeDuplicateDealTeamMember
* @Trigger       : Internal   
* @Description   : This method is called in the above trigger. It removes duplicate Deal Team Member Records.
***************/    
    public List<FBE_Deal_Registration_Team__c > removeDuplicateDealTeamMember(List<FBE_Deal_Registration_Team__c > newdealRegTeamList){        
        Map<string,FBE_Deal_Registration_Team__c> m = new Map<string,FBE_Deal_Registration_Team__c>();
        for(FBE_Deal_Registration_Team__c dtm : newdealRegTeamList){
            if(!m.containsKey(String.valueOf(dtm.User__c)+String.valueOf(dtm.Deal_Registration__c))){
                m.put(String.valueOf(dtm.User__c)+String.valueOf(dtm.Deal_Registration__c),dtm);  
            }
        }  
        newdealRegTeamList = m.values();         
        return newdealRegTeamList;
    }  
/**************
* @MethodName    : addMember
* @Trigger       : Internal   
* @Description   : This method is called in the above trigger. It prepares list of team member records to create new.
***************/    
    public void addMember(list<Deal_Registration__c> dealList,List<AccountTeamMember> accntTeamList){
        //dealRegTeamList = [Select Id, Deal_Registration__c, User__c from FBE_Deal_Registration_Team__c]; 
        for(Integer i=0, j= dealList.Size(); i < j; i++){
            for(Integer k=0, l= accntTeamList.Size(); k < l; k++){
                //system.debug('OptyAccntId'+dealList[i].AccountId+'AccntTeamAccntId'+accntTeamList[k].AccountId);
                if(dealList[i].FBE_Account__c != null && dealList[i].FBE_Account__c == accntTeamList[k].AccountId ){
                    createDealTeamMember(accntTeamList[k].TeamMemberRole, accntTeamList[k].UserId, dealList[i].Id);
                }
                else if(dealList[i].FBE_End_User_Account__c != null && dealList[i].FBE_End_User_Account__c == accntTeamList[k].AccountId ){
                    createDealTeamMember(accntTeamList[k].TeamMemberRole, accntTeamList[k].UserId, dealList[i].Id);
                }
                else if(dealList[i].FBE_FSI_Account__c != null && dealList[i].FBE_FSI_Account__c == accntTeamList[k].AccountId ){
                    createDealTeamMember(accntTeamList[k].TeamMemberRole, accntTeamList[k].UserId, dealList[i].Id);
                }
                else if(dealList[i].FBE_Reseller_VAR_Account__c != null && dealList[i].FBE_Reseller_VAR_Account__c == accntTeamList[k].AccountId ){
                    createDealTeamMember(accntTeamList[k].TeamMemberRole, accntTeamList[k].UserId, dealList[i].Id);
                }
                else if(dealList[i].FBE_Distributor_Account__c != null && dealList[i].FBE_Distributor_Account__c == accntTeamList[k].AccountId ){
                    createDealTeamMember(accntTeamList[k].TeamMemberRole, accntTeamList[k].UserId, dealList[i].Id);
                }
                else if(dealList[i].FBE_OEM_Account__c != null && dealList[i].FBE_OEM_Account__c == accntTeamList[k].AccountId ){
                    createDealTeamMember(accntTeamList[k].TeamMemberRole, accntTeamList[k].UserId, dealList[i].Id);
                }       
            }  
        }
        dealTeamList = removeDuplicateDealTeamMember(dealTeamList);
        try{                       
            if(dealTeamList.size() > 0){
                byPassValidation(true);
                insert dealTeamList;
                byPassValidation(false);
            }            
        }catch(Exception ex){
            byPassValidation(false);
            system.debug('Exception Occurred'+ex.getMessage());
        }
    }
    
    private static void byPassValidation(Boolean isBypass){
        FBE_FPRM_Transfer_Deal_Check__c csTD = FBE_FPRM_Transfer_Deal_Check__c.getInstance(UserInfo.getProfileId());
        csTD.Is_Transfer_Deal__c = isBypass;
        update csTD; 
    }
/**************
* @MethodName    : createDealTeamMemberShare
* @Trigger       : Internal   
* @Description   : This method is called in the above trigger. It create records in Deal Sharing Table for all Team Member records created.
*@ Modification Log : 05-19-2020 [Abhishek Kawle] : Added Apex Sharing Reason for Deal Sharing as part of Defect #8642038
***************/    
    public  void createDealTeamMemberShare(list<FBE_Deal_Registration_Team__c> dealTeamList){
        system.debug('dealteamshare inside');
        List<Deal_Registration__Share> dealShrList = new List<Deal_Registration__Share>();        
        for(Integer k=0, l= dealTeamList.Size(); k < l; k++){
            system.debug('Inside for loop');
            Deal_Registration__Share dealShr  = new Deal_Registration__Share();
            // Set the ID of record being shared.
            dealShr.ParentId = dealTeamList[k].Deal_Registration__c;
            // Set the ID of user or group being granted access.
            dealShr.UserOrGroupId = dealTeamList[k].User__c;
            // Set the access level.
            if(dealTeamList[k].Access_level__c == 'Read'){
                dealShr.AccessLevel = dealTeamList[k].Access_level__c;
            }else{
                dealShr.AccessLevel = 'Edit'; 
            }
            //dealShr.RowCause = 'Manual';
            //Created custom row cause as Manual Rowcause sharing records are overwritten by Salesforce when owner field is updated.
            dealShr.RowCause = Schema.Deal_Registration__Share.RowCause.Deal_Team_Sharing__c; 
            dealShrList.Add(dealShr); 
            
        }
        system.debug('dealShrList'+dealShrList);
        try{
            //Partial Insert required as it will always fail for Owner share bcoz of duplicate record
            List<Database.SaveResult> sr = Database.insert(dealShrList,false);
           system.debug('SaveResult'+sr);
        }catch(Exception ex){
            system.debug('Exception Occurred'+ex.getMessage());
        }        
    }
}