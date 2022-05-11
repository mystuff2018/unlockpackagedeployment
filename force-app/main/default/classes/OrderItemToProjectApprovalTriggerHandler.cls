/**
 * Created by Romulo_Spier and Tiago_Ferreira on 5/22/2020.
 *
 * Trigger Handler for OrderItemToProjectApprovalTrigger
 */

  public class OrderItemToProjectApprovalTriggerHandler extends TriggerHandler
  {
    OrderItemToProjectApprovalDataContext context;
    
    public OrderItemToProjectApprovalTriggerHandler() {
        try {
            System.debug('OrderItemToProjectApprovalTriggerHandler');
            context = new OrderItemToProjectApprovalDataContext((Map<Id, OrderItemToProjectApproval__c>)Trigger.newMap);
        }
        catch(Exception e) {
            insert SaveResultExceptionLogger.createExceptionLogger(e, OrderItemToProjectApprovalTriggerHandler.Class.getName(), 'Order Item to Project Approval');
        }
    }
    
    public override void afterUpdate() {
        try {
            System.debug('afterUpdate');
            
            context.save();
        }
        catch(Exception e) {
            insert SaveResultExceptionLogger.createExceptionLogger(e, OrderItemToProjectApprovalTriggerHandler.Class.getName(), 'Order Item to Project Approval (After Update)');
        }
    }
  }