@isTest
public class  ServiceEmailMessageHandlerTest {
    @IsTest
    static void shouldSyncServiceEmailWithSiebel(){
        //Given a case with valid contact and SR number
        Contact contactRecord = new Contact();
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'doe';
        contactRecord.Email = 'john.doe@Test.com';
        contactRecord.Primary_Phone__c = '2345678984';
        contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('New Contact').getRecordTypeId();
        insert contactRecord;
        
        Case caseRecord = new Case();
        caseRecord.Service_Tag__c = 'QWERTY';
        caseRecord.SR_Number__c = '200045678';
        caseRecord.Description = 'SR Update Test';
        caseRecord.Origin = 'Email';
        caseRecord.ContactId = contactRecord.Id;
        caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        insert caseRecord;

        siebelComSrUpdateMockImpl mockService = new siebelComSrUpdateMockImpl();
        Test.setMock(WebServiceMock.class, mockService);

        //When a new email is sent
        Test.startTest();
        
        EmailMessage emailMessageRecord = new EmailMessage();
        emailMessageRecord.FromAddress ='henrique.test@test.com';
        emailMessageRecord.ToAddress = 'hanu.test@test.com';
        emailMessageRecord.TextBody ='SR Creation Integration';
        emailMessageRecord.Subject ='SR Creation Integration';
        emailMessageRecord.ParentId = caseRecord.Id;
        insert emailMessageRecord;

        Test.stopTest();

        //Then the email message should be synced with Siebel
        emailMessageRecord = [
            SELECT Siebel_Sync_Status__c 
            FROM EmailMessage
            WHERE id =: emailMessageRecord.id
        ];

        System.assertEquals(ServiceConstants.EMAIL_MESSAGE_SYNCED_TO_SIEBEL, emailMessageRecord.Siebel_Sync_Status__c);
    }
}