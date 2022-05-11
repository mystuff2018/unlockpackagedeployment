/**
 * Created by Bruno_Frosi on 2/20/2020.
 */

@IsTest
private class SaveResultExceptionLoggerTest {
     @IsTest
     static void testBehavior() {
         List<Account> listAcc = new List<Account>();
         listAcc.add(OPRTestFactory.newAccount('Account for testing', '111', '11', '12'));
         listAcc.add(OPRTestFactory.newAccount('Account for testing', '123'));
         listAcc.add(OPRTestFactory.newAccount('Account for testing', '234'));
         listAcc.add(OPRTestFactory.newAccount('Account for testing', '345'));
         listAcc.add(OPRTestFactory.newAccount('REALLY BIG STRING TO CAUSE ERROR;REALLY BIG STRING TO CAUSE ERROR;REALLY BIG STRING TO CAUSE ERROR;REALLY BIG STRING TO CAUSE ERROR;REALLY BIG STRING TO CAUSE ERROR;REALLY BIG STRING TO CAUSE ERROR;REALLY BIG STRING TO CAUSE ERROR;REALLY BIG STRING TO CAUSE ERROR;', '456'));
         List<Database.SaveResult> saveResults = Database.Insert(listAcc, false);

         Map<Id, Account> mapAccount = new Map<Id, Account>();
         mapAccount.putAll(listAcc);
         List<sObject> sobjectList = new List<sObject>();
         sobjectList.addAll(mapAccount.values());

         List<ExceptionLogger__c> listLogger = SaveResultExceptionLogger.saveResultsLog(mapAccount.keySet(), mapAccount.keySet(), saveResults, 'test');
         system.assert(listLogger.size() > 0);
         listLogger = SaveResultExceptionLogger.saveResultsLog(mapAccount.keySet(), saveResults, 'test');
         system.assert(listLogger.size() > 0);
         listLogger = SaveResultExceptionLogger.saveResultsLog(sobjectList, saveResults, 'test', 'test');
         system.assert(listLogger.size() > 0);
         listLogger = SaveResultExceptionLogger.saveResultsLog(saveResults, null, mapAccount.keySet(), 'test', 'test');
         system.assert(listLogger.size() > 0);
        
         List<Database.UpsertResult> upsertResults = Database.Upsert(listAcc, false);
         listLogger = SaveResultExceptionLogger.saveResultsLog(mapAccount.keySet(), upsertResults, 'test');
         system.assert(listLogger.size() > 0);

         listLogger = SaveResultExceptionLogger.saveResultsLog(null, upsertResults, mapAccount.keySet(), 'test', 'test');
         system.assert(listLogger.size() > 0);

        
         SaveResultExceptionLogger.systemDebugLog(mapAccount.keySet(),  upsertResults);

         SKU_Effort_Map__c skuEffortMap = new SKU_Effort_Map__c();
         skuEffortMap.Description__c = 'Test';
         skuEffortMap.Active__c = true;
         skuEffortMap.X30_Day_Support__c = false;
         INSERT skuEffortMap;

         SKU_Number__c skuNumber = new SKU_Number__c();
         skuNumber.Sku_Name__c = 'Test';
         skuNumber.SKU_Number__c = 'Test';
         skuNumber.SKU_to_Effort_Mapping__c = skuEffortMap.Id;
         INSERT skuNumber;

         List<SKU_Effort_Map__c> listskuEffortMap = new List<SKU_Effort_Map__c>();
         listskuEffortMap.add(skuEffortMap);

         List<Database.DeleteResult> deleteResults = Database.delete(listskuEffortMap, false);
         List<ExceptionLogger__c> listDelLogger = SaveResultExceptionLogger.saveResultsLog(mapAccount.keySet(), deleteResults, 'test');
         system.assert(listDelLogger.size() > 0);
     }

     @IsTest
     static void testBehavior2() {
         List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
         system.runAs(loginUser[0]){ 
         List<Account> listAcc = new List<Account>();
         listAcc.add(OPRTestFactory.newAccount('Account for testing', '111'));
         listAcc.add(OPRTestFactory.newAccount('Account for testing', '123'));
         listAcc.add(OPRTestFactory.newAccount('Account for testing', '234'));
         listAcc.add(OPRTestFactory.newAccount('Account for testing', '345'));
         listAcc.add(OPRTestFactory.newAccount('Account for testing', '456'));
         INSERT listAcc;
         
         Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','1234567890');
         INSERT contact;

         Order ordr = OPRTestFactory.newOrderWithItem('123123', listAcc[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                 listAcc[1].Id,
                 listAcc[2].Id,
                 listAcc[3].Id,
                 listAcc[4].Id);

         Set<Id> setIdOrders = new Set<Id>();
         setIdOrders.add(ordr.Id);

         List<Order> ordersToApprovalProcess = new List<Order>();
         ordersToApprovalProcess.add(ordr);

         Test.startTest();
         List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();
         for (Order o : ordersToApprovalProcess) {
             Approval.ProcessSubmitRequest orderApprovalProcess = new Approval.ProcessSubmitRequest();
             String comment = 'VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;VERY BIG STRING TO GET AN ERROR;';
             orderApprovalProcess.setComments(comment);
             orderApprovalProcess.setObjectId(o.Id);
             // Submit the record to specific process
             orderApprovalProcess.setProcessDefinitionNameOrId('Order_Association_Approval_Process');

            approvalRequests.add(orderApprovalProcess);
         }
         // Submit the approval request for the Order
         List<Approval.ProcessResult> result = Approval.process(approvalRequests, false);
         List<ExceptionLogger__c> listDelLogger = SaveResultExceptionLogger.saveResultsLog(setIdOrders, result, 'test');
         Test.stopTest();
         }
     }

     @isTest
     static void shouldReturnExceptionLogger(){

        Test.startTest();

         ExceptionLogger__c exceptionLogger;
         try {
            Account acc = new Account(Name = 'Test');
            update acc;
         }
         catch (Exception e) {
             exceptionLogger = SaveResultExceptionLogger.createExceptionLogger(e, 'SaveResultExceptionLoggerTest', 'Test');    
         }
         finally {
             Test.stopTest();
         }

         System.assert(exceptionLogger != null, 'An exception logger must be created in the catch statement'); 
     }
}