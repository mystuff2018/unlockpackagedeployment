@isTest
public class FBE_FPRM_TermsAcceptanceController_Test {
	@isTest
    static void testOnAgree(){
        FBE_FPRM_TermsAcceptanceController controller = new FBE_FPRM_TermsAcceptanceController(); 
        controller.onAgree();
        controller.displayTermsPageAndConditions();
        controller.doLogout();
        
        System.assertNotEquals(String.valueOf(controller.displayTermsPageAndConditions()),'');
    }
}