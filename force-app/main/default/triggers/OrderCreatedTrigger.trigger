trigger OrderCreatedTrigger on Order_Created__e (after insert) {
    system.debug('OrderCreatedTrigger');
    new OrderCreatedTriggerHandler().run();
}