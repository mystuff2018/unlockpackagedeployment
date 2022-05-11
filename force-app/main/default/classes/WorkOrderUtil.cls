/**
 * @description       : Utility class to prevent duplicated code and keep the code readable
 * @author            : Julia Wood
 * Modifications Log 
 * Ver   Date            Author                               Modification
 * 1.0   02-Mar-2021    Cadu/Julia                          Initial Release                  
**/ 

public with sharing class WorkOrderUtil {
    
    public class WorkOrderServiceOption {

        public String serviceLevel {get; set;}
        public String serviceHours {get; set;}
    
        public WorkOrderServiceOption(String serviceLevel, String serviceHours) {
            this.serviceLevel = serviceLevel;
            this.serviceHours = serviceHours;
        }
        public WorkOrderServiceOption() {
            this.serviceLevel = '';
            this.serviceHours = '';
        }
    }

/*	public static WorkOrderServiceOption extractServiceOption(String serviceOption) {
        if (String.isBlank(serviceOption) || (serviceOption.indexOf('-') < 0)) {
            return new WorkOrderServiceOption();
        }
    //    String serviceLevel = StringUtil.safeEscapeSingleQuotes(serviceOption.substringBefore('-'));
    //    String serviceHours = StringUtil.safeEscapeSingleQuotes(serviceOption.substringAfter('-'));
       return new WorkOrderServiceOption(serviceLevel, serviceHours);
    }

    public static Boolean isHES(WorkOrder workOrder){
    //    WOFulfillmentRoutesHelper woRouteHelper = new WOFulfillmentRoutesHelper(workOrder.WO_Fulfillment_Routes__c); 
       return woRouteHelper.isHESPartPath();
    }

    public static String getServiceTag(WorkOrder workOrder){
     /*   WOFulfillmentRoutesHelper fulfillmentRoutes = new WOFulfillmentRoutesHelper(workOrder.WO_Fulfillment_Routes__c);
        if(fulfillmentRoutes.isDualSerialized()){
            return fulfillmentRoutes.getAssetIdentifier();
        }else{
            return workorder?.Asset?.Name;
        }
    }*/
    
    public static Boolean containsCruPart(List<WorkOrderLineItem> lineItems) {
        if (lineItems == null || lineItems.isEmpty()) {
            return null;
        }
        for (WorkOrderLineItem lineItem : lineItems) {
        //    if (lineItem.CRU_FRU__c == 'CRU') {
                return true;
            //}
        }
        return false;
    }

    public static Boolean containsFruPart(List<WorkOrderLineItem> lineItems) {
        if (lineItems == null || lineItems.isEmpty()) {
            return null;
        }
        for (WorkOrderLineItem lineItem : lineItems) {
         //   if (lineItem.CRU_FRU__c == 'FRU') {
                return true;
          //  }
        }
        return false;
    }

    public static Boolean containsNonHardDrivePart(List<WorkOrderLineItem> lineItems) {
        if (lineItems == null || lineItems.isEmpty()) {
            return null;
        }
        for (WorkOrderLineItem lineItem : lineItems) {
       //     if (lineItem.PartCommodity__c != LightningAppConstants.COMMODITIES.HARD_DRIVE) {
                return true;
         //   }
        }
        return false;
    }

     //utility
     public static Boolean isAccountSiteAccess (WorkOrder wo){
        return (wo.Account.Site_Access_Required__c == 'Yes' && wo.Account.Customer_Confirmation_Required__c =='Yes');        
    }

    public static Boolean isWoBreakFix(workOrder wo){
        return (wo.Wo_Type__c == 'Break Fix');
    }

  /*  public static Boolean isWorkTypeProductProblem(workOrder wo){
       return (wo.Work_Type__c == 'Product Problem');
    }

    public static Boolean isWoProfessionalServices(workOrder wo){
        return (wo.Case.Case_Type__c == 'Professional Services');
    }

    public static Boolean isWoMaintenance(workOrder wo){
    //    return (wo.Case.Case_Type__c  == 'Maintenance Services');
    }

    public static Boolean isCaseTypeAllowed(workOrder wo){
        return !(isWoMaintenance(wo) || isWoProfessionalServices(wo));
    }

 /*   //TODO: Offer a check on workOrderItems
    public static Boolean hasParts (String serviceType){
   //     return serviceType == WorkOrderConstants.SERVICE_TYPE_PO || serviceType == WorkOrderConstants.SERVICE_TYPE_PNL;
    }
    //TODO: Offer a check on serviceAppointment
    public static Boolean hasLabor (String serviceType){
   //     return serviceType == WorkOrderConstants.SERVICE_TYPE_LO || serviceType == WorkOrderConstants.SERVICE_TYPE_PNL;
    }*/
}