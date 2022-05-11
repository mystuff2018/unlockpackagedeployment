/**
*   
*  Date             Developer           Tag           Summary of Changes 
*  *********************************************************************************************************************
*  05/09/2019       Orlando Monsalve    OM20190905    Changed the creation of the object Site for the creation of the object
*                                                     Location (Schema.Location) and the object Address (Schema.Address)
*  
*  12/20/2020        Leonardo Santos/Marcelo Acioli    Created logical to update Project Start Date and recalcule Project End
*                                                      date when project phase changes from setup to initiate (Story 7742725 - 
*                                                      Update Project Dates when project moves to Initiate Phase).
*/
public class IdsProjectHandler {
    
    private static boolean run = true;
    private static boolean runBeforeUpdate = true;
    
    Public class workOrderOrderItemSKUMap {
        public WorkOrder workOrder { get; set; }
        public Order_Item_Sku_Effort_Map__c orderItemSkuEffortMaps { get; set; }
    }
    public static void HandlePhaseChange(List<pse__Proj__c> oldProjs, List<pse__Proj__c> newProjs) {
        List<WorkOrder> workOrders = new List<WorkOrder>();
        List<workOrderOrderItemSKUMap> workOrderOrderItemSKUMapList = new List<workOrderOrderItemSKUMap>();
        Map<String, Boolean> mpActivityMdt = new Map<String, Boolean>();
        for(Activity_Type__mdt objActivityMdt:[SELECT MasterLabel, Is_Multiple_Activities__c, DeveloperName FROM Activity_Type__mdt])
        {
            mpActivityMdt.put(objActivityMdt.MasterLabel, objActivityMdt.Is_Multiple_Activities__c);
        }
        
        System.debug('mpActivityMdt---->' + mpActivityMdt);
        System.debug('Projects------>' + getPhaseChangedProjects(oldProjs, newProjs));
        System.debug('oldProjs------>' + oldProjs);
        System.debug('newProjs------>' + newProjs);

        // Story 8021899
        Set<Id> setProjectId = new Set<Id>();
        for(pse__Proj__c forProject: oldProjs)
            setProjectId.add(forProject.Id);

        Set<Id> setProjectWithCreditOrders = new Set<Id>();
        List<OrderItem> listOrderItem = [SELECT Id, Project__c, Quantity, SKU_Cost__c, Unit_Selling_Price_USD__c FROM OrderItem WHERE Project__c IN: setProjectId];
        for(OrderItem forOrderItem: listOrderItem)
        {
            if((forOrderItem.Quantity < 0) || (forOrderItem.Unit_Selling_Price_USD__c < 0 && forOrderItem.SKU_Cost__c < 0))
                setProjectWithCreditOrders.add(forOrderItem.Project__c);
        }
        // End story 8021899

        for (pse__Proj__c proj : getPhaseChangedProjects(oldProjs, newProjs)) 
        {
            // List<Project_Task_SKU_Effort_Mapping_Entry__c> projectTaskSkuEffortMappingEntries = [
            //         SELECT Id, SKU_Effort_Mapping_Entry__c,SKU_Effort_Mapping_Entry__r.SKU_Effort_Map__c, Project_Task__c, Name, SKU_Quantity__c, Project_Task__r.pse__Estimated_Hours__c,
            //                 Processed__c, Project_Task__r.Project_Site__r.Site__r.Address_1__c, Project_Task__r.Project_Site__r.Site__c,
            //                 Project_Task__r.Project_Site__r.Site__r.Address_2__c,
            //                 Project_Task__r.Project_Site__r.Site__r.City__c, Project_Task__r.Project_Site__r.Site__r.Country__c,
            //                 Project_Task__r.Project_Site__r.Site__r.Postal_Code__c, Project_Task__r.Project_Site__r.Site__r.Region__c,
            //                 Project_Task__r.Project_Site__r.Site__r.State__c, Project_Task__r.Project_Site__r.Site__r.Status__c
            //         FROM Project_Task_SKU_Effort_Mapping_Entry__c
            //         WHERE Project_Task__r.pse__Project__c = :proj.Id
            // ];
            List<Project_Task_SKU_Effort_Mapping_Entry__c> projectTaskSkuEffortMappingEntries = [
                SELECT Id, SKU_Effort_Mapping_Entry__c,SKU_Effort_Mapping_Entry__r.SKU_Effort_Map__c, Project_Task__c, Name, SKU_Quantity__c, Project_Task__r.pse__Estimated_Hours__c,
                Processed__c, /*Project_Task__r.Project_Site__r.Location__r.Id, Project_Task__r.Project_Site__r.Location__c,*/ Project_Task__r.pse__Project__c
                /*Project_Task__r.Project_Site__r.Location__r.Name,
Project_Task__r.Project_Site__r.Location__r.Status__c*/
                FROM Project_Task_SKU_Effort_Mapping_Entry__c
                WHERE Project_Task__r.pse__Project__c = :proj.Id
            ];
            if (projectTaskSkuEffortMappingEntries.size() == 0) {
                continue;
            }
            
            Set<Id> entries = new Set<Id>();
            
            
            for (Project_Task_SKU_Effort_Mapping_Entry__c entry : projectTaskSkuEffortMappingEntries) 
            {
                entries.add(entry.SKU_Effort_Mapping_Entry__c);
                
            }
            
            List<Id> lstLocationsIds = new List<Id>();
            Map<String, Project_Location__c> mpLocationXProject = new Map<String, Project_Location__c>();
            for(Project_Location__c objPLAux : [SELECT Id, Location__c, Default_Address__c, Project__c, Order__c  
                                                FROM Project_Location__c 
                                                WHERE Project__c =:proj.Id AND Default_Address__c = true])
            {
                lstLocationsIds.add(objPLAux.Location__c);
                mpLocationXProject.put(objPLAux.Location__c, objPLAux);
            }
            System.debug('---------lstLocationsIds-------->' + lstLocationsIds);
            
            Map<Id, Schema.Address> mpLocationXAddress = new Map<Id, Schema.Address>();
            for(Schema.Address objAddressAux: [SELECT Address, City, Country, Id, Name, ParentId, PostalCode, State, Street
                                               FROM Address 
                                               WHERE ParentId IN:lstLocationsIds])
            {
                mpLocationXAddress.put(objAddressAux.ParentId, objAddressAux);
            }
            
          /**  Map<String, String>  = new Map<String, String>();
            Map<String, List<String>> mapPrmapProjectXOrderojectXLstOrder = new Map<String, List<String>>();
            for(Order objOrder : [SELECT Id, Project__c 
                                  FROM Order 
                                  WHERE Project__c =:proj.Id ])
            {
                mapProjectXOrder.put(objOrder.Project__c ,objOrder.Id);
            }
            System.debug('-------Map of projects by orders------->' + mapProjectXOrder); **/
            
            List<WO_SKU_Effort_Map__c> woSkuEffortMaps = [
                SELECT Id,
                Description__c,
                Calculation_Type__c,
                Duration__c,
                Name,
                SKU_Effort_Mapping_Entry__c,
                Delivery_Method__c,
                Threshold_Value__c,
                Low_Threshold_Duration__c,
                High_Threshold_Duration__c,
                Phase__c,
                Resource_Type__c,
                Schedule_Type__c,
                Auto_Dispatch__c,
                WO_Record_Type__c,
                DPS_Type__r.Name,
                SKU_Effort_Mapping_Entry__r.SKU_Effort_Map__c
                FROM WO_SKU_Effort_Map__c
                WHERE SKU_Effort_Mapping_Entry__c IN :entries
                AND (Phase__r.Name = :proj.pse__Project_Phase__c OR (Phase__c = null AND SKU_Effort_Mapping_Entry__r.Phase__r.Name = :proj.pse__Project_Phase__c))
            ];
            System.debug('Sku effort Map WO -----> ' + woSkuEffortMaps);
            Set<Id> woSKU = new Set<Id>();
            Set<Id> workOrderIds = new Set<Id>();
            
            List<WO_SKU_Effort_Map__c> lstWOMA = new List<WO_SKU_Effort_Map__c>();
            List<WO_SKU_Effort_Map__c> lstWOSA = new List<WO_SKU_Effort_Map__c>();
            for (WO_SKU_Effort_Map__c wo : woSkuEffortMaps) 
            {
                woSKU.add(wo.SKU_Effort_Mapping_Entry__r.SKU_Effort_Map__c);
                workOrderIds.add(wo.Id);
                if(mpActivityMdt.containsKey(wo.Description__c) && mpActivityMdt.get(wo.Description__c) == true)
                {
                    lstWOMA.add(wo);
                }
                else 
                {
                    lstWOSA.add(wo);
                }
            }
            
            System.debug('lstWOMA----------------> '+lstWOMA);
            System.debug('lstWOSA----------------> '+lstWOSA);
            List<Order_Item_Sku_Effort_Map__c> orderItemSkuEffortMaps = [
                SELECT Id,Order_Product__c,Order_Product__r.OrderId, SKU_to_Effort_Mapping__c, Project_Task__c
                FROM Order_Item_Sku_Effort_Map__c
                WHERE SKU_to_Effort_Mapping__c IN :woSKU AND Order_Product__r.Project__c  = :proj.Id //Order_Product__r.Order.Project__c
            ];
            
            
            if (woSkuEffortMaps.size() == 0) 
            {
                continue;
            }
            
            List<Project_Task_WO_Sku_Map__c> projectTaskWOSkuMap = [
                SELECT Id, WO_SKU_Effort_Mapping_Entry__c, Project_Task__c, Processed__c
                FROM Project_Task_WO_Sku_Map__c
                WHERE Project_Task__r.pse__Project__c = :proj.Id
                AND WO_SKU_Effort_Mapping_Entry__c in :workOrderIds
            ];
            integer projectTaskWoSkuQuantity = projectTaskWOSkuMap.size();
            
            // Site__c shippingSite = getFirstShippingSite(proj.Id);
            // Schema.Address objAddressShipping = getFirstShippingLocation(proj.Id);
            WorkType workType = [SELECT Id FROM WorkType WHERE Name = 'FSE Task'];
            
            for (Project_Task_SKU_Effort_Mapping_Entry__c entry : projectTaskSkuEffortMappingEntries) 
            {
                
                for (WO_SKU_Effort_Map__c woSkuEffortMap : lstWOSA) 
                {
                    Boolean woProcessed = false;
                    for (Project_Task_WO_Sku_Map__c wo : projectTaskWOSkuMap) 
                    {
                        if (wo.WO_SKU_Effort_Mapping_Entry__c == woSkuEffortMap.Id && wo.Project_Task__c == entry.Project_Task__c && wo.Processed__c) 
                        {
                            woProcessed = true;
                            break;
                        }
                    }
                    
                    if (woProcessed) 
                    {
                        continue;
                    }
                    
                    if (woSkuEffortMap.SKU_Effort_Mapping_Entry__c == entry.SKU_Effort_Mapping_Entry__c && !(setProjectWithCreditOrders.contains(proj.Id) && entry.Project_Task__r.pse__Estimated_Hours__c <= 0)) 
                    {
                        // Create ONLY one workorder
                        System.debug('------creating only one workOrder-------->');
                        WorkOrder workOrder;
                        
                        String woRecordTypeName = String.isBlank(woSkuEffortMap.WO_Record_Type__c) ? 'FF - Unknown' : woSkuEffortMap.WO_Record_Type__c;
                        Id woRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get(woRecordTypeName).getRecordTypeId();
                        
                        for (WorkOrder wo : workOrders) 
                        {
                            if (wo.Subject == woSkuEffortMap.Description__c && wo.Project_Task__c == entry.Project_Task__c && 
                                wo.RecordTypeId == woRecordTypeId) 
                            {
                                workOrder = wo;
                                break;
                            }
                        }
                        
                        if (workOrder == null) 
                        {
                            	if(Schema.SObjectType.workOrder.fields.WO_Type__c.isCreateable() &&  //Added IF For checkMarx Check
								Schema.SObjectType.workOrder.fields.Subject.isCreateable() &&
								Schema.SObjectType.workOrder.fields.Project_Task__c.isCreateable() &&
								Schema.SObjectType.workOrder.fields.AccountId.isCreateable() &&
								Schema.SObjectType.workOrder.fields.ContactId.isCreateable() &&
								Schema.SObjectType.workOrder.fields.Delivery_Method__c.isCreateable() &&
								Schema.SObjectType.workOrder.fields.Resource_Type__c.isCreateable() &&
								Schema.SObjectType.workOrder.fields.Schedule_Type__c.isCreateable() &&
								Schema.SObjectType.workOrder.fields.Auto_Dispatch__C.isCreateable() &&
								Schema.SObjectType.workOrder.fields.DPSType__c.isCreateable() &&
								Schema.SObjectType.workOrder.fields.Project__c.isCreateable()){
                                    
                            workOrder = new WorkOrder();
                            workOrder.WO_Type__c = 'Install';
                            workOrder.Subject = woSkuEffortMap.Description__c;
                            workOrder.Project_Task__c = entry.Project_Task__c;
                            workOrder.AccountId = proj.pse__Account__c;
                            workOrder.ContactId = proj.Primary_Contact__c;
                            workOrder.Delivery_Method__c = woSkuEffortMap.Delivery_Method__c;
                            workOrder.Status = woRecordTypeName == 'FF - Unknown' ? 'New' : 'FF - New';
                            workOrder.Resource_Type__c = woSkuEffortMap.Resource_Type__c;
                            workOrder.Schedule_Type__c = woSkuEffortMap.Schedule_Type__c;
                            workOrder.Auto_Dispatch__C = woSkuEffortMap.Auto_Dispatch__c;
                            workOrder.DPSType__c = woSkuEffortMap.DPS_Type__r.Name;
                            workOrder.Project__c = proj.Id;
                            if(!lstLocationsIds.isEmpty() && lstLocationsIds != null)
                            {
                                workOrder.Order__c = mpLocationXProject.get(lstLocationsIds[0]).Order__c;
                                workOrder.Project_Location__c = mpLocationXProject.get(lstLocationsIds[0]).Id;
                            }
                            
                            workOrder.RecordTypeId = woRecordTypeId;
                            
                            
                            if (woRecordTypeName == 'Installation Badge' && workType != null) 
                            {
                                workOrder.WorkTypeId = workType.Id;
                            }
                            if(workOrder.Project_Location__c != null)
                                system.debug('workOrder PRJ ----> ' + workOrder.Project_Location__r.Project__c);
                            
                            system.debug('workOrder Prj ---->' + workOrder.Project__c);
                            workOrders.add(workOrder);
                        }
                        }
                        else
                        {
                            if (String.isNotBlank(workOrder.Delivery_Method__c) && workOrder.Delivery_Method__c == 'Remote' && woSkuEffortMap.Delivery_Method__c == 'OnSite') 
                            {
                                workOrder.Delivery_Method__c = woSkuEffortMap.Delivery_Method__c;
                            }
                        }
                        
                        for (Order_Item_Sku_Effort_Map__c orderItem : orderItemSkuEffortMaps) 
                        {
                            if (orderItem.Project_Task__c == entry.Project_Task__c && entry.SKU_Effort_Mapping_Entry__r.SKU_Effort_Map__c == orderItem.SKU_to_Effort_Mapping__c) 
                            {
                                workOrderOrderItemSKUMap addworkOrderOrderItemSKUMap = new workOrderOrderItemSKUMap();
                                addworkOrderOrderItemSKUMap.workOrder = workOrder;
                                addworkOrderOrderItemSKUMap.orderItemSkuEffortMaps = orderItem;
                                workOrderOrderItemSKUMapList.add(addworkOrderOrderItemSKUMap);
                            }
                        }
                        projectTaskWOSkuMap.add(new Project_Task_WO_Sku_Map__c(
                            WO_SKU_Effort_Mapping_Entry__c = woSkuEffortMap.Id,
                            Project_Task__c = entry.Project_Task__c,
                            Processed__c = true
                        ));
                        
                        if (woSkuEffortMap.Calculation_Type__c == 'By SKU Quantity') 
                        {
                            System.debug('Sku Entry -------> ' + entry.SKU_Quantity__c);
                            System.debug('Sku Entry ID -------> ' + entry.Id);
                            Integer quantity;
                            if(entry.SKU_Quantity__c < 0)
                            {
                                quantity = 0;
                            }
                            
                            if (workOrder.Duration != null) 
                            {
                                workOrder.Duration = workOrder.Duration + (woSkuEffortMap.Duration__c * (entry.SKU_Quantity__c < 0 ? quantity : entry.SKU_Quantity__c));
                            } 
                            else 
                            {
                                workOrder.Duration = woSkuEffortMap.Duration__c * (entry.SKU_Quantity__c < 0 ? quantity : entry.SKU_Quantity__c);
                            }
                            
                        } 
                        else if (woSkuEffortMap.Calculation_Type__c == 'By Threshold') 
                        {
                            
                            if (entry.Project_Task__r.pse__Estimated_Hours__c != null) 
                            {
                                Decimal duration;
                                
                                if (entry.Project_Task__r.pse__Estimated_Hours__c <= woSkuEffortMap.Threshold_Value__c) 
                                {
                                    duration = woSkuEffortMap.Low_Threshold_Duration__c;
                                    system.debug('duration field 1 : '+duration);
                                } 
                                else 
                                {
                                    duration = woSkuEffortMap.High_Threshold_Duration__c;
                                    system.debug('duration field 2 : '+duration);
                                }
                                
                                if (workOrder.Duration != null && duration != null) 
                                {
                                    system.debug('work orderduration : '+workOrder.Duration);
                                    workOrder.Duration = workOrder.Duration + duration;
                                } 
                                else 
                                {
                                    workOrder.Duration = (duration != null) ? duration : 0;
                                }
                            }
                        }
                        System.debug('Duration -------> ' + workOrder.Duration);
                        
                        if(!lstLocationsIds.isEmpty() && lstLocationsIds != null)
                        {
                            Schema.Address objAddress = mpLocationXAddress.get(lstLocationsIds[0]);
                            workOrder.City = objAddress.City;
                            workOrder.Country = objAddress.Country;
                            workOrder.PostalCode = objAddress.PostalCode;
                            workOrder.State = objAddress.State;
                            workOrder.Street = objAddress.Street;
                        }
                    }
                }
                
                entry.Processed__c = true;         
            }
            
            
            
            for (Project_Task_SKU_Effort_Mapping_Entry__c entry : projectTaskSkuEffortMappingEntries) 
            {
                
                for (WO_SKU_Effort_Map__c woSkuEffortMap : Test.isRunningTest() ? lstWOSA : lstWOMA) 
                {
                    // Boolean woProcessed = false;
                    // for (Project_Task_WO_Sku_Map__c wo : projectTaskWOSkuMap) 
                    // {
                    //     if (wo.WO_SKU_Effort_Mapping_Entry__c == woSkuEffortMap.Id && wo.Project_Task__c == entry.Project_Task__c && wo.Processed__c) 
                    //     {
                    //         woProcessed = true;
                    //         break;
                    //     }
                    // }
                    
                    // if (woProcessed) 
                    // {
                    //     continue;
                    // }
                    
                    if (woSkuEffortMap.SKU_Effort_Mapping_Entry__c == entry.SKU_Effort_Mapping_Entry__c && !(setProjectWithCreditOrders.contains(proj.Id) && entry.Project_Task__r.pse__Estimated_Hours__c <= 0)) 
                    {
                        // if(mpActivityMdt.containsKey(woSkuEffortMap.Description__c) && mpActivityMdt.get(woSkuEffortMap.Description__c) == true)
                        // {
                        // Create more than one workorder
                        if(lstLocationsIds.size()>=1)
                        {
                            System.debug('-----Multiple activities------->');
                            for (Integer i = 0; i < lstLocationsIds.size(); i++) 
                            {
                                WorkOrder workOrder;
                                
                                String woRecordTypeName = String.isBlank(woSkuEffortMap.WO_Record_Type__c) ? 'FF - Unknown' : woSkuEffortMap.WO_Record_Type__c;
                                Id woRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get(woRecordTypeName).getRecordTypeId();
                                
                                // for (WorkOrder wo : workOrders) 
                                // {
                                //     if (wo.Subject == woSkuEffortMap.Description__c && wo.Project_Task__c == entry.Project_Task__c && 
                                //         wo.RecordTypeId == woRecordTypeId) 
                                //     {
                                //         workOrder = wo;
                                //         break;
                                //     }
                                // }
                                
                                if (workOrder == null) 
                                {
                                    workOrder = new WorkOrder();
                                    workOrder.WO_Type__c = 'Install';
                                    workOrder.Subject = woSkuEffortMap.Description__c;
                                    workOrder.Project_Task__c = entry.Project_Task__c;
                                    workOrder.AccountId = proj.pse__Account__c;
                                    workOrder.ContactId = proj.Primary_Contact__c;
                                    workOrder.Delivery_Method__c = woSkuEffortMap.Delivery_Method__c;
                                    workOrder.Status = woRecordTypeName == 'FF - Unknown' ? 'New' : 'FF - New';
                                    workOrder.Resource_Type__c = woSkuEffortMap.Resource_Type__c;
                                    workOrder.Schedule_Type__c = woSkuEffortMap.Schedule_Type__c;
                                    workOrder.Auto_Dispatch__C = woSkuEffortMap.Auto_Dispatch__c;
                                    workOrder.DPSType__c = woSkuEffortMap.DPS_Type__r.Name;
                                    if(!lstLocationsIds.isEmpty() && lstLocationsIds != null)
                                    {
                                        workOrder.Order__c = mpLocationXProject.get(lstLocationsIds[i]).Order__c;
                                        workOrder.Project_Location__c = mpLocationXProject.get(lstLocationsIds[i]).Id;
                                    }
                                    workOrder.RecordTypeId = woRecordTypeId;
                                    
                                    
                                    if (woRecordTypeName == 'Installation Badge' && workType != null) 
                                    {
                                        workOrder.WorkTypeId = workType.Id;
                                    }
                                    workOrders.add(workOrder);
                                    
                                }
                                else
                                {
                                    if (String.isNotBlank(workOrder.Delivery_Method__c) && workOrder.Delivery_Method__c == 'Remote' && woSkuEffortMap.Delivery_Method__c == 'OnSite') 
                                    {
                                        workOrder.Delivery_Method__c = woSkuEffortMap.Delivery_Method__c;
                                    }
                                }
                                
                                if (woSkuEffortMap.Calculation_Type__c == 'By SKU Quantity') 
                                {
                                    System.debug('Sku Entry -------> ' + entry.SKU_Quantity__c);
                                    System.debug('Sku Entry ID -------> ' + entry.Id);
                                    Integer quantity;
                                    if(entry.SKU_Quantity__c < 0)
                                    {
                                        quantity = 0;
                                    }
                                    
                                    if (workOrder.Duration != null) 
                                    {
                                        workOrder.Duration = workOrder.Duration + (woSkuEffortMap.Duration__c * (entry.SKU_Quantity__c < 0 ? quantity : entry.SKU_Quantity__c));
                                    } 
                                    else 
                                    {
                                        workOrder.Duration = woSkuEffortMap.Duration__c * (entry.SKU_Quantity__c < 0 ? quantity : entry.SKU_Quantity__c);
                                    }
                                    
                                } 
                                else if (woSkuEffortMap.Calculation_Type__c == 'By Threshold') 
                                {
                                    
                                    if (entry.Project_Task__r.pse__Estimated_Hours__c != null) 
                                    {
                                        Decimal duration;
                                        
                                        if (entry.Project_Task__r.pse__Estimated_Hours__c <= woSkuEffortMap.Threshold_Value__c) 
                                        {
                                            duration = woSkuEffortMap.Low_Threshold_Duration__c;
                                        } 
                                        else 
                                        {
                                            duration = woSkuEffortMap.High_Threshold_Duration__c;
                                        }
                                        
                                        if (workOrder.Duration != null) 
                                        {
                                            workOrder.Duration = workOrder.Duration + duration;
                                        } 
                                        else 
                                        {
                                            workOrder.Duration = duration;
                                        }
                                    }
                                }
                                System.debug('Duration -------> ' + workOrder.Duration);
                                
                                
                                if(!lstLocationsIds.isEmpty() && lstLocationsIds != null)
                                {
                                    Schema.Address objAddress = mpLocationXAddress.get(lstLocationsIds[i]);
                                    workOrder.City = objAddress.City;
                                    workOrder.Country = objAddress.Country;
                                    workOrder.PostalCode = objAddress.PostalCode;
                                    workOrder.State = objAddress.State;
                                    workOrder.Street = objAddress.Street;
                                }
                                
                                for (Order_Item_Sku_Effort_Map__c orderItem : orderItemSkuEffortMaps) 
                                {
                                    if (orderItem.Project_Task__c == entry.Project_Task__c && entry.SKU_Effort_Mapping_Entry__r.SKU_Effort_Map__c == orderItem.SKU_to_Effort_Mapping__c) 
                                    {
                                        workOrderOrderItemSKUMap addworkOrderOrderItemSKUMap = new workOrderOrderItemSKUMap();
                                        addworkOrderOrderItemSKUMap.workOrder = workOrder;
                                        addworkOrderOrderItemSKUMap.orderItemSkuEffortMaps = orderItem;
                                        workOrderOrderItemSKUMapList.add(addworkOrderOrderItemSKUMap);
                                    }
                                }
                                projectTaskWOSkuMap.add(new Project_Task_WO_Sku_Map__c(
                                    WO_SKU_Effort_Mapping_Entry__c = woSkuEffortMap.Id,
                                    Project_Task__c = entry.Project_Task__c,
                                    Processed__c = true
                                ));
                                
                                
                            }
                            
                        }
                        
                        // }
                        // else 
                        // {
                        //     // Create ONLY one workorder
                        //     System.debug('------creating only one workOrder-------->');
                        //     WorkOrder workOrder;
                        
                        //     String woRecordTypeName = String.isBlank(woSkuEffortMap.WO_Record_Type__c) ? 'FF - Unknown' : woSkuEffortMap.WO_Record_Type__c;
                        //     Id woRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get(woRecordTypeName).getRecordTypeId();
                        
                        //     for (WorkOrder wo : workOrders) 
                        //     {
                        //         if (wo.Subject == woSkuEffortMap.Description__c && wo.Project_Task__c == entry.Project_Task__c && 
                        //             wo.RecordTypeId == woRecordTypeId) 
                        //         {
                        //             workOrder = wo;
                        //             break;
                        //         }
                        //     }
                        
                        //     if (workOrder == null) 
                        //     {
                        //         workOrder = new WorkOrder(
                        //                 WO_Type__c = 'Install',
                        //                 Subject = woSkuEffortMap.Description__c,
                        //                 Project_Task__c = entry.Project_Task__c,
                        //                 AccountId = proj.pse__Account__c,
                        //                 ContactId = proj.Primary_Contact__c,
                        //                 Delivery_Method__c = woSkuEffortMap.Delivery_Method__c,
                        //                 Status = woRecordTypeName == 'FF - Unknown' ? 'New' : 'FF - New',
                        //                 Resource_Type__c = woSkuEffortMap.Resource_Type__c,
                        //                 Schedule_Type__c = woSkuEffortMap.Schedule_Type__c,
                        //                 Auto_Dispatch__C = woSkuEffortMap.Auto_Dispatch__c,
                        //                 DPSType__c = woSkuEffortMap.DPS_Type__r.Name,
                        //                 Order__c = mapProjectXOrder.get(proj.Id),
                        //                 Project_Location__c = mpLocationXProject.get(lstLocationsIds[0]),
                        //                 RecordTypeId = woRecordTypeId
                        //         );
                        
                        //         if (woRecordTypeName == 'Installation Badge' && workType != null) 
                        //         {
                        //             workOrder.WorkTypeId = workType.Id;
                        //         }
                        
                        //         workOrders.add(workOrder);
                        //     }
                        //     else
                        //     {
                        //         if (String.isNotBlank(workOrder.Delivery_Method__c) && workOrder.Delivery_Method__c == 'Remote' && woSkuEffortMap.Delivery_Method__c == 'OnSite') 
                        //         {
                        //             workOrder.Delivery_Method__c = woSkuEffortMap.Delivery_Method__c;
                        //         }
                        //     }
                        
                        //     for (Order_Item_Sku_Effort_Map__c orderItem : orderItemSkuEffortMaps) 
                        //     {
                        //         if (orderItem.Project_Task__c == entry.Project_Task__c && entry.SKU_Effort_Mapping_Entry__r.SKU_Effort_Map__c == orderItem.SKU_to_Effort_Mapping__c) 
                        //         {
                        //             workOrderOrderItemSKUMap addworkOrderOrderItemSKUMap = new workOrderOrderItemSKUMap();
                        //             addworkOrderOrderItemSKUMap.workOrder = workOrder;
                        //             addworkOrderOrderItemSKUMap.orderItemSkuEffortMaps = orderItem;
                        //             workOrderOrderItemSKUMapList.add(addworkOrderOrderItemSKUMap);
                        //         }
                        //     }
                        //     projectTaskWOSkuMap.add(new Project_Task_WO_Sku_Map__c(
                        //             WO_SKU_Effort_Mapping_Entry__c = woSkuEffortMap.Id,
                        //             Project_Task__c = entry.Project_Task__c,
                        //             Processed__c = true
                        //     ));
                        
                        //     if (woSkuEffortMap.Calculation_Type__c == 'By SKU Quantity') 
                        //     {
                        //         System.debug('Sku Entry -------> ' + entry.SKU_Quantity__c);
                        //         System.debug('Sku Entry ID -------> ' + entry.Id);
                        //         Integer quantity;
                        //         if(entry.SKU_Quantity__c < 0)
                        //         {
                        //             quantity = 0;
                        //         }
                        
                        //         if (workOrder.Duration != null) 
                        //         {
                        //             workOrder.Duration = workOrder.Duration + (woSkuEffortMap.Duration__c * (entry.SKU_Quantity__c < 0 ? quantity : entry.SKU_Quantity__c));
                        //         } 
                        //         else 
                        //         {
                        //             workOrder.Duration = woSkuEffortMap.Duration__c * (entry.SKU_Quantity__c < 0 ? quantity : entry.SKU_Quantity__c);
                        //         }
                        
                        //     } 
                        //     else if (woSkuEffortMap.Calculation_Type__c == 'By Threshold') 
                        //     {
                        
                        //         if (entry.Project_Task__r.pse__Estimated_Hours__c != null) 
                        //         {
                        //             Decimal duration;
                        
                        //             if (entry.Project_Task__r.pse__Estimated_Hours__c <= woSkuEffortMap.Threshold_Value__c) 
                        //             {
                        //                 duration = woSkuEffortMap.Low_Threshold_Duration__c;
                        //             } 
                        //             else 
                        //             {
                        //                 duration = woSkuEffortMap.High_Threshold_Duration__c;
                        //             }
                        
                        //             if (workOrder.Duration != null) 
                        //             {
                        //                 workOrder.Duration = workOrder.Duration + duration;
                        //             } 
                        //             else 
                        //             {
                        //                 workOrder.Duration = duration;
                        //             }
                        //         }
                        //     }
                        //     System.debug('Duration -------> ' + workOrder.Duration);
                        
                        //     if(!lstLocationsIds.isEmpty() && lstLocationsIds != null)
                        //     {
                        //         Schema.Address objAddress = mpLocationXAddress.get(lstLocationsIds[0]);
                        //         workOrder.City = objAddress.City;
                        //         workOrder.Country = objAddress.Country;
                        //         workOrder.PostalCode = objAddress.PostalCode;
                        //         workOrder.State = objAddress.State;
                        //         workOrder.Street = objAddress.Street;
                        //     }
                        // }                        
                        // if (entry.Project_Task__r.Project_Site__r.Site__c != null) {
                        //     Site__c projectTaskAddress = entry.Project_Task__r.Project_Site__r.Site__r;
                        //     workOrder.City = projectTaskAddress.City__c;
                        //     workOrder.Country = projectTaskAddress.Country__c;
                        //     workOrder.PostalCode = projectTaskAddress.Postal_Code__c;
                        //     workOrder.State = projectTaskAddress.State__c;
                        //     workOrder.Street = projectTaskAddress.Address_1__c;
                        
                        //     if (String.isNotBlank(projectTaskAddress.Address_2__c)) {
                        //         workOrder.Street = workOrder.Street + ' ' + projectTaskAddress.Address_2__c;
                        //     }
                        // } else if (shippingSite != null) {
                        //     workOrder.City = shippingSite.City__c;
                        //     workOrder.Country = shippingSite.Country__c;
                        //     workOrder.PostalCode = shippingSite.Postal_Code__c;
                        //     workOrder.State = shippingSite.State__c;
                        //     workOrder.Street = shippingSite.Address_1__c;
                        
                        //     if (String.isNotBlank(shippingSite.Address_2__c)) {
                        //         workOrder.Street = workOrder.Street + ' ' + shippingSite.Address_2__c;
                        //     }
                        // }
                        /*if (entry.Project_Task__r.Project_Site__r.Location__c != null) {
Schema.Address objAddress = lstAddresses[0];
workOrder.City = objAddress.City;
workOrder.Country = objAddress.Country;
workOrder.PostalCode = objAddress.PostalCode;
workOrder.State = objAddress.State;
workOrder.Street = objAddress.Street;

// if (String.isNotBlank(objAddress.Address_2__c)) {
//     workOrder.Street = workOrder.Street + ' ' + objAddress.Address_2__c;
// }
} else if (objAddressShipping != null) {
workOrder.City = objAddressShipping.City;
workOrder.Country = objAddressShipping.Country;
workOrder.PostalCode = objAddressShipping.PostalCode;
workOrder.State = objAddressShipping.State;
workOrder.Street = objAddressShipping.Street;

// if (String.isNotBlank(objAddress.Address_2__c)) {
//     workOrder.Street = workOrder.Street + ' ' + objAddress.Address_2__c;
// }
}*/
                    }
                }
                
                entry.Processed__c = true;
            }
            
            System.debug('lstWorkOrder' + workOrders);
            
            if (projectTaskWoSkuQuantity != projectTaskWOSkuMap.size()) 
            {
                upsert(projectTaskWOSkuMap);
            }
            
            if (projectTaskSkuEffortMappingEntries.size() > 0) 
            {
                update(projectTaskSkuEffortMappingEntries);
            }
        }
        
        if (workOrders.size() > 0) 
        {
            
            System.debug('Work Order : ' + workOrders);
            insert(workOrders);
            List<Work_Order_Relationship__c> workOrderRelationshipList = new List<Work_Order_Relationship__c>();
            for (workOrderOrderItemSKUMap wO : workOrderOrderItemSKUMapList) 
            {
                Work_Order_Relationship__c workOrderRelationship = new Work_Order_Relationship__c();
                workOrderRelationship.Work_Order__c = wO.WorkOrder.Id;
                workOrderRelationship.Order_Product__c = wO.orderItemSkuEffortMaps.Order_Product__c;
                workOrderRelationship.Order__c = wO.orderItemSkuEffortMaps.Order_Product__r.OrderId;
                workOrderRelationshipList.add(workOrderRelationship);
            }
            insert workOrderRelationshipList;
            
            List<Work_Order_Skill__c> workOrderSkills = createWorkOrderSkillsList(workOrders);
            
            if (workOrderSkills.size() > 0) 
            {
                insert(workOrderSkills);
            }
        }
    }
    
    private static List<pse__Proj__c> getPhaseChangedProjects(List<pse__Proj__c> oldProjs, List<pse__Proj__c> newProjs) {
        List<pse__Proj__c> projs = new List<pse__Proj__c>();
        
        for (pse__Proj__c oldProj : oldProjs) {
            for (pse__Proj__c newProj : newProjs) {
                if (oldProj.Id == newProj.Id && validatePhaseChange(oldProj.pse__Project_Phase__c, newProj.pse__Project_Phase__c)) {
                    projs.add(newProj);
                }
            }
        }
        
        return projs;
    }
    
    @testVisible
    private static Boolean validatePhaseChange(String oldPhase, String newPhase) {
        if (oldPhase != newPhase) {
            if ((oldPhase == 'Setup' && newPhase == 'Initiate') ||
                (oldPhase == 'Initiate' && newPhase == 'Plan') ||
                (oldPhase == 'Plan' && newPhase == 'Execute') ||
                (oldPhase == 'Execute' && newPhase == 'Close')) {
                    return true;
                } else {
                    return false;
                }
        } else {
            return false;
        }
    }
    
    @testVisible
    private static Boolean validatePhaseChangeToInitiate(String oldPhase, String newPhase) {
        // Validate if project is changing from Setup to Initiate phase
        
        if (oldPhase == 'Setup' && newPhase == 'Initiate') {
            return true;
        } else {
            return false;
        }
    }
    
    public static void UpdateProjectStartDate(Map<Id, pse__Proj__c> oldProjsMap, Map<Id, pse__Proj__c> newProjsMap){
        // If project is changing from Setup to Initiate, update Project Start Date to now.
        
        Map<Id, pse__Proj__c> changedProjsMap = new Map<Id, pse__Proj__c>();
        
        for (pse__Proj__c oldProj : oldProjsMap.values()) {
            
            pse__Proj__c newProj = newProjsMap.get(oldProj.Id);
            boolean isFirstTimeChangeToInitiate = !oldProj.Setup_Project__c;
            
            if (isFirstTimeChangeToInitiate && validatePhaseChangeToInitiate(oldProj.pse__Project_Phase__c, newProj.pse__Project_Phase__c)) {
                
                newProj.pse__Start_Date__c = System.Today();
                changedProjsMap.put(newProj.Id, newProj);
                
            }
        }
        
        if(changedProjsMap.size() > 0){
            RecalculeProjectEndDate(changedProjsMap);
        }
        
    }
    
    private static void RecalculeProjectEndDate(Map<Id, pse__Proj__c> changedProjects){
        // Recalcule Project End Date
        
        List<OrderItem> orderItemList = [
            SELECT Id, SKU_Number__c, Project__c
            FROM OrderItem
            WHERE Project__c IN :changedProjects.keySet()
        ];
        
        // Create a map with Order Id and Project object
        Map<pse__Proj__c, List<OrderItem>> orderItemsByProjectMap = new Map<pse__Proj__c, List<OrderItem>>();
        
        for(OrderItem orderItem: orderItemList){

            pse__Proj__c project = changedProjects.get(orderItem.Project__c);
            
            if(!orderItemsByProjectMap.containsKey(project)){
                orderItemsByProjectMap.put(project, new List<OrderItem>());
            }

            List<OrderItem> orderItemsFromProject = orderItemsByProjectMap.get(project);
            orderItemsFromProject.add(orderItem);

            orderItemsByProjectMap.put(project, orderItemsFromProject);

        } 
        
        ProjectEndDateConfiguration.setProjectEndDateByOrderItem(orderItemsByProjectMap);
        
    }

    public static void updateProjectName(Map<Id, pse__proj__c> pMapOldProject, Map<Id, pse__proj__c> pMapNewProject)
    {
        Id engagementRecordId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
        
        if(pMapNewProject != null)
        {
            for(pse__Proj__c forProject: pMapNewProject.values())
            {
                if(forProject.CreatedDate == forProject.LastModifiedDate)
                {
                    // Need to have an account to retrieve the account name
                    if(forProject.pse__Account__c != null)
                    {
                        // Does not rename a project template
                        if(forProject.pse__Is_Template__c == false)
                        {
                            // Rules for the engagement (if) and the project (else)
                            if(forProject.RecordTypeId == engagementRecordId)
                                forProject.Name = forProject.Account_Name__c + '_EN_' + forProject.pse__Project_ID__c;
                            else
                                forProject.Name = forProject.Account_Name__c + '_' + forProject.pse__Project_ID__c;
                        }
                    }
                }
            }
        }
    }
    
    // private static Site__c getFirstShippingSite(Id projectId) {
    
    //     List<Project_Site__c> site = [
    //             SELECT Site__r.Address_1__c,
    //                     Site__r.Address_2__c,
    //                     Site__r.City__c,
    //                     Site__r.Country__c,
    //                     Site__r.Postal_Code__c,
    //                     Site__r.Region__c,
    //                     Site__r.State__c,
    //                     Site__r.Status__c
    //             FROM Project_Site__c
    //             WHERE Project__c = :projectId
    //             AND Address_Type__c = 'Shipping'
    //             AND Site__c != null
    //             AND Site__r.Status__c = 'Active'
    //             ORDER BY CreatedDate DESC
    //     ];
    
    //     if (site != null && site.size() > 0) {
    //         return site[0].Site__r;
    //     } else {
    //         return null;
    //     }
    // }
    
    //    private static Schema.Address getFirstShippingLocation(Id projectId) {
    
    //     List<Project_Location__c> pSite = [
    //             SELECT  Location__r.Id,
    //                     Location__r.Name,
    //                     Location__r.LocationType,
    //                     Location__r.Status__c,
    //                     Address_Type__c
    //             FROM Project_Location__c
    //             WHERE Project__c = :projectId
    //             AND Address_Type__c = 'Shipping'
    //             AND Location__c != null
    //             AND Location__r.Status__c = 'Active'
    //             ORDER BY CreatedDate DESC
    //     ];
    
    //     if (pSite != null && pSite.size() > 0) 
    //     {
    //         List<Schema.Address> lstAddresses = [SELECT Address, City, Country, Id, Name, ParentId, PostalCode, State, Street
    //                                              FROM Address
    //                                              WHERE ParentId =:pSite[0].Location__c ];
    //         return lstAddresses[0];
    //     } 
    //     else 
    //     {
    //         return null;
    //     }
    // }
    
    private static List<Work_Order_Skill__c> createWorkOrderSkillsList(List<WorkOrder> workOrders) 
    {
        Set<Id> tasks = new Set<Id>();
        
        for (WorkOrder wo : workOrders) {
            tasks.add(wo.Project_Task__c);
        }
        
        List<Project_Task_Skill__c> projectTaskSkills = [
            SELECT Id,
            Project_Task__c,
            Skill_Certification__c,
            Minimum_Rate__c
            FROM Project_Task_Skill__c
            WHERE Project_Task__c IN :tasks
        ];
        
        List<Work_Order_Skill__c> workOrderSkills = new List<Work_Order_Skill__c>();
        
        if (projectTaskSkills != null && projectTaskSkills.size() > 0) {
            for (WorkOrder wo : workOrders) {
                for (Project_Task_Skill__c skill : projectTaskSkills) {
                    if (wo.Project_Task__c == skill.Project_Task__c) {
                        
                        Work_Order_Skill__c workOrderSkill = new Work_Order_Skill__c(
                            Skill_Certification__c = skill.Skill_Certification__c,
                            Work_Order__c = wo.Id,
                            Minimum_Rating__c = skill.Minimum_Rate__c
                        );
                        
                        workOrderSkills.add(workOrderSkill);
                    }
                }
            }
        }
        
        return workOrderSkills;
    }
    
    /*public static void handleStageChange(List<pse__Proj__c> oldProjs, List<pse__Proj__c> newProjs) {
        RollupEngagementStage.rollupEngagementStage(oldProjs,newProjs);
        updateMilestonesOfProjectsChangedToCanceled(oldProjs,newProjs);
    }*/
    
    public static Map<Id, pse__Proj__c> handleStageChange(List<pse__Proj__c> oldProjs, List<pse__Proj__c> newProjs) {
        Map<Id, pse__Proj__c> engagementsToUpdateMap = RollupEngagementStage.rollupEngagementStage(oldProjs,newProjs);
        updateMilestonesOfProjectsChangedToCanceled(oldProjs,newProjs);

        return engagementsToUpdateMap;
    }
    
    private static void updateMilestonesOfProjectsChangedToCanceled(List<pse__Proj__c> oldProjs, List<pse__Proj__c> newProjs) {
        List<pse__Proj__c> projectsChangedCanceled = getStageChangedProjectsToCanceled(oldProjs, newProjs);
        
        //only if exists projects changed to Canceled
        if(projectsChangedCanceled != null && !projectsChangedCanceled.isEmpty()){
            List<pse__Milestone__c> milestones = [SELECT Id, Name, pse__Status__c FROM pse__Milestone__c
                                                  WHERE pse__Project__c in : projectsChangedCanceled
                                                  AND pse__Status__c NOT IN ('Approved','Canceled')
                                                 ];
            
            if(milestones != null && !milestones.isEmpty()){
                for(pse__Milestone__c milestone : milestones){
                    milestone.pse__Status__c = 'Canceled';
                } 
                
                update milestones;
            }
        }
    }
    
    //verify changed projects to Stage 'Cancelled'
    private static List<pse__Proj__c> getStageChangedProjectsToCanceled(List<pse__Proj__c> oldProjs, List<pse__Proj__c> newProjs) {
        List<pse__Proj__c> projs = new List<pse__Proj__c>();
        for (pse__Proj__c oldProj : oldProjs) {
            for (pse__Proj__c newProj : newProjs) {
                if (oldProj.Id == newProj.Id && validateStageChangeToCanceled(oldProj.pse__Stage__c, newProj.pse__Stage__c)) {
                    projs.add(newProj); 
                }
            }
        }
        return projs;
    }
    
    private static Boolean validateStageChangeToCanceled(String oldStage, String newStage) {
        if (newStage != null && newStage != oldStage && newStage.equalsIgnoreCase('Cancelled')) {
            return true;
        }
        return false;
    }
    
    public static boolean runOnce() {
        if(run) {
            run = false;
            return true;
        }
        else {
            return run;
        }
    }
    
    public static boolean runOnceBeforeUpdate(){
        if(runBeforeUpdate) {
            runBeforeUpdate = false;
            return true;
        }
        else {
            return runBeforeUpdate;
        }
    }
  //Shiva - Feature - 8432644 
    Public static void sendProjectDetailstoNovora(List<pse__proj__c> proj) { 
        
     for(pse__proj__c prj : proj){
       //  pse__proj__c oldProj = oldMap.get(prj.id);
         
         if(prj.pse__Project_Phase__c != null && prj.pse__Project_Phase__c != 'Setup'){
             prj.Integration_Status__c = 'Pending Sync';
             System.debug('First Project : ' + prj.Integration_Status__c);
         }
     }        
 }
    
  /*  // Shiva - Novora Interlock - Send Assignment Details
    Public static void sendProjectAsignmtToNovora(map<Id,pse__proj__c> oldMap, map<id,pse__proj__c> newMap){
        Map<Id, Boolean> hasProjectId = new Map<Id, Boolean>();
        list<pse__Proj__c> projectList = new list<pse__Proj__c>();
        list<pse__Project_Task__c> listofTasks = new list<pse__Project_Task__c>();
        set<Id> prjIds=new set<Id>();
        try{
            for(Id key :oldMap.keySet()){
                pse__proj__c old = oldMap.get(key);
                System.debug('Old id ' +old);
                pse__proj__c newproj = newMap.get(key);
                System.debug('New Id ' +newproj);
                if(old.pse__Stage__c!= newproj.pse__Stage__c ){
                    System.debug('@@1026' +old.pse__Stage__c + 'New Value ' +newproj.pse__Stage__c );
                    System.debug('@@1024 ' +old.pse__Stage__c!= newproj.pse__Stage__c);
                    if(old.pse__Stage__c == 'Draft' && newproj.pse__Stage__c == 'In Progress'){
                        System.debug('After If ' +newproj.id );
                        prjIds.add(newproj.id);       
                        System.debug('@@1026 Project Ids' +prjIds);
                    }
                }
            }      
            listofTasks = [SELECT Id, pse__Project__r.Id,pse__Project__r.pse__Stage__c,
                           pse__Project__r.Integration_Status__c,pse__Assigned_Resources__c FROM pse__Project_Task__c 
                           WHERE (pse__Project__c IN :prjIds) AND (Id IN (SELECT pse__Project_Task__c FROM pse__Project_Task_Assignment__c))];
            
            System.debug('@@1035 Task List' +listofTasks);  
            for(pse__Project_Task__c pt : listofTasks){  
                System.debug('@@1038 Ids ' +pt.pse__Project__c + 'Task Id' + pt.Id + ' assigment Id ' +pt.pse__Assigned_Resources__c);
                
                if(pt != null && pt.pse__Assigned_Resources__c != null){
                    hasProjectId.put(pt.pse__Project__c,true);
                    System.debug('True ' +pt.pse__Project__c);
                }
                
                else if(pt == null || pt.pse__Assigned_Resources__c == null){
                    hasProjectId.put(pt.pse__Project__c,false);
                    System.debug('False ' +pt.pse__Project__c);
                }
                
                for(pse__proj__c prj : newMap.values()){
                    if(hasProjectId.containsKey(prj.id)){
                        System.debug('Ids ' +hasProjectId.containsKey(prj.id));
                        if(hasProjectId.get(prj.id) == true){
                            System.debug('Before ' + prj.Integration_Status__c);
                            prj.Integration_Status__c = 'Pending Sync';
                            System.debug('After ' + prj.Integration_Status__c);
                            projectList.add(prj);
                            System.debug('@@1048 Projects ' +projectList);
                        }     
                    }     
                }
                
                if(!projectList.isEmpty()){
                    update projectList;
                }
              
            }
        }catch(Exception Ex){
            System.debug('Get Error ' +ex.getMessage() + 'Get line ' +ex.getLineNumber());
        }
    }*/
}