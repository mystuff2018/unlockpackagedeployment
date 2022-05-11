public without sharing class SiebelSRUpdate {
    private Siebel_Update_SR__mdt parameters {
        get{
            if (parameters != null) return parameters;
            parameters = Siebel_Update_SR__mdt.getInstance('Default');
            return parameters;
        }
        private set;
    }

    private Boolean retryMechanism = false;

    public siebelComSractivity.FBE_spcOSC_spcSR_spcActivity_spcWF_Output_element updateSR(Id caseId) {
        Case caseRecord = getCase(caseID);
        if(caseRecord.EmailMessages == null || caseRecord.EmailMessages.isEmpty()) return null;

        List<EmailMessage> listEmailMessages = getEmailMessagesPendingToSync(caseRecord.EmailMessages);
        if(listEmailMessages.isEmpty()) return null;

        retryMechanism = true;

        return updateSRFromEmailMessage(caseRecord, listEmailMessages);
    }

    public List<EmailMessage> getEmailMessagesPendingToSync(List<EmailMessage> listEmailMessages){
        List<EmailMessage> listEmailMessagesPendingToSync = new List<EmailMessage>();
        for(EmailMessage emailRecord : listEmailMessages){
            if(emailRecord.Siebel_Sync_Status__c != 'Synced to Siebel'){
                listEmailMessagesPendingToSync.add(emailRecord);
            }
        }
        return listEmailMessagesPendingToSync;
    }

    @future (callout=true)
    public static void updateSRFromEmailMessage(Id emailRecordId) {
        SiebelSRUpdate siebelUpdateService = new SiebelSRUpdate();
        List<EmailMessage> listEmailMessages = new List<EmailMessage>{siebelUpdateService.getEmailRecord(emailRecordId)};
        Case caseRecord = siebelUpdateService.getCase(listEmailMessages[0].ParentId);
        siebelUpdateService.updateSRFromEmailMessage(caseRecord, listEmailMessages);
    }

    public siebelComSractivity.FBE_spcOSC_spcSR_spcActivity_spcWF_Output_element updateSRFromEmailMessage(Case caseRecord, List<EmailMessage> listEmailMessages) {
        wwwSiebelComXmlFbeservicerequestact.ListOfFbeServiceRequestIo request;
        siebelComSractivity.FBE_spcOSC_spcSR_spcActivity_spcWF_Output_element response;

        try {
            request = getRequestHeaderList(caseRecord, listEmailMessages);
            response = sendRequest(request);

            setEmailSyncStatus(response, listEmailMessages);

            logTransaction(request, response);
        } catch (Exception e) {
            createLogRecord(true,  e.getMessage() + ' - ' + e.getStackTraceString());
        }

        return response;
    }

    private siebelComSractivity.FBE_spcOSC_spcSR_spcActivity_spcWF_Output_element sendRequest(
        wwwSiebelComXmlFbeservicerequestact.ListOfFbeServiceRequestIo request){

        siebelComSractivity.FBE_spcOSC_spcSR_spcActivity_spcWF activityService = 
            getActivityService();

        return activityService.FBE_spcOSC_spcSR_spcActivity_spcWF(request);
    }

    public Case getCase(Id caseId){
        return [
            SELECT Description,Origin,Service_Tag__c,Contact.Email,
            SR_Number__c, 
                (SELECT Id,Textbody,FromAddress,ToAddress,Subject,
                    Incoming,Siebel_Sync_Status__c,ParentId 
                FROM EmailMessages ORDER BY CreatedDate DESC)
            FROM Case 
            WHERE Id =: caseId
            LIMIT 1
        ][0];
    }

    public EmailMessage getEmailRecord(Id emailRecordId){
        return [
            SELECT FromAddress, ToAddress, Subject, Textbody, Incoming, ParentId
            FROM EmailMessage 
            WHERE Id =: emailRecordId
            LIMIT 1
        ][0];
    }

    private wwwSiebelComXmlFbeservicerequestact.ListOfFbeAction getListOfActions(Case caseRecord, List<EmailMessage> listEmailMessages){
        List<wwwSiebelComXmlFbeservicerequestact.FbeAction> fbeActionList =
                new List<wwwSiebelComXmlFbeservicerequestact.FbeAction>();

        for(EmailMessage emailMessageRecord : listEmailMessages){
            wwwSiebelComXmlFbeservicerequestact.FbeAction action = 
            new wwwSiebelComXmlFbeservicerequestact.FbeAction();

            String activityUID = emailMessageRecord.Id;
            String fbeAgentNote = getCaseEmailBodyFromEmailMessage(emailMessageRecord);
            String actionType = getActionTypeFromEmailMessage(emailMessageRecord);

            action.ActivityUID = activityUID;
            action.Category = parameters.Action_Category__c;
            action.FBEAgentNote = fbeAgentNote;
            action.FBEServiceTagNumber = caseRecord.Service_Tag__c;
            action.SRNumber = caseRecord.SR_Number__c;
            action.Status = parameters.Action_Status__c;
            action.Type_x = actionType;
            action.Operation = parameters.Action_Operation__c;

            fbeActionList.add(action);
        }
        
        wwwSiebelComXmlFbeservicerequestact.ListOfFbeAction listOfFbeAction = 
                new wwwSiebelComXmlFbeservicerequestact.ListOfFbeAction();

        listOfFbeAction.FbeAction = fbeActionList;

        return listOfFbeAction;
    }

    private String getActionTypeFromEmailMessage(EmailMessage emailRecord){
        if(emailRecord.Incoming){
            return ServiceConstants.SR_ACTION_TYPE_EMAIL_INBOUND;
        } else {
            return ServiceConstants.SR_ACTION_TYPE_EMAIL_OUTBOUND;
        }

	} 

    private String getCaseEmailBodyFromEmailMessage(EmailMessage emailRecord){
        String emailBody = '';

        emailBody += 'From: ' + emailRecord.FromAddress + '\n';
        emailBody += 'To: ' + emailRecord.ToAddress + '\n';
        emailBody += 'Subject: ' + emailRecord.Subject + '\n';
        emailBody += 'Message: ' + emailRecord.Textbody + '\n';

        if (emailBody.length() > 2000) emailBody = emailBody.substring(0,2000);
        return emailBody;
    }

    private siebelComSractivity.FBE_spcOSC_spcSR_spcActivity_spcWF getActivityService(){
        siebelComSractivity.FBE_spcOSC_spcSR_spcActivity_spcWF activityService = 
            new siebelComSractivity.FBE_spcOSC_spcSR_spcActivity_spcWF();
        activityService.timeout_x = 120000;
        activityService.endpoint_x = parameters.Endpoint_URL__c;
        return activityService;
    }

    private wwwSiebelComXmlFbeservicerequestact.ListOfFbeServiceRequestIo getRequestHeaderList(Case caseRecord, List<EmailMessage> listEmailMessages){
        wwwSiebelComXmlFbeservicerequestact.FbeServiceRequest requestObject = 
        new wwwSiebelComXmlFbeservicerequestact.FbeServiceRequest();

        requestObject.SRNumber = caseRecord.SR_Number__c;
        requestObject.Operation = parameters.Request_Operation__c;
        requestObject.ListOfFbeAction = getListOfActions(caseRecord, listEmailMessages);

        List<wwwSiebelComXmlFbeservicerequestact.FbeServiceRequest> requestHeaderList = 
                new List<wwwSiebelComXmlFbeservicerequestact.FbeServiceRequest>{requestObject};
                
        wwwSiebelComXmlFbeservicerequestact.ListOfFbeServiceRequestIo request = 
                new wwwSiebelComXmlFbeservicerequestact.ListOfFbeServiceRequestIo();
        request.FbeServiceRequest = requestHeaderList;

        return request;
    }

    private void logTransaction(
        wwwSiebelComXmlFbeservicerequestact.ListOfFbeServiceRequestIo request,
        siebelComSractivity.FBE_spcOSC_spcSR_spcActivity_spcWF_Output_element response
    ){
        if (parameters.Log_transations__c == 'None') return;

        String message = String.format('Request: {0}\n\n\nResponse: {1}', new List<Object>{request, response});

        if (isSuccess(response) && parameters.Log_transations__c == 'All'){
            createLogRecord(false, message);
        } else {
            createLogRecord(true, message);
        }
    }

    private Boolean isSuccess(siebelComSractivity.FBE_spcOSC_spcSR_spcActivity_spcWF_Output_element response){
        if(response.SiebelErrorMessage == 'Created OSC Activities Successfully'){
            return true;
        }

        return false;
    }

    private void createLogRecord(Boolean apiFailure, String message){
        insert new ExceptionLogger__c(
            API_Failure__c = apiFailure,
            API_PayLoad__c = message,
            Module__c = 'Siebel SR Update',
            Apex_Class__c = 'SiebelSRupdate',
            External_System_Name__c = 'Siebel',
            Method_Name__c = 'srUpdate'
        );
    }

    private void setEmailSyncStatus(
        siebelComSractivity.FBE_spcOSC_spcSR_spcActivity_spcWF_Output_element response, 
        List<EmailMessage> listEmailMessages
    ){
        List<EmailMessage> emailMessagesToUpdate = new List<EmailMessage>();
        Boolean syncedSuccess = isSuccess(response);

        for(EmailMessage emailMessageRecord : listEmailMessages){
            EmailMessage emailUpdated = new EmailMessage(Id = emailMessageRecord.Id);
            if(syncedSuccess){
                emailUpdated.Siebel_Sync_Status__c = ServiceConstants.EMAIL_MESSAGE_SYNCED_TO_SIEBEL;
            } else {
                emailUpdated.Siebel_Sync_Status__c = ServiceConstants.EMAIL_MESSAGE_FAILED;
            }

            emailMessagesToUpdate.add(emailUpdated);
        }
        
        if(!syncedSuccess){
            ServiceCaseHandler.skipCaseTrigger = true;
            update new Case(Id = listEmailMessages[0].ParentId, Siebel_Pending_to_Sync__c = true);    
        }

        if(retryMechanism && syncedSuccess){
            ServiceCaseHandler.skipCaseTrigger = true;
            update new Case(Id = listEmailMessages[0].ParentId, Siebel_Pending_to_Sync__c = false);  
        }

        update emailMessagesToUpdate;
    }
}