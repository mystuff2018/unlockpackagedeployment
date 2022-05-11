public class ResumeExperienceTriggerHandler {
public static void PreventDeletionOfLastResumeExperience(List<Experience__c> ExpList){
        For(Experience__c e: ExpList){
            if(e.Last_Resume_Experience__c == true){
                e.addError('You cannot have an empty mandatory section for a resume profile which Status is Review or Available for Use (except Resume Certifications and Resume Professional Affiliation)');
            }
        }
    }
}