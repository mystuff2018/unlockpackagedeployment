/* -----------------------------------------------------------------------------------------------------------------------
Name:       LightningWorkOrderTriggerHandler
Description:  This class contain method that handles work order trigger
Date         Version  Author             Summary of Changes 
-----------  -------  -----------------  ------------------------------------------------------------------------------
Mar-16-2020     1.0    Rodrigo Carpio     Initial Release for Story 8212167
Apr-30-2020     1.1    Rodrigo Carpio     made code adjustment as per INC11614829
Jan-06-2022     1.3    Stephanie/Greice   Added nullifyingScheduleRoute  
-------------------------------------------------------------------------------------------------------------------------- */
public with sharing class LightningWorkOrderTriggerHandler extends TriggerHandler {
    
   /* public Map<Id, WorkOrder> TriggerNewMap {get;set;}
    public Map<Id, WorkOrder> TriggerOldMap {get;set;}
    public List<WorkOrder> TriggerNew {get;set;}
    public List<WorkOrder> TriggerOld {get;set;}
    public boolean relevantRecordsFound;
    
    // added to diffirentiate submitted to non-submitted work order - INC11614829
    public Map<Id, WorkOrder> TriggerNewMapSubmitted {get;set;}
    public Map<Id, WorkOrder> TriggerOldMapSubmitted {get;set;}
    public List<WorkOrder> TriggerNewSubmitted {get;set;}
    public List<WorkOrder> TriggerOldSubmitted {get;set;}
    public boolean relevantSubmittedRecordsFound;
    public boolean relevantSasQueueRecordsFound; //US11738548
    
    // get trigger config
    private static List<Trigger_Handler_Configuration__mdt> triggerConfig;
    
    public LightningWorkOrderTriggerHandler() 
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       LightningWorkOrderTriggerHandler
    Description:  This handles logic needed when the class is initiated
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    Mar-16-2020     1.0    Rodrigo Carpio     Initial Release for Story 8212167
    Oct-22-2020     1.0    Salesforce        Tech Debt - Performance Improvements 9570690
    -------------------------------------------------------------------------------------------------------------------------- */
  /*  {
        // initialize this handler
        if(!this.initializeHandler()) {
            System.Debug('Bypassed Handler -- >' + LightningWorkOrderTriggerHandler.class.getName());
            return;
        }
    }

    public override Boolean initializeHandler()
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       initializeHandler
    Description:  This handles logic needed when the class is initiated
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    Oct-22-2020     1.0    Salesforce        Tech Debt - Performance Improvements 9570690
    -------------------------------------------------------------------------------------------------------------------------- */
 /*   {
        // check if this handler is bypassed
        if(TriggerHandler.isBypassed(LightningWorkOrderTriggerHandler.class.getName())) {
            return false;
        }
        
        // get implicit bypass details from trigger config - static so that query doesn't have to run more than once
        // every trigger handler should use the object api and handler name
        triggerConfig = new List<Trigger_Handler_Configuration__mdt>();
        triggerConfig = [SELECT Id, Record_Type_Name__c, Enable_Implicit_Bypass__c, Implicit_Bypass_Levels__c  
                        FROM Trigger_Handler_Configuration__mdt
                        WHERE
                        Object_API_Name__c =: WorkOrder.sObjectType.getDescribe().getName() AND
                        Handler_Class_Name__c =: LightningWorkOrderTriggerHandler.class.getName() AND 
                        Enable_Implicit_Bypass__c = true LIMIT 1];
        if(triggerConfig != null && triggerConfig.size() > 0) {
            this.IMPLICIT_BYPASS_LEVELS = triggerConfig[0].Implicit_Bypass_Levels__c != null ? (Integer)triggerConfig[0].Implicit_Bypass_Levels__c : this.IMPLICIT_BYPASS_LEVELS;
            this.ENABLE_IMPLICIT_BYPASS = triggerConfig[0].Enable_Implicit_Bypass__c;
        }

        // ensure relevant records are found
        relevantRecordsFound = false;
        relevantSubmittedRecordsFound = false; // added for INC11614829
        relevantSasQueueRecordsFound = false; //US11738548
        filterRecordsByRecordType();
        return true;

    }
    
    public override void beforeInsert() 
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       beforeInsert
    Description:  This handles logic for before insert event
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    Mar-16-2020     1.0    Rodrigo Carpio     Initial Release for Story 8212167
    -------------------------------------------------------------------------------------------------------------------------- */
  /*  {
        // Implement logic here. Execute only if relevantRecordsFound is set to true
        if (relevantRecordsFound)
        {
            ConvergeWODiagnosticTier.PopulateDiagnosticTierValuesMWD(TriggerNew);        
        }
        ConvergeWorkOrderTriggerHandler.updateFSMforDialhome(Trigger.New);
    }
    
    public override void afterInsert() 
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       afterInsert
    Description:  This handles logic for after insert event
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    Mar-16-2020     1.0    Rodrigo Carpio     Initial Release for Story 8212167
    -------------------------------------------------------------------------------------------------------------------------- */
  /*  {
        // Implement logic here. Execute only if relevantRecordsFound is set to true
        if (relevantRecordsFound)
        {
            WorkOrderTriggerHandler.isBeforeUpdate=False;
            WorkOrderTriggerHandler.createAdNotification(TriggerNew);        
        }
    }
    
    public override void beforeUpdate() 
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       beforeUpdate
    Description:  This handles logic for before update event
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    Mar-16-2020     1.0    Rodrigo Carpio     Initial Release for Story 8212167
	May-19-2020     1.1    Rodrigo Carpio     added condition to check for serviceAppointmentTriggerContext
    Apr-15-2020     1.2    Gabriel/Josteir    Added call to update date for new Owner/S&AS fields
    Jan-05-2022     1.3    Stephanie/Greice   Added nullifyingScheduleRoute
    -------------------------------------------------------------------------------------------------------------------------- */
  /*  {
        // check if update is coming service appointment handler
        TriggerHandler.bypassContext(LightningWorkOrderTriggerHandler.class.getName(), this.currentContext());
        if(!LightningServiceAppointmentHandler.serviceAppointmentTriggerContext)
        {
            if (relevantSubmittedRecordsFound){
			 
                if(WorkOrderTriggerHandler.isBeforeUpdate){
                    ConvergeWorkOrderTriggerHandler.updateAddressForShipping(TriggerOldMapSubmitted,TriggerNewSubmitted); 
                }
                ConvergeWorkOrderTriggerHandler.updateWOPartsStatusAcknowledgedDateTime(TriggerOldMapSubmitted, TriggerNewMapSubmitted);
            }
            // Implement logic here. Execute only if relevantRecordsFound is set to true        
            if (relevantRecordsFound)
            {
                ConvergeWODiagnosticTier.PopulateDiagnosticTierValuesBillTo(TriggerNew);

                if(WorkOrderTriggerHandler.isBeforeUpdate){
                    ConvergeWorkOrderTriggerHandler.updateAddressForShipping(TriggerOldMap,TriggerNew);                     
                }
                
                if(WorkOrderTriggerHandler.runonce){
                    WorkOrderTriggerHandler.deleteAlertOnRejectWorkOrder(TriggerOldMap,TriggerNew);        
                                
                    
                }
                
                WorkOrderTriggerHandler.createAdNotification(TriggerNew);  

                WorkOrderTriggerHandler.restrictContactUpdate(TriggerOldMap, TriggerNewMap);
                
                
                
            }    
        }
        TriggerHandler.clearContextBypass(LightningWorkOrderTriggerHandler.class.getName());
        
        if (relevantSubmittedRecordsFound){
            ConvergeWorkOrderTriggerHandler.updateWOPartsLaborStatusUpdate(TriggerOldMapSubmitted, TriggerNewMapSubmitted);
			ConvergeWorkOrderTriggerHandler.createCaseFeed(TriggerOldMapSubmitted, TriggerNewMapSubmitted); // added for DEFECT 9533570																																															  
        	ConvergeWorkOrderTriggerHandler.updateEventTypeOnWorkOrder(TriggerOldMapSubmitted, TriggerNewMapSubmitted);
            ConvergeWorkOrderTriggerHandler.updateEventTypeLaborScheduled(TriggerOldMapSubmitted, TriggerNewMapSubmitted);
            ConvergeWorkOrderTriggerHandler.updateEventTypePendingSiteAccess(TriggerOldMapSubmitted, TriggerNewMapSubmitted);
            WorkOrderTriggerHandler.updateQueueUpdatedDateOnReasonCode(TriggerOldMapSubmitted, TriggerNewMapSubmitted);
            WorkOrderTriggerHandler.updateOwnerUpdatedDateOnOwner(TriggerOldMapSubmitted, TriggerNewMapSubmitted);
            ConvergeWorkOrderTriggerHandler.UpdateSubStatusForOOWWorkOrder(TriggerOldMapSubmitted, TriggerNewMapSubmitted);
        }

        if (relevantSasQueueRecordsFound){
            ConvergeWorkOrderTriggerHandler.nullifyingScheduleRoute(TriggerOldMapSubmitted, TriggerNewMapSubmitted); //US11738548
        }
        
        if (relevantRecordsFound){
			ConvergeWorkOrderTriggerHandler.createCaseFeed(TriggerOldMap, TriggerNewMap);// added for DEFECT 9533570																																												   
        	ConvergeWorkOrderTriggerHandler.updateEventTypeOnWorkOrder(TriggerOldMap, TriggerNewMap);
            ConvergeWorkOrderTriggerHandler.updateEventTypeLaborScheduled(TriggerOldMap, TriggerNewMap);
            ConvergeWorkOrderTriggerHandler.updateEventTypePendingSiteAccess(TriggerOldMap, TriggerNewMap);
            ConvergeWorkOrderTriggerHandler.updateAsMaintainedFlag(TriggerOldMap, TriggerNewMap);
            WorkOrderTriggerHandler.updateQueueUpdatedDateOnReasonCode(TriggerOldMap, TriggerNewMap);
            WorkOrderTriggerHandler.updateOwnerUpdatedDateOnOwner(TriggerOldMap, TriggerNewMap);
            ConvergeWorkOrderTriggerHandler.UpdateSubStatusForOOWWorkOrder(TriggerOldMap, TriggerNewMap);
        }

        // Caue - Sep-03-2020 - Story 9331986
        checkWOStatusTransition();         
        
    }
    
    public override void afterUpdate() 
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       afterUpdate
    Description:  This handles logic for after update event
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    Mar-16-2020     1.0    Rodrigo Carpio     Initial Release for Story 8212167
    May-02-2020     1.1    Rodrigo Carpio     added a condition for INC11614829
	May-19-2020     1.1    Rodrigo Carpio     added condition to check for serviceAppointmentTriggerContext
    -------------------------------------------------------------------------------------------------------------------------- */
   /* {
        // check if update is coming service appointment handler
        TriggerHandler.bypassContext(LightningWorkOrderTriggerHandler.class.getName(), this.currentContext());
        if(!LightningServiceAppointmentHandler.serviceAppointmentTriggerContext)
        {
            // Implement logic here. Execute only if relevantRecordsFound is set to true
            // perform status update logic
            if (relevantSubmittedRecordsFound)
            { // added for INC11614829 
                processPartnerUpdate();
                ConvergeWorkOrderTriggerHandler.UpdateStatusToCancellationRequest(TriggerOldMapSubmitted, TriggerNewMapSubmitted);
            }
            
            if (relevantRecordsFound)
            {
                ConvergeWorkOrderTriggerHandler.UpdateStatusToCancellationRequest(TriggerOldMap, TriggerNewMap);
                
                WorkOrderTriggerHandler.changeFieldEngineerRecordType(TriggerNew, TriggerOldMap);
                
                WorkOrderTriggerHandler.creatServiceEventsForWorkOrder(TriggerNewMap, TriggerOldMap);        
                
                ConvergeHESPartPickupEvent.CreatePartPickupEvent(TriggerNew, TriggerOldMap);  
                
                WorkOrderTriggerHandler.updateLaborDetails(TriggerNewMap, TriggerOldMap); //Story_11438584
            }
        }

        if (relevantSubmittedRecordsFound)   
        {
            ConvergeWorkOrderTriggerHandler.autoSubmitB2CWO(TriggerOldMapSubmitted, TriggerNewMapSubmitted);
            Map<Id, WorkOrder> WorkOrderNewMap = new Map<Id, WorkOrder>();
            for(WorkOrder WorkOrderRecord : TriggerNewMapSubmitted.values())
            {
                if(WorkOrderRecord.Bulk__c == true)
                    WorkOrderNewMap.put(WorkOrderRecord.Id, WorkOrderRecord);
            }
            if(! WorkOrderNewMap.isEmpty())
				/**** Changed as part of Defect 11953819: APJ - DLP assignment Not working in Reporting WO *** on 1 Feb 2022 ***/
                //ConvergeWorkOrderTriggerHandler.updateReportingWOClosure(TriggerOldMapSubmitted, WorkOrderNewMap);
	/*			ConvergeWorkOrderTriggerHandler.updateReportingWOStatus(TriggerOldMapSubmitted, WorkOrderNewMap);
				
                ConvergeWorkOrderTriggerHandler.updateCaseDetails(TriggerNewSubmitted, TriggerOldMapSubmitted);
        }
            
        TriggerHandler.clearContextBypass(LightningWorkOrderTriggerHandler.class.getName());
    }
    
    private void processPartnerUpdate() 
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       processPartnerUpdate
    Description:  This handles the logic to process partner update for submitted work order
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    Mar-16-2020     1.0    Rodrigo Carpio     Initial Release for Story 8212167
    Apr-30-2020     1.1    Rodrigo Carpio     update the use of TriggerNewMap to TriggerNewMapSubmitted INC11614829
    Jun-02-2020     1.2    Rodrigo Carpio     update for STORY 8737594
    -------------------------------------------------------------------------------------------------------------------------- */
  /*  {
        
        if (ConvergeWorkOrderTriggerHandler.runOnce)
        {
            String messageType = 'TradeComplianceUpdate';
            String region = 'AP';
            String subRegion = 'AP';
            Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>();
            Set<Id> workOrderPartsOnlyIds = new Set<Id>();                                            
            List<WorkOrder> workOrders = [SELECT Id, Service_Type__c, DPS_Region__c, DPS_Sub_Region__c, 
                                          MessageTypeID__c, WO_Type__c, DispatchEvent__c,
                                          ShipmentStatus__c, Status, Parts_Status__c, 
                                          Labor_Status__c, subject, LOB__c, DLP_Rejected_Cancellation__c, 
                                          DCCMTEventCode__c, DSP__c, FTCDateTime__c, Sub_Status__c, IsConvergeWorkOrder__c 
                                          FROM WorkOrder WHERE Id IN :TriggerNewMapSubmitted.keySet()];
            // 
            for(WorkOrder wo : TriggerNewMapSubmitted.values()){
                if(wo.MessageTypeID__c == messageType){
                    if(wo.Sub_Status__c != null){
                        workOrderMap.put(wo.Id, wo);
                    }
                }
                else { // added by Rodrigo to handle message type for Parts Only
                    if(!string.isBlank(wo.MessageTypeID__c))
                        workOrderPartsOnlyIds.add(wo.Id);
                }                                                               
            }
            
            if(workOrderPartsOnlyIds.size()>0) // added by Rodrigo to handle message type for Parts Only
            {
                // perform parts status update process for Parts Only
                ConvergeWorkOrderTriggerHandler.performStatusUpdatePartsOnly(workOrderPartsOnlyIds, null);
            }
            
            if(workOrderMap != null && !workOrderMap.isEmpty()){  // logic that handles the trade comliance update
                //TradeCompliand - China
                ConvergeWorkOrderTriggerHandler.ConvergeWorkOrderWrapper convergeWorkOrderWrapper = new ConvergeWorkOrderTriggerHandler.ConvergeWorkOrderWrapper();
                convergeWorkOrderWrapper.oldMap = TriggerOldMapSubmitted;
                convergeWorkOrderWrapper.newMap = workOrderMap;
                ConvergeWorkOrderTriggerHandler.tradeComplianceUpdate(convergeWorkOrderWrapper);
            }
            
            ConvergeWorkOrderTriggerHandler.ConvergeWorkOrderWrapper convergeWorkOrderWrapper = new ConvergeWorkOrderTriggerHandler.ConvergeWorkOrderWrapper();
            convergeWorkOrderWrapper.oldMap = TriggerOldMapSubmitted;
            convergeWorkOrderWrapper.newMap = TriggerNewMapSubmitted;
            ConvergeWorkOrderTriggerHandler.performStatusUpdate(convergeWorkOrderWrapper);  
            
            ConvergeWorkOrderTriggerHandler.updateFieldEngineers(TriggerNewSubmitted, TriggerOldMapSubmitted);
            //Added by Roshani Kesarwani
        //    ConvergeWorkOrderTriggerHandler.updateDispatchInstruction(TriggerNewMapSubmitted, TriggerOldMapSubmitted);
        }
        
        // added for STORY 8737594
        ConvergeWorkOrderTriggerHandler.performPartsStatusRejectionCheck(TriggerNewSubmitted, TriggerOldMapSubmitted);
    }
    
    private static List<String> getTriggerHandlerConfig(String APIName, String HandlerName) 
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       getTriggerHandlerConfig
    Description:  This pulls the configured metadata base on object name and class handler
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    Mar-16-2020     1.0    Rodrigo Carpio     Initial Release for Story 8212167
    -------------------------------------------------------------------------------------------------------------------------- */
   /* { 
        List<String> listRecordTypeNames = new List<String>();
        for(Trigger_Handler_Configuration__mdt config :[SELECT Id, Record_Type_Name__c FROM Trigger_Handler_Configuration__mdt
                                                        WHERE
                                                        Object_API_Name__c = :APIName AND
                                                        Handler_Class_Name__c = :HandlerName])
        {
            listRecordTypeNames.add(config.Record_Type_Name__c);
        }
        if(listRecordTypeNames.size() > 0)
            return listRecordTypeNames;
        return null;
    }
    
    private static Id getRecordTypeId(String name, Map<String, Schema.RecordTypeInfo> recordTypeMap)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       getRecordTypeId
    Description:  This pulls the list of record type name
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    Mar-16-2020     1.0    Rodrigo Carpio     Initial Release for Story 8212167
    -------------------------------------------------------------------------------------------------------------------------- */
  /*  {
        Schema.RecordTypeInfo recordTypeInfo = recordTypeMap.get(name);
        if(recordTypeInfo != null)
        {
            return recordTypeInfo.getRecordTypeId();
        }
        
        return null;
    }
    
    public static Set<Id> getRecordTypeIds(List<String> recordTypeNames)
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       getRecordTypeIds
    Description:  This gets the list of record type id base on list of names
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    Mar-16-2020     1.0    Rodrigo Carpio     Initial Release for Story 8212167
    -------------------------------------------------------------------------------------------------------------------------- */
 /*   {
        Set<Id> ffRecordTypes = new Set<Id>();
        if(recordTypeNames == null)
            return ffRecordTypes;
        
        Map<String, Schema.RecordTypeInfo> recordTypeMap = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName();
        
        for(String recordTypeName :recordTypeNames)
        {
            Id recordTypeId = getRecordTypeId(recordTypeName, recordTypeMap);
            if(recordTypeId != null)
                ffRecordTypes.add(recordTypeId);
        }
        
        return ffRecordTypes;
    }
    
    private void filterRecordsByRecordType() 
    /* -----------------------------------------------------------------------------------------------------------------------
    Name:       filterRecordsByRecordType
    Description:  This method handles the filtering of data base on record type
    Date         Version  Author             Summary of Changes 
    -----------  -------  -----------------  ------------------------------------------------------------------------------
    Mar-16-2020     1.0    Rodrigo Carpio     Initial Release for Story 8212167
    Apr-30-2020     1.1    Rodrigo Carpio     made code adjustment as per INC11614829  
    -------------------------------------------------------------------------------------------------------------------------- */
/*    {
        
        // Filter records by record types that belong to Lightning and store it in the local variables here
        // set relevantRecordsFound to true if Lightning related records are passed in the trigger context
        // Note: Store the lightning related record type developer names in the Custom Settings and use that for filtering. DO NOT hardcode them here.
        //There already is a custom setting that is created for this - Trigger_Handler_Configuration__mdt
        Set<Id> woRecordTypes = getRecordTypeIds(getTriggerHandlerConfig('WorkOrder', LightningWorkOrderTriggerHandler.class.getName()));
        Boolean hasWORT = false;
        Boolean hasOtherRT = false;
                
        this.TriggerNewMap = new Map<Id, WorkOrder>();
        this.TriggerOldMap = new Map<Id, WorkOrder>();
        this.TriggerNew = new List<WorkOrder>();
        this.TriggerOld = new List<WorkOrder>();
        
        // pulls the value of submitted record type name configure in label INC11614829
        //string submittedTypeId = (Test.isRunningTest()) ? 'Submitted' : Label.WO_Submitted_Record_Type;
        string submittedTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get(Label.WO_Submitted_Record_Type).getRecordTypeId();
        string sasTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('S&AS Reactive Queue').getRecordTypeId();
        // added to diffirentiate submitted to non-submitted work order INC11614829
        this.TriggerNewMapSubmitted = new Map<Id, WorkOrder>();
        this.TriggerOldMapSubmitted = new Map<Id, WorkOrder>();
        this.TriggerNewSubmitted = new List<WorkOrder>();
        this.TriggerOldSubmitted = new List<WorkOrder>();
        
        
        //mount triggerNewMap
        if(Trigger.NewMap != null) {
            for (Id woId : Trigger.NewMap.keySet()) {
                WorkOrder woNew = (WorkOrder) Trigger.newMap.get(woId);
                if (woRecordTypes.contains(woNew.RecordTypeId)) {
                    hasWORT = true;
                    
                    // added the check for record type name INC11614829                    
                    if (submittedTypeId == woNew.RecordTypeId) {
                        relevantSubmittedRecordsFound = true;
                        this.TriggerNewMapSubmitted.put(woId, woNew);   
                    } else if (sasTypeId == woNew.RecordTypeId) {   
                        relevantSubmittedRecordsFound = true; 
                        relevantSasQueueRecordsFound = true;
                        this.TriggerNewMapSubmitted.put(woId, woNew);
                    } else {
                        relevantRecordsFound=true;
                        this.TriggerNewMap.put(woId, woNew);
                    }
                    	
                } else hasOtherRT = true;
            }
        }
        
        //mount triggerNew
        if(Trigger.New != null) {
            for (WorkOrder woNew : (List<WorkOrder>)Trigger.New) {
                if (woRecordTypes.contains(woNew.RecordTypeId)) {
                    hasWORT = true;
                    
                    // added the check for record type name INC11614829                    
                    if (submittedTypeId == woNew.RecordTypeId) {
						relevantSubmittedRecordsFound = true;
                        this.TriggerNewSubmitted.add(woNew);    
                    } else if(sasTypeId == woNew.RecordTypeId) {   
                        relevantSubmittedRecordsFound = true; 
                        relevantSasQueueRecordsFound = true;
                        this.TriggerNewSubmitted.add(woNew); 
                    } else {
                        relevantRecordsFound=true;
                        this.TriggerNew.add(woNew);
                    }                    	
                } else hasOtherRT = true;
            }
        }
        
        //mount triggerOldMap
		// Changed for the defect 9185486, Check the RecordType from Trigger.newMap and not from Trigger.oldMap - Partha
        if(Trigger.OldMap != null) {
            for (Id woId : Trigger.OldMap.keySet()) {
                WorkOrder woOld = (WorkOrder) Trigger.OldMap.get(woId);
                WorkOrder woNew = (WorkOrder) Trigger.NewMap.get(woId);
                if (woRecordTypes.contains(woOld.RecordTypeId) || this.TriggerNewMap.keySet().contains(woId)) {
                    hasWORT = true;
                    
                    // added the check for record type name INC11614829                    
                    if (submittedTypeId == woNew.RecordTypeId) {
                        relevantSubmittedRecordsFound = true;
                        this.TriggerOldMapSubmitted.put(woId, woOld);    
                    } else if(sasTypeId == woNew.RecordTypeId) {   
                        relevantSubmittedRecordsFound = true; 
                        relevantSasQueueRecordsFound = true;
                        this.TriggerOldMapSubmitted.put(woId, woOld);   
                    } else {
                        relevantRecordsFound=true;
                        this.TriggerOldMap.put(woId, woOld);
                    }                    	
                } else hasOtherRT = true;
            }
        }
        
        //mount triggerOld
        if(Trigger.Old != null) {
            for (WorkOrder woOld : (List<WorkOrder>)Trigger.Old) {
                if (woRecordTypes.contains(woOld.RecordTypeId) || this.TriggerNewMap.keySet().contains(woOld.Id)) {
                    hasWORT = true;
                    
                    // added the check for record type name INC11614829                    
                    if (submittedTypeId == woOld.RecordTypeId) {
                        relevantSubmittedRecordsFound = true;
                        this.TriggerOldSubmitted.add(woOld);                           
                    } else if(sasTypeId == woOld.RecordTypeId) {   
                        relevantSubmittedRecordsFound = true; 
                        relevantSasQueueRecordsFound = true;
                        this.TriggerOldSubmitted.add(woOld); 
                    } else {
                        relevantRecordsFound=true;
                        this.TriggerOld.add(woOld);
                    }                    	
                } else hasOtherRT = true;
            }
        }
        
        if(hasWORT)
            system.debug('Continue with this handler. Other handlers should be bypassed.');
        else if(!hasWORT && hasOtherRT)
            TriggerHandler.bypass(LightningWorkOrderTriggerHandler.class.getName());
    }
    
    // Caue - Sep-03-2020 - Story 9331986
    // Caue - Oct-15-2020 - Story 9247737   
    // Method for checking if there is a Status change, and check if the Status Transition is valid
    private void checkWOStatusTransition()
    {   
        try
        {        
            Map<Id, WorkOrder> woNewMap = (relevantSubmittedRecordsFound) ? this.TriggerNewMapSubmitted : this.TriggerNewMap;
            Map<Id, WorkOrder> woOldMap = (relevantSubmittedRecordsFound) ? this.TriggerOldMapSubmitted : this.TriggerOldMap;
            String woValidStatus;
            Integer woPositionInList;
            Boolean doQuery = true;
            Boolean wo2Check = false;
            Boolean woPartsStatusRejectionCheck = false;
            Boolean doPartsStatusRejectionQuery = true;
            List<Dispatch_Labor_Parts_Status_Setup__c> dispatchStatusTransitions;            
            Map<Id, Map<String, Boolean>> wo2CheckDispatch = new Map<Id, Map<String, Boolean>>();
            Map<Id, Map<String, Boolean>> wo2CheckLabor = new Map<Id, Map<String, Boolean>>(); 
            Map<Id, Map<String, Boolean>> wo2CheckPart = new Map<Id, Map<String, Boolean>>(); 
            Map<Id, Map<String, Boolean>> wo2PartsStatusRejectionCheck = new Map<Id, Map<String, Boolean>>();  
            Map<Id, WorkOrder> workOrderPartsStatusRejectionMap = new Map<Id, WorkOrder>();
            
            for(WorkOrder newWorkOrderRecord : woNewMap.values()) 
            {
                if(string.isEmpty(newWorkOrderRecord.DispatchNumber__c))
                { 
                    
                    // Check if is needed verify WO Status Transition
                    if (woOldMap.get(newWorkOrderRecord.Id).Status != newWorkOrderRecord.Status)
                    {                             
                        wo2CheckDispatch.put(newWorkOrderRecord.Id, new Map<String, Boolean>{'Dispatch' => true});
                        wo2Check = true;
                    }

                    // Check if is needed verify Labor Status Transition
                    if (woOldMap.get(newWorkOrderRecord.Id).Labor_Status__c != newWorkOrderRecord.Labor_Status__c)
                    {                
                        wo2CheckLabor.put(newWorkOrderRecord.Id, new Map<String, Boolean>{'Labor' => true});
                        wo2Check = true;
                    }

                    // Check if is needed verify Part Status Transition
                    if (woOldMap.get(newWorkOrderRecord.Id).Parts_Status__c != newWorkOrderRecord.Parts_Status__c)
                    {                
                        wo2CheckPart.put(newWorkOrderRecord.Id, new Map<String, Boolean>{'Part' => true});
                        wo2Check = true;
                    }
                    
                    // Check if is needed verify Parts Status Rejection Check
                    if (!woPartsStatusRejectionCheck && (newWorkOrderRecord.Service_Type__c == 'Parts Only' || newWorkOrderRecord.Service_Type__c == 'Parts and Labor'))
                    {
                        if(doPartsStatusRejectionQuery){
                            workOrderPartsStatusRejectionMap = new Map<Id, WorkOrder>([SELECT Id, LastModifiedBy.Profile.Name FROM WorkOrder WHERE Id IN :woNewMap.keySet()]);
                            doPartsStatusRejectionQuery = false;
                        }
                        if(woOldMap.get(newWorkOrderRecord.Id).Parts_Status__c == 'Cancellation Request' && workOrderPartsStatusRejectionMap.get(newWorkOrderRecord.Id).LastModifiedBy.Profile.Name == 'Service Integration Profile' && 
                           (newWorkOrderRecord.MessageTypeID__c == 'PartsOrderConfirmation' || newWorkOrderRecord.MessageTypeID__c == 'PartsStatusUpdate' || newWorkOrderRecord.MessageTypeID__c == 'PartsOrderStatusUpdate')){
                               wo2PartsStatusRejectionCheck.put(newWorkOrderRecord.Id, new Map<String, Boolean>{'PartsStatus' => true});
                               woPartsStatusRejectionCheck = true;
                           }
                    }
                    
                    if(woPartsStatusRejectionCheck){
                        // If WO Parts Status is cancellation request and receive next parts status update
                        if((wo2PartsStatusRejectionCheck.size() > 0) && wo2PartsStatusRejectionCheck.get(newWorkOrderRecord.Id) != null)
                        {             
        
                            // =================Set the correct Parts Status in the Maps=======================    
                            String partsStaus = 'Cancellation Rejected';         
        
                            if (this.TriggerNewMap.containsKey(newWorkOrderRecord.Id)){
                                this.TriggerNewMap.get(newWorkOrderRecord.Id).Parts_Status__c = partsStaus;
                            }
        
                            if (this.TriggerNewMapSubmitted.containsKey(newWorkOrderRecord.Id)){
                                this.TriggerNewMapSubmitted.get(newWorkOrderRecord.Id).Parts_Status__c = partsStaus;
                            }
                            
                            // Get the position of the current WO record in the list "TriggerNew"
                            woPositionInList = this.TriggerNew.indexOf(newWorkOrderRecord);
                            
                            // If current WO is found in list "TriggerNew", then update the correct Status
                            if (woPositionInList != -1){
                                this.TriggerNew.get(woPositionInList).Parts_Status__c = partsStaus;
                            }
        
                            // Get the position of the current WO record in the list "TriggerNewSubmitted"
                            woPositionInList = this.TriggerNewSubmitted.indexOf(newWorkOrderRecord);
        
                            // If current WO is found in list "TriggerNewSubmitted", then update the correct Status
                            if (woPositionInList != -1){
                                this.TriggerNewSubmitted.get(woPositionInList).Parts_Status__c = partsStaus;
                            }                         
                        }
                    }

                    // Check if there is WO or Labor Status transition                
                    if (wo2Check)
                    {
                        // Control If query is already done, and not query again and again for each WO
                        // It is inside the above IF, because the code will be performed only if Status is being changed
                        if(doQuery)
                        {    
                            // Get the valid status transitions from "Dispatch_Labor_Parts_Status_Setup__c" (Dispatch Labor Parts Status Setup)
                            dispatchStatusTransitions = [SELECT Status_Transition__c, Type__c, Valid_Transition__c 
                                                        FROM Dispatch_Labor_Parts_Status_Setup__c
                                                        WHERE Type__c IN ('Dispatch', 'Labor', 'Parts')];
                            
                            doQuery = false;
                        }

                        
                        // If WO Status has changed
                        if(wo2CheckDispatch != null && wo2CheckDispatch.size() > 0 && wo2CheckDispatch.get(newWorkOrderRecord.Id) != null)
                        {
                            // Call method to check if it is a valid status transtion. Status transition has to be found in "Dispatch_Labor_Parts_Status_Setup__c" (Dispatch Labor Parts Status Setup)
                            woValidStatus = ConvergeWorkOrderTriggerHandler.checkWOStatusTransition('Dispatch', woOldMap.get(newWorkOrderRecord.Id).Status, newWorkOrderRecord, dispatchStatusTransitions);                    
        
                            if (this.TriggerNewMap.containsKey(newWorkOrderRecord.Id)){
                                this.TriggerNewMap.get(newWorkOrderRecord.Id).Status = woValidStatus;
                            }
        
                            if (this.TriggerNewMapSubmitted.containsKey(newWorkOrderRecord.Id)){
                                this.TriggerNewMapSubmitted.get(newWorkOrderRecord.Id).Status = woValidStatus;
                            }
                                    
                            // Get the position of the current WO record in the list "TriggerNew"
                            woPositionInList = this.TriggerNew.indexOf(newWorkOrderRecord);
                            
                            // If current WO is found in list "TriggerNew", then update the correct Status
                            if (woPositionInList != -1){
                                this.TriggerNew.get(woPositionInList).Status = woValidStatus;
                            }
        
                            // Get the position of the current WO record in the list "TriggerNewSubmitted"
                            woPositionInList = this.TriggerNewSubmitted.indexOf(newWorkOrderRecord);
        
                            // If current WO is found in list "TriggerNewSubmitted", then update the correct Status
                            if (woPositionInList != -1){
                                this.TriggerNewSubmitted.get(woPositionInList).Status = woValidStatus;
                            } 
                        }

                        // If WO Labor Status has changed
                        if((wo2CheckLabor.size() > 0) && wo2CheckLabor.get(newWorkOrderRecord.Id) != null)
                        {
                            // Call method to check if it is a valid status transtion. Status transition has to be found in "Dispatch_Labor_Parts_Status_Setup__c" (Dispatch Labor Parts Status Setup)
                            woValidStatus = ConvergeWorkOrderTriggerHandler.checkWOStatusTransition('Labor', woOldMap.get(newWorkOrderRecord.Id).Labor_Status__c, newWorkOrderRecord, dispatchStatusTransitions);               
        
                            // =================Set the correct Labor Status in the Maps=======================                    
        
                            if (this.TriggerNewMap.containsKey(newWorkOrderRecord.Id)){
                                this.TriggerNewMap.get(newWorkOrderRecord.Id).Labor_Status__c = woValidStatus;
                            }
        
                            if (this.TriggerNewMapSubmitted.containsKey(newWorkOrderRecord.Id)){
                                this.TriggerNewMapSubmitted.get(newWorkOrderRecord.Id).Labor_Status__c = woValidStatus;
                            }
                            
                            // Get the position of the current WO record in the list "TriggerNew"
                            woPositionInList = this.TriggerNew.indexOf(newWorkOrderRecord);
                            
                            // If current WO is found in list "TriggerNew", then update the correct Status
                            if (woPositionInList != -1){
                                this.TriggerNew.get(woPositionInList).Labor_Status__c = woValidStatus;
                            }
        
                            // Get the position of the current WO record in the list "TriggerNewSubmitted"
                            woPositionInList = this.TriggerNewSubmitted.indexOf(newWorkOrderRecord);
        
                            // If current WO is found in list "TriggerNewSubmitted", then update the correct Status
                            if (woPositionInList != -1){
                                this.TriggerNewSubmitted.get(woPositionInList).Labor_Status__c = woValidStatus;
                            }                         
                        }

                        // If WO Part Status has changed
                        if((wo2CheckPart.size() > 0) && wo2CheckPart.get(newWorkOrderRecord.Id) != null)
                        {
                            // Call method to check if it is a valid status transtion. Status transition has to be found in "Dispatch_Labor_Parts_Status_Setup__c" (Dispatch Labor Parts Status Setup)
                            woValidStatus = ConvergeWorkOrderTriggerHandler.checkWOStatusTransition('Parts', woOldMap.get(newWorkOrderRecord.Id).Parts_Status__c, newWorkOrderRecord, dispatchStatusTransitions);               
        
                            // =================Set the correct Labor Status in the Maps=======================                    
        
                            if (this.TriggerNewMap.containsKey(newWorkOrderRecord.Id)){
                                this.TriggerNewMap.get(newWorkOrderRecord.Id).Parts_Status__c = woValidStatus;
                            }
        
                            if (this.TriggerNewMapSubmitted.containsKey(newWorkOrderRecord.Id)){
                                this.TriggerNewMapSubmitted.get(newWorkOrderRecord.Id).Parts_Status__c = woValidStatus;
                            }
                            
                            // Get the position of the current WO record in the list "TriggerNew"
                            woPositionInList = this.TriggerNew.indexOf(newWorkOrderRecord);
                            
                            // If current WO is found in list "TriggerNew", then update the correct Status
                            if (woPositionInList != -1){
                                this.TriggerNew.get(woPositionInList).Parts_Status__c = woValidStatus;
                            }
        
                            // Get the position of the current WO record in the list "TriggerNewSubmitted"
                            woPositionInList = this.TriggerNewSubmitted.indexOf(newWorkOrderRecord);
        
                            // If current WO is found in list "TriggerNewSubmitted", then update the correct Status
                            if (woPositionInList != -1){
                                this.TriggerNewSubmitted.get(woPositionInList).Parts_Status__c = woValidStatus;
                            }                         
                        }
                    } 
                }
            } 
        } 
        catch(Exception e){            
            ExceptionHandler.logHandledExceptions(e, 'LightningWorkOrderTriggerHandler', 'checkWOStatusTransition', 'Converge Dispatch');              
        }
	}*/
}