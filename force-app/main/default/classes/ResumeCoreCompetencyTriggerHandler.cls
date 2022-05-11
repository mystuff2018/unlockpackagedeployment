public class ResumeCoreCompetencyTriggerHandler {
    public static void PreventDeletionOfLastResumeCoreCompetency(List<Core_Competency__c> CoreList){
        For(Core_Competency__c c: CoreList){
            if(c.Last_Core_Competency__c == true){
                c.addError('You cannot have an empty mandatory section for a resume profile which Status is Review or Available for Use (except Resume Certifications and Resume Professional Affiliation)');
            }
        }
    }
}