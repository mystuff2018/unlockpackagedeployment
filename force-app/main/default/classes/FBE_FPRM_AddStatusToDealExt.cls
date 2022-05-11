/**************
*@ Class Name                                                    : FBE_FPRM_AddStatusToDealExt
*@ Description                                                   : This class runs from Deal Extension Triggerwhich
sends emails to Deal Partner emails
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 04-15-2021 [Soumiithri Rekha]
*@ Modification Log                                              : 07-13-2021 [Saikumar - Commented the class and moved the logic to 'FBE_FPRM_DealExtnHandler']
***************/
public class FBE_FPRM_AddStatusToDealExt {    
    /*
    public static void updateEmailDealExt(List<Deal_Extension__c> dealExt, Map<id,Deal_Extension__c> dealExtold, boolean data){
        List<Deal_Extension__c> CreatedByIdList = [Select id,createdby.contactid from Deal_Extension__c where id in:dealExt];
        Map<id,id> CreatedByIdMap = new Map<id,id>();
        for(Deal_Extension__c dex :CreatedByIdList){
            CreatedByIdMap.put(dex.id,dex.createdby.contactid);
        }
        system.debug('Inside Trigger Extnsn Method:'+CreatedByIdMap);
        Set<Id> parentid = new Set<Id>();
        Map<id,List<id>> ApprovedDealExtn_DealId = new  Map<id,List<id>> ();
        Map<id,List<id>> RejectedDealExtn_DealId = new  Map<id,List<id>> ();
        FBE_FPRM_Notification_Switch__c cms = FBE_FPRM_Notification_Switch__c.getOrgDefaults();
        for(Deal_Extension__c de : dealExt){
            system.debug('newList'+ de.Createdby.Contactid);
            parentid.add(de.FBE_Deal_Registration__c);
            if(
                (((de.FBE_Extension_Request_Status__c == 'Approved' && de.FBE_Sequence_Number__c == 1 && data == false)||
                 (de.FBE_Extension_Request_Status__c == 'Approved' && dealExtold.get(de.id).FBE_Extension_Request_Status__c == 'Submitted' && data == true)) && 
                 cms.Send_Deal_Extn_Approval_Emails__c == true && cms.FBE_FPRM_Cut_Over_Switch__c== False && CreatedByIdMap.get(de.id)!= null) || 
                (((de.FBE_Extension_Request_Status__c == 'Approved' &&  de.FBE_Sequence_Number__c == 1 && data == false)||
                 (de.FBE_Extension_Request_Status__c == 'Approved' && dealExtold.get(de.id).FBE_Extension_Request_Status__c == 'Submitted' && data == true)) &&
                 cms.Send_Deal_Extn_Approval_Emails__c == true && cms.FBE_FPRM_Cut_Over_Switch__c== True)
            ){
                if(!ApprovedDealExtn_DealId.containsKey(de.FBE_Deal_Registration__c)){
                    ApprovedDealExtn_DealId.put(de.FBE_Deal_Registration__c,new List<id>{de.id});
                }
                else{
                    ApprovedDealExtn_DealId.get(de.FBE_Deal_Registration__c).add(de.id);
                }
            }
            if(
                (de.FBE_Extension_Request_Status__c == 'Rejected'&& dealExtold.get(de.id).FBE_Extension_Request_Status__c == 'Submitted' && data == true && cms.Send_Deal_Extn_Rejection_Emails__c == True && CreatedByIdMap.get(de.id) != null && cms.FBE_FPRM_Cut_Over_Switch__c== False)|| 
                (de.FBE_Extension_Request_Status__c == 'Rejected' && dealExtold.get(de.id).FBE_Extension_Request_Status__c == 'Submitted' && data == true && cms.Send_Deal_Extn_Rejection_Emails__c == True && cms.FBE_FPRM_Cut_Over_Switch__c== True)
            ){
                if(!RejectedDealExtn_DealId.containsKey(de.FBE_Deal_Registration__c)){
                    RejectedDealExtn_DealId.put(de.FBE_Deal_Registration__c,new List<id>{de.id});
                }
                else{
                    RejectedDealExtn_DealId.get(de.FBE_Deal_Registration__c).add(de.id);
                }
            }
            
        }
        system.debug('ApprovedDealExtn_DealId'+ApprovedDealExtn_DealId);
        system.debug('RejectedDealExtn_DealId'+RejectedDealExtn_DealId);
        set<String> nullcheckedEmailes = new set<string>();
        Map<id,set<String>> dealEmail = new  Map<id,set<String>> ();
        Map<id,Deal_Registration__c> dealRegDetails = new Map<id,Deal_Registration__c>([SELECT id,Name,Owner.name,FBE_Deal_Registration_Status__c,FBE_Decline_Comments__c,FBE_Declined_Reason__c,FBE_Expiration_Date__c,FBE_Analyst_Observations_History__c,Analyst_Observations__c,FBE_Deal_Reg_Num__c,FBE_Opportunity_Number__c,CreatedDate,FBE_Submission_Date__c,
                                                                                        FBE_Forecast_Amount__c,FBE_Deal_Submitter_Name__c,FBE_FPRM_Registration_Name__c,FBE_Deal_Justification_Statement__c,FBE_Book_Date__c, FBE_End_User_Account_Name__c,FBE_End_User_First_Name__c,FBE_End_User_Last_Name__c,
                                                                                        FBE_End_User_Mailing_Street__c,FBE_Partner_Owner_Email__c,FBE_End_User_Mailing_City__c,FBE_End_User_Mailing_State__c, FBE_End_User_Mailing_Zip__c,FBE_End_User_Mailing_Country__c,
                                                                                        FBE_End_User_Email__c,FBE_Opportunity_Num__c,FBE_Partner_Team_Mailbox__c,FBE_End_User_Phone__c,FBE_Reseller_VAR_Account__r.Name, FBE_Distributor_Account__r.Name,FBE_FSI_Account__r.Name,FBE_Partner_Sales_Rep_Name__c,
                                                                                        FBE_Partner_Sales_Rep_Email__c, FBE_End_User_Account__r.Name,FBE_Account__r.Name,
                                                                                        FBE_FPRM_Channel_Sales_Rep_Email__c,FBE_FPRM_Channel_Sales_Rep_Name__c,FBE_FPRM_Channel_Sales_Rep_Phone__c,
                                                                                        (Select FBE_Product__r.Name,FBE_Quantity__c,FBE_Line_Of_Business__c from Deal_Products__r)
                                                                                        FROM Deal_Registration__c where id in: parentid]);
        system.debug('dealRegDetails'+dealRegDetails);
        for(Deal_Registration__c deal : dealRegDetails.values()) {
            if(deal.FBE_Partner_Owner_Email__c != null){
                nullcheckedEmailes.add(deal.FBE_Partner_Owner_Email__c);
            }
            if(deal.FBE_Partner_Sales_Rep_Email__c != null){
                nullcheckedEmailes.add(deal.FBE_Partner_Sales_Rep_Email__c);
            }
            if(deal.FBE_Partner_Team_Mailbox__c != null){
                List<String> PartnerTeam = deal.FBE_Partner_Team_Mailbox__c.split(',');
                nullcheckedEmailes.addAll(PartnerTeam);
            }
            dealEmail.put(deal.id,nullcheckedEmailes);
        }
        system.debug('dealEmail'+dealEmail);
        Map<id,set<string>> approved_dealExtnEmails = new Map<id,set<string>> ();
        Map<id,set<string>> Rejected_dealExtnEmails = new Map<id,set<string>> ();
        for(id dealLoop: dealEmail.keyset()){
            if(!ApprovedDealExtn_DealId.isEmpty()){
                for(id apextn : ApprovedDealExtn_DealId.get(dealLoop)){
                    approved_dealExtnEmails.put(apextn, dealEmail.get(dealLoop));
                }
            }
            if(!RejectedDealExtn_DealId.isEmpty()){
                system.debug('am inside rejeted if');
                for(id apextns : RejectedDealExtn_DealId.get(dealLoop)){
                    Rejected_dealExtnEmails.put(apextns, dealEmail.get(dealLoop));
                }
            }
        }
        system.debug('approved_dealExtnEmails'+approved_dealExtnEmails);
        system.debug('Rejected_dealExtnEmails'+Rejected_dealExtnEmails);
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address =: System.label.FBE_Approval_OWD limit 1];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email;
        Messaging.SingleEmailMessage emails;
        List<EmailTemplate> templ = [Select Id,subject,Name,HtmlValue,Body,Markup from EmailTemplate where Name in ('FBE_FPRM_DealExtn_Approval','FBE_FPRM_DealExtn_Rejection') ORDER BY name asc];
        EmailTemplate et ;
        for(Deal_Extension__c dealextnId : dealExt){
            et = FBE_FPRM_DealExtnHandler.getExtEmailTemplate (dealRegDetails.get(dealextnId.FBE_Deal_Registration__c),templ[0],dealextnId);
            List<string> approvedEmailList = new List<string>();
            if(!approved_dealExtnEmails.isEmpty()){
                approvedEmailList.addAll(approved_dealExtnEmails.get(dealextnId.id));
                email = new Messaging.SingleEmailMessage();
                email.setOrgWideEmailAddressId(owea.Id);
                email.setHtmlBody(et.Markup);
                email.setSubject(et.subject);
                if(approved_dealExtnEmails.get(dealextnId.id) != null && approved_dealExtnEmails.get(dealextnId.id).size()>0){
                    email.setToAddresses(approvedEmailList);
                }
                emailList.add(email); 
                approvedEmailList.clear();
            }
        }
        for(Deal_Extension__c dealextnIds : dealExt){
            et = FBE_FPRM_DealExtnHandler.getExtEmailTemplate (dealRegDetails.get(dealextnIds.FBE_Deal_Registration__c),templ[1],dealextnIds);
            List<string> rejectedEmailList = new List<string>();
            if(!Rejected_dealExtnEmails.isEmpty()){
                rejectedEmailList.addAll(Rejected_dealExtnEmails.get(dealextnIds.id));
                emails = new Messaging.SingleEmailMessage();
                emails.setOrgWideEmailAddressId(owea.Id);
                emails.setHtmlBody(et.Markup);
                emails.setSubject(et.subject);
                if(Rejected_dealExtnEmails.get(dealextnIds.id) != null && Rejected_dealExtnEmails.get(dealextnIds.id).size()>0){
                    emails.setToAddresses(rejectedEmailList);
                }
                emailList.add(emails);
                rejectedEmailList.clear();
            }
        }
        system.debug('emailList size:'+emailList.size());
        if( emailList !=NULL && emailList.size()>0){
            try{
                Messaging.sendEmail(emailList);
            }Catch(Exception e){
                System.debug(e);
            }
        }
    }
    */
}