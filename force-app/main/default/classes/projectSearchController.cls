public class projectSearchController {
   
    /** 
    * @description wrapper class to return the search results to component
    **/
    @TestVisible
    private class SearchResult{

        public SearchResult(String Id, String projectId, String projectName, String accountName, String practiceName, String parentId){
            this.Id = Id;
            this.projectId = projectId;
            this.projectName = projectName;
            this.accountName = accountName;
            this.practiceName = practiceName;
            this.parentId = parentId;
            this.actionDisabled = parentId != null;
        }
        
        public String Id;
        public String projectId;
        public String projectName;
        public String accountName;
        public String practiceName;
        public String parentId;
        public Boolean actionDisabled;
        public List<SearchResult> childrenProjectList = new List<SearchResult>();      
    }

    /** 
    * @description wrapper class to return order information
    **/
    @TestVisible
    private class OrderInformation{

        public OrderInformation(String Id, String orderNumber, Boolean hasProject){
            this.Id = Id;
            this.orderNumber = orderNumber;
            this.hasProject = hasProject;
        }
        
        public String Id;
        public String orderNumber;
        public Boolean hasProject;
    }

    // Record type of engagement (parent project)
    private static Id RECORD_TYPE_ID = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
    private static Integer ACCOUNT_LIMIT = 50;
    private static Integer PROJECT_LIMIT = 20;

    /** 
    * @description return a list of engagements that matches the given conditions
    **/
    @AuraEnabled
    public static String searchEngagements(String projectInfo, String customerName, String startDate, 
    String endDate, Boolean includeCancelled, Boolean includeClosure){

        System.debug('@args: ' + projectInfo + ' | ' + customerName + ' | ' + startDate + ' | ' + endDate + ' | ' + includeCancelled + ' | ' + includeClosure);

        Date dateStart = Date.valueOf(startDate);
        Date dateEnd = Date.valueOf(endDate).addDays(1); // Add one more day to use 'less than' in query
        List<SearchResult> resultList;
        List<pse__Proj__c> projectList;

        System.debug('@dateStart: ' + dateStart);
        System.debug('@dateEnd: '+ dateEnd);
        
        // Create a list with stages to not query (closure and cancelled)
        Set<String> stageList = retrieveStageList(includeCancelled, includeClosure);

        System.debug('@stage: ' + stageList);

        // Fields to query return
        List<String> fieldsToReturn = new List<String>{'Id', 'Name', 'RecordTypeId', 'pse__Project_ID__c', 
            'pse__Account__r.Name', 'pse__Practice__r.Name', 'pse__Parent_Project__c', 'pse__Parent_Project__r.Name', 
            'pse__Parent_Project__r.pse__Project_ID__c', 'pse__Parent_Project__r.pse__Account__r.Name', 
            'pse__Parent_Project__r.pse__Practice__r.Name'
        };

        String fixedWhere = 'CreatedDate >= :dateStart AND CreatedDate < :dateEnd AND pse__Stage__c NOT IN :stageList AND pse__Project_ID__c != NULL';
        String variableWhere = '';
        
        // Customer name search
        if(customerName != null && String.isNotBlank(customerName)) {

            List<Account> accountList = retrieveAccountIds(customerName);
            variableWhere += ' AND pse__Account__c IN :accountList';
        }

        // Project info search
        if(projectInfo != null && String.isNotBlank(projectInfo)) {

            List<List<sObject>> soslResult = search.query(
                'FIND :projectInfo IN ALL FIELDS RETURNING pse__Proj__c(' + String.join(fieldsToReturn, ',') + 
                ' WHERE ' + fixedWhere + variableWhere + ') LIMIT :PROJECT_LIMIT'
            );
            projectList =  (List<pse__Proj__c>)soslResult[0];
        }
        else{

            String soqlQuery = 'SELECT ' + String.join(fieldsToReturn, ',') + ' FROM pse__Proj__c WHERE ' + fixedWhere + variableWhere + ' LIMIT :PROJECT_LIMIT';
            projectList = Database.query(soqlQuery);
        }

        if(projectList != null){
            resultList = processResults(projectList);
        }
        
        return JSON.serialize(resultList);
    }

    /** 
    * @description create the SearchResult records to return to component
    **/
    private static List<SearchResult> processResults(List<pse__Proj__c> projectList){

        Map<String, SearchResult> parentProjectMap = new Map<String, SearchResult>();

        for(pse__Proj__c proj: projectList){

            SearchResult sr;
            if(proj.RecordTypeId == RECORD_TYPE_ID){
                // When is the engagement
                sr = new SearchResult(
                    proj.Id, 
                    proj.pse__Project_ID__c,
                    proj.Name, 
                    proj.pse__Account__r.Name, 
                    proj.pse__Practice__r.Name, 
                    null
                );
            }
            else{

                sr = new SearchResult(
                    proj.pse__Parent_Project__c, 
                    proj.pse__Parent_Project__r.pse__Project_ID__c,
                    proj.pse__Parent_Project__r.Name, 
                    proj.pse__Parent_Project__r.pse__Account__r.Name, 
                    proj.pse__Parent_Project__r.pse__Practice__r.Name, 
                    null
                );
            }

            parentProjectMap.put(sr.Id, sr);
        }

        return parentProjectMap.values();
    }

    /** 
    * @description create a list of stage conditions to avoid in the query
    **/
    @TestVisible
    private static Set<String> retrieveStageList(Boolean includeCancelled, Boolean includeClosure){
        // Completed projects
        Map<String, String> stageMap = new Map<String, String>{
            'Cancelled' => 'Cancelled', 
            'Closure' => 'Closure'
        };

        if(includeCancelled){
            stageMap.remove('Cancelled');
        }
        
        if(includeClosure){
            stageMap.remove('Closure');
        }

        return stageMap.keySet();
    }

    /** 
    * @description retrieve all child projects that belongs to engagement 
    **/
    @AuraEnabled
    public static String retrieveChildProjects(String engagementId){

        List<SearchResult> returnList = new List<SearchResult>();
        
        List<pse__Proj__c> childProjectList = [
            SELECT Id, Name, pse__Project_ID__c, pse__Account__r.Name, pse__Practice__r.Name, pse__Parent_Project__c
            FROM pse__Proj__c
            WHERE pse__Parent_Project__c = :engagementId
            AND RecordTypeId != :RECORD_TYPE_ID
        ];

        for(pse__Proj__c proj: childProjectList){

            returnList.add(new SearchResult(
                proj.Id, 
                proj.pse__Project_ID__c,
                proj.Name, 
                proj.pse__Account__r.Name, 
                proj.pse__Practice__r.Name, 
                proj.pse__Parent_Project__c
            ));

        }

        return JSON.serialize(returnList);        
    }   
    
    /** 
    * @description retrieve a set of account Id based on Name of account
    **/
    private static List<Account> retrieveAccountIds(String customerName) {
        
        List<List<SObject>> soslResult = [
            FIND :customerName 
            IN NAME FIELDS 
            RETURNING Account(Id)
            LIMIT :ACCOUNT_LIMIT
        ];

        return (List<Account>)soslResult[0];
    }
    
    /** 
    * @description recover order info from selected orders ids
    **/
    @AuraEnabled
	public static String retrieveOrderNumbers(List<String> orderIds) {

        List<OrderInformation> orderInfoList = new List<OrderInformation>();

        List<Order> orders = [
            SELECT Id, OrderNumber, Project__c
            FROM Order 
            WHERE Id IN: orderIds
            ORDER BY OrderNumber ASC NULLS LAST
        ];

 		List<String> orderNumbers = new List<String>();
		for (Order order: orders) {
            
            orderInfoList.add(new OrderInformation(
                order.Id,
                order.OrderNumber,
                order.Project__c != null
            ));
        }
        
		return JSON.serialize(orderInfoList);
	}
    
    /** 
    * @description create the context to save association and dispatch next event
    **/
    @AuraEnabled
    public static Boolean associateOrdersToProject(String orderId, String projectId){

        // Set<Id> setOrderIds = new Set<Id>();
        // for(String orderId: orderIds){
        //     setOrderIds.add(Id.valueOf(orderId));
        // }
        
        OrderCreatedDataContext context = new OrderCreatedDataContext(new Set<Id>{Id.valueOf(orderId)});

        // for(Id orderId : setOrderIds){
        //     // Populate the map that's necessary to association
        //     context.orderToProjectAssociate.put(orderId, projectId);
        // }

        context.orderToProjectAssociate.put(orderId, projectId);

        if(!context.orderToProjectAssociate.isEmpty()){
            // Update order with project lookup and send to order item grouping
            context.saveOrderAssociation();
            context.sendToOrderItemGroupingEvent();
        }
        
        return true;
    }
}