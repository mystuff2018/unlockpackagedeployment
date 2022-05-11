trigger AccountingAcknowledgmentTrigger on Accounting_Acknowledge__c ( after insert, before insert ) {
    new AccountingAcknowledgmentHandler().run();
}