public class FBE_FPRM_RejectionController {
    @AuraEnabled
    public static void notifyEmail(List<Id> dealIds){
        FBE_FPRM_Notification_Switch__c cms = FBE_FPRM_Notification_Switch__c.getOrgDefaults();
        Map<Id,List<String>> approveorRejectDeals = new Map<Id,List<String>>();
        Map<Id,Id> dealsWithDistiAccount = new Map<Id,Id>();
        Map<Id,Id> dealsWithResellerAccount = new Map<Id,Id>();
        List<String> prmProfiles = System.Label.FBE_FPRM_Profiles.split(';');
        Boolean isFPRMUser = FeatureManagement.checkPermission('FBE_FPRM_Skip_Process_Builder');
        
        String dealQuery='SELECT Id,FBE_Deal_Registration_Status__c,FBE_Declined_Reason__c,FBE_Decline_Comments__c,FBE_Deal_Submitter_Email_Phone__c,FBE_Partner_Owner_Email__c,FBE_Partner_Team_Mailbox__c,FBE_Same_as_submitter__c,FBE_Partner_Sales_Rep_Email__c,FBE_Distributor_Account__c,FBE_Reseller_VAR_Account__c,FBE_Related_Opportunity__c,CreatedBy.contactId FROM Deal_Registration__c WHERE Id IN : dealIds';
        
        System.debug('DealQuery'+database.query(dealQuery));
        
        for(Deal_Registration__c newdeal : database.query(dealQuery))
        {
            if((newdeal.CreatedBy.contactId!= null && cms.FBE_FPRM_Cut_Over_Switch__c == False)|| (cms.FBE_FPRM_Cut_Over_Switch__c == True))
            {
                
                if(newdeal.FBE_Deal_Registration_Status__c == 'Rejected' && cms.Send_Deal_Rejection_Emails__c ==true){
                    { 
                        approveorRejectDeals.put(newDeal.Id, new List<String>());
                    }
                    
                    if(newdeal.FBE_Partner_Owner_Email__c != null){ 
                        approveorRejectDeals.get(newDeal.ID).add(newdeal.FBE_Partner_Owner_Email__c);
                    }
                    if(newdeal.FBE_Partner_Team_Mailbox__c != null){
                        approveorRejectDeals.get(newDeal.ID).addAll(newdeal.FBE_Partner_Team_Mailbox__c.split(','));
                    }
                    if(newdeal.FBE_Same_as_submitter__c == 'No' && newdeal.FBE_Partner_Sales_Rep_Email__c != null)
                    {
                        approveorRejectDeals.get(newDeal.ID).add(newdeal.FBE_Partner_Sales_Rep_Email__c);
                    }
                    if(newdeal.FBE_Distributor_Account__c != null){
                        dealsWithDistiAccount.put(newdeal.Id, newdeal.FBE_Distributor_Account__c);
                    }
                    if(newdeal.FBE_Reseller_VAR_Account__c != null){
                        dealsWithResellerAccount.put(newdeal.Id, newdeal.FBE_Reseller_VAR_Account__c);
                    }
                }
            }
        }
        if(!approveorRejectDeals.isEmpty()){
            SendDealEmails(approveorRejectDeals,FBE_FPRM_DealHelper.getChannelTeamEmails(dealsWithDistiAccount), FBE_FPRM_DealHelper.getChannelTeamEmails(dealsWithResellerAccount));
        }
        
    }
    
    public static void SendDealEmails(Map<id,List<String>> dealIdwithEmails ,Map<Id,List<String>> dealWithDistyTeam , Map<Id,List<String>> dealWithResellerTeam) {
        
        set<id> dealIdwithEmailsList = dealIdwithEmails.keySet();
        
        String dealQuery = 'SELECT id,Name,Owner.name,FBE_Deal_Registration_Status__c,FBE_Opportunity_Num__c,FBE_FPRM_Registration_Name__c,FBE_Expiration_Date__c,FBE_Decline_Comments__c,FBE_Declined_Reason__c,FBE_Deal_Submitter_Name__c,FBE_Analyst_Observations_History__c,Analyst_Observations__c,FBE_Deal_Reg_Num__c,FBE_Opportunity_Number__c,CreatedDate,FBE_Submission_Date__c,'+
            'FBE_Forecast_Amount__c,FBE_Deal_Justification_Statement__c,FBE_Book_Date__c, FBE_End_User_Account_Name__c,FBE_End_User_First_Name__c,FBE_End_User_Last_Name__c,'+
            'FBE_End_User_Mailing_Street__c,FBE_End_User_Mailing_City__c,FBE_End_User_Mailing_State__c, FBE_End_User_Mailing_Zip__c,FBE_End_User_Mailing_Country__c,'+
            'FBE_End_User_Email__c,FBE_End_User_Phone__c,FBE_Reseller_VAR_Account__r.Name, FBE_Distributor_Account__r.Name,FBE_FSI_Account__r.Name,FBE_Partner_Sales_Rep_Name__c,'+
            'FBE_Partner_Sales_Rep_Email__c, FBE_End_User_Account__r.Name,FBE_Account__r.Name,'+
            'FBE_FPRM_Channel_Sales_Rep_Email__c,FBE_FPRM_Channel_Sales_Rep_Name__c,FBE_FPRM_Channel_Sales_Rep_Phone__c,'+
            '(Select FBE_Product__r.Name,FBE_Quantity__c,FBE_Line_Of_Business__c from Deal_Products__r)'+
            'FROM Deal_Registration__c WHERE Id IN :dealIdwithEmailsList';
        Map<Id,Deal_Registration__c> dealMap = new Map<Id, Deal_Registration__c>((List<Deal_Registration__c>)database.query(dealQuery));
        
        string applabel = System.label.FBE_Approval_OWD;
        string orgowd = 'select Id from OrgWideEmailAddress where Address =:applabel  limit 1';
        OrgWideEmailAddress owea = database.query(orgowd);
        
        EmailTemplate tempList = [SELECT Id,Name,subject,HtmlValue,Body,Markup FROM EmailTemplate WHERE Name ='FBE_FPRM_Deal_Declined_Template'];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email;
        List<String> ccList = new List<String>();
        for(Id dealId : dealIdwithEmailsList){
            email = new Messaging.SingleEmailMessage();
            email.setOrgWideEmailAddressId(owea.Id);
            EmailTemplate et ;
            if(dealMap.get(dealId).FBE_Deal_Registration_Status__c =='Rejected'){
                et = FBE_FPRM_DealHelper.getEmailTemplate (dealMap.get(dealId),tempList);
            }
            email.setHtmlBody(et.Markup);
            email.setSubject(et.subject);
            
            if(dealIdwithEmails.get(dealId) != null && dealIdwithEmails.get(dealId).size()>0){
                email.setToAddresses(dealIdwithEmails.get(dealId));
            }
            if(dealWithDistyTeam != null && dealWithDistyTeam.containsKey(dealId)){
                if(dealWithDistyTeam.get(dealId) != null && dealWithDistyTeam.get(dealId).size()>0){
                    ccList.addAll(dealWithDistyTeam.get(dealId));
                }
            }
            if(dealWithResellerTeam !=null && dealWithResellerTeam.containsKey(dealId)){
                if(dealWithResellerTeam.get(dealId) != null && dealWithResellerTeam.get(dealId).size()>0){
                    ccList.addAll(dealWithResellerTeam.get(dealId));
                }
            }
            if(ccList.size() >0){
                email.setCcAddresses(ccList);
            }
            emailList.add(email);
        }
        if( emailList !=NULL && emailList.size()>0){
            try{
                Messaging.sendEmail(emailList);
            }Catch(Exception e){
                System.debug('Exception while notifying the parnters '+e);
            }
        }
    }
}