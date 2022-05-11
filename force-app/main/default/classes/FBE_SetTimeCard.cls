/**************
* @ Class Name        : FBE_SetTimeCard
* @ Description       : This class is created to create/update Timcard & task time when Time SHeet is Submitted
*                       Created as part of Feature #8760856.
* @ CreatedBy         : Deloitte
* @ Modification Log  : Version 1.0 - [Namrata] : 
*********/

public class FBE_SetTimeCard {
    public static List<pse__Timecard_Header__c> createTCList=  new List<pse__Timecard_Header__c>();
    public static List<pse__Timecard_Header__c> updateTCList=  new List<pse__Timecard_Header__c>();
    public static Map<String , pse__Task_Time__c> createTTMap =  new Map<String , pse__Task_Time__c>();
    public static Map<String , pse__Task_Time__c> updateTTMap =  new Map<String , pse__Task_Time__c>();
    public static List<ExceptionLogger__c> exceptionLoggers = new List<ExceptionLogger__c>();
    
    /**************
* @ Method Name        : lockTimeSheetEntryRecord
* @ Description       : This method is created to loch Time Sheet record when Time SHeet is Submitted
*                       Created as part of Feature #8760856.
* @ CreatedBy         : Deloitte
* @ Modification Log  : Version 1.0 - [Namrata] : 
*********/
    public static void lockTimeSheetEntryRecord(List<Id> timeSheetId){ 
        //query all TSE records and lock those - we are not locking TS here
        
        Approval.LockResult[] lrList = Approval.lock(timeSheetId, false);
        for(Approval.LockResult lr : lrList){
            if(lr.isSuccess()){
                System.debug('Successfully locked Time Sheet with ID: ' + lr.getId()); 
            }
            else{
                for(Database.Error err : lr.getErrors()){                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Time Sheet fields that affected this error: ' + err.getFields()); 
                }
            }
            
        }
    }
    
    /**************
* @ Method Name        : updateTimeCard
* @ Description       : This method is created to update Timecard when Time Sheet is Submitted Boomi unique Filter
*                       Created as part of Feature #8760856.
* @ CreatedBy         : Deloitte
* @ Modification Log  : Version 1.0 - [Namrata] : 
*********/
    
    public static pse__Timecard_Header__c updateTimeCard(pse__Timecard_Header__c tc3, TimeSheet ts2){       
        
        try{
            if(ts2.FBE_Day_of_week__c == 'Monday'){
                tc3.pse__Monday_Hours__c =  tc3.pse__Monday_Hours__c + ts2.TotalDurationInHours; 
            }
            else if(ts2.FBE_Day_of_week__c == 'Tuesday'){
                tc3.pse__Tuesday_Hours__c =  tc3.pse__Tuesday_Hours__c + ts2.TotalDurationInHours;
            }
            else if(ts2.FBE_Day_of_week__c == 'Wednesday'){
                tc3.pse__Wednesday_Hours__c = tc3.pse__Wednesday_Hours__c + ts2.TotalDurationInHours;
            }
            else if(ts2.FBE_Day_of_week__c == 'Thursday'){
                tc3.pse__Thursday_Hours__c = tc3.pse__Thursday_Hours__c + ts2.TotalDurationInHours;
            }
            else if(ts2.FBE_Day_of_week__c == 'Friday'){
                tc3.pse__Friday_Hours__c = tc3.pse__Friday_Hours__c + ts2.TotalDurationInHours; 
            }
            else if(ts2.FBE_Day_of_week__c == 'Saturday'){
                tc3.pse__Saturday_Hours__c =  ts2.TotalDurationInHours;
            }
            else{
                tc3.pse__Sunday_Hours__c = tc3.pse__Sunday_Hours__c + ts2.TotalDurationInHours;
                System.debug('Sunday hrs ' + tc3.pse__Sunday_Hours__c);
            }
            
        }catch(Exception ex){
            System.debug('Get Error ' +ex.getMessage() + 'Get Line Number ' +ex.getLineNumber());
        }
        return tc3;
    }
    
    /**************
* @ Method Name        : createTimeCard
* @ Description       : This method is created to Craete Timecard when Time Sheet is Submitted based on Boomi unique Filter
*                       Created as part of Feature #8760856.
* @ CreatedBy         : Deloitte
* @ Modification Log  : Version 1.0 - [Namrata] : 
*********/
    public static void createTimeCard(List<TimeSheet> tsList, String key){
        
        pse__Timecard_Header__c tc2 = new pse__Timecard_Header__c(); 
        /*************************Novora Change start ************************/
        //Added for Novora timecard Defect
        // tc2.pse__Status__c = 'Approved';//added for novora interlock.
        // tc2.FBE_IDS_Time_IntegrationStatus__c = System.Label.FBE_IDS_IntegrationStatus;
        //tc2.pse__Approved__c = True;
        //tc2.pse__Submitted__c = True;
        //End of changes
        date startDayWeek = (tsList[0].StartDate).toStartofWeek();
        date endDayOfweek = startDayWeek +6;
        tc2.pse__Start_Date__c = startDayWeek<=tsList[0].FBE_Project__r.pse__Start_Date__c ? tsList[0].FBE_Project__r.pse__Start_Date__c :startDayWeek;
        tc2.pse__End_Date__c = endDayOfweek>=tsList[0].FBE_Project__r.pse__End_Date__c ? tsList[0].FBE_Project__r.pse__End_Date__c : endDayOfweek ;  
        /****************************Novora Change end **********************/
        //tsList[0].FBE_Service_Appointment__c = null;
        if((tsList[0].FBE_Project__r.Id !=null && tsList[0].FBE_Service_Appointment__c == null) || (tsList[0].FBE_Project__r.Id !=null && tsList[0].FBE_Service_Appointment__r.AppointmentType == 'Shadow Appointment')){
            // Contact con =[Select Id from Contact where name =: tsList[0].ServiceResource.Name];
            Contact con =[Select Id,pse__Salesforce_User__c from Contact where pse__Salesforce_User__c =: tsList[0].ServiceResource.RelatedRecordId];
            
            tc2.pse__Project__c =  tsList[0].FBE_Project__r.Id; //;FBE_Project__r.Name
            tc2.pse__Resource__c = con.id;
            tc2.pse__Submitted__c = True;
            tc2.pse__Approved__c = True;
            tc2.pse__Status__c = 'Approved';
            tc2.Boomi_TC_Unique_ID_Global__c =key;
        } 
        else {
            System.debug('Inside else');
            tc2.pse__Project__c =  tsList[0].FBE_Service_Appointment__r.Project__c;
            tc2.pse__Assignment__c = tsList[0].FBE_Service_Appointment__r.Assignment__c ;
            tc2.pse__Resource__c = tsList[0].FBE_Service_Appointment__r.Assignee__c;
            //tc2.pse__Submitted__c = True;
            tc2.FBE_IDS_Time_IntegrationStatus__c = System.Label.FBE_IDS_IntegrationStatus;
            tc2.Boomi_TC_Unique_ID__c = key;
        }
        
        for(Timesheet ts2 : tsList){
            if(ts2.FBE_Day_of_week__c == 'Monday'){
                tc2.pse__Monday_Hours__c =  ts2.TotalDurationInHours; 
            }
            else if(ts2.FBE_Day_of_week__c == 'Tuesday'){
                tc2.pse__Tuesday_Hours__c =  ts2.TotalDurationInHours;
            }
            else if(ts2.FBE_Day_of_week__c == 'Wednesday'){
                tc2.pse__Wednesday_Hours__c =  ts2.TotalDurationInHours;
            }
            else if(ts2.FBE_Day_of_week__c == 'Thursday'){
                tc2.pse__Thursday_Hours__c =  ts2.TotalDurationInHours;
            }
            else if(ts2.FBE_Day_of_week__c == 'Friday'){
                tc2.pse__Friday_Hours__c =  ts2.TotalDurationInHours; 
            }
            else if(ts2.FBE_Day_of_week__c == 'Saturday'){
                tc2.pse__Saturday_Hours__c =  ts2.TotalDurationInHours;
            }
            else if(ts2.FBE_Day_of_week__c == 'Sunday'){
                tc2.pse__Sunday_Hours__c = ts2.TotalDurationInHours;   
            }   
        }       
        createTCList.add(tc2);  
      
    }
    
    /**************
* @ Method Name       : updateTaskTime
* @ Description       : This method is created to updat Task Time when Time Sheet is Submitted based on Boomi unique Filter
*                       Created as part of Feature #8760856.
* @ CreatedBy         : Deloitte
* @ Modification Log  : Version 1.0 - [Namrata] : 
*********/
    
    public static void updateTaskTime(pse__Task_Time__c tt2, TimeSheet ts4,String key){
        if(updateTTMap.get(key) != null)
            tt2 = updateTTMap.get(key);
        if(ts4.FBE_Day_of_week__c == 'Monday'){
            tt2.pse__Monday_Hours__c = tt2.pse__Monday_Hours__c + ts4.TotalDurationInHours; 
        }
        else if(ts4.FBE_Day_of_week__c == 'Tuesday'){
            tt2.pse__Tuesday_Hours__c = tt2.pse__Tuesday_Hours__c + ts4.TotalDurationInHours; 
        }
        else if(ts4.FBE_Day_of_week__c == 'Wednesday'){
            tt2.pse__Wednesday_Hours__c = tt2.pse__Wednesday_Hours__c + ts4.TotalDurationInHours; 
        }
        else if(ts4.FBE_Day_of_week__c == 'Thursday'){
            tt2.pse__Thursday_Hours__c = tt2.pse__Thursday_Hours__c + ts4.TotalDurationInHours; 
        }
        else if(ts4.FBE_Day_of_week__c == 'Friday'){
            tt2.pse__Friday_Hours__c = tt2.pse__Friday_Hours__c + ts4.TotalDurationInHours; 
        }
        else if(ts4.FBE_Day_of_week__c == 'Saturday'){
            tt2.pse__Saturday_Hours__c = tt2.pse__Friday_Hours__c + ts4.TotalDurationInHours; 
        }
        else if(ts4.FBE_Day_of_week__c == 'Sunday'){
            tt2.pse__Sunday_Hours__c = tt2.pse__Sunday_Hours__c + ts4.TotalDurationInHours; 
        }
        updateTTMap.put(key,tt2);
        
    }
    
    /**************
* @ Method Name       : createTaskTimeFromTimecard
* @ Description       : This method is created to create Task Time when Time Sheet is Submitted based on Boomi unique Filter
*                       Created as part of Feature #8760856.
* @ CreatedBy         : Deloitte
* @ Modification Log  : Version 1.0 - [Namrata] : 
*********/
    public static void createTaskTimeFromTimecard(pse__Timecard_Header__c tc5 , Timesheet ts5,String key){
        try{
            if(ts5.FBE_Project__r.Id == null){
                pse__Task_Time__c tt3;
                if(createTTMap.get(key) != null)    
                    tt3 = createTTMap.get(key);
                else{
                    for(pse__Project_Task_Assignment__c pta :[SELECT Id,pse__Project_Task__c FROM pse__Project_Task_Assignment__c WHERE pse__Project_Task__c =: ts5.FBE_Service_Appointment__r.Work_Order__r.Project_Task__c ]){
                        tt3 = new pse__Task_Time__c();
                        tt3.pse__Timecard__c = tc5.Id;
                        tt3.pse__Project_Task__c = ts5.FBE_Service_Appointment__r.Work_Order__r.Project_Task__c;
                        tt3.pse__Project_Task_Assignment__c = pta.Id;
                    }
                    
                }
                if(ts5.FBE_Day_of_week__c == 'Monday'){
                    tt3.pse__Monday_Hours__c =  ts5.TotalDurationInHours; 
                }
                else if(ts5.FBE_Day_of_week__c == 'Tuesday'){
                    tt3.pse__Tuesday_Hours__c =  ts5.TotalDurationInHours;
                }
                else if(ts5.FBE_Day_of_week__c == 'Wednesday'){
                    tt3.pse__Wednesday_Hours__c =  ts5.TotalDurationInHours;
                }
                else if(ts5.FBE_Day_of_week__c == 'Thursday'){
                    tt3.pse__Thursday_Hours__c =  ts5.TotalDurationInHours;
                }
                else if(ts5.FBE_Day_of_week__c == 'Friday'){
                    tt3.pse__Friday_Hours__c =  ts5.TotalDurationInHours; 
                }
                else if(ts5.FBE_Day_of_week__c == 'Saturday'){
                    tt3.pse__Saturday_Hours__c =  ts5.TotalDurationInHours;
                }
                else if(ts5.FBE_Day_of_week__c == 'Sunday'){
                    tt3.pse__Sunday_Hours__c = ts5.TotalDurationInHours;   
                }
                createTTMap.put(key,tt3);
            }
        }Catch(Exception Ex){
            System.debug('Get Error ' +ex.getMessage() + 'Get Line Number ' +ex.getLineNumber());
        }
    }
    /**************
* @ Method Name       : createUpdateTimecard
* @ Description       : This method iscalled via Process builder when Time Sheet is Submitted to create/update Time card & Task Time
*                       Created as part of Feature #8760856.
* @ CreatedBy         : Deloitte
* @ Modification Log  : Version 1.0 - [Namrata] : 
*********/
    @InvocableMethod (label = 'Create or update Time Card record')
    public static List<TimeSheet> createUpdateTimecard(List<Id> timeSheetId){ //
        List<TimeSheet> lstTimeSheet = new List<TimeSheet>();
        List<pse__Timecard_Header__c> lstTimeCard =  new List<pse__Timecard_Header__c>();
        List<pse__Timecard_Header__c> lstTimeCardForAbsence =  new List<pse__Timecard_Header__c>();
        List<pse__Task_Time__c> lstTaskTime=  new List<pse__Task_Time__c>();
        List <String> dayOfWeek = new List <String>();
        Date ScheduleDate;
        String weekStartDate;  
        String uniqueBoomiId;
        String uniqueBoomiIdTaskTime;
        String uniqueBoomiId2;
        String uniqueBoomiGlobalId;
        String assignmentId ; 
        String globalProjectId;
        string projname;
        String badgeId ; 
        String badgeId2;
        String target;
        String replacement;
        String weekStartDate2;
        Date startDate ;
        String projectTask;
        Map <String , pse__Timecard_Header__c > mapBoomiIdVSTC= new Map <String , pse__Timecard_Header__c>();
        Map <String , pse__Timecard_Header__c > mapBoomiGlobalIdVSTC= new Map <String , pse__Timecard_Header__c>();
        Map <String , List<TimeSheet> > mapBoomiIdVSTS= new Map <String , List<TimeSheet>>();
        Map <String , List<TimeSheet> > mapBoomiGlobalIdVSTS= new Map <String , List<TimeSheet>>();
        Map <String , TimeSheet > mapBoomiIdTTVSTS= new Map <String , TimeSheet>();
        Map <String , pse__Task_Time__c > mapBoomiIdVSTT= new Map <String , pse__Task_Time__c>();
        
        lockTimeSheetEntryRecord(timeSheetId);
        
        lstTimeSheet =[SELECT Id, FBE_Service_Appointment__r.Assignment__c,
                       FBE_Service_Appointment__r.Assignee__r.Badge_ID__c,
                       FBE_Service_Appointment__c,
                       FBE_Service_Appointment__r.SchedStartTime,
                       FBE_Service_Appointment__r.FBE_Day_of_week__c,
                       FBE_Service_Appointment__r.Project__c,
                       FBE_Project__r.Id,
                       FBE_Project__r.pse__Start_Date__c,
                       FBE_Project__r.pse__End_Date__c,
                       FBE_Project__r.pse__Allow_Timecards_Without_Assignment__c,
                       TotalDurationInHours,
                       FBE_Day_of_week__c,
                       StartDate,
                       FBE_Service_Appointment__r.Work_Order__r.Project_Task__c,
                       ServiceResourceId, ServiceResource.Name,FBE_Project__r.Name,
                       ServiceResource.RelatedRecordId,
                       FBE_Service_Appointment__r.AppointmentType
                       FROM TimeSheet 
                       WHERE Id IN: timeSheetId];
        
        
        for(TimeSheet ts :lstTimeSheet){
            target ='00:00:00';
            replacement = '';
            weekStartDate = String.valueOf((ts.StartDate).toStartofWeek());
            weekStartDate2 = (weekStartDate.replace(target, replacement));
            
            if(ts.FBE_Service_Appointment__c != null && ts.FBE_Service_Appointment__r.AppointmentType != 'Shadow Appointment'){
                assignmentId =  String.valueOf(ts.FBE_Service_Appointment__r.Assignment__c).substring(0, 15);
                badgeId = ts.FBE_Service_Appointment__r.Assignee__r.Badge_ID__c;
                projectTask = String.valueOf(ts.FBE_Service_Appointment__r.Work_Order__r.Project_Task__c).substring(0, 15);
            }
            //For Non RUI //if(ts.FBE_Project__r.Id != null)
            else{
                for(Contact con :[Select Id,Badge_ID__c from Contact where name =: ts.ServiceResource.Name]){
                    projname = ts.FBE_Project__r.name;
                    globalProjectId = String.valueOf(ts.FBE_Project__r.Id).substring(0, 15);
                    badgeId2 = con.Badge_ID__c;
                }     
            }
            uniqueBoomiId = assignmentId + '-'+   weekStartDate2 + '-'+    badgeId; 
            uniqueBoomiIdTaskTime =  assignmentId + '-'+ weekStartDate2 + '-'+ badgeId + '-'+projectTask;
            uniqueBoomiGlobalId = projname + '-' + weekStartDate2 + '-' + badgeId2; 
            
            if(ts.FBE_Service_Appointment__c != null && ts.FBE_Service_Appointment__r.AppointmentType != 'Shadow Appointment'){
                if(mapBoomiIdVSTS.containsKey(uniqueBoomiId)) {
                    List<Timesheet> tsListMap = mapBoomiIdVSTS.get(uniqueBoomiId);
                    tsListMap.add(ts);
                    mapBoomiIdVSTS.put(uniqueBoomiId, tsListMap);
                } 
                else {
                    mapBoomiIdVSTS.put(uniqueBoomiId, new List<Timesheet> { ts });
                }                
            }
            if((ts.FBE_Project__c != null && ts.FBE_Service_Appointment__c == null) || (ts.FBE_Project__c != null && ts.FBE_Service_Appointment__r.AppointmentType == 'Shadow Appointment')){
                if(mapBoomiGlobalIdVSTS.containsKey(uniqueBoomiGlobalId)){
                    List<Timesheet> tsTempList = mapBoomiGlobalIdVSTS.get(uniqueBoomiGlobalId);
                    tsTempList.add(ts);
                    mapBoomiGlobalIdVSTS.put(uniqueBoomiGlobalId, tsTempList);                
                }
                else{
                    mapBoomiGlobalIdVSTS.put(uniqueBoomiGlobalId, new List<Timesheet> {ts}); 
                }               
            }
            
            mapBoomiIdTTVSTS.put(uniqueBoomiIdTaskTime ,ts);
         
            
        }
        
        lstTimeCard =[SELECT Id,
                      pse__Resource__c,
                      pse__Resource__r.Badge_ID__c,
                      pse__Assignment__c,
                      pse__Start_Date__c,
                      pse__Monday_Hours__c,
                      pse__Tuesday_Hours__c,
                      pse__Wednesday_Hours__c,
                      pse__Thursday_Hours__c,
                      pse__Friday_Hours__c,
                      pse__Saturday_Hours__c,
                      pse__Sunday_Hours__c,
                      Boomi_TC_Unique_ID__c
                      FROM pse__Timecard_Header__c
                      WHERE Boomi_TC_Unique_ID__c IN: mapBoomiIdVSTS.keySet()];
      
        
        lstTimeCardForAbsence = [ SELECT Id,
                                 pse__Resource__c,
                                 pse__Resource__r.Badge_ID__c,
                                 pse__Assignment__c,
                                 pse__Start_Date__c,
                                 pse__Monday_Hours__c,
                                 pse__Tuesday_Hours__c,
                                 pse__Wednesday_Hours__c,
                                 pse__Thursday_Hours__c,
                                 pse__Friday_Hours__c,
                                 pse__Saturday_Hours__c,
                                 pse__Sunday_Hours__c,
                                 Boomi_TC_Unique_ID_Global__c
                                 FROM pse__Timecard_Header__c
                                 WHERE Boomi_TC_Unique_ID_Global__c IN: mapBoomiGlobalIdVSTS.keySet()];
       
        
        lstTaskTime =[SELECT Id,
                      Boomi_TT_Unique_ID__c,
                      pse__Monday_Hours__c,
                      pse__Tuesday_Hours__c,
                      pse__Wednesday_Hours__c,
                      pse__Thursday_Hours__c,
                      pse__Friday_Hours__c,
                      pse__Saturday_Hours__c,
                      pse__Sunday_Hours__c,
                      pse__Timecard__c
                      FROM pse__Task_Time__c 
                      WHERE Boomi_TT_Unique_ID__c IN: mapBoomiIdTTVSTS.keySet()];
        
              System.debug('lstTimeTask'+lstTaskTime);
            

        for(pse__Timecard_Header__c tc : lstTimeCard){
            mapBoomiIdVSTC.put(tc.Boomi_TC_Unique_ID__c, tc);      
        }
        
        for(pse__Task_Time__c tt : lstTaskTime){
            mapBoomiIdVSTT.put(tt.Boomi_TT_Unique_ID__c, tt);    
            System.debug('Time Task List ::: ' +tt);
            System.debug(' Map :::' +mapBoomiIdVSTT);
        }
        
        for(pse__Timecard_Header__c tcAbsence : lstTimeCardForAbsence){
            mapBoomiGlobalIdVSTC.put(tcAbsence.Boomi_TC_Unique_ID_Global__c, tcAbsence );
        }
        for( String uniqueKey : mapBoomiIdVSTS.keyset() ){
            System.debug('inside 1st loop'+updateTCList);
            pse__Timecard_Header__c tc3 =  mapBoomiIdVSTC.get(uniqueKey);
            List<Timesheet> tsListNew = mapBoomiIdVSTS.get(uniqueKey);
            //As part of Defect 11749874 below code is not required - commented by Sivakumari 
          /*  if(tc3!= null ){
                System.debug('inside tc3'+tc3);
                if(tc3.id != null){*
                    for(Timesheet ts2 : tsListNew){
                        //if(ts2.FBE_Project__c == null){ //For Non Rui
                        tc3 = updateTimeCard (tc3,ts2); 
                        String projectTask2 = String.valueOf(ts2.FBE_Service_Appointment__r.Work_Order__r.Project_Task__c).substring(0, 15);
                        String key =  uniqueKey + '-'+ projectTask2;
                        System.debug('key TT'+key);
                        pse__Task_Time__c tt2 = mapBoomiIdVSTT.get(key);
                        System.debug(' TASK TIME :::: ' +tt2);
                        if(tc3!= null && tt2 != null){
                           // if(tt2.Id != null){
                                updateTCList.add(tc3);
                                updateTaskTime(tt2,ts2,uniqueKey);
                                System.debug('@@427 ### update Task Time ' +tt2 + 'Timesheet' +ts2 + 'UniqueKey' +uniqueKey);
                            }
                      //  }
                       /* else{
                            createTaskTimeFromTimecard(tc3,ts2,uniqueKey);
                             System.debug('@@432 ### insert Task Time ' +tc3 + 'Timesheet' +ts2 + 'UniqueKey' +uniqueKey);
                        }  
                        //}
                    }
                    
                    updateTCList.add(tc3);
                }
            }
            else{*/
                createTimeCard(tsListNew,uniqueKey);  
                
            //}                                   
        }  
        //For Non RUI
        for(String uniqueGlobalKey : mapBoomiGlobalIdVSTS.keySet()){ 
            pse__Timecard_Header__c tc = mapBoomiGlobalIdVSTC.get(uniqueGlobalKey);
            List<TimeSheet> tsList = mapBoomiGlobalIdVSTS.get(uniqueGlobalKey);
            if(tc !=null && tc.Id != null){
                for(TimeSheet ts : tsList){ 
                    tc = updateTimeCard(tc,ts);                                   
                }
                updateTCList.add(tc);
            }
            else{
                createTimeCard(tsList,uniqueGlobalKey);
            }     
        }  //end of NON rui loop
       
        if(!createTCList.isEmpty() ){
            List<Database.SaveResult> createTimeCardResult = Database.insert(createTCList,false);
            System.debug('TC List : ' +createTCList);
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(createTCList, createTimeCardResult, 'FBE_SetTimeCard', 'Create Time Card') );
            
            if(!exceptionLoggers.isEmpty()){
                upsert exceptionLoggers;
            }
            //insert createTCList;
        } 
        
        for(pse__Timecard_Header__c tcCreated :createTCList){
            System.debug('inside tc'+tcCreated);
            uniqueBoomiId2 = tcCreated.Boomi_TC_Unique_ID__c;
            System.debug('Unique Key ::::: ' +uniqueBoomiId2);
            List<TimeSheet> tsList = mapBoomiIdVSTS.get(uniqueBoomiId2);
            if(tsList != null && tsList.size() > 0){
                for(Timesheet ts : tsList){
                    if(ts.FBE_Project__c == null){
                        String uniqueKey2 = uniqueBoomiId2 + ts.FBE_Service_Appointment__r.Work_Order__r.Project_Task__c;
                        createTaskTimeFromTimecard(tcCreated,ts,uniqueKey2);
                    }
                }    
            }
        }
        
        if(createTTMap.values().size() > 0){
            List<Database.SaveResult> CreateTaskTimeResult = Database.insert(createTTMap.values(),false);
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(createTTMap.values(), CreateTaskTimeResult, 'FBE_SetTimeCard', 'Create Task Time') );
            if(!exceptionLoggers.isEmpty()){
                upsert exceptionLoggers;
            }
            //insert createTTMap.values();
        }
        
        if(!updateTCList.isEmpty()){ 
            List<Database.SaveResult> updateTimeCardResult = Database.update(updateTCList,false);
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(updateTCList, updateTimeCardResult, 'FBE_SetTimeCard', 'update Time Card') );
            
            if(!exceptionLoggers.isEmpty()){
                upsert exceptionLoggers;
            }
            //update updateTCList;
        }
        
        if(updateTTMap.values().size() > 0){
            List<Database.SaveResult> updateTaskTimeResult = Database.update(updateTTMap.values(),false);
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(updateTTMap.values(), updateTaskTimeResult, 'FBE_SetTimeCard', 'update Task Time') );
            if(!exceptionLoggers.isEmpty()){
                upsert exceptionLoggers;
            }
            //update updateTTMap.values();
        }
        return lstTimeSheet;
    }
    
    //Added By Mayuri Hegde for Defect 11477765 to populate the Actual Approver on Timcard
    public static void updateApproveronTimecard(){
        Set<Id> tcset = new Set<Id>();
        List<pse__Timecard_Header__c> timcardList = new List<pse__Timecard_Header__c>();
        timcardList = [SELECT Id, Name, pse__Approved__c, pse__Approver__c, pse__Resource__c, pse__Status__c FROM pse__Timecard_Header__c Where pse__Approved__c = True AND pse__Status__c = 'Approved'];
        for(pse__Timecard_Header__c tc : timcardList){
            tcset.add(tc.Id);
            System.debug('tcset'+tcset);
        }
        List<pse__Timecard_Header__c> tcList = [Select Id, Name, pse__Approver__c, (Select TargetObjectId, LastActorId From ProcessInstances) from pse__Timecard_Header__c where Id=: tcset];
        System.debug('tcList'+tcList);
        for(pse__Timecard_Header__c tc : tcList){
            if(!tcList.isEmpty()){
                for(ProcessInstance pi : tc.ProcessInstances){
                    System.debug('Approver'+tc.pse__Approver__c);
                    tc.pse__Approver__c = pi.LastActorId;
                    System.debug('Approver'+tc.pse__Approver__c);
                    System.debug('Approver'+pi.LastActorId);
                }
            }
        }
        update tcList;
    }
    
    //Added By Mayuri Hegde for Defect 11477765 to populate the Approver Field on Timcard
    public static void setApprover(List<pse__Timecard_Header__c> newtcList){
        Set<Id> userset = new Set<Id>();
        Set<Id> projset = new Set<Id>();
        Map<Id, Id> mapProjectIdToManagerId = new Map<Id, Id> ();
        List<User> userList = [SELECT Id, FBE_IDS_User_Profile_Name__c FROM User Where FBE_IDS_User_Profile_Name__c = 'PSA Project Manager'];
        for(User u : userList){
            userset.add(u.Id);
        }
        for(pse__Timecard_Header__c tc : newtcList){
            if(! newtcList.isEmpty() && tc.pse__Project__c != null){
                projset.add(tc.pse__Project__c);
                System.debug('projset'+projset);
            }
        }
        List<pse__Proj__c> projList = [Select Id, pse__Project_Manager__c, pse__Project_Manager__r.pse__Salesforce_User__c From pse__Proj__c Where Id=: projset];
        for(pse__Proj__c pro : projList){
            if(! projList.isEmpty() && pro.pse__Project_Manager__r.pse__Salesforce_User__c != null){
                mapProjectIdToManagerId.put(pro.Id, pro.pse__Project_Manager__r.pse__Salesforce_User__c); 
            }
        }
        for(pse__Timecard_Header__c tc : newtcList){
            if(! newtcList.isEmpty()){
                if(!userset.isEmpty() && userset.contains(tc.OwnerId)){
                    tc.pse__Approver__c = tc.PDM_User__c;
                    System.debug('Approver@@'+tc.pse__Approver__c);
                } else {
                    if(!mapProjectIdToManagerId.isEmpty() && mapProjectIdToManagerId.containsKey(tc.pse__Project__c)){
                        tc.pse__Approver__c = mapProjectIdToManagerId.get(tc.pse__Project__c);
                        System.debug('Approver'+ tc.pse__Approver__c);
                    }
                }
            }
        }
    }
}