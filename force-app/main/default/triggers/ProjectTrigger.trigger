trigger ProjectTrigger on pse__Proj__c (before update, after update, after insert, before insert) {
	new FFProjectTriggerHandler().run();
}