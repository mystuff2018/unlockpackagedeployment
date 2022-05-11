public with sharing class SiebelUpdateSRController {

    @AuraEnabled
    public static ResponseData updateSR(Id caseId){

        try {
            siebelComSractivity.FBE_spcOSC_spcSR_spcActivity_spcWF_Output_element response = 
                new SiebelSRUpdate().updateSR(caseId);
            ResponseData responseData = new ResponseData(response);

            return responseData;

        } catch (Exception e) {
            ResponseData responseData = new ResponseData(e.getMessage(), false);
            return responseData;
        }
    }

    public class ResponseData {
        @AuraEnabled
        public String siebelMessage {get;set;}
        @AuraEnabled
        public Boolean isSuccess {get;set;}

        public ResponseData(String siebelMessage, Boolean isSuccess){
            this.siebelMessage = siebelMessage;
            this.isSuccess = isSuccess;
        }

        public ResponseData(siebelComSractivity.FBE_spcOSC_spcSR_spcActivity_spcWF_Output_element response){
            this.siebelMessage = response.SiebelErrorMessage;
            this.isSuccess = isSuccess(response);
        }

        private Boolean isSuccess(siebelComSractivity.FBE_spcOSC_spcSR_spcActivity_spcWF_Output_element response){
            if(response.SiebelErrorMessage == 'Created OSC Activities Successfully'){
                return true;
            }
    
            return false;
        }
    }
}