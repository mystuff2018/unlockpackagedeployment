@isTest
public class SiebelCreateSRBasedOnOrderNoCtrlTest {

	@isTest 
	static void shouldUpdateCaseSrNumberWhenCalloutIsSucceeds(){
		//Given a valid case and request
		Contact contactRecord = new Contact();
		contactRecord.FirstName = 'Joe';
		contactRecord.LastName = 'Root';
		contactRecord.Email = 'joe.root@test.com';
		contactRecord.Primary_Phone__c = '2348425984';
		contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('New Contact').getRecordTypeId();
		insert contactRecord;
					
		Case caseRecord = new Case();
		caseRecord.Order_Number__c = '1214321';
		caseRecord.Description = 'SR Integration Creation';
		caseRecord.Origin = 'Email';
		caseRecord.ContactId = contactRecord.Id;
		caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service').getRecordTypeId();
		insert caseRecord;
		
		Test.setMock(WebServiceMock.class, new federalServicesSoaCreateUpdateSRMock());
		
		//When the Create SR is invoked
		Test.StartTest();
			SiebelCreateSRBasedOnOrderNoCtrl.ResponseData response =  SiebelCreateSRBasedOnOrderNoCtrl.createSR(caseRecord.id);				
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
	static void shouldReturnErrorMessageWhenInvalidOrderNumber(){
		//Given a case with invalid Service tag
		Contact contactRecord = new Contact();
		contactRecord.FirstName = 'Joe';
		contactRecord.LastName = 'Root';
		contactRecord.Email = 'joe.root@test.com';
		contactRecord.Primary_Phone__c = '2345678984';
		contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('New Contact').getRecordTypeId();
		insert contactRecord;
					
		Case caseRecord = new Case();
		caseRecord.Order_Number__c = 'INVALID';
		caseRecord.Description = 'SR Integration Creation';
		caseRecord.Origin = 'Email';
		caseRecord.ContactId = contactRecord.Id;
		caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service').getRecordTypeId();
		insert caseRecord;
		
		federalServicesSoaCreateUpdateSRMock serviceMock = new federalServicesSoaCreateUpdateSRMock();
		serviceMock.returnAnError = true;
		Test.setMock(WebServiceMock.class, serviceMock);

		String errorMessage = '';
		
		//When the Create SR is invoked
		Test.StartTest();

		SiebelCreateSRBasedOnOrderNoCtrl.ResponseData response = SiebelCreateSRBasedOnOrderNoCtrl.createSR(caseRecord.id);
						
		Test.StopTest();
		//Then an error message should be displayed to end user
		System.assert(response.errorMessage.contains('Invalid Order Number'), 'Response not expected: ' + response.errorMessage);
	}

	@IsTest
	static void shouldThrownExceptionWhenRequestWhenCalloutFails(){
		
		//Given a case with invalid Service tag
		Contact contactRecord = new Contact();
		contactRecord.FirstName = 'Root';
		contactRecord.LastName = 'Joe';
		contactRecord.Email = 'joe.root@Test.com';
		contactRecord.Primary_Phone__c = '2345678984';
		contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('New Contact').getRecordTypeId();
		insert contactRecord;
					
		Case caseRecord = new Case();
		caseRecord.Order_Number__c = '1214321';
		caseRecord.Description = 'SR Integration Creation';
		caseRecord.Origin = 'Email';
		caseRecord.ContactId = contactRecord.Id;
		caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service').getRecordTypeId();
		insert caseRecord;
		
		federalServicesSoaCreateUpdateSRMock serviceMock = new federalServicesSoaCreateUpdateSRMock();
		serviceMock.throwException = true;
		Test.setMock(WebServiceMock.class, serviceMock);

		String errorMessage = '';
		
		//When the Create SR is invoked
		Test.StartTest();

		SiebelCreateSRBasedOnOrderNoCtrl.ResponseData response = SiebelCreateSRBasedOnOrderNoCtrl.createSR(caseRecord.id);
						
		Test.StopTest();

		//Then an error message should be displayed to end user
		System.assertEquals('Error: ' + federalServicesSoaCreateUpdateSRMock.exceptionMessage, response.errorMessage);
		
	}
}