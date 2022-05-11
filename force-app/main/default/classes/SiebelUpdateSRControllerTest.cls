@isTest
public class SiebelUpdateSRControllerTest {
    @IsTest
    static void shouldReturnSuccessMessageWhenCalloutSucceeds(){
        //Given a new case
        Contact contactRecord = new Contact();
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'doe';
        contactRecord.Email = 'john.doe@Test.com';
        contactRecord.Primary_Phone__c = '2345678984';
        contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('New Contact').getRecordTypeId();
        insert contactRecord;

        Case caseRecord = new Case();
        caseRecord.Service_Tag__c = 'QWERTY';
        caseRecord.Description = 'SR Update Test';
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
        emailMessageRecord.Siebel_Sync_Status__c = 'Not Synced';
        insert emailMessageRecord;

        siebelComSrUpdateMockImpl mockService = new siebelComSrUpdateMockImpl();
        Test.setMock(WebServiceMock.class, mockService);

        //When the update Sr service runs with success
        Test.startTest();
    
        SiebelUpdateSRController.ResponseData response = SiebelUpdateSRController.updateSR(caseRecord.Id);
    
        Test.stopTest();

        //Then a success message should be returned
        System.assertEquals(true, response.isSuccess);
    }

    @IsTest
    static void shouldReturnErrorMessageWhenCalloutFails(){
        //Given a new case
        Contact contactRecord = new Contact();
        contactRecord.FirstName = 'John';
        contactRecord.LastName = 'doe';
        contactRecord.Email = 'john.doe@Test.com';
        contactRecord.Primary_Phone__c = '2345678984';
        contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('New Contact').getRecordTypeId();
        insert contactRecord;
        
        Case caseRecord = new Case();
        caseRecord.Service_Tag__c = 'QWERTY';
        caseRecord.Description = 'SR Update Test';
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
        emailMessageRecord.Siebel_Sync_Status__c = 'Not Synced';
        insert emailMessageRecord;

        siebelComSrUpdateMockImpl mockService = new siebelComSrUpdateMockImpl();
        mockService.throwException = true;
        Test.setMock(WebServiceMock.class, mockService);

        //When the update Sr service fails
        Test.startTest();
        
        SiebelUpdateSRController.ResponseData response = SiebelUpdateSRController.updateSR(caseRecord.Id);

        Test.stopTest();

        //Then an error message should be returned
        System.assertEquals(false, response.isSuccess);
    }
}