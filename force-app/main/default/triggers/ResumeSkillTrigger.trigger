trigger ResumeSkillTrigger on Skill__c (before delete) {
ResumeSkillTriggerHandler.PreventDeletionOfLastResumeSkill(Trigger.old);
}