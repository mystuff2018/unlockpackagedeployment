/*
 * @test DAL_ProjectLocationTest
 * @authors Pablo Dunke
 * @date 02/18/2020
 * @description Data access layer for the Project Location Object
 */

public with sharing class DAL_ProjectLocation 
{
    public static List<Project_Location__c> getListProjectLocationBySetProjectId(Set<Id> setProjectId)
    {
        List<Project_Location__c> listProjectLocation = [SELECT Id
                                                                , Location__c
                                                                , Address_Type__c
                                                                , Default_Address__c
                                                                , Order__c
                                                                , Order__r.Id
                                                                , Name
                                                                , Project__c 
                                                            FROM Project_Location__c 
                                                            WHERE Project__c IN: setProjectId];

        return listProjectLocation;
    }
}