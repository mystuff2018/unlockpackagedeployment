public class SiebelSRCreate {

    private Siebel_Create_SR__mdt parameters {
        get{
            if (parameters != null) return parameters;
            parameters = Siebel_Create_SR__mdt.getInstance('Default');
            return parameters;
        }
        private set;
    }

    public siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Output_element srCreate(Id caseID){
        Case caseRecord = getCase(caseID);

        return srCreate(caseRecord);
    }

    public Case getCase(Id caseId){
        return [
            SELECT Description,Subject,Origin,Service_Tag__c,Contact.Email,
                Contact.FirstName,Contact.LastName,Contact.Primary_Phone__c,
                (SELECT Id, Body FROM LiveChatTranscripts),
                (SELECT Id,Textbody,FromAddress,ToAddress,Subject,Incoming FROM EmailMessages ORDER BY CreatedDate DESC)
            FROM Case 
            WHERE Id =: caseId
            LIMIT 1
        ][0];   
    }

    public siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Output_element srCreate(Case caseRecord){      
        wwwSiebelComXmlFbeservicerequestio.ListOfFbeServicerequestIo request = getRequest(caseRecord);
        siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Output_element response = sendRequest(request);
        setEmailMessagesSynced(caseRecord,response);
        logTransaction(request, response);

        return response;
    }

    private void logTransaction(wwwSiebelComXmlFbeservicerequestio.ListOfFbeServicerequestIo request,
            siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Output_element response
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

    private Boolean isSuccess(siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Output_element response){
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

    private wwwSiebelComXmlFbeservicerequestio.ListOfFbeServicerequestIo getRequest(Case caseRecord){
        wwwSiebelComXmlFbeservicerequestio.ListOfFbeServicerequestIo request = 
            new wwwSiebelComXmlFbeservicerequestio.ListOfFbeServicerequestIo();

        wwwSiebelComXmlFbeservicerequestio.FbeServicerequest fbeServicerequest = getFbeRequest(caseRecord);
        
        request.FbeServiceRequest = new List<wwwSiebelComXmlFbeservicerequestio.FbeServicerequest>{fbeServicerequest};

        return request;
    }

    private wwwSiebelComXmlFbeservicerequestio.FbeServicerequest getFbeRequest(Case caseRecord){
        wwwSiebelComXmlFbeservicerequestio.FbeServicerequest fbeServiceRequest = 
            new wwwSiebelComXmlFbeservicerequestio.FbeServicerequest();

        fbeServiceRequest.Abstract_x = caseRecord.Subject;
        fbeServiceRequest.IntegrationId = getUUID();
        fbeServiceRequest.Owner = parameters.Request_Owner__c;
        fbeServiceRequest.SRType = parameters.Request_SR_Type__c;
        fbeServiceRequest.Source = getSource(caseRecord);
        fbeServiceRequest.Status = parameters.Request_Status__c;
        fbeServiceRequest.FBEAssetNumber = caseRecord.Service_Tag__c;
        fbeServiceRequest.Operation = parameters.Request_Operation__c;

        wwwSiebelComXmlFbeservicerequestio.ListOfFbeAction listOfAction = getListOfAction(caseRecord); 
        fbeServicerequest.ListOfFbeAction = listOfAction;
        
        wwwSiebelComXmlFbeservicerequestio.ListOfFBEServiceRequest_Contacts listOfContacts = getListOfContacts(caseRecord.Contact);
        fbeServicerequest.ListOfFBEServiceRequest_Contacts = listOfContacts;

        return fbeServicerequest;
    }

    private String getSource(Case caseRecord){
        if(caseRecord.Origin == 'Chat'){
            return 'Chat';
        } else {
            return 'Email';
        }
    }

    private wwwSiebelComXmlFbeservicerequestio.ListOfFbeAction getListOfAction(Case caseRecord){
        wwwSiebelComXmlFbeservicerequestio.ListOfFbeAction listOfAction = new wwwSiebelComXmlFbeservicerequestio.ListOfFbeAction();
        listOfAction.FbeAction = new List<wwwSiebelComXmlFbeservicerequestio.FbeAction>();

        List<wwwSiebelComXmlFbeservicerequestio.FbeAction> listEmailActions = getListEmailActions(caseRecord);
        listOfAction.FbeAction.addAll(listEmailActions);
        
        if(caseRecord.Origin != 'Email'){
            wwwSiebelComXmlFbeservicerequestio.FbeAction caseDescriptionAction = getCaseDescriptionAction(caseRecord);
            listOfAction.FbeAction.add(caseDescriptionAction);
        }

        if(caseRecord.Origin == 'Chat'){
            wwwSiebelComXmlFbeservicerequestio.FbeAction caseChatAction = getCaseChatAction(caseRecord);
            listOfAction.FbeAction.add(caseChatAction);
        }

        return listOfAction;
    } 

    private wwwSiebelComXmlFbeservicerequestio.ListOfFBEServiceRequest_Contacts getListOfContacts(Contact contactRecord){
        wwwSiebelComXmlFbeservicerequestio.ListOfFBEServiceRequest_Contacts listOfContacts = 
            new wwwSiebelComXmlFbeservicerequestio.ListOfFBEServiceRequest_Contacts();
        listOfContacts.FBEServiceRequest_Contacts = new List<wwwSiebelComXmlFbeservicerequestio.FBEServiceRequest_Contacts>{
            getContacts(contactRecord)
        };
        return listOfContacts;
    } 

    private wwwSiebelComXmlFbeservicerequestio.FBEServicerequest_Contacts getContacts(Contact contactRecord){
        wwwSiebelComXmlFbeservicerequestio.FBEServicerequest_Contacts contacts = 
            new wwwSiebelComXmlFbeservicerequestio.FBEServicerequest_Contacts();

        contacts.FBEContactEmailAddress = contactRecord.Email;
        contacts.FBEContactFirstName = contactRecord.Firstname;
        contacts.FBEContactLastName = contactRecord.LastName;
        contacts.FBELeadContactType = parameters.Contact_FBELeadContactType__c;
        contacts.FBEPartyTypeCode = parameters.Contact_FBEPartyTypeCode__c;
        contacts.FBEPrivacyCode = parameters.Contact_FBEPrivacyCode__c;
        contacts.FBEWorkPhoneNum = contactRecord.Primary_Phone__c;
        contacts.Operation = parameters.Contact_Operation__c;

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

    private siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Output_element sendRequest(
        wwwSiebelComXmlFbeservicerequestio.ListOfFbeServicerequestIo request 
    ){
        siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWFQSPort siebelService = getSiebelService();
        siebelService.endpoint_x = parameters.Endpoint_URL__c;
        siebelService.timeout_x = 120000;
        return siebelService.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF(request);
    }

    private siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWFQSPort getSiebelService(){
        return new siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWFQSPort();
    }

    private List<wwwSiebelComXmlFbeservicerequestio.FbeAction> getListEmailActions(Case caseRecord){
        List<wwwSiebelComXmlFbeservicerequestio.FbeAction> listEmailActionsToReturn = new List<wwwSiebelComXmlFbeservicerequestio.FbeAction>();

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

                wwwSiebelComXmlFbeservicerequestio.FbeAction action = new wwwSiebelComXmlFbeservicerequestio.FbeAction();
                
                action.ActivityUID = em.Id;
                action.Category = parameters.Action_Category__c;                    
                action.FBEAgentNote = emailBody;
                action.Status = parameters.Action_Status__c;
                action.TemplateFlag = parameters.Action_TemplateFlag__c;
                action.Type_x = actionType;
                action.Operation = parameters.Action_Operation__c;
                listEmailActionsToReturn.add(action);
            }
        }

        return listEmailActionsToReturn;
    } 

    private wwwSiebelComXmlFbeservicerequestio.FbeAction getCaseDescriptionAction(Case caseRecord){
        wwwSiebelComXmlFbeservicerequestio.FbeAction action = new wwwSiebelComXmlFbeservicerequestio.FbeAction(); // Case Description
    
        action.ActivityUID = getUUID();
        action.Category = parameters.Action_Category__c; 
        action.FBEAgentNote = caseRecord.Description;
        action.Status = parameters.Action_Status__c;
        action.TemplateFlag = parameters.Action_TemplateFlag__c;
        action.Type_x = ServiceConstants.SR_ACTION_TYPE_INBOUND; 
        action.Operation = parameters.Action_Operation__c;

        return action; 
    } 

    private wwwSiebelComXmlFbeservicerequestio.FbeAction getCaseChatAction(Case caseRecord){
        wwwSiebelComXmlFbeservicerequestio.FbeAction action = new wwwSiebelComXmlFbeservicerequestio.FbeAction(); // Chat Transcript
    
        action.ActivityUID = getUUID();
        action.Category = parameters.Action_Category__c;
        action.FBEAgentNote = getCaseChatTranscript(caseRecord);
        action.Status = parameters.Action_Status__c;
        action.TemplateFlag = parameters.Action_TemplateFlag__c;
        action.Type_x = ServiceConstants.SR_ACTION_TYPE_CHAT;
        action.Operation = parameters.Action_Operation__c; 
        
        return action;
    } 

	private void setEmailMessagesSynced(Case caseRecord, siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Output_element response){
        if(String.isBlank(response.SRNumber)) return;
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