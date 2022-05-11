/**************
*@ Class Name                                                    : FBE_FPRM_Deal_Exp_Notif_Partner
*@ Description                                                   : This batch class runs as a nightly job which 
                                                                   retrives the List of UserIds present in all the Account Teams and 
                                                                   calls an FBE_DealRegEmailUtility Class for Sending Expiry Notifications. 
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 04-15-2021 [Soumiithri Rekha]
*@ Modification Log                                              : 
***************/
public with sharing class FBE_FPRM_Deal_Exp_Notif_Partner implements database.Batchable<sObject>,Database.Stateful {
    
    Date ExpiryDate10 = Date.Today().addDays(10);
    Date ExpiryDate30 = Date.Today().addDays(30);
    Map<ID,Deal_Registration__c> dealRegMap = new Map<ID,Deal_Registration__c>();
     Map<ID,set<string>> dealWithUserIds30Days = new Map<ID,set<string>>();
    Map<ID,set<string>> dealWithUserIds10Days = new Map<ID,set<string>>();
    Map<ID,set<string>> dealWithUserIds0Days = new Map<ID,set<string>>();
        Map<id,set<string>> addemailId = new Map<id,set<string>>();
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT id,
                                         Name,
                                         FBE_Partner_Owner_Email__c,
                                         FBE_Partner_Sales_Rep_Email__c,
                                         FBE_Partner_Team_Mailbox__c,
                                         FBE_Same_as_submitter__c,
                                         FBE_FPRM_Opportunity__c,
                                         FBE_Account__c,
                                         FBE_Distributor_Account__c,
                                         FBE_End_User_Account__c,
                                         FBE_FSI_Account__c,
                                         FBE_Reseller_VAR_Account__c,
                                         FBE_Related_Opportunity__c,
                                         FBE_Deal_Registration_Status__c,
                                         FBE_Expiration_Date__c,
                                         FBE_Deal_Reg_Num__c,
                                         Sales_Stage__c,
                                         FBE_Account__r.Name,
                                         FBE_Partner_Owner__c,
                                         FBE_Related_Opportunity__r.ownerid,
                                         FBE_Related_Opportunity__r.Name,
                                         CreatedBy.contactId,
                                         FBE_Related_Opportunity__r.FBE_Opportunity_Number__c
                                         FROM Deal_Registration__c
                                         WHERE FBE_Deal_Registration_Status__c = 'Approved' AND
                                         FBE_Partner_Opportunity_Stage__c IN ('Plan - 1%', 'Discover - 10%','Qualify - 30%','Propose - 60%','Commit - 90%') AND
                                         (FBE_Expiration_Date__c =:ExpiryDate10 OR
                                          FBE_Expiration_Date__c =:ExpiryDate30 OR
                                          FBE_Expiration_Date__c = Today)]);
        
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        FBE_FPRM_Notification_Switch__c cms = FBE_FPRM_Notification_Switch__c.getOrgDefaults();
        system.debug(cms.Send_Deal_Extn_Exp_Notification__c);
        if(cms.Send_Deal_Extn_Exp_Notification__c == True){
            for(Deal_Registration__c dealRg : (List<Deal_Registration__c>)scope){
                set<string> emailsHere30 = new set<string>();
                set<string> emailsHere10 = new set<string>();
                set<string> emailsHere = new set<string>();
                dealRegMap.put(dealRg.ID,dealRg);
                if((dealRg.CreatedBy.ContactID != null && cms.FBE_FPRM_Cut_Over_Switch__c == False)|| (cms.FBE_FPRM_Cut_Over_Switch__c == True)){
                if(cms.Send_Deal_Extn_Exp_30_Notification__c == True){
                    emailsHere30.clear();
                if(dealRg.FBE_Partner_Owner_Email__c != null && dealRg.FBE_Expiration_Date__c == Date.Today().addDays(30)){
                    emailsHere30.add(dealRg.FBE_Partner_Owner_Email__c);
                }
                if(dealrg.FBE_Partner_Sales_Rep_Email__c != null && dealRg.FBE_Expiration_Date__c == Date.Today().addDays(30)){
                    emailsHere30.add(dealRg.FBE_Partner_Sales_Rep_Email__c);
                }
                if(dealrg.FBE_Partner_Team_Mailbox__c != null && dealRg.FBE_Expiration_Date__c == Date.Today().addDays(30)){
                     List<String> PartnerTeam = dealrg.FBE_Partner_Team_Mailbox__c.split(',');
                    emailsHere30.addAll(PartnerTeam);
                }
                    if(dealRg.FBE_Expiration_Date__c == Date.Today().addDays(30)){
                        dealWithUserIds30Days.put(dealRg.ID,emailsHere30);
                }
                }
                if(cms.Send_Deal_Extn_Exp_10_Notification__c == True){
                  emailsHere10.clear();
                        system.debug('emailsHere10 after clear'+emailsHere10);
                        system.debug('dealWithUserIds10Days after clear'+dealWithUserIds10Days);
                if(dealRg.FBE_Partner_Owner_Email__c != null && dealRg.FBE_Expiration_Date__c == Date.Today().addDays(10)){
                    emailsHere10.add(dealRg.FBE_Partner_Owner_Email__c);
                }
                if(dealrg.FBE_Partner_Sales_Rep_Email__c != null && dealRg.FBE_Expiration_Date__c == Date.Today().addDays(10)){
                    emailsHere10.add(dealRg.FBE_Partner_Sales_Rep_Email__c);
                }
                if(dealrg.FBE_Partner_Team_Mailbox__c != null && dealRg.FBE_Expiration_Date__c == Date.Today().addDays(10)){
                    List<String> PartnerTeam = dealrg.FBE_Partner_Team_Mailbox__c.split(',');
                    emailsHere10.addAll(PartnerTeam);
                }
                    if(dealRg.FBE_Expiration_Date__c == Date.Today().addDays(10)){
                        dealWithUserIds10Days.put(dealRg.ID,emailsHere10);
                        system.debug('dealWithUserIds10Days'+dealWithUserIds10Days);
                        system.debug('emailsHere10'+emailsHere10);
                }
                }
                if(cms.Send_Deal_Extn_Exp_0_Notification__c == True){
                    emailsHere.clear();
                if(dealRg.FBE_Partner_Owner_Email__c != null && dealRg.FBE_Expiration_Date__c == Date.Today()){
                    emailsHere.add(dealRg.FBE_Partner_Owner_Email__c);
                }
                if(dealrg.FBE_Partner_Sales_Rep_Email__c != null && dealRg.FBE_Expiration_Date__c == Date.Today()){
                    emailsHere.add(dealRg.FBE_Partner_Sales_Rep_Email__c);
                }
                if(dealrg.FBE_Partner_Team_Mailbox__c != null && dealRg.FBE_Expiration_Date__c == Date.Today()){
                    List<String> PartnerTeam = dealrg.FBE_Partner_Team_Mailbox__c.split(',');
                    emailsHere.addAll(PartnerTeam);
                }
                    if(dealRg.FBE_Expiration_Date__c == Date.Today()){
                        dealWithUserIds0Days.put(dealRg.ID,emailsHere);
                }
                }
                }
            }
        }
        
            system.debug('dealRegMap'+dealRegMap);
        system.debug('dealWithUserIds0Days'+dealWithUserIds0Days);
         system.debug('dealWithUserIds10Days'+dealWithUserIds10Days);
        system.debug('dealWithUserIds30Days'+dealWithUserIds30Days);
    }
    public void finish(Database.BatchableContext BC){
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address =:System.label.FBE_Approval_OWD  limit 1];
        system.debug('owea'+owea);
        if(dealRegMap != null){
            system.debug('inside email msg');
            EmailTemplate templ = [Select Id,Name,HtmlValue,Body,Markup from EmailTemplate where Name='FBE_FPRM_DealExp_Notification'];
            for(ID dealId : dealRegMap.keySet()){
                system.debug('Inside FOr'); 
                if(dealWithUserIds30Days.containsKey(dealId)){
                    
                    list<String> Toaddress = new list<String>();
                    Toaddress.addAll(dealWithUserIds30Days.get(dealId));
                    message = FBE_DealRegEmailUtility.ExpiryNotification_Partner(dealRegMap.get(dealId),Toaddress,owea.id);
                    messages.add(message);
                    Toaddress.clear();
                }
                if(dealWithUserIds10Days.containsKey(dealId)){
                    
                    list<String> Toaddress = new list<String>();
                    Toaddress.clear();
                    system.debug('Toaddress 10 after clear'+Toaddress);
                    Toaddress.addAll(dealWithUserIds10Days.get(dealId));
                    system.debug('Toaddress 10'+Toaddress);
                    message = FBE_DealRegEmailUtility.ExpiryNotification_Partner(dealRegMap.get(dealId),Toaddress,owea.id);
                    messages.add(message);
                }
                if(dealWithUserIds0Days.containsKey(dealId)){
                    
                    list<String> Toaddress = new list<String>();
                    Toaddress.addAll(dealWithUserIds0Days.get(dealId));
                    system.debug('Toaddress 0'+Toaddress);
                    message = FBE_DealRegEmailUtility.ExpiryNotification_Partner(dealRegMap.get(dealId),Toaddress,owea.id);
                    messages.add(message);
                    Toaddress.clear();
                    system.debug('Toaddress 0 after clear'+Toaddress);
                }
            }
            system.debug('messages Size:'+messages.size());
            if(messages.size()>0){
                system.debug('messages'+messages);
             try{
                 system.debug('Am inside try');
                 Messaging.sendEmail(messages);
             }Catch(Exception e){
                 System.debug('exception'+e);
             }
         }
        }
    }
}