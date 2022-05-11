trigger BillingEventTrigger on pse__Billing_Event__c (after insert) {
	new BillingEventTriggerHandler().run();
}