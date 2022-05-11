@isTest 
Public Class ContactCostUpdateTest {
    @testSetup
    public static void setup() {
        pse__Work_Calendar__c testWorkCal = MDF_WorkCalendarFactory.start()
        	.name('Work Calendar Test')
            .create();
        
		pse__Region__c testRegion = MDF_RegionFactory.start()
           .create();
        
		pse__Rate_Card__c testRateCard = MDF_RateCardFactory.start()
            .role('Project Manager Analyst')
            .averageCostRate(5)
            .relatedRegion(testRegion)
            .create();
        
        pse__Proj__c testProj = MDF_ProjectTemplateFactory.start()
            .create();
            
        Contact testContact = MDF_ContactFactory.start()
            .relatedRegion(testRegion)
            .relatedWorkCalendar(testWorkCal)
            .resourceRole('Project Manager Analyst')
            .isResource(true)
            .create();

    }
    
    @isTest
    public static void updateContact(){
        Test.startTest();
        List<Contact> contactList = new List<Contact>();
        Id PSArecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PSA_Resource').getRecordTypeId();
        for(Contact c : [SELECT Id, pse__Default_Cost_Rate__c,pse__Region__c,RecordTypeId FROM Contact WHERE Name = 'Test Contact']){
            c.RecordTypeId = PSArecordTypeId;
            contactList.add(c);
        }
        update contactList;
        ContactCostUpdateSchedulable contactSchedul = new ContactCostUpdateSchedulable();
        String cronExp = '0 0 0 15 3 ? 2022';
        String jobId = System.schedule('myJobTestContactCostUpdate', cronExp, contactSchedul);
        contactSchedul.execute(null);
        Test.stopTest();
        
        List<pse__Rate_Card__c> rateCardList = new List<pse__Rate_Card__c>([SELECT Id, pse__Average_Cost_Rate__c,pse__Region__c FROM pse__Rate_Card__c WHERE pse__Role__c = 'Project Manager Analyst']);
        List<Contact> contactUpdated = new List<Contact>([SELECT Id, pse__Default_Cost_Rate__c,pse__Region__c,RecordTypeId FROM Contact WHERE Name = 'Test Contact']);
        System.assertEquals(rateCardList[0].pse__Average_Cost_Rate__c,contactUpdated[0].pse__Default_Cost_Rate__c);
    } 
}