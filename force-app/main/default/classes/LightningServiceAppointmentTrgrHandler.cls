// /* -----------------------------------------------------------------------------------------------------------------------
// Name:       LightningServiceAppointmentTrgrHandler
// Description:  This class contain method that handles service appointment trigger
// Date         Version  Author             Summary of Changes 
// -----------  -------  -----------------  ------------------------------------------------------------------------------
// Mar-18-2020     1.0    Rodrigo Carpio       Initial Release for Story 8252798 
// Mar-31-2020     2.0    Partha                Edited to call the method updateLaborStatus in ServiceAppontment for US 7800093
// Apr-01-2020     3.0    Partha            Edited to call the method woInPlannedQueue in ServiceAppontment for US 7696366
// Apr-24-2020     4.0    Shivani               Edited to call the method updateFieldEngineer in ServiceAppontment for defect 8428834 

// -------------------------------------------------------------------------------------------------------------------------- */
 public class LightningServiceAppointmentTrgrHandler extends TriggerHandler {
//     public Map<Id, ServiceAppointment> TriggerNewMap {get;set;}
//     public Map<Id, ServiceAppointment> TriggerOldMap {get;set;}
//     public List<ServiceAppointment> TriggerNew {get;set;}
//     public List<ServiceAppointment> TriggerOld {get;set;}
//     public static boolean serviceAppointmentTriggerContext = false;
//     public boolean relevantRecordsFound;
//     Boolean isConvergeWorkOrder = false;
//     public LightningServiceAppointmentTrgrHandler() 
//     /* -----------------------------------------------------------------------------------------------------------------------
//     Name:       LightningWorkOrderTriggerHandler
//     Description:  This handles logic needed when the class is initiated
//     Date         Version  Author             Summary of Changes 
//     -----------  -------  -----------------  ------------------------------------------------------------------------------
//     Mar-18-2020     1.0    Rodrigo Carpio     Initial Release for Story 8252798
//     -------------------------------------------------------------------------------------------------------------------------- */
//     {
//         serviceAppointmentTriggerContext = true;
//         relevantRecordsFound = false;
//         filterRecordsByRecordType();
//     }
    
//     public override void beforeInsert() 
//     /* -----------------------------------------------------------------------------------------------------------------------
//     Name:       beforeInsert
//     Description:  This handles logic for before insert event
//     Date         Version  Author             Summary of Changes 
//     -----------  -------  -----------------  ------------------------------------------------------------------------------
//     Mar-18-2020     1.0    Rodrigo Carpio     Initial Release for Story 8252798
//     -------------------------------------------------------------------------------------------------------------------------- */
//     {
//         // Implement logic here. Execute only if relevantRecordsFound is set to true
//         //processServiceAppointmentRecord();
//     }
    
//     public override void afterInsert()
//     /* -----------------------------------------------------------------------------------------------------------------------
//     Name:       afterInsert
//     Description:  This handles logic for after insert event
//     Date         Version  Author             Summary of Changes 
//     -----------  -------  -----------------  ------------------------------------------------------------------------------
//     Mar-18-2020     1.0    Rodrigo Carpio     Initial Release for Story 8252798
//     -------------------------------------------------------------------------------------------------------------------------- */
//     {
//         // Implement logic here. Execute only if relevantRecordsFound is set to true
//         if (relevantRecordsFound)
//         {
//             if (ServiceAppointmentHandler.runOnce) {
//                 Map<Id, ServiceAppointment> serviceAppointmentMap = new Map<Id, ServiceAppointment>();
//                 Map<Id, ServiceAppointment> serviceAppointmentHelperMap = new Map<Id, ServiceAppointment>();
//                 ServiceAppointmentHandler.ConvergeServiceAppointmentWrapper convergeServiceAppointmentWrapper = new ServiceAppointmentHandler.ConvergeServiceAppointmentWrapper();
//                 List<ServiceAppointment> serviceAppointments = [SELECT Id, Work_Order__c, Reject_Reason__c, Event_Type__c   
//                                                                 FROM ServiceAppointment WHERE Id IN :TriggerNewMap.keySet()];
//                 for(ServiceAppointment serviceAppt : serviceAppointments){
//                     if(serviceAppt.Event_Type__c == 'Labor'){
//                         serviceAppointmentMap.put(serviceAppt.Id, serviceAppt);
//                     }else if(serviceAppt.Event_Type__c == 'Physical Helper' || serviceAppt.Event_Type__c == 'Technical Helper'){
//                         serviceAppointmentHelperMap.put(serviceAppt.Id, serviceAppt);
//                     }
//                 }
//                 if(serviceAppointmentMap != null && !serviceAppointmentMap.isEmpty()){
//                     convergeServiceAppointmentWrapper.oldMap = TriggerOldMap;
//                     convergeServiceAppointmentWrapper.newMap = serviceAppointmentMap;
//                     ServiceAppointmentHandler.preSubmissionStatusUpdate(convergeServiceAppointmentWrapper);
//                 }
//                 if(serviceAppointmentHelperMap != null && !serviceAppointmentHelperMap.isEmpty()){
//                     convergeServiceAppointmentWrapper.oldMap = TriggerOldMap;
//                     convergeServiceAppointmentWrapper.newMap = serviceAppointmentHelperMap;
//                     ServiceAppointmentHandler.performHelperEvent(convergeServiceAppointmentWrapper);
//                 }    
//             }
//             system.debug('RODRIGO afterInsert updateAddressOnWorkOrder before');
//             ServiceAppointmentHandler.updateAddressOnWorkOrder( TriggerOldMap, TriggerNew, false ); // added by Rodrigo for Defect 7586036
//             system.debug('RODRIGO afterInsert updateAddressOnWorkOrder after');
//             ServiceAppointmentHandler.updateFieldEngineer( TriggerOldMap, TriggerNewMap, true );
//         }
//     }
    
//     public override void beforeUpdate()
//     /* -----------------------------------------------------------------------------------------------------------------------
//     Name:       beforeUpdate
//     Description:  This handles logic for before update event
//     Date         Version  Author             Summary of Changes 
//     -----------  -------  -----------------  ------------------------------------------------------------------------------
//     Mar-18-2020     1.0    Rodrigo Carpio     Initial Release for Story 8252798
//     -------------------------------------------------------------------------------------------------------------------------- */
//     {
//         // Implement logic here. Execute only if relevantRecordsFound is set to true
//         if (relevantRecordsFound)
//         {
//             if (ServiceAppointmentHandler.runOnce) {
//                 Boolean helperEvent = false;
//                 Map<Id, ServiceAppointment> serviceAppointmentMap = new Map<Id, ServiceAppointment>();
//                 List<ServiceAppointment> serviceAppointments = [SELECT Id, Work_Order__c, Reject_Reason__c, Event_Type__c   
//                                                                 FROM ServiceAppointment WHERE Id IN :TriggerNewMap.keySet()];
//                 for(ServiceAppointment serviceAppt : serviceAppointments){
//                     if(serviceAppt.Event_Type__c != 'Labor'){
//                         helperEvent = true;
//                     }
//                 }
//                 if(!helperEvent){
//                     ServiceAppointmentHandler.ConvergeServiceAppointmentWrapper convergeServiceAppointmentWrapper = new ServiceAppointmentHandler.ConvergeServiceAppointmentWrapper();
//                     convergeServiceAppointmentWrapper.oldMap = TriggerOldMap;
//                     convergeServiceAppointmentWrapper.newMap = TriggerNewMap;
//                     ServiceAppointmentHandler.performStatusUpdate(convergeServiceAppointmentWrapper);
//                 }
//                 ServiceAppointmentHandler.updateAddressForAppointment( TriggerOldMap, TriggerNew );
//                 ServiceAppointmentHandler.restrictContactUpdate( TriggerOldMap, TriggerNewMap );
//             }
//         }
//     }
    
//     public override void afterUpdate() 
//     /* -----------------------------------------------------------------------------------------------------------------------
//     Name:       afterUpdate
//     Description:  This handles logic for after update event
//     Date         Version  Author             Summary of Changes 
//     -----------  -------  -----------------  ------------------------------------------------------------------------------
//     Mar-18-2020     1.0    Rodrigo Carpio     Initial Release for Story 8252798    
//     -------------------------------------------------------------------------------------------------------------------------- */
//     {
//         // Implement logic here. Execute only if relevantRecordsFound is set to true
//         //processServiceAppointmentRecord();
//         if (relevantRecordsFound)
//         {
//             ServiceAppointmentHandler.updateAddressOnAsset( TriggerOldMap, TriggerNew );
//             system.debug('RODRIGO afterUpdate updateAddressOnWorkOrder before');
//             ServiceAppointmentHandler.updateAddressOnWorkOrder( TriggerOldMap, TriggerNew, true );  
//             system.debug('RODRIGO afterUpdate updateAddressOnWorkOrder after');
//             ServiceAppointmentHandler.updateFieldEngineer( TriggerOldMap,TriggerNewMap, false );  
//             ServiceAppointmentHandler.updateLaborStatus( TriggerOldMap,TriggerNew );
//             ServiceAppointmentHandler.woInPlannedQueue( TriggerOldMap,TriggerNew );
            
//             // Method to insert Service Event for Scheduling
//             ServiceAppointmentHandler.createServiceEventforScheduledWorkOrders(TriggerOldMap, TriggerNewMap);
//             /*ServiceAppointmentHandler.removeWOFromPlannedQueue(TriggerOldMap, TriggerNew);

//             ServiceAppointmentHandler.ConvergeServiceAppointmentWrapper convergeServiceAppointmentWrapper = new ServiceAppointmentHandler.ConvergeServiceAppointmentWrapper();
//             convergeServiceAppointmentWrapper.oldMap = TriggerOldMap;
//             convergeServiceAppointmentWrapper.newMap = TriggerNewMap;
//             ServiceAppointmentHandler.performPartPickUpEvent(convergeServiceAppointmentWrapper);*/

//         }
//     }
//     private static List<String> getTriggerHandlerConfig(String APIName, String HandlerName) 
//     /* -----------------------------------------------------------------------------------------------------------------------
//     Name:       getTriggerHandlerConfig
//     Description:  This pulls the configured metadata base on object name and class handler
//     Date         Version  Author             Summary of Changes 
//     -----------  -------  -----------------  ------------------------------------------------------------------------------
//     Mar-18-2020     1.0    Rodrigo Carpio     Initial Release for Story 8252798
//     -------------------------------------------------------------------------------------------------------------------------- */
//     { 
//         List<String> listRecordTypeNames = new List<String>();
//         for(Trigger_Handler_Configuration__mdt config :[SELECT Id, Record_Type_Name__c FROM Trigger_Handler_Configuration__mdt
//                                                         WHERE
//                                                         Object_API_Name__c = :APIName AND
//                                                         Handler_Class_Name__c = :HandlerName])
//         {
//             listRecordTypeNames.add(config.Record_Type_Name__c);
//         }
//         if(listRecordTypeNames.size() > 0)
//             return listRecordTypeNames;
//         return null;
//     }
    
//     private static Id getRecordTypeId(String name, Map<String, Schema.RecordTypeInfo> recordTypeMap)
//     /* -----------------------------------------------------------------------------------------------------------------------
//     Name:       getRecordTypeId
//     Description:  This pulls the list of record type name
//     Date         Version  Author             Summary of Changes 
//     -----------  -------  -----------------  ------------------------------------------------------------------------------
//     Mar-18-2020     1.0    Rodrigo Carpio     Initial Release for Story 8252798
//     -------------------------------------------------------------------------------------------------------------------------- */
//     {
//         Schema.RecordTypeInfo recordTypeInfo = recordTypeMap.get(name);
//         if(recordTypeInfo != null)
//         {
//             return recordTypeInfo.getRecordTypeId();
//         }
        
//         return null;
//     }
    
//     public static Set<Id> getRecordTypeIds(List<String> recordTypeNames)
//     /* -----------------------------------------------------------------------------------------------------------------------
//     Name:       getRecordTypeIds
//     Description:  This gets the list of record type id base on list of names
//     Date         Version  Author             Summary of Changes 
//     -----------  -------  -----------------  ------------------------------------------------------------------------------
//     Mar-18-2020     1.0    Rodrigo Carpio     Initial Release for Story 8252798
//     -------------------------------------------------------------------------------------------------------------------------- */
//     {
//         Set<Id> ffRecordTypes = new Set<Id>();
//         if(recordTypeNames == null)
//             return ffRecordTypes;
        
//         Map<String, Schema.RecordTypeInfo> recordTypeMap = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName();
        
//         for(String recordTypeName :recordTypeNames)
//         {
//             Id recordTypeId = getRecordTypeId(recordTypeName, recordTypeMap);
//             if(recordTypeId != null)
//                 ffRecordTypes.add(recordTypeId);
//         }
        
//         return ffRecordTypes;
//     }
//     private void filterRecordsByRecordType() 
//     /* -----------------------------------------------------------------------------------------------------------------------
//     Name:       filterRecordsByRecordType
//     Description:  This method handles the filtering of data base on record type
//     Date         Version  Author             Summary of Changes 
//     -----------  -------  -----------------  ------------------------------------------------------------------------------
//     Mar-18-2020     1.0    Rodrigo Carpio     Initial Release for Story 8252798    
//     -------------------------------------------------------------------------------------------------------------------------- */
//     {
//         // Filter records by record types that belong to Lightning and store it in the local variables here
//         // set relevantRecordsFound to true if Lightning related records are passed in the trigger context
//         // Note: Store the lightning related record type developer names in the Custom Settings and use that for filtering. DO NOT hardcode them here.
//         //There already is a custom setting that is created for this - Trigger_Handler_Configuration__mdt
//         //Added logic to bypass the call of trigger when Service Event is Part Pick up(DEFECT 8492764 fix)
//         Set<Id> saRecordTypes = getRecordTypeIds(getTriggerHandlerConfig('ServiceAppointment', LightningServiceAppointmentTrgrHandler.class.getName()));
//         Boolean hasWORT = false;
//         Boolean hasOtherRT = false;
        
//         this.TriggerNewMap = new Map<Id, ServiceAppointment>();
//         this.TriggerOldMap = new Map<Id, ServiceAppointment>();
//         this.TriggerNew = new List<ServiceAppointment>();
//         this.TriggerOld = new List<ServiceAppointment>();
//         system.debug('saRecordTypes ' + saRecordTypes);
//         //mount triggerNewMap
//         if(Trigger.NewMap != null) {
//             for (Id woId : Trigger.NewMap.keySet()) {
//                 ServiceAppointment woNew = (ServiceAppointment) Trigger.newMap.get(woId);
//                 if ((saRecordTypes.contains(woNew.RecordTypeId)) && woNew.Event_Type__c!= 'Part Pick Up') {
//                     hasWORT = true;
//                     relevantRecordsFound=true;
//                     this.TriggerNewMap.put(woId, woNew);
//                 } else hasOtherRT = true;
//             }
//         }
        
//         //mount triggerNew
//         if(Trigger.New != null) {
//             for (ServiceAppointment woNew : (List<ServiceAppointment>)Trigger.New) {
//                 if ((saRecordTypes.contains(woNew.RecordTypeId)) && woNew.Event_Type__c!= 'Part Pick Up') {
//                     hasWORT = true;
//                     relevantRecordsFound=true;
//                     this.TriggerNew.add(woNew);
//                 } else hasOtherRT = true;
//             }
//         }
        
//         //mount triggerOldMap
//         if(Trigger.OldMap != null) {
//             for (Id woId : Trigger.OldMap.keySet()) {
//                 ServiceAppointment woOld = (ServiceAppointment) Trigger.OldMap.get(woId);
//                 //if ((saRecordTypes.contains(woOld.RecordTypeId) || this.TriggerNewMap.keySet().contains(woId)) && woOld.Event_Type__c!= 'Part Pick Up')
//                 if ((saRecordTypes.contains(woOld.RecordTypeId) || this.TriggerNewMap.keySet().contains(woId)))
//                 {
//                     hasWORT = true;
//                     relevantRecordsFound=true;
//                     this.TriggerOldMap.put(woId, woOld);
//                 } else hasOtherRT = true;
//             }
//         }
        
//         //mount triggerOld
//         if(Trigger.Old != null) {
//             for (ServiceAppointment woOld : (List<ServiceAppointment>)Trigger.Old) {
//                 //if ((saRecordTypes.contains(woOld.RecordTypeId) || this.TriggerNewMap.keySet().contains(woOld.Id)) && woOld.Event_Type__c!= 'Part Pick Up') 
//                 if ((saRecordTypes.contains(woOld.RecordTypeId) || this.TriggerNewMap.keySet().contains(woOld.Id))) 
//                 {
//                     hasWORT = true;
//                     relevantRecordsFound=true;
//                     this.TriggerOld.add(woOld);
//                 } else hasOtherRT = true;
//             }
//         }
        
//         if(hasWORT)
//             system.debug('Continue with this handler. Other handlers should be bypassed.');
//         else if(!hasWORT && hasOtherRT)
//             TriggerHandler.bypass(LightningServiceAppointmentTrgrHandler.class.getName());
//     }
    
 }