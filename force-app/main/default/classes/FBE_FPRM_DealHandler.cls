/*
 * Modification log: Sireesha Myla May 13th 2021 - Story#10382458
 * */

public without sharing class FBE_FPRM_DealHandler {
    //Added the method as part of Stroy# 9911968 
    public static void checkDealthresholdAmount(List<Deal_Registration__c> newList, Map<Id, Deal_Registration__c> oldMap){
        String minThreshold = System.Label.FBE_FPRM_DealReg_Minimum_Threshold_Amount;
        List<String> prmProfiles = System.Label.FBE_FPRM_Profiles.split(';');
        Boolean isFPRMUser = FeatureManagement.checkPermission('FBE_FPRM_Skip_Process_Builder');
        for(Deal_Registration__c newdeal : newList){
            if(newdeal.FBE_Deal_Registration_Status__c == 'Submitted' && oldMap.get(newdeal.Id).FBE_Deal_Registration_Status__c != 'Submitted' && 
               newdeal.FBE_Forecast_Amount__c < decimal.valueOf(minThreshold.replaceAll(',', '')) && isFPRMUser == true){
                   newdeal.addError('Expected revenue of the deal is below the $'+minThreshold+' threshold for deal registration submission. Please update the deal to continue.');
               }
        }
    }
    
    
     //Added the method as part of DEFECT# 12036280
    public static void rejectionFromUI(List<Deal_Registration__c> newList, Map<Id, Deal_Registration__c> oldMap){
        
        
        List<Id> dealid=new List<Id>();
        for(Deal_Registration__c newdeal : newList){
            if(newdeal.FBE_Deal_Registration_Status__c == 'Rejected' && newdeal.FBE_Deal_Registration_Status__c != oldMap.get(newdeal.Id).FBE_Deal_Registration_Status__c 
               && newdeal.FBE_PMO_Substatus__c != 'PMO Approved' && newdeal.FBE_PMO_Substatus__c !='PMO Rejected'){
                 dealid.add(newdeal.Id);  
               }
        }
        if(dealid.size()>0){
            FBE_FPRM_RejectionController.notifyEmail(dealid);
        }
    }
    
    public static void updateDeclinedComments(List<Deal_Registration__c> newList, Map<Id, Deal_Registration__c> oldMap){
        for(Deal_Registration__c newdeal : newList){
            if( oldMap.get(newdeal.Id).FBE_Deal_Registration_Status__c == 'Rejected' && newdeal.FBE_Deal_Registration_Status__c != oldMap.get(newdeal.Id).FBE_Deal_Registration_Status__c){
                newdeal.FBE_Decline_Comments__c = '';
            }
            if(newdeal.FBE_Deal_Registration_Status__c != 'Rejected' && newdeal.FBE_Deal_Registration_Status__c != oldMap.get(newdeal.Id).FBE_Deal_Registration_Status__c){
                newdeal.FBE_Declined_Reason__c = null;
            }
        }
    }   
    
    @InvocableMethod
    public static void notifyParnterUsers(List<Id> dealIds){
         FBE_FPRM_Notification_Switch__c cms = FBE_FPRM_Notification_Switch__c.getOrgDefaults();
        Map<Id,List<String>> submittedDeals = new Map<Id,List<String>>();
        Map<Id,List<String>> approveorRejectDeals = new Map<Id,List<String>>();
        Map<Id,Id> dealsWithDistiAccount = new Map<Id,Id>();
        Map<Id,Id> dealsWithResellerAccount = new Map<Id,Id>();
        List<String> prmProfiles = System.Label.FBE_FPRM_Profiles.split(';');
        Boolean isFPRMUser = FeatureManagement.checkPermission('FBE_FPRM_Skip_Process_Builder');
        
        for(Deal_Registration__c newdeal : [SELECT Id,FBE_Deal_Registration_Status__c,FBE_Deal_Submitter_Email_Phone__c,FBE_Partner_Owner_Email__c,FBE_Partner_Team_Mailbox__c,FBE_Same_as_submitter__c,FBE_Partner_Sales_Rep_Email__c
                    ,FBE_Distributor_Account__c,FBE_Reseller_VAR_Account__c,FBE_Related_Opportunity__c,CreatedBy.contactId FROM Deal_Registration__c WHERE Id IN : dealIds]){
                       
                        System.debug('Deal Cutover switch: ' + cms.FBE_FPRM_Cut_Over_Switch__c);
                        System.debug('PRM User: ' + isFPRMUser);
                        System.debug('approval switch: ' + cms.Send_Deal_Approval_Emails__c);
                        System.debug('approval switch: ' + cms.Send_Deal_Approval_Emails__c);
                        System.debug('Rejected switch: ' + cms.Send_Deal_Rejection_Emails__c);
                        System.debug('Submitted Switch : ' + cms.Send_Deal_Submission_Emails__c);
                        System.debug('Deal Created by' + newdeal.CreatedBy.contactId);
            if((newdeal.CreatedBy.contactId!= null && cms.FBE_FPRM_Cut_Over_Switch__c == False)|| (cms.FBE_FPRM_Cut_Over_Switch__c == True)){
                 System.debug('inside Approve/Reject : status : ' + newdeal.FBE_Deal_Registration_Status__c);
            if((newdeal.FBE_Deal_Registration_Status__c == 'Approved' && cms.Send_Deal_Approval_Emails__c==true)|| (newdeal.FBE_Deal_Registration_Status__c == 'Rejected' && cms.Send_Deal_Rejection_Emails__c ==true)){
                 System.debug('inside Approve/Reject : status : ' + newdeal.FBE_Deal_Registration_Status__c);
                approveorRejectDeals.put(newDeal.Id, new List<String>());
                if(newdeal.FBE_Partner_Owner_Email__c != null) approveorRejectDeals.get(newDeal.ID).add(newdeal.FBE_Partner_Owner_Email__c);
                if(newdeal.FBE_Partner_Team_Mailbox__c != null) approveorRejectDeals.get(newDeal.ID).addAll(newdeal.FBE_Partner_Team_Mailbox__c.split(','));
                if(newdeal.FBE_Same_as_submitter__c == 'No' && newdeal.FBE_Partner_Sales_Rep_Email__c != null) approveorRejectDeals.get(newDeal.ID).add(newdeal.FBE_Partner_Sales_Rep_Email__c);
                if(newdeal.FBE_Distributor_Account__c != null){
                    dealsWithDistiAccount.put(newdeal.Id, newdeal.FBE_Distributor_Account__c);
                }
                if(newdeal.FBE_Reseller_VAR_Account__c != null){
                    dealsWithResellerAccount.put(newdeal.Id, newdeal.FBE_Reseller_VAR_Account__c);
                }
            }
            
            if(newdeal.FBE_Deal_Registration_Status__c == 'Submitted' && cms.Send_Deal_Submission_Emails__c ==true){
                 System.debug('inside Submitted : status : ' + newdeal.FBE_Deal_Registration_Status__c);
                submittedDeals.put(newDeal.Id, new List<String>());
                if(newdeal.FBE_Deal_Submitter_Email_Phone__c != null) submittedDeals.get(newDeal.ID).add(newdeal.FBE_Deal_Submitter_Email_Phone__c);
                if(newdeal.FBE_Partner_Owner_Email__c != null) submittedDeals.get(newDeal.ID).add(newdeal.FBE_Partner_Owner_Email__c);
                if(newdeal.FBE_Partner_Team_Mailbox__c != null) submittedDeals.get(newDeal.ID).addAll(newdeal.FBE_Partner_Team_Mailbox__c.split(','));
                if(newdeal.FBE_Same_as_submitter__c == 'No' && newdeal.FBE_Partner_Sales_Rep_Email__c != null) submittedDeals.get(newDeal.ID).add(newdeal.FBE_Partner_Sales_Rep_Email__c);
            }
                    }}
        if(!approveorRejectDeals.isEmpty()){
            SendDealEmails(approveorRejectDeals,FBE_FPRM_DealHelper.getChannelTeamEmails(dealsWithDistiAccount), FBE_FPRM_DealHelper.getChannelTeamEmails(dealsWithResellerAccount));
        }
        if(!submittedDeals.isEmpty()){
            SendDealEmails(submittedDeals, null,null);
        }
    }
    
    public static void SendDealEmails(Map<id,List<String>> dealIdwithEmails ,Map<Id,List<String>> dealWithDistyTeam , Map<Id,List<String>> dealWithResellerTeam) {
        
        Map<Id,Deal_Registration__c> dealMap = new Map<Id, Deal_Registration__c>([SELECT id,Name,Owner.name,FBE_Deal_Registration_Status__c,FBE_Opportunity_Num__c,FBE_Expiration_Date__c,FBE_Decline_Comments__c,FBE_Declined_Reason__c,FBE_Deal_Submitter_Name__c,FBE_FPRM_Registration_Name__c,FBE_Analyst_Observations_History__c,Analyst_Observations__c,FBE_Deal_Reg_Num__c,FBE_Opportunity_Number__c,CreatedDate,FBE_Submission_Date__c,
                                                                                  FBE_Forecast_Amount__c,FBE_Deal_Justification_Statement__c,FBE_Book_Date__c, FBE_End_User_Account_Name__c,FBE_End_User_First_Name__c,FBE_End_User_Last_Name__c,
                                                                                  FBE_End_User_Mailing_Street__c,FBE_End_User_Mailing_City__c,FBE_End_User_Mailing_State__c, FBE_End_User_Mailing_Zip__c,FBE_End_User_Mailing_Country__c,
                                                                                  FBE_End_User_Email__c,FBE_End_User_Phone__c,FBE_Reseller_VAR_Account__r.Name, FBE_Distributor_Account__r.Name,FBE_FSI_Account__r.Name,FBE_Partner_Sales_Rep_Name__c,
                                                                                  FBE_Partner_Sales_Rep_Email__c, FBE_End_User_Account__r.Name,FBE_Account__r.Name,
                                                                                  FBE_FPRM_Channel_Sales_Rep_Email__c,FBE_FPRM_Channel_Sales_Rep_Name__c,FBE_FPRM_Channel_Sales_Rep_Phone__c,
                                                                                  (Select FBE_Product__r.Name,FBE_Quantity__c,FBE_Line_Of_Business__c from Deal_Products__r)
                                                                                  FROM Deal_Registration__c WHERE Id IN :dealIdwithEmails.keySet()]);
        
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address =: System.label.FBE_Approval_OWD limit 1];
        List<EmailTemplate> tempList = [SELECT Id,Name,subject,HtmlValue,Body,Markup FROM EmailTemplate WHERE Name IN ('FBE_FPRM_Deal_Approval_Template','FBE_FPRM_Deal_Submission_Template','FBE_FPRM_Deal_Declined_Template')  ORDER BY name asc];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email;
        List<String> ccList = new List<String>();
        for(Id dealId : dealIdwithEmails.keySet()){
            email = new Messaging.SingleEmailMessage();
            email.setOrgWideEmailAddressId(owea.Id);
            EmailTemplate et ;
            if(dealMap.get(dealId).FBE_Deal_Registration_Status__c == 'Approved'){
                et = FBE_FPRM_DealHelper.getEmailTemplate (dealMap.get(dealId),tempList[0] );
            }
            if(dealMap.get(dealId).FBE_Deal_Registration_Status__c =='Rejected'){
                et = FBE_FPRM_DealHelper.getEmailTemplate (dealMap.get(dealId),tempList[1]);
            }
            if(dealMap.get(dealId).FBE_Deal_Registration_Status__c =='Submitted'){
                System.debug('inside submit-3');
                et = FBE_FPRM_DealHelper.getEmailTemplate (dealMap.get(dealId),tempList[2]);
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
                System.debug('Partners are notified Successfully');
            }Catch(Exception e){
                System.debug('Exception while notifying the parnters '+e);
            }
        }
    }
    
    
    // Added for My Opty Role Visibility
    public static void shareDealRecordWithPartnerUser(List<Deal_Registration__c> lstDeals,Map<Id,Deal_Registration__c> Oldmap){
        Set<Deal_Registration__Share> toShareDealReg = new Set<Deal_Registration__Share>();
        if(Oldmap != null && !Oldmap.isEmpty()){
            set<Id>  setUserIDs = new set<Id>();
            //Remove record sharing logic 
            for(Deal_Registration__c newDealReg: lstDeals){
                Deal_Registration__c oldDealReg = Oldmap.get(newDealReg.Id);
                if(oldDealReg.FBE_FPRM_Partner_Owner__c != newDealReg.FBE_FPRM_Partner_Owner__c
                   && oldDealReg.FBE_FPRM_Partner_Owner__c != null){
                       setUserIDs.add(oldDealReg.FBE_FPRM_Partner_Owner__c);                    
                   }
                if(oldDealReg.FBE_FPRM_Partner_Sales_Rep__c != newDealReg.FBE_FPRM_Partner_Sales_Rep__c
                   && oldDealReg.FBE_FPRM_Partner_Sales_Rep__c != null){
                       setUserIDs.add(oldDealReg.FBE_FPRM_Partner_Sales_Rep__c); 
                   }
            }                
            /**	for(Deal_Registration__c dr: Oldmap.values()){
            if(dr.FBE_FPRM_Partner_Owner__c != null){
            setUserIDs.add(dr.FBE_FPRM_Partner_Owner__c);
            }
            if(dr.FBE_FPRM_Partner_Sales_Rep__c != null){
            setUserIDs.add(dr.FBE_FPRM_Partner_Sales_Rep__c);
            }                           
            } **/
            if(setUserIDs !=null && !setUserIDs.isEmpty()){
                List<Deal_Registration__Share> lstDealShare = [SELECT Id,ParentId FROM Deal_Registration__Share 
                                                               WHERE ParentId IN : Oldmap.keyset() 
                                                               AND UserOrGroupId IN : setUserIDs 
                                                               AND RowCause = 'PRM_Record_Sharing__c'];  
                
                if(!lstDealShare.isEmpty()){
                    Database.delete(lstDealShare, false);
                }
            }
        } 
        //Assign record sharing logic
        set<Id>  setUserIDs = new set<Id>();
        if(lstDeals != null && !lstDeals.isEmpty()){
            for(Deal_Registration__c newDealReg: lstDeals){
                
                if(newDealReg.FBE_FPRM_Partner_Owner__c != null){
                    setUserIDs.add(newDealReg.FBE_FPRM_Partner_Owner__c);
                }
                if(newDealReg.FBE_FPRM_Partner_Sales_Rep__c != null){
                    setUserIDs.add(newDealReg.FBE_FPRM_Partner_Sales_Rep__c);
                }
            } 
        }
        
        if (setUserIDs !=null && !setUserIDs.isEmpty()){
            System.debug('JSK-1');
            Map<Id,User> mapPartnerUser = new Map<Id, User>([SELECT Id,FBE_FPRM_OnlineRole__c FROM User WHERE Id IN:setUserIDs 
                                                             AND (FBE_FPRM_OnlineRole__c = 'Disty Managed Sales Rep My Opty' OR 
                                                                  FBE_FPRM_OnlineRole__c ='Sales Rep My Opty')]);
            
            
            if(!mapPartnerUser.isEmpty()){
                for(Deal_Registration__c dr: lstDeals){
                    System.debug('JSK-2');
                    if(dr.FBE_FPRM_Partner_Owner__c != null && mapPartnerUser.ContainsKey(dr.FBE_FPRM_Partner_Owner__c)){
                        Deal_Registration__Share drShare = new Deal_Registration__Share();
                        drShare.ParentId = dr.Id;
                        drShare.UserOrGroupId = dr.FBE_FPRM_Partner_Owner__c;
                        drShare.AccessLevel ='Edit';
                        drShare.RowCause = 'PRM_Record_Sharing__c';
                        toShareDealReg.add(drShare);
                    }
                    if(dr.FBE_FPRM_Partner_Sales_Rep__c != null &&  mapPartnerUser.ContainsKey(dr.FBE_FPRM_Partner_Sales_Rep__c)){
                        System.debug('JSK-3');
                        Deal_Registration__Share drShare = new Deal_Registration__Share();
                        drShare.ParentId = dr.Id;
                        drShare.UserOrGroupId = dr.FBE_FPRM_Partner_Sales_Rep__c;
                        drShare.AccessLevel ='Edit';
                        drShare.RowCause = 'PRM_Record_Sharing__c';
                        toShareDealReg.add(drShare);
                    }
                }
            }
        }
        List<Deal_Registration__Share> dealRegShareList = new List<Deal_Registration__Share>(toShareDealReg);
        System.debug('JSK-4 : dealRegShareList count '+ dealRegShareList.size());
        System.debug('JSK-5 : dealRegShareList: '+ dealRegShareList);
        if(!toShareDealReg.isEmpty()){
            Database.SaveResult[] result = Database.insert(dealRegShareList, false);
            System.debug('result==='+result);
        }
        
    }
    
    //Populate Partner Owner and Sales Rep Lookup field for Share record with My Opty User
    public static void populateLookupsBasedOnEmail(List<Deal_Registration__c> lstDeals, User currentUser, Boolean isUpdate){
        
        //get the set of partner owner Sales Rep email 
        set<String> setEmailIDs = new set<String>();
        for(Deal_Registration__c dr: lstDeals){
            if(dr.FBE_Partner_Owner_Email__c != null && (currentUser.ContactId == null || isUpdate == true) ){
                setEmailIDs.add(dr.FBE_Partner_Owner_Email__c);
            }
            if(dr.FBE_Partner_Sales_Rep_Email__c != null){
                setEmailIDs.add(dr.FBE_Partner_Sales_Rep_Email__c);
            }
        }
        system.debug('setEmailIDs==' + setEmailIDs);
        //Map of users against emailId
        Map<String,List<User>> mapEmailIdUser = new Map<String,List<User>>();
        for(User usr : [SELECT Id,Name,Email,FBE_FPRM_OnlineRole__c FROM User WHERE Email IN:setEmailIDs 
                        AND ContactId <> Null and IsActive = True])
        {
            if(mapEmailIdUser.containsKey(usr.Email)){
                mapEmailIdUser.get(usr.Email).add(usr);
            }
            else{
                mapEmailIdUser.put(usr.Email,new List<User> { usr });
            }
        }
        
        for(Deal_Registration__c objDR : lstDeals){
            //Populate Partner Owner Lookup
            if(objDR.FBE_Partner_Owner_Email__c != null && (currentUser.ContactId == null || isUpdate == true) && mapEmailIdUser.containsKey(objDR.FBE_Partner_Owner_Email__c)){
                if(mapEmailIdUser.get(objDR.FBE_Partner_Owner_Email__c).size() > 1){
                    for(User usr : mapEmailIdUser.get(objDR.FBE_Partner_Owner_Email__c)){
                        //if(usr.Name.toLowercase() == objDR.FBE_Partner_Owner__c.toLowercase()){
                        if(usr.Name.equalsIgnoreCase(objDR.FBE_Partner_Owner__c)){       
                            objDR.FBE_FPRM_Partner_Owner__c = usr.Id;
                        }
                    }
                }
                else{
                    objDR.FBE_FPRM_Partner_Owner__c = mapEmailIdUser.get(objDR.FBE_Partner_Owner_Email__c)[0].Id;
                }
            }  
            //Populate Partner Sales Rep Lookup
            if(objDR.FBE_Partner_Sales_Rep_Email__c != null && mapEmailIdUser.containsKey(objDR.FBE_Partner_Sales_Rep_Email__c)){
                if(mapEmailIdUser.get(objDR.FBE_Partner_Sales_Rep_Email__c).size() > 1){
                    for(User usr : mapEmailIdUser.get(objDR.FBE_Partner_Sales_Rep_Email__c)){
                        //if(usr.Name.toLowercase() == objDR.FBE_Partner_Sales_Rep_Name__c.toLowercase()){
                        if(usr.Name.equalsIgnoreCase(objDR.FBE_Partner_Sales_Rep_Name__c)){   
                            objDR.FBE_FPRM_Partner_Sales_Rep__c = usr.Id;
                        }
                    }
                }
                else{
                    objDR.FBE_FPRM_Partner_Sales_Rep__c = mapEmailIdUser.get(objDR.FBE_Partner_Sales_Rep_Email__c)[0].Id;
                }
            }   
        }
        
    }
     
    public static void changeDefaultPartnerOwner(List<Deal_Registration__c> lstDeals){
        
        List<Deal_Registration__c> lstDealReg = new List<Deal_Registration__c>();
        User usr = [Select Id,Name,ContactId,Email from User where Id =: UserInfo.getUserId() limit 1];
        if(usr.ContactId != null){
            User defaultPartnerOwner = [SELECT Id,Name FROM User WHERE CommunityNickname = 'dell_partner_default_user' LIMIT 1]; 
            for(Deal_Registration__c deal : lstDeals){
                Deal_Registration__c dr = new Deal_Registration__c(Id = deal.Id,OwnerId = defaultPartnerOwner.Id);
                lstDealReg.add(dr);
            }
        }
        if(!lstDealReg.isEmpty()){
            Database.update(lstDealReg,false); 
        }
        
    }
    //Added by Sireesha Myla - Story#10382458
    public static void populateEU(Map<Id,Deal_Registration__c> newRecords, Map<Id,Deal_Registration__c> oldRecords)
    {
        Map<Id, End_User_Account__c> EUAccountsMap;
        Set<Id>euAccIds = new Set<Id>();
        for(Deal_Registration__c newdeal: newRecords.values())
        {
            if(newdeal.FBE_Deal_Registration_Status__c=='Submitted' && newdeal.FBE_Deal_Registration_Status__c!= oldRecords.get(newdeal.id).FBE_Deal_Registration_Status__c)
            {
                euAccIds.add(newdeal.FBE_FRPM_End_User_Account__c);
            }
            
        }
        if(euAccIds.size()>0)
        EUAccountsMap = new Map<Id,End_User_Account__c>([select Id,Master_Account__c from End_User_Account__c where Id in:euAccIds AND Master_Account__c !=null]);
        
        if(EUAccountsMap != null)
        {
           for(Deal_Registration__c deal: newRecords.values())
            {
                if( EUAccountsMap.containsKey(deal.FBE_FRPM_End_User_Account__c)) 
                {
                    deal.FBE_End_User_Account__c = EUAccountsMap.get(deal.FBE_FRPM_End_User_Account__c).Master_Account__c;
                    system.debug('EU populated &&&'+deal.FBE_End_User_Account__c);
                }
            } 
        }
    }
    
}