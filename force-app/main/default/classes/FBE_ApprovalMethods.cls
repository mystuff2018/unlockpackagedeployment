/**
* @description       : FBE_ApprovalMethods is common class for Deal Extension And Deal Registration Approval Process called from FBE_DealExtnApprl class
* @author            : Soumithri Rekha v
* @group             : DeLL Team
* @last modified on  : 01-26-2022
* @last modified by  : 
**/
public without sharing class FBE_ApprovalMethods {
    
    private final static Set<String> CSG_BU_CATEGORIES = new Set<String>{'CSG Hardware', 'CSG Other'};
        public static String[] filters = new String[]{'%APOS%','%Nutanix%','%XC Series%', '%Service%','%SonicWALL%', '%VMWare%', '%Maintenance%', '%Warranty Extension%', '%Warranty%', '%Entitlement%', '%Renewal%'};   
            /**************
* @MethodName    : callEUApproval
* @Trigger       : = FBE_DealExtnApprl
* @Description   : This method is called from class== FBE_DealExtnApprl. In this method,we invoke Approval Process =Test 
* @CreatedBy     : DeLL Team
* @CreatedOn     : 01-26-2022 [Soumithri Rekha]
***************/  
            public static void callEUApproval(Set<Id> dealIds, Map<id,String> includeExn,Map<id,id> includeExnid) {
                Map<Id, List<String>> dealIdWithAposProducts = new Map<Id,List<String>>();
                Map<Id, List<String>> dealIdWithNutanixProducts = new Map<Id,List<String>>();
                Map<Id, List<String>> dealIdWithSonicProducts = new Map<Id,List<String>>();
                Map<Id, List<String>> dealIdWithVmwareProducts = new Map<Id,List<String>>();
                Map<Id,Id> dealIdWithAccount = new Map<Id,Id>();
                Map<Id,List<Id>> dealIdWithVARDistAccount = new Map<Id,List<Id>>();// BDD2
                Map<Id,String> dealregQueue = new Map<Id,String>();
                String[] aesr = new String[]{'AE','SR'};
                    Map<Id, List<AccountTeamMember>> EU_Accteammembers = new Map<Id,List<AccountTeamMember>>();
                Map<Id,List<AccountTeamMember>> dealIdWithEUTeammembers = new Map<Id,List<AccountTeamMember>>();
                Map<Id, List<AccountTeamMember>> Disti_Accteammembers = new Map<Id,List<AccountTeamMember>>();
                Map<Id,Id> dealIdWithDistiAccount = new Map<Id,Id>();
                Map<Id,List<AccountTeamMember>> dealIdWithDistiTeammembers = new Map<Id,List<AccountTeamMember>>();
                Map<Id, List<AccountTeamMember>> VAR_Accteammembers = new Map<Id,List<AccountTeamMember>>();
                Map<Id,Id> dealIdWithVARAccount = new Map<Id,Id>();
                Map<Id,List<AccountTeamMember>> dealIdWithVARTeammembers = new Map<Id,List<AccountTeamMember>>();
                MaP<Id, List<Deal_Product__c>> dealProductsMap = new  MaP<Id, List<Deal_Product__c>>();
                string dealquery = 'Select id, FBE_Deal_Registration_Status__c,FBE_Deal_Reg__c,FBE_End_User_Account__c,FBE_Distributor_Account__c,FBE_Reseller_VAR_Account__c,';
                string prodquery = '(Select id,FBE_Product__r.Name,FBE_Product__r.FBE_BU_Category__c from Deal_Products__r where FBE_Product__r.Name Like: filters OR FBE_Product__r.FBE_BU_Category__c in :CSG_BU_CATEGORIES) from Deal_Registration__c where id in:dealIds';
                string queryt =dealquery+prodquery;
                for(Deal_Registration__c deal : database.query(queryt)){
                    system.debug('Inside For:'+deal);
                    List<Deal_Product__c> dealProductsList = deal.Deal_Products__r;
                    if(!dealProductsMap.containsKey(deal.id)){
                        dealProductsMap.put(deal.id, dealProductsList);
                    }
                    
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
                AccTeamRoles = AccTeamRoles;
                List<String> Notify_AccTeamRoles = AccTeamRoles.split(';');
                List<id> dealIdWithAccountvalue = dealIdWithAccount.values();
                string accountQuerys = 'Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole,user.email from AccountTeamMembers where TeamMemberRole IN : Notify_AccTeamRoles ) from Account where Id in:dealIdWithAccountvalue';
                for(Account a : database.query(accountQuerys)){
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
                    
                    System.debug('#Allia ResellerVarAccount'+database.query(accountquery2));
                    System.debug('#Allia ResellerVarAccount'+a.AccountTeamMembers);
                    VAR_Accteammembers.put(a.Id, a.AccountTeamMembers);
                }
                
                for(Id i : dealIdWithVARAccount.keySet()){
                    if(dealIdWithVARAccount.get(i) != NULL && VAR_Accteammembers.containsKey(dealIdWithVARAccount.get(i))){
                        if(VAR_Accteammembers.get(dealIdWithVARAccount.get(i)) != NULL){
                            dealIdWithVARTeammembers.put(i, VAR_Accteammembers.get(dealIdWithVARAccount.get(i)));
                        }   
                    }
                }
                
                
                
                system.debug('dealIdWithAccount:'+dealIdWithAccount);
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
                system.debug('dealIdWithNutanixProducts:'+dealIdWithNutanixProducts);
                string aposquery = 'Select id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like: Aposfilters and Deal_Registration_Name__c in : dealregQueueKeyset';
                List<Deal_Product__c> AposMap = database.query(aposquery);
                for(Deal_Product__c dealp : AposMap){
                    if(!dealIdWithAposProducts.containsKey(dealp.Deal_Registration_Name__c)){
                        dealIdWithAposProducts.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
                    }else
                        dealIdWithAposProducts.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
                }
                system.debug('dealIdWithAposProducts:'+dealIdWithAposProducts);
                string sonicquery = 'Select id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like:Sonicfilters and Deal_Registration_Name__c in : dealregQueueKeyset';
                List<Deal_Product__c> SonicMap = database.query(sonicquery);
                for(Deal_Product__c dealp : SonicMap){
                    if(!dealIdWithSonicProducts.containsKey(dealp.Deal_Registration_Name__c)){
                        dealIdWithSonicProducts.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
                    }else
                        dealIdWithSonicProducts.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
                }
                system.debug('dealIdWithSonicProducts:'+dealIdWithSonicProducts);
                string vmquery = 'Select id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like:Vmfilters and Deal_Registration_Name__c in : dealregQueueKeyset';
                List<Deal_Product__c> VmMap = database.query(vmquery);
                for(Deal_Product__c dealp : VmMap){
                    if(!dealIdWithVmwareProducts.containsKey(dealp.Deal_Registration_Name__c)){
                        dealIdWithVmwareProducts.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
                    }else
                        dealIdWithVmwareProducts.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
                }
                system.debug('dealIdWithVmwareProducts:'+dealIdWithVmwareProducts);
                List<String> AccountTeamRoles = System.Label.ApprovalRoles.split(';');
                List<id> dealIdWithAccountvalues = dealIdWithAccount.values();
                System.debug('#Allia inside no roles check'+dealIdWithAccount.values());
                Map<Id, List<AccountTeamMember>> accountWithAccountMembers = new Map<Id,List<AccountTeamMember>>();
                string queryaccount3 = 'Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole from AccountTeamMembers where TeamMemberRole IN : AccountTeamRoles) from Account where Id IN:dealIdWithAccountvalues';
                for(Account a : database.query(queryaccount3)){
                    accountWithAccountMembers.put(a.Id, a.AccountTeamMembers);//AE;SR;DC_SS;ACCT_SE;TSR;SVC_APOS_SR
                }
                system.debug('accountWithAccountMembers:'+accountWithAccountMembers);
                Map<Id,List<AccountTeamMember>> dealIdWithAccountTeam = new Map<Id,List<AccountTeamMember>>();
                Set<Id> dealIdsWithNoEligibleRoles = new Set<Id>();
                for(Id i : dealIdWithAccount.keySet()){
                    if(dealIdWithAccount.get(i) != NULL && accountWithAccountMembers.containsKey(dealIdWithAccount.get(i))){
                        if(accountWithAccountMembers.get(dealIdWithAccount.get(i)) != NULL){
                            dealIdWithAccountTeam.put(i, accountWithAccountMembers.get(dealIdWithAccount.get(i)));
                        }
                        
                        System.debug('#Allia check check'+accountWithAccountMembers.get(dealIdWithAccount.get(i)));
                        if(accountWithAccountMembers.get(dealIdWithAccount.get(i)) == NULL || accountWithAccountMembers.get(dealIdWithAccount.get(i)).size() == 0 ){
                            System.debug('inside no roles check');
                            dealIdsWithNoEligibleRoles.add(i);
                        }
                    }
                }
                //Map<List<Id>,boolean> dealIdwithisDirectPMO = new Map<List<Id>,boolean>();
                System.debug('dealIdsWithNoEligibleRoles: '+dealIdsWithNoEligibleRoles);
                system.debug('dealIdWithAccountTeam:'+dealIdWithAccountTeam);
                
                
                Map<Id,List<String>> dealIdWithVARDistiAccountMembers = new Map<Id,List<String>>();
                dealIdWithVARDistiAccountMembers = getDealWithActTeamMembers(dealIdWithVARDistAccount);
                System.debug('dealIdWithVARDistiAccountMembers:  '+dealIdWithVARDistiAccountMembers);
                
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
                                    dealIdAposAccountTeamUserID.put(dealId, new List<String>{atm.UserId});
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
                Map<id,List<id>> dealIdEUAccountTeamNotUserID = new Map<id,list<id>>();
                List<id> NotificationUsers = new List<id>();
                if(dealIdWithEUTeammembers != null){
                    for(Id dealId : dealIdWithEUTeammembers.keySet()){
                        for(AccountTeamMember atm : dealIdWithEUTeammembers.get(dealId)){
                            if(!roles.contains(atm.TeamMemberRole)){
                                for(Deal_Product__c dealProduct : dealProductsMap.get(dealId)){
                                    if(atm.TeamMemberRole != 'SVC_APOS_SR'){
                                        if(CSG_BU_CATEGORIES.contains(dealProduct.FBE_Product__r.FBE_BU_Category__c)){
                                            system.debug('EU Notification Team');
                                            NotificationUsers.add(atm.UserId);
                                        }
                                    }
                                    if ( atm.TeamMemberRole == 'SVC_APOS_SR' && dealIdWithAposProducts.containsKey(dealId) && dealIdWithAposProducts.get(dealId).Size()>0){
                                        NotificationUsers.add(atm.UserId);
                                    }
                                }
                            }
                        }
                        if(!dealIdWithDistiTeammembers.isEmpty() && dealIdWithDistiTeammembers.containsKey(dealId)){
                            for(AccountTeamMember atm : dealIdWithDistiTeammembers.get(dealID)){
                                system.debug('Disty Notification Team');
                                NotificationUsers.add(atm.UserId);
                            }
                        }
                        if(!dealIdWithVARTeammembers.isEmpty() && dealIdWithVARTeammembers.containsKey(dealId)){
                            for(AccountTeamMember atm : dealIdWithVARTeammembers.get(dealID)){
                                NotificationUsers.add(atm.UserId);
                            }
                        }
                        
                        if(!dealIdEUAccountTeamNotUserID.containsKey(dealId)){
                            dealIdEUAccountTeamNotUserID.put(dealId, NotificationUsers);
                        }
                    }
                    SendEmailMessages(dealIdEUAccountTeamNotUserID,includeExn);
                    //romove comments -SendEmailMessages_EUFSI(dealIdWithEUTeammembers,dealIdWithDistiTeammembers,dealIdWithVARTeammembers,null,dealIdWithAposProducts);
                    
                }
                
                
                if(!dealIdEUAccountTeamNotUserID.isEmpty() && includeExn == null && includeExnid == null){
                    system.debug('Notification EU Team #####'+dealIdEUAccountTeamNotUserID);
                    SendEmailMessages(dealIdEUAccountTeamNotUserID,includeExn);  
                }
                System.debug('#Allia vmware'+dealIdVmwaresonicWallNutanixAccountTeamUserID);
                if(!dealIdVmwaresonicWallNutanixAccountTeamUserID.isEmpty() && includeExn == null && includeExnid == null){
                    system.debug('SonicWall#####'+dealIdVmwaresonicWallNutanixAccountTeamUserID);
                    SendEmailMessages(dealIdVmwaresonicWallNutanixAccountTeamUserID,includeExn);  
                }
                
                
                if(!dealIdWithVARDistiAccountMembers.isEmpty()){
                    system.debug('VARDistiAccountMembers#####'+dealIdWithVARDistiAccountMembers);
                    //SendEmailMessages(dealIdWithVARDistiAccountMembers);   // bdd2
                }
                
                if(!dealIdAposAccountTeamUserID.isEmpty()){
                    system.debug('AposAccount#####'+dealIdAposAccountTeamUserID);
                    // SendEmailMessages(dealIdAposAccountTeamUserID); // bdd3
                }
                
                if(dealIdsWithNoEligibleRoles.size()>0){
                    //dealIdwithisDirectPMO.put(new List<Id>{ dealIdsWithNoEligibleRoles }, true);
                    //isDirectPMO = true;
                    System.debug('Inside dealIdsWithNoEligibleRoles ');
                    callPSPPMOApproval(dealIdsWithNoEligibleRoles,includeExn,includeExnid);
                }else{
                    for(Id dealId : dealregQueue.keySet()){
                        if(dealregQueue.containsKey(dealId)){
                            if(includeExn == null && includeExnid == null){
                                System.enqueueJob(new FBE_CreateGroupForApproval(dealId,dealIdEUAccountTeamUserID.get(dealId),null,dealIdAposAccountTeamUserID.get(dealId),
                                                                                 dealregQueue.get(dealId), dealIdwithAEId.get(dealId),dealIdWithVARDistiAccountMembers.get(dealId)));  
                            }
                            else{
                                System.enqueueJob(new FBE_CreateGroupForApproval(includeExnid.get(dealId),dealIdEUAccountTeamUserID.get(dealId),null,dealIdAposAccountTeamUserID.get(dealId),
                                                                                 includeExn.get(dealId), dealIdwithAEId.get(dealId),dealIdWithVARDistiAccountMembers.get(dealId)));
                                system.debug('Inside Extension');
                            }}
                    }
                }
            }
    /************    
* @MethodName    : callEUAndFSIApproval
* @Trigger       : = FBE_DealExtnApprl
* @Description   : This method is called from class== FBE_DealExtnApprl. In this method,we invoke Approval Process =TestApproval1 
* @CreatedBy     : DeLL Team
* @CreatedOn     : 01-26-2022 [Soumithri Rekha]
* @Modified 	 : Added Sell-IN/Sell-out Check for FSI Apporvals [Story# 9515291]
*********************/
    public static void callEUAndFSIApproval(Set<id> dealIds, Map<id,string> includeExn, Map<id,id> includeExnid) {
        Map<Id, List<String>> dealIdWithAposProducts = new Map<Id,List<String>>();
        Map<Id, List<String>> dealIdWithNutanixProducts = new Map<Id,List<String>>();
        Map<Id, List<String>> dealIdWithSonicProducts = new Map<Id,List<String>>();
        Map<Id, List<String>> dealIdWithVmwareProducts = new Map<Id,List<String>>();
        Map<Id,List<Id>> dealIdWithVARDistAccount = new Map<Id,List<Id>>();// BDD2
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
        Map<id,List<Deal_Product__c>> dealProductsMap = new Map<id,List<Deal_Product__c>>();
        string dealquery = 'Select id, FBE_Deal_Registration_Status__c,FBE_Deal_Reg__c,FBE_FSI_Account__c,FBE_FSI_Internal_Use__c,FBE_Distributor_Account__c,FBE_Reseller_VAR_Account__c,FBE_End_User_Account__c,(Select id,FBE_Product__r.Name,FBE_Product__r.FBE_BU_Category__c from Deal_Products__r where FBE_Product__r.Name Like: filters OR FBE_Product__r.FBE_BU_Category__c in :CSG_BU_CATEGORIES) from Deal_Registration__c where id in:dealIds';
        for(Deal_Registration__c deal : database.query(dealquery)){
            system.debug('Inside For:'+deal);
            List<Deal_Product__c> dealProductsList = deal.Deal_Products__r;
                    if(!dealProductsMap.containsKey(deal.id)){
                        dealProductsMap.put(deal.id, dealProductsList);
                    }
            system.debug('dealProductsMap'+dealProductsMap);
                    
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
        AccTeamRoles = AccTeamRoles +';CLIENT_OSS';
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
        
        
        system.debug('dealIdWithAccount:'+dealIdWithAccount);
        String[] Nutanixfilters = new String[]{'Nutanix%','XC Series%'};
            String[] Aposfilters = new String[]{'%APOS%','%Service%',  '%Maintenance%', '%Warranty Extension%', '%Warranty%', '%Entitlement%', '%Renewal%'};
                String[] Sonicfilters = new String[]{'%SonicWALL%'};
                    String[] Vmfilters = new String[]{'%VMWare%'};
                        set<id> dealregQueueKeyset = dealregQueue.keyset();
        string nutanixqery ='Select id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like: Nutanixfilters and Deal_Registration_Name__c in : dealregQueueKeyset';
        List<Deal_Product__c> NutanixMap = database.query(nutanixqery);
        for(Deal_Product__c dealp : NutanixMap){
            if(!dealIdWithNutanixProducts.containsKey(dealp.Deal_Registration_Name__c)){
                dealIdWithNutanixProducts.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
            }else
                dealIdWithNutanixProducts.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
        }
        system.debug('dealIdWithNutanixProducts:'+dealIdWithNutanixProducts);
        string aposQuery = 'Select id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like: Aposfilters and Deal_Registration_Name__c in : dealregQueueKeyset';
        List<Deal_Product__c> AposMap = database.query(aposQuery);
        for(Deal_Product__c dealp : AposMap){
            if(!dealIdWithAposProducts.containsKey(dealp.Deal_Registration_Name__c)){
                dealIdWithAposProducts.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
            }else
                dealIdWithAposProducts.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
        }
        system.debug('dealIdWithAposProducts:'+dealIdWithAposProducts);
        string sonicquery = 'Select id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like:Sonicfilters and Deal_Registration_Name__c in : dealregQueueKeyset';
        List<Deal_Product__c> SonicMap = database.query(sonicquery);
        for(Deal_Product__c dealp : SonicMap){
            if(!dealIdWithSonicProducts.containsKey(dealp.Deal_Registration_Name__c)){
                dealIdWithSonicProducts.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
            }else
                dealIdWithSonicProducts.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
        }
        system.debug('dealIdWithSonicProducts:'+dealIdWithSonicProducts);
        string vmquery = 'Select id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like:Vmfilters and Deal_Registration_Name__c in : dealregQueueKeyset';
        List<Deal_Product__c> VmMap = database.query(vmquery);
        for(Deal_Product__c dealp : VmMap){
            if(!dealIdWithVmwareProducts.containsKey(dealp.Deal_Registration_Name__c)){
                dealIdWithVmwareProducts.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
            }else
                dealIdWithVmwareProducts.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
        } 
        system.debug('dealIdWithVmwareProducts:'+dealIdWithVmwareProducts);
        system.debug('dealAccountSet'+dealAccountSet);
        List<String> AccountTeamRoles = System.Label.ApprovalRoles.split(';');
        Map<Id, List<AccountTeamMember>> accountWithAccountMembers = new Map<Id,List<AccountTeamMember>>();
        string accountquery0 = 'Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole from AccountTeamMembers where TeamMemberRole IN : AccountTeamRoles ) from Account where Id in:dealAccountSet';
        for(Account a : database.query(accountquery0)){
            accountWithAccountMembers.put(a.Id, a.AccountTeamMembers);
        }
        system.debug('accountWithAccountMembers:'+accountWithAccountMembers);
        
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
            //logic for Deal with no eligible role
            //
            System.debug('#Allia Dealwithno EU'+accountWithAccountMembers.get(dealIdWithAccount.get(i)));
            System.debug('#Allia Dealwithno FSI'+accountWithAccountMembers.get(dealidwithFSIAccount.get(i)));
            if((accountWithAccountMembers.get(dealIdWithAccount.get(i)) == NULL && accountWithAccountMembers.get(dealidwithFSIAccount.get(i)) == Null) ||
               (accountWithAccountMembers.get(dealIdWithAccount.get(i)).size() == 0 && accountWithAccountMembers.containsKey(dealidwithFSIAccount.get(i)) && accountWithAccountMembers.get(dealidwithFSIAccount.get(i)).size() ==0)){
                   System.debug('2-inside no eligible roles');
                   dealIdsWithNoEligibleRoles.add(i);
               }
        }
        
        
        
        //------dealIdWithAccount---FBE End user account
        System.debug('2- dealIdsWithNoEligibleRoles: '+ dealIdsWithNoEligibleRoles);
        system.debug('dealIdWithAccountTeam:'+dealIdWithAccountTeam);
        
        Map<Id,List<String>> dealIdWithVARDistiAccountMembers = new Map<Id,List<String>>();
        dealIdWithVARDistiAccountMembers = getDealWithActTeamMembers(dealIdWithVARDistAccount);
        System.debug('dealIdWithVARDistiAccountMembers:  '+dealIdWithVARDistiAccountMembers);
        
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
        
        Map<id,List<id>> dealIdEUAccountTeamNotUserID = new Map<id,list<id>>();
                List<id> NotificationUsers = new List<id>();
                if(dealIdWithEUTeammembers != null && dealIdWithFSITeammembers != null){
                    for(Id dealId : dealIdWithEUTeammembers.keySet()){
                        for(AccountTeamMember atm : dealIdWithEUTeammembers.get(dealId)){
                            if(!roles.contains(atm.TeamMemberRole)){
                                for(Deal_Product__c dealProduct : dealProductsMap.get(dealId)){
                                    System.debug('#Allia CSG_BU_CATEGORIES for EU'+dealProduct.FBE_Product__r.FBE_BU_Category__c);
                                    if(atm.TeamMemberRole != 'SVC_APOS_SR'){
                                        if(CSG_BU_CATEGORIES.contains(dealProduct.FBE_Product__r.FBE_BU_Category__c)){
                                            system.debug(' Notification Team');
                                            NotificationUsers.add(atm.UserId);
                                        }
                                    }
                                    if ( atm.TeamMemberRole == 'SVC_APOS_SR' && dealIdWithAposProducts.containsKey(dealId) && dealIdWithAposProducts.get(dealId).Size()>0){
                                        NotificationUsers.add(atm.UserId);
                                    }
                                }
                            }
                        }
                        
                        for(AccountTeamMember atm : dealIdWithFSITeammembers.get(dealId)){
                            System.debug('#Allia atm TeamRole'+atm.TeamMemberRole);
                            if(!roles.contains(atm.TeamMemberRole)){
                                for(Deal_Product__c dealProduct : dealProductsMap.get(dealId)){
                                    System.debug('#Allia CSG_BU_CATEGORIES for FSI'+dealProduct.FBE_Product__r.FBE_BU_Category__c);
                                    if(atm.TeamMemberRole != 'SVC_APOS_SR'){
                                        if(CSG_BU_CATEGORIES.contains(dealProduct.FBE_Product__r.FBE_BU_Category__c)){
                                            system.debug('FSI Notification Team');
                                            NotificationUsers.add(atm.UserId);
                                        }
                                    }
                                    }
                            }
                        }
                        if(!dealIdWithDistiTeammembers.isEmpty() && dealIdWithDistiTeammembers.containsKey(dealId)){
                            for(AccountTeamMember atm : dealIdWithDistiTeammembers.get(dealID)){
                                NotificationUsers.add(atm.UserId);
                            }
                        }
                        if(!dealIdWithVARTeammembers.isEmpty() && dealIdWithVARTeammembers.containsKey(dealId)){
                            for(AccountTeamMember atm : dealIdWithVARTeammembers.get(dealID)){
                                NotificationUsers.add(atm.UserId);
                            }
                        }
                        
                        if(!dealIdEUAccountTeamNotUserID.containsKey(dealId)){
                            dealIdEUAccountTeamNotUserID.put(dealId, NotificationUsers);
                        }
                    }
                    SendEmailMessages(dealIdEUAccountTeamNotUserID,includeExn);
                    //romove comments -SendEmailMessages_EUFSI(dealIdWithEUTeammembers,dealIdWithDistiTeammembers,dealIdWithVARTeammembers,null,dealIdWithAposProducts);
                    
                }
        if(dealIdWithEUTeammembers != null || dealIdWithFSITeammembers != null){
            //romove comments-SendEmailMessages_EUFSI(dealIdWithEUTeammembers,dealIdWithDistiTeammembers,dealIdWithVARTeammembers,dealIdWithFSITeammembers,dealIdWithAposProducts);
        }
        if(!dealIdVmwaresonicWallNutanixAccountTeamUserID.isEmpty() && includeExn == null && includeExnid == null){
            system.debug('SonicWall#####EUFSI'+dealIdVmwaresonicWallNutanixAccountTeamUserID);
            //SendEmailMessages(dealIdVmwaresonicWallNutanixAccountTeamUserID);  --romove comments 
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
            callPSPPMOApproval(dealIdsWithNoEligibleRoles, includeExn,includeExnid);
        }
        else{
            
            for(Id dealId : dealregQueue.keySet()){
                if(dealregQueue.containsKey(dealId)){
                    if(includeExn == null && includeExnid == null){
                        System.enqueueJob(new FBE_CreateGroupForApproval(dealId,dealIdEUAccountTeamUserID.get(dealId),dealIdFSIAccountTeamUserID.get(dealId),dealIdAposAccountTeamUserID.get(dealId),
                                                                         dealregQueue.get(dealId), dealIdwithAEId.get(dealId),dealIdWithVARDistiAccountMembers.get(dealId)));
                    }
                    else{
                        System.enqueueJob(new FBE_CreateGroupForApproval(includeExnid.get(dealID),dealIdEUAccountTeamUserID.get(dealId),dealIdFSIAccountTeamUserID.get(dealId),dealIdAposAccountTeamUserID.get(dealId),
                                                                         includeExn.get(dealId), dealIdwithAEId.get(dealId),dealIdWithVARDistiAccountMembers.get(dealId)));
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
    
    
    /****************        
* @MethodName    : SendEmailMessages
* @Trigger       : = FBE_DealExtnApprl
* @Description   : This method is called from Trigger== FBE_DealExtnApprl. In this method,is used to trigger emails to Nutanix,SonicWall and VMWare DL's 
* @CreatedBy     : DeLL Team
* @CreatedOn     : 01-26-2022 [Soumithri Rekha]
************/
    
    public static void SendEmailMessages(Map<id,List<String>> msg,Map<id,string> includeExn) {
        System.debug('Deals with eligible Accs#####' + msg);
        // defect #10580424  - added FBE_Deal_Createddate__c,FBE_Formatted_Book_Date__c fields in SOQL query
        string applabel = System.label.FBE_Approval_OWD;
        string orgowd = 'select Id from OrgWideEmailAddress where Address =:applabel  limit 1';
        OrgWideEmailAddress owea = database.query(orgowd);
        set<id> msgList = msg.keySet();
        string sub = 'Submitted';
        string dealquery = 'SELECT id,Name,FBE_Analyst_Observations_History__c,Analyst_Observations__c,FBE_Deal_Reg_Num__c,FBE_Opportunity_Number__c,CreatedDate,FBE_Submission_Date__c,FBE_Forecast_Amount__c,FBE_Deal_Justification_Statement__c,FBE_Book_Date__c, FBE_End_User_Account_Name__c,FBE_End_User_First_Name__c,FBE_End_User_Last_Name__c,FBE_End_User_Mailing_Street__c,FBE_End_User_Mailing_City__c,FBE_End_User_Mailing_State__c, FBE_End_User_Mailing_Zip__c,FBE_End_User_Mailing_Country__c,'+
                                                                                  'FBE_End_User_Email__c,FBE_End_User_Phone__c,FBE_Reseller_VAR_Account__r.Name, FBE_Distributor_Account__r.Name,FBE_FSI_Account__r.Name,FBE_Partner_Sales_Rep_Name__c,'+
                                                                                  'FBE_Partner_Sales_Rep_Email__c, FBE_End_User_Account__r.Name,FBE_Deal_Createddate__c,FBE_Formatted_Book_Date__c,FBE_Formatted_Submission_Date__c,'+
                                                                                  '(Select FBE_Product__r.Name,FBE_Quantity__c,FBE_Product__r.FBE_BU_Category__c from Deal_Products__r),(Select Name,FBE_Sequence_Number__c,CreatedDate,FBE_Extension_Request_Reason__c from Deal_Extensions__r where FBE_Extension_Request_Status__c =: sub)'+
                                                                                  'FROM Deal_Registration__c WHERE Id IN :msgList';
        Map<Id,Deal_Registration__c> dealMap = new Map<Id, Deal_Registration__c>((List<Deal_Registration__c>)database.query(dealquery));
        
        List<Messaging.SingleEmailMessage> femailList = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> templ = [Select Id,Name,HtmlValue,Body,Markup from EmailTemplate where Name in ('FBE Deal Approval Email EXT','FBE Deal Ext Notify Email Template') order by Name];
        for(Id dealId : dealMap.keySet()){  
            Deal_Registration__c dealObj = dealMap.get(dealId);
        String subject;
            List<Deal_Extension__c> dexte = dealMap.get(dealId).Deal_Extensions__r;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if(includeExn == null){
                FBE_ApprovalEmailHandler.getEmailTemplate(dealMap.get(dealId),templ[0]);
            subject = FBE_ApprovalEmailHandler.getEmailSubject(dealObj, 'NOTIFICATION OF TIME SENSITIVE APPROVAL REQUEST:');
                email.setHtmlBody(templ[0].Markup);
            }
            else{
                EmailTemplate returntemp = FBE_ApprovalEmailHandler.getEmailTemplate(dealMap.get(dealId), templ[1]);
                subject = FBE_ApprovalEmailHandler.getEmailSubject(dealObj, 'NOTIFICATION OF TIME SENSITIVE EXTENSION REQUEST:');
        	returntemp = FBE_ApprovalEmailHandler.getDealExtEmailTemplate(dexte[0], returntemp);
                email.setHtmlBody(returntemp.Markup);
            }
            email.setOrgWideEmailAddressId(owea.Id);
            email.setSubject(subject);
            email.setToAddresses(msg.get(dealId));
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
* @MethodName    : ChangeStatus
* @Trigger       : = FBE_DealExtnApprl
* @Description   : This method is called from class== FBE_DealExtnApprl. In this method,is to change status to Approved 
* @CreatedBy     : DeLL Team
* @CreatedOn     : 01-26-2022 [Soumithri Rekha]
************/  
    public static void ChangeStatus(Set<Id> dealIds,string sObjName){
        // string objectIs = dealIds[0].getSObjectType().getDescribe().getName();
        system.debug('Inside Change Status'+dealIds);
        Map<Id, List<String>> ProccesSstatus = new Map<Id, List<String>>();
        string pend = 'Pending';
        string ppQuery = 'SELECT TargetObjectId, Status, CreatedDate FROM ProcessInstance WHERE TargetObjectId in: dealIds AND  Status=:pend';
        List<ProcessInstance> pp = database.query(ppQuery);
        system.debug('ProcessInstance query'+pp);
        for(ProcessInstance Pl : pp){
            if(!ProccesSstatus.containsKey(Pl.TargetObjectId)){
                ProccesSstatus.put(Pl.TargetObjectId,new List<String> {Pl.Status});
            }else
                ProccesSstatus.get(Pl.TargetObjectId).add(Pl.Status);
        }
        system.debug('ProccesSstatus'+ProccesSstatus);
        List<Sobject> updatedeal = new List<Sobject> ();
        String strSOQL = 'SELECT Id,FBE_Approval_Fired__c,FBE_Secondary_Status__c,FBE_PMO_Substatus__c FROM ' + sObjName + ' WHERE id in: dealIds';
        Map<String, Object> fieldValueMap = new Map<String, Object>();
        for(Sobject deal : Database.query(strSOQL)){
            fieldValueMap.put('Id',deal.id);
            if(ProccesSstatus.containsKey(deal.id) && ProccesSstatus.get(deal.id).contains('Pending')) { 
                fieldValueMap.put('FBE_Approval_Fired__c',false);
                system.debug('inside if FBE_Approval_Fired__c'+fieldValueMap);
                updatedeal.add(deal);
            }else
            {
                fieldValueMap.put('FBE_Approval_Fired__c',false);
                fieldValueMap.put('FBE_Secondary_Status__c','Sales Approved');
                //deal.FBE_PMO_Substatus__c = 'Pending With PMO';
                system.debug('inside else FBE_Approval_Fired__c'+fieldValueMap);
            }
            
        } 
        
        
        if(fieldValueMap != null && fieldValueMap.size()>0){
            try{
                String sObjectName = sObjName;
                Schema.SObjectType t  = Schema.getGlobalDescribe().get(sObjectName);
                SObject dealing = t.newSObject();
                for(String fieldName : fieldValueMap.keySet()){
                    dealing.put(fieldName, fieldValueMap.get(fieldName));
                }
                Update dealing;
                system.debug('Inside Change Update Final'+fieldValueMap);
            }Catch(Exception e){
                System.debug(e);
            }
        }
        
    }
    /****************        
* @MethodName    : RecallOrRejectStatus
* @Trigger       : = FBE_DealExtnApprl
* @Description   : This method is called from class== FBE_DealExtnApprl. In this method,is to change status to Sales Rejected 
* @CreatedBy     : DeLL Team
* @CreatedOn     : 01-26-2022 [Soumithri Rekha]
************/
    public static void RecallOrRejectStatus(Set<Id> dealIds,String comments, String state, string sObjName){
        system.debug('Inside Reject Status');
        Map<Id, List<String>> ProccesSstatus = new Map<Id, List<String>>();
        Map<Id, List<Id>> ProccessWorkStatus = new Map<Id, List<Id>>();
        Map<Id, List<String>> ProccessActorName = new Map<Id, List<String>>();
        string pend = 'Pending';
        string queueName = 'PSPPMOTeamQueue';
        string processInstanceq = 'Select p.Id,p.ProcessInstance.TargetObjectId,p.ProcessInstance.Status,p.Actor.Name from ProcessInstanceWorkitem p  where p.ProcessInstance.TargetObjectId in: dealIds AND p.ProcessInstance.Status =:pend and p.Actor.Name =:queueName';
        if(comments == System.label.FBE_Status_Recalled){
            for(ProcessInstanceWorkitem Pl  : database.query(processInstanceq)){
                if(!ProccesSstatus.containsKey(Pl.ProcessInstance.TargetObjectId)){
                    ProccesSstatus.put(Pl.ProcessInstance.TargetObjectId,new List<String> {Pl.ProcessInstance.Status});
                }else
                    ProccesSstatus.get(Pl.ProcessInstance.TargetObjectId).add(Pl.ProcessInstance.Status);
                ProccessWorkStatus.put(Pl.ProcessInstance.TargetObjectId,new List<String> {Pl.Id});
            }
        }
        else{
            string processq = 'Select p.Id,p.ProcessInstance.TargetObjectId,p.ProcessInstance.Status,p.Actor.Name from ProcessInstanceWorkitem p  where p.ProcessInstance.TargetObjectId in: dealIds AND p.ProcessInstance.Status=:pend and p.Actor.Name !=: queueName';
            for(ProcessInstanceWorkitem Pl  : database.query(processq))
            {
                system.debug('Inside Process Instance');
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
        }
        system.debug('ProccesSstatus'+ProccesSstatus);
        Map<String, Object> fieldValueMap = new Map<String, Object>();
        String strSOQL = 'SELECT Id,FBE_Approval_Fired__c,FBE_Secondary_Status__c,FBE_PMO_Substatus__c FROM ' + sObjName + ' WHERE id in: dealIds'; 
        
        system.debug('strSOQL'+strSOQL);
        for(sobject deal : Database.query(strSOQL)){
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
            fieldValueMap.put('Id',deal.id);
            if(comments != System.label.FBE_Status_Recalled){
                fieldValueMap.put('FBE_Approval_Fired__c',false);
                fieldValueMap.put('FBE_PMO_Substatus__c','Pending With PMO');
                system.debug('inside else FBE_Approval_Fired__c'+fieldValueMap);
                
            }
            else{
                fieldValueMap.put('FBE_PMO_Substatus__c', 'Sales Review');
                fieldValueMap.put('FBE_Secondary_Status__c', '');
                fieldValueMap.put('FBE_ApprovalFlowCheck__c', false);
            }
            
        }
        if(fieldValueMap != null && fieldValueMap.size()>0){
            try{
                String sObjectName = sObjName;
                Schema.SObjectType t  = Schema.getGlobalDescribe().get(sObjectName);
                SObject dealing = t.newSObject();
                for(String fieldName : fieldValueMap.keySet()){
                    dealing.put(fieldName, fieldValueMap.get(fieldName));
                }
                Update dealing;
            }Catch(Exception e){
                //trigger.new[0].addError('Funding Source, Book Date in Future, Sales Stage, Solution Domain is mandatory for Approval.');
                //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,e.getMessage());
                system.debug(e);
            }
        }
    }
    
    /****************        
* @MethodName    : callPSPPMOApproval
* @Trigger       : = FBE_DealExtnApprl
* @Description   : This method is called from class== FBE_DealExtnApprl. In this method,is to call PSP PMO Approval Process
* @CreatedBy     : DeLL Team
* @CreatedOn    : 01-26-2022 [Soumithri Rekha]
************/ 
    public static void callPSPPMOApproval(Set<id> dealIds, Map<id,string> includeExn, Map<id,id> includeExnid){
        Group pmoQueue = [select Id,name from Group where  Type = 'Queue' AND name = 'PSPPMOTeamQueue' limit 1];
        Id senderId = [SELECT id from user where email =:System.label.FBE_Approval_OWD].Id;
        
        for(Id SeconddealIds : dealIds){
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setSubmitterId(senderId);
            if(includeExn !=  null){
                system.debug('Inside Extension:'+includeExnid.get(SeconddealIds));
                req1.setObjectId(includeExnid.get(SeconddealIds));
                req1.setProcessDefinitionNameOrId('FBE_Deal_Extension_PMO_Approval_Process');
            }
            else{
                req1.setObjectId(SeconddealIds);
                req1.setProcessDefinitionNameOrId('FBE_ApprovalFor_PSPPMOTeam');
            }
            req1.setNextApproverIds(new ID[] {pmoQueue.Id});
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
}