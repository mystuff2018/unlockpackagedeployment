public class TestingRejectStatus {
    @InvocableMethod
    public static void RejectEmail(List<Id> dealIds){
        FBE_FPRM_RejectionController.notifyEmail(dealIds);
    }

}