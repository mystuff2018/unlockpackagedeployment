public class WorkOrderUtils {
    
    public static WorkOrder buildWO(pse__proj__c project, pse__proj__c projComplementaryFields, Set<WO_SKU_Effort_Map__c> woSkuEffortMaps, Set<Project_Task_SKU_Effort_Mapping_Entry__c> projectTaskSkuEffortMappingEntries, List<Order_Item_Sku_Effort_Map__c> orderItemSkuEffortMaps, List<OrderItem> orderItems, Map<Id, Id> onSiteContactIdByProjectIdMap, List<Schema.Location> locations, WorkType workType, Map<Id, List<Schema.Address>> addressesByLocation) {
        
        WO_SKU_Effort_Map__c woSkuEffortMap = getFirstWOEffortMap(woSkuEffortMaps);
        Project_Task_SKU_Effort_Mapping_Entry__c projectTaskSkuEffortMap = getFirstProjectTaskSKUEffortMap(projectTaskSkuEffortMappingEntries);
        String woDescription = getWODescriptionMap(new List<WO_SKU_Effort_Map__c>(woSkuEffortMaps)); 
        Map<Id, OrderItem> orderItemMap = buildOrderItemMap(orderItems);
        String woProblemSummary = fillProblemSummaryFromWoSkuEfforMap(orderItemSkuEffortMaps, woSkuEffortMaps, orderItemMap);
        //String woProblemSummary = fillProblemSummaryFromWoSkuEfforMap(orderItemSkuEffortMaps, woSkuEffortMaps, orderItems);
        String woRecordTypeName = String.isBlank(woSkuEffortMap.WO_Record_Type__c) ? 'FF - Unknown' : woSkuEffortMap.WO_Record_Type__c;
        Id woRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get(woRecordTypeName).getRecordTypeId();
        
        WorkOrder workOrder = new WorkOrder();
        workOrder.WO_Type__c = 'Install';
        workOrder.Subject = woSkuEffortMap.Description__c;
        workOrder.Project_Task__c = projectTaskSkuEffortMap.Project_Task__c;
        workOrder.AccountId = project.pse__Account__c;
        workOrder.Delivery_Method__c = defineDeliveryMethod(woSkuEffortMaps);
        workOrder.Status = woRecordTypeName == 'FF - Unknown' ? 'New' : 'FF - New';
        workOrder.Resource_Type__c = woSkuEffortMap.Resource_Type__c;
        workOrder.Schedule_Type__c = woSkuEffortMap.Schedule_Type__c;
        workOrder.Auto_Dispatch__C = woSkuEffortMap.Auto_Dispatch__c;
        workOrder.DPSType__c = woSkuEffortMap.DPS_Type__r.Name;
        workOrder.SR_Type__c = woSkuEffortMap.SR_Type__c;
        workOrder.SR_Subtype__c = woSkuEffortMap.WO_Type__c;

        if(!locations.isEmpty() && locations != null) {
            workOrder.Order__c = locations[0].Order__c;
            workOrder.LocationId = locations[0].Id;
        }

        if (woRecordTypeName == 'Installation Field') {
            workOrder.ContactId = onSiteContactIdByProjectIdMap.get(project.Id) != null
                ? onSiteContactIdByProjectIdMap.get(project.Id) : projComplementaryFields.Primary_Contact__c;
            workOrder.Description = woDescription != null
                ? (woProblemSummary + woDescription) : '';
          
            Schema.Location plo = locations[0];
            set<String> setTz = new Set<String>();
            setTz.add(plo.TimeZone__c);
            map<String,String> mapTz = TimezoneHelper.getTimeZones(setTz);
            String sitTzo = mapTz.get(plo.TimeZone__c);

            integer offsetMinsStartDate = 0;
            integer offsetMinsEndDate = 0;
            Datetime startDate = TimezoneHelper.conversionDateToDateTime(project.pse__Start_Date__c, 8);
            Datetime endDate = TimezoneHelper.conversionDateToDateTime(project.pse__End_Date__c, 17);
            
            if (sitTzo != null) {
                Timezone tz = TimezoneHelper.getTimeZone(sitTzo);

                offsetMinsStartDate = (tz.getOffset(startDate)) / (1000 * 60);
                offsetMinsEndDate = (tz.getOffset(endDate)) / (1000 * 60);
            }

            workOrder.StartDate = startDate.addMinutes( -offsetMinsStartDate );
            workOrder.EndDate = endDate.addMinutes( -offsetMinsEndDate );

        } else {
            workOrder.StartDate = null;
            workOrder.EndDate = null;
        }


        workOrder.RecordTypeId = woRecordTypeId;
        calculateWODuration(workOrder, woSkuEffortMaps, projectTaskSkuEffortMappingEntries);
        populateLocationInformation(workOrder, locations, addressesByLocation);

        if (woRecordTypeName == 'Installation Badge' && workType != null)
        {
            workOrder.WorkTypeId = workType.Id;
        }

        if (woRecordTypeName == 'Installation field')
        {
           workOrder.Site_Id__c = projComplementaryFields.Site_Id__c;
        }
        
        return workOrder;
    }

       
    public static WorkOrder buildOnDemandWO(WO_SKU_Effort_Map__c woSkuEM, pse__Proj__c project, WorkType workType, Map<String, Id> taskNameToTaskId, Map<Id, pse__Project_Task__c> tasks){
        Id woRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get(woSkuEM.WO_Record_Type__c).getRecordTypeId();
        WorkOrder workOrder = new WorkOrder();
        workOrder.Project__c = project.Id;
        workOrder.WO_Type__c = 'Install';
        workOrder.Subject = woSkuEM.Description__c;
        workOrder.AccountId = project.pse__Account__c;
        workOrder.Delivery_Method__c = woSkuEM.Delivery_Method__c;
        workOrder.Status = ((woSkuEM.WO_Record_Type__c) == 'FF - Unknown') ? 'New' : 'FF - New';
        workOrder.Resource_Type__c = woSkuEM.Resource_Type__c;
        workOrder.Schedule_Type__c = woSkuEM.Schedule_Type__c;
        workOrder.Auto_Dispatch__C = woSkuEM.Auto_Dispatch__c;
        workOrder.DPSType__c = woSkuEM.DPS_Type__r?.Name;
        workOrder.SR_Type__c = woSkuEM.SR_Type__c;
        workOrder.SR_Subtype__c = woSkuEM.WO_Type__c;
        workOrder.RecordTypeId = woRecordTypeId;
        workOrder.Project_Task__c = getTaskWithoutChild(taskNameToTaskId?.get(woSkuEM?.Phase__r?.Name), tasks);
        if ((String)woSkuEM.get('WO_Record_Type__c') == 'Installation Badge' && workType != null){
            workOrder.WorkTypeId = workType.Id;
        }

        return workOrder;
    }

    public static Id getTaskWithoutChild(Id taskId, Map<Id, pse__Project_Task__c> tasks)
    {
        if(taskId == null)
            return null;

        if(!tasks.containsKey(taskId))
            return null;

        pse__Project_Task__c task = tasks.get(taskId);
        if(task.pse__Immediate_Sub_Tasks__r.size() == 0)
        {
            return task.Id;
        }
        else
        {
            return getTaskWithoutChild(task.pse__Immediate_Sub_Tasks__r[0]?.Id, tasks);
        }
    }
    
    public static string defineDeliveryMethod(Set<WO_SKU_Effort_Map__c> woSkuEffortMaps) {
        
        string deliveryMethod = '';
        
        for(WO_SKU_Effort_Map__c woSkuEffortMap : woSkuEffortMaps) {
            
            if(String.isBlank(deliveryMethod)) {
                deliveryMethod = woSkuEffortMap.Delivery_Method__c;
            } else if(deliveryMethod == 'Remote' && woSkuEffortMap.Delivery_Method__c == 'OnSite') {
                deliveryMethod = woSkuEffortMap.Delivery_Method__c;
            }
        }        
        return deliveryMethod;
    }
    
    public static String getWODescriptionMap(List<WO_SKU_Effort_Map__c> woSkuEffortMaps)
    {
        String mapString = '';
        Set<Id> skuToEffortMappingEntryIds = new Set<Id>();
        
        for (WO_SKU_Effort_Map__c woSkuEffortMap : woSkuEffortMaps) {
            skuToEffortMappingEntryIds.add(woSkuEffortMap.SKU_Effort_Mapping_Entry__c);
        }
        
        List<SKU_Effort_Map_Entry__c> skuEffortMapWithChildrenSkills = ProjectHandlerData.getskuEffortMapWithChildrenSkills(skuToEffortMappingEntryIds);
        
        for (WO_SKU_Effort_Map__c woSkuEffortMap : woSkuEffortMaps)
        {
            for (SKU_Effort_Map_Entry__c mapEntry : skuEffortMapWithChildrenSkills) {
                for (Skill_SKU_Effort_Map_Entry__c skillEntry : mapEntry.Skill_SKU_Effort_Map_Entries__r) {
                    if (skillEntry.SKU_Effort_Map_Entry__r.SKU_Effort_Map__c == woSkuEffortMap.SKU_Effort_Mapping_Entry__r.SKU_Effort_Map__c) {
                        if(!mapString.contains(skillEntry.Skill_Certification__r.Name)) {
                            mapString += skillEntry.Skill_Certification__r.Name + ': ' + skillEntry.Minimum_Rate__c + '\n';
                        }
                        
                    }
                }
            }
        }
        return mapString;
    }
    
    @testVisible()
    private static String fillProblemSummaryFromWoSkuEfforMap(List<Order_Item_Sku_Effort_Map__c> orderItemSkuEffortMaps, Set<WO_SKU_Effort_Map__c> woSkuEffortMaps, List<OrderItem> listOrderItem)
    {
        String problemSummary = '';
        
        for (Order_Item_Sku_Effort_Map__c orderItemSkuEfforMap: orderItemSkuEffortMaps) {
            for (WO_SKU_Effort_Map__c woSkuEffortMap: woSkuEffortMaps) { 
                
                if(woSkuEffortMap.SKU_Effort_Mapping_Entry__r.SKU_Effort_Map__c == orderItemSkuEfforMap.SKU_to_Effort_Mapping__c) {
                    for(OrderItem orderItem: listOrderItem) {
                        if(orderItem.Id == orderItemSkuEfforMap.Order_Product__c) {
                            if(problemSummary == null) {
                                problemSummary = orderItem.SKU_Number__c + ' - ' + orderItem.SKU_Description__c  + '\n';
                            } 
                            else if(!problemSummary.contains(orderItem.SKU_Number__c)) {
                                problemSummary += orderItem.SKU_Number__c + ' - ' + orderItem.SKU_Description__c  + '\n';
                            }
                        }
                    }
                }
            }
        }
        return problemSummary;
    }

    @testVisible()
    //refactored version
    private static String fillProblemSummaryFromWoSkuEfforMap(List<Order_Item_Sku_Effort_Map__c> orderItemSkuEffortMaps, Set<WO_SKU_Effort_Map__c> woSkuEffortMaps, Map<Id, OrderItem> orderItemMap)
    {
        String problemSummary = '';
        for (Order_Item_Sku_Effort_Map__c orderItemSkuEfforMap: orderItemSkuEffortMaps) {
            for (WO_SKU_Effort_Map__c woSkuEffortMap: woSkuEffortMaps) { 
                
                if(woSkuEffortMap.SKU_Effort_Mapping_Entry__r.SKU_Effort_Map__c == orderItemSkuEfforMap.SKU_to_Effort_Mapping__c) {

                    OrderItem orderItem = orderItemMap.get(orderItemSkuEfforMap.Order_Product__c);
                    if(problemSummary == null) {
                        problemSummary = orderItem.SKU_Number__c + ' - ' + orderItem.SKU_Description__c  + '\n';
                    } 
                    else if(!problemSummary.contains(orderItem.SKU_Number__c)) {
                        problemSummary += orderItem.SKU_Number__c + ' - ' + orderItem.SKU_Description__c  + '\n';
                    }

                }
            }
        }
        return problemSummary;
    }

    @testVisible()
    private static Map<Id, OrderItem> buildOrderItemMap(List<OrderItem> orderItemList){
        Map<Id, OrderItem> mapOrderItem = new Map<Id, OrderItem>();
        if(!orderItemList.isEmpty()){
            for(OrderItem orderItem : orderItemList){
                mapOrderItem.put(orderItem.Id, orderItem);
            }
        }
        return mapOrderItem;
    }
    
     @testVisible()
    private static WO_SKU_Effort_Map__c getFirstWOEffortMap(Set<WO_SKU_Effort_Map__c> woSkuEfforMaps) {
        WO_SKU_Effort_Map__c firstElement = null;
		for (WO_SKU_Effort_Map__c woSkuEfforMap : woSkuEfforMaps) {
        	firstElement = woSkuEfforMap;
        	break;
		}
        
        return firstElement;
    }
    
     @testVisible()
    private static void calculateWODuration(WorkOrder workOrder, Set<WO_SKU_Effort_Map__c> woSkuEfforMaps, Set<Project_Task_SKU_Effort_Mapping_Entry__c> projectTaskSkuEffortMappingEntries) {
        
        for(WO_SKU_Effort_Map__c woSkuEffortMap : woSkuEfforMaps) {
            for(Project_Task_SKU_Effort_Mapping_Entry__c projectTaskSkuEffortMappingEntry : projectTaskSkuEffortMappingEntries) {
                if(woSkuEffortMap.SKU_Effort_Mapping_Entry__c == projectTaskSkuEffortMappingEntry.SKU_Effort_Mapping_Entry__c) {
                    if(woSkuEffortMap.Calculation_Type__c != null){
                    if (woSkuEffortMap.Calculation_Type__c == 'By SKU Quantity'){
                        calculateDurationBySKUQuantity(workOrder, projectTaskSkuEffortMappingEntry, woSkuEffortMap);
                    } else if (woSkuEffortMap.Calculation_Type__c == 'By Threshold'){
                        calculateDurationByThreshold(workOrder, projectTaskSkuEffortMappingEntry, woSkuEffortMap);
                    }  
                    }
                }
            }
        }
	}
    
    @testVisible()
    private static void calculateDurationByThreshold(WorkOrder workOrder, Project_Task_SKU_Effort_Mapping_Entry__c projectTaskSkuEffortMappingEntry, WO_SKU_Effort_Map__c woSkuEffortMap) {
        try{
        if (projectTaskSkuEffortMappingEntry.Project_Task__r.pse__Estimated_Hours__c != null) {
            Decimal duration;
            if (projectTaskSkuEffortMappingEntry.Project_Task__r.pse__Estimated_Hours__c <= woSkuEffortMap.Threshold_Value__c){
                duration = woSkuEffortMap.Low_Threshold_Duration__c;
            } 
            else {
                duration = woSkuEffortMap.High_Threshold_Duration__c;
            }
            
            if (workOrder.Duration != null){
                workOrder.Duration = workOrder.Duration + duration;
            } else {
                workOrder.Duration = duration;
            }
        }
            
        }Catch(Exception Ex){
            System.debug('Get Error ' +ex.getMessage() + 'Get Line Number ' +ex.getLineNumber());
        }
    }
    
    @testVisible()
    private static void calculateDurationBySKUQuantity(WorkOrder workOrder, Project_Task_SKU_Effort_Mapping_Entry__c projectTaskSkuEffortMappingEntry, WO_SKU_Effort_Map__c woSkuEffortMap) {
        Integer quantity = 0;
        if (workOrder.Duration != null){
            workOrder.Duration = workOrder.Duration + (woSkuEffortMap.Duration__c * (projectTaskSkuEffortMappingEntry.SKU_Quantity__c < 0 ? quantity : projectTaskSkuEffortMappingEntry.SKU_Quantity__c));
        } else {
            workOrder.Duration = woSkuEffortMap.Duration__c * (projectTaskSkuEffortMappingEntry.SKU_Quantity__c < 0 ? quantity : projectTaskSkuEffortMappingEntry.SKU_Quantity__c);
        }
    }

    private static void populateLocationInformation(WorkOrder workOrder, List<Schema.Location> locations, Map<Id, List<Schema.Address>> addressesByLocation) {
        if(!locations.isEmpty() && locations != null){
            if(addressesByLocation.containsKey(locations[0].Id)) {
                Schema.Address address = addressesByLocation.get(locations[0].Id).get(0);
                workOrder.City = address.City;
                workOrder.Country = address.Country;
                workOrder.PostalCode = address.PostalCode;
                workOrder.State = address.State;
                workOrder.Street = address.Street;
            }
        }
    }
    
       @testVisible()
    private static Project_Task_SKU_Effort_Mapping_Entry__c getFirstProjectTaskSKUEffortMap(Set<Project_Task_SKU_Effort_Mapping_Entry__c> projectTaskSkuEffMappEntries) {
        Project_Task_SKU_Effort_Mapping_Entry__c firstElement = null;
		for (Project_Task_SKU_Effort_Mapping_Entry__c projectTaskSkuEffMappEntry : projectTaskSkuEffMappEntries) {
        	firstElement = projectTaskSkuEffMappEntry;
        	break;
		}
        
        return firstElement;
    }
}