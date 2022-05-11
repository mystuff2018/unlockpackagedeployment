public with sharing class WorkOrderSchedulingTriggerHandler {
	//public static Boolean runonce = true;
	
	/*public static void PopulatePartnerName(WorkOrder wo, Map<String,Account_Partner_Preference__c> mapPrefLines) {
        System.debug('[ResourceScheduling: WorkOrderSchedulingTriggerHandler - PopulatePartnerDetailsFields');
        
        System.debug('Work Order Id: ' + wo.Id);
        System.debug('Work Order Status: ' + wo.Status);
        
        if (wo.Id == null && wo.Status != 'FF - New') {
            wo.Status = 'FF - New';
        }
        
        if ((wo.AccountId != null) && (wo.PartnerName__c == null)) {
            System.debug('Get Partner Details by Custommer Preference');
            System.debug('Customer Account Id: ' + wo.AccountId);
            System.debug('Country Code:' + wo.CountryCode);
            
            wo.Partner_Country__c = wo.CountryCode;
            
            Id accountId = wo.AccountId;
            String countryCode = wo.CountryCode;
            
            Account_Partner_Preference__c preferredLine = mapPrefLines.get(wo.CountryCode + wo.AccountId);
            system.debug('preferredLine: ' + preferredLine);
            
            if (preferredLine != null) {
                System.debug(preferredLine);
                System.debug(preferredLine.Partner__c);
                wo.PartnerName__c = preferredLine.Partner__c;
            }
        }
    }
    
    
    public static void PopulatePartnerDetailsFields(WorkOrder wo, Map<String,Partner_Details__c> mapPartnerDetails) {
        if (wo.PartnerName__c != null) {
            // Get the partner details
            Partner_Details__c preferredPartner = mapPartnerDetails.get(wo.PartnerName__c);
            System.debug('preferredPartner: ' + preferredPartner);
            
            if (preferredPartner != null) {
                wo.Partner_Code__c = preferredPartner.Code__C;                    
                wo.CallType__c = preferredPartner.Call_Type__c;
                                    
                if (wo.DPSType__c == null)
                    wo.DPSType__c = preferredPartner.DPS_Type__c;
            }
        }        
    }    

    public static void PopulatePartnerDetailsFields_New(List<WorkOrder> workOrders) {

        setPartnerPreference(workOrders);

        Map<Id, Id> partnerFromWorkOrders = new Map<Id, Id>();

        for(WorkOrder wo : workOrders) {
            partnerFromWorkOrders.put(wo.Id, wo.PartnerName__c);
        }

        Map<Id, Partner_Details__c> partnerDetails = new Map<Id, Partner_Details__c> ([SELECT Id, Name, Code__c, Call_Type__c, DPS_Type__c FROM Partner_Details__c p WHERE p.Id IN :partnerFromWorkOrders.values()]);

        for(WorkOrder wo : workOrders) {
            if (wo.Id == null && wo.Status != 'FF - New') {
                wo.Status = 'FF - New';
            }

            if (wo.PartnerName__c != null) {
                if (partnerDetails.get(wo.PartnerName__c) != null) {
                wo.Partner_Code__c = partnerDetails.get(wo.PartnerName__c).Code__C;                    
                wo.CallType__c = partnerDetails.get(wo.PartnerName__c).Call_Type__c;
                                    
                if (wo.DPSType__c == null)
                    wo.DPSType__c = partnerDetails.get(wo.PartnerName__c).DPS_Type__c;
                }
            }
        }       
    }

    private static void setPartnerPreference(List<WorkOrder> workOrders) {
        Map<Id, String> countryCodeFromWorkOrders = new Map<Id, String>();
        Map<Id, Id> accountFromWorkOrder = new Map<Id, Id>();

        for (WorkOrder workOrder : workOrders) {
            countryCodeFromWorkOrders.put(workOrder.Id, workOrder.CountryCode);
            accountFromWorkOrder.put(workOrder.Id, workOrder.AccountId);
        }

        List<Account_Partner_Preference__c> preferredLines = [
            SELECT Name, Account__c, Partner__c, Country__c 
            FROM Account_Partner_Preference__c 
            WHERE Country__C IN :countryCodeFromWorkOrders.values() AND Account__c IN :accountFromWorkOrder.values()
        ];

        for (WorkOrder workOrder : workOrders) {  
            if ((workOrder.AccountId != null) && (workOrder.PartnerName__c == null)) {
                if (!preferredLines.isEmpty()) {

                    // Account_Partner_Preference__c preferredLine = null;
                    String partnerName = '';

                    for(Account_Partner_Preference__c item : preferredLines) {
                        if(item.Country__C == workOrder.CountryCode && item.Account__c == workOrder.AccountId) {
                            partnerName = item.Partner__c;
                            break;
                        }
                    }

                    workOrder.PartnerName__c = partnerName;
                }
            }
        }
    } */
    
    public static void CheckWorkOrderStatus (List<WorkOrder> wolist) {
        Id recordTypeIdBadge = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Installation Badge').getRecordTypeId();
    	
        for (WorkOrder wo: wolist) {
            if (wo.RecordTypeId == recordTypeIdBadge) {
                System.debug('Work Order Id: ' + wo.Id);
                System.debug('Work Order Status: ' + wo.Status);
                
                if (wo.Id == null && wo.Status != 'FF - New') {
                    wo.Status = 'FF - New';
                }
            }
        }    
    }
}