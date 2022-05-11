public class OrderImporterController {
    
    public class ValidateResponse {
        
        public ValidateResponse() {
            ValidOrders = new List<String>();
            InvalidOrders = new List<String>();
            Errors = new List<String>();
        }
        
        @AuraEnabled
        public List<String> ValidOrders { get; set; }    
        
        @AuraEnabled
        public List<String> InvalidOrders { get; set; }
        
        @AuraEnabled
        public List<String> Errors { get; set; }
        
        @AuraEnabled
        public Boolean HasErrors { 
            get {
                return Errors.size() > 0;
            }  
        }
    }
   
    @AuraEnabled
    public static void importOrder(String[] orderNumbers, String buid, Id projectId) {
        List<Order_Import_Queue__c> ordersToQueue = new List<Order_Import_Queue__c>();
        
        //string requestBody = '{"ORDER_REQUEST": [';
        
        //List<string> orderRequest = new List<string>();
        
        List<Order_Import_Queue__c> queuedOrdersToDelete = [
            SELECT Order_Number__c, BUID__c 
            FROM Order_Import_Queue__c 
            WHERE Order_number__c IN :orderNumbers 
              AND BUID__C = :buid 
              AND ProcessedDate__c = null
        ];
        
        delete (queuedOrdersToDelete);
        
        for(string order : orderNumbers) {
            Order_Import_Queue__c queue = new Order_Import_Queue__c(
                BUID__c = buid,
                Project__c = projectId,
                Order_Number__c = order
            );
            
            ordersToQueue.add(queue);
            
            //orderRequest.add('{"ORDER_NUMBER": "'+order+'","ORDER_BUID": "'+buid+'"}');
        }
        
        //requestBody += string.join(orderRequest, ',');
        //requestBody += ']}';
        
        insert(ordersToQueue);
        
        //orderImportCallout(requestBody);
    }
    
   /* @future(callout=true)
    private static void orderImportCallout(string requestBody) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        
        request.setEndpoint('callout:Order_Import');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBody);
        
        response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> orderImportResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            
            List<Object> orderResponseList = (List<Object>) orderImportResponse.get('ORDER_RESPONSE');

            for (Object orderResponse : orderResponseList) {
                Map<String, Object> mappedOrderResponse = (Map<String, Object>) orderResponse;
                
                String orderNumber = (String) mappedOrderResponse.get('ORDER_NUMBER');
                system.debug('Order Number: ' + orderNumber);
                String orderBuid = (String) mappedOrderResponse.get('ORDER_BUID');
                system.debug('Order BUID: ' + orderBuid);
                String status = (String) mappedOrderResponse.get('STATUS');
                system.debug('Status: ' + status);
                
                updateOrderImportQueueStatus(orderNumber, orderBuid, status);
            }
        }
        else {
            System.debug(LoggingLevel.Error, '[ImportOrders] Request: ' + request);
            System.debug(LoggingLevel.Error, '[ImportOrders] Response: ' + response);
            System.debug(LoggingLevel.Error, '[ImportOrders] Response body: ' + response.getBody());
        }
    }
    
    private static void updateOrderImportQueueStatus(String orderNumber, String orderBuid, String status) {
        List<Order_Import_Queue__c> listOrderImportQueue = [SELECT Id, Order_Import_Response_Status__c FROM Order_Import_Queue__c WHERE Order_Number__c = :orderNumber AND BUID__c = :orderBuid];
        
        if (listOrderImportQueue.size() > 0) {
            listOrderImportQueue[0].Order_Import_Response_Status__c = status;
            
            update(listOrderImportQueue);
        }
    } */
    
    @AuraEnabled
    public static List<Order_Import_Queue__c> getImportQueue(Id projectId){
        List<Order_Import_Queue__c> orders = [
            SELECT Id, Order_Number__c, BUID__c, ProcessedDate__c, Order_Import_Response_Status__c, FBE_Siebel_Integration_Message__c, CreatedDate
            FROM Order_Import_Queue__c
            WHERE Project__c =: projectId
            ORDER BY CreatedDate Desc
        ];
        
        return orders;
    }
    
    @AuraEnabled
    public static ValidateResponse validateImportOrder(String orderNumber, String buid, Id projectId) {
        ValidateResponse response = new ValidateResponse();
            
        orderNumber = orderNumber.trim();
        
        List<String> validOrders = new List<String>();
        List<String> invalidNonNumericOrders = new List<String>();
        
        for (String order : orderNumber.split(',')) {
            order = order.trim();
            
            if (order.isNumeric()) {
                if (!validOrders.contains(order)) {
                    validOrders.add(order);
                }
            }
            else {
                invalidNonNumericOrders.add(order);
            }
        }
        
        List<Order> invalidAssociatedOrders = [SELECT OrderNumber__c, Project__c, Project__r.pse__Project_ID__c 
                                               FROM Order 
                                               WHERE OrderNumber__c IN :validOrders 
                                               AND BUID__C =: buid
                                               AND FF_Feed__c = true];
        
        List<Order_Import_Queue__c> alreadyImportedOrders = [
            SELECT Order_Number__c, Project__c, Project__r.pse__Project_ID__c 
            FROM Order_Import_Queue__c 
            WHERE Order_number__c IN :validOrders 
              AND BUID__C = :buid
              AND (Project__c != :projectId OR (Project__c = :projectId AND ProcessedDate__c != null))
        ];
        
        for (String order : validOrders) {
            Boolean foundAssociated = false, foundQueued = false;
            
            for (Order invalidAssociatedOrder : invalidAssociatedOrders) {
                if (order == invalidAssociatedOrder.OrderNumber__c) {
                    foundAssociated = true;
                    break;
                }
            }
            
            for (Order_Import_Queue__c orderImportQueue : alreadyImportedOrders) {
                if (order == orderImportQueue.Order_Number__c) {
                    foundQueued = true;
                    break;
                }
            }
            
            if (!foundAssociated && !foundQueued) {
                response.ValidOrders.add(order);    
            }
        }
        
        if (invalidNonNumericOrders.size() > 0) {
            response.Errors.add('Order number must be numeric: ' + String.join(invalidNonNumericOrders, ', '));
            response.InvalidOrders.addAll(invalidNonNumericOrders);
        }
        
        List<String> projectsInfo = new List<String>();
        
        if (invalidAssociatedOrders.size() > 0) {
            for (Order order : invalidAssociatedOrders) {
                projectsInfo.add(order.OrderNumber__c + ' - ' + order.Project__r.pse__Project_ID__c);
                response.InvalidOrders.add(order.OrderNumber__c);
            }
        }
        
        if (alreadyImportedOrders.size() > 0) {
            for (Order_Import_Queue__c order : alreadyImportedOrders) {
                projectsInfo.add(order.Order_Number__c + ' - ' + order.Project__r.pse__Project_ID__c);
                response.InvalidOrders.add(order.Order_Number__c);
            }
        }
        
        for (String projectInfo : projectsInfo) {
            response.Errors.add('Order number already requested for project: ' + projectInfo);
        }
        
        return response;
    }
}