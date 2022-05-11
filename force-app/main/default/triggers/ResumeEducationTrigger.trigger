trigger ResumeEducationTrigger on Education__c (before delete) {
ResumeEducationTriggerHandler.PreventDeletionOfLastResumeEducation(Trigger.old);
}