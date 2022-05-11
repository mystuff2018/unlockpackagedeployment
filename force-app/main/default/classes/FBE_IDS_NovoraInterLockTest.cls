@isTest
public class FBE_IDS_NovoraInterLockTest {
    @testSetup
    static void testDataSetup(){
       
       User loginUser =  [Select Id from User where FBE_Integration_User__c = true];
          system.runAs(loginUser){ 
      
              pse__Proj__c projectTemplate = new pse__Proj__c(
                  Name='Phased Project Template - Custom - Global',
                  pse__Is_Template__c = true,
                  pse__Is_Active__c = true,
                  pse__Start_Date__c = Date.today()
              );
              insert projectTemplate;
               
            pse__Practice__c testPractice = new pse__Practice__c(
                Name = 'Test Practice',
                Standard_Project_Template__c = projectTemplate.Id
                
            );
            insert testPractice;
            
            pse__Region__c testRegion = new pse__Region__c(
                Name = 'Test Region'
            );
            insert testRegion;
            
          
            Contact testContact = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact',
                Primary_Phone__c = '555-5555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
                
            );
           
            insert testContact;
  
            pse__Permission_Control__c testPermission = new pse__Permission_Control__c(
                pse__User__c = loginUser.id,
                pse__Region__c = testRegion.id,
               // pse__Practice__c = testPractice.id,
                pse__Cascading_Permission__c = true,
                pse__Resource_Request_Entry__c = true,
                pse__Timecard_Entry__c = true,
                pse__Timecard_Ops_Edit__c =true,
                pse__Staffing__c = true   
                
            );
         
            insert testPermission;
              
        
              
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = testContact.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Closed_for_Time_Entry__c = false,
                Integration_Status__c = System.Label.FBE_IDS_IntegrationStatus,
                pse__Is_Active__c = true
            );
           
            insert testProject;
              
                           
            pse__Schedule__c testSchedule = new pse__Schedule__c(
                   	pse__Start_Date__c = system.today(),
                	pse__End_Date__c = system.today()+30
            );
            insert testSchedule;
            
            
             pse__Assignment__c testAssignment = new pse__Assignment__c(
                 Name = 'Test Assignment',
                 pse__Resource__c = testContact.Id,
                 pse__Project__c = testProject.Id,
                 pse__Schedule__c = testSchedule.id,
                 pse__Bill_Rate__c = 0,
                 pse__Cost_Rate_Amount__c = 1000
            );
            
            Insert testAssignment;
            
                pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 30,
                pse__Estimated_Hours__c = 8,
                pse__Description__c = 'Test Description',
                pse__Started__c = true,
                FBE_IDS_Task_IntegrationStatus__c = System.Label.FBE_IDS_IntegrationStatus,
                pse__Project__c = testProject.Id
            );
  
            insert testProjectTask;
            
            testProjectTask.pse__Project__c = testProject.Id;
            testProjectTask.FBE_IDS_Task_IntegrationStatus__c= 'test1';
            update testProjectTask;
              
              
            
           pse__Project_Task_Assignment__c taskAsigmnt = new pse__Project_Task_Assignment__c(
                pse__Resource__c = testContact.Id,
                pse__Project_Task__c = testProjectTask.id,
                FBE_IDS_Assignment_IntegrationStatus__c = System.Label.FBE_IDS_IntegrationStatus
            );
          //  insert taskAsigmnt;
                    
              
              FBE_IDS_NovoraInterLock.updateProjectTask(testProjectTask);
              FBE_IDS_NovoraInterLock.updateProjectTaskAsigmnt(taskAsigmnt);      
             Test.startTest();
            Set<Id> projIds = new Set<Id>();            
            list<pse__Proj__c> s = [select id,pse__Stage__c from pse__Proj__c where id =:testProject.id];
            s[0].BUID__c = '12';
            s[0].Local_Channel__c = 'US-52';
            s[0].pse__Project_Phase__c ='Initiate';
            s[0].pse__Stage__c ='In Progress';
            update s;
            Map<Id, pse__proj__c> oldProj = new map<id,pse__proj__c>();  
            oldProj.put(testProject.id,testProject);
            Map<Id, pse__proj__c> newProj = new map<id,pse__proj__c>(s);
            
           
            PageReference pgRef = new PageReference('/apex/pse__proj__c'); 
            Test.setCurrentPage(pgRef); 
            id projectId = ApexPages.currentPage().getParameters().put('id', testProject.id);
            projIds.add(projectId);
            if(projIds.size()>0){
                FBE_IDS_NovoraInterLock.projectTasksToProcess(projIds);
                FBE_IDS_NovoraInterLock.projectTaskAsignmtToProcess(projIds);  
                          }            
            FBE_IDS_NovoraInterLock.sendProjectAsignmtToNovora(oldProj, newProj);
            FBE_IDS_NovoraInterLock.runOnceNovoraInterlocks();
            Test.stopTest();
        }
        
    }
    
 
    
     @isTest
     static void testProjectforNovora(){ 
      
        pse__Proj__c projects = [select Id, pse__Project_Phase__c, pse__Practice__c, pse__Region__c from pse__Proj__c Limit 1];
      
        Set<Id> projIds = new Set<Id>();
        Map<Id, pse__proj__c> oldProj;
        Map<Id, pse__proj__c> newProj;
         
       
        List<pse__proj__c> projList = new  List<pse__proj__c>();
        projList.add(projects);
      
        PageReference pgRef = new PageReference('/apex/pse__proj__c'); 
        Test.setCurrentPage(pgRef); 
        id projectId = ApexPages.currentPage().getParameters().put('id', projects.id);
        projIds.add(projectId);
        if(projIds.size()>0){
            Boolean isBefore = false;
            FBE_IDS_NovoraInterLock.projectTasksToProcess(projIds);
            FBE_IDS_NovoraInterLock.projectTaskAsignmtToProcess(projIds); 
            FBE_IDS_NovoraInterLock.sendProjectAsignmtToNovora(oldProj, newProj);
            FBE_IDS_NovoraInterLock.runOnceNovoraInterlocks();
              }
        
    }
    
      
    @isTest
    static void testProjectTaskAssignmentforNovora(){
     
        List<pse__Project_Task_Assignment__c> assignmentList = [select id,FBE_IDS_Assignment_IntegrationStatus__c, 
                                                                pse__Project_Task__c, 
                                                                pse__Project_Task__r.pse__Project__c,  
                                                                pse__Project_Task__r.pse__Assigned_Resources__c  
                                                                from pse__Project_Task_Assignment__c Limit 1];
        
        FBE_IDS_NovoraInterLock.beforeInsertAndUpdateOnPrjTaskAssignmt(assignmentList); 
        Update assignmentList;     
       
    }
    

    @isTest
     static void testTimecardHeder(){
       
        pse__Proj__c projects = [select Id, Name, pse__Project_Phase__c, 
                                 pse__Practice__c, pse__Region__c from pse__Proj__c Where Name = 'Test project' Limit 1];
              
        Set<Id> projIds = new Set<Id>(); 
        projIds.add(projects.Id);      
      
        List<pse__Timecard_Header__c> timcardList = [SELECT id, pse__Project__c, pse__Project__r.Name, 
                                                     pse__Project__r.pse__Start_Date__c, 
                                                     pse__Project__r.pse__End_Date__c, pse__Start_Date__c,
                                                     pse__End_Date__c,FBE_IDS_Time_IntegrationStatus__c,
                                                     pse__Status__c FROM pse__Timecard_Header__c 
                                                     Where pse__Project__c IN :projIds
                                                     Limit 1];
         Test.startTest();
         List<pse__Timecard_Header__c> tcList = new List<pse__Timecard_Header__c>();
         for(pse__Timecard_Header__c tc : timcardList){
             tc.FBE_IDS_Time_IntegrationStatus__c = 'Test Sync';
             tcList.add(tc);
         }
             FBE_IDS_NovoraInterLock.SendTimecardDetailsToNovora(tcList);
             Update tcList ;
             Test.stopTest();
         
         
     }
 
    @isTest
    static void testprojectTaskDelete(){ 
        list<pse__Project_Task__c> taskList = new list<pse__Project_Task__c>();
        pse__Project_Task__c testTask = [Select id,pse__Task_Number__c, isDeleted,pse__Start_Date_Time__c,pse__End_Date_Time__c,
                                         pse__Description__c,pse__Started__c,pse__Project__c,pse__Parent_Task__c,
                                         pse__Start_Date__c,pse__End_Date__c
                                         from pse__Project_Task__c Limit 1];
        taskList.add(testTask);
        
        Project_Task_Delete__c taskDelte = new Project_Task_Delete__c();
        taskDelte.Task_Number__c = testTask.pse__Task_Number__c;  
        taskDelte.IsDeleted__c = true;
        taskDelte.Project_ID__c = testTask.pse__Project__c; 
        taskDelte.Start_Date__c = String.valueOf(testTask.pse__Start_Date__c);
        taskDelte.End_Date__c =  String.valueOf(testTask.pse__End_Date__c);
        taskDelte.Description__c = testTask.pse__Description__c;
        taskDelte.Completed__c = true;
        taskDelte.Parent_Task__c = testTask.pse__Parent_Task__c;
        taskDelte.IntegrationStatus__c = 'Test Sync';
        insert taskDelte;
         
        FBE_IDS_NovoraInterLock.processDeletedProjectTasks(taskList);  
      
    }
    
 
}