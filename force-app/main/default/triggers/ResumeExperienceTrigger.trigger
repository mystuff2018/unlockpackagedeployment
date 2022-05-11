trigger ResumeExperienceTrigger on Experience__c (before delete) {
ResumeExperienceTriggerHandler.PreventDeletionOfLastResumeExperience(Trigger.old);
}