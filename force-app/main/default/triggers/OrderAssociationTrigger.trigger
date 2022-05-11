trigger OrderAssociationTrigger on Order_Association__e (after insert) { 
    
    System.debug('OrderAssociationTrigger');
    new OrderAssociationTriggerHandler().run();
    
}