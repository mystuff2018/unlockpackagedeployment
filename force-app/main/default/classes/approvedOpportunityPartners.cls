public with sharing class approvedOpportunityPartners {
    @AuraEnabled
    public static List <BD_Opportunity_Partner__c> getApprovedPartnersList(String recordId) {
        List<BD_Opportunity_Partner__c> oppPartnerList =  [SELECT Id, Name, Partner_Account__c, Opportunity_Number__c,Partner_Account__r.Name,
        TA_Discussion_Approved_Status__c, TA_Discussion_Approved_Date__c
            FROM BD_Opportunity_Partner__c WHERE TA_Discussion_Approved_Status__c='Completed' AND Opportunity__c =: recordId];
        return oppPartnerList;
    }

}