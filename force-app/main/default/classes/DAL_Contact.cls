/**
 * Created by Romulo_Spier on 1/30/2020.
 * Data access layer for Order Object.
 * This class should be used to concentrate avery SOQL query for Order.
 * Pay attention to implement reusable queries.
 */

public with sharing class DAL_Contact {
    public static Map<Id, Contact> getContactByProjectManagerId(Map<Id, pse__Proj__c> projects) {
        Map<Id,List<Id>> projectsManagersIds = new Map<Id,List<Id>>();
        Map<Id, Contact> projectsManagersContacts = new Map <Id, Contact>();

        for(pse__Proj__c proj : projects.values()){
            if (!projectsManagersIds.containskey(proj.pse__Project_Manager__c)){
                projectsManagersIds.put(proj.pse__Project_Manager__c, new List<Id>());
            }

            List<Id> projManagers = projectsManagersIds.get(proj.pse__Project_Manager__c);
            projManagers.add(proj.Id);
            projectsManagersIds.put(proj.pse__Project_Manager__c, projManagers);
        }

        for (Contact c : [SELECT Id, pse__Salesforce_User__c FROM Contact WHERE Id IN :projectsManagersIds.keySet()]) {
            for(pse__Proj__c proj : projects.values()) {
                projectsManagersContacts.put(proj.Id, c);
            }
        }

        return projectsManagersContacts;
    }

    public static Map<Id, Contact> getMapContactIdContactBySetId(Set<Id> setContactId)
    {
        Map<Id, Contact> mapContact = new Map<Id, Contact>([
            SELECT Id
                    , MailingCity
                    , MailingCountry
                    , MailingPostalCode
                    , MailingState
                    , MailingStreet
                    , Mailing_State__c
                FROM Contact 
                WHERE Id IN: setContactId]);

        return mapContact;
    }
}