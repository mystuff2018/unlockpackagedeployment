/**************
*@ Class Name                                                    : FBE_LeadTriggerHandler
*@ Description                                                   : This class is written to handle the Trigger related to lead. The methods related to all the triggers
are referred here. 
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 10-24-2019 [Soumithri Rekha]
*@ Modification Log                                              : 
***************/                                                 
public without sharing class FBE_LeadTriggerHandler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public FBE_LeadTriggerHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
     /**************
* @MethodName    : AccontFieldsMand
* @Trigger       : FBE_LeadConvertTrigger
* @Description   : This method is called from Trigger=FBE_LeadConvertTrigger. In this method, gives manual access to lead owner who is not part of Account Team of Account FBE_Account_Name__c 
* @CreatedBy     : DeLL Team
* @CreatedOn     : 10-15-2019 [Soumithri Rekha]
***************/
    public void AccontFieldsMand(list < Lead > newLeadList) {
        List < Lead > ld = new List<Lead>();
        for (Lead le: (List < Lead > ) Trigger.new) {
            if(le.FBE_End_User_Account__c == null && le.FBE_Account_Name__c != null){
                le.FBE_End_User_Account__c = le.FBE_Account_Name__c;
                ld.add(le);
            }
        }
        try{
          update ld;  
        }
        catch(exception e){
            system.debug('error' + e.getCause()+'Line'+e.getLineNumber());
        }
        
        
    }
    /**************
* @MethodName    : AccessToLead
* @Trigger       : FBE_LeadConvertTrigger
* @Description   : This method is called from Trigger=FBE_LeadConvertTrigger. In this method, gives manual access to lead owner who is not part of Account Team of Account FBE_Account_Name__c 
* @CreatedBy     : DeLL Team
* @CreatedOn     : 10-15-2019 [Soumithri Rekha]
***************/
    
    
    public void AccessToLead(list < Lead > newLeadList) {
        List < AccountShare > jobShares = new List < AccountShare > ();
        Map<id,List<id>> leadAccountDetails = new Map<id,List<id>>();
        Map<id,id> leadOwnerDetails = new Map<id,id>();
        List<id> accountDetails = new List<id > ();
        Map < id, List<id> > accountTeamDetails = new Map < id, List<id> > ();
        List<ID> users = new List<ID>();
        for (Lead le: (List < Lead > ) Trigger.new) {
            /*if(le.FBE_Account_Name__c == null || le.FBE_End_User_Account__c == null){
                le.id.addError('AccountName and End User Account is Mandatory');
            }*/
            if(le.FBE_Account_Name__c != null && le.FBE_End_User_Account__c != null){
                leadAccountDetails.put(le.id,new List<id>{le.FBE_Account_Name__c,le.FBE_End_User_Account__c});
                leadOwnerDetails.put(le.id, le.OwnerId);
                accountDetails.add(le.FBE_Account_Name__c);
                accountDetails.add(le.FBE_End_User_Account__c);
            }
        }
        for(User ow: [Select id from user where id in: leadOwnerDetails.values()]){
            users.add(ow.id);
        }
        System.debug('accountDetails :' + accountDetails);
        if (accountDetails!= null && accountDetails.size() > 0) {
            for (AccountTeamMember atm: [Select UserId, TeamMemberRole, Id, AccountId From AccountTeamMember where AccountID in: accountDetails]) {
                if(!accountTeamDetails.keySet().contains(atm.UserId)){
                    accountTeamDetails.put(atm.UserId, new List<id>{atm.AccountId});
                }
                accountTeamDetails.get(atm.UserId).add(atm.AccountId);
            }
        }
        
        System.debug('accountTeamDetails :' + accountTeamDetails);
        
        for (Lead l: (List < Lead > ) Trigger.new) {
            List<id> AccountTeamAccounts = new List<Id>();
            if(accountTeamDetails.containsKey(l.OwnerId)){
                AccountTeamAccounts = accountTeamDetails.get(l.OwnerId);
            }
            List<id> getAccount = new List<Id>();
            if (leadAccountDetails != null && !leadAccountDetails.isEmpty()) {
                getAccount = leadAccountDetails.get(l.id);
            }
            System.debug('users for Account :' + getAccount);
            if(getAccount.size()>0){
                for(id ga : getAccount){
                    if (AccountTeamAccounts == null || !AccountTeamAccounts.contains(ga) && l.isConverted == false && users.contains(l.OwnerId)) {
                        AccountShare accountShare = new AccountShare();
                        accountShare.AccountId = ga;
                        accountShare.UserOrGroupId = l.OwnerId;
                        accountShare.AccountAccessLevel = 'Edit';
                        accountShare.OpportunityAccessLevel = 'Edit';
                        //accountShare.Rowcause = Schema.AccountShare.RowCause.ImplicitParent;
                        jobShares.add(accountShare);
                        
                    }
                }
            }
        }
        if (jobShares.size() > 0) {
            /** Insert all of the newly created Share records and capture save result **/
            INSERT jobShares;
            
        }
        
    }
    
    /**************
* @MethodName    : RemoveAccessToLead
* @Trigger       : FBE_LeadConvertTrigger
* @Description   : This method is called from Trigger=FBE_LeadConvertTrigger. In this method, removes manual access to lead owner after conversion or change of ownership who is not part of Account Team of Account FBE_Account_Name__c 
* @CreatedBy     : DeLL Team
* @CreatedOn     : 10-15-2019 [Soumithri Rekha]
***************/
    
    
    public void RemoveAccessToLead(Map < Id, Lead > oldLeadMap, list < Lead > AllNewLeadList, list < Lead > AllOldLeadList) {
        System.debug('Inside RemoveAccessToLead');
        Map < id, List<id> > AccountShareDetails = new Map < id, List<id> > ();
        Map < id, List<id>> OldAccountShareDetails = new Map < id, List<id> > ();
        Map < id, List<id> > OldEndAccountShareDetails = new Map < id, List<id> > ();
        List < id > AccountShareDeleteList = new List < id > ();
        List < id > LeadOwnerDetails = new List < id > ();
        Set < id > LeadOldOwnerDetails = new Set < id > ();
        Set < id > LeadOldAccountDetails = new Set < id > ();
        Set < id > LeadOldEndAccountDetails = new Set < id > ();
        List < AccountShare > jobShares = new List < AccountShare > ();
        Map < id, List<integer> > AggregateCountOfLeads = new Map < id, List<integer> > ();
        Map < id, integer > AggregateCountOfEndLeads = new Map < id, integer > ();
        for (Lead LeadAccountOld: oldLeadMap.Values()) {
            LeadOldOwnerDetails.add(LeadAccountOld.OwnerId);
            LeadOldAccountDetails.add(LeadAccountOld.FBE_Account_Name__c);
            LeadOldEndAccountDetails.add(LeadAccountOld.FBE_End_User_Account__c);
        }
        system.debug('LeadOldEndAccountDetails'+LeadOldEndAccountDetails);
        List < AggregateResult > countofLeads = [select count(id) cnt, OwnerID own, FBE_Account_Name__c name from Lead where isconverted = False and OwnerID in: LeadOldOwnerDetails and FBE_Account_Name__c in: LeadOldAccountDetails group by OwnerID, FBE_Account_Name__c];
        System.debug('countofLeads' + countofLeads);
        List < AggregateResult > countofEndLeads = [select count(id) cnt, OwnerID own, FBE_End_User_Account__c name from Lead where isconverted = False and OwnerID in: LeadOldOwnerDetails and FBE_End_User_Account__c in: LeadOldEndAccountDetails group by OwnerID, FBE_End_User_Account__c];
        
        System.debug('countofEndLeads' + countofEndLeads);
        for (Lead LeadAccount: AllNewLeadList) {
            Lead oldLead = oldLeadMap.get(LeadAccount.ID);
            LeadOwnerDetails.add(oldLead.ownerID);
            if(countofLeads.size()>0){
                for (AggregateResult ar: countofLeads) {
                    System.debug('Inside Aggregate Result For' + ar.get('own') + 'account' + ar.get('name'));
                    System.debug('Inside Lead Result For' + LeadAccount.OwnerID + 'account' + LeadAccount.FBE_Account_Name__c);
                    if (oldLead.OwnerID == (ID) ar.get('own') && oldLead.FBE_Account_Name__c == (ID) ar.get('name')) {
                        System.debug('Inside Aggregate Result For inside if');
                        AggregateCountOfLeads.put(LeadAccount.ID, new List<Integer>{(Integer) ar.get('cnt')});
                    }
                }
            }
            else                 
                AggregateCountOfLeads.put(LeadAccount.ID, new List<Integer>{0});
            if(countofEndLeads.size()>0){
                system.debug('countofEndLeads');
                for (AggregateResult ar: countofEndLeads) {
                    System.debug('Inside Aggregate Result For' + ar.get('own') + 'account' + ar.get('name'));
                    System.debug('Inside Lead Result For' + LeadAccount.OwnerID + 'account' + LeadAccount.FBE_End_User_Account__c);
                    if (oldLead.OwnerID == (ID) ar.get('own') && oldLead.FBE_End_User_Account__c == (ID) ar.get('name')) {
                        System.debug('Inside Aggregate Result For inside if');
                        AggregateCountOfLeads.get(LeadAccount.ID).add( (Integer) ar.get('cnt'));
                    }
                }
            }
            else{
                system.debug('inside null');
                AggregateCountOfLeads.get(LeadAccount.ID).add( (Integer) (0));
            }
        }
        System.debug('AggregateCountOfLeads' + AggregateCountOfLeads);
        
        for (AccountShare leSh: [select id, UserOrGroupId, AccountId, AccountAccessLevel from accountshare where Rowcause = 'Manual'
                                 and UserOrGroupId in: LeadOwnerDetails
                                ]) {
                                    //AccountShareDetails.put(leSh.id,leSh.UserOrGroupId);
                                    if(!AccountShareDetails.containsKey(leSh.UserOrGroupId)){
                                        AccountShareDetails.put(leSh.UserOrGroupId,new List<id>{leSh.id});
                                    }else
                                        AccountShareDetails.get(leSh.UserOrGroupId).add(leSh.id);
                                    
                                }
        for (AccountShare leSha: [select id, UserOrGroupId, AccountId, AccountAccessLevel from accountshare where Rowcause = 'Manual'
                                  and UserOrGroupId in: LeadOwnerDetails and AccountId in:LeadOldAccountDetails]) {
                                      if(!OldAccountShareDetails.containsKey(leSha.UserOrGroupId)){
                                          OldAccountShareDetails.put(leSha.UserOrGroupId,new List<id>{leSha.id});
                                      }else
                                          OldAccountShareDetails.get(leSha.UserOrGroupId).add(leSha.id); 
                                  }
        system.debug('OldAccountShareDetails'+OldAccountShareDetails);
        for (AccountShare leShas: [select id, UserOrGroupId, AccountId, AccountAccessLevel from accountshare where Rowcause = 'Manual'
                                   and UserOrGroupId in: LeadOwnerDetails and AccountId in:LeadOldEndAccountDetails
                                  ]) {
                                      if(!OldEndAccountShareDetails.containsKey(leShas.UserOrGroupId)){
                                          OldEndAccountShareDetails.put(leShas.UserOrGroupId,new List<id>{leShas.id});
                                      }else
                                          OldEndAccountShareDetails.get(leShas.UserOrGroupId).add(leShas.id); 
                                  }
        for (Lead le: AllNewLeadList) {
            System.debug('isconverted' + le.isConverted);
            List<Integer> leadCount = AggregateCountOfLeads.get(le.ID);
            Lead oldLead = oldLeadMap.get(le.ID);
            System.debug('OldLeadInfo' + oldLead.OwnerID);
            System.debug('NewLeadInfo' + Le.OwnerID);
            for(integer i = 0;i<=1;i++){
                if ( leadCount[i] == 0) {
                    if (le.OwnerID != oldLead.OwnerID && AccountShareDetails.get(oldLead.OwnerID) != null) {
                        System.debug('if owners are not same'); 
                        AccountShareDeleteList.addAll(AccountShareDetails.get(oldLead.OwnerID));
                    }if (le.FBE_Account_Name__c != oldLead.FBE_Account_Name__c && oldlead.FBE_Account_Name__c != le.FBE_End_User_Account__c && OldAccountShareDetails.get(oldLead.OwnerID) != null) {
                        System.debug('if Accounts are not same');
                         AccountShareDeleteList.addALL(OldAccountShareDetails.get(oldLead.OwnerID));
                    }
                    if (le.FBE_End_User_Account__c != oldLead.FBE_End_User_Account__c && oldlead.FBE_End_User_Account__c != le.FBE_Account_Name__c  && OldEndAccountShareDetails.get(oldLead.OwnerID) != null) {
                        System.debug('if end user Accounts are not same');
                         AccountShareDeleteList.addAll(OldEndAccountShareDetails.get(oldLead.OwnerID));
                    }
                    if (le.isConverted == true && AccountShareDetails.get(le.OwnerID) != null) {
                        System.debug('if Lead is converted');
                        AccountShareDeleteList.addAll(AccountShareDetails.get(le.OwnerID));
                    }
                }
            }
            
            
        }
        
        
        System.debug('AccountShareDeleteList' + AccountShareDeleteList);
        if (AccountShareDeleteList.size() > 0) {
            List < AccountShare > ashr = [Select id from Accountshare where id in: AccountShareDeleteList];
            if (ashr != null){
                DELETE(ashr);
            }    
        }
    }
    
         /**************
* @MethodName    : LeadStatusisNew
* @Trigger       : FBE_LeadConvertTrigger
* @Description   : This method is called from Trigger=FBE_LeadConvertTrigger. In this method, fliping the status into New when the status is Closed by Sales from Dell Main 
* @CreatedBy     : DeLL Team
* @CreatedOn     : 11-02-2021 [Siva Valluru]
***************/
/******** Revert the changes as per Biz
    public void LeadStatusisNew(list < Lead > newLeadList) {
        List < Lead > ld = new List<Lead>();
            Id DirectRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Direct Lead').getRecordTypeId();

        for (Lead le: newLeadList) {
            if(le.Status != null && le.Status == 'Closed by Sales' && le.Recordtypeid == DirectRecTypeId ){
               le.Status = 'New';
                ld.add(le);
            }
        }
       
        
    }
  ********/  
/**************
* @MethodName    : CloseTaskForLead
* @Description   : This method is called from Trigger=FBE_LeadConvertTrigger. In this method, We will close all open tasks associated to the Lead upon Conversion 
* @CreatedBy/On  : DELL [Chaitanya Kedarisetty] / 06-04-2021 
***************/
    public void CloseTaskForLead(List < Lead > oldLeadTask) {
        system.debug('Inside CloseTaskForLead');
        List <Task> LeadTaskList = new List<Task> ();
        for (Lead lt:oldLeadTask) {
            for (Lead tList : [select Id, ConvertedContactId, IsConverted FROM Lead where Id=:lt.Id]){
                system.debug('CloseTaskForLead - ConvertedContactId=>'+tList.ConvertedContactId);
                if(tList.ConvertedContactId!=null && tList.IsConverted==true){
                    system.debug('Inside If Loop for CloseTaskForLead');
                    for (Task LeadTask : [SELECT Id, WhoId, Status, Description from Task where Status != 'Closed' and RecordType.DeveloperName = 'Lead_Support_Request' and FBE_Lead_Created_Task__c = true and WhoId =:tList.ConvertedContactId]){
                        system.debug('CloseTaskForLead - LeadTasks=>'+LeadTask);
                        system.debug('Inside Size If Loop for CloseTaskForLead');
                        LeadTask.Status = 'Closed';
                        if (LeadTask.Description == null) {
                            LeadTask.Description = 'Auto Closure of Task during Lead Conversion';
                        }
            		LeadTaskList.add(LeadTask);
                    }
                }
            }
        }
        try{
            if(LeadTaskList.size()>0){
                system.debug('Inside Size If Loop for Update');
                update LeadTaskList;
            }
        }
        catch(exception exp){
            system.debug('error' + exp.getCause()+'Line'+exp.getLineNumber());
        }
    }
}