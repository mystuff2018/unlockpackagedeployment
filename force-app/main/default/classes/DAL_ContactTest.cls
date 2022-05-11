@isTest
public class DAL_ContactTest {

@isTest
   static void shouldGetContactByProjectManager(){
       
       pse__Proj__c project = OPRTestFactory.createSimpleProject();
       
       Contact cnct = OPRTestFactory.newContact('Test', 'Test', 'US', 'Texas','1234567890');
        insert cnct;
       project.pse__Project_Manager__c = cnct.Id;
        update project;
       
       Test.startTest();
       Map<Id, Contact> result = DAL_Contact.getContactByProjectManagerId(new Map<Id, pse__Proj__c>{project.Id => project});
       Test.stopTest();       
       System.assertEquals(1, result.size(), 'Map should contains 1 contact');
        
   }
    
   @isTest
    static void shouldGetContactMap(){
       
       Contact contact = new Contact(
               FirstName = 'Test',
                LastName = 'Test lastname',                
               MailingPostalCode = '11111',                
               MailingStreet = '1 Dell way',
           Mailing_State__c = 'Texas',
               Email='test@dell.com',
           phone='1234567890'
        );
        insert contact;      
        Test.startTest();
        Map<Id, Contact> result = DAL_Contact.getMapContactIdContactBySetId(new Set<Id>{contact.Id});
      Test.stopTest();
       
       System.assertEquals(1, result.size(), 'Map should contains 1 contact');
       
    }
}