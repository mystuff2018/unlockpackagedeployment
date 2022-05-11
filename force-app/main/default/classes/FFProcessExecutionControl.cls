public with sharing class FFProcessExecutionControl {
    public Map<Id, FFProcessControl__c> controlMap = new Map<Id, FFProcessControl__c>();
    public Set<Id> ordersFailed = new Set<Id>();
    public Set<Id> processingUpdated = new Set<Id>();
    public FFProcessControlSettings__c executionSettings;
    
    public FFProcessExecutionControl(Set<Id> ordersIds){
        executionSettings = FFProcessControlSettings__c.getOrgDefaults();

        if(ordersIds != null){
            getExistingControls(ordersIds);
        }
    }

    private Set<Id> retrieveSuccessIds(List<Database.SaveResult> saveResults, List<Database.UpsertResult> upsertResults){
        Set<Id> successIds = new Set<Id>();

        if(saveResults != null){
            for(Database.SaveResult result: saveResults){
                if(result.isSuccess()){
                    successIds.add(result.getId());
                }
            }
        }

        if(upsertResults != null){
            for(Database.UpsertResult result: upsertResults){
                if(result.isSuccess()){
                    successIds.add(result.getId());
                }
            }
        }

        return successIds;
    }

    public void verifyDmlAndSendToReprocessing(List<Database.SaveResult> saveResults, List<Database.UpsertResult> upsertResult, List<SObject> objectList, Schema.SObjectField orderField){
        verifyDmlSuccess(saveResults, upsertResult, objectList, orderField);

        sendOrderToReprocessing();
    }

    public Set<Id> verifyDmlSuccess(List<Database.SaveResult> saveResults, List<Database.UpsertResult> upsertResult, List<SObject> objectList, Schema.SObjectField orderField){
        Set<Id> successIds = retrieveSuccessIds(saveResults, upsertResult);

        List<SObject> failedSObjects = new List<SObject>();

        for(SObject obj: objectList){
            if(!successIds.contains(obj.Id)){
                failedSObjects.add(obj);
            }
        }

        for(SObject obj: failedSObjects){
            this.ordersFailed.add(Id.valueOf(String.valueOf(obj.get(orderField))));
        }

        return this.ordersFailed;
    }

    public void sendOrderToReprocessing(){
        List<Order_Processing__c> orderProcessingList = [
            SELECT Id, ProcessStatus__c, OrderId__c, RetryCount__c
            FROM Order_Processing__c
            WHERE OrderId__c = :this.ordersFailed
        ];

        for(Order_Processing__c processing: orderProcessingList){
            setProcessLog(String.valueOf(processing.OrderId__c), '--- RETRY ---', 'Retry Order');
            processing.RetryCount__c += 1;
            if(processing.RetryCount__c > Integer.valueOf(executionSettings.NumberOfRetries__c)){
            	processing.ProcessStatus__c = 'Failure';   
            }
            else {
                processing.ProcessStatus__c = 'Pending';   
            }

            processingUpdated.add(processing.Id);
        }

        update orderProcessingList;
    }

    private void getExistingControls(Set<Id> orderId){
        List<FFProcessControl__c> controlList = [
            SELECT Id, OrderId__c, DataPayload__c, ProcessPhase__c, ExceptionLog__c
            FROM FFProcessControl__c
            WHERE OrderId__c IN :orderId
        ];

        for(FFProcessControl__c ctrl: controlList){
            controlMap.put(ctrl.OrderId__c, ctrl);
        }
    }

    public void setProcessLog(String orderId, String payload, String processPhase){
        FFProcessControl__c control = controlMap.get(orderId);

        if(control != null){
            control.DataPayload__c += '\n\n' + payload;
            control.ProcessPhase__c += '\n\n' + processPhase;
        }
        else{
            control = new FFProcessControl__c();
            control.DataPayload__c = payload;
            control.ProcessPhase__c = processPhase;
            control.OrderId__c = orderId;
        }

        controlMap.put(orderId, control);
    }

    public void insertControls(){
        upsert controlMap.values() OrderId__c;
    }
}