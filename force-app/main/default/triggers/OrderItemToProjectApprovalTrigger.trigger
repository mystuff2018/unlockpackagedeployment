trigger OrderItemToProjectApprovalTrigger on OrderItemToProjectApproval__c (after update) {
    system.debug('OrderItemToProjectApprovalTrigger');
    new OrderItemToProjectApprovalTriggerHandler().run();
}