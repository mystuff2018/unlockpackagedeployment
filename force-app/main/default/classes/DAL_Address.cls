/*
 * @test DAL_AddressTest
 * @authors Pablo Dunke
 * @date 02/26/2020
 * @description Data access layer for the Address Object
 */

public with sharing class DAL_Address 
{
    public static List<Schema.Address> getListAddressBySetParentId(Set<Id> setParentId)
    {
        List<Schema.Address> listAddress = [SELECT Id
                                                    , City
                                                    , Country
                                                    , ParentId
                                                    , PostalCode
                                                    , Primary_Address__c
                                                    , State 
                                                    , Street
                                                FROM Address 
                                                WHERE ParentId IN: setParentId];
                                                    
        return listAddress;
    }
}