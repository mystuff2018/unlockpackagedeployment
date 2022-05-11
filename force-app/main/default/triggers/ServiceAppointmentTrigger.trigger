/*
      Purpose:
            Trigger ServiceAppointmentHandler to populate the project lookup upon service appointment upon
            creation.
            
      Initiative: Dell Thunderbolt PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    9/13/18
    
    =============================================================================================================
    Modification History:
    -------------------------------------------------------------------------------------------------------------
    Name                Date        Company             Description
    -------------------------------------------------------------------------------------------------------------
    Pawan K             1/8/19      OAC Services INC.   Added Before Updated event to clone
                                                related Work Orders.
                                                Class : workOrderCloneController 
                                                
    Valenzuela L        20190612    Added support to convert scheduled Start into siteTimezone    
    Rodrigo Carpio      10/22/2019  added by Rodrigo for Defect 7586036
  Ramzil Cleopas      10/29/2019  Added logic to call method to insert Service Event for Scheduling
  Rodrigo Carpio      Mar-20-2020 refactor the lightning trigger logic for story 8252798
    -------------------------------------------------------------------------------------------------------------
    =============================================================================================================
*/

trigger ServiceAppointmentTrigger on ServiceAppointment (before insert, before update, after insert, after update) {
    //decouple of FinancialForce Trigger
    
   
    List<ServiceAppointment> saList = new List<ServiceAppointment>();
    List<ServiceAppointment> assignedSAList = new List<ServiceAppointment>();
    Map<Id, AssignedResource> serviceResourceMap = new Map<Id, AssignedResource>();
    Map<Id, String> WorkOrderXappointmentMap = new Map<Id, String>();
    Set<Id> assigneeId = new Set<Id>();
        
   
    if(!System.isBatch()){
    new FFServiceAppointmentTriggerHandler().run();
    
    if(!(Trigger_Execution_Control__c.getInstance().Skip_ServiceAppointment_Trigger__c)){
        new LightningServiceAppointmentTrgrHandler().run(); // added for Story 8252798        
    }
    if(Trigger.isAfter && Trigger.isInsert && RecursiveTriggerHandler.isFirstTime()){
       String saListString = json.serialize(Trigger.NEW);
      // FFServiceAppointmentTriggerHandler.updateCustomerNameOnSA(saListString);  
    }
    }
}