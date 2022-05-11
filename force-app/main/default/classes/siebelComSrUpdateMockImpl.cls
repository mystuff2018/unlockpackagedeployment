@isTest
global class siebelComSrUpdateMockImpl implements WebServiceMock {
    public Boolean returnAnError = false; 
    public Boolean throwException = false; 

    public static final String successMessage = 'Created OSC Activities Successfully';
    public static final String errorMessage = 'Error creating activities';


    global void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,       		
        String responseType) {
    
        siebelComSractivity.FBE_spcOSC_spcSR_spcActivity_spcWF_Output_element responseSrUpdate = 
            new siebelComSractivity.FBE_spcOSC_spcSR_spcActivity_spcWF_Output_element();
        
        responseSrUpdate.SiebelErrorMessage = successMessage;

        if(returnAnError){
            responseSrUpdate.SiebelErrorMessage = errorMessage;
        }

        if(throwException){
            CalloutException e = new CalloutException();
            e.setMessage(errorMessage);
            throw e;
        }
    
        response.put('response_x', responseSrUpdate); 
    }
}