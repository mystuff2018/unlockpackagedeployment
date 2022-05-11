public class FBE_FPRM_AccountAffilationStatus_SCH implements schedulable{
    public void execute(SchedulableContext ctx) {
        FBE_FPRM_AccountAffilationStatusBatch Esc = new FBE_FPRM_AccountAffilationStatusBatch();
        Database.executeBatch(Esc, 200);
    }

}