@isTest
global class siebelComSracreateMockImpl implements WebServiceMock {
   public Object request {get; private set;}
   public Boolean returnAnError = false; 
   public Boolean throwException = false; 

   public static final String srNumber = '2000001';
   public static final String errorCode = '(SBL-BPR-00162)--IDS_ERR_EAI_SA_INSERT_MATCH_FOUND';
   public static final String errorMessage = 'The value entered in field Account Id of buscomp FBE Service Request does not match any value in the bounded pick list PickList SR Account.';
   public static final String exceptionMessage = 'Time Out.';


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
            
            this.request = request;
       
            siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Output_element srResponse = 
               new siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Output_element();
            
               srResponse.SRNumber = srNumber;

            if(returnAnError){
               srResponse.Error_spcCode = errorCode;
               srResponse.Error_spcMessage = errorMessage;
            }

            if(throwException){
               CalloutException e = new CalloutException();
               e.setMessage(exceptionMessage);
               throw e;
            }
       
            response.put('response_x', srResponse); 
   }
}