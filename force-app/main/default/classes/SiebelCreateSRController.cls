public with sharing class SiebelCreateSRController {
    @AuraEnabled
    public static ResponseData createSR(Id caseId){
        try {
            Id srId;
            siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Output_element response = 
                new SiebelSRCreate().srCreate(caseId);

            if(isSuccess(response)){
                srId = createSrRecord(caseId, response);

            } else {
                if(response.Error_spcMessage.contains('The value entered in field Account Id of buscomp FBE Service Request does not match any value in the bounded pick list PickList SR Account.')){
                    srId = createSrRecord(caseId, response);
                    return new ResponseData(null, null, 'Invalid Service Tag - SR Number: ' + response.SRNumber);
                }
    
                return new ResponseData(null, null, response.Error_spcCode + ' - ' + response.Error_spcMessage);
            }
                
            return new ResponseData(srId, response.SRNumber, null);
        } catch (Exception e) {
            logException(e,'SiebelCreateSRController','createSR');
            return new ResponseData(null, null, 'Error: ' + e.getMessage());
        }
    }

    private static Boolean isSuccess(siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Output_element response){
        if(String.isBlank(response.Error_spcCode) && String.isNotBlank(response.SRNumber)) {
            return true;
        }
        return false;
    }

    private static Id createSrRecord(Id caseId, siebelComSracreate.FBE_spcOSC_spcSR_spcAct_spcCreate_spcWF_Output_element response){
        
        update new Case(
            Id = caseId,
            SR_Number__c = response.SRNumber,
            Siebel_Pending_to_Sync__c = false
        );
        
        Service_Request__c sr =  new Service_Request__c(
            Case__c = caseId,
            Name = response.SRNumber,
            ST_Title__c = response.SRTitle
        );

        insert sr;
        return sr.Id;
    }

    private static void logException(Exception e, String apexClass, String methodName){
        String description = e.getMessage() + '\n' + e.getStackTraceString() + '\n' +
            e.getCause() + '\n' + e.getLineNumber();

        ExceptionLogger__c exceptionLogger = new ExceptionLogger__c(
            Apex_Class__c = apexClass,
            Method_Name__c = methodName,
            Description__c = description
        );

        insert exceptionLogger;
    }

    public class serviceException extends Exception {}

    public class ResponseData {
        @AuraEnabled
        public Id srId {get;set;}
        @AuraEnabled
        public String srNumber {get;set;}
        @AuraEnabled
        public String errorMessage {get;set;}

        public ResponseData(Id srId, String srNumber, String errorMessage){
            this.srId = srId;
            this.srNumber = srNumber;
            this.errorMessage = errorMessage;
        }
    }
}