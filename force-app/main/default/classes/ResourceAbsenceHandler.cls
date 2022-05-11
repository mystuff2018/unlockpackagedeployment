/**************
* @ Class Name        : ResourceAbsenceHandler
* @ Description       : This class is created to automatically create Time Sheet & Time Sheet Entry when the Absence record for Resource is created in FSL 
*                       Created as part of Feature #8760856.
* @ CreatedBy         : Deloitte
* @ Modification Log  : Version 1.0 - [Namrata] : 
*********/

public class ResourceAbsenceHandler {
    public static List<ExceptionLogger__c> exceptionLoggers = new List<ExceptionLogger__c>();
    public static List<TimeSheet> createTimeSheet(List<ResourceAbsence> raList){
        List<TimeSheet> tsList = new List<TimeSheet>();
        List<pse__Proj__c> projList = new List<pse__Proj__c>();
        Map<String , pse__Proj__c> mapAbsenceVsGlobalProject = new Map<String , pse__Proj__c>();
        Date startDate;
        Date endDate;
        Integer count;
        
        projList = getProjectList();
        
        for(ResourceAbsence ra : raList){
            for(pse__Proj__c proj : projList){
                if(ra.Type == proj.Name){
                    mapAbsenceVsGlobalProject.put(ra.Type ,proj);  
                }                
            }  
        }
        
        for(ResourceAbsence ra : raList){
            startDate = (ra.Start).date();
            endDate = (ra.End).date();
            count = startDate.daysBetween(endDate);
            System.debug('Count'+Count);
            pse__Proj__c pj = mapAbsenceVsGlobalProject.get(ra.Type);
            if(pj != null){
                for(Integer i =0; i<= count; i++){
                    TimeSheet objTS = new TimeSheet();
                    objTS.StartDate = (ra.Start).date().addDays(i);
                    objTS.EndDate = (ra.Start).date().addDays(i);//Date.valueOf(ra.Start).addDays(i+1);
                    objTS.ServiceResourceId = ra.ResourceId;
                    objTS.FBE_Project__c = pj.Id; 
                    objTS.FBE_Resource_Absence__c = ra.Id;
                    tsList.add(objTS);        
                }
            }                                                                                         
        }
        
        if(!tsList.isEmpty() || tsList.size()>0){ //Added size check as a part of checkMarx
            List<Database.SaveResult> InsertTimeSheetResult = Database.insert(tsList,false);
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(tsList, InsertTimeSheetResult, 'ResourceAbsenceHandler', 'createTimeSheet') );
            if(!exceptionLoggers.isEmpty()){
                upsert exceptionLoggers;
            }
            createTimeSheetEntry(tsList, raList);            
        }      
        return tsList;
    }
    
    public static List<TimeSheetEntry> createTimeSheetEntry(List<TimeSheet> tsList, List<ResourceAbsence> raList){
        List<TimeSheetEntry> tseList = new List<TimeSheetEntry>();
        for(ResourceAbsence raObj : raList){
            for(TimeSheet ts : tsList){
                Time myTime = Time.newInstance(8, 0, 0, 0);
                Time myTime2 = Time.newInstance(16, 0, 0, 0);
                Time myTime3 = Time.newInstance(0, 0, 0, 0);
                TimeSheetEntry objTSE = new TimeSheetEntry();
                objTSE.TimeSheetId = ts.Id;
                system.debug('ts.FBE_Project__r.Name'+ts.FBE_Project__r.Name);
                if(raObj.Type == 'Vacation'){
                    objTSE.StartTime = DateTime.newInstance(ts.StartDate, myTime); 
                    objTSE.EndTime = DateTime.newInstance(ts.EndDate, myTime2); 
                }
                else{
                    objTSE.StartTime = DateTime.newInstance(ts.StartDate,myTime3);
                    objTSE.EndTime = DateTime.newInstance(ts.EndDate,myTime3);
                }
                tseList.add(objTSE);
            }
            
        }
        
        if(!tseList.isEmpty() || tseList.size()>0){ //Added a size check as a part of checkMarx
            List<Database.SaveResult> InsertTimeSheetEntryResult = Database.insert(tseList,false);
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(tseList, InsertTimeSheetEntryResult, 'ResourceAbsenceHandler', 'createTimeSheetEntry') );
            if(!exceptionLoggers.isEmpty()){
                upsert exceptionLoggers;
            }
        }
        return tseList;        
    }
    
    public static List<pse__Proj__c> getProjectList(){
        List<pse__Proj__c> projList = new List<pse__Proj__c>();
        projList =[SELECT Id, Name
                   FROM pse__Proj__c 
                   WHERE pse__Allow_Timecards_Without_Assignment__c = true];
        return projList;
    }
    
    public static void updateRelatedTimesheets(Map<Id,ResourceAbsence> oldResourceAbsenceMap,List<ResourceAbsence> newResourceAbsenceList){
        List<pse__Proj__c> projList = new List<pse__Proj__c>();
        Map<Id,ResourceAbsence> resAbMap = new Map<Id,ResourceAbsence>();
        Map<String , pse__Proj__c> mapAbsenceVsGlobalProject = new Map<String , pse__Proj__c>();
        for(ResourceAbsence resab: newResourceAbsenceList){
            if(resab.Start!=oldResourceAbsenceMap.get(resab.id).Start || resab.End!=oldResourceAbsenceMap.get(resab.id).End){
                resAbMap.put(resab.id,resab);
            }
        }
        
        List<TimeSheet> timeSheetList = [Select Id,StartDate,EndDate,FBE_Resource_Absence__c,Status from TimeSheet where FBE_Resource_Absence__c IN : resAbMap.keySet()];
                
        Map<String,TimeSheet> resAbTimeSheetMap= new Map<String,TimeSheet>();
        
        for(TimeSheet ts: timeSheetList){
            resAbTimeSheetMap.put(ts.FBE_Resource_Absence__c+'-'+ts.StartDate,ts);         
        }
        Date startDate;Date endDate;Integer count;
        List<TimeSheet> createTsList = new List<TimeSheet>();
        
        projList = getProjectList();
        for(pse__Proj__c proj : projList){
            mapAbsenceVsGlobalProject.put(proj.Name,proj);
        }
        
        List<TimeSheet> matchts = new List<TimeSheet>();
        Set<TimeSheet> delts = new Set<TimeSheet>();
        List<ResourceAbsence> resAbforTimeSheet = new List<ResourceAbsence>(); 
        delts.addAll(resAbTimeSheetMap.values());
        for(ResourceAbsence ra: resAbMap.values()){            
            Set<Date> datelist = new Set<Date>();
            
            Date CountingDate = (ra.Start).date();
            do {
                TimeSheet ts = resAbTimeSheetMap.get(ra.Id+'-'+countingDate);
                if(ts!=null){
                    delts.remove(ts);
                }else{
                    pse__Proj__c pj = mapAbsenceVsGlobalProject.get(ra.Type);
                    if(pj!=null){
                        TimeSheet objTS = new TimeSheet();
                        objTS.StartDate = CountingDate;
                        objTS.EndDate = CountingDate;
                        objTS.ServiceResourceId = ra.ResourceId;
                        objTS.FBE_Project__c = pj.Id; 
                        objTS.FBE_Resource_Absence__c = ra.Id;
                        createTsList.add(objTS);                        
                        resAbforTimeSheet.add(ra);
                    }
                }
                countingDate = countingDate.addDays(1);    
            }while(countingDate <= ra.End.date());            
        }
        List<TimeSheet> delTimesheets =new List<TimeSheet>();
        for(TimeSheet ts: delts){
            if(ts.Status!='Submitted')
                delTimesheets.add(ts);
        }
        //try{
        delete delTimesheets;
        //}catch(Exception e){
          //  system.debug('error occured in deletion '+e.getMessage());
        //}
        //insert createTsList;
        
        if(!createTsList.isEmpty() || createTsList.size()>0){ 
            List<Database.SaveResult> InsertTimeSheetResult = Database.insert(createTsList,false);
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(createTsList, InsertTimeSheetResult, 'ResourceAbsenceHandler', 'createTimeSheet') );
            if(!exceptionLoggers.isEmpty()){
                upsert exceptionLoggers;
            }
            createTimeSheetEntry(createTsList, resAbforTimeSheet);            
        }    
    }
        
    
    public static void deleteRelatedTimesheets(List<ResourceAbsence> oldResourceAbsenceList){
        Set<Id> resabIds = new Set<Id>();        
        for(ResourceAbsence ra : oldResourceAbsenceList){
            resabIds.add(ra.Id);
        }
        List<TimeSheet> timeSheetList =  [Select Id from TimeSheet where FBE_Resource_Absence__c IN : resabIds AND Status!='Submitted'];
        //system.debug('timeSheetList '+timeSheetList);      
        Delete timeSheetList;
        
    }
}