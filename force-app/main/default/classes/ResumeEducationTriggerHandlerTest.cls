@isTest
public class ResumeEducationTriggerHandlerTest {
    
    private static testMethod void testDelete(){
        List<Account> accList= TestDataUtility.createAccounts(1,true);
        List<Contact> conList= TestDataUtility.createContacts(1,accList[0].Id,true,true);
        Resume__c resume = new Resume__c();
        resume.Resource__c	 = conList[0].Id;
        resume.Status__c  = 'In Process';
        insert resume;
        List<Education__c> educationList = new List<Education__c>();
        Education__c education = new Education__c();
        education.Resume__c = resume.id;
        educationList.add(education);
        insert educationList;
        
        Test.startTest();
        ResumeEducationTriggerHandler.PreventDeletionOfLastResumeEducation(educationList);
        Test.stopTest();
        
    }
    private static testMethod void testDelete1(){
        List<Account> accList= TestDataUtility.createAccounts(1,true);
        List<Contact> conList= TestDataUtility.createContacts(1,accList[0].Id,true,true);
        Resume__c resume = new Resume__c();
        resume.Resource__c	 = conList[0].Id;
        resume.Status__c  = 'In Process';
        insert resume;
        Core_Competency__c comp = new Core_Competency__c();
        comp.Resume__c = resume.id;
        insert comp;
        Education__c edu = new Education__c	();
        edu.Resume__c = resume.id;
        insert edu;
        Experience__c exp = new Experience__c();
        exp.Resume__c = resume.id;
        insert exp;
        Skill__c	 ski = new Skill__c		();
        ski.Resume__c = resume.id;
        insert ski;
        System.debug(' resume.No_of_Education__c'+resume.No_of_Education__c );
        System.debug(' resume.Status__c'+resume.Status__c );
        
        resume.Status__c  = 'In Review';
        update resume;
        
        Resume__c resu = [Select id,Status__c,No_of_Education__c from Resume__c where id =:resume.id  ];
        System.debug(' resume.No_of_Education__c'+resu.No_of_Education__c );
        System.debug(' resume.Status__c'+resu.Status__c );
        
        
        Education__c educationInsert = [select id,Resume__c,Last_Resume_Education__c,Resume__r.Status__c,Resume__r.No_of_Education__c  from Education__c where id =:edu.id];
        System.debug('educationInsert'+educationInsert.Last_Resume_Education__c);
        Profile prof = [Select id from Profile where name = 'PSA Technical Resource'];
        User user = new User();
        user.profileId = prof.id;
        user.firstName = 'Test1';
        user.lastName = 'Test';
        user.EmployeeNumber = '1234';
        user.email = 'test@test.com';
        user.Username= 'testchand@test.com';
        user.Alias= 'test1';
        user.TimeZoneSidKey= 'America/Los_Angeles';
        user.LocaleSidKey= 'en_US';
        user.EmailEncodingKey= 'ISO-8859-1';
        user.LanguageLocaleKey= 'en_US';
        
        
        insert user;
        
        Test.startTest();
        System.runAs(user){
            try{
                System.debug('educationList'+educationInsert.Last_Resume_Education__c);
                delete educationInsert;
            }
            // ResumeEducationTriggerHandler.PreventDeletionOfLastResumeEducation(educationList);
            catch( Exception ex){
                String thwonException = ex.getMessage();
                System.debug('thwonException'+thwonException);
                
                
            }
            
        }
        //
        Test.stopTest();
    }
}