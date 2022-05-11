/*
 * @class DAL_Address
 * @authors Pablo Dunke
 * @date 02/26/2020
 */

@IsTest
private class DAL_AddressTest 
{
    @IsTest
    static void testGetListAddress() 
    {
        // Create the data
        Account account = OPRTestFactory.createSimpleAccount();

        Contact contact = OPRTestFactory.createSimpleContact();
        contact.MailingPostalCode = '18730';
        contact.MailingStreet = '3rd Street';
        contact.MailingCity = 'Dallas';
        contact.Mailing_State__c = 'Texas';
        contact.MailingCountry = 'United States';
        update contact;

        Schema.Location location = new Schema.Location();
        location.Name = 'Location';
        location.Status__c = 'Active';
        location.Account__c = account.Id;
        insert location;

        Schema.Address address = new Schema.Address();
        address.Street = contact.MailingStreet;
        address.City = contact.MailingCity;
        address.Country = contact.MailingCountry;
        address.PostalCode = contact.MailingPostalCode;
        address.ParentId = location.Id;
        address.Primary_Address__c = true;
        address.State = contact.Mailing_State__c;
        insert address;

        // Set the data
        Set<Id> setLocationId = new Set<Id>();
        setLocationId.add(location.Id);

        // Action
        Test.startTest();
        List<Schema.Address> listAddress = DAL_Address.getListAddressBySetParentId(setLocationId);
        Test.stopTest();

        // Assertion
        System.assertEquals(1, listAddress.size());
    }
}