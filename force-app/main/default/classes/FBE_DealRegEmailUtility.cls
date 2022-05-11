/**************
*@ Class Name                                                    : FBE_DealRegEmailUtility
*@ Description                                                   : This is Utility class for all the DEal Expiration Notifications
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 05-15-2020 [Rakesh Reddy Mula]
*@ Modification Log                                              : 09-09-2020 [Rakesh Reddy Mula] Moved Messaging.SendEmail to FBE_DealExpiredNotificationsBatch
***************/

public class FBE_DealRegEmailUtility {
    
    public static Messaging.SingleEmailMessage TenDaysNotification(Deal_Registration__c DelReg,List<ID> userIds, Id orgWideEmailAddress) {           
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        String emailSubject = '10 Days Notice! - Your Approved Federal Registration is about to Expire';
        String emailTextBody = 'This is a reminder to let you know that the following federal registration associated to one of your Dell Technologies Federal accounts is due to expire in 10 days.' + '</br></br>' + 
            '<b>Registration #: </b>'+DelReg.FBE_Deal_Reg_Num__c + '</br>'+
            '<b>Registration Name: </b>'+DelReg.Name + '</br>' +
            '<b>Linked Opportunity #: </b>' +DelReg.FBE_Related_Opportunity__r.FBE_Opportunity_Number__c + '</br>' +
            '<b>Expiration Date: </b>'+(DelReg.FBE_Expiration_Date__c).month()+ '/' + (DelReg.FBE_Expiration_Date__c).day() + '/' + (DelReg.FBE_Expiration_Date__c).year() + '</br>' +
            '<b>Partner Account Name: </b>'+DelReg.FBE_Account__r.Name + '</br></br>' +
            'Please check with your Partner about the status of this registration and ask them to close the registration if it is no longer active.';         
        message.setOrgWideEmailAddressId(orgWideEmailAddress);
        message.setToAddresses(userIds);
        //message.setTargetObjectId(userId);
        message.setSaveAsActivity(false);
        message.setSubject(emailSubject);
        message.setHtmlBody(emailTextBody);
       // messages.add(message);
        
        return message;
    }
    
    public static Messaging.SingleEmailMessage ThirtyDaysNotification(Deal_Registration__c DelReg,List<ID> userIds,Id orgWideEmailAddress) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();      
        String emailSubject = '30 Days Notice! - Your Approved Federal Registration is about to Expire';
        String emailTextBody = 'This is a reminder to let you know that the following federal registration associated to one of your Dell Technologies Federal accounts is due to expire in 30 days.' + '</br></br>' + 
            '<b>Registration #: </b>'+DelReg.FBE_Deal_Reg_Num__c + '</br>'+
            '<b>Registration Name: </b>'+DelReg.Name + '</br>' +
            '<b>Linked Opportunity #: </b>' +DelReg.FBE_Related_Opportunity__r.FBE_Opportunity_Number__c + '</br>' +
            '<b>Expiration Date: </b>'+(DelReg.FBE_Expiration_Date__c).month()+ '/' + (DelReg.FBE_Expiration_Date__c).day() + '/' + (DelReg.FBE_Expiration_Date__c).year() + '</br>' +
            '<b>Partner Account Name: </b>'+DelReg.FBE_Account__r.Name + '</br></br>' +
            'Please check with your Partner about the status of this registration and ask them to close the registration if it is no longer active.';         
        message.setOrgWideEmailAddressId(orgWideEmailAddress);
        message.setToAddresses(userIds);
        //message.setTargetObjectId(userId);
        message.setSaveAsActivity(false);
        message.setSubject(emailSubject);
        message.setHtmlBody(emailTextBody);
        //messages.add(message);
        
        return message;

    }
    
    public static Messaging.SingleEmailMessage ExpiryNotification(Deal_Registration__c DelReg,List<ID> userIds,Id orgWideEmailAddress) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        String emailSubject = 'Final Notice! Your Approved Federal Registration is Expired';
        String emailTextBody = 'The following deal associated to one of your accounts has expired and subsequently cancelled.' + '</br>' + 
            'Registration Number: '+DelReg.FBE_Deal_Reg_Num__c + '</br>'+
            'Opportunity Name: ' +DelReg.FBE_Related_Opportunity__r.Name + '</br>' +
            'Sales Stage: ' +DelReg.Sales_Stage__c + '</br>' +
            'Partner Account Name: '+DelReg.FBE_Account__r.Name + '</br></br>' +
            'To view this record, please click the following link:'+'</br>' +
            system.URL.getSalesforceBaseUrl().toExternalForm()+'/'+DelReg.Id + '</br>'+
            'Please review the deal and take appropriate action. ';         
        message.setOrgWideEmailAddressId(orgWideEmailAddress);
        message.setToAddresses(userIds);
        //message.setTargetObjectId(userId);
        message.setSaveAsActivity(false);
        message.setSubject(emailSubject);
        message.setHtmlBody(emailTextBody);
        //messages.add(message);
        
        return message;
    } 
        public static Messaging.SingleEmailMessage ExpiryNotification_Partner(Deal_Registration__c DelReg,List<String> userIds,Id orgWideEmailAddress) {
        system.debug('userIds'+userIds);
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            String fullFileURL = System.label.FBE_FPRM_Partner_Full_URL+'/'+ DelReg.id;
            String recordURL  = '<a href='+fullFileURL+ '>' +'Federal Partner Relationship Management'+'</a>';
            
        String emailSubject = 'A Reminder that your Approved Federal Registration is about to Expire';
        String emailTextBody = '<b>'+DelReg.FBE_Partner_Owner__c+',</b></br></br>'+
            'This is a reminder to let you know that the following federal registration associated to one of your Dell Technologies Federal accounts is due to expire.'+'</br></br>'+
            '<b>Registration #:</b> '+DelReg.FBE_Deal_Reg_Num__c + '</br>'+
            '<b>Opportunity Name:</b> ' +DelReg.FBE_Related_Opportunity__r.Name + '</br>' +
            '<b>Opportunity #: </b>' +DelReg.FBE_FPRM_Opportunity__c + '</br>' +
            '<b>Expiration Date :</b>'+DelReg.FBE_Expiration_Date__c + '</br>' +
            '<b>Partner Account Name:</b> '+DelReg.FBE_Account__r.Name + '</br></br>' +
            'If this registration is still active, you may request a renewal via the registration page in the ' +
            //system.URL.getSalesforceBaseUrl().toExternalForm()+'/'+DelReg.Id +' Registrations that have progressed into quoting are eligible for extension. '+'</br></br>'+
             recordURL +' Registrations that have progressed into quoting are eligible for extension. '+'</br></br>'+
            'If this registration is no longer active, please close the registration as appropriate.'+'<br/>'+
			'Contact your Channel Inside Sales Representative should need further assistance.'+'</br></br>'+
            'Thank you for choosing Dell Technologies!'+'</br></br></br>'+
            'Dell Technologies Federal Deal Registration Portal'+'</br>'+
			'Terms and conditions apply. Please see your Partner Portal for details.';         
        message.setOrgWideEmailAddressId(orgWideEmailAddress);
        message.setToAddresses(userIds);
        //message.setTargetObjectId(userId);
        message.setSaveAsActivity(false);
        message.setSubject(emailSubject);
        message.setHtmlBody(emailTextBody);
        //messages.add(message);
        system.debug('message'+message);
        return message;
    } 
    
}