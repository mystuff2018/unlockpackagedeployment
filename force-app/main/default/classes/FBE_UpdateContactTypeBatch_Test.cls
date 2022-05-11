/**************
 * @ Class Name        : FBE_UpdateContactTypeBatch
 * @ Description       : This class is created to test code coverage for FBE_UpdateContactTypeBatch. Created as part of IDS Feature #7868086.
 * 						 The test class has following methods :
                         1. A test data setup method to create Contacts with null record type.
						 2. A test method to execute batch job for Contact record type update to 'Customer Contact'.
 * @ CreatedBy         : Deloitte Consulting
 * @ CreatedOn         : 07/20/2020
 * @ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created the test class.
*********/
@isTest
private class FBE_UpdateContactTypeBatch_Test {
    /**************
* @MethodName    : setup
* @Trigger       : -
* @Description   : This method creates test data for Batch execution.
***************/
    @testSetup
    static void setup(){
        User lUser =  FBE_UtilityFactory_Test.getIntegrationUser();
        system.runAs(lUser){
            Account account = new Account();
            account.Name = 'Test Account';
            insert account;
            
            List<Contact> contactList = FBE_UtilityFactory_Test.createContact(3,account.Id);
            Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Default_Contact').getRecordTypeId();
            for(Contact eaCon : contactList){
                eaCon.RecordTypeId = recordTypeId;
            }
            insert contactList;
        }
    }
    
    /**************
     * @MethodName    : testBatchExecution
     * @Trigger       : -
     * @Description   : This method invokes batch job and updates contact Record Type to 'Customer Contact'.
     ***************/ 
    static TestMethod void testBatchExecution(){
        Test.startTest();
        FBE_UpdateContactTypeBatch obj = new FBE_UpdateContactTypeBatch();
        database.executeBatch(obj);
        System.assertEquals(0, [SELECT count() FROM Contact WHERE RecordTypeId = '']);
    }

}