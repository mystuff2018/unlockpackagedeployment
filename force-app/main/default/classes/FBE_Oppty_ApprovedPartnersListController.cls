/****************************************************************************************************
* Author         : Dell Team - Oppty [Nirmal Kumar Ravi - STORY 11970896]
* Description    : Previously Approved Partners. 
* Date Created   : 9/2/2022
* Version        : 1.0
* Modification Log           Developer          Last Modified Date           Description
* 1.0                        Nirmal Kumar Ravi       
* 
****************************************************************************************************/
public with sharing class FBE_Oppty_ApprovedPartnersListController {
    @AuraEnabled(cacheable=true)
    public static List <BD_Opportunity_Partner__c> getApprovedPartnersList(String recordId) {
        List<BD_Opportunity_Partner__c> oppPartnerList =  [SELECT Id, Name, Partner_Account__r.Name, Opportunity_Number__c,
                                                           TA_Discussion_Approved_Status__c, TA_Discussion_Approved_Date__c
                                                           FROM BD_Opportunity_Partner__c WHERE TA_Discussion_Approved_Status__c='Completed' AND Opportunity__c =: recordId];
        return oppPartnerList;
    }
}