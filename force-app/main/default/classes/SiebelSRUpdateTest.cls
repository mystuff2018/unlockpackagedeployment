@isTest
public class SiebelSRUpdateTest {
    @IsTest
    static void shouldSendEmailDataToSiebelWhenThereIsEmailMessage(){
        //Given a case with EmailMessages
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

        //When update sr service runs
        Test.startTest();
        
        SiebelSRUpdate siebelService = new SiebelSRUpdate();
        siebelComSractivity.FBE_spcOSC_spcSR_spcActivity_spcWF_Output_element response = siebelService.updateSR(caseRecord.Id);

        Test.stopTest();

        //Then 
        System.assertEquals(siebelComSrUpdateMockImpl.successMessage, response.SiebelErrorMessage);
    }

    @IsTest
    static void shouldReturnErrorMessageWhenCalloutReturnsAnError(){
        //Given a case with EmailMessages
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
        emailMessageRecord.Siebel_Sync_Status__c = 'Not synced';
        insert emailMessageRecord;

        siebelComSrUpdateMockImpl mockService = new siebelComSrUpdateMockImpl();
        mockService.returnAnError = true;
        Test.setMock(WebServiceMock.class, mockService);

        //When update sr service runs
        Test.startTest();
        
        SiebelSRUpdate siebelService = new SiebelSRUpdate();
        siebelComSractivity.FBE_spcOSC_spcSR_spcActivity_spcWF_Output_element response = siebelService.updateSR(caseRecord.Id);

        Test.stopTest();

        //Then the error message should be returned
        System.assertEquals(siebelComSrUpdateMockImpl.errorMessage, response.SiebelErrorMessage);
    }
}