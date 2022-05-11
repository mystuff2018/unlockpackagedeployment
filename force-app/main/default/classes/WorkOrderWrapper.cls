public with sharing class WorkOrderWrapper {
    /* Work Order Fields */
    @AuraEnabled
    public Double AssetManufacturerNo;
    @AuraEnabled
    public String AssetSerialNumber;
    @AuraEnabled
    public Boolean CheckForServiceTypeEqualsPartsOnly;
    @AuraEnabled
    public Boolean CheckForServiceTypeEqualsRepairCenter;
    @AuraEnabled
    public String DPSBUID;
    @AuraEnabled
    public Boolean EMCAssetIdentifier;
    @AuraEnabled
    public Boolean GroundShipmentFlag;
    @AuraEnabled
    public String Id;
    @AuraEnabled
    public String LaborSource;
    @AuraEnabled
    public String ServiceTag;
    @AuraEnabled
    public String ServiceOption;
    @AuraEnabled
    public String ServiceType;
    @AuraEnabled
    public String ShippingCountry;
    @AuraEnabled
    public String SpecialOption;
    @AuraEnabled
    public String WorkOrderNumber;
    /* JS fields */
    @AuraEnabled
    public Boolean batteryPresent;
    @AuraEnabled
    public String comdelrefresh = '';
    @AuraEnabled
    public String Commodityclass = '';
    @AuraEnabled
    public String CountryCde;
    @AuraEnabled
    public String Defcmpclass = '';
    @AuraEnabled
    public String defcompDelrefresh = '';
    @AuraEnabled
    public Boolean onLoad = true;
    @AuraEnabled
    public Boolean promptAutoPart = false;
    @AuraEnabled
    public Boolean RtnToDefault = false;
    @AuraEnabled
    public String SearchManualClass = 'SearchManual slds-hide';
    @AuraEnabled
    public Boolean showSerialNumber = false;
    @AuraEnabled
    public Boolean showTabCommodity = false;
    @AuraEnabled
    public Boolean ViewSPMD = false;
    @AuraEnabled
    public String AssetItemClass {get;set;}
    @AuraEnabled
    public Boolean serviceOptionHasHourOrSame {get;set;}
    @AuraEnabled
    public Boolean isOutsideClickPolygon = false;
    @AuraEnabled
    public String AssetPSNT {get;set;}
    @AuraEnabled public Boolean showSerialNumberSearch;
    @AuraEnabled public Boolean showComponentTypeSearch;
    @AuraEnabled public Boolean hasAPS;
    @AuraEnabled public String callType;
    @AuraEnabled public String origin;
    @AuraEnabled public Boolean hasBasePart;
    @AuraEnabled public Boolean isBasePartEligible;
    @AuraEnabled public Boolean isCsPartsValidation;

    
    public WorkOrderWrapper(WorkOrder workOrder) {
        this.Id = workOrder.Id;
        this.CheckForServiceTypeEqualsPartsOnly = workOrder.CheckForServiceTypeEqualsPartsOnly__c;
        this.CheckForServiceTypeEqualsRepairCenter = workOrder.CheckForServiceTypeEqualsRepairCenter__c;
        this.DPSBUID = workOrder.DPS_BUID__c;
        this.EMCAssetIdentifier = workOrder.EMC_Asset_Identifier__c;
        this.GroundShipmentFlag = workOrder.Ground_Shipment_Flag__c;
        this.LaborSource = workOrder.Labor_Source__c;
       // this.origin = workOrder.Workorder_Origin__c;
        this.ServiceOption = workOrder.Service_Option__c;
        this.ServiceTag = workOrder.ServiceTag__c;
        this.ServiceType = workOrder.Service_Type__c;
        this.ShippingCountry = workOrder.Shipping_Country__c;
        this.SpecialOption = workOrder.Special_Option__c;
        this.WorkOrderNumber = workOrder.WorkOrderNumber;
      //  this.hasBasePart = workOrder.Has_Base_Part__c;
      //  this.isBasePartEligible = workOrder.Is_Base_Part_Eligible__c;
        if(workOrder.Asset != null){
       //     this.AssetManufacturerNo = workOrder.Asset.Manufacturer_No__c;
            this.AssetSerialNumber = workOrder.Asset.SerialNumber;
            this.AssetItemClass = workOrder.AssetItemClass__c;
         //   this.AssetPSNT = workOrder.Asset.PSNT__c;
        }else{
            this.AssetManufacturerNo = 0;
            this.AssetSerialNumber = '';
        }
        
        if(this.ServiceOption != null)
            this.serviceOptionHasHourOrSame = this.ServiceOption.contains('Hour') || this.ServiceOption.contains('Same');
    }
    
    public static WorkOrderWrapper createWorkOrderWrapper(WorkOrder workOrder){
        WorkOrderWrapper wow = new WorkOrderWrapper(workOrder);
        return wow;
    }
}