public with sharing class FBE_FPRM_DealHelper {
    public static Map<Id,List<String>> getChannelTeamEmails(Map<Id,Id> dealsWithChannelActId) {
        Map<Id,List<String>> actIdWithTeammembers = new Map<Id,List<String>>();
        Map<Id,List<String>> dealIdWithTeammembers = new Map<Id,List<String>>();
         String[] aesr = new String[]{'AE','SR'};
             
             List<id> dealsWithChannelActIdvalues = dealsWithChannelActId.values();
             String query='SELECT Id,AccountId,UserId,TeamMemberRole,user.email FROM AccountTeamMember WHERE AccountId IN :dealsWithChannelActIdvalues AND TeamMemberRole IN :aesr';
        for(AccountTeamMember atm : database.query(query)){
            if(!actIdWithTeammembers.containsKey(atm.AccountId)){
                actIdWithTeammembers.put(atm.AccountId, new List<String>{atm.user.email});
            }else{
                actIdWithTeammembers.get(atm.AccountId).add(atm.user.email);
            }
        }
        for(Id i : dealsWithChannelActId.keySet()){
            if(dealsWithChannelActId.get(i) != NULL && actIdWithTeammembers.containsKey(dealsWithChannelActId.get(i))){
                if(actIdWithTeammembers.get(dealsWithChannelActId.get(i)) != NULL){
                    dealIdWithTeammembers.put(i, actIdWithTeammembers.get(dealsWithChannelActId.get(i)));
                }   
            }
        }
        System.debug('dealIdWithTeammembers:  '+dealIdWithTeammembers);
        return dealIdWithTeammembers;
    }
    
    public static EmailTemplate getEmailTemplate(Deal_Registration__c dealObj , EmailTemplate emailtem ){
        EmailTemplate templ = emailtem;
        templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Deal_Reg_Num__c}' ,dealObj.FBE_Deal_Reg_Num__c);
        templ.Markup = templ.Markup.replace('{!relatedTo.Name}' ,dealObj.Name);
        
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
        templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Deal_Submitter_Name__c}' ,dealObj.FBE_Deal_Submitter_Name__c);
        
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
        if(dealObj.FBE_Declined_Reason__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Declined_Reason__c}', dealObj.FBE_Declined_Reason__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Declined_Reason__c}', '');
        if(dealObj.FBE_Decline_Comments__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Decline_Comments__c}', dealObj.FBE_Decline_Comments__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Decline_Comments__c}', '');
        
        if(dealObj.FBE_FPRM_Registration_Name__c != NULL && templ.Subject.contains('{!Deal_Registration__c.FBE_FPRM_Registration_Name__c}'))
            templ.subject = templ.subject.replace('{!Deal_Registration__c.FBE_FPRM_Registration_Name__c}' ,dealObj.Name);
        else
            templ.subject = templ.subject.replace('{!Deal_Registration__c.FBE_FPRM_Registration_Name__c}' ,'');
        
        if(dealObj.FBE_Expiration_Date__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Expiration_Date__c}', String.valueOf(dealObj.FBE_Expiration_Date__c));
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Expiration_Date__c}', '');
        
        Map<String,String> prdName = new Map<String,String>();
        Map<String,String> prdLob = new Map<String,String>();
        List<Deal_Product__c> lstprd = dealObj.Deal_Products__r;
        for(Deal_Product__c cont :lstprd)
        {
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
        String fullFileURL = System.label.FBE_FPRM_Partner_Full_URL+'/'+ dealObj.id;
        String recordURL  = '<a href='+fullFileURL+ '>' +'Federal Partner Relationship Management'+'</a>';
        templ.Markup = templ.Markup.replace('Federal Partner Relationship Management',recordURL);
        
        return templ;
    }
}