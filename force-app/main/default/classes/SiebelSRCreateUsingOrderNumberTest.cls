@isTest
public class SiebelSRCreateUsingOrderNumberTest  {

    @isTest
    static void createSRForEmailCaseWithEmailBody(){
        // Given an Email Case with Email records
        Contact contactRecord = new Contact();
        contactRecord.FirstName = 'Joe';
        contactRecord.LastName = 'Root';
        contactRecord.Email = 'joe.root@test.com';
        contactRecord.Primary_Phone__c = '2345678984';
        contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('New Contact').getRecordTypeId();
        insert contactRecord;
        
        Case caseRecord = new Case();
        caseRecord.Order_Number__c = '1234321';
        caseRecord.Description = 'SR Integration Creation';
        caseRecord.Origin = 'Email';
        caseRecord.ContactId = contactRecord.Id;
        caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        insert caseRecord;
        
        EmailMessage emailMessageRecord = new EmailMessage();
        emailMessageRecord.FromAddress ='agentfromm.test@test.com';
        emailMessageRecord.ToAddress = 'customerTo.test@test.com';
        emailMessageRecord.TextBody ='SR Creation Integration';
        emailMessageRecord.Subject ='SR Creation Integration';
        emailMessageRecord.ParentId = caseRecord.Id;
        insert emailMessageRecord;

        federalServicesSoaCreateUpdateSRMock siebelMockService = new federalServicesSoaCreateUpdateSRMock();
        Test.setMock(WebServiceMock.class, siebelMockService);

        // When the Create SR button executes
        Test.StartTest();
        
        SiebelSRCreateUsingOrderNumber siebelSrService = new SiebelSRCreateUsingOrderNumber();
        federalServicesSoaCreateUpdateSR.SalesOrderSR_Output_element response = 
            siebelSrService.srCreate(caseRecord.id);
        
        Test.StopTest();

        // Then the email body should be sent in Agent Notes
        federalServicesSoaCreateUpdateSR.SalesOrderSR_Input_element request = 
            (federalServicesSoaCreateUpdateSR.SalesOrderSR_Input_element) siebelMockService.request;

        String emailBody = '';
        emailBody += 'From: ' + emailMessageRecord.FromAddress + '\n';
        emailBody += 'To: ' + emailMessageRecord.ToAddress + '\n';
        emailBody += 'Subject: ' + emailMessageRecord.Subject + '\n';
        emailBody += 'Message: ' + emailMessageRecord.Textbody + '\n';

        System.assertEquals(
            request.ListOfFbeOscSalesOrderSrIo.FbeTdServiceRequest[0].ListOfFbeTdAction.FbeTdAction[0].FBEAgentNote, 
            emailBody,
            'Agent Notes should have the email body if the case is an Email Case'
        );

        System.assertEquals(response.SRNumber, federalServicesSoaCreateUpdateSRMock.srNumber, 'SR Number should be returned');
    }

    @isTest
    static void createSRForChatCaseWithChatTranscript(){
        // Given Chat Case with Chat Transcript
        Contact contactRecord = new Contact();
        contactRecord.FirstName = 'Joe';
        contactRecord.LastName = 'Root';
        contactRecord.Email = 'joe.root@test.com';
        contactRecord.Primary_Phone__c = '2345678984';
        contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('New Contact').getRecordTypeId();
        insert contactRecord;
        
        Case caseRecord = new Case();
        caseRecord.Order_Number__c = '1234321';
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
      
        federalServicesSoaCreateUpdateSRMock siebelMockService = new federalServicesSoaCreateUpdateSRMock();
        Test.setMock(WebServiceMock.class, siebelMockService);

        // When the Create SR button executes
        Test.StartTest();
        
        SiebelSRCreateUsingOrderNumber siebelSrService = new SiebelSRCreateUsingOrderNumber();
        federalServicesSoaCreateUpdateSR.SalesOrderSR_Output_element response = 
            siebelSrService.srCreate(caseRecord.id);
        
        Test.StopTest();

        // Then the chat Transcript body should be sent in Agent Notes
		federalServicesSoaCreateUpdateSR.SalesOrderSR_Input_element request = 
            (federalServicesSoaCreateUpdateSR.SalesOrderSR_Input_element) siebelMockService.request;          
        
        System.debug('---------liveChatTranscriptRecord.body-----------'+liveChatTranscriptRecord.body);
        System.debug('----------response.FBEAgentNote-----------'+request.ListOfFbeOscSalesOrderSrIo.FbeTdServiceRequest[0].ListOfFbeTdAction.FbeTdAction[0].FBEAgentNote);
        
        System.assertEquals(
            request.ListOfFbeOscSalesOrderSrIo.FbeTdServiceRequest[0].ListOfFbeTdAction.FbeTdAction[0].FBEAgentNote, 
            liveChatTranscriptRecord.body,
            'Agent Notes should match the Chat Transcript body'
        );

        System.assertEquals(response.SRNumber, federalServicesSoaCreateUpdateSRMock.srNumber, 'SR Number should be returned');
    }

    @isTest  
    static void createSRForEmailActionsAndcaseDescription(){
        Contact contactRecord = new Contact();
        contactRecord.FirstName = 'Root';
        contactRecord.LastName = 'Joe';
        contactRecord.Email = 'joe.root@Test.com';
        contactRecord.Primary_Phone__c = '2345678984';
        contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('New Contact').getRecordTypeId();
        insert contactRecord;
        
        Case caseRecord = new Case();
        caseRecord.Order_Number__c = '1234321';
        caseRecord.Description = 'SR Integration Creation';
        caseRecord.Origin = 'Email';
        caseRecord.ContactId = contactRecord.Id;
        caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        insert caseRecord;

        List<EmailMessage> listEmailRecords =  new List<EmailMessage>();
        EmailMessage emailMessageRecord = new EmailMessage();
        emailMessageRecord.FromAddress ='testuser.from@test.com';
        emailMessageRecord.ToAddress = 'testuser.to@test.com';
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
            
        federalServicesSoaCreateUpdateSRMock siebelMockService = new federalServicesSoaCreateUpdateSRMock();
        Test.setMock(WebServiceMock.class, siebelMockService);

        // When the Create SR button executes
        Test.StartTest();
        
        SiebelSRCreateUsingOrderNumber siebelSrService = new SiebelSRCreateUsingOrderNumber();
        federalServicesSoaCreateUpdateSR.SalesOrderSR_Output_element response = 
            siebelSrService.srCreate(caseRecord.id);
        
        Test.StopTest();

        // Then the email body should be sent in Agent Notes
        federalServicesSoaCreateUpdateSR.SalesOrderSR_Input_element request = 
            (federalServicesSoaCreateUpdateSR.SalesOrderSR_Input_element) siebelMockService.request; 
        
        System.assertEquals(response.SRNumber, federalServicesSoaCreateUpdateSRMock.srNumber, 'SR Number should be returned');
    }
}