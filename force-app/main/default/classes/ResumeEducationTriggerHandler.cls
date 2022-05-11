public class ResumeEducationTriggerHandler {
public static void PreventDeletionOfLastResumeEducation(List<Education__c> EduList){
        For(Education__c e: EduList){
            if(e.Last_Resume_Education__c == true){
                e.addError('You cannot have an empty mandatory section for a resume profile which Status is Review or Available for Use (except Resume Certifications and Resume Professional Affiliation)');
            }
        }
    }
}