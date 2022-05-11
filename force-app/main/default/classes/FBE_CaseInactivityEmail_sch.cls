public without sharing class FBE_CaseInactivityEmail_sch implements schedulable{
    public void execute(SchedulableContext ctx) {
        FBE_CaseInactivity_EmailBatch Esc = new FBE_CaseInactivity_EmailBatch();
        Database.executeBatch(Esc, 200);
    }
    
}