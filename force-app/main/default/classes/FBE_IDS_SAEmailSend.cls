/**************
 *@ Class Name        : FBE_IDS_SAEmailSend
 *@ Description       : This class is written to send email for Service Appointment events.
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 08-20-2020
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script - Feature #7946971.
 ***************/
public class FBE_IDS_SAEmailSend {
	
    //Email send for Resource Schedule Confirmation. This is triggered from process builder - FF Process on Service Appointment
    @InvocableMethod(label = 'Send Resource Confirmation Email when SA is Dispatched to Assigned Resources')
    public static void sendResourceConfirmationEmail(List<ServiceAppointment> saList){
        List<EmailTemplate> etList = [SELECT Id,
                                      Subject,
                                      Description,
                                      HtmlValue,
                                      DeveloperName,
                                      Body 
                                      FROM EmailTemplate 
                                      WHERE DeveloperName = 'FBE_IDS_Resource_Confirmation_AR'
                                     LIMIT 1];
        //System.debug('Email template: '+etList);
        List<Messaging.SingleEmailMessage> emailMsgList = new List<Messaging.SingleEmailMessage>();
        
        List<IDS_Email_Setting__mdt> emailSettings = [SELECT Id, DeveloperName, MasterLabel, Send_Email__c
                                                      FROM IDS_Email_Setting__mdt
                                                     WHERE DeveloperName= 'Resource_Schedule_Confirmation'
                                                     LIMIT 1];       
        Set<Id> saIds = new Set<Id>();
		String currentUserEmail = UserInfo.getUserEmail();
        List<String> ccAddresses = new List<String>();
        
        for(ServiceAppointment eachSA : saList){
            saIds.add(eachSA.Id);            
        }
        System.debug('ccAddresses: '+ccAddresses);
        List<AssignedResource> saAssignedResourceList = [SELECT Id,
                                                         ServiceResourceId,
                                                         ServiceResource.RelatedRecordId,
                                                         ServiceResource.RelatedRecord.Email,
                                                         ServiceAppointment.Project__r.pse__Project_Manager__r.Email
                                                         FROM AssignedResource
                                                         WHERE ServiceAppointmentId IN :saIds];
         System.debug('AssignedResource List: '+saAssignedResourceList);   
        
        if(!emailSettings.isEmpty()){
            if(emailSettings[0].Send_Email__c){
                if(etList != null && saAssignedResourceList != null){
                    for(AssignedResource eachResource : saAssignedResourceList){
                        String templateId = string.valueOf(etList[0].id);
                        String userId = string.valueOf(eachResource.ServiceResource.RelatedRecordId);
                        String whatId = string.valueOf(eachResource.id);
                        ccAddresses.add(currentUserEmail);
                        if(eachResource.ServiceAppointment.Project__r.pse__Project_Manager__r.Email != null){
                            ccAddresses.add(eachResource.ServiceAppointment.Project__r.pse__Project_Manager__r.Email);
                        }
                        //System.debug('Template Id: '+ templateId);
                        //System.debug('User Id: ' +userId);
                        //System.debug('What Id: ' +whatId);
                        //System.debug('User Email Id: '+eachResource.ServiceResource.RelatedRecord.Email);
                        
                        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(templateId,userId,whatId);           
                        String emailSubject = message.getSubject();
                        String emailTextBody = message.getHtmlBody();
                        //System.debug('Email Subject: '+emailSubject);
                        //System.debug('Email Text Body: '+emailTextBody);
                        
                        message.setTemplateId(templateId);
                        message.setTargetObjectId(userId);
                        message.setSaveAsActivity(false);
                        message.setCcAddresses(ccAddresses);
                        
                        emailMsgList.add(message);
                        ccAddresses.clear();
                    }
                    
                    try {
                        if(emailMsgList.size() > 0){
                            Messaging.sendEmail(emailMsgList);
                        }
                        
                    } 
                    catch(DMLException e) {
                        System.debug(e);
                    }
                }
                
                else
                {
                    System.debug('Email template for Resource Confirmation or Assigned Resources do not exist.');
                }
            }
        }
        else{
            System.debug('Email settings custom metadata record was not found for - Resource Schedule Confirmation');
        }
    }
}