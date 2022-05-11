global with sharing class WorkOrderManualCreationBatch implements Database.Batchable<SObject>, Database.Stateful {
    public Id projectId {get;set;}
    public pse__Proj__c project {get;set;}
    public Id userId {get;set;}
    public WorkType workType {get;set;}
    public Map<Id, Schema.Address> LocationIdToAddressMap {get;set;}
    public Boolean isWOCreated = false;
    
    public WorkOrderManualCreationBatch(Id pProjectId, Id pUserId)
    {
        this.projectId = pProjectId;
        System.debug('Project Id ' + this.projectId);
        this.userId = pUserId;
        getWorkTypeByName('FSE Task');
        this.project = getProject();
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext context)
    {
         System.debug('Inside Start Method' +projectId);
      
        return Database.getQueryLocator([SELECT Id, Default_Address__c, Project__c, Order__c 
                                         FROM Location
                                         WHERE Default_Address__c = True AND Project__c = :projectId]);
        
    }
  
    
    public void execute(Database.BatchableContext context, List<Schema.Location> scope)
    {
         
         System.debug('Inside Execute Method');
        getLocationAddress(scope);
        System.debug('Scope #####c ' +scope);
        Map<Id,Schema.Location> LocationMap = new Map<Id,Schema.Location>(scope);
        System.debug('@@  Location Map :::: ' +LocationMap);
        List<WorkOrder> selectWorkOders = [SELECT Id, Subject, RecordTypeId, LocationId FROM WorkOrder WHERE Project__c = :this.projectId AND LocationId IN :LocationMap.keySet()];
        System.debug('@@29 :::: ' +selectWorkOders);
        Map<String, workOrder> locationAndWorkOrderMap = new Map<String, workOrder>();
        if(!selectWorkOders.isEmpty()){
        for(workOrder workOrderTemp : selectWorkOders){
            String key = workOrderTemp.LocationId + ';' + workOrderTemp.Subject;
            System.debug('@@33 ##### ' +key);
            if(!locationAndWorkOrderMap.containsKey(key)){
                locationAndWorkOrderMap.put(key, workOrderTemp);
                  System.debug('@@35 ##### ' +locationAndWorkOrderMap);
            }
        }
        }
        
        List<WO_SKU_Effort_Map__c> WOEntries = getWOEntriesBySkuNumber(getSKUNumbersFromProject(projectId));
         System.debug('@@41 ##### ' +WOEntries);

        Map<Id, pse__Project_Task__c> tasks = new Map<Id, pse__Project_Task__c>([SELECT Id, Name, (SELECT Id FROM pse__Immediate_Sub_Tasks__r) FROM pse__Project_Task__c WHERE pse__Project__c = :this.projectId]);
        Map<String, Id> taskNameToTaskId = getTaskMap(tasks);
        System.debug('@@45 ##### ' +taskNameToTaskId);
        
        List<WorkOrder> listWorkOrders = new List<WorkOrder>();
        for(WO_SKU_Effort_Map__c woSku :WOEntries)
        {
            listWorkOrders.add(WorkOrderUtils.buildOnDemandWO(woSku, project, workType, taskNameToTaskId, tasks));
        }

        
        List<WorkOrder> workOdersToBeCreated = new List<WorkOrder>();
        for(Schema.Location location : scope) {
            for(Workorder workOrder : listWorkOrders){
                String key = location.Id + ';' + workOrder.Subject;
                if(!locationAndWorkOrderMap.containsKey(key)){
                    WorkOrder workOrderTemp = workOrder.clone();
                    workOrderTemp.LocationId = location.Id;

                    if(this.locationIdToAddressMap.containsKey(Location.Id)) {
                        Schema.Address address = this.locationIdToAddressMap.get(Location.Id); 
                         System.debug('@@64 ##### ' +address);
                        workOrderTemp.City = address.City;
                        workOrderTemp.Country = address.Country;
                        workOrderTemp.PostalCode = address.PostalCode;
                        workOrderTemp.State = address.State;
                        workOrderTemp.Street = address.Street;
                    }
                    workOdersToBeCreated.add(workOrderTemp);
                    locationAndWorkOrderMap.put(key, workOrderTemp);
                }  
            }
        }
        //TriggerHandler.bypass('preventWOCreationOnTaskWithChildren');
        if(!workOdersToBeCreated.isEmpty()){
            isWOCreated = true;
            System.debug('@@91 :::: ' +isWOCreated);
          Database.Insert(workOdersToBeCreated, false);
        }
         System.debug('@@77 ##### ' +workOdersToBeCreated);
        
        if(project.Order_Products__r != null && project.Order_Products__r.size() > 0)
        {
            List<Work_Order_Relationship__c> relationships = new List<Work_Order_Relationship__c>();
            for(WorkOrder wo :workOdersToBeCreated)
            {
                System.debug('@@98 ##### ' +workOdersToBeCreated);
                System.debug('@@99 ##### ' +wo.id);
                if(wo.Id != null)
                {
                    for(OrderItem oi :project.Order_Products__r)
                    {
                        System.debug('@@103 ##### ' +project.Order_Products__r); 
                        System.debug('@@105 ##### ' +oi.id);
                        Work_Order_Relationship__c woRelat = new Work_Order_Relationship__c();
                        woRelat.Work_Order__c = wo.Id;
                        woRelat.Order_Product__c = oi.Id;
                        woRelat.Order__c = oi.OrderId;
                        System.debug('@@93 ##### ' +woRelat);
                        relationships.add(woRelat);
                    }
                }
            }
            if(relationships != null && relationships.size() > 0)
            	Database.Insert(relationships, false);
              System.debug('@@99 ##### ' +relationships);
        }
        
        Set<Id> workOrderIds = new Set<Id>();
        for (WorkOrder workOrder : workOdersToBeCreated) {
            workOrderIds.add(workOrder.Id);
        }

      /*  FFWorkOrderCalculateDPSType calculator = new FFWorkOrderCalculateDPSType(workOrderIds);
        calculator.CSGcalculateDPSTypeCallType();*/
    }

    public Map<String, Id> getTaskMap(Map<Id, pse__Project_Task__c> tasks)
    {
        Map<String, Id> taskNameToTaskId = new Map<String, Id>();

        for(pse__Project_Task__c task :tasks.values())
        {
            taskNameToTaskId.put(task.Name, task.Id);
        }
        return taskNameToTaskId;
    }
    
/*   public void getLocationAddress(List<Project_Location__c> scope)
    {
        this.projectLocationIdToAddressMap = new Map<Id, Schema.Address>();
        
        Map<Id, Id> locationtoProjectLocatioIds = new Map<Id, Id>();
        for(Project_Location__c pl :scope){
            if(pl.Location__c != null)
            	locationtoProjectLocatioIds.put(pl.Location__c, pl.Id);
        }
        
        if(locationtoProjectLocatioIds.size() > 0)
        {
            List<Schema.Address> addresses = ProjectHandlerData.getAddressesByLocations(locationtoProjectLocatioIds.keySet());
            for(Schema.Address a :addresses)
            {
                this.projectLocationIdToAddressMap.put(locationtoProjectLocatioIds.get(a.ParentId), a);
            }
        }
    } */

    public void getLocationAddress(List<Schema.Location> scope)
    {
        System.debug('Inside GetLocationAddress Method');
        this.locationIdToAddressMap = new Map<Id, Schema.Address>();
        System.debug('140 #### ' +this.locationIdToAddressMap);

        Set<Id> locationIds = new Set<Id>();
        
       // Map<Id, Id> locationtoProjectLocatioIds = new Map<Id, Id>();
        for(Schema.Location l :scope){
             System.debug('155 #### ' +l.id);
            	locationIds.add(l.Id);
        }
        
        if(locationIds.size() > 0)
        {
            List<Schema.Address> addresses = ProjectHandlerData.getAddressesByLocations(locationIds);
            System.debug('@@158 ##### ' +addresses);
            for(Schema.Address a :addresses)
            {
                this.locationIdToAddressMap.put(a.ParentId, a);
            }
        }
    }
    
    public List<WO_SKU_Effort_Map__c> getWOEntriesBySkuNumber(Set<String> skuNumbers)
    {
        Set<Id> skuEffortMapIds = new Set<Id>();
        List<AggregateResult> skuEffortMaps = [SELECT SKU_to_Effort_Mapping__c FROM SKU_Number__c WHERE SKU_Number__c IN :skuNumbers GROUP BY SKU_to_Effort_Mapping__c];
        System.debug('@@170 ##### ' +skuEffortMaps);
        for(AggregateResult ar :skuEffortMaps)
        {
            skuEffortMapIds.add((Id)ar.get('SKU_to_Effort_Mapping__c'));
        }
        
       
        List<AggregateResult> WOSkuEntriesAR = [SELECT MAX(Id) maxId
                                                FROM WO_SKU_Effort_Map__c 
                                                WHERE SKU_Effort_Mapping_Entry__r.SKU_Effort_Map__c IN :skuEffortMapIds AND On_Demand_WO_Creation__c = true
                                                GROUP BY Calculation_Type__c, Delivery_Method__c, Description__c, 
                                                Phase__c, SKU_Effort_Mapping_Entry__c, 
                                                WO_Record_Type__c, Auto_Dispatch__c, DPS_Type__c, Resource_Type__c, 
                                                Schedule_Type__c, Template__c, SR_Subtype__c, SR_Type__c, WO_Type__c, Event_Type__c, CallType__c, 
                                                On_Demand_WO_Creation__c];
        System.debug('@@ 185 ##### ' +WOSkuEntriesAR);
        Set<Id> WOSkuEMIds = new Set<Id>();
        for(AggregateResult ar :WOSkuEntriesAR)
        {
            WOSkuEMIds.add((Id)ar.get('maxId'));
        }
        
        List<WO_SKU_Effort_Map__c> WOSkuEntries = [SELECT Id, Calculation_Type__c, Delivery_Method__c, Description__c, Duration__c, 
                                                   High_Threshold_Duration__c, Low_Threshold_Duration__c, Phase__c, SKU_Effort_Mapping_Entry__c, 
                                                   Threshold_Value__c, WO_Record_Type__c, Auto_Dispatch__c, DPS_Type__c, DPS_Type__r.Name, Resource_Type__c, 
                                                   Schedule_Type__c, Template__c, SR_Subtype__c, SR_Type__c, WO_Type__c, Event_Type__c, CallType__c, 
                                                   On_Demand_WO_Creation__c, Phase__r.Name
                                                   FROM WO_SKU_Effort_Map__c
                                                   WHERE Id IN :WOSkuEMIds];
        System.debug('@@ 199 ##### ' +WOSkuEntries);
        return WOSkuEntries;
    }
    
    public Set<String> getSKUNumbersFromProject(Id projectId)
    {
         System.debug('@@  Inside SKU Numbers Method ');
        Set<String> skuNumbers = new Set<String>();
        List<AggregateResult> orderItems = [SELECT SKU_Number__c FROM OrderItem WHERE Project__c = :projectId GROUP BY SKU_Number__c];
        System.debug('@@ 207 ##### ' +orderItems);
        for(AggregateResult ar :orderItems)
        {
            skuNumbers.add((String)ar.get('SKU_Number__c'));
        }
        return skuNumbers;
    }
    
    private void getWorkTypeByName(String workTypeName){
        System.debug('@@ 229 Inside Work Type Method   ##### ');
        List<WorkType> woTypeList = [SELECT Id FROM WorkType WHERE Name =: workTypeName];
        System.debug('@@ 217 ##### ' +woTypeList);
        if(!woTypeList.isEmpty()) {
            this.workType = woTypeList[0];
        }
    }
    
    private pse__Proj__c getProject()
    {
        List<pse__Proj__c> projects = [SELECT Id, pse__Account__c, (SELECT Id, OrderId FROM Order_Products__r) FROM pse__Proj__c WHERE Id = :this.projectId];
         System.debug('@@ 226 ##### ' +projects);
        if(projects != null && projects.size() > 0)
        	return projects[0];
        return null;
    }
    
    public void finish(Database.BatchableContext context){
        if(isWOCreated == True){
        System.debug('@@259 :::: ' +isWOCreated);
        FFNotificationHelper.buildFFNotification('Work Order On Demand Creation','The Work Orders were created on the project ', projectId, new Set<String>{userId});
    }
    }
}