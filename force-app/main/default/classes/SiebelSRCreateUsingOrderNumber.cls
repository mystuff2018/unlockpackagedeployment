public class SiebelSRCreateUsingOrderNumber {
    
    private Siebel_Create_SR__mdt parameters {
        get{
            if (parameters != null) return parameters;
            parameters = Siebel_Create_SR__mdt.getInstance('OrderNumber');
            
            return parameters;
        }
        private set;
    }
    
    public federalServicesSoaCreateUpdateSR.SalesOrderSR_Output_element srCreate(Id caseID){
        Case caseRecord = getCase(caseID);

        return srCreate(caseRecord);
    }

    public Case getCase(Id caseId){
        return [
            SELECT Description,Subject,Origin,Service_Tag__c,Contact.Email,
                Contact.FirstName,Contact.LastName,Contact.Primary_Phone__c, Order_Number__c,
                (SELECT Id, Body FROM LiveChatTranscripts),
                (SELECT Id,Textbody,FromAddress,ToAddress,Subject,Incoming FROM EmailMessages ORDER BY CreatedDate DESC)
            FROM Case 
            WHERE Id =: caseId
            LIMIT 1
        ][0];   
    }

    public federalServicesSoaCreateUpdateSR.SalesOrderSR_Output_element srCreate(Case caseRecord){
        
        federalServicesSoaCreateUpdateSR.ListOfFbeOscSalesOrderSrIo request = getRequest(caseRecord);
        
        federalServicesSoaCreateUpdateSR.SalesOrderSR_Output_element response = sendRequest(request);
        setEmailMessagesSynced(caseRecord,response);
        logTransaction(request, response);

        return response;
    }

    private void logTransaction(federalServicesSoaCreateUpdateSR.ListOfFbeOscSalesOrderSrIo request,
    federalServicesSoaCreateUpdateSR.SalesOrderSR_Output_element response
    ){
        if (parameters.Log_transations__c == 'None') return;

        String message = String.format('Request: {0}\n\n\nResponse: {1}', new List<Object>{request, response});
        if(isSuccess(response)){
            if (parameters.Log_transations__c == 'All'){
                createLogRecord(false, message);
            }
            
        } else {
            createLogRecord(true, message);
        }
    }

    private void createLogRecord(Boolean apiFailure, String message){
        insert new ExceptionLogger__c(
            API_Failure__c = apiFailure,
            API_PayLoad__c = message,
            Module__c = 'Siebel SR Create',
            Apex_Class__c = 'SiebelSRCreate',
            External_System_Name__c = 'Siebel',
            Method_Name__c = 'srCreate'
        );
    }

    private Boolean isSuccess(federalServicesSoaCreateUpdateSR.SalesOrderSR_Output_element response){
        if(String.isBlank(response.Error_spcCode) && String.isNotBlank(response.SRNumber)) {
            return true;
        }
        return false;
    }

    public String getUUID(){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,20);

        return guid;
    }

    private federalServicesSoaCreateUpdateSR.ListOfFbeOscSalesOrderSrIo getRequest(Case caseRecord){
        federalServicesSoaCreateUpdateSR.ListOfFbeOscSalesOrderSrIo request = 
            new federalServicesSoaCreateUpdateSR.ListOfFbeOscSalesOrderSrIo();

        federalServicesSoaCreateUpdateSR.FbeTdServiceRequest fbeServicerequest = getFbeRequest(caseRecord);
        request.FbeTdServiceRequest = new List<federalServicesSoaCreateUpdateSR.FbeTdServiceRequest>{fbeServicerequest};
        return request;
    }

    private federalServicesSoaCreateUpdateSR.FbeTdServiceRequest getFbeRequest(Case caseRecord){
        federalServicesSoaCreateUpdateSR.FbeTdServiceRequest fbeServiceRequest = 
            new federalServicesSoaCreateUpdateSR.FbeTdServiceRequest();

        fbeServiceRequest.Abstract_x = caseRecord.Subject;
        fbeServiceRequest.IntegrationId = getUUID();
        fbeServiceRequest.Owner = parameters.Request_Owner__c;
        fbeServiceRequest.SRType = parameters.Request_SR_Type__c;
        fbeServiceRequest.Source = getSource(caseRecord);
        fbeServiceRequest.Status = parameters.Request_Status__c;
        fbeServiceRequest.FBEOrderNum = caseRecord.Order_Number__c;
        fbeServiceRequest.Operation = parameters.Request_Operation__c;

        federalServicesSoaCreateUpdateSR.ListOfFbeTdAction listOfAction = getListOfAction(caseRecord); 
        fbeServicerequest.ListOfFbeTdAction = listOfAction;
        
        federalServicesSoaCreateUpdateSR.ListOfFbeOscContact listOfContacts = getListOfContacts(caseRecord.Contact);
        fbeServicerequest.ListOfFbeOscContact = listOfContacts;

        return fbeServicerequest;
    }

    private String getSource(Case caseRecord){
        if(caseRecord.Origin == ServiceConstants.CASE_ORIGIN_CHAT){
            return ServiceConstants.CASE_ORIGIN_CHAT;
        } else {
            return ServiceConstants.CASE_ORIGIN_EMAIL;
        }
    }

    private federalServicesSoaCreateUpdateSR.ListOfFbeTdAction getListOfAction(Case caseRecord){
        federalServicesSoaCreateUpdateSR.ListOfFbeTdAction listOfAction = new federalServicesSoaCreateUpdateSR.ListOfFbeTdAction();
        listOfAction.FbeTdAction = new List<federalServicesSoaCreateUpdateSR.FbeTdAction>();

        List<federalServicesSoaCreateUpdateSR.FbeTdAction> listEmailActions = getListEmailActions(caseRecord);
        listOfAction.FbeTdAction.addAll(listEmailActions);
        
        if(caseRecord.Origin != ServiceConstants.CASE_ORIGIN_EMAIL && caseRecord.Origin != ServiceConstants.CASE_ORIGIN_CHAT){
            federalServicesSoaCreateUpdateSR.FbeTdAction caseDescriptionAction = getCaseDescriptionAction(caseRecord);
            listOfAction.FbeTdAction.add(caseDescriptionAction);
        }
        
        if(caseRecord.Origin == ServiceConstants.CASE_ORIGIN_CHAT){
            federalServicesSoaCreateUpdateSR.FbeTdAction caseChatAction = getCaseChatAction(caseRecord);
            listOfAction.FbeTdAction.add(caseChatAction);
        }
        
        return listOfAction;
    }

    private federalServicesSoaCreateUpdateSR.ListOfFbeOscContact getListOfContacts(Contact contactRecord){
        federalServicesSoaCreateUpdateSR.ListOfFbeOscContact listOfContacts = 
            new federalServicesSoaCreateUpdateSR.ListOfFbeOscContact();
        listOfContacts.FbeOscContact = new List<federalServicesSoaCreateUpdateSR.FbeOscContact>{
            getContacts(contactRecord)
        };
        return listOfContacts;
    }

    private federalServicesSoaCreateUpdateSR.FbeOscContact getContacts(Contact contactRecord){
        federalServicesSoaCreateUpdateSR.FbeOscContact contacts = 
            new federalServicesSoaCreateUpdateSR.FbeOscContact();

        contacts.EmailAddress = contactRecord.Email;
        contacts.FirstName = contactRecord.Firstname;
        contacts.LastName = contactRecord.LastName;
        contacts.Type_x = parameters.Contact_FBELeadContactType__c;
        contacts.PartyTypeCode = parameters.Contact_FBEPartyTypeCode__c;
        contacts.PrivacyCode = parameters.Contact_FBEPrivacyCode__c;
        contacts.WorkPhone = contactRecord.Primary_Phone__c;
        
        return contacts;
    }

    private String getCaseChatTranscript(Case caseRecord){
        String chatTranscript = '';
        
        if(caseRecord.LiveChatTranscripts != null && !caseRecord.LiveChatTranscripts.isEmpty()){
            chatTranscript = caseRecord?.LiveChatTranscripts[0]?.Body;
            
            if (String.isBlank(chatTranscript)) return '';
            chatTranscript = chatTranscript.replaceAll('<[^>]+>','\n');
        }
        if (chatTranscript.length() > 2000) chatTranscript = chatTranscript.substring(0,2000);
        
        return chatTranscript;
    }

    private federalServicesSoaCreateUpdateSR.SalesOrderSR_Output_element sendRequest(
        federalServicesSoaCreateUpdateSR.ListOfFbeOscSalesOrderSrIo request 
    ){
        federalServicesSoaCreateUpdateSR.FBECreateUpdateSRBindingQSPort siebelService = getSiebelService();
        siebelService.endpoint_x = parameters.Endpoint_URL__c;
        siebelService.timeout_x = 120000;
        return siebelService.CreateUpdateSR(request);
    }

    private federalServicesSoaCreateUpdateSR.FBECreateUpdateSRBindingQSPort getSiebelService(){
        return new federalServicesSoaCreateUpdateSR.FBECreateUpdateSRBindingQSPort();
    }

    private List<federalServicesSoaCreateUpdateSR.FbeTdAction> getListEmailActions(Case caseRecord){
        List<federalServicesSoaCreateUpdateSR.FbeTdAction> listEmailActionsToReturn = new List<federalServicesSoaCreateUpdateSR.FbeTdAction>();

        if(caseRecord.EmailMessages.size() > 0){
            // Todo create email body and type methods
            for(EmailMessage em : caseRecord.EmailMessages){
                String emailBody = '';
                emailBody += 'From: ' + em.FromAddress + '\n';
                emailBody += 'To: ' + em.ToAddress + '\n';
                emailBody += 'Subject: ' + em.Subject + '\n';
                emailBody += 'Message: ' + em.Textbody + '\n';
                String actionType = '';
                if(em.Incoming){
                    actionType = ServiceConstants.SR_ACTION_TYPE_EMAIL_INBOUND;
                } else {
                    actionType = ServiceConstants.SR_ACTION_TYPE_EMAIL_OUTBOUND;
                }

                federalServicesSoaCreateUpdateSR.FbeTdAction action = new federalServicesSoaCreateUpdateSR.FbeTdAction();
                
                action.ActivityUID = em.Id;
                action.Category = parameters.Action_Category__c;                    
                action.FBEAgentNote = emailBody;
                action.Status = parameters.Action_Status__c;
                action.TemplateFlag = parameters.Action_TemplateFlag__c;
                action.Type_x = actionType;
                listEmailActionsToReturn.add(action);
            }
        }
        
        return listEmailActionsToReturn;
    }

    private federalServicesSoaCreateUpdateSR.FbeTdAction getCaseDescriptionAction(Case caseRecord){
        federalServicesSoaCreateUpdateSR.FbeTdAction action = new federalServicesSoaCreateUpdateSR.FbeTdAction(); // Case Description
    
        action.ActivityUID = getUUID();
        action.Category = parameters.Action_Category__c; 
        action.FBEAgentNote = caseRecord.Description;
        action.Status = parameters.Action_Status__c;
        action.TemplateFlag = parameters.Action_TemplateFlag__c;
        action.Type_x = ServiceConstants.SR_ACTION_TYPE_INBOUND;

        return action; 
    }

    private federalServicesSoaCreateUpdateSR.FbeTdAction getCaseChatAction(Case caseRecord){
        federalServicesSoaCreateUpdateSR.FbeTdAction action = new federalServicesSoaCreateUpdateSR.FbeTdAction(); // Chat Transcript
    
        action.ActivityUID = getUUID();
        action.Category = parameters.Action_Category__c;
        action.FBEAgentNote = getCaseChatTranscript(caseRecord);
        action.Status = parameters.Action_Status__c;
        action.TemplateFlag = parameters.Action_TemplateFlag__c;
        action.Type_x = ServiceConstants.SR_ACTION_TYPE_CHAT;
        
        return action;
    }

    private void setEmailMessagesSynced(Case caseRecord, federalServicesSoaCreateUpdateSR.SalesOrderSR_Output_element response){
        if(!isSuccess(response)) return;
        if(caseRecord.EmailMessages.isEmpty()) return;

        List<EmailMessage> listEmailMessageSynced = new List<EmailMessage>();

        for(EmailMessage em : caseRecord.EmailMessages){
            EmailMessage syncedEmailMessage = new EmailMessage();
            syncedEmailMessage.id = em.id;
            syncedEmailMessage.Siebel_Sync_Status__c = ServiceConstants.EMAIL_MESSAGE_SYNCED_TO_SIEBEL;
            listEmailMessageSynced.add(syncedEmailMessage);
        }
 
        update listEmailMessageSynced;
	}
}