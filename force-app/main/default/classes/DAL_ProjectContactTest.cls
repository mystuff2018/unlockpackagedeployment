/*
 * @class OrderAssociationProjectContacts
 * @authors Pablo Dunke and Tiago Ferreira
 * @date 02/11/2020
 */

@IsTest
private class DAL_ProjectContactTest 
{
    // @IsTest
    // static void testWithProjectContact() 
    // {
    //     // Create the data
    //     pse__Proj__c project = OPRTestFactory.createProject();
    //     Contact contact = OPRTestFactory.createSimpleContact();

    //     Project_Contact__c projectContact = new Project_Contact__c();
    //     projectContact.Contact_Role__c = 'End User';
    //     projectContact.Contact_Type__c = 'Customer';
    //     projectContact.Contact__c = contact.Id;
    //     projectContact.Primary_Contact__c = false;
    //     projectContact.Project__c = project.Id;
    //     insert projectContact;

    //     // Set the values
    //     Set<Id> setProjectId = new Set<Id>();
    //     setProjectId.add(project.Id);

    //     // Action
    //     Map<Id, List<Project_Contact__c>> result = DAL_ProjectContact.getMapProjectIdListProjectContact(setProjectId);

    //     // Assertion
    //     System.assertEquals(result.get(project.Id).size(), 1);
    // }
}