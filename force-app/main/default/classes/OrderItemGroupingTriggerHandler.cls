public class OrderItemGroupingTriggerHandler extends TriggerHandler{

    Map<Id, Id> orderToEngagement = new Map<Id, Id>();
    OrderItemGroupingDataContext context;

    public OrderItemGroupingTriggerHandler() {
        try{
            System.debug('OrderItemGroupingTriggerHandler');

            for(Order_Item_Grouping__e event :(List<Order_Item_Grouping__e>)Trigger.new) {
                orderToEngagement.put(Id.valueOf(event.Order_ID__c), Id.valueOf(event.Engagement_ID__c));
                System.debug('orderToEngagement'+orderToEngagement);
            }

            context = new OrderItemGroupingDataContext(orderToEngagement);
            System.debug('context ------'+context);
        }
        catch(System.DmlException dml) {
            insert SaveResultExceptionLogger.createExceptionLogger(dml, OrderItemGroupingTriggerHandler.Class.getName(), 'Order Item Grouping');
        }
        catch(Exception e) {
            insert SaveResultExceptionLogger.createExceptionLogger(e, OrderItemGroupingTriggerHandler.Class.getName(), 'Order Item Grouping');
        }
    }

    public override void afterInsert(){
        try{
            System.debug('afterInsert');
			SYstem.debug('context details'+context);
            OrderItemGroupingPracticeRules.groupingOrderItemByPractice(context);

            context.save();
        }
        catch(System.DmlException dml) {
            insert SaveResultExceptionLogger.createExceptionLogger(dml, OrderItemGroupingTriggerHandler.Class.getName(), 'Order Item Grouping (After Insert)');
        }
        catch(Exception e) {
            insert SaveResultExceptionLogger.createExceptionLogger(e, OrderItemGroupingTriggerHandler.Class.getName(), 'Order Item Grouping (After Insert)');
        }
    }
}