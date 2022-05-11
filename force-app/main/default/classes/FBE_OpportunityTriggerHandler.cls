/**************
* @ClassName    : FBE_OpportunityTriggerHandler
* @Description  : Credated this class to Prevent the Account/Opty team members who are not part of var-reseller and Distributor accounts
* @CreatedBy     : DeLL Team
* @CreatedOn     : 11-28-2020 [Lavakumar]
* @LastModified  : May-21-2020 [Sireesha Myla]
***************/

public without sharing class FBE_OpportunityTriggerHandler{
    public static void directTeamMemValidation(List<opportunity> oppList,Map<ID,Opportunity> oldMap){
        List<Opportunity> filterList = new List<Opportunity>();
        set<ID> accountIds = new set<ID>();
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        for(Opportunity opp : oppList)
        {
            system.debug('$$$$1');
            
            if(profileName == 'Federal Core Sales Group' && opp.FBE_Pursuit_Type__c =='Indirect' && (opp.stageName == 'Won - 100%' || opp.stageName == 'Lost - 0%' || opp.stageName == 'Cancelled - 0%') && opp.stageName != oldMap.get(opp.id).stageName)
            {
                if(opp.FBE_Distributor__c == NULL && opp.FBE_VAR_Seller__c == NULL && opp.FBE_FSI_Account__c == NULL )
                {
                    system.debug('$$$$3');
                    opp.addError('Only account team members of the Distributor Account or the Reseller Account can close or win an Indirect Opportunity');
                }else if(opp.FBE_Distributor__c == NULL && opp.FBE_VAR_Seller__c == NULL && opp.FBE_FSI_Account__c != NULL)
                {
                    filterList.add(opp);
                    system.debug('FSI account exists&&&'+opp.FBE_FSI_Account__c);
                    accountIds.add(opp.FBE_FSI_Account__c);
                }else if(opp.FBE_Distributor__c != NULL && opp.FBE_VAR_Seller__c != NULL && opp.FBE_FSI_Account__c != NULL)
                {
                    filterList.add(opp);
                    system.debug('&&%%% Three accounts are not null'+opp.FBE_FSI_Account__c);
                    accountIds.add(opp.FBE_FSI_Account__c);
                    accountIds.add(opp.FBE_Distributor__c);
                    accountIds.add(opp.FBE_VAR_Seller__c);
                }
                else{
                    system.debug('$$$$4');
                    filterList.add(opp);
                    if(opp.FBE_Distributor__c != NULL )
                    {
                        system.debug('$$$$5');
                        accountIds.add(opp.FBE_Distributor__c);
                    }
                    if(opp.FBE_VAR_Seller__c != NULL)
                    {
                        system.debug('$$$$6');
                        accountIds.add(opp.FBE_VAR_Seller__c);
                    }
                }
            }
        }
        if(filterList.size() > 0 && accountIds.size() > 0)
        {
            system.debug('$$$$7');
            Id userId = userinfo.getUserId();
            set<ID> accountIdsAssocToUserIds = new set<ID>();
            //if(profileName == 'Federal Core Sales Group'){
            system.debug('$$$$8');
            for(AccountTeamMember accTeam : [select id ,userId,AccountId from AccountTeamMember where  AccountId IN : accountIds AND userId = :userId])
            {
                accountIdsAssocToUserIds.add(accTeam.AccountId);
            }
            //}
            system.debug('+++++'+accountIdsAssocToUserIds);
            //Map<ID,string> errorThrow = new Map<ID,string>();
            for(Opportunity opp : filterList)
            {
                // Not required to check the account Set size()
                system.debug('$$$$9');
                system.debug('+++++'+accountIdsAssocToUserIds);
                system.debug('contains'+accountIdsAssocToUserIds.contains(opp.FBE_Distributor__c));
                if(opp.FBE_Distributor__c!=NULL && opp.FBE_VAR_Seller__c == NULL && ! accountIdsAssocToUserIds.contains(opp.FBE_Distributor__c))
                {
                    system.debug('+++++');
                    system.debug('$$$$10');
                    //errorThrow(opp.id,'Error');
                    opp.addError('Only account team members of the Distributor Account or the Reseller Account can close or win an Indirect Opportunity');
                }else if(opp.FBE_VAR_Seller__c!=NULL && opp.FBE_Distributor__c==NULL && ! accountIdsAssocToUserIds.contains(opp.FBE_VAR_Seller__c))
                {
                    system.debug('$$$$11');
                    //errorThrow(opp.id,'Error');
                    opp.addError('Only account team members of the Distributor Account or the Reseller Account can close or win an Indirect Opportunity');
                }else if(opp.FBE_VAR_Seller__c!=NULL && opp.FBE_Distributor__c!=NULL && ! accountIdsAssocToUserIds.contains(opp.FBE_VAR_Seller__c) && ! accountIdsAssocToUserIds.contains(opp.FBE_Distributor__c))
                {
                    opp.addError('Only account team members of the Distributor Account or the Reseller Account can close or win an Indirect Opportunity');
                }else if(opp.FBE_VAR_Seller__c==NULL && opp.FBE_Distributor__c==NULL && opp.FBE_FSI_Account__c!=NULL && ! accountIdsAssocToUserIds.contains(opp.FBE_FSI_Account__c))
                {
                    System.debug('fsi only&&&'+opp.FBE_FSI_Account__c);
                    opp.addError('Only account team members of the FSI Account can close or win an Indirect Opportunity when there is no Distributor Account or VAR/Reseller Account populated');
                }else if(opp.FBE_VAR_Seller__c!=NULL && opp.FBE_Distributor__c!=NULL && opp.FBE_FSI_Account__c!=NULL && !accountIdsAssocToUserIds.contains(opp.FBE_VAR_Seller__c) && !accountIdsAssocToUserIds.contains(opp.FBE_Distributor__c) && accountIdsAssocToUserIds.contains(opp.FBE_FSI_Account__c) )
                {
                    System.debug('%%% fsi member not allowed here &&&'+opp.FBE_FSI_Account__c);
                    opp.addError('Only account team members of the Distributor Account or the Reseller Account can close or win an Indirect Opportunity');
                }
            }
            
        }
    }
    
    //Story-8330877
    public static void updateRevenueAlert(list<Opportunity> newList , Map<Id,Opportunity> oldMap) {
        for(Opportunity opty : newList){
            if(opty.Amount >= decimal.valueOf(System.Label.Opportunity_Revenue_Alert) && opty.Amount != oldMap.get(opty.Id).Amount && 
               (oldMap.get(opty.Id).Amount <= decimal.valueOf(System.Label.Opportunity_Revenue_Alert) || oldMap.get(opty.Id).Amount == null)){
                   string recordtypename = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opty.recordtypeid).getname();
                   if(recordtypename == 'Standard Opportunity'){
                       System.debug('inside method - updateRevenueAlert');
                       opty.FBE_Revenue_Alert_Popup__c = true;                
                   }
               }
            
            if(opty.Amount >= decimal.valueOf(System.Label.Opportunity_Revenue_Alert) && 
               (oldMap.get(opty.Id).StageName == 'Cancelled - 0%' || oldMap.get(opty.Id).StageName =='Lost - 0%')){
                   string oldRecordtype = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oldMap.get(opty.Id).recordtypeid).getname();
                   string currentRecordtype = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opty.recordtypeid).getname();
                   if(oldRecordtype == 'Locked Standard Opportunity' && currentRecordtype == 'Standard Opportunity'){
                       System.debug('inside: Locked Std - Std');
                       opty.FBE_Revenue_Alert_Popup__c = true;  
                   }
               }
        }
    }
    public static void shareOpptyRecordWithPartnerUser(List<Opportunity> lstOppty,Map<Id,Opportunity> Oldmap){
        Set<OpportunityShare> toShareOppty = new Set<OpportunityShare>();
        if(Oldmap != null && !Oldmap.isEmpty()){
            //Remove record sharing logic
            set<Id>  setUserIDs = new set<Id>();
            for(Opportunity opp: Oldmap.values()){
                if(opp.FBE_FPRM_Partner_Owner_Lookup__c != null){
                    setUserIDs.add(opp.FBE_FPRM_Partner_Owner_Lookup__c);
                }
                if(opp.FBE_FPRM_Partner_Sales_Rep__c != null){
                    setUserIDs.add(opp.FBE_FPRM_Partner_Sales_Rep__c);
                }                           
            }
            if(setUserIDs !=null && !setUserIDs.isEmpty()){
                List<OpportunityShare> lstOpptyShare = [SELECT Id,OpportunityId FROM OpportunityShare 
                                                        WHERE OpportunityId IN : Oldmap.keyset() 
                                                        AND UserOrGroupId IN : setUserIDs 
                                                        AND RowCause = 'Manual'];
                
                if(!lstOpptyShare.isEmpty()){
                    Database.delete(lstOpptyShare, false);
                }  
            }
            
        }
        //Assign record sharing logic
        set<Id>  setUserIDs = new set<Id>();
        if(lstOppty != null && !lstOppty.isEmpty()){
            for(Opportunity opp: lstOppty){
                if(opp.FBE_FPRM_Partner_Owner_Lookup__c	 != null){
                    setUserIDs.add(opp.FBE_FPRM_Partner_Owner_Lookup__c	);
                }
                if(opp.FBE_FPRM_Partner_Sales_Rep__c != null){
                    setUserIDs.add(opp.FBE_FPRM_Partner_Sales_Rep__c);
                }
            } 
        }
        if(setUserIDs !=null && !setUserIDs.isEmpty()){
            Map<Id,User> mapPartnerUser = new Map<Id, User>([SELECT Id,FBE_FPRM_OnlineRole__c FROM User WHERE Id IN:setUserIDs AND
                                                             (FBE_FPRM_OnlineRole__c = 'Disty Managed Sales Rep My Opty' OR
                                                              FBE_FPRM_OnlineRole__c ='Sales Rep My Opty')]);
            
            if(!mapPartnerUser.isEmpty()){
                for(Opportunity opp: lstOppty){
                    if(opp.FBE_FPRM_Partner_Owner_Lookup__c	 != null && mapPartnerUser.ContainsKey(opp.FBE_FPRM_Partner_Owner_Lookup__c	)){
                        OpportunityShare opptyShare = new OpportunityShare();
                        opptyShare.OpportunityId = opp.Id;
                        opptyShare.UserOrGroupId = opp.FBE_FPRM_Partner_Owner_Lookup__c	;
                        opptyShare.OpportunityAccessLevel ='Edit';
                        toShareOppty.add(opptyShare);
                    }
                    if(opp.FBE_FPRM_Partner_Sales_Rep__c != null &&  mapPartnerUser.ContainsKey(opp.FBE_FPRM_Partner_Sales_Rep__c)){
                        OpportunityShare opptyShare = new OpportunityShare();
                        opptyShare.OpportunityId = opp.Id;
                        opptyShare.UserOrGroupId = opp.FBE_FPRM_Partner_Sales_Rep__c;
                        opptyShare.OpportunityAccessLevel ='Edit';
                        toShareOppty.add(opptyShare);
                    }
                }
            }
            
        }
        
        List<OpportunityShare> opptyShareList = new List<OpportunityShare>(toShareOppty);
        if(!toShareOppty.isEmpty()){
            Database.SaveResult[] result = Database.insert(opptyShareList, false);
            for(Database.SaveResult sr: result){
                System.debug('result==='+sr);
            }
        }
        
    }
    //UserRole Validation on update ISG Selling Motion of the opportunity
    public static void userRoleValidation(List<Opportunity> lstOppty,Map<Id,Opportunity> Oldmap){
        List<Opportunity> opptyList = new List<Opportunity>();
        for(Opportunity oppRec : lstOppty) {
            if(oppRec.FBE_Storage_Selling_Motion__c == NULL) {
                opptyList.add(oppRec);
            }
        }
        system.debug('opptyList'+opptyList);
        if(opptyList.size() > 0) {
            FBE_OpportunityTriggerHandler.userRoleCheck(opptyList);
            
        }        
    }  
    //UserRole Validation on insert ISG Selling Motion of the opportunity
    public static void userRoleInsertValidation(List<Opportunity> lstOppty){
        List<Opportunity> opptyList = new List<Opportunity>();
        for(Opportunity oppRec : lstOppty) {
            if(oppRec.FBE_Storage_Selling_Motion__c == NULL) {
                opptyList.add(oppRec);
            }
        }
        if(opptyList.size() > 0) {
            FBE_OpportunityTriggerHandler.userRoleCheck(opptyList);
            
        }    }  
    //UserRole Validation  ISG Selling Motion of the opportunity
    public static void userRoleCheck(List<Opportunity> lstOppty){
        Id userId = userinfo.getUserId();
        
        User userDetails =[SELECT Id, UserRole.Name FROM User where Id=:userId]; 
        String opptyRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId();
        List<String> userRolesList = new List<String>();
        system.debug('userDetails'+userDetails);
        for(User_Roles__mdt userRole :  [SELECT Id, FBE_User_Roles__c,MasterLabel FROM User_Roles__mdt WHERE MasterLabel != NULL]) {
            if(userRole.FBE_User_Roles__c != NULL) {
                if(userRole.MasterLabel.contains('ISG')) {
                    userRolesList.addAll(userRole.FBE_User_Roles__c.split(','));
                }   
            }
        } 
        system.debug('userRolesList'+userRolesList.size());
        system.debug('userRolesList'+userRolesList);
        for(Opportunity oppRec : lstOppty) {
            system.debug('userRolesList.contains(userDetails.UserRole.Name)'+userRolesList.contains(userDetails.UserRole.Name)+' '+Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppRec.RecordTypeId).getname());
            if(userRolesList.contains(userDetails.UserRole.Name) && oppRec.FBE_Storage_Selling_Motion__c == NULL && (Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppRec.RecordTypeId).getname() == 'Standard Opportunity'
              || Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oppRec.RecordTypeId).getname() == 'Locked Standard Opportunity')) {
                oppRec.addError('ISG Selling Motion should be filled.');
            }
        } 
        
    }
    
}