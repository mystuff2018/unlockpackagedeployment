public class OrderAssociationRetryEvent {

    public static List<Order_Association__e> validateCloneTaskJob(List<Order_Association__e> dataToAssociate){
        
        Map<Id, List<Order_Association__e>> eventByOrderId = new Map<Id, List<Order_Association__e>>();
        for(Order_Association__e event: dataToAssociate){
            if(!eventByOrderId.containsKey(event.Project_ID__c)){
                eventByOrderId.put(event.Project_ID__c, new List<Order_Association__e>());
            }   
            List<Order_Association__e> lstEvent = eventByOrderId.get(event.Project_ID__c);
            lstEvent.add(event);
            eventByOrderId.put(event.Project_ID__c, lstEvent);
        }

        Map<Id, Id> cloneMap = new Map<Id, Id>();
		if(eventByOrderId.size() > 0){												//if - checkmarks update
        for(Clone_Project_Info__c clone: [SELECT Id, Queued_Job_Id__c, Project__c FROM Clone_Project_Info__c WHERE Project__c in :eventByOrderId.keySet() ORDER BY CreatedDate DESC]){
            if(!cloneMap.containsKey(clone.Queued_Job_Id__c)){
                cloneMap.put(clone.Queued_Job_Id__c, clone.Project__c);
            }
        }
		}
        List<Order_Association__e> retryList = new List<Order_Association__e>();
        Set<Id> setProjectId = new Set<Id>();
        for(AsyncApexJob async: [SELECT Id FROM AsyncApexJob WHERE Id = :cloneMap.keySet() AND CompletedDate = NULL AND Status NOT IN ('Failed', 'Aborted', 'Completed')]){

            Id projectId = cloneMap.get(async.Id);
            setProjectId.add(projectId);
            for(Order_Association__e item : eventByOrderId.get(projectId)){
                Order_Association__e event = new Order_Association__e(
                    Order_ID__c = item.Order_ID__c,
                    Project_ID__c = item.Project_ID__c,
                    Order_Item_Id__c = item.Order_Item_Id__c
                );
                retryList.add(event);
            }
            eventByOrderId.remove(projectId);

        }
        
        if(!retryList.isEmpty()){
            EventBus.publish(retryList);
        }
        
        List<Order_Association__e> result = new List<Order_Association__e>();
        for(Id projectId : eventByOrderId.keySet()){
            result.addAll(eventByOrderId.get(projectId));
        }

        return result;
    }

    // Mock created to test coverage
    public class OrderAssociationRetryEventMock implements Queueable{
        public void execute(QueueableContext context) {
            
        }
    }
}