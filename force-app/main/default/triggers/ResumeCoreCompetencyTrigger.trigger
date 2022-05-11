trigger ResumeCoreCompetencyTrigger on Core_Competency__c (before delete) {
ResumeCoreCompetencyTriggerHandler.PreventDeletionOfLastResumeCoreCompetency(Trigger.old);
}