/************    
* @ClassName    : FBE_DealApprovalsNotificationBatch 
* @Description   : Send First & Second reminders for EU/FSI & Disti/VAR_Reseller Approvers
* @CreatedBy     : DeLL Team
* @CreatedOn     : 12-13-2019 [Sai]
* @UpdatedOn     : 09-03-2021 [Siva Kumar Valluru] - Removed the Group logic & revamp the code, Feature #10004794
* @UpdatedOn     : 15-03-2021 [Siva Kumar Valluru] - Retrieve the last hour reminders record as per the Defect #10110723
* @UpdatedOn     : 21-04-2021 [Siva Kumar Valluru] - Re-added the Apos Product logic for EU Team, Defect #10476452
* @UpdatedOn     : 09-06-2021 [Siva Kumar Valluru] - Approval Email notification data discrepancy,  Defect #10717359
* @UpdatedOn     : 22-06-2021 [Siva Kumar Valluru] - Defect #10580424
* @Modified 	 : Added Sell-IN/Sell-out Check for FSI Apporvals remiders [Story# 9515291]
*********************/
public class FBE_DealApprovalsNotificationBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    public static String[] filters = new String[]{'%APOS%','%Nutanix%','%XC Series%', '%Service%','%SonicWALL%', '%VMWare%', '%Maintenance%', '%Warranty Extension%', '%Warranty%', '%Entitlement%', '%Renewal%'};   
        private final static Set<String> CSG_BU_CATEGORIES = new Set<String>{'CSG Hardware', 'CSG Other'};
            
            public Database.QueryLocator start(Database.BatchableContext BC){  
                return Database.getQueryLocator([Select Id,FBE_Deal_Registration_Status__c,FBE_AE_ManagerID__c,FBE_End_User_Account__c,FBE_FSI_Account__c,FBE_FSI_Internal_Use__c
                                                 ,FBE_Distributor_Account__c,FBE_Reseller_VAR_Account__c, FBE_First_Reminder__c,FBE_Second_Reminder__c FROM Deal_Registration__c WHERE 
                                                 FBE_Deal_Registration_Status__c ='Submitted' AND FBE_Secondary_Status__c = 'Pending Sales Review'
                                                 AND ( DAY_ONLY(ConvertTimeZone(FBE_First_Reminder__c)) = :Date.today() OR DAY_ONLY(ConvertTimeZone(FBE_Second_Reminder__c)) = :Date.today())]);        
            }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){  
        list<String> Toaddress = new list<String>();
        list<String> Ccaddress = new list<String>();
        List<Messaging.SingleEmailMessage> Mail_lst = new List<Messaging.SingleEmailMessage>();
        
        Map<Id, List<AccountTeamMember>> EU_Accteammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id,Id> dealIdWithAccount_fr = new Map<Id,Id>();
        Map<Id,List<AccountTeamMember>> dealIdWithEUTeammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id, List<AccountTeamMember>> EU_Accteammembers_sr = new Map<Id,List<AccountTeamMember>>();
        Map<Id,Id> dealIdWithAccount_sr = new Map<Id,Id>();
        Map<Id,List<AccountTeamMember>> dealIdWithEUTeammembers_sr = new Map<Id,List<AccountTeamMember>>();
        Map<Id, List<AccountTeamMember>> FSI_Accteammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id,Id> dealIdWithFSIAccount_fr = new Map<Id,Id>();
        Map<Id,List<AccountTeamMember>> dealIdWithFSITeammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id, List<AccountTeamMember>> FSI_Accteammembers_sr = new Map<Id,List<AccountTeamMember>>();
        Map<Id,Id> dealIdWithFSIAccount_sr = new Map<Id,Id>();
        Map<Id,List<AccountTeamMember>> dealIdWithFSITeammembers_sr = new Map<Id,List<AccountTeamMember>>();
        
        Map<Id, List<AccountTeamMember>> Disti_Accteammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id,Id> dealIdWithDistiAccount = new Map<Id,Id>();
        Map<Id,List<AccountTeamMember>> dealIdWithDistiTeammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id, List<AccountTeamMember>> Disti_Accteammembers_sr = new Map<Id,List<AccountTeamMember>>();
        Map<Id,Id> dealIdWithDistiAccount_sr = new Map<Id,Id>();
        Map<Id,List<AccountTeamMember>> dealIdWithDistiTeammembers_sr = new Map<Id,List<AccountTeamMember>>();
        
        Map<Id, List<AccountTeamMember>> VAR_Accteammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id,Id> dealIdWithVARAccount = new Map<Id,Id>();
        Map<Id,List<AccountTeamMember>> dealIdWithVARTeammembers = new Map<Id,List<AccountTeamMember>>();
        Map<Id, List<AccountTeamMember>> VAR_Accteammembers_sr = new Map<Id,List<AccountTeamMember>>();
        Map<Id,Id> dealIdWithVARAccount_sr = new Map<Id,Id>();
        Map<Id,List<AccountTeamMember>> dealIdWithVARTeammembers_sr = new Map<Id,List<AccountTeamMember>>();
        system.debug('SCOPE#####'+scope);
        
        //Defect #10476452  
        Map<Id, List<String>> dealIdWithAposProducts_fr = new Map<Id,List<String>>();
        Map<Id,String> dealregQueue_fr = new Map<Id,String>();
        Map<Id, List<String>> dealIdWithAposProducts_sr = new Map<Id,List<String>>();
        Map<Id,String> dealregQueue_sr = new Map<Id,String>();
        
        for(Deal_Registration__c dealReg : (List<Deal_Registration__c>)scope){            
            if(dealReg.FBE_First_Reminder__c != null && dealReg.FBE_First_Reminder__c.Date() == system.today()){                  
                //defect #10110723   
                if(dealReg.FBE_First_Reminder__c.timeGMT() <= System.now().timeGMT() && dealReg.FBE_First_Reminder__c.timeGMT() >= system.now().timeGMT().addHours(-1)){              
                    if(dealReg.FBE_End_User_Account__c != null){
                        dealIdWithAccount_fr.put(dealReg.Id , dealReg.FBE_End_User_Account__c);
                        
                        if(dealReg.FBE_Distributor_Account__c != null || dealReg.FBE_Reseller_VAR_Account__c != null){
                            dealIdWithDistiAccount.put(dealReg.Id , dealReg.FBE_Distributor_Account__c);
                            dealIdWithVARAccount.put(dealReg.Id , dealReg.FBE_Reseller_VAR_Account__c);                        
                        }                    
                    }
                    if(dealReg.FBE_FSI_Account__c != null && dealReg.FBE_FSI_Internal_Use__c !='Sell-in'){
                        dealIdWithFSIAccount_fr.put(dealReg.Id , dealReg.FBE_FSI_Account__c);                    
                    }                        
                }
            }  
            if(dealReg.FBE_Second_Reminder__c != null && dealReg.FBE_Second_Reminder__c.Date() == system.today())  {               
                //defect #10110723
                if(dealReg.FBE_Second_Reminder__c.timeGMT() <= System.now().timeGMT() && dealReg.FBE_Second_Reminder__c.timeGMT() >= system.now().timeGMT().addHours(-1)){
                    if(dealReg.FBE_End_User_Account__c != null){
                        dealIdWithAccount_sr.put(dealReg.Id , dealReg.FBE_End_User_Account__c);                    
                        if(dealReg.FBE_Distributor_Account__c != null || dealReg.FBE_Reseller_VAR_Account__c != null){
                            dealIdWithDistiAccount_sr.put(dealReg.Id , dealReg.FBE_Distributor_Account__c);
                            dealIdWithVARAccount_sr.put(dealReg.Id , dealReg.FBE_Reseller_VAR_Account__c);  
                        }    
                    }
                    if(dealReg.FBE_FSI_Account__c != null && dealReg.FBE_FSI_Internal_Use__c !='Sell-in'){
                        dealIdWithFSIAccount_sr.put(dealReg.Id , dealReg.FBE_FSI_Account__c);                        
                    }                    
                }
            }             
        }
        system.debug('EU Map&&&'+dealIdWithAccount_sr.size());
        
        String[] Aposfilters = new String[]{'%APOS%','%Service%',  '%Maintenance%', '%Warranty Extension%', '%Warranty%', '%Entitlement%', '%Renewal%'};    
            
            // First Reminder logic starts for EU Team Only     
            // Retrieve approvers & notify accountteammembers
            String AccTeamRoles = System.Label.ApprovalRoles;
        AccTeamRoles = AccTeamRoles +';CLIENT_OSS;CLIENT_TSR';
        List<String> Notify_AccTeamRoles = AccTeamRoles.split(';');
        if(dealIdWithAccount_fr != null) {           
            // Added the logic for Apos Products Defect #10476452
            for(Deal_Registration__c deal : [Select id, FBE_Deal_Registration_Status__c,FBE_Deal_Reg__c,FBE_End_User_Account__c,FBE_Distributor_Account__c,FBE_Reseller_VAR_Account__c,
                                             (Select id,FBE_Product__r.Name from Deal_Products__r where FBE_Product__r.Name Like: filters) from Deal_Registration__c where id in:dealIdWithAccount_fr.keyset()]){
                                                 system.debug('Inside For:'+deal);
                                                 dealregQueue_fr.put(deal.Id , deal.FBE_Deal_Reg__c);                 
                                             }
            if(dealregQueue_fr != null){
                List<Deal_Product__c> AposMap = [Select id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like: Aposfilters and Deal_Registration_Name__c in : dealregQueue_fr.Keyset()];
                if(AposMap.size() >0){
                    for(Deal_Product__c dealp : AposMap){
                        if(!dealIdWithAposProducts_fr.containsKey(dealp.Deal_Registration_Name__c)){
                            dealIdWithAposProducts_fr.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
                        }else
                            dealIdWithAposProducts_fr.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
                    }
                }   
            }   
            // Ended the logic for Apos Products Defect #10476452         
            for(Account a : [Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole,user.email from AccountTeamMembers where TeamMemberRole IN : Notify_AccTeamRoles ) from Account where Id in:dealIdWithAccount_fr.values()]){
                EU_Accteammembers.put(a.Id, a.AccountTeamMembers);
            }
            
            if(EU_Accteammembers != null){    
                for(Id i : dealIdWithAccount_fr.keySet()){
                    if(dealIdWithAccount_fr.get(i) != NULL && EU_Accteammembers.containsKey(dealIdWithAccount_fr.get(i))){
                        if(EU_Accteammembers.get(dealIdWithAccount_fr.get(i)) != NULL){
                            dealIdWithEUTeammembers.put(i, EU_Accteammembers.get(dealIdWithAccount_fr.get(i)));
                        }   
                    }
                }
            }
            // for Disti_Accteammembers
            if(dealIdWithDistiAccount != null){
                for(Account a : [Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole,user.email from AccountTeamMembers where TeamMemberRole IN ('AE','SR')) from Account where Id in:dealIdWithDistiAccount.values()]){
                    Disti_Accteammembers.put(a.Id, a.AccountTeamMembers);
                }
            } 
            for(Id i : dealIdWithDistiAccount.keySet()){
                if(dealIdWithDistiAccount.get(i) != NULL && Disti_Accteammembers.containsKey(dealIdWithDistiAccount.get(i))){
                    if(Disti_Accteammembers.get(dealIdWithDistiAccount.get(i)) != NULL){
                        dealIdWithDistiTeammembers.put(i, Disti_Accteammembers.get(dealIdWithDistiAccount.get(i)));
                    }   
                }
            }        
            // for VAR_Accteammembers
            if(dealIdWithVARAccount != null){
                for(Account a : [Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole,user.email from AccountTeamMembers where TeamMemberRole IN ('AE','SR') ) from Account where Id in:dealIdWithVARAccount.values()]){
                    VAR_Accteammembers.put(a.Id, a.AccountTeamMembers);
                }
            } 
            for(Id i : dealIdWithVARAccount.keySet()){
                if(dealIdWithVARAccount.get(i) != NULL && VAR_Accteammembers.containsKey(dealIdWithVARAccount.get(i))){
                    if(VAR_Accteammembers.get(dealIdWithVARAccount.get(i)) != NULL){
                        dealIdWithVARTeammembers.put(i, VAR_Accteammembers.get(dealIdWithVARAccount.get(i)));
                    }   
                }
            }
            OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address =: System.label.FBE_Approval_OWD limit 1];
            Map<Id,Deal_Registration__c> dealMap_EU_fr = new Map<Id, Deal_Registration__c>([SELECT id,Name,FBE_Analyst_Observations_History__c,Analyst_Observations__c,FBE_Deal_Reg_Num__c,FBE_Opportunity_Number__c,CreatedDate,FBE_Submission_Date__c,
                                                                                            FBE_Forecast_Amount__c,FBE_Deal_Justification_Statement__c,FBE_Book_Date__c, FBE_End_User_Account_Name__c,FBE_End_User_First_Name__c,FBE_End_User_Last_Name__c,
                                                                                            FBE_End_User_Mailing_Street__c,FBE_End_User_Mailing_City__c,FBE_End_User_Mailing_State__c, FBE_End_User_Mailing_Zip__c,FBE_End_User_Mailing_Country__c,
                                                                                            FBE_End_User_Email__c,FBE_End_User_Phone__c,FBE_Reseller_VAR_Account__r.Name, FBE_Distributor_Account__r.Name,FBE_FSI_Account__r.Name,FBE_Partner_Sales_Rep_Name__c,
                                                                                            FBE_Partner_Sales_Rep_Email__c, FBE_End_User_Account__r.Name,FBE_Deal_Createddate__c,FBE_Formatted_Book_Date__c,FBE_Formatted_Submission_Date__c,
                                                                                            (Select FBE_Product__r.Name,FBE_Quantity__c, FBE_Product__r.FBE_BU_Category__c from Deal_Products__r)
                                                                                            FROM Deal_Registration__c WHERE Id IN :dealIdWithAccount_fr.keySet()]);
            
            EmailTemplate templ_fr = [Select Id,Name,HtmlValue,Body,Markup from EmailTemplate where Name='FBE Deal First Reminder Email Template' limit 1];
            String  formatted_createddate;
            String formatted_submission_date;
            
            //Iterate the loop for EU first reminder folks
            for(Id dealId : dealMap_EU_fr.keySet()){               
                //Clear the both address during Iteration to avoid duplicate 
                Toaddress.clear();
                Ccaddress.clear();
                formatted_createddate = '';
                formatted_submission_date = '';
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setOrgWideEmailAddressId(owea.Id);
                Deal_Registration__c dealObj = dealMap_EU_fr.get(dealId);
                List<Deal_Product__c> dealProductsList = dealObj.Deal_Products__r;
                //defect #10580424
                if(String.isBlank(dealObj.FBE_Deal_Createddate__c)){
                    formatted_createddate = FBE_ApprovalEmailHandler.getformattedDatetime(dealObj.createdDate);
                    if(String.isNotBlank(formatted_createddate)){
                        dealObj.FBE_Deal_Createddate__c = formatted_createddate;
                    }
                }
                if( String.isBlank(dealObj.FBE_Formatted_Submission_Date__c)){
                    formatted_submission_date = FBE_ApprovalEmailHandler.getformattedDatetime(dealObj.FBE_Submission_Date__c);
                    if(String.isNotBlank(formatted_submission_date)){
                        dealObj.FBE_Formatted_Submission_Date__c = formatted_submission_date;
                    }
                }
                String subject = FBE_ApprovalEmailHandler.getEmailSubject(dealObj, 'REMINDER: TIME SENSITIVE APPROVAL REQUEST: ');
                email.setSubject(subject);
                // clone the template for rendering the temp values Defect #10717359
                Emailtemplate clonetemp = templ_fr.clone();
                EmailTemplate returntemp = FBE_ApprovalEmailHandler.getEmailTemplate(dealObj,clonetemp);
                String euApprovalLink = FBE_ApprovalEmailHandler.getApprovalLink(dealId, 'EU Team');
                returntemp.Markup = returntemp.Markup.replace('dealApprovalLinkInsertion', '<a href=' + euApprovalLink + '>' + dealObj.Name + '</a>');               
                email.setHtmlBody(returntemp.Markup);               
                
                if(dealIdWithEUTeammembers.containsKey(dealId)){                 
                    for (AccountTeamMember Acctm : dealIdWithEUTeammembers.get(dealId)){               
                        //Defect #10476452
                        if ( Acctm.TeamMemberRole == 'SVC_APOS_SR'){
                            if(dealIdWithAposProducts_fr.size()>0){
                                if(dealIdWithAposProducts_fr.get(dealId).Size()>0){ 
                                    Ccaddress.add(Acctm.user.email);
                                }
                            }
                        } 
                        if(Acctm.TeamMemberRole == 'CLIENT_TSR' || Acctm.TeamMemberRole == 'CLIENT_OSS'){
                            for(Deal_Product__c dealProduct : dealProductsList){                             
                                if(CSG_BU_CATEGORIES.contains(dealProduct.FBE_Product__r.FBE_BU_Category__c)){
                                    Ccaddress.add(Acctm.user.email);
                                }
                            }
                        } 
                        else if(Acctm.TeamMemberRole != 'CLIENT_OSS' && Acctm.TeamMemberRole != 'SVC_APOS_SR'){
                            Toaddress.add(Acctm.user.email);
                        }
                    }
                }
                //Disti - AE & SR roles added into Ccaddress
                if(dealIdWithDistiTeammembers.containsKey(dealId)){
                    for (AccountTeamMember Disti_AccTm : dealIdWithDistiTeammembers.get(dealId)){
                        if(Disti_AccTm.TeamMemberRole == 'AE' || Disti_AccTm.TeamMemberRole == 'SR'){
                            Ccaddress.add(Disti_AccTm.user.email);
                        }
                    }
                }               
                // VAR/Reseller - AE & SR roles added into Ccaddress
                if(dealIdWithVARTeammembers.containsKey(dealId)){
                    for (AccountTeamMember VAR_AccTm : dealIdWithVARTeammembers.get(dealId)){     
                        if(VAR_AccTm.TeamMemberRole == 'AE' || VAR_AccTm.TeamMemberRole == 'SR'){
                            Ccaddress.add(VAR_AccTm.user.email);
                        }
                    }
                }            
                email.setToAddresses(Toaddress);
                email.setCcAddresses(Ccaddress);
                Mail_lst.add(email);
                system.debug('EU_First_email#####'+email);             
            }         
        }    
        Toaddress.clear();
        Ccaddress.clear();
        // Second Reminder logic starts for EU Team Only 
        
        // Retrieve approvers & notify accountteammembers
        // String AccTeamRoles = System.Label.ApprovalRoles;
        //AccTeamRoles = AccTeamRoles +';CLIENT_OSS';
        //List<String> Notify_AccTeamRoles = AccTeamRoles.split(';');
        if(dealIdWithAccount_sr != null) {          
            // Added the logic for Apos Products Defect #10476452
            for(Deal_Registration__c deal : [Select id, FBE_Deal_Registration_Status__c,FBE_Deal_Reg__c,FBE_End_User_Account__c,FBE_Distributor_Account__c,FBE_Reseller_VAR_Account__c,
                                             (Select id,FBE_Product__r.Name from Deal_Products__r where FBE_Product__r.Name Like: filters OR FBE_Product__r.FBE_BU_Category__c in ('CSG Hardware','CSG Other')) from Deal_Registration__c where id in:dealIdWithAccount_sr.keyset()]){                                                 
                                                 dealregQueue_sr.put(deal.Id , deal.FBE_Deal_Reg__c);
                                                 
                                             }
            if(dealregQueue_sr != null){    
                List<Deal_Product__c> AposMap = [Select id,Deal_Registration_Name__c,FBE_Product__r.Name from Deal_Product__c where FBE_Product__r.Name Like: Aposfilters and Deal_Registration_Name__c in : dealregQueue_sr.Keyset()];
                if(AposMap.size()>0){
                    for(Deal_Product__c dealp : AposMap){
                        if(!dealIdWithAposProducts_sr.containsKey(dealp.Deal_Registration_Name__c)){
                            dealIdWithAposProducts_sr.put(dealp.Deal_Registration_Name__c, new List<String>{dealp.FBE_Product__r.Name});
                        }else
                            dealIdWithAposProducts_sr.get(dealp.Deal_Registration_Name__c).add(dealp.FBE_Product__r.Name);
                    }  
                }   
            }
            // Ended the logic for Apos Products Defect #10476452           
            
            for(Account a : [Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole,user.email from AccountTeamMembers where TeamMemberRole IN : Notify_AccTeamRoles ) from Account where Id in:dealIdWithAccount_sr.values()]){
                EU_Accteammembers_sr.put(a.Id, a.AccountTeamMembers);
            }
            
            for(Id i : dealIdWithAccount_sr.keySet()){
                if(dealIdWithAccount_sr.get(i) != NULL && EU_Accteammembers_sr.containsKey(dealIdWithAccount_sr.get(i))){
                    if(EU_Accteammembers_sr.get(dealIdWithAccount_sr.get(i)) != NULL){
                        dealIdWithEUTeammembers_sr.put(i, EU_Accteammembers_sr.get(dealIdWithAccount_sr.get(i)));
                        
                    }
                }       
            }  
            
            // for Disti_Accteammembers
            if(dealIdWithDistiAccount_sr != null){  
                for(Account a : [Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole,user.email from AccountTeamMembers where TeamMemberRole IN ('AE','SR') ) from Account where Id in:dealIdWithDistiAccount_sr.values()]){
                    Disti_Accteammembers_sr.put(a.Id, a.AccountTeamMembers);
                }
            } 
            for(Id i : dealIdWithDistiAccount_sr.keySet()){
                if(dealIdWithDistiAccount_sr.get(i) != NULL && Disti_Accteammembers_sr.containsKey(dealIdWithDistiAccount_sr.get(i))){
                    if(Disti_Accteammembers_sr.get(dealIdWithDistiAccount_sr.get(i)) != NULL){
                        dealIdWithDistiTeammembers_sr.put(i, Disti_Accteammembers_sr.get(dealIdWithDistiAccount_sr.get(i)));
                    }   
                }
            }
            
            // for VAR_Accteammembers
            if(dealIdWithVARAccount_sr != null){    
                for(Account a : [Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole,user.email from AccountTeamMembers where TeamMemberRole IN ('AE','SR') ) from Account where Id in:dealIdWithVARAccount_sr.values()]){
                    VAR_Accteammembers_sr.put(a.Id, a.AccountTeamMembers);
                }
            } 
            for(Id i : dealIdWithVARAccount_sr.keySet()){
                if(dealIdWithVARAccount_sr.get(i) != NULL && VAR_Accteammembers_sr.containsKey(dealIdWithVARAccount_sr.get(i))){
                    if(VAR_Accteammembers_sr.get(dealIdWithVARAccount_sr.get(i)) != NULL){
                        dealIdWithVARTeammembers_sr.put(i, VAR_Accteammembers_sr.get(dealIdWithVARAccount_sr.get(i)));
                    }   
                }
            }
            
            
            OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address =: System.label.FBE_Approval_OWD limit 1];
            Map<Id,Deal_Registration__c> dealMap_EU_sr = new Map<Id, Deal_Registration__c>([SELECT id,Name,FBE_Analyst_Observations_History__c,Analyst_Observations__c,FBE_Deal_Reg_Num__c,FBE_Opportunity_Number__c,CreatedDate,FBE_Submission_Date__c,
                                                                                            FBE_Forecast_Amount__c,FBE_Deal_Justification_Statement__c,FBE_Book_Date__c, FBE_End_User_Account_Name__c,FBE_End_User_First_Name__c,FBE_End_User_Last_Name__c,
                                                                                            FBE_End_User_Mailing_Street__c,FBE_End_User_Mailing_City__c,FBE_End_User_Mailing_State__c, FBE_End_User_Mailing_Zip__c,FBE_End_User_Mailing_Country__c,
                                                                                            FBE_End_User_Email__c,FBE_End_User_Phone__c,FBE_Reseller_VAR_Account__r.Name, FBE_Distributor_Account__r.Name,FBE_FSI_Account__r.Name,FBE_Partner_Sales_Rep_Name__c,
                                                                                            FBE_Partner_Sales_Rep_Email__c, FBE_End_User_Account__r.Name,FBE_Deal_Createddate__c,FBE_Formatted_Book_Date__c,FBE_Formatted_Submission_Date__c,
                                                                                            (Select FBE_Product__r.Name,FBE_Quantity__c, FBE_Product__r.FBE_BU_Category__c from Deal_Products__r)
                                                                                            FROM Deal_Registration__c WHERE Id IN :dealIdWithAccount_sr.keySet()]);
            
            
            EmailTemplate templ_sr = [Select Id,Name,HtmlValue,Body,Markup from EmailTemplate where Name='FBE Deal Sec Reminder Email Template' limit 1];
            
            String  formatted_createddate;
            String  formatted_submission_date;
            //Iterate the loop for EU second reminder folks
            for(Id dealId : dealMap_EU_sr.keySet()){            
                Toaddress.clear();
                Ccaddress.clear();  
                formatted_createddate = '';
                formatted_submission_date = '';               
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setOrgWideEmailAddressId(owea.Id);
                Deal_Registration__c dealObj = dealMap_EU_sr.get(dealId);
                List<Deal_Product__c> dealProductsList = dealObj.Deal_Products__r;
                
                //defect #10580424
                if(String.isBlank(dealObj.FBE_Deal_Createddate__c)){
                    formatted_createddate = FBE_ApprovalEmailHandler.getformattedDatetime(dealObj.createdDate);
                    if(String.isNotBlank(formatted_createddate)){
                        dealObj.FBE_Deal_Createddate__c = formatted_createddate;
                    }
                }
                if( String.isBlank(dealObj.FBE_Formatted_Submission_Date__c)){
                    formatted_submission_date = FBE_ApprovalEmailHandler.getformattedDatetime(dealObj.FBE_Submission_Date__c);
                    if(String.isNotBlank(formatted_submission_date)){
                        dealObj.FBE_Formatted_Submission_Date__c = formatted_submission_date;
                    }
                }
                
                String subject = FBE_ApprovalEmailHandler.getEmailSubject(dealObj, 'FINAL REMINDER: TIME SENSITIVE APPROVAL REQUEST: ');
                email.setSubject(subject);
                // cloning the template - Defect #10717359
                Emailtemplate clonetemp_EU_sr = templ_sr.clone();
                EmailTemplate returntemp_EU_sr = FBE_ApprovalEmailHandler.getEmailTemplate(dealObj,clonetemp_EU_sr);
                String euApprovalLink2 = FBE_ApprovalEmailHandler.getApprovalLink(dealId, 'EU Team');
                returntemp_EU_sr.Markup = returntemp_EU_sr.Markup.replace('dealApprovalLinkInsertion', '<a href=' + euApprovalLink2 + '>' + dealObj.Name + '</a>');               
                email.setHtmlBody(returntemp_EU_sr.Markup);
                
                if(dealIdWithEUTeammembers_sr.containsKey(dealId)){
                    for (AccountTeamMember Acctm : dealIdWithEUTeammembers_sr.get(dealId)) {    
                        //Defect #10476452
                        // if ( Acctm.TeamMemberRole == 'SVC_APOS_SR' && dealIdWithAposProducts_sr.containsKey(dealId) && dealIdWithAposProducts_sr.get(dealId).Size()>0){
                        if ( Acctm.TeamMemberRole == 'SVC_APOS_SR'){
                            if(dealIdWithAposProducts_sr.size()>0){
                                if(dealIdWithAposProducts_sr.containsKey(dealId)){
                                    if(dealIdWithAposProducts_sr.get(dealId).Size()>0){
                                        Ccaddress.add(Acctm.user.email);
                                    }
                                }
                            }
                        }
                        if(Acctm.TeamMemberRole == 'CLIENT_TSR' || Acctm.TeamMemberRole == 'CLIENT_OSS'){
                            for(Deal_Product__c dealProduct : dealProductsList){
                                if(CSG_BU_CATEGORIES.contains(dealProduct.FBE_Product__r.FBE_BU_Category__c)){
                                    Ccaddress.add(Acctm.user.email);
                                }
                            }
                        } 
                        else if(Acctm.TeamMemberRole != 'CLIENT_OSS' && Acctm.TeamMemberRole != 'SVC_APOS_SR'){                            
                            Toaddress.add(Acctm.user.email);
                        }                    
                    }
                }
                
                //Disti - AE & SR roles added into Ccaddress
                if(dealIdWithDistiTeammembers_sr.containsKey(dealId)){
                    for (AccountTeamMember Disti_Sr_AccTm : dealIdWithDistiTeammembers_sr.get(dealId)){           
                        if(Disti_Sr_AccTm.TeamMemberRole == 'AE' || Disti_Sr_AccTm.TeamMemberRole == 'SR'){
                            Ccaddress.add(Disti_Sr_AccTm.user.email);
                        }
                    }
                }
                
                // VAR/Reseller  - AE & SR roles added into Ccaddress
                if(dealIdWithVARTeammembers_sr.containsKey(dealId)){
                    for (AccountTeamMember VAR_Sr_AccTm : dealIdWithVARTeammembers_sr.get(dealId)){
                        if(VAR_Sr_AccTm.TeamMemberRole == 'AE' || VAR_Sr_AccTm.TeamMemberRole == 'SR'){
                            Ccaddress.add(VAR_Sr_AccTm.user.email);
                        }
                    }
                }           
                email.setToAddresses(Toaddress);
                email.setCcAddresses(Ccaddress);  
                Mail_lst.add(email);
                system.debug('Mail_lst#####'+Mail_lst.size());            
            }              
        }             
        Toaddress.clear();
        Ccaddress.clear();  
        
        // First Reminder logic starts for FSI Team Only     
        // Retrieve approvers & notify accountteammembers
        String FSITeamRoles = System.Label.EUFSIApprovalRoles;
        FSITeamRoles = FSITeamRoles +';CLIENT_OSS;CLIENT_TSR';
        List<String> Notify_FSITeamRoles = FSITeamRoles.split(';');
        
        if(dealIdWithFSIAccount_fr != null) {
            for(Account a : [Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole,user.email from AccountTeamMembers where TeamMemberRole IN : Notify_FSITeamRoles ) from Account where Id in:dealIdWithFSIAccount_fr.values()]){
                FSI_Accteammembers.put(a.Id, a.AccountTeamMembers);
            }
            
            for(Id i : dealIdWithFSIAccount_fr.keySet()){
                if(dealIdWithFSIAccount_fr.get(i) != NULL && FSI_Accteammembers.containsKey(dealIdWithFSIAccount_fr.get(i))){
                    if(FSI_Accteammembers.get(dealIdWithFSIAccount_fr.get(i)) != NULL){
                        dealIdWithFSITeammembers.put(i, FSI_Accteammembers.get(dealIdWithFSIAccount_fr.get(i)));
                    }   
                }
            }  
            OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address =: System.label.FBE_Approval_OWD limit 1];
            Map<Id,Deal_Registration__c> dealMap_FSI_fr = new Map<Id, Deal_Registration__c>([SELECT id,Name,FBE_Analyst_Observations_History__c,Analyst_Observations__c,FBE_Deal_Reg_Num__c,FBE_Opportunity_Number__c,CreatedDate,FBE_Submission_Date__c,
                                                                                             FBE_Forecast_Amount__c,FBE_Deal_Justification_Statement__c,FBE_Book_Date__c, FBE_End_User_Account_Name__c,FBE_End_User_First_Name__c,FBE_End_User_Last_Name__c,
                                                                                             FBE_End_User_Mailing_Street__c,FBE_End_User_Mailing_City__c,FBE_End_User_Mailing_State__c, FBE_End_User_Mailing_Zip__c,FBE_End_User_Mailing_Country__c,
                                                                                             FBE_End_User_Email__c,FBE_End_User_Phone__c,FBE_Reseller_VAR_Account__r.Name, FBE_Distributor_Account__r.Name,FBE_FSI_Account__r.Name,FBE_Partner_Sales_Rep_Name__c,
                                                                                             FBE_Partner_Sales_Rep_Email__c, FBE_End_User_Account__r.Name,FBE_Deal_Createddate__c,FBE_Formatted_Book_Date__c,FBE_Formatted_Submission_Date__c,
                                                                                             (Select FBE_Product__r.Name,FBE_Quantity__c, FBE_Product__r.FBE_BU_Category__c from Deal_Products__r)
                                                                                             FROM Deal_Registration__c WHERE Id IN :dealIdWithFSIAccount_fr.keySet()]);
            
            EmailTemplate templ_fsifr = [Select Id,Name,HtmlValue,Body,Markup from EmailTemplate where Name='FBE Deal First Reminder Email Template' limit 1];
            
            String  formatted_createddate;
            String  formatted_submission_date;       
            //Iterate the loop for FSI first reminder folks
            for(Id dealId : dealMap_FSI_fr.keySet()){
                Toaddress.clear();
                Ccaddress.clear();      
                formatted_createddate = '';
                formatted_submission_date = '';
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setOrgWideEmailAddressId(owea.Id);
                Deal_Registration__c dealObj = dealMap_FSI_fr.get(dealId);
                List<Deal_Product__c> dealProductsList = dealObj.Deal_Products__r;
                
                //defect #10580424
                if(String.isBlank(dealObj.FBE_Deal_Createddate__c)){
                    formatted_createddate = FBE_ApprovalEmailHandler.getformattedDatetime(dealObj.createdDate);
                    if(String.isNotBlank(formatted_createddate)){
                        dealObj.FBE_Deal_Createddate__c = formatted_createddate;
                    }
                }
                if( String.isBlank(dealObj.FBE_Formatted_Submission_Date__c)){
                    formatted_submission_date = FBE_ApprovalEmailHandler.getformattedDatetime(dealObj.FBE_Submission_Date__c);
                    if(String.isNotBlank(formatted_submission_date)){
                        dealObj.FBE_Formatted_Submission_Date__c = formatted_submission_date;
                    }
                }
                
                String subject = FBE_ApprovalEmailHandler.getEmailSubject(dealObj, 'REMINDER: TIME SENSITIVE APPROVAL REQUEST: ');
                email.setSubject(subject);
                // cloning the template - Defect #10717359
                Emailtemplate clonetemp_FSI_fr = templ_fsifr.clone();
                EmailTemplate returntemp_FSI_fr = FBE_ApprovalEmailHandler.getEmailTemplate(dealObj,clonetemp_FSI_fr);
                String fsiApprovalLink = FBE_ApprovalEmailHandler.getApprovalLink(dealId, 'FSI Team');
                returntemp_FSI_fr.Markup = returntemp_FSI_fr.Markup.replace('dealApprovalLinkInsertion', '<a href=' + fsiApprovalLink + '>' + dealObj.Name + '</a>');               
                
                email.setHtmlBody(returntemp_FSI_fr.Markup);
                
                if(dealIdWithFSITeammembers.containsKey(dealId)){
                    for (AccountTeamMember Acctm : dealIdWithFSITeammembers.get(dealId))     {           
                        if(Acctm.TeamMemberRole == 'CLIENT_TSR' || Acctm.TeamMemberRole == 'CLIENT_OSS'){
                            for(Deal_Product__c dealProduct : dealProductsList){
                                if(CSG_BU_CATEGORIES.contains(dealProduct.FBE_Product__r.FBE_BU_Category__c)){
                                    Ccaddress.add(Acctm.user.email);
                                }
                            }
                        } 
                        else 
                            Toaddress.add(Acctm.user.email);
                    }
                }
                email.setToAddresses(Toaddress);
                email.setCcAddresses(Ccaddress);
                Mail_lst.add(email);             
            }              
        }    
        Toaddress.clear();
        Ccaddress.clear();
        
        // Second Reminder logic starts for FSI Team Only     
        if(dealIdWithFSIAccount_sr != null) {
            for(Account a : [Select Id,(Select Id,AccountId,User.Manager.Id, UserId,TeamMemberRole,user.email from AccountTeamMembers where TeamMemberRole IN : Notify_FSITeamRoles ) from Account where Id in:dealIdWithFSIAccount_sr.values()]){
                FSI_Accteammembers_sr.put(a.Id, a.AccountTeamMembers);
            }
            
            for(Id i : dealIdWithFSIAccount_sr.keySet()){
                if(dealIdWithFSIAccount_sr.get(i) != NULL && FSI_Accteammembers_sr.containsKey(dealIdWithFSIAccount_sr.get(i))){
                    if(FSI_Accteammembers_sr.get(dealIdWithFSIAccount_sr.get(i)) != NULL){
                        dealIdWithFSITeammembers_sr.put(i, FSI_Accteammembers_sr.get(dealIdWithFSIAccount_sr.get(i)));
                    }   
                }
            }  
            OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address =: System.label.FBE_Approval_OWD limit 1];
            Map<Id,Deal_Registration__c> dealMap_FSI_sr = new Map<Id, Deal_Registration__c>([SELECT id,Name,FBE_Analyst_Observations_History__c,Analyst_Observations__c,FBE_Deal_Reg_Num__c,FBE_Opportunity_Number__c,CreatedDate,FBE_Submission_Date__c,
                                                                                             FBE_Forecast_Amount__c,FBE_Deal_Justification_Statement__c,FBE_Book_Date__c, FBE_End_User_Account_Name__c,FBE_End_User_First_Name__c,FBE_End_User_Last_Name__c,
                                                                                             FBE_End_User_Mailing_Street__c,FBE_End_User_Mailing_City__c,FBE_End_User_Mailing_State__c, FBE_End_User_Mailing_Zip__c,FBE_End_User_Mailing_Country__c,
                                                                                             FBE_End_User_Email__c,FBE_End_User_Phone__c,FBE_Reseller_VAR_Account__r.Name, FBE_Distributor_Account__r.Name,FBE_FSI_Account__r.Name,FBE_Partner_Sales_Rep_Name__c,
                                                                                             FBE_Partner_Sales_Rep_Email__c, FBE_End_User_Account__r.Name,FBE_Deal_Createddate__c,FBE_Formatted_Book_Date__c,FBE_Formatted_Submission_Date__c,
                                                                                             (Select FBE_Product__r.Name,FBE_Quantity__c, FBE_Product__r.FBE_BU_Category__c from Deal_Products__r)
                                                                                             FROM Deal_Registration__c WHERE Id IN :dealIdWithFSIAccount_sr.keySet()]);
            
            
            EmailTemplate templ_fsisr = [Select Id,Name,HtmlValue,Body,Markup from EmailTemplate where Name='FBE Deal Sec Reminder Email Template' limit 1];
            String  formatted_createddate;
            String  formatted_submission_date;        
            //Iterate the loop for FSI final reminder folks
            for(Id dealId : dealMap_FSI_sr.keySet()){               
                Toaddress.clear();
                Ccaddress.clear();  
                formatted_createddate = '';
                formatted_submission_date = '';     
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setOrgWideEmailAddressId(owea.Id);
                Deal_Registration__c dealObj = dealMap_FSI_sr.get(dealId);
                List<Deal_Product__c> dealProductsList = dealObj.Deal_Products__r;
                //defect #10580424
                if(String.isBlank(dealObj.FBE_Deal_Createddate__c)){
                    formatted_createddate = FBE_ApprovalEmailHandler.getformattedDatetime(dealObj.createdDate);
                    if(String.isNotBlank(formatted_createddate)){
                        dealObj.FBE_Deal_Createddate__c = formatted_createddate;
                    }
                }
                if( String.isBlank(dealObj.FBE_Formatted_Submission_Date__c)){
                    formatted_submission_date = FBE_ApprovalEmailHandler.getformattedDatetime(dealObj.FBE_Submission_Date__c);
                    if(String.isNotBlank(formatted_submission_date)){
                        dealObj.FBE_Formatted_Submission_Date__c = formatted_submission_date;
                    }
                }                
                String subject = FBE_ApprovalEmailHandler.getEmailSubject(dealObj, 'FINAL REMINDER: TIME SENSITIVE APPROVAL REQUEST: ');
                email.setSubject(subject);
                // cloning the template - Defect #10717359
                Emailtemplate clonetemp_FSI_sr = templ_fsisr.clone();
                EmailTemplate returntemp_FSI_sr = FBE_ApprovalEmailHandler.getEmailTemplate(dealObj,clonetemp_FSI_sr);
                String fsiApprovalLink2 = FBE_ApprovalEmailHandler.getApprovalLink(dealId, 'FSI Team');
                returntemp_FSI_sr.Markup = returntemp_FSI_sr.Markup.replace('dealApprovalLinkInsertion', '<a href=' + fsiApprovalLink2 + '>' + dealObj.Name + '</a>');               
                
                email.setHtmlBody(returntemp_FSI_sr.Markup);
                
                if(dealIdWithFSITeammembers_sr.containsKey(dealId)){
                    for (AccountTeamMember Acctm : dealIdWithFSITeammembers_sr.get(dealId)){
                        if(Acctm.TeamMemberRole == 'CLIENT_TSR' || Acctm.TeamMemberRole == 'CLIENT_OSS'){
                            for(Deal_Product__c dealProduct : dealProductsList){
                                if(CSG_BU_CATEGORIES.contains(dealProduct.FBE_Product__r.FBE_BU_Category__c)){
                                    Ccaddress.add(Acctm.user.email);
                                }
                            }
                        } 
                        else 
                            Toaddress.add(Acctm.user.email);                        
                    }
                }
                email.setToAddresses(Toaddress);
                email.setCcAddresses(Ccaddress);
                Mail_lst.add(email);             
            }              
        }    
        System.debug('Mail_lst: '+ Mail_lst.size());        
        if(Mail_lst.size()>0){
            try{
                Messaging.sendEmail(Mail_lst);
            }catch(Exception e){
                System.debug(e);
            }
        }        
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}