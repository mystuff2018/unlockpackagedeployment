// ShivaKumari Novora InterLock -  Feature 8432644 
public class FBE_IDS_NovoraInterLock {
    private static boolean run = true;
    private static boolean runBeforeUpdate = true;
    
    
    public Static Void projectDetailsToNovora(List<pse__proj__c> projectNew, Map<id,pse__proj__c> oldMap,boolean isBefore){
        Set<Id> filteredProjectsIds = new Set<Id>();
        
        List<pse__proj__c> projectsToUpdate = new List<pse__proj__c>();
        try{
            Map<String,Integer> phasePriority = new Map<String,Integer>(); 
            phasePriority.put('Setup',1);
            phasePriority.put('Initiate',2);
            phasePriority.put('Plan',3);
            phasePriority.put('Execute',4);
            phasePriority.put('Close',5);
            for(pse__Proj__c proj : projectNew){
                if(proj.pse__Project_Phase__c != 'SetUp' && oldMap.get(proj.Id).pse__Project_Phase__c != proj.pse__Project_Phase__c && phasePriority.get(oldMap.get(proj.Id).pse__Project_Phase__c) < phasePriority.get(proj.pse__Project_Phase__c)){
                    if(isBefore){
                        proj.Integration_Status__c = System.Label.FBE_IDS_IntegrationStatus;
                    }else{
                        filteredProjectsIds.add(proj.id);    
                    }
                }
                
            }
            if(filteredProjectsIds.size() > 0){
                projectTasksToProcess(filteredProjectsIds);     
                projectTaskAsignmtToProcess(filteredProjectsIds);    
              //  projectTimeCardsToProcess(filteredProjectsIds);
            }
        }Catch(Exception Ex){
            System.debug('Get Error ' +ex.getMessage() + 'Get Line Number ' +ex.getLineNumber());
        }
        
    }
    
    public static void projectTasksToProcess(Set<ID> projectIds){
        List<pse__Project_Task__c> projTaskToUpdate = new List<pse__Project_Task__c>();
        for(pse__Project_Task__c projTask : [select id, FBE_IDS_Task_IntegrationStatus__c from pse__Project_Task__c where pse__Project__c IN : projectIds]){ 
            projTaskToUpdate.add(updateProjectTask(projTask));
           
        }
        if(projTaskToUpdate.size() > 0){
            UPDATE projTaskToUpdate;
        }
    }
    
    
    public static pse__Project_Task__c updateProjectTask(pse__Project_Task__c projTask){
        projTask.FBE_IDS_Task_IntegrationStatus__c = String.escapeSingleQuotes(System.Label.FBE_IDS_IntegrationStatus); //Added escapeSingleQuotes as a part of CheckMarx
        return projTask;
    }
    
    
    public static void projectTaskAsignmtToProcess(Set<ID> projectIds){
        List<pse__Project_Task_Assignment__c> projTaskAsignmtToUpdate = new List<pse__Project_Task_Assignment__c>(); 
        for(pse__Project_Task_Assignment__c projTaskAsigmnt : [select id,FBE_IDS_Assignment_IntegrationStatus__c, 
                                                               pse__Project_Task__c, 
                                                               pse__Project_Task__r.pse__Project__c,  
                                                               pse__Project_Task__r.pse__Assigned_Resources__c  
                                                               from pse__Project_Task_Assignment__c 
                                                               where pse__Project_Task__r.pse__Project__c IN : projectIds ]){      
                                                                   projTaskAsignmtToUpdate.add(updateProjectTaskAsigmnt(projTaskAsigmnt));
                                                                   
                                                               }
        
        
        if(projTaskAsignmtToUpdate.size() > 0){
            UPDATE projTaskAsignmtToUpdate;
        }
        
    }
    public static pse__Project_Task_Assignment__c updateProjectTaskAsigmnt(pse__Project_Task_Assignment__c projTaskAsigmnt){
        projTaskAsigmnt.FBE_IDS_Assignment_IntegrationStatus__c = String.escapeSingleQuotes(System.Label.FBE_IDS_IntegrationStatus); //Added escapeSingleQuotes as a part of CheckMarx
        return projTaskAsigmnt;
    }


    public static void processDeletedProjectTasks(List<pse__Project_Task__c> projTaskDeleted){
      
        List<Project_Task_Delete__c> toInsertTask = new List<Project_Task_Delete__c>();
        for(pse__Project_Task__c deleteTask : projTaskDeleted){
         
            Project_Task_Delete__c backup = new Project_Task_Delete__c();
            backup.Task_Number__c = deleteTask.pse__Task_Number__c;  
            backup.IsDeleted__c = true;
            backup.Project_ID__c = deleteTask.pse__Project__c;
            //Added for Defect
          if(deleteTask.pse__Start_Date__c != null){
                String dt = string.valueOf(deleteTask.pse__Start_Date__c);
                backup.Start_Date__c =  dt;
              
            }
            if(deleteTask.pse__End_Date__c != null){
                String dts = string.valueOf(deleteTask.pse__End_Date__c); 
                backup.End_Date__c = dts;
              
            }
            backup.Description__c = deleteTask.pse__Description__c;
            backup.Completed__c = true;
            backup.Parent_Task__c =  deleteTask.pse__Parent_Task__c;
            backup.IntegrationStatus__c = System.Label.FBE_IDS_IntegrationStatus;
            toInsertTask.add(backup);
            
        }
        if(toInsertTask.size()>0){
            insert toInsertTask;
            
        }
    }
    
    //New task assignment created on project task and project stage in not equal to Draft
    Public Static Void beforeInsertAndUpdateOnPrjTaskAssignmt(list<pse__Project_Task_Assignment__c> prjTskList){
        User currentuser = [Select Id,Name,Email,alias from User where Id=:userinfo.getuserId()];
       
        set<id> projectTaskId = new set<id>();
        for(pse__Project_Task_Assignment__c p : prjTskList){
            projectTaskId.add(p.pse__Project_Task__c);
        }
        
        List<pse__Project_Task__c> pTaskList =  [SELECT id, FBE_IDS_Task_IntegrationStatus__c,
                                                 pse__Project__r.pse__Stage__c,
                                                 pse__Project__c FROM pse__Project_Task__c 
                                                 WHERE id IN :projectTaskId]; 
        
      
        if(pTaskList.size() > 0){
            for(pse__Project_Task__c ptask : pTaskList){ 
                if(currentuser.Alias != 'boomi'){      
                if(ptask.pse__Project__c != null && ptask.pse__Project__r.pse__Stage__c != 'Draft' ){
                    for(pse__Project_Task_Assignment__c pta : prjTskList){
                        pta.FBE_IDS_Assignment_IntegrationStatus__c = System.Label.FBE_IDS_IntegrationStatus;
                        
                    }
                }
            }
            }
        }
    }
    
    
    
    // Shiva - Feature - 8432644 
    // Shiva - Novora Interlock - Send Assignment Details If it is already exisitng 
    // and stage is modified from Draft to InProgress (Update on Project)
    
    Public static void sendProjectAsignmtToNovora(map<Id,pse__proj__c> oldMap, map<id,pse__proj__c> newMap){
        
        list<pse__Project_Task_Assignment__c> projTaskAsignmtList = new list<pse__Project_Task_Assignment__c>();
        Map<id,pse__Project_Task_Assignment__c> listofAssignmentMap = new Map<id,pse__Project_Task_Assignment__c>();
        List<pse__Project_Task_Assignment__c> listofAssignments;
        set<Id> prjIds=new set<Id>();
        
        try{
            for(Id key :oldMap.keySet()){
                pse__proj__c old = oldMap.get(key);
                pse__proj__c newproj = newMap.get(key);
                if(old.pse__Stage__c!= newproj.pse__Stage__c ){
                    if(old.pse__Stage__c == 'Draft' && newproj.pse__Stage__c == 'In Progress'){ 
                        prjIds.add(newproj.id);         
                    }
                }
            }      
            
            listofAssignments =  [select id,FBE_IDS_Assignment_IntegrationStatus__c, 
                                  pse__Project_Task__c, 
                                  pse__Project_Task__r.pse__Project__c,  
                                  pse__Project_Task__r.pse__Assigned_Resources__c  
                                  FROM pse__Project_Task_Assignment__c 
                                  WHERE pse__Project_Task__r.pse__Project__c IN : prjIds ]; 
            
            for(pse__Project_Task_Assignment__c pt : listofAssignments){  
                if(pt != null && pt.pse__Project_Task__r.pse__Project__c != null){
                    listofAssignmentMap.put(pt.pse__Project_Task__r.pse__Project__c,pt);
                    
                }else if(pt == null || pt.pse__Project_Task__r.pse__Project__c  == null){        
                    listofAssignmentMap.put(pt.pse__Project_Task__r.pse__Project__c,pt);     
                }
            }
            
            for(pse__Project_Task_Assignment__c taskAsignmt : listofAssignmentMap.values()){
                if(listofAssignmentMap.containsKey(taskAsignmt.pse__Project_Task__r.pse__Project__c)){
                    listofAssignmentMap.get(taskAsignmt.pse__Project_Task__r.pse__Project__c);
                    taskAsignmt.FBE_IDS_Assignment_IntegrationStatus__c = System.Label.FBE_IDS_IntegrationStatus;
                    projTaskAsignmtList.add(taskAsignmt);   
                }     
                
            }
            if(projTaskAsignmtList.size() > 0){
                update projTaskAsignmtList;
            }
            
        }catch(Exception Ex){
            System.debug('@@205 Get Error ' +ex.getMessage() + 'Get line ' +ex.getLineNumber());
        }
    }
    
 
   
    public Static void SendTimecardDetailsToNovora(List<pse__Timecard_Header__c> newTimeList){
        User currentuser = [Select Id,Name,Email,alias from User where Id=:userinfo.getuserId()];
        List<pse__Timecard_Header__c> newList = new list<pse__Timecard_Header__c>();
        Set<ID> projectIds = new Set<ID>();
        for(pse__Timecard_Header__c th : newTimeList){
            projectIds.add(th.pse__Project__c);
        }
        
        for(pse__Timecard_Header__c tm : [SELECT id, pse__Project__c, pse__Project__r.Name, pse__Project__r.pse__Start_Date__c, 
                                          pse__Project__r.pse__End_Date__c, pse__Start_Date__c,
                                          pse__End_Date__c,FBE_IDS_Time_IntegrationStatus__c,
                                          pse__Status__c FROM pse__Timecard_Header__c 
                                          WHERE pse__Project__c IN :projectIds]){
                                              if(currentuser.Alias != 'boomi' && tm.pse__Project__r.Name !='Job Shadowing' ){
                                                 System.debug('Boomi User ### ' +currentuser.Alias);
                                                  if(tm.pse__Start_Date__c > tm.pse__Project__r.pse__Start_Date__c && tm.pse__End_Date__c < tm.pse__Project__r.pse__End_Date__c){    
                                                      tm.FBE_IDS_Time_IntegrationStatus__c = System.Label.FBE_IDS_IntegrationStatus;
                                                      newList.add(tm);                  
                                                  }else if(currentuser.Alias == 'boomi'){
                                                      tm.FBE_IDS_Time_IntegrationStatus__c = '';   
                                                       System.debug('status ### ' + tm.FBE_IDS_Time_IntegrationStatus__c );
                                                  }
                                              }
                                          }
        
        
        if(!newList.isEmpty()){
            update newList;
        }
    }
    
     
    public static boolean runOnceNovoraInterlocks(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
    
    public static boolean runOnceNovoraBeforeUpdate(){
        if(runBeforeUpdate) {
            runBeforeUpdate = false;
            return true;
        }
        else {
            return runBeforeUpdate;
        }
    }
}