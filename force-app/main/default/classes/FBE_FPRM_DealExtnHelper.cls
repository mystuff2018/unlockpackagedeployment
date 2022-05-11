public class FBE_FPRM_DealExtnHelper {
    
    public static void notifyPartnerUsers(List<Deal_Extension__c> dealExtns , FBE_FPRM_Notification_Switch__c cms){
        List<Deal_Extension__c> eligibleExtnList = new List<Deal_Extension__c>();
        List<Deal_Extension__c> CreatedByIdList = new List<Deal_Extension__c>();
        Map<Id,Id> CreatedByIdMap = new Map<Id,Id>();
        if(dealExtns.size()>0){
            for(Deal_Extension__c dex : [SELECT id,createdby.contactid FROM Deal_Extension__c WHERE Id IN : dealExtns]){
                CreatedByIdMap.put(dex.id,dex.createdby.contactid);
            }
        }
        for(Deal_Extension__c dealExn: dealExtns){
            if((cms.FBE_FPRM_Cut_Over_Switch__c== False && CreatedByIdMap.get(dealExn.id)!= null) || cms.FBE_FPRM_Cut_Over_Switch__c== True ){ // to check for the Poilt Customers  OR Complete Switch
                eligibleExtnList.add(dealExn);
            }
        }
        Set<Id> parentids = new Set<Id>();
        Set<String> partnerEmails;
        Map<id,Set<String>> dealWithPartnerEmails = new  Map<id,Set<String>> ();
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address =: System.label.FBE_Approval_OWD limit 1];
        Map<Id,List<Id>> approveOrrejectExtn_DealId = new  Map<Id,List<Id>> ();
        for(Deal_Extension__c dealExtn : eligibleExtnList){
            parentids.add(dealExtn.FBE_Deal_Registration__c);
        }
        Map<id,Deal_Registration__c> dealRegDetails = new Map<id,Deal_Registration__c>([SELECT id,Name,Owner.name,FBE_Deal_Registration_Status__c,FBE_Decline_Comments__c,FBE_Declined_Reason__c,FBE_Expiration_Date__c,FBE_Analyst_Observations_History__c,Analyst_Observations__c,FBE_Deal_Reg_Num__c,FBE_Opportunity_Number__c,CreatedDate,FBE_Submission_Date__c,
                                                                                        FBE_Forecast_Amount__c,FBE_Deal_Submitter_Name__c,FBE_FPRM_Registration_Name__c,FBE_Deal_Justification_Statement__c,FBE_Book_Date__c, FBE_End_User_Account_Name__c,FBE_End_User_First_Name__c,FBE_End_User_Last_Name__c,
                                                                                        FBE_End_User_Mailing_Street__c,FBE_Partner_Owner_Email__c,FBE_End_User_Mailing_City__c,FBE_End_User_Mailing_State__c, FBE_End_User_Mailing_Zip__c,FBE_End_User_Mailing_Country__c,
                                                                                        FBE_End_User_Email__c,FBE_Opportunity_Num__c,FBE_Partner_Team_Mailbox__c,FBE_End_User_Phone__c,FBE_Reseller_VAR_Account__r.Name, FBE_Distributor_Account__r.Name,FBE_FSI_Account__r.Name,FBE_Partner_Sales_Rep_Name__c,
                                                                                        FBE_Partner_Sales_Rep_Email__c, FBE_End_User_Account__r.Name,FBE_Account__r.Name,
                                                                                        FBE_FPRM_Channel_Sales_Rep_Email__c,FBE_FPRM_Channel_Sales_Rep_Name__c,FBE_FPRM_Channel_Sales_Rep_Phone__c,
                                                                                        (Select FBE_Product__r.Name,FBE_Quantity__c,FBE_Line_Of_Business__c from Deal_Products__r)
                                                                                        FROM Deal_Registration__c where id in: parentids]);
        
        for(Deal_Registration__c deal : dealRegDetails.values()) {
            partnerEmails = new Set<string>();
            if(deal.FBE_Partner_Owner_Email__c != null){
                partnerEmails.add(deal.FBE_Partner_Owner_Email__c);
            }
            if(deal.FBE_Partner_Sales_Rep_Email__c != null){
                partnerEmails.add(deal.FBE_Partner_Sales_Rep_Email__c);
            }
            if(deal.FBE_Partner_Team_Mailbox__c != null){
                List<String> PartnerTeam = deal.FBE_Partner_Team_Mailbox__c.split(',');
                partnerEmails.addAll(PartnerTeam);
            }
            dealWithPartnerEmails.put(deal.id,partnerEmails);
        }
        system.debug('dealWithPartnerEmails'+dealWithPartnerEmails);
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email;
        List<EmailTemplate> templ = [Select Id,subject,Name,HtmlValue,Body,Markup from EmailTemplate where Name in ('FBE_FPRM_DealExtn_Approval','FBE_FPRM_DealExtn_Rejection') ORDER BY name asc];
        EmailTemplate et ;
        
        for(Deal_Extension__c dealEx : eligibleExtnList){
            if(dealEx.FBE_Extension_Request_Status__c == 'Approved' && dealRegDetails.containsKey(dealEx.FBE_Deal_Registration__c)){
                et = getExtEmailTemplate (dealRegDetails.get(dealEx.FBE_Deal_Registration__c),templ[0],dealEx);
            }
            if(dealEx.FBE_Extension_Request_Status__c == 'Rejected' && dealRegDetails.containsKey(dealEx.FBE_Deal_Registration__c)){
                et = getExtEmailTemplate (dealRegDetails.get(dealEx.FBE_Deal_Registration__c),templ[1],dealEx);
            }
            email = new Messaging.SingleEmailMessage();
            email.setOrgWideEmailAddressId(owea.Id);
            email.setHtmlBody(et.Markup);
            email.setSubject(et.subject);
            if(dealWithPartnerEmails.containsKey(dealEx.FBE_Deal_Registration__c)){
                List<String> toaddressList = new List<String>();
                toaddressList.addAll(dealWithPartnerEmails.get(dealEx.FBE_Deal_Registration__c));
                email.setToAddresses(toaddressList);                
            }
            emailList.add(email); 
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
   
    public static EmailTemplate getExtEmailTemplate(Deal_Registration__c dealObj , EmailTemplate emailtem, Deal_Extension__c dealexn){
        EmailTemplate templ = emailtem;
        templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Deal_Reg_Num__c}' ,dealObj.FBE_Deal_Reg_Num__c);
        templ.Markup = templ.Markup.replace('{!relatedTo.Name}' ,dealObj.Name);
        //templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Opportunity_Num__c}' ,dealObj.FBE_Opportunity_Number__c);
        
        if(dealObj.FBE_Opportunity_Number__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Opportunity_Number__c}', dealObj.FBE_Opportunity_Number__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Opportunity_Number__c}', '');
        if(dealObj.FBE_Opportunity_Num__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Opportunity_Num__c}', dealObj.FBE_Opportunity_Num__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Opportunity_Num__c}', '');
        
        templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Account__r.Name}' ,dealObj.FBE_Account__r.Name);
        templ.Markup = templ.Markup.replace('{!relatedTo.ID}' ,dealObj.Id);
        if(dealObj.FBE_Deal_Submitter_Name__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Deal_Submitter_Name__c}' ,dealObj.FBE_Deal_Submitter_Name__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Deal_Submitter_Name__c}', '');
        if(dealObj.FBE_FPRM_Channel_Sales_Rep_Email__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_FPRM_Channel_Sales_Rep_Email__c}', dealObj.FBE_FPRM_Channel_Sales_Rep_Email__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_FPRM_Channel_Sales_Rep_Email__c}', '');
        
        if(dealObj.FBE_FPRM_Channel_Sales_Rep_Name__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_FPRM_Channel_Sales_Rep_Name__c}', dealObj.FBE_FPRM_Channel_Sales_Rep_Name__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_FPRM_Channel_Sales_Rep_Name__c}', '');
        
        if(dealObj.FBE_FPRM_Channel_Sales_Rep_Phone__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_FPRM_Channel_Sales_Rep_Phone__c}', dealObj.FBE_FPRM_Channel_Sales_Rep_Phone__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_FPRM_Channel_Sales_Rep_Phone__c}', '');
              
        if(dealexn.FBE_Approval_Rejection_Reason__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Decline_Comments__c}', dealexn.FBE_Approval_Rejection_Reason__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Decline_Comments__c}', '');
        
        if(dealObj.FBE_FPRM_Registration_Name__c != NULL && templ.Subject.contains('{!Deal_Registration__c.FBE_FPRM_Registration_Name__c}'))
            templ.subject = templ.subject.replace('{!Deal_Registration__c.FBE_FPRM_Registration_Name__c}' ,dealObj.Name);
        else
            templ.subject = templ.subject.replace('{!Deal_Registration__c.FBE_FPRM_Registration_Name__c}' ,'');
        
        if(dealObj.FBE_Expiration_Date__c != NULL)
        {
            Datetime expDate = dealObj.FBE_Expiration_Date__c.addDays(60);
            String dateOutput = expDate.formatGMT('MM/dd/yyyy');
			templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Expiration_Date__c}', dateOutput);
        }
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Expiration_Date__c}', '');
               
        Map<String,String> prdName = new Map<String,String>();
        Map<String,String> prdLob = new Map<String,String>();
        List<Deal_Product__c> lstprd = dealObj.Deal_Products__r;
        for(Deal_Product__c cont :lstprd){
            prdName.put(cont.FBE_Product__r.Name+'<br/>',cont.FBE_Quantity__c+'<br/>');
            prdLob.put(cont.FBE_Product__r.Name+'<br/>',cont.FBE_Line_Of_Business__c+'<br/>'); 
        }
        templ.Markup = templ.Markup.replace('{!eachProduct.FBE_Product__r.Name}', JSON.serialize(prdName.Keyset()));
        templ.Markup = templ.Markup.replace('{!eachProduct.FBE_Line_Of_Business__c}', JSON.serialize(prdLob.Values()));
        templ.Markup = templ.Markup.replace('{!ROUND(eachProduct.FBE_Quantity__c,0)}', JSON.serialize(prdName.Values()));  
        templ.Markup = templ.Markup.replace('","','');
        templ.Markup = templ.Markup.replace('["','');
        templ.Markup = templ.Markup.replace('"]','');
        templ.Markup = templ.Markup.replace('\\"','"');
        
        //<apex:outputLink value="{!LEFT($Api.Partner_Server_URL_140,FIND('.com',$Api.Partner_Server_URL_140)+4)+led.Id}">{!led.FirstName} {!led.LastName}</apex:outputLink>
        
        //'{!LEFT($Api.Partner_Server_URL_140,FIND('.com',$Api.Partner_Server_URL_140)+4)'+dealObj.Id+'}';
        
        String fullFileURL = System.label.FBE_FPRM_Partner_Full_URL+'/'+ dealObj.id;
        String recordURL  = '<a href='+fullFileURL+ '>' +'Federal Partner Relationship Management'+'</a>';
        templ.Markup = templ.Markup.replace('Federal Partner Relationship Management',recordURL);
        
        return templ;
    }     
}