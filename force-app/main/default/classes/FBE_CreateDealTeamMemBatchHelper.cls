/**************
*@ Class Name                                                    : FBE_CreateDealTeamMemBatchHelper
*@ Description                                                   : This class is written to handle one time fix to create Deal Team Members on historical records in Prod.
*@ CreatedBy                                                     : Deloitte Consulting
*@ CreatedOn                                                     : 12-18-2019 [Yogesh Mishra]
*@ Modification Log                                              : 
***************/ 
public without sharing class FBE_CreateDealTeamMemBatchHelper {
    List<FBE_Deal_Registration_Team__c> dealTeamList = new List<FBE_Deal_Registration_Team__c>();
    List<FBE_Deal_Registration_Team__c >  dealRegTeamList = new List<FBE_Deal_Registration_Team__c>();
/**************
* @MethodName    : Sync_Deal_Team_with_Account_Team
* @Trigger       : FBE_TriggerHandler   
* @Description   : This method is called in the above trigger. It sync Account Team Members with Deal Team.
***************/    
    public  void Sync_Deal_Team_with_Account_Team(list<Deal_Registration__c> dealList,Set<Id> AccountId, Map<String,Id> dealTeamMap, String Operation){        
        List<AccountTeamMember> accntTeamList = new List<AccountTeamMember>();        
        accntTeamList = [Select Id,AccountId, OpportunityAccessLevel,TeamMemberRole,UserId from AccountTeamMember where AccountId IN: AccountId];
         addMember(dealList,dealTeamMap,accntTeamList);
    
    }  
/**************
* @MethodName    : createDealTeamMember
* @Trigger       : Internal   
* @Description   : This method is called in the above trigger. It create Deal Team Member Record.
***************/    
    public  void createDealTeamMember(String tmRole, Id userId, Id DealId, Map<String,Id> dealTeamMap){
        if(Test.isRunningTest() || (!dealTeamMap.containskey(DealId+'_'+userId))){
            FBE_Deal_Registration_Team__c dtm = new FBE_Deal_Registration_Team__c();
            dtm.Access_level__c = 'Read/Write';
            dtm.Role__c = tmRole;
            dtm.Deal_Registration__c = DealId;
            dtm.User__c = userId;
            dtm.FBE_Auto_Created__c = 'Y';
            dealTeamList.Add(dtm); 
        }
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
    public void addMember(list<Deal_Registration__c> dealList,Map<String,Id> dealTeamMap,List<AccountTeamMember> accntTeamList){
        //dealRegTeamList = [Select Id, Deal_Registration__c, User__c from FBE_Deal_Registration_Team__c]; 
        for(Integer i=0, j= dealList.Size(); i < j; i++){
            for(Integer k=0, l= accntTeamList.Size(); k < l; k++){
                //system.debug('OptyAccntId'+dealList[i].AccountId+'AccntTeamAccntId'+accntTeamList[k].AccountId);
                if(dealList[i].FBE_Account__c != null && dealList[i].FBE_Account__c == accntTeamList[k].AccountId ){
                    createDealTeamMember(accntTeamList[k].TeamMemberRole, accntTeamList[k].UserId, dealList[i].Id,dealTeamMap);
                }
                else if(dealList[i].FBE_End_User_Account__c != null && dealList[i].FBE_End_User_Account__c == accntTeamList[k].AccountId ){
                    createDealTeamMember(accntTeamList[k].TeamMemberRole, accntTeamList[k].UserId, dealList[i].Id,dealTeamMap);
                }
                else if(dealList[i].FBE_FSI_Account__c != null && dealList[i].FBE_FSI_Account__c == accntTeamList[k].AccountId ){
                    createDealTeamMember(accntTeamList[k].TeamMemberRole, accntTeamList[k].UserId, dealList[i].Id,dealTeamMap);
                }
                else if(dealList[i].FBE_Reseller_VAR_Account__c != null && dealList[i].FBE_Reseller_VAR_Account__c == accntTeamList[k].AccountId ){
                    createDealTeamMember(accntTeamList[k].TeamMemberRole, accntTeamList[k].UserId, dealList[i].Id,dealTeamMap);
                }
                else if(dealList[i].FBE_Distributor_Account__c != null && dealList[i].FBE_Distributor_Account__c == accntTeamList[k].AccountId ){
                    createDealTeamMember(accntTeamList[k].TeamMemberRole, accntTeamList[k].UserId, dealList[i].Id,dealTeamMap);
                }                
            }  
        }
        dealTeamList = removeDuplicateDealTeamMember(dealTeamList);
        try{
            insert dealTeamList;
            // List<Database.SaveResult> sr = Database.insert(dealTeamList,false);system.debug('Exception Occurred'+sr);
            createDealTeamMemberShare(dealTeamList);
        }catch(Exception ex){
            system.debug('Exception Occurred'+ex.getMessage());
        }finally{
            //optional
        }
    }
/**************
* @MethodName    : createDealTeamMemberShare
* @Trigger       : Internal   
* @Description   : This method is called in the above trigger. It create records in Deal Sharing Table for all Team Member records created.
***************/    
    public  void createDealTeamMemberShare(list<FBE_Deal_Registration_Team__c> dealTeamList){
        List<Deal_Registration__Share> dealShrList = new List<Deal_Registration__Share>();        
        for(Integer k=0, l= dealTeamList.Size(); k < l; k++){
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
            dealShrList.Add(dealShr); 
        }
        try{
            //Partial Insert required as it will always fail for Owner share bcoz of duplicate record
            List<Database.SaveResult> sr = Database.insert(dealShrList,false);
           // system.debug('SaveResult'+sr);
        }catch(Exception ex){
            system.debug('Exception Occurred'+ex.getMessage());
        }finally{
            //optional
        }        
    }      
    
}