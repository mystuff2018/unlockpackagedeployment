public class ResumeSkillTriggerHandler {
public static void PreventDeletionOfLastResumeSkill(List<Skill__c> SklList){
        For(Skill__c s: SklList){
            if(s.Last_Resume_Skill__c == true){
                s.addError('You cannot have an empty mandatory section for a resume profile which Status is Review or Available for Use (except Resume Certifications and Resume Professional Affiliation)');
            }
        }
    }
}