/*
 * @test DAL_LocationTest
 * @authors Pablo Dunke
 * @date 02/18/2020
 * @description Data access layer for the Location Object
 */

public with sharing class DAL_Location 
{
    public static List<Schema.Location> getListLocationBySetAccountId(Set<Id> setAccountId)
    {
        List<Schema.Location> listLocation = [SELECT Id
                                                    , Account__c
                                                    , Name
                                                FROM Location 
                                                WHERE Account__c IN: setAccountId];

        return listLocation;
    }
}