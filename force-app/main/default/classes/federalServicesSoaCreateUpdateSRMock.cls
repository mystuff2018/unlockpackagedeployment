global class federalServicesSoaCreateUpdateSRMock implements WebServiceMock{
    public Object request;
    public Boolean returnAnError = false;
    public Boolean throwException = false;
    
    public static final String orderId = 'undefined';
    public static final String srNumber = '2000001';
    public static final String errorCode = 'OSC Request Succesfully completed';
    public static final String errorMessage = 'Invalid Order Number Found.';
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
       
            federalServicesSoaCreateUpdateSR.SalesOrderSR_Output_element srResponse = 
               new federalServicesSoaCreateUpdateSR.SalesOrderSR_Output_element();
            
               srResponse.SRNumber = srNumber;

            if(returnAnError){
               srResponse.OrderId = orderId;
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