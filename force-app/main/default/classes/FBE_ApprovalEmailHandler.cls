/**************
* @ClassName    : FBE_ApprovalEmailHandler
* @Trigger       : FBE_ApprovalEmailHandler
* @Description   : This class is called from Handler=FBE_DealReg_ApproveDealsHandler. In this class,we retun updated template with merge fields
* @CreatedBy     : DeLL Team
* @CreatedOn     : 12-13-2019 [Soumithri Rekha, Sai]
* @UpdatedOn     : 04-08-2021 [Siva - Defect #10441994]
* @UpdatedOn     : 06-21-2021 [Siva - Defect #10580424]
***************/
public class FBE_ApprovalEmailHandler {
    public static EmailTemplate getEmailTemplate(Deal_Registration__c dealObj , EmailTemplate etemplate){
        EmailTemplate templ = etemplate;
        String fo = dealObj.FBE_Analyst_Observations_History__c;               
        if(fo != '' && fo != null){
            templ.Markup = templ.Markup.replace('<b>Registration reviewer observations</b>:', '<b>Registration reviewer observations</b>: '+fo);
        }else{
            templ.Markup = templ.Markup.replace('<b>Registration reviewer observations</b>:', '');
        }
        templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Deal_Reg_Num__c}', dealObj.FBE_Deal_Reg_Num__c);
        templ.Markup = templ.Markup.replace('{!relatedTo.Name}',dealObj.Name);
        if(dealObj.FBE_Opportunity_Number__c != NULL)
        templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Opportunity_Number__c}', dealObj.FBE_Opportunity_Number__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Opportunity_Number__c}','');
           
        // defect #10580424  
        if(dealObj.FBE_Deal_Createddate__c != NULL){
           templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Deal_Createddate__c}',dealObj.FBE_Deal_Createddate__c);
       }
       if(dealObj.FBE_Formatted_Book_Date__c != NULL){
           templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Formatted_Book_Date__c}',dealObj.FBE_Formatted_Book_Date__c);
           }
        if(dealObj.FBE_Formatted_Submission_Date__c != NULL){
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Formatted_Submission_Date__c}',dealObj.FBE_Formatted_Submission_Date__c); 
        }
        templ.Markup = templ.Markup.replace('{!relatedTo.CreatedDate}', String.valueOf(dealObj.CreatedDate.format()));
        templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Submission_Date__c}', String.valueOf(dealObj.FBE_Submission_Date__c.format()));
        templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Forecast_Amount__c}', String.valueOf(dealObj.FBE_Forecast_Amount__c));
        templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Deal_Justification_Statement__c}', dealObj.FBE_Deal_Justification_Statement__c);
        templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Book_Date__c}', String.valueOf(dealObj.FBE_Book_Date__c));
        if(dealObj.FBE_End_User_Account_Name__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_Account_Name__c}', dealObj.FBE_End_User_Account_Name__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_Account_Name__c}', '');
        if(dealObj.FBE_End_User_First_Name__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_First_Name__c}', dealObj.FBE_End_User_First_Name__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_First_Name__c}', '');
        if(dealObj.FBE_End_User_Last_Name__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_Last_Name__c}', dealObj.FBE_End_User_Last_Name__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_Last_Name__c}', '');
        if(dealObj.FBE_End_User_Mailing_Street__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_Mailing_Street__c}', dealObj.FBE_End_User_Mailing_Street__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_Mailing_Street__c}', '');
        if(dealObj.FBE_End_User_Mailing_City__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_Mailing_City__c}', dealObj.FBE_End_User_Mailing_City__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_Mailing_City__c}', '');
        if(dealObj.FBE_End_User_Mailing_State__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_Mailing_State__c}', dealObj.FBE_End_User_Mailing_State__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_Mailing_State__c}', '');
        if(dealObj.FBE_End_User_Mailing_Zip__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_Mailing_Zip__c}', dealObj.FBE_End_User_Mailing_Zip__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_Mailing_Zip__c}', '');
        if(dealObj.FBE_End_User_Mailing_Country__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_Mailing_Country__c}', dealObj.FBE_End_User_Mailing_Country__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_Mailing_Country__c}', '');
        if(dealObj.FBE_End_User_Email__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_Email__c}', dealObj.FBE_End_User_Email__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_Email__c}', '');
        if(dealObj.FBE_End_User_Phone__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_Phone__c}', dealObj.FBE_End_User_Phone__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_End_User_Phone__c}', '');
        if(dealObj.FBE_Reseller_VAR_Account__r.Name != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Reseller_VAR_Account__r.Name}', dealObj.FBE_Reseller_VAR_Account__r.Name);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Reseller_VAR_Account__r.Name}', '');
        if(dealObj.FBE_Distributor_Account__r.Name != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Distributor_Account__r.Name}', dealObj.FBE_Distributor_Account__r.Name);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Distributor_Account__r.Name}', '');
        if(dealObj.FBE_FSI_Account__r.Name != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_FSI_Account__r.Name}', dealObj.FBE_FSI_Account__r.Name);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_FSI_Account__r.Name}', '');
        if(dealObj.FBE_Partner_Sales_Rep_Name__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Partner_Sales_Rep_Name__c}', dealObj.FBE_Partner_Sales_Rep_Name__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Partner_Sales_Rep_Name__c}', '');
        if(dealObj.FBE_Partner_Sales_Rep_Email__c != NULL)
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Partner_Sales_Rep_Email__c}', dealObj.FBE_Partner_Sales_Rep_Email__c);
        else
            templ.Markup = templ.Markup.replace('{!relatedTo.FBE_Partner_Sales_Rep_Email__c}', '');
        
        Map<String,String> prdName = new Map<String,String>();
        List<Deal_Product__c> lstprd = dealObj.Deal_Products__r;
        for(Deal_Product__c cont :lstprd)
        {
            prdName.put(cont.FBE_Product__r.Name+'<br/>',cont.FBE_Quantity__c+'<br/>');
        }
        templ.Markup = templ.Markup.replace('{!eachProduct.FBE_Product__r.Name}', JSON.serialize(prdName.Keyset()));
        templ.Markup = templ.Markup.replace('{!ROUND(eachProduct.FBE_Quantity__c,0)}', JSON.serialize(prdName.Values()));
        templ.Markup = templ.Markup.replace('","','');
        templ.Markup = templ.Markup.replace('["','');
        templ.Markup = templ.Markup.replace('"]','');
        
        
        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ dealObj.id;
        String recordURL  = '<a href='+fullFileURL+' >'+dealObj.name+'</a>';
        templ.Markup = templ.Markup.replace('Click the URL to access the Deal:','Click the URL to access the Deal: ' + recordURL);
        
        //templ.Markup = templ.Markup.replaceAll('Click the URL to access the Deal:','Click the URL to access the Deal: ' + URL.getSalesforceBaseUrl().toExternalForm() +'/' + dealObj.id);
        system.debug('templ.Markup #####'+templ.Markup);
        //system.debug('templ#####'+templ);
        return templ;
    }

    public static String getEmailSubject(Deal_Registration__c dealObj , String s){
        String subject = s;
        
        if(dealObj.FBE_Deal_Reg_Num__c != NULL) subject = subject + 'Deal Reg Num: ' + dealObj.FBE_Deal_Reg_Num__c + '; ';
            else subject = subject + 'Deal Reg Num: ' +  '; ';
            
            if(dealObj.FBE_End_User_Account__r.Name != NULL) subject = subject + 'End User Account Name: ' + dealObj.FBE_End_User_Account__r.Name + '; ';
            else subject = subject + 'End User Account Name: ' +  '; ';
            
            if(dealObj.FBE_Reseller_VAR_Account__r.Name != NULL) subject = subject + 'Reseller Account Name: ' + dealObj.FBE_Reseller_VAR_Account__r.Name + '; ';
            else subject = subject + 'Reseller Account Name: ' +  '; ';
            
            if(dealObj.FBE_Distributor_Account__r.Name != NULL) subject = subject + 'Distributor Account Name: ' + dealObj.FBE_Distributor_Account__r.Name + '; ';
            else subject = subject + 'Distributor Account Name: ' +  '; ';
            
            if(dealObj.FBE_FSI_Account__r.Name != NULL) subject = subject + 'FSI Account Name: ' + dealObj.FBE_FSI_Account__r.Name + '; ';
            else subject = subject + 'FSI Account Name: ' +  '; ';
        system.debug('subject #####'+subject);
        return subject;
    }  
    // defect #10580424
     public static String getformattedDatetime(Datetime Deal_datetime){
             String date_time_format='M/d/yyyy h:mm a';
             Datetime date_time = Deal_datetime;
             Timezone tz = Timezone.getTimeZone(Label.Deal_Email_Time_Zone); //Gets value from Custom Label such as CST.
             String timezoneId = tz.getID();
             String timeZoneName = tz.getDisplayName();
                
                
            String dt = date_time.format(date_time_format,timezoneId);
            String formatteddatetime = dt + ' - ' + timeZoneName.substring(11);
            System.debug('formatteddatetime: '+formatteddatetime);
            return formatteddatetime;
     
    } 
    
    public static String getApprovalLink(Id dealId, String team){
        List<ProcessInstance> processInstances = [select Id,Status from ProcessInstance  where TargetObjectId =: dealId and status = 'Pending'];
        Set<Id> processIds = new Set<Id>();
        for(ProcessInstance pI : processInstances){
            processIds.add(pI.Id);
        }
        List<ProcessInstanceWorkitem> workItemList = [select id, Actor.name, OriginalActor.name from ProcessInstanceWorkitem where ProcessInstanceId in : processIds];
        String approvalLink = '';
        for(ProcessInstanceWorkitem workItem : workItemList){
            if(workItem.Actor.name.contains(team) ){
                approvalLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+workItem.Id;
            }            
        }
        return approvalLink;        
    }
    
    
    public static EmailTemplate getDealExtEmailTemplate(Deal_Extension__c dealExt , EmailTemplate etemplate){
        EmailTemplate templ = etemplate;
        templ.Markup = templ.Markup.replace('<b>Deal Extension #:</b>', '<b>Deal Extension #:</b> ' + dealExt.Name);
        templ.Markup = templ.Markup.replace('<b>Request #:</b>', '<b>Request #:</b> ' + dealExt.FBE_Sequence_Number__c.intValue());
        String dateOutput = getformattedDatetime(dealExt.CreatedDate);
        //String dateOutput = dealExt.CreatedDate.format('MM/dd/yyyy HH:mm a', 'CST');
        templ.Markup = templ.Markup.replace('<b>Deal Extension Created Date/Time:</b>', '<b>Deal Extension Created Date/Time:</b> ' + dateOutput);

        String reason = dealExt.FBE_Extension_Request_Reason__c != null ? dealExt.FBE_Extension_Request_Reason__c : '';
        templ.Markup = templ.Markup.replace('<b>Extension Request Reason: </b>', '<b>Extension Request Reason: </b> ' + reason);        
        return templ;
    }
}