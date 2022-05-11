/**
* @description : FEATURE 9745204 STORY 10822324 : 24hr and 48hr reminder batch for deal extensions
* @author      : Dipanshu Parakh
* @created on  : 20-01-2022
**/
public with sharing class FBE_FPRMDealExtApprovalReminderBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc){    
        return Database.getQueryLocator([Select Id, Name, FBE_Extension_Request_Status__c, FBE_Sequence_Number__c, FBE_First_Reminder__c, FBE_Second_Reminder__c, FBE_Deal_Registration__c, FBE_Extension_Request_Reason__c,
                                         FBE_Deal_EndUser_Account__c, FBE_Deal_FSI_Account__c, FBE_Deal_Registration__r.FBE_FSI_Internal_Use__c, FBE_Deal_Distributor_Account__c, FBE_Deal_Reseller_Account__c, CreatedDate
                                         FROM Deal_Extension__c WHERE FBE_Extension_Request_Status__c ='Submitted' AND FBE_Secondary_Status__c = 'Pending Sales Review' AND FBE_Sequence_Number__c > 1
                                         AND ( DAY_ONLY(ConvertTimeZone(FBE_First_Reminder__c)) = :Date.today() OR DAY_ONLY(ConvertTimeZone(FBE_Second_Reminder__c)) = :Date.today())]);            
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        List<String> toAddress = new List<String>();
        List<String> ccAddress = new List<String>();
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        Map<Id,Id> dealIdWithEUAccountFR = new Map<Id,Id>();
        Map<Id,Id> dealIdWithDistiAccountFR = new Map<Id,Id>();
        Map<Id,Id> dealIdWithVARAccountFR = new Map<Id,Id>();
        Map<Id,Id> dealIdWithFSIAccountFR = new Map<Id,Id>();
        Map<Id, Deal_Extension__c> dealIdDealExtensionMapFR = new Map<Id, Deal_Extension__c>();

        Map<Id,Id> dealIdWithEUAccountSR = new Map<Id,Id>();
        Map<Id,Id> dealIdWithDistiAccountSR = new Map<Id,Id>();
        Map<Id,Id> dealIdWithVARAccountSR = new Map<Id,Id>();
        Map<Id,Id> dealIdWithFSIAccountSR = new Map<Id,Id>();       
        Map<Id, Deal_Extension__c> dealIdDealExtensionMapSR = new Map<Id, Deal_Extension__c>();

        for(Deal_Extension__c dealExt : (List<Deal_Extension__c>)scope){              
            if(dealExt.FBE_First_Reminder__c != null && dealExt.FBE_First_Reminder__c.Date() == System.today() 
            && dealExt.FBE_First_Reminder__c.timeGMT() <= System.now().timeGMT() && dealExt.FBE_First_Reminder__c.timeGMT() >= system.now().timeGMT().addHours(-1)){
                dealIdDealExtensionMapFR.put(dealExt.FBE_Deal_Registration__c, dealExt);               
                if(dealExt.FBE_Deal_EndUser_Account__c != null){                      
                    dealIdWithEUAccountFR.put(dealExt.FBE_Deal_Registration__c, dealExt.FBE_Deal_EndUser_Account__c);                   
                    
                    if(dealExt.FBE_Deal_Distributor_Account__c != null || dealExt.FBE_Deal_Reseller_Account__c != null){
                        dealIdWithDistiAccountFR.put(dealExt.FBE_Deal_Registration__c , dealExt.FBE_Deal_Distributor_Account__c);
                        dealIdWithVARAccountFR.put(dealExt.FBE_Deal_Registration__c , dealExt.FBE_Deal_Reseller_Account__c);                        
                    }                    
                }
                if(dealExt.FBE_Deal_FSI_Account__c != null && dealExt.FBE_Deal_Registration__r.FBE_FSI_Internal_Use__c !='Sell-in'){
                    dealIdWithFSIAccountFR.put(dealExt.FBE_Deal_Registration__c , dealExt.FBE_Deal_FSI_Account__c);                    
                }                    
            }  
            if(dealExt.FBE_Second_Reminder__c != null && dealExt.FBE_Second_Reminder__c.Date() == system.today() 
            && dealExt.FBE_Second_Reminder__c.timeGMT() <= System.now().timeGMT() && dealExt.FBE_Second_Reminder__c.timeGMT() >= system.now().timeGMT().addHours(-1)){
                dealIdDealExtensionMapSR.put(dealExt.FBE_Deal_Registration__c, dealExt);
                if(dealExt.FBE_Deal_EndUser_Account__c != null){
                    dealIdWithEUAccountSR.put(dealExt.FBE_Deal_Registration__c , dealExt.FBE_Deal_EndUser_Account__c);                    
                    
                    if(dealExt.FBE_Deal_Distributor_Account__c != null || dealExt.FBE_Deal_Reseller_Account__c != null){
                        dealIdWithDistiAccountSR.put(dealExt.FBE_Deal_Registration__c , dealExt.FBE_Deal_Distributor_Account__c);
                        dealIdWithVARAccountSR.put(dealExt.FBE_Deal_Registration__c , dealExt.FBE_Deal_Reseller_Account__c);  
                    }    
                }
                if(dealExt.FBE_Deal_FSI_Account__c != null && dealExt.FBE_Deal_Registration__r.FBE_FSI_Internal_Use__c !='Sell-in'){
                    dealIdWithFSIAccountSR.put(dealExt.FBE_Deal_Registration__c , dealExt.FBE_Deal_FSI_Account__c);                        
                }                    
            }              
        }
        String notificationRoles = System.Label.Deal_Extension_Notification_Roles;
        List<String> notificationRolesList = notificationRoles.split(';');
        
        String euApprovalRoles = System.Label.ApprovalRoles + ';' + notificationRoles;
        List<String> euAccountTeamRolesList = euApprovalRoles.split(';');
        
        String fsiRoles = System.Label.EUFSIApprovalRoles + ';' + notificationRoles;
		List<String> fsiAccountTeamRolesList = fsiRoles.split(';');
                
        OrgWideEmailAddress owea = [SELECT Id from OrgWideEmailAddress where Address =: System.label.FBE_Approval_OWD limit 1];

        //First reminder logic for EU team      
        Map<Id, List<String>> dealIdWithAposProductsFR = new Map<Id,List<String>>();        
        if(dealIdWithEUAccountFR != null) {       
            //creating a map of deal with corresponding APOS products                                          
            List<Deal_Product__c> aposProducts = [Select Id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like: FBE_FPRM_DealConstants.APOS_FILTERS and Deal_Registration_Name__c in : dealIdWithEUAccountFR.Keyset()];
            if(aposProducts.size() > 0){
                for(Deal_Product__c dealp : aposProducts){
                    if(!dealIdWithAposProductsFR.containsKey(dealp.Deal_Registration_Name__c)){
                        dealIdWithAposProductsFR.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
                    }else{
                        dealIdWithAposProductsFR.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
                    }
                }
            }   
            Map<Id, List<AccountTeamMember>> dealIdWithEUTeamMembersFR = getAccountTeamMembersMap(euAccountTeamRolesList, dealIdWithEUAccountFR);
            Map<Id, List<AccountTeamMember>> dealIdWithDistiTeamMembersFR = getAccountTeamMembersMap(FBE_FPRM_DealConstants.distiVARAccTeamRoles, dealIdWithDistiAccountFR);
            Map<Id, List<AccountTeamMember>> dealIdWithVARTeamMembersFR = getAccountTeamMembersMap(FBE_FPRM_DealConstants.distiVARAccTeamRoles, dealIdWithVARAccountFR);
                        
            Map<Id, Deal_Registration__c> dealMap_EU_fr = getDealRegMap(dealIdWithEUAccountFR.keySet());
            EmailTemplate templ_fr = [SELECT Id, Name, HtmlValue, Body, Markup from EmailTemplate where Name='FBE Deal Extension First Reminder Email' limit 1];
            
            for(Id dealId : dealMap_EU_fr.keySet()){   
                toAddress.clear();
        		ccAddress.clear(); 
                Deal_Registration__c dealObj = dealMap_EU_fr.get(dealId);
                List<Deal_Product__c> dealProductsList = dealObj.Deal_Products__r;
                Messaging.SingleEmailMessage email =  getEmailDetails(dealObj, dealIdDealExtensionMapFR, 'EU Extn Team', templ_fr);
                email.setOrgWideEmailAddressId(owea.Id);               

                if(dealIdWithEUTeamMembersFR.containsKey(dealId)){                 
                    for (AccountTeamMember accTm : dealIdWithEUTeamMembersFR.get(dealId)){   
                        if (accTm.TeamMemberRole == 'SVC_APOS_SR' && dealIdWithAposProductsFR.size() > 0){     
                                ccAddress.add(accTm.user.email);                               
                        } 
                        if(notificationRolesList.contains(accTm.TeamMemberRole)){
                            for(Deal_Product__c dealProduct : dealProductsList){                             
                                if(FBE_FPRM_DealConstants.CSG_BU_CATEGORIES.contains(dealProduct.FBE_Product__r.FBE_BU_Category__c)){
                                    ccAddress.add(accTm.user.email);
                                }
                            }
                        }else if(!notificationRolesList.contains(accTm.TeamMemberRole) && accTm.TeamMemberRole != 'SVC_APOS_SR'){
                            toAddress.add(accTm.user.email);
                        }
                    }
                }
                if(dealIdWithDistiTeamMembersFR.containsKey(dealId)){
                    for (AccountTeamMember distiTeamMember : dealIdWithDistiTeamMembersFR.get(dealId)){
                        if(FBE_FPRM_DealConstants.distiVARAccTeamRoles.contains(distiTeamMember.TeamMemberRole)){
                            ccAddress.add(distiTeamMember.user.email);
                        }
                    }
                }               
                if(dealIdWithVARTeamMembersFR.containsKey(dealId)){
                    for (AccountTeamMember resellerTeamMember : dealIdWithVARTeamMembersFR.get(dealId)){     
                        if(FBE_FPRM_DealConstants.distiVARAccTeamRoles.contains(resellerTeamMember.TeamMemberRole)){
                            ccAddress.add(resellerTeamMember.user.email);
                        }
                    }
                }   
                email.setToAddresses(toAddress);
                email.setCcAddresses(ccAddress);
                mailList.add(email);        
            } 
        }         
        toAddress.clear();
        ccAddress.clear(); 
        
        // First Reminder logic for FSI Team Only     
        if(dealIdWithFSIAccountFR != null) {
            Map<Id,List<AccountTeamMember>> dealIdWithFSITeammembersFR = getAccountTeamMembersMap(fsiAccountTeamRolesList, dealIdWithFSIAccountFR);               
            Map<Id,Deal_Registration__c> dealMap_FSI_fr = getDealRegMap(dealIdWithFSIAccountFR.keySet());
           
            EmailTemplate templ_fsifr = [Select Id,Name,HtmlValue,Body,Markup from EmailTemplate where Name = 'FBE Deal Extension First Reminder Email' limit 1];
            for(Id dealId : dealMap_FSI_fr.keySet()){
                toAddress.clear();
        		ccAddress.clear(); 
                Deal_Registration__c dealObj = dealMap_FSI_fr.get(dealId);
                List<Deal_Product__c> dealProductsList = dealObj.Deal_Products__r;
                Messaging.SingleEmailMessage email = getEmailDetails(dealObj, dealIdDealExtensionMapFR, 'FSI Extn Team', templ_fsifr);
                email.setOrgWideEmailAddressId(owea.Id);  
                
                if(dealIdWithFSITeammembersFR.containsKey(dealId)){
                    for (AccountTeamMember Acctm : dealIdWithFSITeammembersFR.get(dealId)){  
                        if(notificationRolesList.contains(Acctm.TeamMemberRole)){
                            for(Deal_Product__c dealProduct : dealProductsList){
                                if(FBE_FPRM_DealConstants.CSG_BU_CATEGORIES.contains(dealProduct.FBE_Product__r.FBE_BU_Category__c)){
                                    ccAddress.add(Acctm.user.email);
                                }
                            }
                        }else{
                            toAddress.add(Acctm.user.email);
                        }
                    }
                }
                email.setToAddresses(toAddress);
                email.setCcAddresses(ccAddress);
                mailList.add(email);              
            }
        }      
        toAddress.clear();
        ccAddress.clear(); 

        //Second Reminder logic for EU team
        Map<Id, List<String>> dealIdWithAposProductsSR = new Map<Id,List<String>>();
        if(dealIdWithEUAccountSR != null) { 
            List<Deal_Product__c> aposProducts = [Select Id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like: FBE_FPRM_DealConstants.APOS_FILTERS and Deal_Registration_Name__c in : dealIdWithEUAccountSR.Keyset()];
            if(aposProducts.size() > 0){
                for(Deal_Product__c dealp : aposProducts){
                    if(!dealIdWithAposProductsSR.containsKey(dealp.Deal_Registration_Name__c)){
                        dealIdWithAposProductsSR.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
                    }else{
                        dealIdWithAposProductsSR.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
                    }
                }
            }           
            Map<Id, List<AccountTeamMember>> dealIdWithEUTeamMembersSR = getAccountTeamMembersMap(euAccountTeamRolesList, dealIdWithEUAccountSR);
            Map<Id, List<AccountTeamMember>> dealIdWithDistiTeamMembersSR = getAccountTeamMembersMap(FBE_FPRM_DealConstants.distiVARAccTeamRoles, dealIdWithDistiAccountSR);
            Map<Id, List<AccountTeamMember>> dealIdWithVARTeamMembersSR = getAccountTeamMembersMap(FBE_FPRM_DealConstants.distiVARAccTeamRoles, dealIdWithVARAccountSR);
            
            Map<Id, Deal_Registration__c> dealMap_EU_SR = getDealRegMap(dealIdWithEUAccountSR.keySet()); 
            EmailTemplate templSR = [SELECT Id, Name, HtmlValue, Body, Markup from EmailTemplate where Name = 'FBE Deal Extension Second Reminder Email' limit 1];
            
            for(Id dealId : dealMap_EU_SR.keySet()){    
                toAddress.clear();
        		ccAddress.clear(); 
                Deal_Registration__c dealObj = dealMap_EU_SR.get(dealId);
                List<Deal_Product__c> dealProductsList = dealObj.Deal_Products__r;
                Messaging.SingleEmailMessage email =  getEmailDetails(dealObj, dealIdDealExtensionMapSR, 'EU Extn Team', templSR);
                email.setOrgWideEmailAddressId(owea.Id);     

                if(dealIdWithEUTeamMembersSR.containsKey(dealId)){                 
                    for (AccountTeamMember accTm : dealIdWithEUTeamMembersSR.get(dealId)){  
                        if (accTm.TeamMemberRole == 'SVC_APOS_SR' && dealIdWithAposProductsSR.size() > 0){                              
                                ccAddress.add(accTm.user.email);           
                        } 
                        if(notificationRolesList.contains(accTm.TeamMemberRole)){
                            for(Deal_Product__c dealProduct : dealProductsList){                             
                                if(FBE_FPRM_DealConstants.CSG_BU_CATEGORIES.contains(dealProduct.FBE_Product__r.FBE_BU_Category__c)){
                                    ccAddress.add(accTm.user.email);
                                }
                            }
                        }else if(!notificationRolesList.contains(accTm.TeamMemberRole) && accTm.TeamMemberRole != 'SVC_APOS_SR'){
                            toAddress.add(accTm.user.email);
                        }
                    }
                }
                if(dealIdWithDistiTeamMembersSR.containsKey(dealId)){
                    for (AccountTeamMember distiTeamMember : dealIdWithDistiTeamMembersSR.get(dealId)){
                        if(FBE_FPRM_DealConstants.distiVARAccTeamRoles.contains(distiTeamMember.TeamMemberRole)){
                            ccAddress.add(distiTeamMember.user.email);
                        }
                    }
                }               
                if(dealIdWithVARTeamMembersSR.containsKey(dealId)){
                    for (AccountTeamMember resellerTeamMember : dealIdWithVARTeamMembersSR.get(dealId)){     
                        if(FBE_FPRM_DealConstants.distiVARAccTeamRoles.contains(resellerTeamMember.TeamMemberRole)){
                            ccAddress.add(resellerTeamMember.user.email);
                        }
                    }
                } 
                email.setToAddresses(toAddress);
                email.setCcAddresses(ccAddress);
                mailList.add(email);        
            } 
        }
        toAddress.clear();
        ccAddress.clear(); 

        // Second Reminder logic for FSI Team Only     
        if(dealIdWithFSIAccountSR != null) {
            Map<Id,List<AccountTeamMember>> dealIdWithFSITeammembersSR = getAccountTeamMembersMap(fsiAccountTeamRolesList, dealIdWithFSIAccountSR);               
            Map<Id,Deal_Registration__c> dealMap_FSI_SR = getDealRegMap(dealIdWithFSIAccountSR.keySet());
            
            EmailTemplate templFsiSR = [Select Id,Name,HtmlValue,Body,Markup from EmailTemplate where Name='FBE Deal Extension Second Reminder Email' limit 1];
            for(Id dealId : dealMap_FSI_SR.keySet()){
                toAddress.clear();
        		ccAddress.clear(); 
                Deal_Registration__c dealObj = dealMap_FSI_SR.get(dealId);
                List<Deal_Product__c> dealProductsList = dealObj.Deal_Products__r;
                
                Messaging.SingleEmailMessage email = getEmailDetails(dealObj, dealIdDealExtensionMapSR, 'FSI Extn Team', templFsiSR);
                email.setOrgWideEmailAddressId(owea.Id);  
                
                if(dealIdWithFSITeammembersSR.containsKey(dealId)){
                    for (AccountTeamMember Acctm : dealIdWithFSITeammembersSR.get(dealId)){           
                        if(notificationRolesList.contains(Acctm.TeamMemberRole)){
                            for(Deal_Product__c dealProduct : dealProductsList){
                                if(FBE_FPRM_DealConstants.CSG_BU_CATEGORIES.contains(dealProduct.FBE_Product__r.FBE_BU_Category__c)){
                                    ccAddress.add(Acctm.user.email);
                                }
                            }
                        }else{
                            toAddress.add(Acctm.user.email);
                        }
                    }
                }
                email.setToAddresses(toAddress);
                email.setCcAddresses(ccAddress);
                mailList.add(email);              
            }
        }
       	if(mailList.size()>0){
            try{
                Messaging.sendEmail(mailList);
            }catch(Exception e){
                System.debug(e);
            }
        }      
    }    
    
    public void finish(Database.BatchableContext BC){}
    
    //to get a list of account team members for each deal based on roles provided
    private static Map<Id, List<AccountTeamMember>> getAccountTeamMembersMap(List<String> notifyAccTeamRoles, Map<Id, Id> dealIdWithAccountIdMap){
        Map<Id, List<AccountTeamMember>> accountTeamMembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id, List<AccountTeamMember>> dealIdWithAccountTeamMembers = new Map<Id,List<AccountTeamMember>>();
        for(Account a : [SELECT Id,(Select Id, AccountId, User.Manager.Id, UserId, TeamMemberRole, user.email 
                                    FROM AccountTeamMembers where TeamMemberRole IN : notifyAccTeamRoles ) from Account where Id IN : dealIdWithAccountIdMap.values()]){
                                        accountTeamMembers.put(a.Id, a.AccountTeamMembers);
                                    }
        if(accountTeamMembers != null){    
            for(Id i : dealIdWithAccountIdMap.keySet()){
                if(dealIdWithAccountIdMap.get(i) != NULL && accountTeamMembers.containsKey(dealIdWithAccountIdMap.get(i))){
                    if(accountTeamMembers.get(dealIdWithAccountIdMap.get(i)) != NULL){
                        dealIdWithAccountTeamMembers.put(i, accountTeamMembers.get(dealIdWithAccountIdMap.get(i)));
                    }   
                }
            }
        }
        return dealIdWithAccountTeamMembers; 
    } 
    
    //This function queries the deal registration object based on the IDs provided and return a Map
    private static Map<Id,Deal_Registration__c> getDealRegMap(Set<Id> dealIdSet){
        Map<Id,Deal_Registration__c> dealMap = new Map<Id, Deal_Registration__c>([SELECT id,Name,FBE_Analyst_Observations_History__c,Analyst_Observations__c,FBE_Deal_Reg_Num__c,FBE_Opportunity_Number__c,CreatedDate,FBE_Submission_Date__c,
                                                                                             FBE_Forecast_Amount__c,FBE_Deal_Justification_Statement__c,FBE_Book_Date__c, FBE_End_User_Account_Name__c,FBE_End_User_First_Name__c,FBE_End_User_Last_Name__c,
                                                                                             FBE_End_User_Mailing_Street__c,FBE_End_User_Mailing_City__c,FBE_End_User_Mailing_State__c, FBE_End_User_Mailing_Zip__c,FBE_End_User_Mailing_Country__c,
                                                                                             FBE_End_User_Email__c,FBE_End_User_Phone__c,FBE_Reseller_VAR_Account__r.Name, FBE_Distributor_Account__r.Name,FBE_FSI_Account__r.Name,FBE_Partner_Sales_Rep_Name__c,
                                                                                             FBE_Partner_Sales_Rep_Email__c, FBE_End_User_Account__r.Name,FBE_Deal_Createddate__c,FBE_Formatted_Book_Date__c,FBE_Formatted_Submission_Date__c,
                                                                                             (Select FBE_Product__r.Name,FBE_Quantity__c, FBE_Product__r.FBE_BU_Category__c from Deal_Products__r)
                                                                                             FROM Deal_Registration__c WHERE Id IN :dealIdSet]);
        return dealMap;
    }
    
    //to create Email object and prepare its markup
    private static Messaging.SingleEmailMessage getEmailDetails(Deal_Registration__c dealObj, Map<Id, Deal_Extension__c> dealIdDealExtensionMap, String team, EmailTemplate templ){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();      
        Deal_Extension__c dealExtObj = dealIdDealExtensionMap.get(dealObj.Id);
        
        String subject = '';
        if(templ.Name == 'FBE Deal Extension First Reminder Email'){
            subject = FBE_ApprovalEmailHandler.getEmailSubject(dealObj, 'REMINDER: TIME SENSITIVE EXTENSION REQUEST: ');
        } else if(templ.Name == 'FBE Deal Extension Second Reminder Email'){
            subject = FBE_ApprovalEmailHandler.getEmailSubject(dealObj, 'FINAL REMINDER: TIME SENSITIVE EXTENSION REQUEST: ');
        }
        email.setSubject(subject);
		Emailtemplate clonetemp = templ.clone();
        EmailTemplate returntemp = FBE_ApprovalEmailHandler.getEmailTemplate(dealObj, clonetemp);
        returntemp = FBE_ApprovalEmailHandler.getDealExtEmailTemplate(dealExtObj, returntemp);
        String aprovalLink = FBE_ApprovalEmailHandler.getApprovalLink(dealExtObj.Id, team);
        returntemp.Markup = returntemp.Markup.replace('dealExtensionApprovalLink', '<a href=' + aprovalLink + '>' + dealObj.Name + ' - ' + dealExtObj.Name + '</a>');                               
        email.setHtmlBody(returntemp.Markup);

        return email;
    }        
}