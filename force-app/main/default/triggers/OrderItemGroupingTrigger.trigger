trigger OrderItemGroupingTrigger on Order_Item_Grouping__e (after insert) {
  system.debug('OrderItemGroupingTrigger');
    new OrderItemGroupingTriggerHandler().run();
}