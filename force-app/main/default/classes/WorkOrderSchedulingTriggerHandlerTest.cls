@isTest
 public class WorkOrderSchedulingTriggerHandlerTest {
	// @isTest static void PopulatePartnerDetailsFieldsTest() { 
        
        // Account a = new Account();
        // a.Name = 'TestAccount';
        // insert a;
        
        // pse__Practice__c practice = new pse__Practice__c();
        // insert practice;
        
         // partner details
        // Partner_Details__c partnerDetails = new Partner_Details__c(Name = 'WISTR', Code__c= 'WISTR', DPS_Type__c = 'WTR', Call_Type__c = 'INSTALL', Country__c = 'US');
        // insert partnerDetails;
        
         // acoount partner preference
        // Account_Partner_Preference__c accountPartner = new Account_Partner_Preference__c(Account__c = a.Id, Country__c = 'US', Practice__c = practice.Id, Partner__c = partnerDetails.Id);
        // insert accountPartner;
        
         // work order
        // WorkOrder wo = new WorkOrder(Status='FF-New', AccountId = a.Id, Country__c = 'US', Partner_Country__c = 'US', CountryCode = 'US');
        // insert wo;
        
        // String countryCode = 'US';
        // String state = 'TX';
        // String city = 'Texas';
        // String zipCode = '10004';
        // String region = 'AMERICAS';
        
        // Set<String> setCountryCode = new Set<String>();
        // Set<Id> setAccountId = new Set<Id>();
        // Set<Id> setPartnerId = new Set<Id>();
        
        // setCountryCode.add(wo.CountryCode);
        // setAccountId.add(wo.AccountId);
        // setPartnerId.add(wo.PartnerName__c);
        
        // Map<String,Account_Partner_Preference__c> mapPrefLines = new Map<String,Account_Partner_Preference__c>();
        // List<Account_Partner_Preference__c> preferredLines = [SELECT Name, Account__c, Partner__c, Country__c 
                                                              // FROM Account_Partner_Preference__c 
                                                              // WHERE Country__C IN :setCountryCode AND Account__c IN :setAccountId];
        // for(Account_Partner_Preference__c pl :preferredLines)
        // {
            // mapPrefLines.put(pl.Country__C + pl.Account__c, pl);
        // }
        
        // Map<String,Partner_Details__c> mapPartnerDetails = new Map<String,Partner_Details__c>([SELECT Id, Name, Code__c, Call_Type__c, DPS_Type__c 
                                                                                               // FROM Partner_Details__c p 
                                                                                               // WHERE p.Id IN :setPartnerId]);
        
        // act
        // Test.startTest();
        // WorkOrderSchedulingTriggerHandler.PopulatePartnerName(wo, mapPrefLines);
        // WorkOrderSchedulingTriggerHandler.PopulatePartnerDetailsFields(wo, mapPartnerDetails);
        // Test.stopTest();
    // }

    // @isTest static void PopulatePartnerDetailsFieldsTest_new() {
        
        // Account a = new Account();
        // a.Name = 'TestAccount';
        // insert a;
        
        // pse__Practice__c practice = new pse__Practice__c();
        // insert practice;
        
         // partner details
        // Partner_Details__c partnerDetails = new Partner_Details__c(Name = 'WISTR', Code__c= 'WISTR', DPS_Type__c = 'WTR', Call_Type__c = 'INSTALL', Country__c = 'US');
        // insert partnerDetails;
        
         // acoount partner preference
        // Account_Partner_Preference__c accountPartner = new Account_Partner_Preference__c(Account__c = a.Id, Country__c = 'US', Practice__c = practice.Id, Partner__c = partnerDetails.Id);
        // insert accountPartner;
        
         // work order
        // List<WorkOrder> wos = new List<WorkOrder>();
        // wos.add(new WorkOrder(Status='FF-New', AccountId = a.Id, Country__c = 'US', Partner_Country__c = 'US', CountryCode = 'US'));
        // insert wos;
        
        // String countryCode = 'US';
        // String state = 'TX';
        // String city = 'Texas';
        // String zipCode = '10004';
        // String region = 'AMERICAS';
        
        // act
        // Test.startTest();
        // WorkOrderSchedulingTriggerHandler.PopulatePartnerDetailsFields_New(wos);
        // Test.stopTest();
    // }
    
    // @isTest static void CheckWorkOrderStatusTest() {
        
        // Account a = new Account();
        // a.Name = 'TestAccount';
        // insert a;
                
        // List<WorkOrder> wo = new List<WorkOrder>();
        
         // work order
        // WorkOrder wolist = new WorkOrder(Status='FF-New', AccountId = a.Id);
        // insert wolist;
            
        // wo.add(wolist);
        
        // act
        // Test.startTest();
        // WorkOrderSchedulingTriggerHandler.CheckWorkOrderStatus(wo);
        // Test.stopTest();
    // }
 }