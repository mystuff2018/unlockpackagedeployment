@isTest
public class ServiceCaseHandlerTest {
    @IsTest
    static void shouldUpdateServiceQueueWhenCaseIsAssignedToQueue(){
        //Given that a case was assigned to a Queue
        Case caseRecord = new Case();
        caseRecord.RecordTypeId = new ServiceCaseHandler().serviceCaseRecordTypeId;
        insert caseRecord;

        String queueName = ServiceConstants.QUEUE_US_CC_FEd_SUPPORT_Email;
        Group queueRecord = [SELECT Id FROM Group WHERE Name = :queueName AND Type = 'Queue'][0];

        //When the case trigger executes 
        Test.startTest();
        
        caseRecord.OwnerId = queueRecord.id;
        update caseRecord;

        Test.stopTest();

        //Then service queue field should be updated
        caseRecord = [
            SELECT Id, Service_Queue__c 
            FROM Case 
            WHERE Id = :caseRecord.Id
        ];

        System.assertEquals(queueName, caseRecord.Service_Queue__c, 'Service queue field should match the queue name');
    }

    @isTest
    static void shouldNotUpdateServiceQueueWhenCaseIsAssignedToUser(){
        //Given that a case was assigned to an User
        Case caseRecord = new Case();
        caseRecord.RecordTypeId = new ServiceCaseHandler().serviceCaseRecordTypeId;
        insert caseRecord;

        User newOwner = new User(
            FirstName = 'Test',
            LastName = 'Agent',
            Username = 'svchandletest@dell.com.ge2dev.test',
            Email = 'svchandletest@dell.com.ge2dev.test',
            ProfileId = UserInfo.getProfileId(),
            EmployeeNumber = 'svchandletest1234',
            Alias = 'svctst', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US'
        );
        insert newOwner;

        //When the case trigger executes 
        Test.startTest();

        caseRecord.OwnerId = newOwner.Id;
        update caseRecord;
        
        Test.stopTest();
        //Then service queue field should not change
        caseRecord = [
            SELECT Id, Service_Queue__c 
            FROM Case 
            WHERE Id = :caseRecord.Id
        ];

        System.assertEquals(null, caseRecord.Service_Queue__c, 'Service queue field should be empty');
    }
    @IsTest
    static void shouldUpdateCaseReason(){
        
        String queueName = ServiceConstants.QUEUE_US_CC_FEd_SUPPORT_Email;
        Group queueRecord = [SELECT Id FROM Group WHERE Name = :queueName AND Type = 'Queue'][0];

        test.startTest();

        Case caseRecord = new Case();
        caseRecord.RecordTypeId = new ServiceCaseHandler().serviceCaseRecordTypeId;
        caseRecord.OwnerId = queueRecord.id;
        insert caseRecord;       

        test.stopTest();

        //Then caserecord should have added case Reason
        caseRecord = [
            SELECT Id, Service_Queue__c, Reason 
            FROM Case 
            WHERE Id = :caseRecord.Id
        ];
        System.assertEquals(ServiceConstants.CASE_REASON_CUSTOMER_CARE, caseRecord.Reason, 'Case reason should be added to Customer Care.');
        System.assertEquals(ServiceConstants.QUEUE_US_CC_FEd_SUPPORT_Email, caseRecord.Service_Queue__c, 'Case Service queue should be updated to US_CC_Fed_Support_Email Queue name.');

    }
}