/*
 * @test DAL_ProjectContactTest
 * @authors Pablo Dunke and Tiago Ferreira
 * @date 02/10/2020
 * @description Data access layer for the Project Contact Object
 */

public with sharing class DAL_ProjectContact 
{
    public static Map<Id, List<Project_Contact__c>> getMapProjectIdListProjectContact(Set<Id> setProjectId)
    {
        List<Project_Contact__c> listProjectContact = [SELECT Id
                                                                , Contact__c
                                                                , Primary_Contact__c 
                                                                , Project__c
                                                            FROM Project_Contact__c 
                                                            WHERE Project__c IN: setProjectId];

        Map<Id, List<Project_Contact__c>> mapProjectIdProjectContact = new Map<Id, List<Project_Contact__c>>();
        for(Project_Contact__c forProjectContact: listProjectContact)
        {
            if(!mapProjectIdProjectContact.containsKey(forProjectContact.Project__c))
            {
                mapProjectIdProjectContact.put(forProjectContact.Project__c, new List<Project_Contact__c>());
            }

            List<Project_Contact__c> forListProjectContact = mapProjectIdProjectContact.get(forProjectContact.Project__c);

            forListProjectContact.add(forProjectContact);

            mapProjectIdProjectContact.put(forProjectContact.Project__c, forListProjectContact);
        }

        return mapProjectIdProjectContact;
    }
}