/**************
 * @ Class Name        : AssignedResourceTriggerHandler
 * @ Description       : This class is created to Populate assignee on the Service Appointment when SA is scheduled and resource is assigned 
 *                       Created as part of Feature #8760856.
 * @ CreatedBy         : Deloitte
 * @ Modification Log  : Version 1.0 - [Namrata] :
 * 						 Version 1.1 - [Abhishek Kawle]  11/23/2020: Added method 'createProjectSharing' as part of Defect #9746815
*********/

public class AssignedResourceTriggerHandler {
    public static List<ExceptionLogger__c> exceptionLoggers = new List<ExceptionLogger__c>();
    public static void populateAssignee(Map <Id,AssignedResource> mapAppointmentVsResource){ 
        List<String> resourceNameList = new List<String>();
        List<ServiceAppointment> updateAppointmentList = new List<ServiceAppointment>();
        Map<String, Id> mapNameVsContactId = new  Map<String, Id> ();
        Map <Id,AssignedResource> mapAppointmentVsResourceName = new Map <Id,AssignedResource>();
        
        List<AssignedResource> arList =[Select Id,ServiceResourceId,ServiceResource.name,ServiceAppointmentId,ServiceResource.RelatedRecordId from AssignedResource where Id IN:mapAppointmentVsResource.values() ];
        
        for(AssignedResource sr : arList){
          resourceNameList.add(sr.ServiceResource.RelatedRecordId); 
          mapAppointmentVsResourceName.put(sr.ServiceAppointmentId, sr);
        } 

        List<ServiceAppointment> appointmentList = [SELECT Id,Status,Assignee__c FROM ServiceAppointment WHERE Id IN : mapAppointmentVsResource.keySet()];
        
        for(Contact con : [SELECT Id,pse__Salesforce_User__c FROM Contact WHERE pse__Salesforce_User__c IN : resourceNameList]){
            mapNameVsContactId.put(con.pse__Salesforce_User__c, con.Id);
        }
        for(ServiceAppointment sa : appointmentList ){ 
            
                AssignedResource resource = mapAppointmentVsResourceName.get(sa.Id);

                if( mapNameVsContactId.containsKey(resource.ServiceResource.RelatedRecordId ) ){
                    sa.Assignee__c = mapNameVsContactId.get(resource.ServiceResource.RelatedRecordId);
                    updateAppointmentList.add(sa);
                } 
        }
        if(!updateAppointmentList.isEmpty()){
            List<Database.SaveResult> updateAssigneeResult = Database.update(updateAppointmentList,false);
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(updateAppointmentList, updateAssigneeResult, 'AssignedResourceTriggerHandler', 'populateAssignee') );
            if(!exceptionLoggers.isEmpty() || exceptionLoggers.size()>0){ //Added size check as a part of CheckMarx
                upsert exceptionLoggers;
            }
        }

    }
    
    public static void deleteRecords(Set<Id> deleteARList){
        if(!deleteARList.isEmpty() || deleteARList.size()>0){ //Added size check as a part of CheckMarx
        System.debug('deleteARList'+deleteARList);
        delete [select id from AssignedResource where id in : deleteARList];
    }
        
    }
    
    public static void createProjectSharing(List<AssignedResource> assignedReList){
        Set<Id> arSet = new Set<Id>();
        List<pse__Proj__Share> projectShareRecords = new List<pse__Proj__Share>();
        
        for(AssignedResource ar : assignedReList){
            arSet.add(ar.Id);
        }
        
        List<AssignedResource> arList =[SELECT Id, 
                                        ServiceResourceId, 
                                        ServiceAppointmentId, 
                                        ServiceAppointment.AppointmentType,
                                        ServiceAppointment.Project__c,
                                        ServiceResource.RelatedRecordId,
                                        ServiceResource.RelatedRecord.Name
                                        FROM AssignedResource 
                                        WHERE Id IN:arSet];
        
        for(AssignedResource eachAR : arList){
            //Create a Project share record           
            if(eachAR.ServiceAppointment.AppointmentType == 'Primary Appointment'){
                pse__Proj__Share eachRecord = new pse__Proj__Share();
                eachRecord.ParentId = eachAR.ServiceAppointment.Project__c;
                eachRecord.UserOrGroupId = eachAR.ServiceResource.RelatedRecordId;
                eachRecord.RowCause = Schema.pse__Proj__Share.RowCause.PSA_Tech_Resource_Share__c;
                eachRecord.AccessLevel = 'Edit';
                
                projectShareRecords.add(eachRecord);                
            }
        }
        
        if(!projectShareRecords.isEmpty()){
            insert projectShareRecords;
        }
    }

}