/*
 * @class DAL_ProjectLocation
 * @authors Pablo Dunke
 * @date 02/26/2020
 */

@IsTest
private class DAL_ProjectLocationTest 
{
    // @IsTest
    // static void testGetListProjectLocation() 
    // {
    //     // Create the data
    //     pse__Proj__c project = OPRTestFactory.createProject();

    //     Contact contact = OPRTestFactory.createSimpleContact();
    //     contact.MailingPostalCode = '10800';
    //     contact.MailingStreet = '2nd Street';
    //     contact.MailingCity = 'Los Angeles';
    //     contact.Mailing_State__c = 'California';
    //     contact.MailingCountry = 'United States';
    //     update contact;

    //     Order order = OPRTestFactory.createOrderStateCountry(null, null, null, null, 'United States', 'Texas');
    //     order.Install_At_Contact__c = contact.Id;
    //     order.ShipToContactId = contact.Id;
    //     order.Project__c = project.Id;
    //     update order;

    //     Schema.Location location = new Schema.Location();
    //     location.Account__c = order.AccountId;
    //     location.Status__c = 'Active';
    //     location.Name = contact.MailingStreet + '_' + contact.MailingCity;
    //     insert location;

    //     Schema.Address address = new Schema.Address();
    //     address.Street = contact.MailingStreet;
    //     address.City = contact.MailingCity;
    //     address.Country = contact.MailingCountry;
    //     address.PostalCode = contact.MailingPostalCode;
    //     address.ParentId = location.Id;
    //     address.Primary_Address__c = true;
    //     address.State = contact.Mailing_State__c;
    //     insert address;

    //     Project_Location__c projectLocation = new Project_Location__c();
    //     projectLocation.Address_Type__c = 'Shipping';
    //     projectLocation.Location__c = location.Id;
    //     projectLocation.Project__c = order.Project__c;
    //     projectLocation.Name = location.Name.Abbreviate(80);
    //     projectLocation.Order__c = order.Id;
    //     projectLocation.Default_Address__c = true;
    //     insert projectLocation;

    //     // Set the data
    //     Set<Id> setProjectId = new Set<Id>();
    //     setProjectId.add(project.Id);

    //     // Action
    //     Test.startTest();
    //     List<Project_Location__c> listProjectLocation = DAL_ProjectLocation.getListProjectLocationBySetProjectId(setProjectId);
    //     Test.stopTest();

    //     // Assertion
    //     System.assertEquals(1, listProjectLocation.size());
    // }
}