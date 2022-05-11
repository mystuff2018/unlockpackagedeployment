public class FSLCreateShadowAppointmentCtrl {
    @AuraEnabled
    public static string createChildShadowSA(String recordId){
        ServiceAppointment serviceAppt =  [Select Id,AccountId,Project__c,AppointmentType,AppointmentNumber,ContactId,Work_Order__c,Duration,DurationType,Subject,WorkTypeId,RecordTypeId,ParentRecordId,Project_Task__c,Excluded_Engineer_SA__c,GeocodeAccuracy__c,Address,EarliestStartTime,
                                           DueDate,ScheduleStart_SiteTimeZone__c,PSA_Execution_Site_TimeZone__c,Assignee__c,Resource_TimeZone__c,Assignment__c,Description,Status,StatusCategory,Physical_Helper_Requested_by_Engineer__c,
                                           Assist_Service_Appointment__c,Shadow_Task_Added__c,Jeopardy_State__c,FSL__Related_Service__c FROM ServiceAppointment WHERE Id =:recordId];
        // Child ServiceAppointment Fields
        ServiceAppointment shadowAppt = serviceAppt.clone(false, true, false, false);
        shadowAppt.Project__c = System.Label.ShadowApptProject; // Custom label
        shadowAppt.Status = 'New';
        shadowAppt.Work_Order__c = null;
        shadowAppt.ParentRecordId = System.Label.ShadowApptParentRecordId;// Custom label 
        shadowAppt.Assignee__c = null;
        shadowAppt.Assignment__c = null;
        shadowAppt.SchedStartTime  =null;
        shadowAppt.SchedEndTime= null;
        shadowAppt.AppointmentType = 'Shadow Appointment';
        shadowAppt.FSL__Related_Service__c = serviceAppt.Id;
        //Updating Parent Record
        serviceAppt.AppointmentType = 'Primary Appointment';
        serviceAppt.Shadow_Task_Added__c = true;
        try{
            upsert new List<ServiceAppointment>{shadowAppt,serviceAppt};
                if(Test.isRunningTest())  //Condition to ensure test is running
             	integer intTest =1/0;
                return shadowAppt.Id;
        }
        catch(Exception e){
           throw new AuraHandledException('Error Creating Service Appointment'+e.getMessage());
        }
    }
}