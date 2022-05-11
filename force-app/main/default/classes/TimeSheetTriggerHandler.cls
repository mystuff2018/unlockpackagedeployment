/**************
 * @ Class Name        : TimeSheetTriggerHandler
 * @ Description       : This class is created to automatically share Time Sheet record with Resource in FSL 
 *                       Created as part of Feature #8760856.
 * @ CreatedBy         : Deloitte
 * @ Modification Log  : Version 1.0 - [Namrata] : 
*********/
public class TimeSheetTriggerHandler {
    public static List<ExceptionLogger__c> exceptionLoggers = new List<ExceptionLogger__c>();
    public static List<TimeSheetShare> shareTimeSheetWithServiceResource(List<TimeSheet> tsList, Map<Id, ServiceResource>serviceResourceMap){
        List<TimeSheetShare> tsShareList = new List<TimeSheetShare>();
        for(TimeSheet ts : tsList){
            for(ServiceResource sr :serviceResourceMap.values() ){
                if(ts.ServiceResourceId == sr.Id){
                    TimeSheetShare tsShare = new TimeSheetShare();
                    tsShare.ParentId = ts.Id;
                    tsShare.UserOrGroupId = sr.RelatedRecordId;
                    System.debug('sr.RelatedRecordId'+sr.RelatedRecordId);
                    tsShare.AccessLevel = 'edit';
                    tsShareList.add(tsShare);   
                }                                   
            }                
       }        
        List<Database.SaveResult> jobShareInsertResult = Database.insert(tsShareList,false);
        exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(tsShareList, jobShareInsertResult, 'TimeSheetTriggerHandler', 'Share Time Sheet Record') );
        if(!exceptionLoggers.isEmpty()){
            upsert exceptionLoggers;
        }
        return tsShareList; 
    }
    
    /**************
 * @ Method Name       : createTimeSheet
 * @ Description       : This method  is created to automatically create Time Sheet record when Service Appointment is Dispatched
 *                       Created as part of Feature #8760856.
 * @ CreatedBy         : Deloitte
 * @ Modification Log  : Version 1.0 - [Namrata] : 
*********/
    
    public static List<TimeSheet> createTimeSheet(List<ServiceAppointment> saList,List<AssignedResource> resourceList){
        List<TimeSheet> tsList = new List<TimeSheet>();
        Map<Id, AssignedResource> aappointmnetIdVSResourceMap = new Map<Id, AssignedResource>() ;
        Date startDate;
        Date endDate;
        Integer count;
        
        if(!resourceList.isEmpty()){
            for(AssignedResource resource : resourceList){
                aappointmnetIdVSResourceMap.put(resource.ServiceAppointmentId, resource);
            }            
        }
        
        for(ServiceAppointment sa: saList){
          startDate = (sa.SchedStartTime).date();
          endDate = (sa.SchedEndTime).date();  
          count = startDate.daysBetween(endDate);
          AssignedResource resource = aappointmnetIdVSResourceMap.get(sa.Id);
            for(Integer i =0; i<= count; i++){
                TimeSheet tsObj = new TimeSheet();
                tsObj.StartDate = (sa.SchedStartTime).date().addDays(i);
                tsObj.EndDate = (sa.SchedStartTime).date().addDays(i);//(sa.SchedEndTime).date().addDays(i);  
                tsObj.Status = 'New';
                if(sa.AppointmentType == 'Shadow Appointment' && sa.Project__c != null){ // Added check for Shadow SA here to assign global project if type is Shadow SA
                	tsObj.FBE_Project__c = sa.Project__c;
                    tsObj.FBE_Service_Appointment__c = sa.Id; 
                }else{
                	tsObj.FBE_Service_Appointment__c = sa.Id; 
                }
                tsObj.ServiceResourceId = resource.ServiceResourceId;
                tsList.add(tsObj);      
            }                               
        }
        if(!tsList.isEmpty() || tsList.size()>0){ //Added a size check as a part of checkMarx     
           List<Database.SaveResult> InsertTimeSheetResult = Database.insert(tsList,false);
           exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(tsList, InsertTimeSheetResult, 'TimeSheetTriggerHandler', 'Create Time Sheet Record') );
           
           if(!exceptionLoggers.isEmpty()){
                upsert exceptionLoggers;
           }
        
        } 
        createTimeSheetEntry(tsList);
        return tsList;
    }
    
/**************
 * @ Method Name       : createTimeSheetEntry
 * @ Description       : This method  is created to automatically create Time Sheet Entry record when Service Appointment is Dispatched
 *                       Created as part of Feature #8760856.
 * @ CreatedBy         : Deloitte
 * @ Modification Log  : Version 1.0 - [Namrata] : 
*********/
    
    public static List<TimeSheetEntry> createTimeSheetEntry(List<TimeSheet> tsList){
        List<TimeSheetEntry> tseList = new List<TimeSheetEntry>();
        List<String> typeList = new String[2];
        typeList.add(0, 'Travel To Customer Site'); typeList.add(1, 'Onsite'); typeList.add(2, 'Travel From Customer Site');
        
        for(TimeSheet ts : tsList){
            for(Integer i= 0; i< 3; i++){                
                Time myTime = Time.newInstance(0, 0, 0, 0);
                TimeSheetEntry tseObj = new TimeSheetEntry();
                tseObj.TimeSheetId = ts.Id;
                tseObj.StartTime = DateTime.newInstance(ts.StartDate,myTime);
                tseObj.EndTime = DateTime.newInstance(ts.EndDate,myTime); 
                if(i == 0){
                    tseObj.Type = typeList[0];     
                }
                if(i == 1){
                    tseObj.Type = typeList[1];     
                }
                if(i == 2){
                    tseObj.Type = typeList[2];     
                }
                //tseObj.Type = type;
                tseList.add(tseObj);                   
            }    
        }
        if(!tseList.isEmpty() || tseList.size()>0 ){ //Added a size check as a part of CheckMarx
            List<Database.SaveResult> InsertTimeSheetEntryResult = Database.insert(tseList,false);
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(tseList, InsertTimeSheetEntryResult, 'TimeSheetTriggerHandler', 'Create Time Sheet Entry Record') );
            if(!exceptionLoggers.isEmpty()){
                upsert exceptionLoggers;
            }
        }
        return tseList;
    }
    
    
}