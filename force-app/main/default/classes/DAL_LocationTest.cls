/*
 * @class DAL_Location
 * @authors Pablo Dunke
 * @date 02/26/2020
 */

@IsTest
private class DAL_LocationTest 
{
     @IsTest
    static void testGetListLocation() 
     {
        // Create the data
        Account account = OPRTestFactory.newAccount('Test Account', '2020');

       Schema.Location location = new Schema.Location();
       location.Name = 'Location';
        location.Status__c = 'Active';
        location.Account__c = account.Id;
        insert location;

        // Set the data
         Set<Id> setAccountId = new Set<Id>();
         setAccountId.add(account.Id);

         // Action
         Test.startTest();
         List<Schema.Location> listLocation = DAL_Location.getListLocationBySetAccountId(setAccountId);
         Test.stopTest();

         // Assertion
         System.assertEquals(1, listLocation.size());
     }
}