/* -----------------------------------------------------------------------------------------------------------------------
Class Name:       WorkOrderTrigger
Description:           
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author               Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
               1.0                                  Initial Release
12/20/2018     1.1      Rayana Alencar              Adding the call for creation of Accidental Damage Notification
04/04/2019     1.2      Israel Agostinho            Fix defect 6279329
04/04/2019     1.3      Akhil VM                    User Story : 6152610
06/18/2019     1.4     Rodrigo Carpio               changes for DEFECT 6821559
04/10/2019     1.5     Ramzil Cleopas               US 7339014 Added logic to add Event Code for Service Events
Mar-16-2020    1.6     Rodrigo Carpio               move the lightning work order logic for Story 8212167
-------------------------------------------------------------------------------------------------------------------------- 
*/


// tdavis 2018-01-03 - added after update
trigger WorkOrderTrigger on WorkOrder (before update, before insert, after insert, after update)
{
    //decouple of FinancialForce Trigger
    //new FFWorkOrderTriggerHandler().run();
    TriggerHandlerRunner.HandlerRunnerClass('FFWorkOrderTriggerHandler');

    //TODO: decouple of Lightning Trigger
    // Lightning Trigger Handler – only execute if the Custom Setting allows trigger execution on WO
    if(!(Trigger_Execution_Control__c.getInstance().Skip_WorkOrder_Trigger__c) && !(NonAgentWoCreationController.nonagentWoflag))
    {
        //new LightningWorkOrderTriggerHandler().run(); // added for Story 8212167
    }
    
    /*
    if(UserInfo.getUserName() != 'service_interface_user_data@dell.com.dellservices'){
        List<String> cityList = new List<String>();
        Map<String,Id> mapofcityname = new Map<String,Id>();
        
        if(Trigger.isInsert && Trigger.isBefore){
            ConvergeWODiagnosticTier.PopulateDiagnosticTierValuesMWD(Trigger.New); // move to LightningWorkOrderTriggerHandler
        }
        
        if(Trigger.isBefore && Trigger.isUpdate){
            ConvergeWODiagnosticTier.PopulateDiagnosticTierValuesBillTo(Trigger.New); // move to LightningWorkOrderTriggerHandler
        }
        
        
        if(!(Trigger_Execution_Control__c.getInstance().Skip_WorkOrder_Trigger__c)){
            Boolean isConvergeWorkOrder = false;
            if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
                List<WorkOrder> convergeWorkOrders = [SELECT IsConvergeWorkOrder__c, EMC_Asset_Identifier__c 
                                    FROM WorkOrder WHERE Id IN: Trigger.new LIMIT 1]; 
                for(WorkOrder wo : convergeWorkOrders){
                    if(wo.IsConvergeWorkOrder__c){
                        isConvergeWorkOrder = true;
                    }
                }
            }
            if(isConvergeWorkOrder){
                if(Trigger.isAfter && Trigger.isUpdate && ConvergeWorkOrderTriggerHandler.runOnce){
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
                                                                            FROM WorkOrder WHERE Id IN :Trigger.newMap.keySet()];
                    for(WorkOrder wo : Trigger.newMap.values()){
                        if(wo.MessageTypeID__c == messageType){
                            if(wo.DPS_Region__c.equalsIgnoreCase(region) && wo.DPS_Sub_Region__c.equalsIgnoreCase(subRegion) && wo.Sub_Status__c != null){
                                workOrderMap.put(wo.Id, wo);
                            }
                        }
                        else { // added by Rodrigo to handle message type for Parts Only
                                if(!string.isBlank(wo.MessageTypeID__c))
                                    workOrderPartsOnlyIds.add(wo.Id);
                            }                                                               
                    }
                    system.debug('workOrderPartsOnlyIds ' + workOrderPartsOnlyIds);
                    if(workOrderPartsOnlyIds.size()>0) // added by Rodrigo to handle message type for Parts Only
                    {
                        // perform parts status update process for Parts Only
                        ConvergeWorkOrderTriggerHandler.performStatusUpdatePartsOnly(workOrderPartsOnlyIds, null);
                    }
                    
                    if(workOrderMap != null && !workOrderMap.isEmpty()){
                        //TradeCompliand - China
                        ConvergeWorkOrderTriggerHandler.ConvergeWorkOrderWrapper convergeWorkOrderWrapper = new ConvergeWorkOrderTriggerHandler.ConvergeWorkOrderWrapper();
                        convergeWorkOrderWrapper.oldMap = Trigger.oldMap;
                        convergeWorkOrderWrapper.newMap = workOrderMap;
                        ConvergeWorkOrderTriggerHandler.tradeComplianceUpdate(convergeWorkOrderWrapper);
                    }
                    ConvergeWorkOrderTriggerHandler.updateFieldEngineers(Trigger.New, Trigger.oldMap);
                }
                if(Trigger.isAfter && Trigger.isUpdate && ConvergeWorkOrderTriggerHandler.runOnce){
                    ConvergeWorkOrderTriggerHandler.ConvergeWorkOrderWrapper convergeWorkOrderWrapper = new ConvergeWorkOrderTriggerHandler.ConvergeWorkOrderWrapper();
                    convergeWorkOrderWrapper.oldMap = Trigger.oldMap;
                    convergeWorkOrderWrapper.newMap = Trigger.newMap;
                    ConvergeWorkOrderTriggerHandler.performStatusUpdate(convergeWorkOrderWrapper);                        
                }
            }
            if(Trigger.isBefore && Trigger.isInsert) // will be removed from the current code
            {
                //WorkOrderTriggerHandler.PopulateCityLookup(Trigger.new);
                WorkOrderTriggerHandler.mapLatamCountryStateonInsert(Trigger.new);
                //WorkOrderTriggerHandler.populateLatamAddressfields(Trigger.new);
                
                map<Id, WorkOrder> mapNew;
                mapNew = new map<Id, WorkOrder>();
                for(WorkOrder o : trigger.new){
                    system.debug('o ' + o);
                    mapNew.put(o.Id, o);
                }
                if(!(Trigger_Execution_Control__c.getInstance().Skip_WO_RecordType_Update__c))
                    WorkOrderTriggerHandler.setRecordType(Trigger.oldMap, mapNew, false); // prod issue
            }
            
            if(Trigger.isAfter && Trigger.isInsert){
                WorkOrderTriggerHandler.populateLatamAddressfields(Trigger.new); // will be removed from the current code
                WorkOrderTriggerHandler.isBeforeUpdate=False; // move to LightningWorkOrderTriggerHandler
                try{
                    //handle the AD Notifications  
                    WorkOrderTriggerHandler.createAdNotification(Trigger.new);  // move to LightningWorkOrderTriggerHandler
                } catch (Exception ex){
                    ExceptionHandler.logHandledExceptions(ex,'WorkOrderTrigger','createAdNotification','WorkOrderTriggerHandler');
                }
            }
            
            if(Trigger.isBefore && Trigger.isUpdate){
                // rodrigo added for converge stories(6270324/7241240/7278849)
                if(WorkOrderTriggerHandler.isBeforeUpdate){
                    ConvergeWorkOrderTriggerHandler.updateAddressForShipping(Trigger.oldMap,Trigger.new);  // move to LightningWorkOrderTriggerHandler
                }
                
                //Call Helper.
                if(WorkOrderTriggerHandler.runonce){
                    Boolean isNotConvergeWorkOrder = false;
                    Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>();
                    List<WorkOrder> convergeWorkOrders = [SELECT MessageTypeID__c, IsConvergeWorkOrder__c, EMC_Asset_Identifier__c 
                                        FROM WorkOrder WHERE Id IN: Trigger.new LIMIT 1]; 
                    for(WorkOrder wo : convergeWorkOrders){
                        if(!wo.IsConvergeWorkOrder__c){
                            isNotConvergeWorkOrder = true;
                        }
                        //if(wo.MessageTypeID__c == 'BreakFixCancelConfirmation' || wo.MessageTypeID__c == 'SvcCallCancelConfirmation'){
                        //    workOrderMap.put(wo.Id, wo);
                        //}
                    }
                    //if(isNotConvergeWorkOrder || (workOrderMap != null && !workOrderMap.isEmpty())){
                    if(isNotConvergeWorkOrder){
                        WorkOrderTriggerHandler.updateRegionIdonWorkOrder(Trigger.oldMap, Trigger.newMap); // will be removed from the current code
                    }
                    //WorkOrderTriggerHandler.populateCities(Trigger.new,Trigger.oldMap);
                    //WorkOrderTriggerHandler.updateAddressonLatamUpdate(Trigger.oldMap,Trigger.new);
                    WorkOrderTriggerHandler.deleteAlertOnRejectWorkOrder(Trigger.oldMap,Trigger.new); // will be removed from the current code
                    
                // WorkOrderTriggerHandler.PopulateCityandStateLatam(Trigger.new,Trigger.oldMap);
                
                DispatchInternationalAddessValidation.checkInternationalAddressUpdate(Trigger.new, Trigger.oldMap); // will be removed from the current code
                     
            }
                
                
            
            
                WorkOrderTriggerHandler.updateWOPartsLaborStatusUpdate(Trigger.oldMap, Trigger.newMap); // DEFECT 6821559
                if(!(Trigger_Execution_Control__c.getInstance().Skip_WO_RecordType_Update__c)) // will be removed from the current code
                    WorkOrderTriggerHandler.setRecordType(Trigger.oldMap, Trigger.newMap, true); // prod issue 
                //handle the AD Notifications  
                try{
                    //handle the AD Notifications  
                    WorkOrderTriggerHandler.createAdNotification(Trigger.new);  // move to LightningWorkOrderTriggerHandler     
                } catch (Exception ex){
                    ExceptionHandler.logHandledExceptions(ex,'WorkOrderTrigger','createAdNotification','WorkOrderTriggerHandler');
                }
                
                WorkOrderTriggerHandler.restrictContactUpdate( Trigger.OldMap, Trigger.newMap );  // move to LightningWorkOrderTriggerHandler
            }
        }

        if(Trigger.isUpdate && Trigger.isAfter)
        {
            WorkOrderTriggerHandler.changeFieldEngineerRecordType(Trigger.new, Trigger.OldMap);  // move to LightningWorkOrderTriggerHandler
            WorkOrderTriggerHandler.creatServiceEventsForWorkOrder(Trigger.newMap, Trigger.oldMap);  // move to LightningWorkOrderTriggerHandler
        }


        if (Trigger.isBefore) {
            for(WorkOrder wo : Trigger.New) {
                if (Trigger.isUpdate) {
                    //For Manual Reprocess Approved Workorders
                    if(wo.WO_Type__c == 'Break Fix')
                        DispatchWorkOrderClassManualReprocess.ResubmitApprovedWorkOrder(Trigger.New, Trigger.OldMap);  // move to LightningWorkOrderTriggerHandler
                }
            }
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        ConvergeHESPartPickupEvent.CreatePartPickupEvent(Trigger.New, Trigger.OldMap);   // move to LightningWorkOrderTriggerHandler
    }
    */
    /*------Akhil : May 0502 - calling method to populate Address fields--------- moved from isBefore and isUpdate */
            //if(WorkOrderTriggerHandler.isBeforeUpdate){
            //    WorkOrderTriggerHandler.updateGSCVAddress(Trigger.new,Trigger.old);
            //}
            /*----Akhil Ends : May 0502----*/
}