@IsTest
public class FFProcessExecutionControlTest {
	@isTest
    static void shouldSendOrderToReprocessingSuccess(){
        List<Order> orders = new List<Order>();
         pse__Proj__c project = OPRTestFactory.createSimpleProject();
		orders.add(OPRTestFactory.createSimpleOrder());
        orders.add(OPRTestFactory.createSimpleOrderToProject(project.id));      
        
        Set<Id> orderIds = (new Map<Id,SObject>(orders)).keySet();
        
        FFProcessExecutionControl executionControl = new FFProcessExecutionControl(orderIds);
        
        for(Order o : orders){
            executionControl.setProcessLog(string.valueOf(o.Id), string.valueOf(o), 'shouldSendOrderToReprocessingSuccess: Creating Orders');
        }
        executionControl.insertControls();
        
        List<Database.UpsertResult> saveResults = Database.upsert(orders, false);
               
        Test.startTest();
        	executionControl.verifyDmlAndSendToReprocessing(null, saveResults, orders, Schema.Order.Id);
        Test.stopTest();

        List<FFProcessControl__c> controlList = [
            SELECT Id, OrderId__c, DataPayload__c, ProcessPhase__c, ExceptionLog__c
            FROM FFProcessControl__c
            WHERE OrderId__c IN :orderIds
        ];
        
        System.assert(controlList != null);
    }
    
    @isTest
    static void shouldSendOrderToReprocessingFailure(){
        FFProcessControlSettings__c executionSettings = new FFProcessControlSettings__c();
        executionSettings.NumberOfRetries__c = 3;
        insert executionSettings;
        
        List<Order> orders = new List<Order>();
		orders.add(OPRTestFactory.createSimpleOrder());
        orders.add(OPRTestFactory.createSimpleOrder());    
        
        Set<Id> orderIds = (new Map<Id,SObject>(orders)).keySet();
        
        FFProcessExecutionControl executionControl = new FFProcessExecutionControl(orderIds);
        
        List<Order_Processing__c> ordersToProcess = new List<Order_Processing__c>();
        for(Order o : orders){
            executionControl.setProcessLog(string.valueOf(o.Id), string.valueOf(o), 'shouldSendOrderToReprocessingFailure: Creating Orders');           
            //Creating the Order Processing object with Retry Count bigger than 3 so we can test the ProcessStatus = failure
            ordersToProcess.add(new Order_Processing__c(
                    OrderId__c = Id.valueOf(o.Id),
                    ProcessStatus__c = 'Pending',
                    RetryCount__c =  4
            ));
        }
        insert ordersToProcess;
        //Updating Order Account to null so we can force an error on the update
        orders[0].AccountId = null;
        executionControl.insertControls();
        
        List<Database.SaveResult> saveResults = Database.update(orders, false);
               
        Test.startTest();
        	executionControl.verifyDmlAndSendToReprocessing(saveResults, null, orders, Schema.Order.Id);
        Test.stopTest();

        List<Order_Processing__c> orderProcessingList = [
            SELECT Id, ProcessStatus__c, OrderId__c, RetryCount__c
            FROM Order_Processing__c
            WHERE ProcessStatus__c = 'Failure'
        ];
        
        System.assert(orderProcessingList.size() == 1);
    }
}