public class FFOrderTriggerHandler extends TriggerHandler{

    private Map<String, Custom_Order_Status_to_Order_Status_Map__mdt> statusMap = new Map<String, Custom_Order_Status_to_Order_Status_Map__mdt>();
    private List<Custom_Order_Status_to_Order_Status_Map__mdt> statusMappings;
    public Map<Id, Order> TriggerNewMap {get;set;}
    public Map<Id, Order> TriggerOldMap {get;set;}
    public List<Order> TriggerNew {get;set;}
    public List<Order> TriggerOld {get;set;}   
    public static Boolean sendInactiveProjectNotification = false;
    public FFOrderTriggerHandler() {
		if(TriggerHandler.isBypassed(FFOrderTriggerHandler.class.getName())){
            //Prevent constructor execution when trigger is already bypassed
            return;
        }
		
        filterFinancialForceOrders();           
    }

    //Set recordType
    public static void setRecordType(Order order) {
        if (order.BUID__c != '99901') {
            order.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
        } else {
            order.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('SAP_Order').getRecordTypeId();
        }
    }
    	//[Deloitte - Abhishek Kawle] : Added code to set the correct State value in Install at State field based on the Statecode coming from Siebel.
    public static void updateInstallAtStateCode(Order order){
        if(order.FBE_Install_At_Country__c != null && order.FBE_Install_At_State__c != null){
            
            List<Country_State__mdt> countryStateMapping = [SELECT Id, DeveloperName, Country__c, State__c, StateCode__c 
                                                  FROM Country_State__mdt
                                                 WHERE Country__C =:order.FBE_Install_At_Country__c];
            
            string stateCode = order.FBE_Install_At_State__c;
            for(Country_State__mdt mapping : countryStateMapping){
                if(mapping.StateCode__c.equalsIgnoreCase(stateCode)){
                    System.debug('Value for Order Install At StateCode: '+ order.FBE_Install_At_State__c+ ' is: '+ mapping.State__c);
                    order.FBE_Install_At_State__c = mapping.State__c;
                    break;
                }
            }
        }
    }

    public override void beforeInsert() {
        for (Order newOrder : (List<Order>) Trigger.new) {
            setRecordType(newOrder);
            updateInstallAtStateCode(newOrder);
            Custom_Order_Status_to_Order_Status_Map__mdt orderStatus = statusMap.get(newOrder.Order_Status__c);
            if (orderStatus != null && newOrder.Order_Status__c == orderStatus.Custom_Status__c) {
                newOrder.Order_Status__c = orderStatus.Order_Status__c;
            }
        }
    }

    public override void beforeUpdate() {
        //After removing Lightning Orders, just making sure list is not empty, so we have FF orders in the list object to call HandleStatusUpdate method
        if (!this.TriggerNew.isEmpty()) {
            IdsOrderUpdateHandler.handleStatusUpdate(this.TriggerNew, this.TriggerOld, statusMappings);
        }
    }

    public override void afterUpdate() {
        //after removing Lightning Orders, just making sure list is not empty, so we have FF orders in the list object to call HandleUpdate method
        if (!this.TriggerNew.isEmpty()) {             
            IdsOrderUpdateHandler.handleOrderUpdate(this.TriggerNew, this.TriggerOld);        
        //ProjectBuidLocalChannelHandler.setBuidAndLocalChannelWhenUpdate(this.TriggerNew);
        }
    }

    private void setStatusMap() {
        if (statusMap.isEmpty()) {
            statusMappings = [
                    SELECT Custom_Status__c, Order_Status__c, Status_Order__c
                    FROM Custom_Order_Status_to_Order_Status_Map__mdt
            ];

            for (Custom_Order_Status_to_Order_Status_Map__mdt mapping : statusMappings) {
                statusMap.put(mapping.Custom_Status__c, mapping);
            }
        }
    }

    private void filterFinancialForceOrders() {
        Boolean hasFFFeed = false;

        this.TriggerNewMap = new Map<Id, Order>();
        this.TriggerOldMap = new Map<Id, Order>();
        this.TriggerNew = new List<Order>();
        this.TriggerOld = new List<Order>();
        
        //mount triggerNewMap
        if(Trigger.NewMap != null) {
            for (Id orderId : Trigger.NewMap.keySet()) {
                Order orderNew = (Order) Trigger.NewMap.get(orderId);
                if (orderNew.FF_Feed__c) {
                    hasFFFeed = true;
                    this.TriggerNewMap.put(orderId, orderNew);
                } 
            }
        }
        //mount triggerOldMap
        if(Trigger.OldMap != null) {
            for (Id orderId : Trigger.OldMap.keySet()) {
                Order orderOld = (Order) Trigger.OldMap.get(orderId);
                if (orderOld.FF_Feed__c) {
                    hasFFFeed = true;
                    this.TriggerOldMap.put(orderId, orderOld);
                } 
            }
        }
         //mount triggerNew
         if(Trigger.New != null) {
            for (Order orderNew : (List<Order>)Trigger.New) {
                if (orderNew.FF_Feed__c) {
                    hasFFFeed = true;
                    this.TriggerNew.add(orderNew);
                } 
            }
        }
        //mount triggerOld
        if(Trigger.Old != null) {
            for (Order orderOld : (List<Order>)Trigger.Old) {
                if (orderOld.FF_Feed__c) {
                    hasFFFeed = true;
                    this.TriggerOld.add(orderOld);
                } 
            }
        }

        if(hasFFFeed) {
            setStatusMap();
            system.debug('Continue with FFOrderTriggerHandler. Other handlers should be bypassed.');
        } else {
            TriggerHandler.bypass(FFOrderTriggerHandler.class.getName());
        }
    }
}