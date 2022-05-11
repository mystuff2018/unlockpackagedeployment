@isTest
public class DisplayServapptResAbsCntrlTest {
    @testSetup
    static void setupTestData(){
        test.startTest();
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
        User userTest = TestDataGenerator.createUser('Smith1234','Julian','29');
        insert userTest;
        Account account = new Account();
        account.Name = 'AccountName';
        insert account;
        ServiceResource sr = new ServiceResource();
        sr.Name = 'Test Contact One';
        sr.IsActive = true;
        sr.ResourceType = 'T';
        sr.RelatedRecordId = userTest.Id;
        insert sr;
        ServiceAppointment serviceappointment_Obj = new ServiceAppointment(ParentRecordId = account.id, EarliestStartTime = DateTime.now(), DueDate = DateTime.now()+10, SchedStartTime = DateTime.now(), SchedEndTime = DateTime.now()+4, Subject = 'Subject704');
        Insert serviceappointment_Obj; 
        ResourceAbsence resourceabsence_Obj = new ResourceAbsence(ResourceId = sr.Id, Type = 'Vacation', Start = DateTime.now(), End = DateTime.now()+2);
        Insert resourceabsence_Obj;
        }
        test.stopTest();
    }
    static testMethod void test_getWrapperClassList(){
        List<ServiceAppointment> serviceappointment_Obj = [SELECT Id, AppointmentNumber, Subject, SchedStartTime, SchedEndTime FROM ServiceAppointment Where SchedStartTime = TODAY OR SchedEndTime = TODAY OR (SchedStartTime <= TODAY AND SchedEndTime >= TODAY)];
        System.assertEquals(true,serviceappointment_Obj.size()>0);
        List<ServiceResource> srList = [SELECT Id, Name, RelatedRecordId FROM ServiceResource];
        List<User> userTest = [Select Id, Name, TimeZoneSidKey FROM User Where Id =: srList[0].RelatedRecordId];
        system.runAs(userTest[0]){
            List<ResourceAbsence> resabsList = [SELECT Id, AbsenceNumber, Start, End, Type, Resource.RelatedRecordId FROM ResourceAbsence Where (End = TODAY OR Start = TODAY OR (Start <= TODAY AND End >= TODAY)) AND Resource.RelatedRecordId =: userTest[0].Id];
            System.assertEquals(true,resabsList.size()>0);
            DisplayServapptResAbsCntrl obj01 = new DisplayServapptResAbsCntrl();
            DisplayServapptResAbsCntrl.getWrapperClassList();
        }
    }
    
}