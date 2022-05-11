@isTest
public class SiebelCreateSRController_Test {

	@isTest 
	static void shouldUpdateCaseSrNumberWhenCalloutIsSucceeds(){
		//Given a valid case and request
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
		
		Test.setMock(WebServiceMock.class, new siebelComSracreateMockImpl());
		
		//When the Create SR is invoked
		Test.StartTest();
			SiebelCreateSRController.ResponseData response =  SiebelCreateSRController.createSR(caseRecord.id);				
		Test.StopTest();

		//Then the SR Number should be update on the case record
		caseRecord = [
			SELECT Id, SR_Number__c
			FROM Case
			WHERE Id =: caseRecord.id
		];

		System.assertEquals(response.srNumber, caseRecord.SR_Number__c, 'SR Number should be updated on the case record after a success response.');
	}

    @isTest 
	static void shouldReturnErrorMessageWhenServiceTagIsInvalid(){
		//Given a case with invalid Service tag
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
		
		siebelComSracreateMockImpl serviceMock = new siebelComSracreateMockImpl();
		serviceMock.returnAnError = true;
		Test.setMock(WebServiceMock.class, serviceMock);

		String errorMessage = '';
		
		//When the Create SR is invoked
		Test.StartTest();

		SiebelCreateSRController.ResponseData response = SiebelCreateSRController.createSR(caseRecord.id);
						
		Test.StopTest();

		//Then an error message should be displayed to end user
		System.assert(response.errorMessage.contains('Invalid Service Tag'), 'Response not expected: ' + response.errorMessage);
	}

	@IsTest
	static void shouldThrownExceptionWhenRequestWhenCalloutFails(){
		
		//Given a case with invalid Service tag
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
		
		siebelComSracreateMockImpl serviceMock = new siebelComSracreateMockImpl();
		serviceMock.throwException = true;
		Test.setMock(WebServiceMock.class, serviceMock);

		String errorMessage = '';
		
		//When the Create SR is invoked
		Test.StartTest();

		SiebelCreateSRController.ResponseData response = SiebelCreateSRController.createSR(caseRecord.id);
						
		Test.StopTest();

		//Then an error message should be displayed to end user
		System.assertEquals('Error: ' + siebelComSracreateMockImpl.exceptionMessage, response.errorMessage);
		
	}
}