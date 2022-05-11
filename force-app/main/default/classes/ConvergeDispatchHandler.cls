/* -----------------------------------------------------------------------------------------------------------------------
Name:       ConvergeDispatchHandler
Description:  
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
08/29/2019     1.0    Deepa Lakamanhalli PPID validation for Converged - Story #6634882
06-Sept-19     1.1    Gopi               6723325 KYHD & KYC behaviour
09/23/2019     1.2    Deepa              6681427,6681438, DD,DR - added Entitlement fields
09/23/2019     1.3    RodrigoC           7278849,6270324,7278849 shipping address details
10/01/2019     1.4    Ramzil             7339014 Update Event Code for Service Events
18/01/2019     1.5    Himani Rawat       7460373 Updated getDispatchDefaults method to query CompleteCareOption__c.
                                         - added entitlementADDetails method    
10/30/2019     1.6    RodrigoC           added new input parameters to getSpecialOptions
11/06/2019     1.7    Ramzil             7375991 Added isGCCuser method 
11/09/2019     1.8    Rodrigo            modified getWorkOrderData for story 7549975
17/12/2019     1.9    Archana            7460373 - added createAccidentalDamageAlerts method
Mar-23-2020	   2.0    Rodrigo	         7932222 - repairCenterAccess
26/03/2020     2.1    Joao Carlos Pereira   Added all Alternate Address fields for the getWorkOrder
30/03/2020     2.2    Praful             createServiceAppointment: Story 8258067: Added Service_Category__c, Billable__c to WO query  ==> Defect 8349562: Added address fields in query
14/04/2020     2.3    Tamil Lakshmi      US8318921 changes added new method for Reschedule 
17-Apr-2019    2.4    Rodrigo Carpio        8422207 Added ISPAltAccount__c field for retrieving them for Mail-In 																															 
23-Apr-2020    2.5    Tamil Lakshmi      US8326509 Added UpdateReschedulingDates method for Updating Helper n Part Pickup event
24-Apr-2020    2.6    Krishna           US6269291 Added method getPartDeliveryLocation for the Part delivery Location Lookup
--------------------------------------------------------------------------------------------------------------------------
*/
public with sharing class ConvergeDispatchHandler 
{
    //@TestVisible private static list < EntitlementADDetails__x > mockentitlementdata = new List < EntitlementADDetails__x > ();
//    @TestVisible private static String calendarDownload = 'N';
//    @TestVisible private static String pageType = 'SRDETAIL';
//    @TestVisible private static List < ESupportUrlResponse__x > mockedESupportURLResponse = new List < ESupportUrlResponse__x > ();
//    // code added or move for test coverage Rodrigo - starts here
//    @TestVisible private static List < ServiceLevelSlot__x > mockedServiceLevelSlot = new List < ServiceLevelSlot__x > ();
//    @TestVisible private static List < ConvergedAvailableOptions__x > mockedServiceOptions = new List < ConvergedAvailableOptions__x > ();
//    @TestVisible private static List < SpecialOptions__x > mockedSpecialOptions = new List < SpecialOptions__x > ();
//    @TestVisible private static List < DispatchDSPDLP__c > mockedDSPDLP = new List < DispatchDSPDLP__c > ();
//    //Krishna
//    @TestVisible private static List < PartDeliveryLocation__x > mockedPartDeliveryLocation = new List < PartDeliveryLocation__x > ();
//    private static id gccAddressId = null;   
//    private static string addressLine1 = null;
//    private static string addressLine2 = null;
//    private static string addressLine3 = null;
//    private static string addressLine4 = null;
//    private static string cityValue = null;
//    private static string shipcountryCode = null;
//    private static string postalCode = null;
//    private static string stateValue = null;
//    private static string countryCode = null;
//    private static boolean getAssetAddress = true;
//    @TestVisible private static Id mockGSCVAddressId = null;
//    // code added or move for test coverage Rodrigo - ends here
//    
//    public class ServiceAppointmentWrap 
//    {        
//        @AuraEnabled public WorkOrder workorderRecord{get;set;}
//        @AuraEnabled public List<Preference__c> preferenceRecords{get;set;}
//        @AuraEnabled public Asset assetRecord{get;set;}
//        @AuraEnabled public Case caseRecord{get;set;}
//        @AuraEnabled public Address_Data_GCC__c gccRecord{get;set;}
//        @AuraEnabled public String workorderTimeZone{get;set;}
//        public ServiceAppointmentWrap()
//        {
//            workorderRecord = new WorkOrder();
//            preferenceRecords = new List<Preference__c>();
//            assetRecord = new Asset();
//            caseRecord = new Case();
//            gccRecord = new Address_Data_GCC__c();
//            workorderTimeZone = '';
//        }
//    }
//    
//    public class SubmitWorkOrderWrap 
//    {
//        @AuraEnabled public WorkOrder workorderRecord{get;set;}
//        @AuraEnabled public Boolean checkInstructions{get;set;}
//        @AuraEnabled public ServiceAppointment appointmentRecord{get;set;}
//        @AuraEnabled public user userRecord{get;set;}
//        @AuraEnabled public Boolean checkPeferenceRecord{get;set;}
//        @AuraEnabled public String isAssetOnHoldForCSWO{get;set;}
//        @AuraEnabled public Boolean isdeferral{get;set;}
//        public SubmitWorkOrderWrap()
//        {
//            workorderRecord = new WorkOrder();
//            checkInstructions = false;
//            appointmentRecord = new ServiceAppointment();
//            userRecord = new User();
//            checkPeferenceRecord = false;
//            isAssetOnHoldForCSWO = '';
//        }
//    }
//    
//    public class OverrideEntitlementWrap 
//    {
//        @AuraEnabled public WorkOrder workorderRecord{get;set;}
//        @AuraEnabled public Boolean isElevatedUser{get;set;}
//        @AuraEnabled public DispatchDefaults__c dispatchDefaultsRecord{get;set;}
//        @AuraEnabled public List<String> LOB{get;set;}
//        @AuraEnabled public Boolean repairCenterAccess{get;set;}
//        public OverrideEntitlementWrap ()
//        {
//            workorderRecord = new WorkOrder();
//            isElevatedUser = false;
//            dispatchDefaultsRecord = new DispatchDefaults__c();
//            LOB = new List<String>();
//            repairCenterAccess = false;
//        }
//    }
//    
//    public class ServiceOptionWrap
//    {
//        @AuraEnabled public string responseCode{get;set;}
//        @AuraEnabled public string serviceOptions{get;set;}
//        public ServiceOptionWrap(){
//            string responseCode;
//            string serviceOptions;
//        }
//        
//    }
//    
//    /*-- 
//    Component : getRecordsToSubmitWorkOrder
//    Description: this will get all the records related to WorkOrder submits
//    Change Log:
//    ===============================================================================================
//    Date              Author            UserStory#           Change Description
//    ===============================================================================================
//    19-Nov-2019       Partha            6793165              Initial Version
//    08-Jan-2020       Roshni            defect 7866229            v2
//
//    */
//    @AuraEnabled
//    public static OverrideEntitlementWrap getRecordsToOverrideEntitlement(Id workOrderId)
//    {
//        //try
//        //{
//            OverrideEntitlementWrap entitlementWrap = new OverrideEntitlementWrap();
//            entitlementWrap.workorderRecord = ConvergeDispatchHandler.getWorkOrder(workOrderId);
//            entitlementWrap.isElevatedUser = ConvergeDispatchHandler.userProfile(workOrderId);
//            entitlementWrap.dispatchDefaultsRecord = ConvergeDispatchHandler.getDispatchDefaults(workOrderId);
//            entitlementWrap.LOB = ConvergeDispatchHandler.getProductClassification(entitlementWrap.workorderRecord.LOB__c); 
//        
//            return entitlementWrap;
//        //}
//        //catch(Exception e) 
//        //{
//        //    ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'getRecordsToOverrideEntitlement', 'Converge Dispatch');
//        //    return null;
//        //}    
//    }
//
//
//    /*-- 
//    Component : getRecordsToSubmitWorkOrder
//   
//    Description: this will get all the records related to WorkOrder submits
//    Change Log:
//    ===============================================================================================
//    Date              Author            UserStory#           Change Description
//    ===============================================================================================
//    19-Nov-2019       Partha            6793165              Initial Version
//    08-Jan-2020       Roshni            defect 7866229            v2
//    */
//    @AuraEnabled
//    public static SubmitWorkOrderWrap getRecordsToSubmitWorkOrder(Id woId, Id userId, Id assetId)
//    {
//        //try
//        //{
//            Boolean isHES = ConvergeDispatchHandler.checkHES(woId);
//            SubmitWorkOrderWrap submitWrap = new SubmitWorkOrderWrap();
//            submitWrap.workorderRecord = ConvergeDispatchHandler.getWorkOrder(woId);
//            submitWrap.appointmentRecord = ConvergeDispatchHandler.getServiceAppointment(woId);
//            submitWrap.checkInstructions = ConvergeDispatchHandler.checkForInstruction(woId);
//            submitWrap.userRecord = ConvergeDispatchHandler.getSandASUserId(userId);
//            submitWrap.checkPeferenceRecord = ConvergeDispatchHandler.getContactPreference(woId);
//            submitWrap.isdeferral = ConvergeSchedulingHandler.getDeferralAccess(woId);
//            //bypass AssetHoldStatus if the Asset is HES
//            if(!isHES) submitWrap.isAssetOnHoldForCSWO = ConvergeDispatchHandler.getAssetHoldStatus(assetId);
//            return submitWrap;
//        //}
//        //catch(Exception e) 
//        //{
//        //    ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'getRecordsToSubmitWorkOrder', 'Converge Dispatch');
//        //    return null;
//        //}    
//    }
//
//    //method to check is HES asset, to bypass AssetHoldStatus check for HES
//    public static Boolean checkHES(Id workOrderId) {
//        List<WorkOrder> wo = [SELECT Id, EMC_Asset_Identifier__c FROM WorkOrder WHERE Id = :workOrderId LIMIT 1];
//        if(!wo.isEmpty()) {
//            if(wo[0].EMC_Asset_Identifier__c != null && wo[0].EMC_Asset_Identifier__c) return true;
//        }
//        return false;
//    }
//
//
//    /*-- 
//    Component : getWorkOrder
//   
//    Description: this will get the details of WorkOrder 
//    Change Log:
//    ===============================================================================================
//    Date              Author            UserStory#           Change Description
//    ===============================================================================================
//    17-Apr-2019       Rodrigo C         8422207             Added ISPAltAccount__c,Shipping_Recipient_Contact__r.FirstName, Shipping_Recipient_Contact__r.LastName field for retrieving them for Mail-In 
//    22-Aprl-2020      Prakhar Sinha     8362757             Added Latitude, Longitude              
//    */
//    @AuraEnabled
//    public static WorkOrder getWorkOrder(Id workorderId){
//        try
//        {   
//            //Himani
//            WorkOrder workOrderRecord = [ Select Id, Bill_To__c, Bill_To_Order_Number__c, IsConvergeWorkOrder__c, EMC_Asset_Identifier__c, LOB__c, Out_of_Warranty__c, DSP_Override_Request__c, CheckForServiceTypeEqualsPartsOnly__c,IsSOChange__c,
//                                          LineItemCount,CheckForServiceTypeEqualsLaborOnly__c, Labor_Source__c,Shipping_Recipient_Contact__c,Need_by_Date__c, Need_by_Time__c, DeltaTimezone__c,
//                                          Service_Type__c, Service_Option__c, Special_Option__c, Product_Classification__c, DASP__c, Billable__c, Asset_Country__c, WorkOrderNumber, ISPAltAccount__c,Shipping_Recipient_Contact__r.FirstName, Shipping_Recipient_Contact__r.LastName,
//                                          DSP__c, Status, Sub_Status__c, AccountId, ServiceTag__c, AD_Count__c, Complete_Care_Option__c,Reason_for_Damage__c, WO_Type__c, DPS_BUID__c, FSD_Oconus_Federal_Flag__c,
//                                          FSD_Oconus_Federal_Flag_Int__c, City_APJ__c, State_APJ__c, Shipping_Country__c, Zip_Code__c, Labor_Selected_Check__c,CheckForServiceTypeEqualsRepairCenter__c,
//                                          Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Line_4__c, Asset.Manufacturer_No__c, Asset.SerialNumber, Asset.Country__c,
//                                          Eligible_for_Site_Access_Consolidation__c, Account.Customer_Confirmation_Required__c, Delivery_Option__c, Delivery_Contact__c, Delivery_Contact_Email__c, Delivery_Contact_Phone__c, CountryCode,
//                                          Account.Site_Access_Required__c, CaseId, Case.Priority, Case.Case_Type__c, Case.Work_Order_Type__c, DPS_Region__c, S_AS_Queue__c,Part_Access_Ticket_Required__c,Required_on_Shipping_Label__c,Access_Ticket_Number__c,Required_post_Waybill__c,
//                                          Account.Site_Access_Requirement_Type__c, OwnerId, ServiceAgent_User__c, Ground_Shipment_Flag__c, Override_Ground_Shipment__c, DSP_Override_Reason__c,
//                                          Alternate_Return_Address_Checkbox__c, Alternate_Return_Street__c, Alternate_Return_Street_2__c, Alternate_Return_City__c, Alternate_Return_State__c, Alternate_Return_Postal_Code__c, Push_address_update_to_asset__c, Alternate_Return_Country__c, Service_Category__c,Latitude,Longitude
//                                         FROM WorkOrder Where Id =: workorderId Limit 1 ];
//            system.debug('workOrderRecord ' + workOrderRecord);
//            //if(workOrderRecord != Null){
//                return workOrderRecord;
//            //}
//            //else
//            //    return null;
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'getWorkOrder', 'Converge Dispatch');
//            return null;
//        }
//    }
//    
  @AuraEnabled
   public static Boolean getContactPreference(Id workorderId)
    {
//        try
//        {
           Boolean hasPermanentSiteAccess = false;
//            WorkOrder woRecord = [ Select Id, AccountId, Account.Max_Min_Resource_Limit__c, 
//                                   Account.Site_Access_Required__c, Account.Customer_Confirmation_Required__c,
//                                   Account.Site_Access_Requirement_Type__c 
//                                   From WorkOrder Where Id =: workorderId ];
//            
//            if(woRecord.Account.Site_Access_Required__c == 'Yes' && 
//               woRecord.Account.Customer_Confirmation_Required__c == 'Yes' && 
//               woRecord.Account.Site_Access_Requirement_Type__c == 'Labor' && 
//               Integer.valueOf(woRecord.Account.Max_Min_Resource_Limit__c) <= [ Select Count() From Preference__c Where Preference_Type__c = 'Permanent Access Resource' And Account__c =: woRecord.AccountId ])
//                hasPermanentSiteAccess = true;
//            
           return hasPermanentSiteAccess;
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'getContactPreference', 'Converge Dispatch');
//            return null;
//        }
    }
//    public static ID getGCCAddressDetails(string countryCode, string stateCode, string city, string postalCode)
//        /*--
//Component : getGCCAddressDetails
//Description: this will handle the logic get the GSCV address info
//Change Log:
//===============================================================================================
//Date                Author                  UserStory#               Change Description
//===============================================================================================
//23-Sep-2019       Rodrigo Carpio            6270324/7241240/7278849                   Initial Version
//*/
//    {
//        try {
//            ID gccAddressID = null;
//            List<Address_Data_GCC__c> gccRecords = new List<Address_Data_GCC__c>();
//            gccRecords = [ Select Id, COUNTRYNAME__c, COUNTRYCODE__c, STATENAME__c, STATECODE__c, Name, POSTCODE__c
//                          From Address_Data_GCC__c 
//                          Where COUNTRYCODE__c =: countryCode 
//                          //And STATECODE__c =: stateCode 
//                          AND Name =: city 
//                          AND POSTCODE__c =: postalCode Limit 1 ];
//            
//
//            if(!gccRecords.isEmpty())
//            {
//                system.debug('gccRecords[0].Id ' + gccRecords[0].Id);
//                gccAddressID = gccRecords[0].Id;
//            }
//            
//            return gccAddressID;
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'getGCCAddressDetails', 'Converge Dispatch');
//            return null;
//        }
//    }
//    
//    /*--
//     * getServiceAddressInfo
//     * --
//     * ===============================================================================================
//Date                Author                  UserStory#               Change Description
//===============================================================================================
//20-Sep-2019       Rodrigo Carpio            6270324/7241240/7278849                   Initial Version
//
//    @TestVisible
//    private static void getServiceAddressInfo(Id workorderId, Id accId)
//    {
//        system.debug('inside getServiceAddressInfo1');
//        List<Account> accBillAddress = new List<Account>();
//        // get account billing address
//        accBillAddress = [SELECT Id, BillingCity, BillingCountry, BillingCountryCode, BillingPostalCode, BillingState, BillingStateCode,
//                            BillingStreet, Billing_Country__c, Billing_State__c FROM Account WHERE Id =: accId];
//            if(!accBillAddress.isEmpty() && (accBillAddress[0].Billing_Country__c != Null ||  accBillAddress[0].BillingCountry != Null) && accBillAddress[0].BillingStreet != null)
//
//                cityValue = accBillAddress[0].BillingCity;
//                postalCode = accBillAddress[0].BillingPostalCode;
//                stateValue = accBillAddress[0].BillingState;
//                addressLine1 = accBillAddress[0].BillingStreet;
//                addressLine2 = accBillAddress[0].BillingStreet;
//                addressLine3 = '';
//                addressLine4 = '';
//                countryCode = accBillAddress[0].BillingCountryCode;
//                shipcountryCode = accBillAddress[0].BillingCountryCode;
//                system.debug('inside getServiceAddressInfo1 accBillAddress[0] ' + accBillAddress[0]);
//                gccAddressId = getGCCAddressDetails(accBillAddress[0].Billing_Country__c, accBillAddress[0].BillingStateCode, accBillAddress[0].BillingCity, accBillAddress[0].BillingStateCode);            
//                system.debug('inside getServiceAddressInfo1 accBillAddress[0] ' + gccAddressId);
//                if(gccAddressId!=null) {   
//                    getAssetAddress = false;
//                } else {
//                    if (countryCode != null && addressLine1 !=null && (stateValue!=null || cityValue != null) )
//                        getAssetAddress = false;
//                }
//            }
//
//   /* @TestVisible
//     private static void getServiceAddressInfo(Id workorderId, Id accId)
//    {
//        system.debug('inside getServiceAddressInfo1');
//        List<Account> accBillAddress = new List<Account>();
//        // get account billing address
//        accBillAddress = [SELECT Id, BillingCity, BillingCountry, BillingCountryCode, BillingPostalCode, BillingState, BillingStateCode,
//                            BillingStreet, Billing_Country__c, Billing_State__c FROM Account WHERE Id =: accId];
//            if(!accBillAddress.isEmpty() && (accBillAddress[0].Billing_Country__c != Null ||  accBillAddress[0].BillingCountry != Null) && accBillAddress[0].BillingStreet != null)
//{
//
//        cityValue = accBillAddress[0].BillingCity;
//                postalCode = accBillAddress[0].BillingPostalCode;
//                stateValue = accBillAddress[0].BillingState;
//                addressLine1 = accBillAddress[0].BillingStreet;
//                addressLine2 = accBillAddress[0].BillingStreet;
//                addressLine3 = '';
//                addressLine4 = '';
//                countryCode = accBillAddress[0].BillingCountryCode;
//                shipcountryCode = accBillAddress[0].BillingCountryCode;
//                system.debug('inside getServiceAddressInfo1 accBillAddress[0] ' + accBillAddress[0]);
//                gccAddressId = getGCCAddressDetails(accBillAddress[0].Billing_Country__c, accBillAddress[0].BillingStateCode, accBillAddress[0].BillingCity, accBillAddress[0].BillingStateCode);            
//                system.debug('inside getServiceAddressInfo1 accBillAddress[0] ' + gccAddressId);
//                if(gccAddressId!=null) {   
//                    getAssetAddress = false;
//                } else {
//                    if (countryCode != null && addressLine1 !=null && (stateValue!=null || cityValue != null) )
//                        getAssetAddress = false;
//                }             
//            }
//            else {
//                if (countryCode != null && addressLine1 !=null && (stateValue!=null || cityValue != null) )
//                    getAssetAddress = false;            }
//        }
//    }
//    } */
//    
//    @AuraEnabled 
//    public static WorkOrder updateShippingDetails(Id workorderId)
//        /*--
//Component : updateShippingDetails
//Description: this will handle the logic to set shipping details information
//Change Log:
//===============================================================================================
//Date                Author                  UserStory#               Change Description
//===============================================================================================
//20-Sep-2019       Rodrigo Carpio            6270324/7241240/7278849                   Initial Version
//*/
//    {
//        List<WorkOrder> workorderRecords = new List<WorkOrder>();
//        List<Preference__c> preferenceRecords = new List<Preference__c>();
//        List<Account> accountRecords = new List<Account>();
//        List<Address_Data_GCC__c> gccRecords = new List<Address_Data_GCC__c>();
//        List<Asset> assetRecords = new List<Asset>();
//        try {
//            workorderRecords = [ Select AccountId, CaseId, AssetId, CheckForServiceTypeEqualsLaborOnly__c, City_APJ__c, City, Zip_Code__c,
//                                ContactId, AdditionalContactId__c, EMC_Asset_Identifier__c, Shipping_City_State_Zip_Code__c, Address_Line_1__c
//                                From workOrder Where Id =: workorderId Limit 1 ];
//            
//            if (!workorderRecords.isEmpty() && workorderRecords[0].EMC_Asset_Identifier__c) {
//                preferenceRecords = [ Select Id, Preference_Type__c, Contact__c, Account__c 
//                                     From Preference__c Where Account__c =: workorderRecords[0].AccountId and Preference_Type__c='Shipping Contact' ];
//                system.debug('preferenceRecords ' + preferenceRecords);
//                accountRecords = [ Select Id, ShippingStreet, ShippingCity, ShippingCountryCode, ShippingState, ShippingStateCode, ShippingCountry, ShippingPostalCode, Shipping_County__c, Shipping_Street_2__c, Shipping_State__c, Shipping_country__c
//                                  From Account Where Id =: workorderRecords[0].AccountId ];
//                system.debug('accountRecords ' + accountRecords);
//            }
//            
//            if (workorderRecords != null)
//            {
//            // Shipping Address logic
//                /*if (!workorderRecords[0].EMC_Asset_Identifier__c) { // populate CS shipping address
//// asset level service address
//assetRecords = [ Select Id, X24_Hour_Contact__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Line_4__c,
//Country__c, State__c, City__c, Street__c, Zip__c 
//From Asset Where Id =: workorderRecords[0].AssetId Limit 1 ];
//system.debug('assetRecords ' + assetRecords);
//if(assetRecords[0].Country__c != Null && assetRecords[0].State__c != Null)
//{
//gccAddressId = getGCCAddressDetails(assetRecords[0].Country__c, assetRecords[0].State__c, assetRecords[0].City__c, assetRecords[0].Zip__c);
//if(gccAddressId!=null)
//{
//system.debug('gccAddressId ' + gccAddressId);        
//workorderRecords[0].Shipping_Address_Line_1__c = assetRecords[0].Address_Line_1__c;
//workorderRecords[0].Shipping_Address_Line_2__c = assetRecords[0].Address_Line_2__c;
//workorderRecords[0].Shipping_Address_Line_3__c = assetRecords[0].Address_Line_3__c;
//workorderRecords[0].Shipping_Address_Line_4__c = assetRecords[0].Address_Line_4__c;
//workorderRecords[0].Shipping_City_State_Zip_Code__c = gccAddressId;
//workorderRecords[0].Shipping_Country__c = assetRecords[0].Country__c;
//if(assetRecords[0].Address_Line_1__c <> null){
//workorderRecords[0].Street = assetRecords[0].Address_Line_1__c;
//}
//else{
//
//}
//if(assetRecords[0].Address_Line_2__c <> null){
//
//}
//system.debug('workorderRecords ' + workorderRecords[0]);
//}
//} 
//}
//else*/
//                system.debug('workorderRecords[0].EMC_Asset_Identifier__c ' + workorderRecords[0].EMC_Asset_Identifier__c);                                                                                                        
//                if (workorderRecords[0].EMC_Asset_Identifier__c)
//                { // populate HES shipping address
//                    //system.debug('preferenceRecords[0] ' + preferenceRecords[0]);
//                    // set the shipping recipient contact information
//                    if (workorderRecords[0].EMC_Asset_Identifier__c && preferenceRecords!=null && preferenceRecords.size()>0)
//                    {
//                        system.debug('preferenceRecords[0] ' + preferenceRecords[0].Contact__c);
//                        if (preferenceRecords[0].Contact__c != null)
//                            workorderRecords[0].Shipping_Recipient_Contact__c = preferenceRecords[0].Contact__c;
//                        else
//                            workorderRecords[0].Shipping_Recipient_Contact__c = workorderRecords[0].ContactId;
//                    }
//                    else{
//                        getServiceAddressInfo(workorderId, workorderRecords[0].AccountId);
//                        workorderRecords[0].Shipping_Recipient_Contact__c = workorderRecords[0].ContactId;
//
//                    //system.debug('accountRecords[0] ' + accountRecords[0]);
//                    system.debug('accountRecords[0] ' + accountRecords[0].Shipping_country__c);
//                    system.debug('accountRecords[0] ' + accountRecords[0].ShippingCountry);
//                    system.debug('accountRecords[0] ' +  accountRecords[0]);
//                    // set the shipping address information
//                    if(!accountRecords.isEmpty() && (accountRecords[0].Shipping_country__c != Null ||  accountRecords[0].ShippingCountry != Null) && accountRecords[0].ShippingStreet != null)
//                    {
//                        cityValue = accountRecords[0].ShippingCity;
//                        postalCode = accountRecords[0].ShippingPostalCode;
//                        stateValue = accountRecords[0].ShippingState;
//                        addressLine1 = accountRecords[0].ShippingStreet;
//                        addressLine2 = accountRecords[0].ShippingStreet;
//                        addressLine3 = accountRecords[0].Shipping_Street_2__c;
//                        addressLine4 = accountRecords[0].Shipping_Street_2__c;
//                        countryCode = accountRecords[0].ShippingCountryCode;
//                        shipcountryCode = accountRecords[0].ShippingCountryCode;
//                        system.debug('accountRecords[0] ' + accountRecords[0]);
//                        gccAddressId = getGCCAddressDetails(accountRecords[0].Shipping_country__c, accountRecords[0].ShippingStateCode, accountRecords[0].ShippingCity, accountRecords[0].ShippingPostalCode);            
//                        system.debug('accountRecords[0] ' + gccAddressId);
//                        if(gccAddressId!=null)
//                        {   
//                            //workorderRecords[0].Shipping_City_State_Zip_Code__c = gccAddressId;
//                            getAssetAddress = false;
//                        }
//                        else {
//                            if (countryCode != null && addressLine1 !=null && (stateValue!=null || cityValue != null) )
//                                getAssetAddress = false;
//                        }
//                    }
//                    else {                
//                        // line of has been move into a function for code coverage
//                        getServiceAddressInfo(workorderId, workorderRecords[0].AccountId);
//                        
//                    }    
//                }
//                
//                if (getAssetAddress) { // asset level service address
//                    assetRecords = [ Select Id, X24_Hour_Contact__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Line_4__c,
//                                    Country__c, State__c, City__c, Street__c, Zip__c 
//                                    From Asset Where Id =: workorderRecords[0].AssetId Limit 1 ];
//                    system.debug('updateShippingDetails getAssetAddress ' + assetRecords);
//                    system.debug('updateShippingDetails getAssetAddress ' + assetRecords[0].Country__c);
//                    system.debug('updateShippingDetails getAssetAddress ' + assetRecords[0].State__c);
//                    
//                    if(assetRecords[0].Country__c != Null)
//                    {
//                     /*cityValue = assetRecords[0].City__c;
//postalCode = assetRecords[0].Zip__c;
//stateValue = assetRecords[0].State__c;
//addressLine1 = assetRecords[0].Address_Line_1__c;
//addressLine2 = assetRecords[0].Address_Line_2__c;
//addressLine3 = assetRecords[0].Address_Line_3__c;
//addressLine4 = assetRecords[0].Address_Line_4__c;
//countryCode = assetRecords[0].Country__c;
//system.debug('gccAddressId asset address ' + assetRecords[0]);
//gccAddressId = getGCCAddressDetails(assetRecords[0].Country__c, assetRecords[0].State__c, assetRecords[0].City__c, assetRecords[0].Zip__c);
//if(gccAddressId!=null)
//{
//system.debug('gccAddressId asset address ' + gccAddressId);    
////workorderRecords[0].Shipping_City_State_Zip_Code__c = gccAddressId;
////system.debug('workorderRecords asset address ' + workorderRecords[0]);                                    
//}*/
//                        workorderRecords[0].Address_Line_1__c = assetRecords[0].Address_Line_1__c;
//                        workorderRecords[0].Address_Line_2__c = assetRecords[0].Address_Line_2__c;
//                        workorderRecords[0].Address_Line_3__c = assetRecords[0].Address_Line_3__c;
//                        workorderRecords[0].Address_Line_4__c = assetRecords[0].Address_Line_4__c;
//
//
//
//
//
//
//
//
//
//                        if(System.label.LatamCountries.contains(assetRecords[0].Country__c))
//                        {
//                            gccRecords = [ Select Id, COUNTRYNAME__c, COUNTRYCODE__c, STATENAME__c, STATECODE__c, Name, POSTCODE__c
//                                          From Address_Data_GCC__c 
//                                          Where COUNTRYCODE__c =: assetRecords[0].Country__c And name =: assetRecords[0].City__c Limit 1];
//                        }
//                        else if(System.label.APCountryCodes.contains(assetRecords[0].Country__c)){
//                            gccRecords = [ Select Id, COUNTRYNAME__c, COUNTRYCODE__c, STATENAME__c, STATECODE__c, Name, POSTCODE__c
//                                          From Address_Data_GCC__c 
//                                          Where COUNTRYCODE__c =: assetRecords[0].Country__c And POSTCODE__c =: assetRecords[0].Zip__c Limit 1];
//                            
//                        }
//                        else if(assetRecords[0].Country__c=='JP')
//                        {
//                            gccRecords = [ Select Id, COUNTRYNAME__c, COUNTRYCODE__c, STATENAME__c, STATECODE__c, Name, POSTCODE__c
//                                          From Address_Data_GCC__c 
//                                          Where COUNTRYCODE__c =: assetRecords[0].Country__c And POSTCODE__c =: assetRecords[0].Zip__c Limit 1 ];
//                            
//                        }
//                        
//                        else if(System.label.AVSCountryCodes.contains(assetRecords[0].Country__c)){
//                            
//                            workorderRecords[0].City_APJ__c = assetRecords[0].City__c;
//                            workorderRecords[0].Zip_Code__c = assetRecords[0].Zip__c;
//                            workorderRecords[0].State_APJ__c = assetRecords[0].State__c;
//                            workorderRecords[0].Shipping_Country__c = assetRecords[0].Country__c;
//                            workorderRecords[0].CountryCode               =   assetRecords[0].Country__c;
//                            //workorderRecords[0].Country  = assetRecords[0].Country__c;
//                            workorderRecords[0].DeltaISOCountryCode__c  =   assetRecords[0].Country__c;
//                            workorderRecords[0].CountryCode__c          =   assetRecords[0].Country__c;
//                            workorderRecords[0].postalcode              =   assetRecords[0].Zip__c;
//                            //workorderRecords[0].timezone__c             =   woTimeZone;
//                            workorderRecords[0].City                   =   assetRecords[0].City__c;
//                        }
//                        
//                        if(gccRecords.size()==1 && !System.label.AVSCountryCodes.contains(assetRecords[0].Country__c))
//                        {
//                            workorderRecords[0].City_APJ__c=gccRecords[0].name;
//                            workorderRecords[0].State_APJ__c=gccRecords[0].STATENAME__c;
//                             workorderRecords[0].StateCode__c=gccRecords[0].STATECODE__c;
//                            
//                            if(!System.label.LatamCountries.contains(assetRecords[0].Country__c)) // added for DEFECT 8080207
//                            {
//                                workorderRecords[0].postalcode=assetRecords[0].Zip__c;
//                                workorderRecords[0].Zip_Code__c = assetRecords[0].Zip__c;    
//                            }
//                            else if(System.label.LatemZipRequiredCountries.contains(assetRecords[0].Country__c)) // added for DEFECT 8080207
//                                {
//                                    workorderRecords[0].postalcode=assetRecords[0].Zip__c;
//                                    workorderRecords[0].Zip_Code__c = assetRecords[0].Zip__c;
//                                }
//                            
//                            workorderRecords[0].Shipping_Country__c = assetRecords[0].Country__c;
//                            workorderRecords[0].CountryCode  = assetRecords[0].Country__c;
//                            //workorderRecords[0].Country  = assetRecords[0].Country__c;
//                            workorderRecords[0].DeltaISOCountryCode__c  = assetRecords[0].Country__c;
//                            workorderRecords[0].CountryCode__c=assetRecords[0].Country__c;
//                            
//                            //workorderRecords[0].timezone__c=woTimeZone;
//                            workorderRecords[0].City                   =   gccRecords[0].name;
//                            
//                        }
//                        else{
//                            if(!System.label.AVSCountryCodes.contains(assetRecords[0].Country__c))
//                            {
//                                if(!System.label.LatamCountries.contains(assetRecords[0].Country__c)) // added for DEFECT 8080207
//                                {
//                                    workorderRecords[0].postalcode=assetRecords[0].Zip__c;
//                                    workorderRecords[0].Zip_Code__c = assetRecords[0].Zip__c;
//                                }
//                                else if(System.label.LatemZipRequiredCountries.contains(assetRecords[0].Country__c)) // added for DEFECT 8080207
//                                {
//                                    workorderRecords[0].postalcode=assetRecords[0].Zip__c;
//                                    workorderRecords[0].Zip_Code__c = assetRecords[0].Zip__c;
//                                }
//                                
//                                workorderRecords[0].Shipping_Country__c = assetRecords[0].Country__c;
//                                workorderRecords[0].CountryCode  = assetRecords[0].Country__c;
//                                // workorderRecords[0].Country  = assetRecords[0].Country__c;
//                                workorderRecords[0].DeltaISOCountryCode__c  = assetRecords[0].Country__c;
//                                workorderRecords[0].CountryCode__c=assetRecords[0].Country__c;
//                                
//                                //workorderRecords[0].timezone__c=woTimeZone;
//                            }
//                        }
//                    }
//                }
//                //workorderRecords[0].Address_Line_1__c = addressLine1;
//                //workorderRecords[0].Address_Line_2__c = addressLine2;
//                //workorderRecords[0].Address_Line_3__c = addressLine3;
//                //workorderRecords[0].Address_Line_4__c = addressLine4;
//                //workorderRecords[0].Country__c = countryCode;
//                //workorderRecords[0].Shipping_Country__c = countryCode;
//                //workorderRecords[0].Zip_Code__c=postalCode;
//                //system.debug('getAssetAddress cityValue ' + cityValue);
//                //system.debug('getAssetAddress gccAddressId ' + gccAddressId);  
//               if (shipcountryCode != null && addressLine1 != null)
//                {
//                    if (gccAddressId == null)
//                    {
//                    system.debug('getAssetAddress postalCode ' + postalCode);
//                    system.debug('getAssetAddress stateValue ' + stateValue);    
//                    workorderRecords[0].Address_Line_1__c = addressLine1;
//                    //workorderRecords[0].Address_Line_2__c = addressLine2;
//                    workorderRecords[0].Address_Line_3__c = addressLine3;
//                    //workorderRecords[0].Address_Line_4__c = addressLine4;
//                    workorderRecords[0].Shipping_Country__c = shipcountryCode;
//                    workorderRecords[0].CountryCode = shipcountryCode;
//                    workorderRecords[0].City_APJ__c = cityValue;
//                    workorderRecords[0].Zip_Code__c = postalCode;
//                    workorderRecords[0].State_APJ__c = stateValue;
//                    workorderRecords[0].PostalCode = postalCode; 
//
//
//
//
//
//
//
//
//
//                }
//                else                
//                    workorderRecords[0].Shipping_City_State_Zip_Code__c = gccAddressId;
//                }
//
//                /*workorderRecords[0].CountryCode = countryCode;
//                system.debug('workorderRecords[0].CountryCode ' + workorderRecords[0].CountryCode);
//                system.debug('workorderRecords[0].City_APJ__c ' + workorderRecords[0].City_APJ__c);
//                workorderRecords[0].City = cityValue;
//                system.debug('workorderRecords[0].CountryCode ' + workorderRecords[0].City);
//                workorderRecords[0].PostalCode = postalCode;                
//                system.debug('workorderRecords[0].CountryCode ' + workorderRecords[0].PostalCode);
//                workorderRecords[0].Street = workorderRecords[0].Address_Line_1__c; 
//
//                system.debug('RODRIGO workorderRecords[0] ' + workorderRecords[0]);*/
//                update workorderRecords[0];
//                
//                return workorderRecords[0];
//            }
//            return null;
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'updateShippingDetails', 'Converge Dispatch');
//            return null;
//        }   
//    }
//    
//    @AuraEnabled(cacheable=true)
//    public static Id getPreferenceRecords(Id AccountId)
//    {
//        List<Preference__c>  preferenceRecords = new List<Preference__c>();
//        try
//        {
//            preferenceRecords = [ Select Id, Preference_Type__c, Contact__c, Account__c 
//                                  From Preference__c Where Account__c =: AccountId And Preference_Type__c = 'After Hour Contact' Limit 1 ];
//            if(!preferenceRecords.isEmpty())
//                return preferenceRecords[0].Contact__c; 
//            else
//                return null;                  
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'getPreferenceRecords', 'Converge Dispatch');
//            return null;
//        }
//    }
//    
//    @AuraEnabled
//    public static ServiceAppointmentWrap createServiceAppointment(Id workorderId) 
//    {
//        List<WorkOrder> workorderRecords = new List<WorkOrder>();
//        List<Preference__c> preferenceRecords = new List<Preference__c>();
//        List<Case> caseRecords = new List<Case>();
//        List<Asset> assetRecords = new List<Asset>();
//        List<Address_Data_GCC__c> gccRecords = new List<Address_Data_GCC__c>();
//        String woTimeZone = '';
//        try
//        {
//            ServiceAppointmentWrap appointmentWrap = new ServiceAppointmentWrap();
//            workorderRecords = [ Select AccountId, CaseId, AssetId, CheckForServiceTypeEqualsLaborOnly__c,CRU_Eligible_Flag__c,Bill_To__c,
//                                ContactId,CheckForServiceTypeEqualsPartsOnly__c, AdditionalContactId__c, EMC_Asset_Identifier__c, DPS_BUID__c, Service_Category__c, Billable__c,
//                                Address_Line_1__c, Address_Line_2__c, City_APJ__c, State_APJ__c, Shipping_Country__c, Zip_Code__c
//                                From workOrder Where Id =: workorderId Limit 1 ];
//            
//            preferenceRecords = [ Select Id, Preference_Type__c, Contact__c, Account__c 
//                                 From Preference__c Where Account__c =: workorderRecords[0].AccountId ];
//            
//            caseRecords = [ Select Id From Case Where Id =: workorderRecords[0].CaseId Limit 1 ];
//            
//            assetRecords = [ Select Id, X24_Hour_Contact__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Line_4__c,
//                            Country__c, State__c, City__c, Street__c, Zip__c, Alternate_Account__c 
//                            From Asset Where Id =: workorderRecords[0].AssetId Limit 1 ];
//            
//            String jsonTimeZone = tz.LocalTime.getOffset(assetRecords[0].Country__c, assetRecords[0].State__c, assetRecords[0].City__c);
//            if(jsonTimeZone != Null)
//            {
//                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonTimeZone);         
//                woTimeZone = (String)m.get('tz_sfdc');
//            }
//            
//            if(assetRecords[0].Country__c != Null && assetRecords[0].State__c != Null)
//            {
//            
//                  if(System.label.LatamCountries.contains(assetRecords[0].Country__c))
//                  { 
//                        gccRecords = [ Select Id, COUNTRYNAME__c, COUNTRYCODE__c, STATENAME__c, STATECODE__c, Name, POSTCODE__c
//                              From Address_Data_GCC__c 
//                              Where COUNTRYCODE__c =: assetRecords[0].Country__c And name =: assetRecords[0].City__c Limit 1];
//
//                  }
//                   else if(System.label.APCountryCodes.contains(assetRecords[0].Country__c)){
//                       gccRecords = [ Select Id, COUNTRYNAME__c, COUNTRYCODE__c, STATENAME__c, STATECODE__c, Name, POSTCODE__c
//                              From Address_Data_GCC__c 
//                              Where COUNTRYCODE__c =: assetRecords[0].Country__c And POSTCODE__c =: assetRecords[0].Zip__c Limit 1];
//
//                   }
//
//                   else if(assetRecords[0].Country__c=='JP')
//                   {
//                       gccRecords = [ Select Id, COUNTRYNAME__c, COUNTRYCODE__c, STATENAME__c, STATECODE__c, Name, POSTCODE__c
//                              From Address_Data_GCC__c 
//                              Where COUNTRYCODE__c =: assetRecords[0].Country__c And POSTCODE__c =: assetRecords[0].Zip__c Limit 1 ];
//                   }
//                 else{
//                        gccRecords = [ Select Id, COUNTRYNAME__c, COUNTRYCODE__c, STATENAME__c, STATECODE__c, Name, POSTCODE__c
//                              From Address_Data_GCC__c 
//                              Where COUNTRYCODE__c =: assetRecords[0].Country__c And STATECODE__c =: assetRecords[0].State__c Limit 1 ];
//                 }
//                
//           }
//
//           if(gccRecords.size()==1)
//           {
//                 appointmentWrap.gccRecord = gccRecords[0];
//           }
//            if(!workorderRecords.isEmpty())
//                appointmentWrap.workorderRecord = workorderRecords[0];
//            if(!preferenceRecords.isEmpty())
//                appointmentWrap.preferenceRecords = preferenceRecords;
//            if(!caseRecords.isEmpty())
//                appointmentWrap.caseRecord = caseRecords[0];
//            if(!assetRecords.isEmpty())
//                appointmentWrap.assetRecord = assetRecords[0];
//            /*if(!gccRecords.isEmpty())
//                appointmentWrap.gccRecord = gccRecords[0];*/
//            if(woTimeZone != Null)
//                appointmentWrap.workorderTimeZone = woTimeZone;
//            
//            
//            if(test.isRunningTest()) 
//                integer i = 1/0;
//            return appointmentWrap;
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'createServiceAppointment', 'Converge Dispatch');
//            return null;
//        }          
//    }
//    
//    @AuraEnabled
//    public static ServiceAppointment getServiceAppointment(Id workorderId) 
//    {
//        system.debug('in ServiceAppointment');
//        List<ServiceAppointment> listApp = new List<ServiceAppointment>();
//        try
//        {
//            listApp = [ Select Id, Status,SchedEndTime,SchedStartTime, Work_Order__r.EMC_Asset_Identifier__c, Primary_Contact__c, Work_Order__r.Sub_Status__c,
//                                 Work_order__r.WorkOrderTarget__c, Country__c, GSCV_Address__c, Address_Line_1__c, Address_Line_2__c,Work_order__r.LOB__c,
//                                 Address_Line_3__c, Service_Date__c, Address_Line_4__c, City__c, State__c, State_Code__c, Zip__c,Alternate_Account__c, Work_Order__c,
//                                 Work_Order__r.WorkOrderNumber, Work_Order__r.OwnerId, Work_Order__r.S_AS_Reactive_Queue__c, Work_Order__r.S_AS_Queue__c,  
//                                 Work_Order__r.Eligible_for_Site_Access_Consolidation__c, Work_Order__r.CheckForServiceTypeEqualsLaborOnly__c,
//                                 Work_Order__r.Case.Priority, Work_Order__r.Case.Case_Type__c, Work_Order__r.Account.Site_Access_Required__c, Country, GSCV_Address__r.Name,
//                                 Work_Order__r.Service_Option__c, Work_Order__r.Product_Classification__c, Work_Order__r.Service_Type__c, 
//                                 Work_order__r.Status, Work_order__r.FSD_DSP_Selection__c, Work_order__r.Schedule_Enable_Flag__c, Work_Order__r.EntitlementStartDate__c, Work_Order__r.EntitlementEndDate__c,
//                                 Work_Order__r.ServiceAgent_User__c, Work_Order__r.Labor_Status__c, Work_order__r.DSP__c, Work_order__r.RecordType.Name, Work_order__r.Out_of_Warranty__c,Work_Order__r.DASP__c,Work_Order__r.DPS_Region__c, Permanently_update_Service_Address__c,
//                                 Work_Order__r.Account.Customer_Confirmation_Required__c, Work_Order__r.Account.Site_Access_Requirement_Type__c, Work_Order__r.Account.Access_Type__c, Service_Start__c, Service_End__c, Service_Start_UI__c, Service_End_UI__c, Committed__c, forceUnconfirmedSlots__c   
//                                 From ServiceAppointment Where Work_Order__c =: workorderId Limit 1 ];
//            System.debug('appointmentRecord'+listApp);
//            if(listApp != null && listApp.size() > 0) 
//                return listApp[0];
//            return null;
//        }
//        catch(Exception e) 
//        {  
//            system.debug('in catch block');
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'getServiceAppointment', 'Converge Dispatch');
//            return null;
//        }
//    }    
//    
//    @AuraEnabled
//    public static DispatchDefaults__c getDispatchDefaults(Id workorderId) 
//    {
//        system.debug('----getDispatchDefaults------');
//        try
//        {   
//            DispatchDefaults__c DispatchDefaultsRecord = [ Select Id,PRU_Flag__c,OutOfWarranty__c,Name,Bill_To__c,Service_Type__c,KYHDOption__c, 
//                                                          Keep_Your_Components__c,ServiceHours__c,ServiceLevel__c,BasicEntitlement__c,Work_Order__r.LOB__c,Work_Order__r.CRU_Eligible_Flag__c,
//                                                          Work_Order__r.Address_Line_1__c,Work_Order__r.Address_Line_2__c,Work_Order__r.Address_Line_3__c,Work_Order__r.Address_Line_4__c,
//                                                          Work_Order__r.City_APJ__c,Work_Order__r.State_APJ__c,Work_Order__r.Zip_Code__c,Work_Order__r.Shipping_Country__c,Work_Order__r.StateCode__c,
//                                                          Work_Order__r.Bill_To__c,Work_Order__r.Billable__c, Work_Order__r.EMC_Asset_Identifier__c,Work_Order__r.Out_of_Warranty__c,Work_Order__r.Resource_Type__c,
//                                                          Data_Destruction__c, DataRecovery__c, CompleteCareOption__c, Health_Check__c, Work_Order__r.Case.Case_Type__c,AD_Override__c,Reason_for_the_Damage__c
//                                                          FROM DispatchDefaults__c Where Work_Order__c =: workorderId Limit 1 ];
//            
//            system.debug('----getDispatchDefaults------'+DispatchDefaultsRecord);
//            //if(DispatchDefaultsRecord != Null){
//                return DispatchDefaultsRecord;
//            //}
//            //else
//            //    return null;
//        }
//        catch(Exception e) 
//        {
//            system.debug('----e------'+e);
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'getDispatchDefaults', 'Converge Dispatch');
//            return null;
//        }
//    }
//    
//    @AuraEnabled
//    public static List<String> getProductClassification(string LOB){
//        try{
//            list<string> valueString = new list<string>();
//            Set<String> setProductValue = new Set<String>();
//            
//            if(String.isNotBlank(LOB)){
//                Product_Classification__mdt productClassificationRecord = [ Select Id, Value__c From Product_Classification__mdt Where LOB__c =: LOB Limit 1 ];
//                if(productClassificationRecord != Null){                                
//                    valueString.add(productClassificationRecord.Value__c);
//                    return valueString;
//                }
//                else
//                    return null;
//            }
//            else{
//                list<Product_Classification__mdt> productClassificationList = [ Select Id, Value__c From Product_Classification__mdt ];               
//                if(!productClassificationList.isEmpty()){
//                    for(Product_Classification__mdt rec: productClassificationList){                                           
//                        setProductValue.add(rec.Value__c);                       
//                        //valueString.add(rec.Value__c);
//                    }
//                    valueString.addAll(setProductValue);
//                    return valueString;
//                }
//                else 
//                    return null;
//            }
//        }
//        catch(Exception e){
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'getProductClassification', 'Converge Dispatch');
//            return null;
//        }
//    }
//    
//    @AuraEnabled
//    public static ServiceOptionWrap getServiceOptions(string serviceType,string serviceLevel,string serviceHours,string city,string state,string postalCode,string LOB,string country,string Billable,boolean GrndShip, boolean overrideGrndship, String woNumber){
///*--
//Component : getServiceOptions
//Description: this will handle the logic to get service options
//Change Log:
//===============================================================================================
//Date                Author                  UserStory#               Change Description
//===============================================================================================
//30-Oct-2019       Rodrigo Carpio                               added input parameter serviceType and modified the odata call
//10-Dec-2019       Archana                                       added input parameter for Groundship flag
//23-Dec-2019       Tamil Lakshmi                                added logic for BestAvailable Options
//*/
//        try{
//            ServiceOptionWrap serviceOptionWrapper = new ServiceOptionWrap();
//            list<string> serviceOptionValues = new list<string>();
//            string groundShipFlg;
//            groundShipFlg = String.valueOf(GrndShip ? (overrideGrndship? false : true):false);
//            // String woNumber = [Select Id,WorkOrderNumber from WorkOrder where id=:workOrderId limit 1].WorkOrderNumber;
//            
//            List<ConvergedAvailableOptions__x> serviceOptionRecords = (!mockedServiceOptions.isEmpty()) ? mockedServiceOptions : [ select id,ServiceHours__c,ServiceLevel__c,AvailableOption__c,BestAvailableOption__c,AvailableOptionRank__c,BestAvailableOptionRank__c,AvailableOptionPeriodRank__c,BestAvailableOptionPeriodRank__c,ResponseCode__c from ConvergedAvailableOptions__x where ServiceType__c =: serviceType AND ServiceLevel__c =: serviceLevel AND ServiceHours__c =: serviceHours AND City__c =: city AND State__c =: state AND PostalCode__c =: postalCode AND LOB__c =: LOB AND Country__c =: country AND Billable__c =: Billable AND GroundShipFlg__c = :GroundShipFlg AND WorkOrderNumber__c =:woNumber];
//            //console.log('serviceOptionRecords'+serviceOptionRecords);
//            System.debug('serviceOptionRecords'+serviceOptionRecords);
//            string BestAvail = '';
//            string ResultList = '';
//            if(!serviceOptionRecords.isEmpty()){
//                System.debug('in if'); 
//                //console.log('in if');
//                for(ConvergedAvailableOptions__x rec : serviceOptionRecords){
//                    serviceOptionValues.add(rec.AvailableOption__c); 
//                    BestAvail = rec.BestAvailableOption__c;
//                    serviceOptionWrapper.responseCode = rec.ResponseCode__c;
//                }
//                ResultList= String.join(serviceOptionValues, ',');
//                serviceOptionWrapper.serviceOptions = ResultList;
//                System.debug('serviceOptionValues----'+ResultList);
//                System.debug('serviceOptionValues----'+serviceOptionWrapper);
//                return serviceOptionWrapper;
//            }
//            else{
//                //console.log('in else');
//                System.debug('in else');
//                return null;
//            }
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'getServiceOptions', 'Converge Dispatch');
//            return null;
//        }
//    } 
//    
//    @AuraEnabled    
//    public static list<string> getSpecialOptions(string woType, string serviceType,string serviceLevel,string serviceHours,string country, string oconusFederalFlag, string serviceBuid, string serviceProvider){
//        /*--
//Component : getSpecialOptions
//Description: this will handle the logic to get special options
//Change Log:
//===============================================================================================
//Date                Author                  UserStory#               Change Description
//===============================================================================================
//30-Oct-2019       Rodrigo Carpio                               added input parameter for DEFECT 7600339
//*/
//        try{
//            system.debug('getSpecialOptions ' + woType);
//            system.debug('serviceProvider ' + serviceProvider);
//            string federalOconus = 'No';
//            list<string> specialOptionValues = new list<string>();
//            List<SpecialOptions__x> specialOptionRecords = (!mockedSpecialOptions.isEmpty()) ? mockedSpecialOptions :[select id,ServiceSubType__c,ServiceLevel__c,SpecialOption__c 
//                                                            from SpecialOptions__x where ServiceType__c =: woType AND ServiceSubType__c =: serviceType 
//                                                            AND ServiceLevel__c =: serviceLevel AND ServiceHours__c =: serviceHours 
//                                                            AND Country__c =: country AND OconusFederalFlag__c =: federalOconus
//                                                           AND ServiceBuid__c =: serviceBuid AND ServiceProvider__c =: serviceProvider];
//            if(!specialOptionRecords.isEmpty()){
//                specialOptionValues.add('None');
//                for(SpecialOptions__x rec : specialOptionRecords){
//                    specialOptionValues.add(rec.SpecialOption__c); 
//                }
//                return specialOptionValues;
//            }
//            else
//                return null;
//        }
//        catch(Exception e) 
//        {
//            System.debug('inside getSpecialOptions catch block'+e.getMessage());
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'getSpecialOptions', 'Converge Dispatch');
//            return null;
//        }
//    }   
//    
//    //Added by Sajal, as part of Story-6802598(dispatchSubmittedServiceEvent)
//    @AuraEnabled(cacheable=true)
//    public static list<DispatchServiceEvent__c> getServiceEvents(Id workOrderId) {
//        try{
//            list<DispatchServiceEvent__c> serviceEventList = new list<DispatchServiceEvent__c>();
//            serviceEventList = [SELECT Id, DSP_Code__c, DSP_Reference__c, Reject_Reason__c, Service_Event__c, Event_DateTime__c, Event_Source__c, ISP_Engineer_Id__c, 
//                                DSP_Office_Id__c, DSP_Details__c, Reply_Code__c, Reply_Code_Description__c, Vendor_Transaction_DateTime__c, 
//                                Event_Code__c, CreatedDate FROM DispatchServiceEvent__c WHERE Work_Order__c =: workOrderId limit 100];
//            //System.debug('-----'+serviceEventList);
//            return serviceEventList;
//        }
//        catch(Exception e)
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'getServiceEvents', 'Fetch Service Event');
//            return null;
//        }
//        
//    }
//    //Added by Sajal, as part of Story-6802598(dispatchSubmittedInstructions)
//    @AuraEnabled(cacheable=true)
//    public static list<DispatchInstruction__c> getInstructions(Id workOrderId) {
//        try{
//            list<DispatchInstruction__c> instructionsList = new list<DispatchInstruction__c>();
//            instructionsList = [SELECT Id, Name, CreatedDate, CreatedById, CreatedBy.Name , Receiver__c, Instruction__c FROM DispatchInstruction__c WHERE Work_Order__c =: workOrderId ];
//            //System.debug('-----'+serviceEventList);
//            return instructionsList;
//        }
//        catch(Exception e)
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'getInstructions', 'Fetch Instructions');
//            return null;
//        }
//        
//    }
//
//
//
//    public static void isSimplePartTask(Id workorderId){
//        try{
//            Boolean simpePartTask = true;
//            List<WorkOrderLineItem> workOrderLineitems  = new List<WorkOrderLineItem>();
//
//            workOrderLineitems = [SELECT id,CRU_FRU__c,workorder.Service_Type__c from WorkOrderLineItem where workorderId =: workorderId];
//
//            if(workOrderLineitems.size() > 0){
//                if(workOrderLineitems[0].workorder.Service_Type__c != 'Parts and Labor')
//                    simpePartTask = false;
//                else{
//                    for(WorkOrderLineItem woli :workOrderLineitems){
//                        if(woli.CRU_FRU__c != 'CRU'){
//                            simpePartTask = false;
//                            break;
//                        }
//                    }
//                }
//            }else
//                simpePartTask = false;
//            
//            
//            Update new workOrder(id = workorderId,Simple_Part_Task__c = simpePartTask);
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'isSimplePartTask', 'Converge Dispatch');
//            
//        }
//    }
//    
//      @AuraEnabled
//    public static void getDASPDSPValues(string DASPValue, Id workorderId){
//        try{
//            
//            WorkOrder WO = new WorkOrder();
//            List<DispatchDSPDLP__c> DASP =  [ Select PartnerCode__c, PartnerName__c From DispatchDSPDLP__c where PartnerName__c =:DASPValue AND Type__c = 'DASP' limit 1 ];
//            List<DispatchDSPDLP__c> DSPRecords = (!mockedDSPDLP.isEmpty()) ? mockedDSPDLP : [ Select PartnerCode__c, PartnerName__c From DispatchDSPDLP__c where PartnerCode__c =:DASP[0].PartnerCode__c AND Type__c = 'DSP' limit 1 ];
//            if(DSPRecords.size()>0){
//               WO = [Select id, FSD_DASP_Flag__c, DSP__c from WorkOrder where Id =: workorderId limit 1];
//                WO.DSP__c = DSPRecords[0].PartnerCode__c;
//                WO.FSD_DASP_Flag__c = true;
//                //added DSP name to resolve defect 7856629
//                WO.DSPName__c = DSPRecords[0].PartnerName__c;
//            }  
//            Update WO;
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'getDASPDSPValues', 'Converge Dispatch');
//            
//        }
//    }
//    
//    @AuraEnabled(cacheable=true)
//    public static list<string> getDASPValues(string countryCode){
//        try{
//            list<string> DASPValues = new list<string>();
//            List<DispatchDSPDLP__c> DASPRecords = (!mockedDSPDLP.isEmpty()) ? mockedDSPDLP : [ Select PartnerCode__c, PartnerName__c From DispatchDSPDLP__c where Type__c = 'DASP' AND CountryCode__c =: countryCode AND Active__c = true limit 50 ];
//            if(!DASPRecords.isEmpty()){
//                for(DispatchDSPDLP__c rec : DASPRecords){
//                    DASPValues.add(rec.PartnerName__c); 
//                }
//                return DASPValues;
//            }
//            else
//                return null;
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'getDASPValues', 'Converge Dispatch');
//            return null;
//        }
//    }
//    @AuraEnabled(cacheable=true)
//    public static ID getQueueID(String Queue_dev_name) 
//    {
//        String Temp_ID=[select id from group where type='queue' and DeveloperName='S_S_Queue' limit 1].id;
//        return Temp_ID;
//    }
//    
//    @AuraEnabled
//    public static User getSandASUserId(Id userId) 
//    {
//        try
//        {
//            User userResult = [Select Id, Profile.Name, Name From User Where Id =: userId Limit 1];
//            //if(userResult != null)
//                return userResult;
//            //else
//            //    return null;
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'getSandASUserId', 'Converge Dispatch');
//            return null;
//        }
//    }
//    
//    @AuraEnabled
//    public static map<string,map<string,string>> getMaintenanceCalendar(Id AccountId){
//        try{
//            map<string,map<string,string>> fullMap = new map<string,map<string,string>>();
//            Set<string> days = new Set<string>{'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'};
//                for(string recSt: days){
//                    map<string,string> innermap = new map<string,string>();
//                    fullMap.put(recSt,innermap);
//                }
//            
//            list<Maintenance_Calendar__c> calendarRecords = [select id,Day__c,End_Time__c,Start_Time__c from Maintenance_Calendar__c where Account__c =: AccountId order by Start_Time__c ASC];
//            if(!calendarRecords.isEmpty()){
//                for(Maintenance_Calendar__c rec : calendarRecords){
//                    String st = rec.Day__c;
//                    if(st.contains(';')){
//                        list<string> dayList = st.split(';');
//                        for(string stRec: dayList){
//                            if(fullMap.containsKey(stRec)){
//                                map<string,string> timemap = fullMap.get(stRec);
//                                string timeString = timeFormat(String.ValueOf(rec.Start_Time__c))+'-'+timeFormat(String.ValueOf(rec.End_Time__c));
//                                timemap.put(rec.id+stRec,timeString);
//                                fullMap.put(stRec,timemap);
//                            }else{
//                                map<string,string> timemap = new map<string,string>();
//                                string timeString = timeFormat(String.ValueOf(rec.Start_Time__c))+'-'+timeFormat(String.ValueOf(rec.End_Time__c));
//                                timemap.put(rec.id+stRec,timeString);
//                                fullMap.put(stRec,timemap);
//                            }
//                        }
//                    }else if(fullMap.containsKey(st)){
//                        map<string,string> timemap = fullMap.get(st);
//                        string timeString = timeFormat(String.ValueOf(rec.Start_Time__c))+'-'+timeFormat(String.ValueOf(rec.End_Time__c));
//                        timemap.put(rec.id+st,timeString);
//                        fullMap.put(st,timemap);
//                    }else{
//                        System.debug('inside else');
//                        map<string,string> timemap = new map<string,string>();
//                        string timeString = timeFormat(String.ValueOf(rec.Start_Time__c))+'-'+timeFormat(String.ValueOf(rec.End_Time__c));
//                        timemap.put(rec.id,timeString);
//                        fullMap.put(rec.Day__c,timemap);
//                    }
//                }
//                return fullMap;
//            }
//            else
//                return null;
//        }catch(Exception e){
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'getMaintenanceCalendar', 'Converge Dispatch');
//            return null;
//        }
//        
//    }
//    
//    public static String timeFormat(String timeString){
//        string hours = timeString.left(2);
//        string mins = timeString.substring(3,5); 
//        string times;
//        
//        if(integer.valueOf(hours) > 12)
//            times = string.valueOf(integer.valueOf(hours) - 12)+':'+mins+'PM';
//        else if(integer.valueOf(hours) == 0)
//            times = '12'+':'+mins+'AM';
//        else if(integer.valueOf(hours) < 12)
//            times = string.valueOf(integer.valueOf(hours))+':'+mins+'AM';
//        else if(integer.valueOf(hours) == 12)
//            times = '12'+':'+mins+'PM';        
//        else
//            times = null;
//        
//        return times;
//    }
//    /*
//Author:  Deepa Lakamanhalli
//Description:This method handles PPID validation for Converged - Story #6634882
//Usage: LWC component - dispatchCreateLwc - validatePPIDService
//*/
//    @TestVisible public static List<ValidateReturnParts__x> mockAutovalidateParts = new List<ValidateReturnParts__x>();
//    
//    @AuraEnabled(cacheable=true)
//    public static List <String> validatePPID(List<String> ppidList, String serviceBUID) {
//        List<String> returnedList = new List<String>();
//        
//        List<ValidateReturnParts__x> validatereturnparts = new List<ValidateReturnParts__x>();
//        //List<String> ppidStringList = new List<String>();
//        Map<String, String> ppidPartMap = new Map<String, String>();
//        
//        system.debug('ppidList ===>  '+ppidList);
//        try{
//            if (!ppidList.isEmpty()) {
//                for (String str: ppidList) {
//                    if (!ppidPartMap.containskey(str.substring(3, 8))) {
//                        ppidPartMap.put(str.substring(3, 8).toUpperCase(), str);
//                        //ppidStringList.add(str.substring(3, 8).toUpperCase());
//                    }
//                }
//                //system.debug('ppidStringList  ===> '+ppidStringList);
//                system.debug('ppidPartMap  ===> '+ppidPartMap);
//                system.debug('ppidPartMap  ===> '+ppidPartMap.keySet());
//                
//                List<String> ppidAllowedList = System.Label.Dispatch_PPID_Allowed!= null ? System.Label.Dispatch_PPID_Allowed.split(',') : new List<String>();
//                system.debug('ppidAllowedList  ===> '+ppidAllowedList);
//                
//                List<String> validatePPIDList = new List<String>();
//                for(String str: ppidPartMap.keySet()){
//                    if (!ppidAllowedList.contains(str)) {
//                        validatePPIDList.add(str);
//                    }
//                }
//                system.debug('validatePPIDList ===>  '+validatePPIDList);
//                
//                //String ppidNumberstring = String.join(validatePPIDList, ',');
//                
//                //validatereturnparts=[Select PartNumber__c,ResponseMessage__c,  ResponseCode__c,ValidPart__c,ItemExists__c from ValidateReturnParts__x where PartNumber__c in : ppidPartMap.keySet() and ServiceBUID__c=:ServiceBUID]; 
//                validatereturnparts = (!mockAutovalidateParts.isEmpty()) ? mockAutovalidateParts : [SELECT PartNumber__c, ResponseMessage__c, ResponseCode__c, ValidPart__c,
//                                                                                                    ItemExists__c, FunctionalDescription__c FROM ValidateReturnParts__x
//                                                                                                    WHERE PartNumber__c =: String.join(validatePPIDList, ',') AND ServiceBUID__c =: ServiceBUID LIMIT 500];
//                                                                                                        
//                for (ValidateReturnParts__x v: validatereturnparts) {
//                if (v.ResponseCode__c == '100' && (v.ValidPart__c == 'true' && ppidPartMap.containskey(v.PartNumber__c))) {
//                returnedList.add(ppidPartMap.get(v.PartNumber__c));
//                } else if(v.ResponseCode__c == '100' && (v.ValidPart__c == 'false' && ppidPartMap.containskey(v.PartNumber__c))){
//                returnedList.add(ppidPartMap.get(v.PartNumber__c)+'*');
//                //returnedList.add('Invalid PPID');
//                 //break;
//                } else{
//                 returnedList.add('Error : '+v.ResponseCode__c+' and '+v.ResponseMessage__c);
//                     }
//                 }
//                /*if (!returnedList.isEmpty()) {
//                    returnedList.add('Success');
//                }*/
//                
//            }
//            system.debug('returnedList >>'+returnedList);
//            return returnedList;
//            
//        } catch(Exception e) {
//            String str = e.getMessage();
//            returnedList.add(str);
//            return returnedList;
//        }
//        
//    }
//    //Pawan starts
//    @AuraEnabled
//    public static void cancelServiceAppointment(Id workorderId) 
//    {
//        try
//        {
//            List<ServiceAppointment> CancelSAStatus = [ Select Id, Status From ServiceAppointment Where Work_Order__c =: workorderId ];
//            system.debug('CancelSAStatus:::'+CancelSAStatus);
//            if(!CancelSAStatus.isEmpty())
//            {
//                for(ServiceAppointment rec:CancelSAStatus)
//                {   
//                    rec.Status='Cancelled';
//                }
//                update CancelSAStatus;
//            }       
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'cancelServiceAppointment', 'Converge Dispatch');
//        }
//    }
//    //Pawan ends
//    @AuraEnabled(cacheable=true)    
//    public static Boolean checkUserPermission(){
//        String ProfileName=[Select Profile.Name from User where id= :UserInfo.getUserId() limit 1].Profile.Name;
//        if (ProfileName=='Work Order Elevated Access' )
//            return true;
//        else return false;
//    } 
//    @AuraEnabled
//    public static WorkOrder getWorkOrderData(Id workOrderId){
//        /*--
//Component : getWorkOrderData
//Description: get work order information
//Change Log:
//===============================================================================================
//Date                Author                  UserStory#               Change Description
//===============================================================================================
//09-Nov-2019       Rodrigo Carpio            7549975  modified returned fields addedd Parts_Status__c/Service_Type__c
//    
//*/
//        WorkOrder workorder = new WorkOrder();
//        try{
//            workorder = [Select EMC_Asset_Identifier__c, Labor_Status__c, Status, Sub_Status__c,DSP__c, DSP_Override_Request__c, DPSType__c, DLP_Name__c, FSD_Tranport_DLP_Name__c, Collect_DLP__c, Parts_Status__c,Schedule_Enable_Flag__c,Service_Type__c, CountryCode, WO_Type__c from WorkOrder where Id =: workOrderId];
//        }catch(Exception ex){
//            ExceptionHandler.logHandledExceptions(ex, 'ConvergeDispatchHandler', 'getWorkOrderData', 'Converge Dispatch');
//        }
//        return workorder;
//    }
//    
//    
//    /*
//    Name : updateServiceEvent
//    Description: This method updates the Event Code on Service Events   
//    Date          Author             UserStory#      Change Description
//    3-Oct-2019    Ramzil Cleopas     7339014         Initial Version
//    */
//    @AuraEnabled(cacheable=true)
//    public static void updateServiceEvent(Id workOrderId, String eventCode){ 
//        try{
//        List<DispatchServiceEvent__c> lstServiceEvents = new List<DispatchServiceEvent__c>();
//        List<DispatchServiceEvent__c> lstServiceEventsUpdate = new List<DispatchServiceEvent__c>();
//          
//        lstServiceEvents = [Select Id, Event_Code__c FROM DispatchServiceEvent__c Where Work_Order__c =: workOrderId];   
//        
//        for(DispatchServiceEvent__c eventObj : lstServiceEvents){
//            eventObj.Event_Code__c = eventCode; 
//            lstServiceEventsUpdate.add(eventObj); 
//        }
//        
//        System.debug('lstServiceEventsUpdate-->'+lstServiceEventsUpdate);
//        if(lstServiceEventsUpdate.size()>0){
//            update lstServiceEventsUpdate;
//        }  
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'updateServiceEvent', 'Converge Dispatch');
//        }  
//    } 
//
//    /*
//    Name : userProfile
//    Description: This method gets the profile of current user   
//    Date              Author                Defect#                            Change Description
//    09-Oct-2019       Antra Shrivastav      7471957                            Defect Fix
//    06-Nov-2019       Roshni                takeOwnerShip page refresh         Defect Fix
//    */
//    @AuraEnabled
//    public static boolean userProfile(Id workOrderId)
//    {
//        try{
//        boolean profileCheck = false;
//        Id workOrderOwner = [ SELECT OwnerId FROM WorkOrder WHERE Id =: workOrderId ].OwnerId;
//        String currentProfile = [ SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId() ].Name;                  
//        if(currentProfile == 'Work Order Elevated Access' && UserInfo.getUserId() != workOrderOwner)
//            profileCheck = true;
//        return profileCheck;
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'userProfile', 'Converge Dispatch');
//            return null;
//        }  
//    }
//    
//    // HImani
//    @AuraEnabled
//    public static void createAlert(String adCount, String workOrderId)
//    {   
//    try{
//    system.debug('&&&&&inside createAlert%%%%'+adCount);
//        Dispatch_Alert__c dAlert = new Dispatch_Alert__c();
//        dAlert.Name = 'Already AD has been provided for Asset';
//        dAlert.Work_Order__c = workOrderId;
//        system.debug('&&&&&dAlert%%%%'+dAlert);
//        insert dAlert;
//    }
//    catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'createAlert', 'Converge Dispatch');
//        }  
//    } // HImani 
//    
//    // HImani
//    @AuraEnabled
//    public static void createReminders(String recordId)
//    {   
//        WorkOrder wo = [Select Id, CaseId, AD_Count__c From WorkOrder where Id =: recordId];
//        
//        List<WorkOrder> wOrder = [Select id, Status From WorkOrder WHERE CaseId =: wo.CaseId Order By CreatedDate LIMIT 1];
//        
//        if(wo.AD_Count__c == 1) {
//            
//            Customer_Reminder__c cD = new Customer_Reminder__c();
//            if(!wOrder.isEmpty() && wOrder[0].Status == 'Work In Progress') {
//                
//                cD.Name = 'name';
//                cD.Link__c = 'https://kb.dell.com/infocenter/index?page=content&id=PNP19011&actp=SEARCH&viewlocale=en_US&searchid=1568734486857';
//                cD.Reminder__c = 'An Accidental Damage Work Order is already in progress. To continue, select an Override Reason. This dispatch will be put on hold for review.';
//                cD.Type__c = 'Accidental Damage';
//                cD.Work_Order__c = recordId;
//            }
//            else if (!wOrder.isEmpty() && wOrder[0].Status == 'Service Complete') {
//                
//                cD.Name = 'name';
//                cD.Link__c = 'https://kb.dell.com/infocenter/index?page=content&id=PNP19011&actp=SEARCH&viewlocale=en_US&searchid=1568734486857';
//                cD.Reminder__c = 'The Accidental Damage limit has been reached for this contractual year. To continue, select an Override Reason. This dispatch will be put on hold for review.';
//                cD.Type__c = 'Accidental Damage';
//                cD.Work_Order__c = recordId;
//            }
//            
//        insert cD;
//        }
//            } // HImani
//            
//    @AuraEnabled
//    public static void createAccidentalDamageAlerts(String recordId)
//    {   
//        List<Dispatch_Alert__c> alert = [select Alert_Reason__c from Dispatch_Alert__c where Name = 'Accidental Damage' and Work_Order__c =: recordId];
//        if(alert.isEmpty() && alert.size() == 0)
//        {
//            Dispatch_Alert__c   alert1 = new Dispatch_Alert__c(Work_Order__c = recordId, Alert_Details__c = 'Already AD has been provided for Asset', Alert_Reason__c = 'Accidental Damage', Blocked__c = true, Name = 'Accidental Damage');
//            insert alert1;
//        }
//        
//         WorkOrder wo = [Select AssetId From WorkOrder where Id =: recordId];
//         List<WorkOrder> workOr = [Select id, Status From WorkOrder WHERE AssetId =: wo.AssetId Order By CreatedDate];
//        List<Customer_Reminder__c>  Cr1 = [select Type__c from Customer_Reminder__c where Name = 'Accidental Damage' and Work_Order__c =: recordId];
//        if(Cr1.isEmpty() && Cr1.size() == 0){
//        for(WorkOrder work : workOr){
//           if(work.Status == 'Work In Progress')
//           {
//               Customer_Reminder__c cr = new Customer_Reminder__c(Link__c = 'https://kb.dell.com/infocenter/index?page=content&id=PNP19011&actp=SEARCH&viewlocale=en_US&searchid=1568734486857',name = 'Accidental Damage',Reminder__c = 'An Accidental Damage Work Order is already in progress. To continue, select an Override Reason. This dispatch will be put on hold for review.',Type__c = 'Accidental Damage',Work_Order__c = recordId);
//               insert cr;
//               break;
//           }
//            if(work.Status == 'Service Complete')
//           {
//               Customer_Reminder__c cr = new Customer_Reminder__c(Link__c = 'https://kb.dell.com/infocenter/index?page=content&id=PNP19011&actp=SEARCH&viewlocale=en_US&searchid=1568734486857', name = 'Accidental Damage',Reminder__c = 'The Accidental Damage limit has been reached for this contractual year. To continue, select an Override Reason. This dispatch will be put on hold for review.',Type__c = 'Accidental Damage',Work_Order__c = recordId);
//               insert cr;
//               break;
//           }
//        }
//        }  
//    }        
//    
//    /*--
//    Component :  changeWorkOrderOwnerInElevatedQueue
//    Description: Ability for the System to assign related WOs to the S&AS
//    Change Log:
//    ===============================================================================================
//    Date                Author               UserStory#               Change Description
//    ===============================================================================================
//    10-Oct-2019         Partha               7417563                  Initial Version  
//    19-March-2020       Lekha                8182892                  Removed the check for CreatedDate from.
//    */
//    @AuraEnabled
//    public static void changeWorkOrderOwnerInElevatedQueue(Id workOrderId, Id userId)
//    {
//        try
//        {
//            WorkOrder workorderRecord = [ Select Id, OwnerId, AccountId From WorkOrder Where Id =: workOrderId ];
//            List<WorkOrder> workorderList = [ Select Id, OwnerId, AccountId, S_AS_Queue__c, Unscheduled_Reason__c, CreatedDate 
//                                                From WorkOrder 
//                                                Where AccountId =: workorderRecord.AccountId And 
//                                                S_AS_Queue__c = 'Other' And
//                                                Unscheduled_Reason__c = 'Site Access Consolidation Pending' And
//                                                Id !=: workOrderId];
//                                                
//
//            if(! workorderList.isEmpty())
//            {
//                for(WorkOrder woRecord : workorderList)
//                {
//                        woRecord.OwnerId = userId;                        
//                }
//                    update workorderList;                    
//            }            
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'changeWorkOrderOwnerInElevatedQueue', 'Converge Dispatch');
//            
//        }
//    }  
//
//    /*--
//    Component :  fetchWorkOrderOwnerInElevatedQueue
//    Description: Ability for the System to fetch and assign related WOs to the S&AS
//    Change Log:
//    ===============================================================================================
//    Date                Author               UserStory#               Change Description
//    ===============================================================================================
//    19-March-2020         Lekha               8182892                  Initial Version  
//    */
//    @AuraEnabled
//    public static List<WorkOrder> fetchWorkOrderOwnerInElevatedQueue(Id workOrderId, Id userId)
//    {
//        try
//        {
//            WorkOrder workorderRecord = [ Select Id, OwnerId, AccountId From WorkOrder Where Id =: workOrderId ];
//            List<WorkOrder> workorderList = [ Select Id, WorkOrderNumber, OwnerId, AccountId, S_AS_Queue__c, Unscheduled_Reason__c, CreatedDate 
//                                                From WorkOrder 
//                                                Where AccountId =: workorderRecord.AccountId And 
//                                                S_AS_Queue__c = 'Other' And
//                                                Unscheduled_Reason__c = 'Site Access Consolidation Pending' And
//                                                Id !=: workOrderId];
//            return workorderList;
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'fetchWorkOrderOwnerInElevatedQueue', 'Converge Dispatch');
//            return null;
//        }
//    }  
//
//    @AuraEnabled
//    public static String entitlementADDetails(String serviceTag) {
//        
//        List<User> lstUser = [Select Id, FederationIdentifier From User WHERE Id =: UserInfo.getUserId()];
//        system.debug('------lstUser------'+lstUser);
//        try{
//            List<EntitlementADDetails__x> lstOfEntitlementADDetails = new List<EntitlementADDetails__x>();
//            lstOfEntitlementADDetails = (!mockentitlementdata.isEmpty()) ? mockentitlementdata : [SELECT Id, ServiceTag__c, UserId__c, ADCount__c, ResponseCode__c
//                                                                       FROM EntitlementADDetails__x
//                                                                       WHERE ServiceTag__c=: serviceTag
//                                                                       AND UserId__c=: lstUser[0].FederationIdentifier];
//            
//            if(lstOfEntitlementADDetails[0].ResponseCode__c == '100') {
//                
//                return lstOfEntitlementADDetails[0].ADCount__c;
//            }
//        }
//        catch(Exception e){
//            return '0';
//        }
//        
//        
//        return '';
//    }
//    
//    /*--
//    Component  :  updateEntitlementDates
//    Description:  This will handle the logic get the entitlement date time from external system
//    Change Log :
//    ===============================================================================================
//    Date              Author                  UserStory#               Change Description
//    ===============================================================================================
//    21-Oct-2019       Partha                  Initial Version
//    23-Oct-2019       Rodrigo                 7233090, 7229147          Added changes to support for Parts Only using variable countryCode, stateCode & zipCodeValue
//    28-Nov-2019       Rodrigo                 1.2                       Added logic for getting the India Country Code using DPS BUID
//    26-Dec-2019       Archana                                           Added logic to handle all the time zone. 
//
//    */
//        @AuraEnabled
//    public static void updateEntitlementDates(Id woId)      
//    {
//        try
//        {
//            String serviceLevel = '';
//            String serviceHour = '';
//            String countryCode = '';
//            String countryCodeNew = '';
//            String countryValue = '';
//            String postalCode = '';
//            string stateCode = '';
//            string woTimeZone = '';
//            ServiceAppointment saRecord = new ServiceAppointment();
//            //created a new wo object to resolve the defect 7643204 for service option change
//            WorkOrder woRecord = new WorkOrder(Id = woId);
//            WorkOrder workOrderRecord = [ Select Id, WorkOrderNumber, Service_Option__c, SLAStartDate__c, DPS_Region__c,
//                                         EntitlementStartDate__c, SLAEndDate__c, EntitlementEndDate__c, DeltaTimezone__c,
//                                         DeltaShiftStart__c, DeltaShiftEnd__c, Shipping_Country__c, Service_Type__c, 
//                                         Zip_Code__c, State_APJ__c, DPS_BUID__c, Need_by_Date__c, Need_by_Time__c, 
//                                         WO_Type__c, Timezone__c, countryCode,DeltaISOCountryCode__c
//                                         From WorkOrder Where Id =: woId LIMIT 1];
//            
//            woTimeZone = workOrderRecord.Timezone__c;
//            List < ConvergedTimeZone__mdt > tzList = new List <ConvergedTimeZone__mdt> ();
//            if(woTimeZone == null || woTimeZone == 'N/A' || woTimeZone == '' )
//            {
//
//
//                tzList = [SELECT Default_Delta_Timezone__c, Default_SFDC_Timezone__c FROM ConvergedTimeZone__mdt WHERE CountryCode__c =: workOrderRecord.countryCode LIMIT 1];
//                }
//
//                    woRecord.DeltaTimezone__c = tzList[0].Default_Delta_Timezone__c;
//                    woRecord.TimeZone__c = tzList[0].Default_SFDC_Timezone__c;
//                    woTimeZone = tzList[0].Default_SFDC_Timezone__c;
//                }
//            }
//
//
//
//
//
//
//
//
//
//            //if (workOrderRecord.WO_Type__c == 'Break Fix')
//            {
//                if (!workOrderRecord.Service_Type__c.equalsIgnoreCase('Parts Only') && !workOrderRecord.Service_Type__c.equalsIgnoreCase('Mail-In'))
//                {
//                    saRecord = [ Select Id, Country__c, Country, State_Code__c, Zip__c, EarliestStartTime, DueDate
//                                From ServiceAppointment Where Work_Order__c =: woId LIMIT 1];    
//                    countryCode = saRecord.Country__c;
//                    if(countryCode == 'IN') 
//                    {
//                        countryCodeNew = workOrderRecord.DeltaISOCountryCode__c;
//                    }  
//                    else
//                    {
//                        countryCodeNew = saRecord.Country__c;
//                    }                     
//                }else 
//                {
//                    countryCode = workOrderRecord.Shipping_Country__c; 
//                    countryCodeNew = workOrderRecord.Shipping_Country__c;                   
//                }
//                if(String.isNotEmpty(workOrderRecord.Service_Option__c) && workOrderRecord.Service_Option__c.contains('-'))    
//                {
//                    serviceLevel = workOrderRecord.Service_Option__c.substringBeforeLast('-');
//                    serviceHour = workOrderRecord.Service_Option__c.substringAfterLast('-');
//                }
//                
//                List <ServiceLevelSlot__x> slaDateList = new List <ServiceLevelSlot__x>();
//
//
//                slaDateList = (!mockedServiceLevelSlot.isEmpty()) ? mockedServiceLevelSlot : [ SELECT Start__c, End__c, ResponseCode__c, ResponseDetails__c, ResponseMessage__c, TimeZone__c
//                                                                                              FROM ServiceLevelSlot__x WHERE Country__c =: countryCode AND ServiceHours__c =: serviceHour
//                                                                                              AND ServiceLevel__c =: serviceLevel AND TimeZone__c=:woTimeZone
//                                                                                              AND WorkOrderNumber__c=:workOrderRecord.WorkOrderNumber
//                                                                                             ];
//
//
//                if (!slaDateList.isEmpty() && slaDateList.size()>0)
//                {
//                    if (String.isNotEmpty(slaDateList[0].Start__c)) 
//                    {                        
//                        //woRecord.SLAStartDate__c = slaDateList[0].Start__c.substring(0, slaDateList[0].Start__c.lastIndexOf('-'));
//                        if (slaDateList[0].Start__c.contains('Z') || slaDateList[0].Start__c.contains('z')) 
//                            woRecord.SLAStartDate__c = slaDateList[0].Start__c.substringBeforeLast('Z');
//                        else
//                            woRecord.SLAStartDate__c = slaDateList[0].Start__c.contains('+') ? (slaDateList[0].Start__c.substring(0, slaDateList[0].Start__c.lastIndexOf('+'))): slaDateList[0].Start__c.contains('-')?(slaDateList[0].Start__c.substring(0, slaDateList[0].Start__c.lastIndexOf('-'))) : (slaDateList[0].Start__c.substring(0, slaDateList[0].Start__c.lastIndexOf('Z')));
//                                
//                                if(string.isEmpty(workOrderRecord.EntitlementStartDate__c) || workOrderRecord.EntitlementStartDate__c.contains('undefined')) {
//                                    //woRecord.EntitlementStartDate__c = slaDateList[0].Start__c.contains('+') ? (slaDateList[0].Start__c.substring(0, slaDateList[0].Start__c.lastIndexOf('+'))): slaDateList[0].Start__c.contains('-')?(slaDateList[0].Start__c.substring(0, slaDateList[0].Start__c.lastIndexOf('-'))) : (slaDateList[0].Start__c.substring(0, slaDateList[0].Start__c.lastIndexOf('Z')));
//                                    woRecord.EntitlementStartDate__c = slaDateList[0].Start__c; //Updated as part of defect 7869923
//                                    woRecord.Deferred__c = 'No';
//                                }
//                        
//                    }
//                    system.debug('woRecord.SLAStartDate__c ' + woRecord.SLAStartDate__c);
//                    if(String.isNotEmpty(slaDateList[0].End__c)) 
//                    {
//                        string tmpDate = slaDateList[0].End__c;
//                        if (slaDateList[0].End__c.contains('Z') || slaDateList[0].End__c.contains('z')) 
//                            woRecord.SLAEndDate__c = slaDateList[0].End__c.substringBeforeLast('Z');
//                        else
//                            woRecord.SLAEndDate__c = slaDateList[0].End__c.contains('+') ? (slaDateList[0].End__c.substring(0, slaDateList[0].End__c.lastIndexOf('+'))):slaDateList[0].End__c.contains('-')?(slaDateList[0].End__c.substring(0, slaDateList[0].End__c.lastIndexOf('-'))) : (slaDateList[0].End__c.substring(0, slaDateList[0].End__c.lastIndexOf('Z')));
//                                
//                                if(string.isEmpty(workOrderRecord.EntitlementEndDate__c) || workOrderRecord.EntitlementEndDate__c.contains('undefined'))
//                                woRecord.EntitlementEndDate__c = slaDateList[0].End__c; //Updated as part of defect 7869923
//                        //woRecord.EntitlementEndDate__c = slaDateList[0].End__c.contains('+') ? (slaDateList[0].End__c.substring(0, slaDateList[0].End__c.lastIndexOf('+'))):slaDateList[0].End__c.contains('-')?(slaDateList[0].End__c.substring(0, slaDateList[0].End__c.lastIndexOf('-'))) : (slaDateList[0].End__c.substring(0, slaDateList[0].End__c.lastIndexOf('Z')));
//                        
//                        if(string.isBlank(workOrderRecord.Need_by_Date__c))
//                            woRecord.Need_by_Date__c = tmpDate.substring(5,7) + '/' + tmpDate.substring(8,10) + '/' + tmpDate.substring(0,4); 
//                        
//                        if(string.isBlank(workOrderRecord.Need_by_Time__c)) {
//                            tmpDate = tmpDate.substring(tmpDate.indexOf('T')+1);
//                            woRecord.Need_by_Time__c = tmpDate.contains('+') ? (tmpDate.substring(0, tmpDate.indexOf('+'))) : (tmpDate.contains('-') ? (tmpDate.substring(0, tmpDate.indexOf('-'))) : (tmpDate.substring(0, tmpDate.indexOf('Z'))));
//                                }
//                        
//                    }
//                    system.debug('woRecord.SLAEndDate__c ' + woRecord.SLAEndDate__c);
//                    system.debug('sla ' + woRecord);
//                    //Defect 7918310 starts
//                    //List < Timezone__mdt > tzList = new List < Timezone__mdt > ();
//                    if(slaDateList[0].TimeZone__c == null || slaDateList[0].TimeZone__c == 'N/A' || slaDateList[0].TimeZone__c == '' )
//                    {
//
//
//                        tzList = [SELECT Default_Delta_Timezone__c, Default_SFDC_Timezone__c FROM ConvergedTimeZone__mdt WHERE CountryCode__c =: countryCodeNew LIMIT 1];
//
//
//                            woRecord.DeltaTimezone__c = tzList[0].Default_Delta_Timezone__c;
//                            woRecord.TimeZone__c = tzList[0].Default_SFDC_Timezone__c;
//                        }
//                    }
//                    else
//                    {    // CheckMarx US#8448239
//
//                        tzList = [SELECT DeltaTimezone__c FROM ConvergedTimeZone__mdt WHERE SFDC_Timezone__c =: slaDateList[0].TimeZone__c and CountryCode__c =: countryCodeNew LIMIT 1];
//
//
//                            woRecord.DeltaTimezone__c = tzList[0].DeltaTimezone__c;
//                        
//                    }
//                    //Defect 7918310 ends
//                    
//                    //woRecord.DeltaTimezone__c = slaDateList[0].TimeZone__c;
//                    //woRecord.DeltaShiftStart__c = slaDateList[0].ShiftStart__c;
//                    //woRecord.DeltaShiftEnd__c = slaDateList[0].ShiftEnd__c;
//                    
//                    
//                    update woRecord;
//                    
//                    if(! workOrderRecord.Service_Type__c.equalsIgnoreCase('Parts Only'))
//                    { 
//                        sarecord.EarliestStartTime = DateTime.valueOf(slaDateList[0].Start__c.replace('T', ' '));
//                        saRecord.DueDate = DateTime.valueOf(slaDateList[0].End__c.replace('T', ' '));
//                        update saRecord;
//                    }
//                }
//                
//            }
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'updateEntitlementDates', 'Converge Dispatch');
//        }
//    }
//
//
//    @AuraEnabled
//    public static Boolean checkForInstruction(Id workOrderId) 
//    {
//        Boolean hasInstruction = false;
//        List<WorkOrder> workOrderList = new List<WorkOrder>();
//        List<DispatchInstruction__c> instructionList = new List<DispatchInstruction__c>();
//
//        //Story 8346905 - Praful added Mail-In check
//        workOrderList = [SELECT Service_Type__c FROM WorkOrder 
//                        WHERE Service_Type__c IN ('Parts and Labor','Labor Only','Mail-In') AND Id =:workorderId];
//
//        if(!workOrderList.isEmpty())
//        {
//            instructionList = [SELECT Id FROM DispatchInstruction__c 
//                               WHERE Audience__c includes ('Field') AND Work_Order__c =:workorderId];
//            
//            if(!instructionList.isEmpty()) 
//            {
//                hasInstruction = true;
//            }
//        } else {
//            hasInstruction = true;
//        }
//        return hasInstruction;
//    }
//    
//    @AuraEnabled
//    public static string getCustomerReminders(Id workOrderId, String type){
//        List<Customer_Reminder__c> lstCR = [SELECT id, Type__c FROM Customer_Reminder__c where Work_Order__c =:workOrderId
//                                            AND Type__c=: type];
//        if(lstCR.isEmpty()){
//            return 'true';
//        } else {
//            return 'false';
//        }
//    }
//    
//    /*--
//    Component : getGCCConfigurations
//    Description: This method will return the Service Provider Values for GCC Agents based on the country
//    Change Log:
//    ===============================================================================================
//    Date                Author                  UserStory#               Change Description
//    ===============================================================================================
//    06-Nov-2019         Ramzil Cleopas          6803976                  Initial Version
//    */
//    @AuraEnabled
//    public static List<String> getGCCConfigurations(String countryCode){
//        
//        List<String> DSPValues = new List<String>();
//        
//        List<DispatchDSPDLP__c> DSPRecords = [Select PartnerCode__c, PartnerName__c 
//                                                FROM DispatchDSPDLP__c where 
//                                                Type__c = 'DSP' AND 
//                                                CountryCode__c =: countryCode 
//                                                AND Active__c = true];
//       
//        if(!DSPRecords.isEmpty()){
//            for(DispatchDSPDLP__c dspObj : DSPRecords){
//                DSPValues.add(dspObj.PartnerName__c); 
//            }
//            return DSPValues;
//        }else{
//            return null;
//        }
//    }
//    
//    /*--
//    Component : getPartnerCodeForGCC
//    Description: This method will return the Partner Code to update DSP value for GCC Users
//    Change Log:
//    ===============================================================================================
//    Date                Author                  UserStory#               Change Description
//    ===============================================================================================
//    14-Dec-2019         Ramzil Cleopas          6803976                  Initial Version
//    */
//    @AuraEnabled
//    public static DispatchDSPDLP__c getPartnerCodeForGCC(String partnerName, String countryCode){
//            
//        DispatchDSPDLP__c DSPRecord = new DispatchDSPDLP__c();
//        
//        DSPRecord = [Select Id,PartnerCode__c 
//                         FROM DispatchDSPDLP__c where 
//                         PartnerName__c =: partnerName AND 
//                         Type__c = 'DSP' AND 
//                         CountryCode__c =: countryCode 
//                         AND Active__c = true ];
//       
//        if(DSPRecord != null){           
//            return DSPRecord;
//        }else{
//            return null;
//        }
//    }
//    
//    /*--
//    Component : isGCCuser
//    Description: This method  will check if the user is having GCCUser PermissionSet or not
//    Change Log:
//    ===============================================================================================
//    Date                Author                  UserStory#               Change Description
//    ===============================================================================================
//    06-Nov-2019         Ramzil Cleopas          6803976                  Initial Version
//    */
//    @AuraEnabled
//    public static Boolean isGCCuser(){
//    
//         List<PermissionSetAssignment> GCCPerUserCheck = new List <PermissionSetAssignment>();
//        GCCPerUserCheck = [SELECT PermissionSetId FROM PermissionSetAssignment 
//                            WHERE AssigneeId =: UserInfo.getUserId() AND 
//                            (PermissionSet.Name = 'Work_Order_GCC_User' OR PermissionSet.Name = 'Service_LAP_Access') LIMIT 10];
//        System.debug('GCCPerUserCheck-->'+GCCPerUserCheck);
//         
//         if (GCCPerUserCheck.size()>0) {
//            return true;
//        }else{
//            return false;
//        }
//    }
//
//    @AuraEnabled
//    public static Boolean isLAPUser(){
//    
//         List<PermissionSetAssignment> LAPUserCheck = new List <PermissionSetAssignment>();
//        LAPUserCheck = [SELECT PermissionSetId FROM PermissionSetAssignment 
//                            WHERE AssigneeId =: UserInfo.getUserId() AND 
//                            PermissionSet.Name = 'Service_LAP_Access' LIMIT 10];
//        System.debug('LAPUserCheck-->'+LAPUserCheck);
//         
//         if (LAPUserCheck.size()>0) {
//            return true;
//        }else{
//            return false;
//        }
//    }
//
//    @AuraEnabled
//    public static WorkOrder getWorkOrderRecord(Id workOrderId){
//        WorkOrder wo = new WorkOrder();
//        try{
//            wo = [SELECT Id, OwnerId, Owner.Profile.Name, SiteAccessConfirmed__c FROM WorkOrder where Id =: workOrderId];
//        }catch(Exception ex){
//            ExceptionHandler.logHandledExceptions(ex, 'ConvergeDispatchHandler', 'getWorkOrderRecord', 'Converge Dispatch');
//        }
//        return wo;
//    }
//    
//    /**** STORY 7471867 start****/
//    
//    public class RepeatDispatchWap {
//        @AuraEnabled public Boolean ifAssetPurchasedRecently {
//            get;
//            set;
//        }
//        @AuraEnabled public String ServiceBUID {
//            get;
//            set;
//        }
//        @AuraEnabled public Boolean ifAssetHasRepeatDispatch {
//            get;
//            set;
//        }
//        @AuraEnabled public Integer recordsCount {
//            get;
//            set;
//        }
//        @AuraEnabled public Boolean invalidPPID {
//            get;
//            set;
//        }
//        @AuraEnabled public String repeatDispatchMessage {
//            get;
//            set;
//        }
//
//        public repeatDispatchWap() {
//            ifAssetPurchasedRecently = false;
//            ifAssetHasRepeatDispatch = false;
//            recordsCount = 0;
//            invalidPPID = false;
//            ServiceBUID = '';
//            repeatDispatchMessage = '';
//        }
//    }
//
//    @AuraEnabled
//    public static RepeatDispatchWap checkRepeatDispatchInAsset(string caseId,String countryCode)
//    /* 
//       Description : Check if Asset is purchased recently and if there is any workorder has been created in last 28 days in Asset associated to the case.
//       Author      : Bikram B
//       Date        : 27th March, 2018
//    */
//    {
//        try {
//
//            RepeatDispatchWap dispatchwap = new RepeatDispatchWap();
//            Integer recordsCount = 0;
//            boolean ifAssetHasRepeatDispatch = false;
//            if (!string.isBlank(caseId)) {
//                //Integer lastNDays_AssetPurchasedDate = 30;
//                //system.debug('Akhil++ inside checkRepeatDispatchInAsset');
//                System.debug('Akhil++ CountryCode :'+ countryCode);
//                Integer lastNDays_AssetPurchasedDate;
//                if(countryCode<>NULL && !(String.isBlank(countryCode))){
//                    //system.debug('Akhil++ inside checkRepeatDispatchInAsset CountryCode:'+countryCode);
//                    List<Asset_Country__mdt> acList =[Select Invoice_Time__c,CountryCode__c from Asset_Country__mdt where CountryCode__c=:countryCode LIMIT 1];
//                    if(acList<>NULL && acList.size()>0){
//                        lastNDays_AssetPurchasedDate = (Integer) acList[0].Invoice_Time__c;
//                    }
//                }
//                //Integer lastNDays = 28;
//                Integer lastNDays = integer.valueOf(System.Label.RepeatDispatchDaysCheck);
//                String repeatDispatchMessage = String.format(Label.Provide_Reason_For_Repeat_Work_Order, new List<String>{ Label.RepeatDispatchDaysCheck });
//                Date dispatchCreatedDateToCompare = Date.today().addDays(-1 * lastNDays);
//                List < Case > csList = [select AssetId from
//                    case where id = :
//                        caseId LIMIT 1
//                ];
//                if (csList != null && !csList.isEmpty() && csList[0].AssetId != null) {
//                    Asset assetRec = [select Country__c,Asset_Age__c, Invoice_Date_New__c, Customer_BUID__c,
//                        (select CreatedDate from workorders WHERE CreatedDate >=: dispatchCreatedDateToCompare and(status != 'Open'
//                                and status != 'Cancelled' and WO_Type__c = 'Break Fix')
//                            //and status IN('Pending Review', 'Approved', 'Problem', 'Work In Progress', 
//                            //              'Submitted', 'Awaiting Acknowledgement','Queued')
//                        )
//                        from Asset where id =: csList[0].AssetId LIMIT 1
//                    ];
//
//                    dispatchwap.ServiceBUID = assetRec.Customer_BUID__c;
//                    // Check if the Asset is purchased within the last 30 days
//                    if (assetRec.Invoice_Date_New__c != null) {
//                        if(assetRec.Country__c != null && lastNDays_AssetPurchasedDate == null)
//                        {
//                                List<Asset_Country__mdt> acList =[Select Invoice_Time__c,CountryCode__c from Asset_Country__mdt where CountryCode__c=:countryCode LIMIT 1];
//                                if(acList<>NULL && acList.size()>0) {
//                                    lastNDays_AssetPurchasedDate = (Integer) acList[0].Invoice_Time__c;
//                                }
//                        }
//                        //system.debug('Akhil++ inside invoice date is not null:'+lastNDays_AssetPurchasedDate);
//                        Integer numberofDays = assetRec.Invoice_Date_New__c.daysBetween(system.today());
//                        if (lastNDays_AssetPurchasedDate<>NULL && countryCode<>NULL && numberofDays >= 0 && numberofDays <= lastNDays_AssetPurchasedDate) {
//                            //system.debug('Akhil++ inside checkRepeatDispatchInAsset lastpurchasedDate:'+lastNDays_AssetPurchasedDate);
//                            dispatchwap.ifAssetPurchasedRecently = true;
//                        }
//                    }
//
//                    //else if(assetRec.workorders != null && !assetRec.workorders.isEmpty()){
//                    //if(!dispatchwap.ifAssetPurchasedRecently && assetRec.workorders != null && !assetRec.workorders.isEmpty()){
//                    if (assetRec.workorders != null && !assetRec.workorders.isEmpty()) {
//                        ifAssetHasRepeatDispatch = true;
//                        recordsCount = assetRec.workorders.size();
//                        dispatchwap.ifAssetHasRepeatDispatch = ifAssetHasRepeatDispatch;
//                        dispatchwap.recordsCount = recordsCount;
//                        dispatchwap.repeatDispatchMessage = repeatDispatchMessage;
//                    }
//                }
//            }
//            return dispatchwap;
//        } catch (Exception e) {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'checkRepeatDispatchInAsset', 'Converge Dispatch');
//            return null;
//        }
//    }
//    
//   /**** STORY 7471867 start****/
// /*--
//    Component : deleteServiceAppointment
//    Description: This method will be used when the remove Labor button is clicked
//    Change Log:
//    ===============================================================================================
//    Date                Author                  UserStory#               Change Description
//    ===============================================================================================
//    06-Nov-2019         Pawan Hegde               7660946                  Initial Version
//    */
//    @AuraEnabled
//    public static Boolean deleteServiceAppointment(Id workOrderId){
//        try{
//            List<ServiceAppointment> ServiceAppointments = [SELECT Id FROM ServiceAppointment WHERE Work_Order__c = :workOrderId LIMIT 50000];
//                if(ServiceAppointments.size()>0){
//                    delete ServiceAppointments;
//                    return true;
//                }
//                else
//                {
//                    return false;
//                }
//        }catch(Exception e){
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'deleteServiceAppointment', 'Converge Dispatch');
//            return false;
//        }
//    } 
//
//    /*--
//    Component : checkLaborDisplayView
//    Description: This method will be used when the remove Labor button is clicked
//    Change Log:
//    ===============================================================================================
//    Date                Author                  UserStory#               Change Description
//    ===============================================================================================
//    11-Nov-2019         Pawan Hegde             6803976                  Initial Version
//    14-Jan-2020         Roshni Singh            7808702                  v2
//    Apr-08-2020         Praful Desai            STORY 8258067            Removed Mail-In from partsOnlyServiceType
//    */
//    @AuraEnabled
//    public static Boolean checkLaborDisplayView(Id workOrderId){
//        try {
//            List<String> partsOnlyServiceType =new List<String>{'Carry-In', 'Collect','Remote'}; //STORY 8258067
//            //List<String> partsOnlyServiceType =new List<String>{'Mail-In','Carry-In', 'Collect','Remote'};
//            DispatchDefaults__c DispatchDefaultsRecord = [ Select Id,Bill_To__c,Service_Type__c FROM DispatchDefaults__c Where Work_Order__c =: workorderId Limit 1 ];
//            WorkOrder workorderRecord = [Select Id, status,CheckForServiceTypeEqualsLaborOnly__c, Bill_To__c From WorkOrder Where Id =: workOrderId];
//            if(workorderRecord.CheckForServiceTypeEqualsLaborOnly__c == true && !(partsOnlyServiceType.contains(DispatchDefaultsRecord.Service_Type__c))){    
//                return true;
//            } else if (partsOnlyServiceType.contains(DispatchDefaultsRecord.Service_Type__c) && workorderRecord.Bill_To__c!=null && workorderRecord.Bill_To__c!=''){
//                return true;
//            } else {
//                return false;
//            }
//        } catch(Exception e) {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'checkLaborDisplayView', 'Converge Dispatch');
//            return false;
//        }
//    }
//    
//    /*--
//    Component : laborFlagCheck
//    Description: This method will be used when the remove Labor button is clicked
//    Change Log:
//    ===============================================================================================
//    Date                Author                  UserStory#               Change Description
//    ===============================================================================================
//    19-Nov-2019         Pawan Hegde               6803976                  Initial Version
//    */
//    @AuraEnabled
//    public static Boolean laborFlagCheck(Id workOrderId) {
//        try {
//            WorkOrder workorderRecord = [Select Id, status, CheckForServiceTypeEqualsLaborOnly__c, Labor_Selected_Check__c From WorkOrder Where Id =: workOrderId];
//            return workorderRecord.Labor_Selected_Check__c;
//        } catch (Exception e) {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'laborFlagCheck', 'Converge Dispatch');
//            return false;
//        }
//    }
//
//    
//    /*--
//    Component : GCCEditCheck
//    Description: This method will be used when the remove Labor button is clicked
//    Change Log:
//    ===============================================================================================
//    Date                Author                  UserStory#               Change Description
//    ===============================================================================================
//    11-Nov-2019         Pawan Hegde               6803976                  Initial Version
//    */
//    @AuraEnabled
//    public static Boolean GCCEditCheck(Id workOrderId){
//    try
//        {
//            WorkOrder workorderRecord = [Select Id, status, Sub_Status__c From WorkOrder Where Id =: workOrderId];
//            List<PermissionSetAssignment> GCCPerUserCheck = new List <PermissionSetAssignment>();
//            
//            GCCPerUserCheck = [SELECT PermissionSetId FROM PermissionSetAssignment 
//                                WHERE AssigneeId =: UserInfo.getUserId() AND 
//                                PermissionSet.Name = 'Work_Order_GCC_User' LIMIT 10];
//                                
//            if((workorderRecord.status== System.Label.Work_Order_Problem_Status || workorderRecord.status == System.Label.Work_Order_Review_Status) && (workorderRecord.Sub_Status__c != 'REJECTED')){    
//                if(GCCPerUserCheck.size()>0){
//                    return true;
//                }else{
//                    return false;
//                }                                        
//            }else{
//                return false;
//            }
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'GCCEditCheck', 'Converge Dispatch');
//            return false;
//        }       
//    }
//    
//    /*--
//    Component : hideLaborButton
//    Description: This method will be used when the remove Labor button is clicked
//    Change Log:
//    ===============================================================================================
//    Date                Author                  UserStory#               Change Description
//    ===============================================================================================
//    19-Nov-2019         Pawan Hegde             6803976                  Initial Version
//    14-Jan-2020         Roshni Singh            7808702                  v2
//    Apr-08-2020         Praful Desai            STORY 8258067            Removed Mail-In from partsOnlyServiceType
//    */
//    @AuraEnabled
//    public static Boolean hideLaborButton(Id workOrderId){
//    try {
//            //List<String> partsOnlyServiceType =new List<String>{'Mail-In','Carry-In', 'Collect','Return','Parts Only'};
//            List<String> partsOnlyServiceType =new List<String>{'Carry-In', 'Collect','Return','Parts Only'}; //STORY 8258067
//            WorkOrder workorderRecord = [Select Id, status,Bill_To__c,EMC_Asset_Identifier__c From WorkOrder Where Id =: workOrderId];
//            DispatchDefaults__c DispatchDefaultsRecord = [ Select Id,Bill_To__c,Service_Type__c,BasicEntitlement__c FROM DispatchDefaults__c Where Work_Order__c =: workorderId Limit 1 ];
//            
//            if(workorderRecord.Bill_To__c != Null && workorderRecord.Bill_To__c != '--None--'){    
//                return false;                                        
//            }else if(partsOnlyServiceType.contains(DispatchDefaultsRecord.Service_Type__c) && DispatchDefaultsRecord.BasicEntitlement__c == true){
//                return true;
//            }else if(workorderRecord.EMC_Asset_Identifier__c == true && DispatchDefaultsRecord.BasicEntitlement__c == true){
//                return true;
//            }else{
//                return false;
//            }
//
//        } catch(Exception e) {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'hideLaborButton', 'Converge Dispatch');
//            return false;
//        }       
//    }
//    
//    /*--
//    Component : rescheduleQuickAction
//    Description: This method is for changing the owner temporarily on Rescheduling
//    Change Log:
//    ===============================================================================================
//    Date                Author                  UserStory#               Change Description
//    ===============================================================================================
//    06-DEC-2019         Shantanu Biswal          7755536                  Initial Version
//    */
//    @AuraEnabled
//    public static String getOwnerID(String workOrderId){
//        String workOrderOwner;
//
//
//        WorkOrder wr=[Select Id,OwnerId from workorder where id=:workOrderId limit 1];
//        String woOwner = wr.OwnerId;
//        String userId = UserInfo.getUserId();
//        User usr = [Select Id, Name, Profile.Name from User where Id=:userId LIMIT 1];
//        if(woOwner != userId && usr.Profile.Name == 'Work Order Elevated Access'){
//            workOrderOwner = wr.OwnerId;
//            wr.OwnerId= userId;
//            update wr;           
//        }
//        else{
//            workOrderOwner=  'OK';
//        }
//
//        return workOrderOwner;       
//    }
//      
//    @AuraEnabled
//    public static String hidePartsDeliverySection(Id workOrderId){
//    try
//        {
//            WorkOrder workorderRecord = [Select Id, CheckForServiceTypeEqualsLaborOnly__c, service_type__c,
//                                         Asset.EMC_Asset_Identifier__c,Delivery_Option__c From WorkOrder Where Id =: workOrderId];
//            User userRecord = [SELECT Id, Profile.Name,username from User where Id = :UserInfo.getUserId()];
//
//            if(workorderRecord.service_type__c == 'Parts and Labor' && workorderRecord.Asset.EMC_Asset_Identifier__c == true && ( userRecord.Profile.Name == 'Work Order Elevated Access' || userRecord.username == 'r.udhaya@dellteam.com.dellservices.dev1')) {
//                if(workorderRecord.Delivery_Option__c == 'Dell Preferred Delivery Location'){
//                    return 'HES_SAS_PL_DPDL';
//                }else if (workorderRecord.Delivery_Option__c == 'Customer Service Address'){
//                    return 'HES_SAS_PL_CSA';
//                }else if(workorderRecord.Delivery_Option__c == 'Manual Address Override'){
//                    return 'HES_SAS_PL_MAO';
//                }else{
//                    return 'HES_SAS_PL';
//                }
//            }else if(workorderRecord.CheckForServiceTypeEqualsLaborOnly__c == true){    
//                return 'Labor Only';                                        
//            }else{               
//                return 'Parts Only';
//            }
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeDispatchHandler', 'hidePartsDeliverySection', 'Converge Dispatch');
//            return 'Error';
//        }           
//     
// }
// 
//
//    
//    public with sharing class statusWrapper{
//        
//        @AuraEnabled public workOrder workOrderRecord {get; set;}
//        @AuraEnabled public String woStatusLastUpdatedDate {get; set;}
//        @AuraEnabled public String subStatusLastUpdatedDate {get; set;}
//        @AuraEnabled public String partStatusLastUpdatedDate {get; set;}
//        @AuraEnabled public String laborStatusLastUpdatedDate {get; set;}
//        @AuraEnabled public List<string> allWorkOrderStatusList {get; set;}
//        @AuraEnabled public Boolean disableEditOption {get;set;}
//        @AuraEnabled public Boolean GCCUser {get;set;} //adding Logic for GCC
//        
//        public statusWrapper(){
//            
//            workOrderRecord = new workOrder();
//            woStatusLastUpdatedDate = '';
//            subStatusLastUpdatedDate = '';
//            partStatusLastUpdatedDate = '';
//            laborStatusLastUpdatedDate = '';
//            allWorkOrderStatusList = new List<string>();
//            disableEditOption = false;
//            GCCUser =false; //adding Logic for GCC
//        }
//    }
//    /* -----------------------------------------------------------------------------------------------------------------------
//    Name:       fetchStatusFieldsData
//    Description:  this method fetches the work order status, part, labor and sub status from DB and shows on UI of lightning component
//    Input: workOrderId - work order record identifier
//    workOrderId - work order record identifier          
//    Output: an instance of the wrapper class(statusWrapper)
//    Date         Version  Author             Summary of Changes 
//    -----------  -------  -----------------  ------------------------------------------------------------------------------
//    14/12/2019     1.0     Rahul Jain   Initial Release
//    -------------------------------------------------------------------------------------------------------------------------- */    
//    @Auraenabled
//    public static statusWrapper fetchStatusFieldsData(String workOrderId){
//        
//        try{
//            List<WorkOrder> workOrderList = [Select Id, RecordType.DeveloperName, Status, Sub_Status__c, Comments__c, Labor_Status__c, Parts_Status__c, 
//                                             Labor_Status_Last_Modified__c, Parts_Status_Last_Modified__c,
//                                             Sub_Status_Last_Modified__c, LastModifiedDate, ISP_Comments__c, 
//                                             Reason_for_repeat_Work_Order__c From workOrder where Id = :workOrderId limit 1];
//            
//            statusWrapper statusWrapperInstance = new statusWrapper();
//            statusWrapperInstance.GCCUser =ShipPartsController.isGCCuser() ;//adding Logic for GCC
//            //String userProfile = '';
//            String wostatus = workOrderList[0].Status;
//            //List<User> userList = [Select Id, ProfileId from user where Id = :UserInfo.getUserId() limit 1];
//           //Profile profileName = [Select Name from Profile where Id = :userList[0].ProfileId limit 1];
//            //userProfile = profileName.Name;
//            String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
//            //Removing the logic for Profile Check--Dattaa1
//            /*List<User> userList = [Select Id, ProfileId from user where Id = :UserInfo.getUserId() limit 1];
//            
//            string profileIdsInCustomLabel = Label.Dispatch_ProfileIdsCommaSeparated;
//            
//            if(null != userList && userList.size() > 0 && String.isNotBlank(profileIdsInCustomLabel)){
//                
//                List<String> profileIdsList = new List<String>();
//                if(null != profileIdsInCustomLabel && profileIdsInCustomLabel.length() > 0){
//                    
//                    if(profileIdsInCustomLabel.contains(',')){
//                      profileIdsList = profileIdsInCustomLabel.split(',');
//                    }
//                    else{
//                        profileIdsList.add(profileIdsInCustomLabel);
//                    }
//                    //system.debug('profileIdsList ###'+profileIdsList);
//                    
//                    for(String IdProfile : profileIdsList){
//                        
//                        if(IdProfile.startswith('00e')){
//                            
//                          if(IdProfile == userList[0].ProfileId){
//                              statusWrapperInstance.disableEditOption = true;
//                          }
//                        }
//                    }
//                }
//            }*/
//            if(null != workOrderList && workOrderList.size() > 0){
//                
//                //system.debug('workOrderList[0].RecordType.DeveloperName ###'+workOrderList[0].RecordType.DeveloperName);
//                if(workOrderList[0].RecordType.DeveloperName == 'Delta_Dispatch')
//                    statusWrapperInstance.disableEditOption = true;
//                
//                Set<String> statuslist= new Set<String>();
//                    /*if(!statusWrapperInstance.GCCUser){ //adding Logic for GCC
//                        if(null != System.Label.Dispatch_Status_Not_Allowed)
//                        {
//                                for(String key : System.Label.Dispatch_Status_Not_Allowed.split(','))
//                                statuslist.add(key);
//                        }
//                    }
//                    else{    //adding Logic for GCC
//                        if(null != System.Label.Dispatch_Status_Allowed_GCC)
//                        {
//                                for(String key : System.Label.Dispatch_Status_Allowed_GCC.split(','))
//                                statuslist.add(key);
//                        }
//                    }*/
//           
//                
//                //Schema.DescribeFieldResult fieldResult = workOrder.Status.getDescribe(); 
//                //List<Schema.PicklistEntry> pick_list_values = fieldResult.getPicklistValues(); 
//               //for(Schema.PicklistEntry pe : pick_list_values){
//                    if(!statusWrapperInstance.GCCUser && (usrProfileName.equalsIgnoreCase('Service Agent')||usrProfileName.equalsIgnoreCase('System Administrator') )){//non GCC User
//                        if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Awaiting acknowledgement') ))
//                        {
//                          statusWrapperInstance.allWorkOrderStatusList.add('Cancellation Request');
//                        }
//                        if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Awaiting Compliance') ))
//                        {
//                          statusWrapperInstance.allWorkOrderStatusList.add('Cancellation Request');
//                        }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Awaiting acknowledgement') ))
//                        {
//                          statusWrapperInstance.allWorkOrderStatusList.add('Work In Progress');
//                        }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Pending Review') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Approved');
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Pending Review') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Re Work');
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Pending Review') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Approved') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Cancellation Request') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Service Complete') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Closed');
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Problem') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Cancellation Request');
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Problem') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Work In Progress') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Cancellation Request');
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Work In Progress') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Service Complete');
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Rework') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Open') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Delay/Service Interruption') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Service Complete');
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Delay/Service Interruption') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Cancellation Request');
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Cancellation Request') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Cancellation Request') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Work In Progress');
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Cancellation Request') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Service Complete');
//                         }
//
//                        
//                    }
//                    else if(usrProfileName.equalsIgnoreCase('Work Order Approver')|| statusWrapperInstance.GCCUser){//Approver Profile
//                        
//                        /*  if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Awaiting acknowledgement') ))
//                       {
//                          statusWrapperInstance.allWorkOrderStatusList.add('Cancellation Request');
//                         system.debug('RAHUL3'+statusWrapperInstance);
//                        }*/
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Awaiting acknowledgement') ))
//                        {
//                          statusWrapperInstance.allWorkOrderStatusList.add('Work In Progress');
//                          system.debug('RAHUL4'+statusWrapperInstance);
//                        }
//                   /*      system.debug('RAHUL100'+workOrderList[0].Status);
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Pending Review') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Approved');
//                         system.debug('RAHUL5'+statusWrapperInstance);
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Pending Review') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Rework');
//                         system.debug('RAHUL6'+statusWrapperInstance);
//                         } */
//                   //     /* if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Pending Review') ))
//                    //     {
//                   //      statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
//                   //      system.debug('RAHUL7'+statusWrapperInstance);
//                   //      }
//                    //     if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Approved') ))
//                   //      {
//                   //      statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
//                   //      system.debug('RAHUL8'+statusWrapperInstance);
//                    //     }
//                   //      if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Cancellation Request') ))
//                      //   {
//                  //     statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
//                   //      system.debug('RAHUL9'+statusWrapperInstance);
//                   //      } */
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Service Complete') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Closed');
//                         system.debug('RAHUL10'+statusWrapperInstance);
//                         }
//                    //   /*  if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Problem') ))
//                   //      {
//                   //      statusWrapperInstance.allWorkOrderStatusList.add('Cancellation Request');
//                   //      system.debug('RAHUL11'+statusWrapperInstance);
//                   //      }
//                   //      if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Problem') ))
//                   //      {
//                   //      statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
//                    //     system.debug('RAHUL12'+statusWrapperInstance);
//                    //     }
//   //    if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Work In Progress') ))
//     //                    {
//      //                   statusWrapperInstance.allWorkOrderStatusList.add('Cancellation Request');
//       //                  system.debug('RAHUL13'+statusWrapperInstance);
//       //                  } */
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Work In Progress') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Service Complete');
//                         system.debug('RAHUL14'+statusWrapperInstance);
//                         }
//                    /*     if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Rework') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
//                         system.debug('RAHUL15'+statusWrapperInstance);
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Open') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
//                         system.debug('RAHUL16'+statusWrapperInstance);
//                         } */
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Delay/Service Interruption') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Service Complete');
//                         system.debug('RAHUL17'+statusWrapperInstance);
//                         }
//                       /*  if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Delay/Service Interruption') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Cancellation Request');
//                         system.debug('RAHUL18'+statusWrapperInstance);
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Cancellation Request') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
//                         system.debug('RAHUL19'+statusWrapperInstance);
//                         }*/
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Cancellation Request') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Work In Progress');
//                         system.debug('RAHUL20'+statusWrapperInstance);
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Cancellation Request') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Service Complete');
//                         system.debug('RAHUL21'+statusWrapperInstance);
//                         }
//                        if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Cancellation Request') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
//                         system.debug('RAHUL21'+statusWrapperInstance);
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Cancelled') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Cancelled');
//                         system.debug('RAHUL21'+statusWrapperInstance);
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Closed') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Closed');
//                         system.debug('RAHUL21'+statusWrapperInstance);
//                         }
//                          if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Open') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Open');
//                         system.debug('RAHUL21'+statusWrapperInstance);
//                         }
//                          if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Approved') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Approved');
//                         system.debug('RAHUL21'+statusWrapperInstance);
//                         }
//                          if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Rework') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Rework');
//                         system.debug('RAHUL21'+statusWrapperInstance);
//                         }
//                          if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Service Complete') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Service Complete');
//                         system.debug('RAHUL21'+statusWrapperInstance);
//                         }
//                         if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Pending Review') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Pending Review');
//                         system.debug('RAHUL24'+statusWrapperInstance);
//                         }
//                          if(null != workOrderList[0].Status && (workOrderList[0].Status.equalsIgnoreCase('Problem') ))
//                         {
//                         statusWrapperInstance.allWorkOrderStatusList.add('Problem');
//                         system.debug('RAHUL21'+statusWrapperInstance);
//                         }
//                    }
//                    
//                statusWrapperInstance.workOrderRecord = workOrderList[0]; 
//                statusWrapperInstance.woStatusLastUpdatedDate = fetchDateAndHours(workOrderList[0].LastModifiedDate);
//                statusWrapperInstance.subStatusLastUpdatedDate = fetchDateAndHours(workOrderList[0].Sub_Status_Last_Modified__c);
//                statusWrapperInstance.partStatusLastUpdatedDate = fetchDateAndHours(workOrderList[0].Parts_Status_Last_Modified__c);
//                statusWrapperInstance.laborStatusLastUpdatedDate = fetchDateAndHours(workOrderList[0].Labor_Status_Last_Modified__c);
//                return statusWrapperInstance;
//            }
//            else 
//                return null;
//         }
//         catch(exception e){
//          ExceptionHandler.logHandledExceptions(e,'ConvergeDispatchHandler','fetchStatusFieldsData','fetchStatusFieldsData');
//          return null;
//      }
//    }
//     
//    @Auraenabled
//    public static String fetchDateAndHours(DateTime lastModifiedDate){
//         
//        String  dateTimeString = '';
//        if(null != lastModifiedDate)
//            dateTimeString = lastModifiedDate.format('MM/dd/yy HH:mm');
//        return dateTimeString;
//    }
// 
//  /* Method for getting Work Order Pending Site Access Object, Shantanu for Reschedule User Story 7775205 */
//    @AuraEnabled
//    public static Work_Order_Pending_Site_Access__c getWOPendingSADetails(String workOrderId){        
//        Work_Order_Pending_Site_Access__c woSAP = new Work_Order_Pending_Site_Access__c();
//
//        WorkOrder wr=[Select Id,WorkOrderNumber from workorder where id=:workOrderId limit 1];
//
//
//        woSAP = [Select Id,WorkOrder__c,OwnerId, HasTakenOwnerShip__c from Work_Order_Pending_Site_Access__c where Work_Order_Number__c=:wr.WorkOrderNumber limit 1];
//
//
//
//        woSAP.HasTakenOwnerShip__c = true;
//        update woSAP;
//
//        return woSAP;
//    }
// /* Method to fetch Asset hold status from Bill SDR system through SwaggerAPI callout.: defect 7866229 */
//    @AuraEnabled
//    public static String getAssetHoldStatus(String assetId){ 
//        try{
//            String assetHoldStatusValue;     
//            String assetName = [Select Name from Asset where id =:assetId].Name;        
//            if(assetName != null){
//               // String endpointURL = label.SwaggerDomainUrl + assetName + '?apikey=' + label.convergeswaggerapikey;
//                String endpointURL = label.ConvergeSwaggerAssetOnHoldUrl+ assetName + '?apikey=' + label.ConvergeSwaggerApiKeyVal;
//                Http h = new Http();
//                HttpRequest req = new HttpRequest();
//                req.setEndpoint(endpointURL);
//                req.setMethod('GET');
//                HttpResponse res = h.send(req);
//                
//                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
//                String assetValue = (String)results.get('AssetHoldStatus');
//
//                List<Asset_Hold_Status__mdt> lstAssetHoldStatus = [Select Id,WO_Creation_Not_Allowed__c from Asset_Hold_Status__mdt where MasterLabel = :assetValue limit 1];
//                if(!lstAssetHoldStatus.isEmpty() && lstAssetHoldStatus[0].WO_Creation_Not_Allowed__c){
//                    assetHoldStatusValue = 'Asset On Hold';
//                    return assetHoldStatusValue;
//                }
//                else return 'success';
//            }else return null;
//        }
//        catch(Exception ex){
//            System.debug('getAssetHoldStatus '+ex.getMessage());
//            ExceptionHandler.logHandledExceptions(ex,'ConvergeDispatchHandler','getAssetHoldStatus','Converge Dispatch');
//            return null;
//        }  
//    }
//    /* Method for getting Work Order Pending Approval Object */
//    @AuraEnabled
//    public static DispatchPendingApproval__c getWOPendingApprovalDetails(String recordId){        
//        DispatchPendingApproval__c dispatchPendingApproval =[Select Id,Work_Order__c from DispatchPendingApproval__c where id=:recordId limit 1];
//        return dispatchPendingApproval;
//    }
//    /* Method for getting Work Order data for Pending Approval Object */
//    @AuraEnabled
//    public static WorkOrder getWOData(String workorderId){  
//        WorkOrder workorder =[Select Id, KYHD__c, Complete_Care_Option__c,Reason_for_Damage__c,AD_Override_Reason_PO__c, Site_Delivery_Allowed__c,DSP_Override_Request__c, Deferral_Call__c, CallType__c,
//        Address_Line_1__c,Address_Line_2__c,Address_Line_3__c, Address_Line_4__c, City_APJ__c,State_APJ__c,Shipping_Country__c, Zip_Code__c,
//        Region__c, DPS_Sub_Region__c,EntitlementStartDate__c,EntitlementEndDate__c, Timezone__c from WorkOrder where id=:workorderId];
//        return workorder;
//    }
//    
//    /* -----------------------------------------------------------------------------------------------------------------------
//    Name:       getESupportURL
//    Description:  this function contains the logic to make a call to get eSupport URL
//    Input: 
//    Output: None
//    Date         Version  Author             Summary of Changes 
//    -----------  -------  -----------------  ------------------------------------------------------------------------------
//    09/01/2018     1.0     Rodrigo Carpio    Initial Release
//    -------------------------------------------------------------------------------------------------------------------------- */   
//    @AuraEnabled   
//    public static void getESupportURL(ID workOrderId) 
//    {
//        try {
//
//            Workorder workOrderRecord = [select id,DPS_BUID__c,eSupport_URL__c,eSupportCalendar_URL__c,PartnerWorkOrderNumber__c,
//                                            DeltaSRNumber__c,ContactEmal__c,Timezone__c,Schedule_Enable_Flag__c from workorder where Id =:workorderId limit 1];
//                
//            ServiceAppointment SA = new ServiceAppointment();
//            SA = [Select Id, Service_Start__c, Service_End__c,CountryCode
//                    FROM ServiceAppointment 
//                    WHERE Work_Order__c =: workOrderRecord.Id  Limit 1];
//
//            if (string.isNotBlank(SA.Service_Start__c)) {
//                calendarDownload = 'Y';
//            }
//            if (String.isNotBlank(SA.Service_Start__c) && workOrderRecord.Schedule_Enable_Flag__c.equalsIgnoreCase('Y')) {
//                pageType = 'SCHEDULE';
//            }
//            
//            list < ESupportUrlResponse__x > objESupport = new list < ESupportUrlResponse__x > ();
//            
//            objESupport = (!mockedESupportURLResponse.isEmpty()) ? mockedESupportURLResponse : [SELECT EsupportCalendarUrl__c,
//                                                                                                EsupportUrl__c, ResponseCode__c, ResponseMessage__c
//                                                                                                FROM ESupportUrlResponse__x
//                                                                                                WHERE Buid__c =: workOrderRecord.DPS_BUID__c 
//                                                                                                AND CountryCode__c =: SA.CountryCode
//                                                                                                AND DPSNumber__c =: workOrderRecord.PartnerWorkOrderNumber__c 
//                                                                                                AND SRNumber__c =: workOrderRecord.DeltaSRNumber__c
//                                                                                                AND EmailId__c =: workOrderRecord.ContactEmal__c
//                                                                                                AND TimeZone__c =: workOrderRecord.Timezone__c
//                                                                                                AND PageType__c =: pageType AND IncludeCalendarDownload__c =: calendarDownload
//                                                                                                AND StartDate__c =: SA.Service_Start__c AND EndDate__c =: SA.Service_End__c
//                                                                                            ];
//                                                                                                system.debug('after eSupport Call - ' + objESupport);
//            if (objESupport.size() > 0 && !objESupport.isEmpty() && objESupport != null) {
//                if (objESupport[0].ResponseCode__c.equals('100')) {
//                    workOrderRecord.eSupport_URL__c = objESupport[0].EsupportUrl__c;
//                    workOrderRecord.eSupportCalendar_URL__c = objESupport[0].EsupportCalendarUrl__c;
//                } else {
//                    workOrderRecord.eSupport_URL__c = 'http://www.dell.com/support/incidents-online/' + SA.CountryCode + '/en/19/srSearch';
//                }
//            } else {
//
//            }
//
//            //return wo;
//            update workOrderRecord;
//        }
//        catch (Exception e) {
//            ExceptionHandler.logHandledExceptions(e, 'DispatchSubmissionProcess', 'getESupportURL', 'Dispatch Management');              
//        }
//    }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//    //Krishna : User Story - 6269291
//    /*
//@AuraEnabled(cacheable=true)
//    public static List<DLPLookup__x> getWorkOrderList(String searchText) {
//        //String key = '%' + searchText + '%';
//        //return [SELECT Id,WorkOrderNumber,Status,Shipping_Country__c,Preferred_Delivery_Location__c FROM WorkOrder where 
//                //WorkOrderNumber LIKE :key LIMIT 5];
//        String key = searchText;
//        return [SELECT Id,ISOCountryCode__c,ISPFSDPUDOId__c,ISPFSDPUDOStatus__c,ISPPudoAddressLine1__c,ISPPudoAddressLine2__c,ISPPudoAddressLine3__c,ISPPudoAddressLine4__c,ISPPudoAddressSequence__c,ISPPudoCity__c,ISPPudoCountryCode__c,ISPPudoCustAddressLine1__c,ISPPudoCustAddressLine2__c,ISPPudoCustAddressLine3__c,ISPPudoCustAddressLine4__c,ISPPudoCustCity__c,ISPPudoCustCountryCode__c,ISPPudoCustCountry__c,ISPPudoCustomerNumber__c,ISPPudoCustState__c,ISPPudoCustZipCode__c,ISPPUDODesc__c,ISPPUDOName__c,ISPPudoState__c,ISPPudoZipCode__c,LocationType__c,DestinationType__c,ContactName__c,ContactPhone__c,ContactEmail__c FROM DLPLookup__x WHERE State__c = 'TX' AND PostalCode__c LIKE :key AND  City__c = 'ROUND ROCK' AND ServiceLevel__c = 'Next Business Day' AND ServiceHRs__c = '' AND ServiceType__c = 'Break Fix' AND DASP__c = null AND BulkFlag__c = 'N' AND DSPCode__c = null  AND ServiceProviderId__c = 'UNY' AND ISOCountryCode__c = 'US'  AND Region__c = 'AMERICAS' AND ServiceSubType__c = 'Parts and Labor' AND LOB__c = '4EM' AND OOW__c = 'true' AND OOH__c = 'false' AND GroundShipFlg__c = 'false' AND KYC__c = 'false' AND KYHD__c = 'false' AND FederalOconusFlag__c = null AND Billable__c = null AND CompleteCare__c = 'false' AND ServiceTag__c = 'CLARiiONAX4-5F' AND Country__c = 'US' AND PartsDLP__c = null AND CallType__c = null];
//        //return [SELECT Id,ISOCountryCode__c,ISPFSDPUDOId__c,ISPFSDPUDOStatus__c,ISPPudoAddressLine1__c,ISPPudoAddressLine2__c,ISPPudoAddressLine3__c,ISPPudoAddressLine4__c,ISPPudoAddressSequence__c,ISPPudoCity__c,ISPPudoCountryCode__c,ISPPudoCustAddressLine1__c,ISPPudoCustAddressLine2__c,ISPPudoCustAddressLine3__c,ISPPudoCustAddressLine4__c,ISPPudoCustCity__c,ISPPudoCustCountryCode__c,ISPPudoCustCountry__c,ISPPudoCustomerNumber__c,ISPPudoCustState__c,ISPPudoCustZipCode__c,ISPPUDODesc__c,ISPPUDOName__c,ISPPudoState__c,ISPPudoZipCode__c FROM DLPLookup__x WHERE State__c = 'TX' AND ServiceLevel__c = 'Next Business Day' AND ServiceHRs__c = '' AND ServiceType__c = 'Break Fix' AND DASP__c = null AND BulkFlag__c = 'N' AND DSPCode__c = null AND PostalCode__c = '78664' AND ServiceProviderId__c = 'UNY' AND ISOCountryCode__c = 'US' AND City__c = 'ROUND ROCK' AND Region__c = 'AMERICAS' AND ServiceSubType__c = 'Parts and Labor' AND LOB__c = '4EM' AND OOW__c = 'true' AND OOH__c = 'false' AND GroundShipFlg__c = 'false' AND KYC__c = 'false' AND KYHD__c = 'false' AND FederalOconusFlag__c = null AND Billable__c = null AND CompleteCare__c = 'false' AND ServiceTag__c = 'CLARiiONAX4-5F' AND Country__c = 'US' AND PartsDLP__c = null AND CallType__c = null];
//        
//    }
//    */
//   //US8318921 starts          
//    @AuraEnabled            
//    public static Boolean getRescheduleDetails(String workorderId) {   
//        try{
//        Boolean RescheduleCheck = false;  
//        String PartPickVal = 'NA';
//        String PDLType = 'NA';
//        String PartStatus = 'NA';
//        ServiceAppointment[] SA = [SELECT status,event_type__c,Work_Order__r.PDL_Type__c, Work_Order__r.Status, Work_Order__r.Labor_status__c, Work_Order__r.Parts_Status__c  FROM serviceAppointment WHERE Work_Order__c  =:workorderId  AND Work_Order__r.Service_Type__c = 'Parts and Labor' and Event_Type__c = 'Part Pick Up' ];       
//        if(SA.size() == 0)
//        {
//            SA = [SELECT status,event_type__c,Work_Order__r.PDL_Type__c, Work_Order__r.Status, Work_Order__r.Labor_status__c, Work_Order__r.Parts_Status__c  FROM serviceAppointment WHERE Work_Order__c  =:workorderId  AND Work_Order__r.Service_Type__c = 'Parts and Labor' and Event_Type__c = 'Labor' ];       
//        }
//        if(SA.size() > 0)    
//        {
//            if(SA[0].Work_Order__r.PDL_Type__c != null && SA[0].Work_Order__r.PDL_Type__c != '')
//            {
//                PDLType = SA[0].Work_Order__r.PDL_Type__c;
//            }
//            if(SA[0].status != null && SA[0].status != '' && SA[0].Event_Type__c == 'Part Pick Up')
//            {
//                PartPickVal = SA[0].status;
//            }
//            if(SA[0].Work_Order__r.Parts_Status__c != null && SA[0].Work_Order__r.Parts_Status__c != '')
//            {
//                PartStatus = SA[0].Work_Order__r.Parts_Status__c;
//            }
//            List<Reschedule_Setting__mdt> rescheduleSettings = [SELECT Reschedule_Access__c FROM Reschedule_Setting__mdt where Labor_Status__c= :SA[0].Work_Order__r.Labor_status__c and Part_Delivery_Location__c= :PDLType and Part_Pickup_Status__c = :PartPickVal and Part_Status__c =:PartStatus and WO_Status__c = :SA[0].Work_Order__r.Status];         
//            if(rescheduleSettings != null && rescheduleSettings.size() > 0){        
//                RescheduleCheck = rescheduleSettings[0].Reschedule_Access__c;     
//            } 
//        }  
//        system.debug('RescheduleCheck:::'+RescheduleCheck);
//        return RescheduleCheck;  
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeSchedulingHandler', 'getRescheduleDetails', 'Converge Dispatch');
//            return null;
//        }
//    }                   
//    //US8318921 ends    
//
//    //US8326509 starts          
//    @AuraEnabled            
//    public static List<ServiceAppointment> UpdateReschedulingDates(String workOrderId,String ServiceDate,String starDateTime,String endDateTime, String UIstarDateTime, String UIendDateTime) {   
//        try{
//
//
//
//            SA = [Select id,Service_Date__c,Service_Start__c,Service_End__c,Service_Start_UI__c,Service_End_UI__c,Status from serviceAppointment where work_order__c=:workOrderId];
//            }
//
//            {
//               for(ServiceAppointment salist : SA){
//                    salist.Service_Date__c = ServiceDate;                 
//                    salist.Service_Start__c = starDateTime;
//                    salist.Service_End__c = endDateTime;
//                    salist.Service_Start_UI__c = UIstarDateTime;
//                    salist.Service_End_UI__c = UIendDateTime;
//                    salist.Status = 'Acknowledged';
//                } 
//                update SA;
//            }
//            return SA;  
//        }
//        catch(Exception e) 
//        {
//            ExceptionHandler.logHandledExceptions(e, 'ConvergeSchedulingHandler', 'UpdateReschedulingDates', 'Converge Dispatch');
//            return null;
//        }
//    }     
//    //US8326509 ends    
}