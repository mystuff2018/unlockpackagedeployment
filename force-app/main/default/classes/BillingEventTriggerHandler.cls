/***************************************************************************************
* Created By - Shweta Meshram (SFDC Fed Services-Dell)
* Created On - March,2021
* Related Task -
* Purpose - Handler class for pse__Billing_Event__c object trigger
****************************************************************************************/
public class BillingEventTriggerHandler extends TriggerHandler{
/************************************************************************************
* Created By - Shweta Meshram ( SFDC Fed Services-Dell)
* Created On - March,2021
* Related Task - 
* Purpose -  When ever billing event genrated on Miles stone create Po request for billing
*		  - 
***********************************************************************************/
    public Map<Id, pse__Billing_Event__c> triggerNewMap { get; set; }
    public Map<Id, pse__Billing_Event__c> triggerOldMap { get; set; }
    public List<pse__Billing_Event__c> triggerNew { get; set; }
    public List<pse__Billing_Event__c> triggerOld { get; set; }
    
    public BillingEventTriggerHandler(){
        if(TriggerHandler.isBypassed(BillingEventTriggerHandler.class.getName()))
            return;
        filterRecordsByRecordType();
    }
    private void filterRecordsByRecordType() {
        system.debug('Called Trigger::::::');
        this.triggerNewMap = new Map<Id, pse__Billing_Event__c>();
        this.triggerOldMap = new Map<Id, pse__Billing_Event__c>();
        this.triggerNew = new List<pse__Billing_Event__c>();
        this.triggerOld = new List<pse__Billing_Event__c>();
        
        //mount triggerNewMap
        if (Trigger.NewMap != null) {
            this.triggerNewMap = (Map<Id, pse__Billing_Event__c>)Trigger.NewMap;
        }
        //mount triggerOldMap
        if (Trigger.OldMap != null) {
            this.triggerOldMap = (Map<Id, pse__Billing_Event__c>) Trigger.OldMap;
        }
        //mount triggerNew
        if (Trigger.New != null) {
            this.triggerNew = (List<pse__Billing_Event__c>) Trigger.New;
        }
        //mount triggerOld
        if (Trigger.Old != null) {
            this.triggerOld = (List<pse__Billing_Event__c>) Trigger.Old;
        }
        
    }
 
    public override void afterInsert() {
        createPORequestForBilling(this.triggerNew);
    }
    public static void createPORequestForBilling(list<pse__Billing_Event__c> newList){
        list<pse__Billing_Event__c> selectedBillingEvent = new list<pse__Billing_Event__c> ();
        for(pse__Billing_Event__c be : newList){
            if(be.pse__Project__c != null){
                selectedBillingEvent.add(be);
            }  	
        }
        // create Po request for selected selectedBillingEvent
        if(!selectedBillingEvent.isEmpty()){
            list<Request__c> lstRequest = new list<Request__c>();
            // get request recordtype  
            Id Billing_CreateRecordtype = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('Milestone_Billing').getRecordTypeId();
            for(pse__Billing_Event__c be : selectedBillingEvent){
                Request__c request = new Request__c();
                request.RecordTypeID = Billing_CreateRecordtype;
                request.Project__c  = be.pse__Project__c ;
                request.Billing_Event__c = be.ID;
                lstRequest.add(request);
            }
            // insert request
            TriggerHandler.bypass(RequestTriggerHandler.class.getName());
            Insert lstRequest;
            TriggerHandler.clearBypass(RequestTriggerHandler.class.getName());
        }
    }
}