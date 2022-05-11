/**************
 * @ Class Name        : OrderTriggerHandler
 * @ Description       : 
 * @ Modification Log  : Version 1.0 - [Deloitte - Abhishek Kawle] : Modified code as per Multi-Tower Hierarchy Feature #6476862
*********/
public class OrderTriggerHandler extends TriggerHandler {
    
     private Map<String,Custom_Order_Status_to_Order_Status_Map__mdt> statusMap = new Map<String, Custom_Order_Status_to_Order_Status_Map__mdt>();
     private List<Custom_Order_Status_to_Order_Status_Map__mdt> statusMappings;
     private List<Order> newOrdersFF = new List<Order>();
     private List<Order> oldOrdersFF = new List<Order>();
     private final String INTEGRATION_PROFILE_NAME = 'Service Integration Profile';
    
     public OrderTriggerHandler() {
         setStatusMap();
         filterFinancialForceOrders();
     }

     //Set recordType 
     public static void setRecordType(Order order){
         //Default RecordType for Orders in DFN.
         if(order.BUID__c != '99901'){
            order.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
         }else{
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

         for(Order newOrder : (List<Order>)Trigger.new){
             setRecordType(newOrder);
             updateInstallAtStateCode(newOrder);
            // Bypass this step for FF Orders
             /*if(!newOrdersFF.contains(newOrder)) {
                 Profile userProfileName = [
                     SELECT Name
                     FROM Profile 
                     WHERE Id = :UserInfo.getProfileId()
                 ];

                // if(userProfileName.Name == INTEGRATION_PROFILE_NAME){
                    // newOrder.Status = 'BK'; 
                    // newOrder.AccountId = newOrder.Billing_Account__c ;
                // }
             } 
             else { */
                 Custom_Order_Status_to_Order_Status_Map__mdt orderStatus = statusMap.get(newOrder.Order_Status__c);
                 if(orderStatus != null && newOrder.Order_Status__c == orderStatus.Custom_Status__c){
                     newOrder.Order_Status__c = orderStatus.Order_Status__c;
                // } 
             } 
         }
     }
   
     public override void beforeUpdate(){
        // After removing Lightning Orders, just making sure list is not empty, so we have FF orders in the list object to call HandleStatusUpdate method
         if(!newOrdersFF.isEmpty()) {
             IdsOrderUpdateHandler.handleStatusUpdate(newOrdersFF, oldOrdersFF, statusMappings);
         }
     }

     public override void afterUpdate(){
        // after removing Lightning Orders, just making sure list is not empty, so we have FF orders in the list object to call HandleUpdate method
         if(!newOrdersFF.isEmpty()) {
             IdsOrderUpdateHandler.handleOrderUpdate(newOrdersFF, oldOrdersFF);
         }
     }
    
    //[Deloitte - Abhishek Kawle] : Added code to invoke Order Created event.
  /*  public override void afterInsert(){
        if(!newOrdersFF.isEmpty()) {
            List<Order_Created__e> eventList = new List<Order_Created__e>();
            
            for(Order eaOrder : newOrdersFF){
                Order_Created__e event = new Order_Created__e();
                event.Order_ID__c = eaOrder.Id;
                event.Is_Event_Reprocessing__c = true;
                eventList.add(event);
                
            }
          List<Database.SaveResult> eventPublishResults = Eventbus.publish(eventList);
        }
    } */

     private void setStatusMap(){

         if(statusMap.isEmpty()){
             statusMappings = [
                 SELECT Custom_Status__c, Order_Status__c, Status_Order__c 
                 FROM Custom_Order_Status_to_Order_Status_Map__mdt where Id!=Null 
             ]; //Added where and id Null check as a part of checkMarx
        
             for(Custom_Order_Status_to_Order_Status_Map__mdt mapping : statusMappings){
                 statusMap.put(mapping.Custom_Status__c, mapping);
             }
         }
     }

     private void filterFinancialForceOrders(){
        // /*  
        // Only add the FF orders to the newOrdersFF and oldOrdersFF lists
        // that will prevent Lightning orders from being processed inside 
        // "IdsOrderUpdateHandler.HandleUpdate" and IdsOrderUpdateHandler.HandleStatusUpdate methods
        // */
        
         if(Trigger.new != null) {
             for(Order newOrder : (List<Order>)Trigger.new) { 
                 if(newOrder.FF_Feed__c) {
                    
                     newOrdersFF.add(newOrder);

                     if(Trigger.oldMap != null){
                         Order oldOrder = (Order)Trigger.oldMap.get(newOrder.Id);
                         oldOrdersFF.add(oldOrder);
                     }
                 } 
             }
         }
     }
    
 }