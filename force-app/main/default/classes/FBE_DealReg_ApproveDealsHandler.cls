/**
* @description       : 
* @author            : Sitaram Teki
* @group             : 
* @last modified on  : 11-02-2021
* @last modified by  : Dipanshu Parakh
**/
public without sharing class FBE_DealReg_ApproveDealsHandler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private final static Set<String> CSG_BU_CATEGORIES = new Set<String>{'CSG Hardware', 'CSG Other'};
        public static String[] filters = new String[]{'%APOS%','%Nutanix%','%XC Series%', '%Service%','%SonicWALL%', '%VMWare%', '%Maintenance%', '%Warranty Extension%', '%Warranty%', '%Entitlement%', '%Renewal%'};   
            
            public FBE_DealReg_ApproveDealsHandler(boolean isExecuting, integer size) {
                m_isExecuting = isExecuting;
                BatchSize = size;
            }
    
    public void allMethodscall(Map<id,Deal_Registration__c> newDeals,Map<id,Deal_Registration__c> oldDeals){
        set<Id> apr1List = new set<Id>();
        set<Id> apr3List = new set<Id>();
        set<Id> apr5List = new set<Id>();
        set<Id> changestate =  new set<Id>();
        set<Id> rejectstate =  new set<Id>();
        set<Id> rejectstateAuto =  new set<Id>();
        set<Id> RecallStatus =  new set<Id>();
        set<Id> ifNone =  new set<Id>();
        
        for(Deal_Registration__c deal : newDeals.Values()){
            //System.debug('calling method #####'+deal.FBE_Distributor_Account__c + deal.FBE_FSI_Account__c + deal.FBE_Deal_Registration_Status__c + deal.FBE_PMO_Substatus__c);   
            
            if((deal.FBE_Distributor_Account__c != null && deal.FBE_FSI_Account__c == null && deal.FBE_Deal_Registration_Status__c == 'Submitted' && deal.FBE_PMO_Substatus__c == 'Under Review' && oldDeals.get(deal.ID).FBE_PMO_Substatus__c != 'Under Review') || 
               (deal.FBE_Reseller_VAR_Account__c != null && deal.FBE_Distributor_Account__c == null && deal.FBE_FSI_Account__c == null && deal.FBE_Deal_Registration_Status__c == 'Submitted' && deal.FBE_PMO_Substatus__c == 'Under Review' && oldDeals.get(deal.ID).FBE_PMO_Substatus__c != 'Under Review')){
                   System.debug('Inside First Approval ');
                   apr1List.add(deal.id);
               }
            if((deal.FBE_Distributor_Account__c != null && deal.FBE_FSI_Account__c != null && deal.FBE_Deal_Registration_Status__c == 'Submitted' && deal.FBE_PMO_Substatus__c == 'Under Review' && oldDeals.get(deal.ID).FBE_PMO_Substatus__c != 'Under Review') || 
               (deal.FBE_Reseller_VAR_Account__c != null && deal.FBE_Distributor_Account__c == null && deal.FBE_FSI_Account__c != null && deal.FBE_Deal_Registration_Status__c == 'Submitted' && deal.FBE_PMO_Substatus__c == 'Under Review' && oldDeals.get(deal.ID).FBE_PMO_Substatus__c != 'Under Review')){
                   System.debug('Inside Thrid APproval ');
                   apr3List.add(deal.id);
               }
            if(deal.FBE_Deal_Registration_Status__c == 'Recalled' && oldDeals.get(deal.ID).FBE_Deal_Registration_Status__c == 'Submitted'){
                System.debug('Inside Recalled');
                RecallStatus.add(deal.id);
            }
            /* if((deal.FBE_PMO_Substatus__c == 'Pending With PMO' &&( deal.FBE_Funding_Source__c == null || deal.FBE_Book_Date__c == null || deal.Sales_Stage__c == null || deal.FBE_Solution_Domain__c == null || deal.FBE_Book_Date__c < System.today()))){
deal.id.addError('Funding Source, Book Date in future, Sales Stage, Solution Domain is mandatory for PSP PMO Approval.');
}


if((deal.FBE_Deal_Registration_Status__c != 'Recalled' && deal.FBE_PMO_Substatus__c == 'Pending With PMO' && oldDeals.get(deal.ID).FBE_Secondary_Status__c != 'Sales Approved' && deal.FBE_Funding_Source__c != null && deal.FBE_Book_Date__c != null && deal.FBE_Book_Date__c >= System.today() && deal.Sales_Stage__c != null && deal.FBE_Solution_Domain__c != null)
|| (deal.FBE_Deal_Registration_Status__c != 'Recalled' && oldDeals.get(deal.ID).FBE_Secondary_Status__c != 'Sales Rejected'  && oldDeals.get(deal.ID).FBE_PMO_Substatus__c == 'Under Review' && deal.FBE_Secondary_Status__c != 'Pending Sales Review' && deal.FBE_Secondary_Status__c != 'PSP PMO Approved' && deal.FBE_Secondary_Status__c != 'PSP PMO Rejected' && deal.FBE_Funding_Source__c != null && deal.FBE_Book_Date__c != null && deal.Sales_Stage__c != null &&  deal.FBE_Book_Date__c >= System.today() && deal.FBE_Solution_Domain__c != null)){
System.debug('Inside Pending with PMO');
apr5List.add(deal.id);
}*/
            
            if((deal.FBE_Distributor_Account__c != null && deal.FBE_FSI_Account__c == null ) ||
               (deal.FBE_Reseller_VAR_Account__c != null && deal.FBE_Distributor_Account__c == null && deal.FBE_FSI_Account__c == null) ||
               (deal.FBE_Distributor_Account__c != null && deal.FBE_FSI_Account__c != null ) ||
               (deal.FBE_Reseller_VAR_Account__c != null && deal.FBE_Distributor_Account__c == null && deal.FBE_FSI_Account__c != null)
              ){
                  if(deal.FBE_Deal_Registration_Status__c == 'Submitted' && deal.FBE_PMO_Substatus__c == 'Pending With PMO' && oldDeals.get(deal.ID).FBE_Secondary_Status__c != 'Sales Approved')
                  {
                      System.debug('Inside Pending with PMO');
                      apr5List.add(deal.id);
                  }
              }
            
            if(deal.FBE_Secondary_Status__c == 'Sales Rejected' && oldDeals.get(deal.ID).FBE_Secondary_Status__c != 'Sales Rejected' && deal.FBE_PMO_Substatus__c != 'Pending With PMO'){
                System.debug('Inside Sales Rejected');
                rejectstate.add(deal.id);
            }
            if(deal.FBE_Secondary_Status__c == 'Passed SLA' && oldDeals.get(deal.ID).FBE_Secondary_Status__c != 'Passed SLA'){
                System.debug('Inside Passed SLA');
                rejectstateAuto.add(deal.id);
            }
            if(deal.FBE_Approval_Fired__c == true){
                changestate.add(deal.id);
            }
        }
        
        if(apr1List != NULL && apr1List.size()>0){
            callEUApproval(apr1List);
        }
        if(apr3List != NULL && apr3List.size()>0){
            callEUAndFSIApproval(apr3List);
        }
        if(changestate !=NULL && changestate.size()>0){
            ChangeStatus(changestate);
        }
        if(rejectstate != NULL && rejectstate.size()>0){
            RecallOrRejectStatus(rejectstate,System.label.FBE_Rejected_SalesTeam,'Reject');
        }
        if(rejectstateAuto != NULL && rejectstateAuto.size()>0){
            RecallOrRejectStatus(rejectstateAuto,System.label.FBE_Rejected_PassedSLA,'Reject');
        }
        if(apr5List !=NULL && apr5List.size()>0){
            callPSPPMOApproval(apr5List);
        }
        if(RecallStatus != Null && RecallStatus.Size()>0){
            RecallOrRejectStatus(RecallStatus,System.label.FBE_Status_Recalled,'Removed');
        }
    }
    
    /**************
* @MethodName    : callEUApproval
* @Trigger       : FBE_ApproveDeals
* @Description   : This method is called from Trigger=FBE_ApproveDeals. In this method,we invoke Approval Process =Test 
* @CreatedBy     : DeLL Team
* @CreatedOn     : 12-13-2019 [Soumithri Rekha, Sai]
***************/
    public static void callEUApproval(Set<Id> dealIds) {
        Map<Id, List<String>> dealIdWithAposProducts = new Map<Id,List<String>>();
        Map<Id, List<String>> dealIdWithNutanixProducts = new Map<Id,List<String>>();
        Map<Id, List<String>> dealIdWithSonicProducts = new Map<Id,List<String>>();
        Map<Id, List<String>> dealIdWithVmwareProducts = new Map<Id,List<String>>();
        Map<Id,Id> dealIdWithAccount = new Map<Id,Id>();
        Map<Id,List<Id>> dealIdWithVARDistAccount = new Map<Id,List<Id>>();// BDD2
        Map<Id,String> dealregQueue = new Map<Id,String>();
        
        Map<Id, List<AccountTeamMember>> EU_Accteammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id,List<AccountTeamMember>> dealIdWithEUTeammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id, List<AccountTeamMember>> Disti_Accteammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id,Id> dealIdWithDistiAccount = new Map<Id,Id>();
        Map<Id,List<AccountTeamMember>> dealIdWithDistiTeammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id, List<AccountTeamMember>> VAR_Accteammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id,Id> dealIdWithVARAccount = new Map<Id,Id>();
        Map<Id,List<AccountTeamMember>> dealIdWithVARTeammembers = new Map<Id,List<AccountTeamMember>>();
        
           String[] aesr = new String[]{'AE','SR'};
            
            string dealquery = 'Select id, FBE_Deal_Registration_Status__c,FBE_Deal_Reg__c,FBE_End_User_Account__c,FBE_Distributor_Account__c,FBE_Reseller_VAR_Account__c,';
        string prodquery = '(Select id,FBE_Product__r.Name,FBE_Product__r.FBE_BU_Category__c from Deal_Products__r where FBE_Product__r.Name Like: filters OR FBE_Product__r.FBE_BU_Category__c in :CSG_BU_CATEGORIES) from Deal_Registration__c where id in:dealIds';
        string queryt =dealquery+prodquery;
        
        for(Deal_Registration__c deal : database.query(queryt)){
            System.debug('#Allia deal'+deal);
            dealIdWithAccount.put(deal.Id , deal.FBE_End_User_Account__c);
            dealIdWithVARDistAccount.put(deal.Id, new List<Id>{deal.FBE_Distributor_Account__c,deal.FBE_Reseller_VAR_Account__c}); // BDD2
            dealregQueue.put(deal.Id , deal.FBE_Deal_Reg__c);
            if(deal.FBE_Distributor_Account__c != null || deal.FBE_Reseller_VAR_Account__c != null)
            {
                dealIdWithDistiAccount.put(deal.Id , deal.FBE_Distributor_Account__c);
                dealIdWithVARAccount.put(deal.Id , deal.FBE_Reseller_VAR_Account__c);
                
            }
        }
        
        // Retrieve approvers & notify accountteammembers
        String AccTeamRoles = System.Label.ApprovalRoles;
        AccTeamRoles = AccTeamRoles +';CLIENT_OSS;CLIENT_TSR';
        List<String> Notify_AccTeamRoles = AccTeamRoles.split(';');
        
        List<id> dealIdWithAccountvalue = dealIdWithAccount.values();
        string accountQuerys = 'Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole,user.email from AccountTeamMembers where TeamMemberRole IN : Notify_AccTeamRoles ) from Account where Id in:dealIdWithAccountvalue';
        for(Account a : database.query(accountQuerys)){
            System.debug('#Allia accountQuerys'+a);
            EU_Accteammembers.put(a.Id, a.AccountTeamMembers);
        }
        
        for(Id i : dealIdWithAccount.keySet()){
            if(dealIdWithAccount.get(i) != NULL && EU_Accteammembers.containsKey(dealIdWithAccount.get(i))){
                if(EU_Accteammembers.get(dealIdWithAccount.get(i)) != NULL){
                    dealIdWithEUTeammembers.put(i, EU_Accteammembers.get(dealIdWithAccount.get(i)));
                }   
            }
        }
        
        List<id> dealIdWithDistiAccountvalues = dealIdWithDistiAccount.values();
        // for Disti_Accteammembers
        string accountquery1 = 'Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole,user.email from AccountTeamMembers where TeamMemberRole IN :aesr) from Account where Id in:dealIdWithDistiAccountvalues';
        for(Account a : database.query(accountquery1)){
            Disti_Accteammembers.put(a.Id, a.AccountTeamMembers);
        }
        
        for(Id i : dealIdWithDistiAccount.keySet()){
            if(dealIdWithDistiAccount.get(i) != NULL && Disti_Accteammembers.containsKey(dealIdWithDistiAccount.get(i))){
                if(Disti_Accteammembers.get(dealIdWithDistiAccount.get(i)) != NULL){
                    dealIdWithDistiTeammembers.put(i, Disti_Accteammembers.get(dealIdWithDistiAccount.get(i)));
                }   
            }
        }
        
        List<id> dealIdWithVARAccountvalues = dealIdWithVARAccount.values();
        string accountquery2 = 'Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole,user.email from AccountTeamMembers where TeamMemberRole IN :aesr ) from Account where Id in:dealIdWithVARAccountvalues';
        // for VAR_Accteammembers
        for(Account a : database.query(accountquery2)){
            VAR_Accteammembers.put(a.Id, a.AccountTeamMembers);
        }
        
        for(Id i : dealIdWithVARAccount.keySet()){
            if(dealIdWithVARAccount.get(i) != NULL && VAR_Accteammembers.containsKey(dealIdWithVARAccount.get(i))){
                if(VAR_Accteammembers.get(dealIdWithVARAccount.get(i)) != NULL){
                    dealIdWithVARTeammembers.put(i, VAR_Accteammembers.get(dealIdWithVARAccount.get(i)));
                }   
            }
        }
        
        String[] Nutanixfilters = new String[]{'%Nutanix%','%XC Series%'};
            String[] Aposfilters = new String[]{'%APOS%','%Service%',  '%Maintenance%', '%Warranty Extension%', '%Warranty%', '%Entitlement%', '%Renewal%'};
                String[] Sonicfilters = new String[]{'%SonicWALL%'};
                    String[] Vmfilters = new String[]{'%VMWare%'};
                        set<id> dealregQueueKeyset = dealregQueue.Keyset();
                        string nuntanixquery = 'Select id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like: Nutanixfilters and Deal_Registration_Name__c in : dealregQueueKeyset';
        List<Deal_Product__c> NutanixMap = database.query(nuntanixquery);
        for(Deal_Product__c dealp : NutanixMap){
            if(!dealIdWithNutanixProducts.containsKey(dealp.Deal_Registration_Name__c)){
                dealIdWithNutanixProducts.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
            }else
                dealIdWithNutanixProducts.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
        }
        
        string aposquery = 'Select id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like: Aposfilters and Deal_Registration_Name__c in : dealregQueueKeyset';
        List<Deal_Product__c> AposMap = database.query(aposquery);
        for(Deal_Product__c dealp : AposMap){
            if(!dealIdWithAposProducts.containsKey(dealp.Deal_Registration_Name__c)){
                dealIdWithAposProducts.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
            }else
                dealIdWithAposProducts.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
        }
        
        string sonicquery = 'Select id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like:Sonicfilters and Deal_Registration_Name__c in : dealregQueueKeyset';
        List<Deal_Product__c> SonicMap = database.query(sonicquery);
        for(Deal_Product__c dealp : SonicMap){
            if(!dealIdWithSonicProducts.containsKey(dealp.Deal_Registration_Name__c)){
                dealIdWithSonicProducts.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
            }else
                dealIdWithSonicProducts.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
        }
        
        string vmquery = 'Select id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like:Vmfilters and Deal_Registration_Name__c in : dealregQueueKeyset';
        List<Deal_Product__c> VmMap = database.query(vmquery);
        for(Deal_Product__c dealp : VmMap){
            if(!dealIdWithVmwareProducts.containsKey(dealp.Deal_Registration_Name__c)){
                dealIdWithVmwareProducts.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
            }else
                dealIdWithVmwareProducts.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
        }
        
        List<String> AccountTeamRoles = System.Label.ApprovalRoles.split(';');
        List<id> dealIdWithAccountvalues = dealIdWithAccount.values();
        Map<Id, List<AccountTeamMember>> accountWithAccountMembers = new Map<Id,List<AccountTeamMember>>();
        string queryaccount3 = 'Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole from AccountTeamMembers where TeamMemberRole IN : AccountTeamRoles) from Account where Id IN:dealIdWithAccountvalues';
        for(Account a : database.query(queryaccount3)){
            accountWithAccountMembers.put(a.Id, a.AccountTeamMembers);
        }
        
        Map<Id,List<AccountTeamMember>> dealIdWithAccountTeam = new Map<Id,List<AccountTeamMember>>();
        Set<Id> dealIdsWithNoEligibleRoles = new Set<Id>();
        for(Id i : dealIdWithAccount.keySet()){
            if(dealIdWithAccount.get(i) != NULL && accountWithAccountMembers.containsKey(dealIdWithAccount.get(i))){
                if(accountWithAccountMembers.get(dealIdWithAccount.get(i)) != NULL){
                    dealIdWithAccountTeam.put(i, accountWithAccountMembers.get(dealIdWithAccount.get(i)));
                }
                if(accountWithAccountMembers.get(dealIdWithAccount.get(i)) == NULL || accountWithAccountMembers.get(dealIdWithAccount.get(i)).size() == 0 ){
                    
                    dealIdsWithNoEligibleRoles.add(i);
                }
            }
        }
        
        
        Map<Id,List<String>> dealIdWithVARDistiAccountMembers = new Map<Id,List<String>>();
        dealIdWithVARDistiAccountMembers = getDealWithActTeamMembers(dealIdWithVARDistAccount);
        
        List<String> roles = System.Label.EUFSIApprovalRoles.split(';');//AE;SR;DC_SS;ACCT_SE;TSR;CLIENT_OSS
        Map<Id,List<Id>> dealIdEUAccountTeamUserID = new Map<Id,List<Id>>();
        Map<Id,List<String>> dealIdAposAccountTeamUserID = new Map<Id,List<String>>();
        Map<Id,List<String>> dealIdVmwaresonicWallNutanixAccountTeamUserID = new Map<Id,List<String>>(); 
        Map<Id,List<Id>> dealIdwithAEId = new Map<Id,List<Id>>();
        for(Id dealId : dealIdWithAccountTeam.keySet()){
            for(AccountTeamMember atm : dealIdWithAccountTeam.get(dealId)){
                if(atm.TeamMemberRole == 'AE'){
                    if(!dealIdwithAEId.containsKey(dealId)){
                        dealIdwithAEId.put(dealId, new List<Id>{atm.User.Manager.Id});
                    }else{
                        dealIdwithAEId.get(dealId).add(atm.User.Manager.Id);
                    }
                }
                if(roles.contains(atm.TeamMemberRole)){
                    
                    if(!dealIdEUAccountTeamUserID.containsKey(dealId)){
                        dealIdEUAccountTeamUserID.put(dealId, new List<ID>{atm.UserId});
                    }else
                        dealIdEUAccountTeamUserID.get(dealId).add(atm.UserId);
                }
                if (dealIdWithAposProducts.containsKey(dealId)){
                    if(atm.TeamMemberRole == 'SVC_APOS_SR' && dealIdWithAposProducts.get(dealId).Size()>0){
                        
                        
                        if(!dealIdAposAccountTeamUserID.containsKey(dealId)){
                            dealIdAposAccountTeamUserID.put(dealId, new List<String>{atm.UserId});
                        }else
                            dealIdAposAccountTeamUserID.get(dealId).add(atm.UserId);
                    }
                }
                if (dealIdWithVmwareProducts.containsKey(dealId)){
                    if(dealIdWithVmwareProducts.get(dealId).Size()>0){
                        
                        if(!dealIdVmwaresonicWallNutanixAccountTeamUserID.containsKey(dealId)){
                            dealIdVmwaresonicWallNutanixAccountTeamUserID.put(dealId,new List<String>{System.label.FBE_VMWare_DLEmail});
                        }else
                            dealIdVmwaresonicWallNutanixAccountTeamUserID.get(dealId).add(System.label.FBE_VMWare_DLEmail);//FederalVMwareTeam@dell.com
                    }
                }
                if (dealIdWithSonicProducts.containsKey(dealId)){
                    if(dealIdWithSonicProducts.get(dealId).Size()>0){
                        
                        if(!dealIdVmwaresonicWallNutanixAccountTeamUserID.containsKey(dealId)){
                            dealIdVmwaresonicWallNutanixAccountTeamUserID.put(dealId, new List<String>{System.label.FBE_SonicWall_DLEmail});
                        }else
                            dealIdVmwaresonicWallNutanixAccountTeamUserID.get(dealId).add(System.label.FBE_SonicWall_DLEmail);//dealregistration@sonicwall.com
                    }
                }
                if (dealIdWithNutanixProducts.containsKey(dealId)){
                    if(dealIdWithNutanixProducts.get(dealId).Size()>0){
                        system.debug('Nutanix');
                        if(!dealIdVmwaresonicWallNutanixAccountTeamUserID.containsKey(dealId)){
                            dealIdVmwaresonicWallNutanixAccountTeamUserID.put(dealId, new List<String>{System.label.FBE_Nutanix_DLEmail});
                        }else
                            dealIdVmwaresonicWallNutanixAccountTeamUserID.get(dealId).add(System.label.FBE_Nutanix_DLEmail);//Dell_Nutanix_Deal_Registration@Dell.com
                    }
                }
            }
        }
        
        if(dealIdWithEUTeammembers != null){
            SendEmailMessages_EUFSI(dealIdWithEUTeammembers,dealIdWithDistiTeammembers,dealIdWithVARTeammembers,null,dealIdWithAposProducts);
        }
        
        if(!dealIdVmwaresonicWallNutanixAccountTeamUserID.isEmpty()){
            SendEmailMessages(dealIdVmwaresonicWallNutanixAccountTeamUserID);   
        }
        
        
        if(!dealIdWithVARDistiAccountMembers.isEmpty()){
            
            //SendEmailMessages(dealIdWithVARDistiAccountMembers);   // bdd2
        }
        
        if(!dealIdAposAccountTeamUserID.isEmpty()){
            
            // SendEmailMessages(dealIdAposAccountTeamUserID); // bdd3
        }
        
        if(dealIdsWithNoEligibleRoles.size()>0){
            callPSPPMOApproval(dealIdsWithNoEligibleRoles);
        }else{
            for(Id dealId : dealregQueue.keySet()){
                if(dealregQueue.containsKey(dealId)){
                    System.enqueueJob(new FBE_CreateGroupForApproval(dealId,dealIdEUAccountTeamUserID.get(dealId),null,dealIdAposAccountTeamUserID.get(dealId),
                                                                     dealregQueue.get(dealId), dealIdwithAEId.get(dealId),dealIdWithVARDistiAccountMembers.get(dealId)));
                }
            }
        }
    }
    
    /************    
* @MethodName    : callEUAndFSIApproval
* @Trigger       : FBE_ApproveDeals
* @Description   : This method is called from Trigger=FBE_ApproveDeals. In this method,we invoke Approval Process =TestApproval1 
* @CreatedBy     : DeLL Team
* @CreatedOn     : 12-13-2019 [Soumithri Rekha, Sai]
*********************/
    public static void callEUAndFSIApproval(Set<id> dealIds) {
        Map<Id, List<String>> dealIdWithAposProducts = new Map<Id,List<String>>();
        Map<Id, List<String>> dealIdWithNutanixProducts = new Map<Id,List<String>>();
        Map<Id, List<String>> dealIdWithSonicProducts = new Map<Id,List<String>>();
        Map<Id, List<String>> dealIdWithVmwareProducts = new Map<Id,List<String>>();
        Map<Id,List<Id>> dealIdWithVARDistAccount = new Map<Id,List<Id>>();
        Map<Id,Id> dealIdWithAccount = new Map<Id,Id>();
        Map<Id,Id> dealidwithFSIAccount = new Map<Id,Id>();
        Map<Id,String> dealregQueue = new Map<Id,String>();
        Set<id> dealAccountSet = new Set<id>();
        
        String[] aesr = new String[]{'AE','SR'};
        
        Map<Id, List<AccountTeamMember>> EU_Accteammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id,List<AccountTeamMember>> dealIdWithEUTeammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id, List<AccountTeamMember>> Disti_Accteammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id,Id> dealIdWithDistiAccount = new Map<Id,Id>();
        Map<Id,List<AccountTeamMember>> dealIdWithDistiTeammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id, List<AccountTeamMember>> VAR_Accteammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id,Id> dealIdWithVARAccount = new Map<Id,Id>();
        Map<Id,List<AccountTeamMember>> dealIdWithVARTeammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id, List<AccountTeamMember>> FSI_Accteammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id,List<AccountTeamMember>> dealIdWithFSITeammembers = new Map<Id,List<AccountTeamMember>>();
        
        string dealquery = 'Select id, FBE_Deal_Registration_Status__c,FBE_Deal_Reg__c,FBE_FSI_Account__c,FBE_FSI_Internal_Use__c,FBE_Distributor_Account__c,FBE_Reseller_VAR_Account__c,FBE_End_User_Account__c,(Select id,FBE_Product__r.Name,FBE_Product__r.FBE_BU_Category__c from Deal_Products__r where FBE_Product__r.Name Like: filters OR FBE_Product__r.FBE_BU_Category__c in :CSG_BU_CATEGORIES) from Deal_Registration__c where id in:dealIds';
        for(Deal_Registration__c deal : database.query(dealquery)){
            dealIdWithAccount.put(deal.Id , deal.FBE_End_User_Account__c);
            if(deal.FBE_FSI_Account__c !=null && deal.FBE_FSI_Internal_Use__c !='Sell-in')
            { 
                dealidwithFSIAccount.put(deal.Id ,deal.FBE_FSI_Account__c); 
            }
            dealAccountSet.addAll(dealIdWithAccount.Values());
            dealAccountSet.addAll(dealidwithFSIAccount.Values());
            dealregQueue.put(deal.Id , deal.FBE_Deal_Reg__c);
            dealIdWithVARDistAccount.put(deal.Id, new List<Id>{deal.FBE_Distributor_Account__c,deal.FBE_Reseller_VAR_Account__c}); // bdd2
            if(deal.FBE_Distributor_Account__c != null || deal.FBE_Reseller_VAR_Account__c != null)
            {
                dealIdWithDistiAccount.put(deal.Id , deal.FBE_Distributor_Account__c);
                dealIdWithVARAccount.put(deal.Id , deal.FBE_Reseller_VAR_Account__c);
                
            }
        }
        
        // Retrieve approvers & notify accountteammembers
        String AccTeamRoles = System.Label.ApprovalRoles;
        AccTeamRoles = AccTeamRoles +';CLIENT_OSS;CLIENT_TSR';
        List<String> Notify_AccTeamRoles = AccTeamRoles.split(';');
        list<id> dealIdWithAccountvalues = dealIdWithAccount.values();
        string accountquery = 'Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole,user.email from AccountTeamMembers where TeamMemberRole IN : Notify_AccTeamRoles ) from Account where Id in:dealIdWithAccountvalues';
        for(Account a : database.query(accountquery)){ 
            EU_Accteammembers.put(a.Id, a.AccountTeamMembers);
        }
        
        for(Id i : dealIdWithAccount.keySet()){
            if(dealIdWithAccount.get(i) != NULL && EU_Accteammembers.containsKey(dealIdWithAccount.get(i))){
                if(EU_Accteammembers.get(dealIdWithAccount.get(i)) != NULL){
                    dealIdWithEUTeammembers.put(i, EU_Accteammembers.get(dealIdWithAccount.get(i)));
                }   
            }
        }
        
        List<id> dealIdWithDistiAccountvalues = dealIdWithDistiAccount.values();
        // for Disti_Accteammembers
        string accountquery1 = 'Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole,user.email from AccountTeamMembers where TeamMemberRole IN :aesr) from Account where Id in:dealIdWithDistiAccountvalues';
        for(Account a : database.query(accountquery1)){
            Disti_Accteammembers.put(a.Id, a.AccountTeamMembers);
        }
        
        for(Id i : dealIdWithDistiAccount.keySet()){
            if(dealIdWithDistiAccount.get(i) != NULL && Disti_Accteammembers.containsKey(dealIdWithDistiAccount.get(i))){
                if(Disti_Accteammembers.get(dealIdWithDistiAccount.get(i)) != NULL){
                    dealIdWithDistiTeammembers.put(i, Disti_Accteammembers.get(dealIdWithDistiAccount.get(i)));
                }   
            }
        }
        
        // for VAR_Accteammembers
        List<id> dealIdWithVARAccountvalues = dealIdWithVARAccount.values();
        string accountquery2 = 'Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole,user.email from AccountTeamMembers where TeamMemberRole IN :aesr ) from Account where Id in:dealIdWithVARAccountvalues';
        for(Account a : database.query(accountquery2) ){
            VAR_Accteammembers.put(a.Id, a.AccountTeamMembers);
        }
        
        for(Id i : dealIdWithVARAccount.keySet()){
            if(dealIdWithVARAccount.get(i) != NULL && VAR_Accteammembers.containsKey(dealIdWithVARAccount.get(i))){
                if(VAR_Accteammembers.get(dealIdWithVARAccount.get(i)) != NULL){
                    dealIdWithVARTeammembers.put(i, VAR_Accteammembers.get(dealIdWithVARAccount.get(i)));
                }   
            }
        }
        
        // Retrieve approvers & notify accountteammembers
        String FSITeamRoles = System.Label.EUFSIApprovalRoles;
        FSITeamRoles = FSITeamRoles +';CLIENT_OSS;CLIENT_TSR';
        List<String> Notify_FSITeamRoles = FSITeamRoles.split(';');
        
        List<id> dealIdWithFSIAccountvalues = dealIdWithFSIAccount.values();
        string accountquery4 = 'Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole,user.email from AccountTeamMembers where TeamMemberRole IN : Notify_FSITeamRoles ) from Account where Id in:dealIdWithFSIAccountvalues';
        for(Account a : database.query(accountquery4)){
            FSI_Accteammembers.put(a.Id, a.AccountTeamMembers);
        }
        
        for(Id i : dealIdWithFSIAccount.keySet()){
            if(dealIdWithFSIAccount.get(i) != NULL && FSI_Accteammembers.containsKey(dealIdWithFSIAccount.get(i))){
                if(FSI_Accteammembers.get(dealIdWithFSIAccount.get(i)) != NULL){
                    dealIdWithFSITeammembers.put(i, FSI_Accteammembers.get(dealIdWithFSIAccount.get(i)));
                }   
            }
        } 
        
        String[] Nutanixfilters = new String[]{'Nutanix%','XC Series%'};
            String[] Aposfilters = new String[]{'%APOS%','%Service%',  '%Maintenance%', '%Warranty Extension%', '%Warranty%', '%Entitlement%', '%Renewal%'};
                String[] Sonicfilters = new String[]{'%SonicWALL%'};
                    String[] Vmfilters = new String[]{'%VMWare%'};
                          set<id> dealregQueueKeyset = dealregQueue.Keyset();
                        string nutanixqery ='Select id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like: Nutanixfilters and Deal_Registration_Name__c in : dealregQueueKeyset';
        List<Deal_Product__c> NutanixMap = database.query(nutanixqery);
        for(Deal_Product__c dealp : NutanixMap){
            if(!dealIdWithNutanixProducts.containsKey(dealp.Deal_Registration_Name__c)){
                dealIdWithNutanixProducts.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
            }else
                dealIdWithNutanixProducts.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
        }
        
        string aposQuery = 'Select id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like: Aposfilters and Deal_Registration_Name__c in : dealregQueueKeyset';
        List<Deal_Product__c> AposMap = database.query(aposQuery);
        for(Deal_Product__c dealp : AposMap){
            if(!dealIdWithAposProducts.containsKey(dealp.Deal_Registration_Name__c)){
                dealIdWithAposProducts.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
            }else
                dealIdWithAposProducts.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
        }
        
        string sonicquery = 'Select id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like:Sonicfilters and Deal_Registration_Name__c in : dealregQueueKeyset';
        List<Deal_Product__c> SonicMap = database.query(sonicquery);
        for(Deal_Product__c dealp : SonicMap){
            if(!dealIdWithSonicProducts.containsKey(dealp.Deal_Registration_Name__c)){
                dealIdWithSonicProducts.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
            }else
                dealIdWithSonicProducts.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
        }
        
        string vmquery = 'Select id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like:Vmfilters and Deal_Registration_Name__c in : dealregQueueKeyset';
        List<Deal_Product__c> VmMap = database.query(vmquery);
        for(Deal_Product__c dealp : VmMap){
            if(!dealIdWithVmwareProducts.containsKey(dealp.Deal_Registration_Name__c)){
                dealIdWithVmwareProducts.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
            }else
                dealIdWithVmwareProducts.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
        } 
        
        List<String> AccountTeamRoles = System.Label.ApprovalRoles.split(';');
        Map<Id, List<AccountTeamMember>> accountWithAccountMembers = new Map<Id,List<AccountTeamMember>>();
        string accountquery0 = 'Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole from AccountTeamMembers where TeamMemberRole IN : AccountTeamRoles ) from Account where Id in:dealAccountSet';
        for(Account a : database.query(accountquery0)){
            accountWithAccountMembers.put(a.Id, a.AccountTeamMembers);
        }
        
        Set<Id> dealIdsWithNoEligibleRoles = new Set<Id>();
        Map<Id,List<AccountTeamMember>> dealIdWithAccountTeam = new Map<Id,List<AccountTeamMember>>();
        Map<Id,List<AccountTeamMember>> dealIdWithFsiAccountTeam = new Map<Id,List<AccountTeamMember>>();
        
        for(Id i : dealIdWithAccount.keySet()){
            if((dealIdWithAccount.get(i) != NULL && accountWithAccountMembers.containsKey(dealIdWithAccount.get(i)))){
                if((accountWithAccountMembers.get(dealIdWithAccount.get(i)) != NULL)){
                    
                    dealIdWithAccountTeam.put(i, accountWithAccountMembers.get(dealIdWithAccount.get(i)));
                    
                    
                }
            }
            if((dealidwithFSIAccount.get(i) != NULL && accountWithAccountMembers.containsKey(dealidwithFSIAccount.get(i)))){
                if((accountWithAccountMembers.get(dealidwithFSIAccount.get(i)) != NULL)){
                    dealIdWithFsiAccountTeam.put(i, accountWithAccountMembers.get(dealidwithFSIAccount.get(i)));
                }
            }
            
            if((accountWithAccountMembers.get(dealIdWithAccount.get(i)) == NULL && accountWithAccountMembers.get(dealidwithFSIAccount.get(i)) == Null) ||
               (accountWithAccountMembers.get(dealIdWithAccount.get(i)).size() == 0 && accountWithAccountMembers.containsKey(dealidwithFSIAccount.get(i)) && accountWithAccountMembers.get(dealidwithFSIAccount.get(i)).size() ==0)){
                   dealIdsWithNoEligibleRoles.add(i);
               }
        }
        
        
        Map<Id,List<String>> dealIdWithVARDistiAccountMembers = new Map<Id,List<String>>();
        dealIdWithVARDistiAccountMembers = getDealWithActTeamMembers(dealIdWithVARDistAccount);
        
        List<String> roles = System.Label.EUFSIApprovalRoles.split(';');
        Map<Id,List<Id>> dealIdEUAccountTeamUserID = new Map<Id,List<Id>>();
        Map<Id,List<Id>> dealIdFSIAccountTeamUserID = new Map<Id,List<Id>>();
        Map<Id,List<Id>> dealIdAposAccountTeamUserID = new Map<Id,List<Id>>();
        Map<Id,List<String>> dealIdVmwaresonicWallNutanixAccountTeamUserID = new Map<Id,List<String>>(); 
        Map<Id,List<Id>> dealIdwithAEId = new Map<Id,List<Id>>();
        for(Id dealId : dealIdWithAccountTeam.keySet()){
            // added containsKey check for dealIdWithFsiAccountTeam
            if(dealIdWithFsiAccountTeam.containsKey(dealId)){
                for(AccountTeamMember att : dealIdWithFsiAccountTeam.get(dealId)){
                    if(roles.contains(att.TeamMemberRole)){
                        system.debug('FSI Team');
                        if(!dealIdFSIAccountTeamUserID.containsKey(dealId)){
                            dealIdFSIAccountTeamUserID.put(dealId, new List<ID>{att.UserId});
                        }else
                            dealIdFSIAccountTeamUserID.get(dealId).add(att.UserId);
                    }
                }
            }
            for(AccountTeamMember atm : dealIdWithAccountTeam.get(dealId)){
                if(atm.TeamMemberRole == 'AE'){
                    if(!dealIdwithAEId.containsKey(dealId)){
                        dealIdwithAEId.put(dealId, new List<Id>{atm.User.Manager.Id});
                    }else{
                        dealIdwithAEId.get(dealId).add(atm.User.Manager.Id);
                    }
                }
                if(roles.contains(atm.TeamMemberRole)){
                    system.debug('EU Team');
                    if(!dealIdEUAccountTeamUserID.containsKey(dealId)){
                        dealIdEUAccountTeamUserID.put(dealId, new List<ID>{atm.UserId});
                    }else
                        dealIdEUAccountTeamUserID.get(dealId).add(atm.UserId);
                }
                
                if (dealIdWithAposProducts.containsKey(dealId)){
                    if(atm.TeamMemberRole == 'SVC_APOS_SR' && dealIdWithAposProducts.get(dealId).Size()>0){
                        system.debug('Apos');
                        if(!dealIdAposAccountTeamUserID.containsKey(dealId)){
                            dealIdAposAccountTeamUserID.put(dealId, new List<ID>{atm.UserId});
                        }else
                            dealIdAposAccountTeamUserID.get(dealId).add(atm.UserId);
                    }
                }
                if (dealIdWithVmwareProducts.containsKey(dealId)){
                    if(dealIdWithVmwareProducts.get(dealId).Size()>0){
                        system.debug('VMware');
                        if(!dealIdVmwaresonicWallNutanixAccountTeamUserID.containsKey(dealId)){
                            dealIdVmwaresonicWallNutanixAccountTeamUserID.put(dealId,new List<String>{System.label.FBE_VMWare_DLEmail});
                        }else
                            dealIdVmwaresonicWallNutanixAccountTeamUserID.get(dealId).add(System.label.FBE_VMWare_DLEmail);//FederalVMwareTeam@dell.com
                    }
                }
                if (dealIdWithSonicProducts.containsKey(dealId)){
                    if(dealIdWithSonicProducts.get(dealId).Size()>0){
                        system.debug('SonicWall');
                        if(!dealIdVmwaresonicWallNutanixAccountTeamUserID.containsKey(dealId)){
                            dealIdVmwaresonicWallNutanixAccountTeamUserID.put(dealId, new List<String>{System.label.FBE_SonicWall_DLEmail});
                        }else
                            dealIdVmwaresonicWallNutanixAccountTeamUserID.get(dealId).add(System.label.FBE_SonicWall_DLEmail);//dealregistration@sonicwall.com
                    }
                }
                if (dealIdWithNutanixProducts.containsKey(dealId)){
                    if(dealIdWithNutanixProducts.get(dealId).Size()>0){
                        system.debug('Nutanix');
                        if(!dealIdVmwaresonicWallNutanixAccountTeamUserID.containsKey(dealId)){
                            dealIdVmwaresonicWallNutanixAccountTeamUserID.put(dealId, new List<String>{System.label.FBE_Nutanix_DLEmail});
                        }else
                            dealIdVmwaresonicWallNutanixAccountTeamUserID.get(dealId).add(System.label.FBE_Nutanix_DLEmail);//Dell_Nutanix_Deal_Registration@Dell.com
                    }
                }
            }
        }
        
        if(dealIdWithEUTeammembers != null || dealIdWithFSITeammembers != null){
            SendEmailMessages_EUFSI(dealIdWithEUTeammembers,dealIdWithDistiTeammembers,dealIdWithVARTeammembers,dealIdWithFSITeammembers,dealIdWithAposProducts);
        }
        if(!dealIdVmwaresonicWallNutanixAccountTeamUserID.isEmpty()){
            system.debug('SonicWall#####EUFSI'+dealIdVmwaresonicWallNutanixAccountTeamUserID);
            SendEmailMessages(dealIdVmwaresonicWallNutanixAccountTeamUserID);   
        }
        if(!dealIdAposAccountTeamUserID.isEmpty()){
            system.debug('APOS#####EUFSI'+dealIdAposAccountTeamUserID);
            //SendEmailMessages(dealIdAposAccountTeamUserID);
        }
        if(!dealIdWithVARDistiAccountMembers.isEmpty()){
            system.debug('VARDistiAccountMembers#####EUFSI'+dealIdWithVARDistiAccountMembers);
            //SendEmailMessages(dealIdWithVARDistiAccountMembers);   // bdd2
        }
        if(dealIdsWithNoEligibleRoles.size()>0){
            system.debug('inside no roles FSI');
            callPSPPMOApproval(dealIdsWithNoEligibleRoles);
        }
        else{
            
            for(Id dealId : dealregQueue.keySet()){
                if(dealregQueue.containsKey(dealId)){
                    System.enqueueJob(new FBE_CreateGroupForApproval(dealId,dealIdEUAccountTeamUserID.get(dealId),dealIdFSIAccountTeamUserID.get(dealId),dealIdAposAccountTeamUserID.get(dealId),
                                                                     dealregQueue.get(dealId), dealIdwithAEId.get(dealId),dealIdWithVARDistiAccountMembers.get(dealId)));
                }
            }
        }
    }
    
    /****************        
* @MethodName    : ChangeStatus
* @Trigger       : FBE_ApproveDeals
* @Description   : This method is called from Trigger=FBE_ApproveDeals. In this method,is to change status to Approved 
* @CreatedBy     : DeLL Team
* @CreatedOn     : 12-13-2019 [Soumithri Rekha, Sai]
************/  
    public static void ChangeStatus(Set<Id> dealIds){
        system.debug('Inside Change Status');
        Map<Id, List<String>> ProccesSstatus = new Map<Id, List<String>>();
        List<ProcessInstance> pp = [SELECT TargetObjectId, Status, CreatedDate FROM ProcessInstance WHERE TargetObjectId in: dealIds AND  Status='Pending'];
        system.debug('ProcessInstance query'+pp);
        for(ProcessInstance Pl : [SELECT TargetObjectId, Status, CreatedDate FROM ProcessInstance WHERE TargetObjectId in: dealIds AND Status='Pending']){
            if(!ProccesSstatus.containsKey(Pl.TargetObjectId)){
                ProccesSstatus.put(Pl.TargetObjectId,new List<String> {Pl.Status});
            }else
                ProccesSstatus.get(Pl.TargetObjectId).add(Pl.Status);
        }
        system.debug('ProccesSstatus'+ProccesSstatus);
        List<Deal_Registration__c> updatedeal = new List<Deal_Registration__c> ();
        for(Deal_Registration__c deal : [Select id, FBE_Approval_Fired__c,FBE_Secondary_Status__c from Deal_Registration__c where id in:dealIds]){
            if(ProccesSstatus.containsKey(deal.id) && ProccesSstatus.get(deal.id).contains('Pending')) { 
                deal.FBE_Approval_Fired__c = false;
                system.debug('inside if FBE_Approval_Fired__c'+deal.FBE_Approval_Fired__c);
                updatedeal.add(deal);
            }else
            {
                deal.FBE_Approval_Fired__c = false;
                deal.FBE_Secondary_Status__c = 'Sales Approved';
                system.debug('inside else FBE_Approval_Fired__c'+deal.FBE_Secondary_Status__c);
                updatedeal.add(deal);
            }
            
        }
        if(updatedeal != null && updatedeal.size()>0){
            try{
                update updatedeal;
            }Catch(Exception e){
                System.debug(e);
            }
        }
        
    }  
    
    /****************        
* @MethodName    : RecallOrRejectStatus
* @Trigger       : FBE_ApproveDeals
* @Description   : This method is called from Trigger=FBE_ApproveDeals. In this method,is to change status to Sales Rejected 
* @CreatedBy     : DeLL Team
* @CreatedOn     : 12-13-2019 [Soumithri Rekha, Sai]
************/
    public static void RecallOrRejectStatus(Set<Id> dealIds,String comments, String state){
        system.debug('Inside Reject Status');
        Map<Id, List<String>> ProccesSstatus = new Map<Id, List<String>>();
        Map<Id, List<Id>> ProccessWorkStatus = new Map<Id, List<Id>>();
        Map<Id, List<String>> ProccessActorName = new Map<Id, List<String>>();
        List<ProcessInstance> pp = [SELECT TargetObjectId, Status, CreatedDate FROM ProcessInstance WHERE TargetObjectId in: dealIds AND  Status='Pending'];
        system.debug('ProcessInstance query'+pp);
        
        for(ProcessInstanceWorkitem Pl  : [Select p.Id,p.ProcessInstance.TargetObjectId,p.ProcessInstance.Status,p.Actor.Name from ProcessInstanceWorkitem p  where p.ProcessInstance.TargetObjectId in: dealIds AND p.ProcessInstance.Status ='Pending' and p.Actor.Name != 'PSPPMOTeamQueue'])
        {
            if(!ProccesSstatus.containsKey(Pl.ProcessInstance.TargetObjectId)){
                ProccesSstatus.put(Pl.ProcessInstance.TargetObjectId,new List<String> {Pl.ProcessInstance.Status});
            }else
                ProccesSstatus.get(Pl.ProcessInstance.TargetObjectId).add(Pl.ProcessInstance.Status);
            if(!ProccessActorName.containsKey(Pl.ProcessInstance.TargetObjectId)){
                ProccessActorName.put(Pl.ProcessInstance.TargetObjectId,new List<String> {Pl.Actor.Name});
            }else
                ProccessActorName.get(Pl.ProcessInstance.TargetObjectId).add(Pl.Actor.Name);
            if(!ProccessWorkStatus.containsKey(Pl.ProcessInstance.TargetObjectId)){
                ProccessWorkStatus.put(Pl.ProcessInstance.TargetObjectId,new List<String> {Pl.Id});
            }else
                ProccessWorkStatus.get(Pl.ProcessInstance.TargetObjectId).add(Pl.Id);
        }
        if(comments == System.label.FBE_Status_Recalled){
            for(ProcessInstanceWorkitem Pl  : [Select p.Id,p.ProcessInstance.TargetObjectId,p.ProcessInstance.Status,p.Actor.Name from ProcessInstanceWorkitem p  where p.ProcessInstance.TargetObjectId in: dealIds AND p.ProcessInstance.Status ='Pending' and p.Actor.Name = 'PSPPMOTeamQueue']){
                if(!ProccesSstatus.containsKey(Pl.ProcessInstance.TargetObjectId)){
                    ProccesSstatus.put(Pl.ProcessInstance.TargetObjectId,new List<String> {Pl.ProcessInstance.Status});
                }else
                    ProccesSstatus.get(Pl.ProcessInstance.TargetObjectId).add(Pl.ProcessInstance.Status);
                ProccessWorkStatus.put(Pl.ProcessInstance.TargetObjectId,new List<String> {Pl.Id});
            }
        }
        system.debug('ProccesSstatus'+ProccesSstatus);
        List<Deal_Registration__c> updatedeal = new List<Deal_Registration__c> ();
        for(Deal_Registration__c deal : [Select id, FBE_Approval_Fired__c,FBE_Secondary_Status__c,FBE_PMO_Substatus__c from Deal_Registration__c where id in:dealIds]){
            if((ProccesSstatus.containsKey(deal.id) && ProccesSstatus.get(deal.id).contains('Pending') )|| test.isRunningTest()) { 
                Approval.ProcessWorkitemRequest[] requestList = new Approval.ProcessWorkitemRequest[]{};
                    List<Id> workItemId = ProccessWorkStatus.get(deal.id); 
                if(workItemId != null && workItemId.size()>0)
                {
                    for(id itemid : workItemId){
                        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                        req.setWorkitemId(itemid);
                        req.setComments(comments);
                        req.setAction(state);
                        requestList.add(req);
                    }
                    try{
                        Approval.ProcessResult[] result =  Approval.process(requestList);
                    }catch(Exception e){
                        System.debug(e);
                    }
                }
            }
            if(comments != System.label.FBE_Status_Recalled){
                deal.FBE_Approval_Fired__c = false;
                deal.FBE_PMO_Substatus__c = 'Pending With PMO';
                system.debug('inside else FBE_Approval_Fired__c'+deal.FBE_PMO_Substatus__c);
                updatedeal.add(deal);
            }
            else{
                deal.FBE_PMO_Substatus__c = 'Sales Review';
                deal.FBE_Secondary_Status__c = '';
                deal.FBE_ApprovalFlowCheck__c = False;
                updatedeal.add(deal);
            }
            
        }
        if(updatedeal != null && updatedeal.size()>0){
            try{
                update updatedeal;
            }Catch(Exception e){
                system.debug(e);
            }
        }
    }
    
    
    /****************        
* @MethodName    :SendEmailMessages_EUFSI
* @Trigger       : FBE_ApproveDeals
* @Description   : Send Initial mails for EU/FSI/Disti/VAR/Reseller 
* @CreatedBy     : DeLL Team
* @CreatedOn     : 12-13-2019 [Siva Kumar Valluru]
* @Comments 	 : S-10383759 : Added Client_TSR and Client_OSS in CC address for EU/FSI for CSG_BU_CATEGORIES	
************/
    
    public static void SendEmailMessages_EUFSI(Map<id,List<AccountTeamMember>> EUTeamwithaccteams,Map<id,List<AccountTeamMember>> DistiTeamwithaccteams,Map<id,List<AccountTeamMember>> VARTeamwithaccteams,Map<id,List<AccountTeamMember>> FSITeamwithaccteams,Map<Id,List<String>> dealIdWithAposProducts) {
        
        // defect #10580424  - added FBE_Deal_Createddate__c,FBE_Formatted_Book_Date__c fields in SOQL query
        
        list<String> Toaddress = new list<String>();
        list<String> Ccaddress = new list<String>();
        list<String> FSI_Toaddress = new list<String>();
        list<String> FSI_Ccaddress = new list<String>();
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address =: System.label.FBE_Approval_OWD limit 1];
        
        set<id> EUTeam = EUTeamwithaccteams.keySet();
        string sub = 'Submitted';
        string dealquery = 'SELECT id,Name,FBE_Analyst_Observations_History__c,Analyst_Observations__c,FBE_Deal_Reg_Num__c,FBE_Opportunity_Number__c,CreatedDate,FBE_Submission_Date__c,FBE_Forecast_Amount__c,FBE_Deal_Justification_Statement__c,FBE_Book_Date__c, FBE_End_User_Account_Name__c,FBE_End_User_First_Name__c,FBE_End_User_Last_Name__c,FBE_End_User_Mailing_Street__c,FBE_End_User_Mailing_City__c,FBE_End_User_Mailing_State__c, FBE_End_User_Mailing_Zip__c,FBE_End_User_Mailing_Country__c,'+
            'FBE_End_User_Email__c,FBE_End_User_Phone__c,FBE_Reseller_VAR_Account__r.Name, FBE_Distributor_Account__r.Name,FBE_FSI_Account__r.Name,FBE_Partner_Sales_Rep_Name__c,'+
            'FBE_Partner_Sales_Rep_Email__c, FBE_End_User_Account__r.Name,FBE_Deal_Createddate__c,FBE_Formatted_Book_Date__c,FBE_Formatted_Submission_Date__c,'+
            '(Select FBE_Product__r.Name,FBE_Quantity__c,FBE_Product__r.FBE_BU_Category__c from Deal_Products__r)'+
            'FROM Deal_Registration__c WHERE Id IN :EUTeam';
        Map<Id,Deal_Registration__c> dealMap = new Map<Id, Deal_Registration__c>((List<Deal_Registration__c>)database.query(dealquery));
        
        EmailTemplate templ = [Select Id,Name,HtmlValue,Body,Markup from EmailTemplate where Name='FBE Deal Approval Notification Email' limit 1];
        
        for(Id dealId : dealMap.keySet()){  
            FBE_ApprovalEmailHandler.getEmailTemplate (dealMap.get(dealId),templ);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setOrgWideEmailAddressId(owea.Id);
            Deal_Registration__c dealObj = dealMap.get(dealId);
            List<Deal_Product__c> dealProductsList = dealObj.Deal_Products__r;
            String subject = FBE_ApprovalEmailHandler.getEmailSubject(dealObj, 'NOTIFICATION OF TIME SENSITIVE APPROVAL REQUEST: ');
            email.setSubject(subject);
            //email.setToAddresses(msg.get(dealId));
            if(EUTeamwithaccteams.containsKey(dealId)){
                for (List <AccountTeamMember> lst_AccTm : EUTeamwithaccteams.values()){
                    for (AccountTeamMember Acctm : lst_AccTm){                 
                        if(Acctm.TeamMemberRole == 'CLIENT_TSR' || Acctm.TeamMemberRole == 'CLIENT_OSS'){
                            for(Deal_Product__c dealProduct : dealProductsList){
                                if(CSG_BU_CATEGORIES.contains(dealProduct.FBE_Product__r.FBE_BU_Category__c)){
                                    Toaddress.add(Acctm.user.email);
                                }
                            }
                        }
                        if ( Acctm.TeamMemberRole == 'SVC_APOS_SR' && dealIdWithAposProducts.containsKey(dealId) && dealIdWithAposProducts.get(dealId).Size()>0){
                            Toaddress.add(Acctm.user.email);
                        }						
                    }
                }
            }
            //Disti in Cc
            if(DistiTeamwithaccteams.containsKey(dealId)){
                for (List <AccountTeamMember> lst_AccTm : DistiTeamwithaccteams.values())
                {
                    for (AccountTeamMember Acctm : lst_AccTm)
                    {                 
                        if(Acctm.TeamMemberRole == 'AE' || Acctm.TeamMemberRole == 'SR'){
                            system.debug('Acctm.TeamMemberRole_Cc#####'+Acctm.TeamMemberRole);
                            Toaddress.add(Acctm.user.email);
                        }
                        
                    }
                }
            }
            // VAR/Reseller in Cc
            if(VARTeamwithaccteams.containsKey(dealId)){
                for (List <AccountTeamMember> lst_AccTm : VARTeamwithaccteams.values())
                {
                    for (AccountTeamMember Acctm : lst_AccTm)
                    {                 
                        if(Acctm.TeamMemberRole == 'AE' || Acctm.TeamMemberRole == 'SR'){
                            Toaddress.add(Acctm.user.email);
                        }
                        
                    }
                }
            }
            String fo = dealObj.FBE_Analyst_Observations_History__c;
            if(String.isNotBlank(fo) && String.isNotEmpty(fo)){
                templ.Markup = templ.Markup.replace('Registration reviewer observations:', '<b>Registration reviewer observations</b>: ');
                // Defect #10441994
                templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Analyst_Observations_History__c}', dealObj.FBE_Analyst_Observations_History__c);
            }else{
                templ.Markup = templ.Markup.replace('<b>Registration reviewer observations</b>:', '');
                // Defect #10441994
                templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Analyst_Observations_History__c}', '');
            }
            
            templ.Markup = templ.Markup.replace('A Deal has been submitted for your approval', 'The following registration associated to one of your accounts has been submitted for approval to the core sales team');    
            templ.Markup = templ.Markup.replace('Please review the registration request within DFN SFDC and complete the action you would like the Deal Registration to take', ' ');    
            
            templ.Markup = templ.Markup.replace('within 24 hours.', '');
            system.debug('Template Markup #####'+templ.Markup);
            email.setToAddresses(Toaddress);
            //email.setCcAddresses(Ccaddress);
            email.setHtmlBody(templ.Markup);
            
            //If notified users is exists
            if(Toaddress.size()>0){ 
                mailList.add(email);
            }
        }
        if(FSITeamwithaccteams != null){
            // for FSI Team
            // defect #10580424  - added FBE_Deal_Createddate__c,FBE_Formatted_Book_Date__c fields in SOQL query
            
            set<id> fsiTeam = FSITeamwithaccteams.keySet();
            
            string dealquery1 = 'SELECT id,Name,FBE_Analyst_Observations_History__c,Analyst_Observations__c,FBE_Deal_Reg_Num__c,FBE_Opportunity_Number__c,CreatedDate,FBE_Submission_Date__c,'+
                'FBE_Forecast_Amount__c,FBE_Deal_Justification_Statement__c,FBE_Book_Date__c, FBE_End_User_Account_Name__c,FBE_End_User_First_Name__c,FBE_End_User_Last_Name__c,'+
                'FBE_End_User_Mailing_Street__c,FBE_End_User_Mailing_City__c,FBE_End_User_Mailing_State__c, FBE_End_User_Mailing_Zip__c,FBE_End_User_Mailing_Country__c,'+
                'FBE_End_User_Email__c,FBE_End_User_Phone__c,FBE_Reseller_VAR_Account__r.Name, FBE_Distributor_Account__r.Name,FBE_FSI_Account__r.Name,FBE_Partner_Sales_Rep_Name__c,'+
                'FBE_Partner_Sales_Rep_Email__c, FBE_End_User_Account__r.Name,FBE_Deal_Createddate__c,FBE_Formatted_Book_Date__c,FBE_Formatted_Submission_Date__c,'+
                '(Select FBE_Product__r.Name,FBE_Quantity__c, FBE_Product__r.FBE_BU_Category__c from Deal_Products__r)'+
                'FROM Deal_Registration__c WHERE Id IN :fsiTeam';
            
            Map<Id,Deal_Registration__c> dealMap_FSI = new Map<Id, Deal_Registration__c>((List<Deal_Registration__c>)database.query(dealquery1));
            
            EmailTemplate fsitempl = [Select Id,Name,HtmlValue,Body,Markup from EmailTemplate where Name='FBE Deal Approval Notification Email' limit 1];
            
            for(Id dealId : dealMap_FSI.keySet()){  
                FBE_ApprovalEmailHandler.getEmailTemplate (dealMap_FSI.get(dealId),fsitempl);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setOrgWideEmailAddressId(owea.Id);
                Deal_Registration__c dealObj = dealMap_FSI.get(dealId);
                List<Deal_Product__c> dealProductsList = dealObj.Deal_Products__r;
                String subject = FBE_ApprovalEmailHandler.getEmailSubject(dealObj, 'NOTIFICATION OF TIME SENSITIVE APPROVAL REQUEST: ');
                email.setSubject(subject);
                //email.setToAddresses(msg.get(dealId));
                if(FSITeamwithaccteams.containsKey(dealId)){
                    for (List <AccountTeamMember> lst_AccTm : FSITeamwithaccteams.values()){
                        for (AccountTeamMember Acctm : lst_AccTm){                 
                            if(Acctm.TeamMemberRole == 'CLIENT_TSR' || Acctm.TeamMemberRole == 'CLIENT_OSS'){
                                for(Deal_Product__c dealProduct : dealProductsList){
                                    if(CSG_BU_CATEGORIES.contains(dealProduct.FBE_Product__r.FBE_BU_Category__c)){
                                        FSI_Toaddress.add(Acctm.user.email);
                                    }
                                }
                            }              
                        }
                    }
                }
                
                String fsi_analyst_Obsv = dealObj.FBE_Analyst_Observations_History__c;
                if(String.isNotBlank(fsi_analyst_Obsv) && String.isNotEmpty(fsi_analyst_Obsv)){
                    fsitempl.Markup = fsitempl.Markup.replace('Registration reviewer observations:', '<b>Registration reviewer observations</b>: ');
                    // Defect #10441994
                    fsitempl.Markup = fsitempl.Markup.replace('{!relatedTo.FBE_Analyst_Observations_History__c}', dealObj.FBE_Analyst_Observations_History__c);
                }else{
                    fsitempl.Markup = fsitempl.Markup.replace('<b>Registration reviewer observations</b>:', '');
                    // Defect #10441994
                    fsitempl.Markup = fsitempl.Markup.replace('{!relatedTo.FBE_Analyst_Observations_History__c}', '');
                }
                fsitempl.Markup = fsitempl.Markup.replace('A Deal has been submitted for your approval', 'The following registration associated to one of your accounts has been submitted for approval to the core sales team');   
                fsitempl.Markup = fsitempl.Markup.replace('Please review the registration request within DFN SFDC and complete the action you would like the Deal Registration to take', ' ');  
                fsitempl.Markup = fsitempl.Markup.replace('within 24 hours.', '');
                
                system.debug('Template Markup #####'+templ.Markup);
                email.setToAddresses(FSI_Toaddress);
                //email.setCcAddresses(FSI_Ccaddress);
                email.setHtmlBody(fsitempl.Markup);
                
                if(FSI_Toaddress.size()>0){
                    mailList.add(email);
                }
            }
        }
        if(mailList.size()>0){
            try{
                Messaging.sendEmail(mailList);
            }Catch(Exception e){
                System.debug(e);
            }
        }
    }
    /****************        
* @MethodName    : SendEmailMessages
* @Trigger       : FBE_ApproveDeals
* @Description   : This method is called from Trigger=FBE_ApproveDeals. In this method,is used to trigger emails to Nutanix,SonicWall and VMWare DL's 
* @CreatedBy     : DeLL Team
* @CreatedOn     : 12-13-2019 [Soumithri Rekha, Sai]
************/
    
    public static void SendEmailMessages(Map<id,List<String>> msg) {
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address =: System.label.FBE_Approval_OWD limit 1];
        set<id> msgList = msg.keySet();
        string sub = 'Submitted';
        string dealquery = 'SELECT id,Name,FBE_Analyst_Observations_History__c,Analyst_Observations__c,FBE_Deal_Reg_Num__c,FBE_Opportunity_Number__c,CreatedDate,FBE_Submission_Date__c,FBE_Forecast_Amount__c,FBE_Deal_Justification_Statement__c,FBE_Book_Date__c, FBE_End_User_Account_Name__c,FBE_End_User_First_Name__c,FBE_End_User_Last_Name__c,FBE_End_User_Mailing_Street__c,FBE_End_User_Mailing_City__c,FBE_End_User_Mailing_State__c, FBE_End_User_Mailing_Zip__c,FBE_End_User_Mailing_Country__c,'+
            'FBE_End_User_Email__c,FBE_End_User_Phone__c,FBE_Reseller_VAR_Account__r.Name, FBE_Distributor_Account__r.Name,FBE_FSI_Account__r.Name,FBE_Partner_Sales_Rep_Name__c,'+
            'FBE_Partner_Sales_Rep_Email__c, FBE_End_User_Account__r.Name,FBE_Deal_Createddate__c,FBE_Formatted_Book_Date__c,FBE_Formatted_Submission_Date__c,'+
            '(Select FBE_Product__r.Name,FBE_Quantity__c,FBE_Product__r.FBE_BU_Category__c from Deal_Products__r),(Select Name,FBE_Sequence_Number__c,CreatedDate,FBE_Extension_Request_Reason__c from Deal_Extensions__r where FBE_Extension_Request_Status__c =: sub)'+
            'FROM Deal_Registration__c WHERE Id IN :msgList';
        
        Map<Id,Deal_Registration__c> dealMap = new Map<Id, Deal_Registration__c>((List<Deal_Registration__c>)database.query(dealquery));
        
        List<Messaging.SingleEmailMessage> femailList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate templ = [Select Id,Name,HtmlValue,Body,Markup from EmailTemplate where Name='FBE Deal Approval Email EXT'];
        for(Id dealId : dealMap.keySet()){  
            FBE_ApprovalEmailHandler.getEmailTemplate (dealMap.get(dealId),templ);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setOrgWideEmailAddressId(owea.Id);
            Deal_Registration__c dealObj = dealMap.get(dealId);
            String subject = FBE_ApprovalEmailHandler.getEmailSubject(dealObj, 'TIME SENSITIVE APPROVAL REQUEST: ');
            email.setSubject(subject);
            email.setToAddresses(msg.get(dealId));
            email.setHtmlBody(templ.Markup);
            femailList.add(email);
        }
        if( femailList !=NULL && femailList.size()>0){
            try{
                Messaging.sendEmail(femailList);
            }Catch(Exception e){
                System.debug(e);
            }
        }
    }
    /****************        
* @MethodName    : callPSPPMOApproval
* @Trigger       : FBE_ApproveDeals
* @Description   : This method is called from Trigger=FBE_ApproveDeals. In this method,is to call PSP PMO Approval Process
* @CreatedBy     : DeLL Team
* @CreatedOn    : callPSPPMOApproval
************/ 
    public static void callPSPPMOApproval(Set<id> dealIds){
        Group pmoQueue = [select Id,name from Group where  Type = 'Queue' AND name = 'PSPPMOTeamQueue' limit 1];
        Id senderId = [SELECT id from user where email =:System.label.FBE_Approval_OWD Limit 1].Id;
        for(Id SeconddealIds : dealIds){
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setSubmitterId(senderId);
            req1.setObjectId(SeconddealIds);
            req1.setNextApproverIds(new ID[] {pmoQueue.Id});
            req1.setProcessDefinitionNameOrId('FBE_ApprovalFor_PSPPMOTeam');
            req1.setSkipEntryCriteria(true);
            system.debug('Request:'+ req1 );
            try{
                Approval.ProcessResult result = Approval.process(req1); // approval is kicked off
                system.debug('Approval Result:'+ result );
            }Catch(Exception e){
                System.debug(e);
            }
        }
    } 
    
    
    public void updateApproveDeclineComments(List<Deal_Registration__c> newList, Map<Id, Deal_Registration__c> oldMap){ 
        List<Deal_Registration__c> updList = new List<Deal_Registration__c>();
        List<Deal_Registration__c> dealstobeUpdated = new List<Deal_Registration__c>();
        set<id> pendingdeals = new set<id>();
        List<ProcessInstance> inProcess = [SELECT TargetObjectId FROM ProcessInstance WHERE TargetObjectId in: newList AND  Status='Pending'];
        
        
        for(ProcessInstance p : inProcess){
            pendingdeals.add(p.TargetObjectId);
        }
        
        for(Deal_Registration__c deal : newList){
            // Story - 9036777 - start
            if(deal.Analyst_Observations__c != oldMap.get(deal.Id).Analyst_Observations__c && deal.FBE_Analyst_Observations_History__c == oldMap.get(deal.Id).FBE_Analyst_Observations_History__c){
                System.debug('1');
                if(deal.Analyst_Observations__c != null && deal.Analyst_Observations__c != ''){
                    deal.FBE_Analyst_Observations_History__c = deal.Analyst_Observations__c + ';' + deal.FBE_Analyst_Observations_History__c ;
                }
            }
            
            if(deal.FBE_Deal_Registration_Status__c == 'Submitted' && deal.FBE_Secondary_Status__c == null && deal.FBE_PMO_Substatus__c == 'Under Review')
            {
                System.debug('2');
                if(deal.FBE_Analyst_Observations_History__c != null && deal.FBE_Analyst_Observations_History__c != '' && deal.FBE_Analyst_Observations_History__c != oldMap.get(deal.Id).FBE_Analyst_Observations_History__c){
                    System.debug('3');
                    deal.Analyst_Observations__c = deal.FBE_Analyst_Observations_History__c;
                }
                if(deal.FBE_Analyst_Observations_History__c != null){
                    System.debug('4');
                    if(oldMap.get(deal.Id).FBE_Analyst_Observations_History__c != null && deal.FBE_Analyst_Observations_History__c != oldMap.get(deal.Id).FBE_Analyst_Observations_History__c){
                        System.debug('5');
                        deal.FBE_Analyst_Observations_History__c = deal.FBE_Analyst_Observations_History__c + ';' + oldMap.get(deal.Id).FBE_Analyst_Observations_History__c; // 
                    }
                    if(oldMap.get(deal.Id).FBE_Analyst_Observations_History__c == null){
                        System.debug('6');
                        deal.FBE_Analyst_Observations_History__c = deal.FBE_Analyst_Observations_History__c;
                    }
                }
                
                if(deal.FBE_Analyst_Observations_History__c == null && oldMap.get(deal.Id).FBE_Analyst_Observations_History__c != null){
                    deal.FBE_Analyst_Observations_History__c = oldMap.get(deal.Id).FBE_Analyst_Observations_History__c ;
                }
            }
            // Story - 9036777 - END
            if(deal.FBE_Deal_Registration_Status__c == 'Submitted' && (oldMap.get(deal.ID).FBE_Deal_Registration_Status__c != 'Submitted')){
                deal.FBE_PMO_Substatus__c = 'Sales Review'; 
                deal.FBE_Secondary_Status__c = '';
                deal.FBE_Approved_Declined_Date__c = NULL;
                deal.FBEApprovalReminderUsers__c = ''; // Stroy-9488223
            }
            if((deal.FBE_PMO_Substatus__c == 'PMO Approved' && oldMap.get(deal.Id).FBE_PMO_Substatus__c != 'PMO Approved') 
               || (deal.FBE_PMO_Substatus__c == 'PMO Rejected' && oldMap.get(deal.Id).FBE_PMO_Substatus__c != 'PMO Rejected')){
                   System.debug('inside update comments');
                   updList.add(deal);
               }
            if((deal.FBE_Distributor_Account__c != null && deal.FBE_FSI_Account__c == null ) ||
               (deal.FBE_Reseller_VAR_Account__c != null && deal.FBE_Distributor_Account__c == null && deal.FBE_FSI_Account__c == null) ||
               (deal.FBE_Distributor_Account__c != null && deal.FBE_FSI_Account__c != null ) ||
               (deal.FBE_Reseller_VAR_Account__c != null && deal.FBE_Distributor_Account__c == null && deal.FBE_FSI_Account__c != null)
              ){
                  system.debug('do nothing');       
              }
            else if(deal.FBE_Deal_Registration_Status__c == 'Submitted' && oldMap.get(deal.ID).FBE_PMO_Substatus__c == 'Sales Review' && deal.FBE_PMO_Substatus__c == 'Under Review' && !pendingdeals.contains(deal.ID)){
                System.debug('inside sales review comments');
                deal.FBE_PMO_Substatus__c = 'Sales Review'; 
                deal.FBE_ApprovalFlowCheck__c = False;
            }
            
            
        }
        if(updList.size() > 0){
            for(ProcessInstance pi : [Select TargetObjectId, CreatedDate ,Status, (Select StepStatus,TargetObjectId,Actor.name,OriginalActor.name,comments,
                                                                                   ProcessInstanceId,CreatedDate FROM StepsAndWorkitems where
                                                                                   OriginalActor.Name LIKE '%PSPPMO%' AND (stepstatus = 'Approved' OR stepstatus = 'Rejected') ORDER BY createdDate DESC limit 1 )
                                      FROM ProcessInstance WHERE TargetObjectId = : updList[0].id order by createdDate desc limit 1])
            {                
                if(pi.StepsAndWorkitems[0].StepStatus == 'Approved' ){
                    System.debug('inside approved comments');
                    if(updList[0].FBE_Funding_Source__c == null || updList[0].FBE_Book_Date__c == null || updList[0].Sales_Stage__c == null || updList[0].FBE_Solution_Domain__c == null || updList[0].FBE_Book_Date__c < System.today()){
                        updList[0].addError('Operation Cancelled: Book Date in future, Sales Stage, Funding source, Solution domain is mandatory for Approval!');
                    }
                    if(pi.StepsAndWorkitems[0].comments != null){
                        if(updList[0].FBE_Secondary_Status__c == null ){
                            updList[0].FBE_Secondary_Status__c = 'PSP PMO Approved';
                        }
                        updList[0].FBE_Decline_Comments__c = pi.StepsAndWorkitems[0].comments;
                        updList[0].FBE_Deal_Registration_Status__c ='Approved';
                        
                    }else
                        updList[0].addError('Operation Cancelled: Please provide a Approval Comments!');
    
                    
                }
                if(pi.StepsAndWorkitems[0].StepStatus == 'Rejected' ){
                    System.debug('inside reject comments');
                    if(pi.StepsAndWorkitems[0].comments != null){
                        if(updList[0].FBE_Secondary_Status__c == null ){
                            updList[0].FBE_Secondary_Status__c = 'PSP PMO Rejected';
                        }
                        updList[0].FBE_Decline_Comments__c = pi.StepsAndWorkitems[0].comments;
                        updList[0].FBE_Deal_Registration_Status__c ='Rejected';
                        updList[0].FBE_Declined_Reason__c = 'Reject - Other';
                        system.debug('updList'+updList[0]);
                    }else{
                        updList[0].addError('Operation Cancelled: Please provide a Rejection Comments!');
                     
                    }
                    
                }
            }
        }
        
    }
    
    public static Map<Id,List<Id>> getDealWithActTeamMembers(Map<Id,List<Id>> dealWithActIds){
        //---   BDD2 -- start --
        List<Id> varDistiAcntIds = new List<Id>();
        for(List<Id> actIds : dealWithActIds.values()){
            varDistiAcntIds.addAll(actIds);
        }
        Map<Id, List<Id>> accountWithVARDistiAccountMembers = new Map<Id,List<Id>>();
        for(AccountTeamMember atm : [Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole from AccountTeamMember where TeamMemberRole IN ('AE','SR') AND
                                     AccountId IN : varDistiAcntIds]){
                                         if(!accountWithVARDistiAccountMembers.containskey(atm.AccountId)){
                                             accountWithVARDistiAccountMembers.put(atm.AccountId, new List<Id>{atm.UserId});
                                         }else{
                                             accountWithVARDistiAccountMembers.get(atm.AccountId).add(atm.UserId);
                                         }
                                     }
        
        Map<Id,List<String>> dealIdWithVARDistiAccountMembers = new Map<Id,List<String>>();
        List<String> uIds;
        for(Id dealId : dealWithActIds.keySet()){
            uIds = new List<String>();
            for(Id actId : dealWithActIds.get(dealId)){
                if(accountWithVARDistiAccountMembers.containsKey(actId)){
                    uIds.addAll(accountWithVARDistiAccountMembers.get(actId));
                }
            }
            dealIdWithVARDistiAccountMembers.put(dealId, uIds);
        }
        System.debug('dealIdWithVARDistiAccountMembers:  '+dealIdWithVARDistiAccountMembers);
        return dealIdWithVARDistiAccountMembers;
        //-- BDD2 --- end ---
    }
    
    public void checkDealthresholdAmount(List<Deal_Registration__c> newList, Map<Id, Deal_Registration__c> oldMap){ 
        String minThreshold = System.Label.FBE_FPRM_DealReg_Minimum_Threshold_Amount;
        List<String> prmProfiles = System.Label.FBE_FPRM_Profiles.split(';');
        String userProfile=[Select Id,Name from Profile where Id=:UserInfo.getProfileId()].Name;
        for(Deal_Registration__c newdeal : newList){
            if(newdeal.FBE_Deal_Registration_Status__c == 'Submitted' && oldMap.get(newdeal.Id).FBE_Deal_Registration_Status__c != 'Submitted' && 
               newdeal.FBE_Forecast_Amount__c < decimal.valueOf(minThreshold.replaceAll(',', '')) && prmProfiles.contains(userProfile)){
                   newdeal.addError('Expected revenue of the deal is below the $'+minThreshold+' threshold for deal registration submission. Please update the deal to continue.');
               }
        }
    }
    
    
    /**************
* @MethodName    : UpdateCreated_Submissiondate
* @Trigger       : FBE_DealRegTrigger
* @Description   : This method is called by the above trigger. In this method, update the Submission/Created date into customfield with 
required formatte used in Notification/Reminders template. 
* @CreatedBy     : Siva Kumar Valluru

***************/ 
    
    public void UpdateCreated_Submissiondate(List<Deal_Registration__c> newdeallst, map<id,Deal_Registration__c> mapdeal){
        
        String formatted_submission_date,formatted_createddate; 
        List<Deal_Registration__c> deallst = new list<Deal_Registration__c>();
        
        for(Deal_Registration__c deal : newdeallst){
            
            if((deal.id != null && deal.FBE_Submission_Date__c != null && String.isBlank(deal.FBE_Formatted_Submission_Date__c)) || (deal.FBE_Submission_Date__c != mapdeal.get(deal.id).FBE_Submission_Date__c) ){
                formatted_submission_date = '' ;
                formatted_submission_date = FBE_ApprovalEmailHandler.getformattedDatetime(deal.FBE_Submission_Date__c);
                if(String.isNotBlank(formatted_submission_date)){
                    deal.FBE_Formatted_Submission_Date__c = formatted_submission_date;
                    deallst.add(deal);
                }
                
            }
            if(deal.id != null && deal.FBE_Submission_Date__c != null && String.isBlank(deal.FBE_Deal_Createddate__c)){
                formatted_createddate = '';
                formatted_createddate = FBE_ApprovalEmailHandler.getformattedDatetime(deal.createdDate);
                if(String.isNotBlank(formatted_createddate)){
                    deal.FBE_Deal_Createddate__c = formatted_createddate;
                    deallst.add(deal);
                }
            }
            
        }
        
    } 
    
    
}