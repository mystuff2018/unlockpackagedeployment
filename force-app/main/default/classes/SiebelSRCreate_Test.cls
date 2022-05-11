@isTest
public class SiebelSRCreate_Test  {

    @isTest
    static void createSRForEmailCaseWithEmailBody(){
        // Given an Email Case with Email records
        Contact contactRecord = new Contact();
        contactRecord.FirstName = 'Klar';
        contactRecord.LastName = 'Bill';
        contactRecord.Email = 'Bill.Klar@Test.com';
        contactRecord.Primary_Phone__c = '2345678984';
        contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Support RecordType').getRecordTypeId();
        insert contactRecord;
        
        Case caseRecord = new Case();
        caseRecord.Service_Tag__c = 'QWERTY';
        caseRecord.Description = 'SR Integration Creation';
        caseRecord.Origin = 'Email';
        caseRecord.ContactId = contactRecord.Id;
        caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        insert caseRecord;
        
        EmailMessage emailMessageRecord = new EmailMessage();
        emailMessageRecord.FromAddress ='henrique.test@test.com';
        emailMessageRecord.ToAddress = 'hanu.test@test.com';
        emailMessageRecord.TextBody ='SR Creation Integration';
        emailMessageRecord.Subject ='SR Creation Integration';
        emailMessageRecord.ParentId = caseRecord.Id;
        insert emailMessageRecord;

        siebelComSracreateMockImpl siebelMockService = new siebelComSracreateMockImpl();
        Test.setMock(WebServiceMock.class, siebelMockService);

        // When the Create SR button executes
        Test.StartTest();
        
        SiebelSRCreate siebelSrService = new SiebelSRCreate();
        siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Output_element response = 
            siebelSrService.srCreate(caseRecord.id);
        
        Test.StopTest();

        // Then the email body should be sent in Agent Notes
        siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Input_element request = 
            (siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Input_element) siebelMockService.request;

        String emailBody = '';
        emailBody += 'From: ' + emailMessageRecord.FromAddress + '\n';
        emailBody += 'To: ' + emailMessageRecord.ToAddress + '\n';
        emailBody += 'Subject: ' + emailMessageRecord.Subject + '\n';
        emailBody += 'Message: ' + emailMessageRecord.Textbody + '\n';

       /* System.assertEquals(
            request.ListOfFbeServiceRequestIo.FbeServiceRequest[0].ListOfFbeAction.FbeAction[0].FBEAgentNote, 
            emailBody,
            'Agent Notes should have the email body if the case is an Email Case'
        );*/

        System.assertEquals(response.SRNumber, siebelComSracreateMockImpl.srNumber, 'SR Number should be returned');
    }

    @isTest
    static void createSRForChatCaseWithChatTranscript(){
        // Given Chat Case with Chat Transcript
        Contact contactRecord = new Contact();
        contactRecord.FirstName = 'Klar';
        contactRecord.LastName = 'Bill';
        contactRecord.Email = 'Bill.Klar@Test.com';
        contactRecord.Primary_Phone__c = '2345678984';
        contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('New Contact').getRecordTypeId();
        insert contactRecord;
        
        Case caseRecord = new Case();
        caseRecord.Service_Tag__c = 'QWERTY';
        caseRecord.Description = 'SR Integration Creation';
        caseRecord.Origin = 'Chat';
        caseRecord.ContactId = contactRecord.Id;
        caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        insert caseRecord;
        
        LiveChatVisitor liveChatVisitorRecord = new LiveChatVisitor();
        insert liveChatVisitorRecord;
        
        LiveChatTranscript liveChatTranscriptRecord = new LiveChatTranscript();
        liveChatTranscriptRecord.body ='attaching Transcript body to case';
        liveChatTranscriptRecord.LiveChatVisitorid = liveChatVisitorRecord.id;
        liveChatTranscriptRecord.CaseId = caseRecord.Id;
        
        insert liveChatTranscriptRecord;
        
        siebelComSracreateMockImpl siebelMockService = new siebelComSracreateMockImpl();
        Test.setMock(WebServiceMock.class, siebelMockService);

        // When the Create SR button executes
        Test.StartTest();
        
        SiebelSRCreate siebelSrService = new SiebelSRCreate();
        siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Output_element response = 
            siebelSrService.srCreate(caseRecord.id);
        
        Test.StopTest();

        // Then the chat Transcript body should be sent in Agent Notes
		siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Input_element request = 
            (siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Input_element) siebelMockService.request;          
        
       /* System.assertEquals(
            request.ListOfFbeServiceRequestIo.FbeServiceRequest[0].ListOfFbeAction.FbeAction[0].FBEAgentNote, 
            liveChatTranscriptRecord.body,
            'Agent Notes should match the Chat Transcript body'
        );*/

        System.assertEquals(response.SRNumber, siebelComSracreateMockImpl.srNumber, 'SR Number should be returned');
    }
    @testVisible static List<Siebel_Create_SR__mdt> customMetadata { 
    get {
        if ( customMetadata == null )
            customMetadata = [ SELECT Action_Category__c,Action_Operation__c,Action_Status__c,Action_TemplateFlag__c,Action_Type_x__c FROM Siebel_Create_SR__mdt ]; 
        return customMetadata;
    } set; }
    
  @isTest  
   static void createSRForEmailActionsAndcaseDescription(){
        Contact contactRecord = new Contact();
        contactRecord.FirstName = 'Klar';
        contactRecord.LastName = 'Bill';
        contactRecord.Email = 'Bill.Klar@Test.com';
        contactRecord.Primary_Phone__c = '2345678984';
        contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('New Contact').getRecordTypeId();
        insert contactRecord;
        
        Case caseRecord = new Case();
        caseRecord.Service_Tag__c = 'QWERTY';
        caseRecord.Description = 'SR Integration Creation';
        caseRecord.Origin = 'Email';
        caseRecord.ContactId = contactRecord.Id;
        caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        insert caseRecord;
       List<EmailMessage> listEmailRecords =  new List<EmailMessage>();
        EmailMessage emailMessageRecord = new EmailMessage();
        emailMessageRecord.FromAddress ='henrique.test@test.com';
        emailMessageRecord.ToAddress = 'hanu.test@test.com';
        emailMessageRecord.TextBody ='SR Creation Integration';
        emailMessageRecord.Subject ='SR Creation Integration';
        emailMessageRecord.ParentId = caseRecord.Id;
        listEmailRecords.add(emailMessageRecord);
        
        EmailMessage emailMessageRecords = new EmailMessage();
        emailMessageRecords.FromAddress ='henrique11.test@test.com';
        emailMessageRecords.ToAddress = 'hanu.test@test.com';
        emailMessageRecords.TextBody ='SR Creation Integrations';
        emailMessageRecords.Subject ='SR Creation Integrations';
        emailMessageRecords.ParentId = caseRecord.Id;
        listEmailRecords.add(emailMessageRecords);
       insert listEmailRecords;       
            
         siebelComSracreateMockImpl siebelMockService = new siebelComSracreateMockImpl();
         Test.setMock(WebServiceMock.class, siebelMockService);

        // When the Create SR button executes
        Test.StartTest();
        
        SiebelSRCreate siebelSrService = new SiebelSRCreate();
        siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Output_element response = 
            siebelSrService.srCreate(caseRecord.id);
        
        Test.StopTest();

        // Then the email body should be sent in Agent Notes
        siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Input_element request = 
            (siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Input_element) siebelMockService.request; 
        
        System.assertEquals(response.SRNumber, siebelComSracreateMockImpl.srNumber, 'SR Number should be returned');
    } 
}