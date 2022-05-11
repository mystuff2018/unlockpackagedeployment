@isTest
public class FBE_SetTimeCard_Test {  
    @isTest
    static void testTimeCardCreation(){
        List<Id> timeSheetIdList = new List<Id>();
        pse__Timecard_Header__c tc = new pse__Timecard_Header__c();
        List<Contact> contactList = new List<Contact>();
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // if(!Test.isRunningTest()){
            String Key = 'Test';
            String Key2 = 'Test12345';
            List<Account> accountList = FBE_Test_Utility.createAccount(1);
            insert accountList;
            
            Contact contactOne = new Contact(
                FirstName = 'Test Contact',
                LastName = 'One',
                Phone = '9876567890',
                Email = 'test@testone.com',
                Badge_ID__c = '483426',
                AccountId = accountList[0].Id,
                pse__Is_Resource_Active__c = True,
                pse__Is_Resource__c =True,
                pse__Salesforce_User__c = loginUser[0].Id
            );
            
            contactList.add(contactOne);
            insert contactList;            
            
            List<ServiceResource> srList = FBE_Test_Utility.createServiceResource(1, loginUser);
            insert srList;
            System.debug('srList'+srList);
            List<pse__Proj__c> projList = FBE_Test_Utility.createProject(1);
            insert projList;
            
            //List<pse__Practice__c> practiceList =[Select Id,name from pse__Practice__c where name='Global Practice'];
            List<pse__Practice__c> practiceList = FBE_Test_Utility.createPractice();
            insert practiceList;
            
            
            List<pse__Permission_Control__c> pcPracticeList = FBE_Test_Utility.createPermissionControlForPractice(1, practiceList, loginUser);
            insert pcPracticeList; 
            
            List<pse__Permission_Control__c> pcResourceList = FBE_Test_Utility.createPermissionControlForResource(1, contactList, loginUser);
            insert pcResourceList;
            
            List<pse__Permission_Control__c> pcProjectList = FBE_Test_Utility.createPermissionControlForProject(1, projList, loginUser);
            insert pcProjectList;
            
            
            List<pse__Schedule__c> scheduleList = FBE_Test_Utility.createSchedule(1);
            insert scheduleList;
            
            List<pse__Assignment__c> assignmentList = FBE_Test_Utility.createAssignment(1, contactList, projList, scheduleList,NULL);
            insert assignmentList; 
            
            List<pse__Project_Task__c> ptList = FBE_Test_Utility.createProjectTask(1, projList);
            insert ptList;
            
            pse__Project_Task_Assignment__c pseTaskAssignment = new pse__Project_Task_Assignment__c();
            pseTaskAssignment.pse__Project_Task__c = ptList[0].Id;
            pseTaskAssignment.pse__Resource__c = contactList[0].Id;
            pseTaskAssignment.pse__Resource__r = contactList[0];
            insert pseTaskAssignment;
            System.debug('pseTaskAssignment'+pseTaskAssignment);
            
            List<WorkOrder> woList = FBE_Test_Utility.createWorkOrder(1,ptList);
            insert woList;
            
            List<ServiceAppointment> saList = FBE_Test_Utility.createServiceAppointment(1, woList, assignmentList, contactList, projList);
            insert saList;
            
            TimeSheet tss = new TimeSheet();
            tss.StartDate = System.today();
            tss.EndDate = (System.today() + 7) ;
            tss.ServiceResourceId = srList[0].Id; 
            tss.FBE_Service_Appointment__c =saList[0].Id;
            tss.Status = 'New';
            insert tss;
            
            List<pse__Project_Task_Assignment__c> ptalist = [SELECT Id, pse__Project_Task__c FROM pse__Project_Task_Assignment__c Where pse__Project_Task__c =: ptList];
			System.debug('ptalist'+ptalist);
            List<TimeSheet> tsList = FBE_Test_Utility.createTimeSheet(7, srList, saList);
            insert tsList;
            SYstem.debug('tsList===='+tsList);
            
            for(TimeSheet ts : tsList){
                timeSheetIdList.add(ts.Id);   
            }  
            
            
            /**   List<TimeSheet> tsList2 = FBE_Test_Utility.createTimeSheet(7, srList, saList);
insert tsList2; **/
            
            Test.startTest(); 
            List<pse__Timecard_Header__c> tcList = FBE_Test_Utility.createTimeCard(1,contactList, projList, assignmentList);
            insert tcList;
            
            pse__Task_Time__c tt = new pse__Task_Time__c();
            List<pse__Task_Time__c> ttList = FBE_Test_Utility.createTaskTime(1,tcList,ptList);
            insert ttList;
            
            // Contact con =[Select Id,pse__Salesforce_User__c from Contact where pse__Salesforce_User__c =: tsList[0].ServiceResource.RelatedRecordId limit 1];
            
            tc.pse__Project__c =  tsList[1].FBE_Project__r.Id; 
            tc.pse__Resource__c = contactOne.id;
            tc.Boomi_TC_Unique_ID_Global__c = 'test';
            tc.Boomi_TC_Unique_ID__c = 'test2';
            
            List<TimeSheet> lstTimeSheet =[SELECT Id, FBE_Service_Appointment__r.Assignment__c,
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
                                           FROM TimeSheet WHERE id in:tsList
                                           LIMIT 1];
            
            System.debug('lstTimeSheet'+lstTimeSheet);
            /** for(TimeSheet ts : lstTimeSheet){
timeSheetIdList.add(ts.Id);   
} **/
            
            pse__Timecard_Header__c tc3 =[SELECT Id,
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
                                          WHERE Id =:tcList[0].Id];
            
            pse__Task_Time__c ttNew = [SELECT Id,
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
                                       WHERE ID=:ttList[0].Id]; 
            
            
            pse__Task_Time__c tt2 = [SELECT Id,
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
                                     WHERE ID=:ttList[0].Id];
            
            /**  pse__Timecard_Header__c tc2 = new pse__Timecard_Header__c();
tc2.pse__Project__c =  tsList[2].FBE_Project__r.Id; 
tc2.Boomi_TC_Unique_ID__c ='Test4'; 

tc2.Boomi_TC_Unique_ID_Global__c ='Test5';
tc2.pse__Resource__c = contactOne.id;
tc2.pse__Monday_Hours__c = 2;  
tc2.pse__Tuesday_Hours__c =  2; 
tc2.pse__Wednesday_Hours__c = 2; 
tc2.pse__Thursday_Hours__c = 2;  **/
            
            
            
            System.debug('timeSheetIdList'+timeSheetIdList);
            FBE_SetTimeCard.lockTimeSheetEntryRecord(timeSheetIdList);
            
            FBE_SetTimeCard.createUpdateTimecard(timeSheetIdList);
            //List<TimeSheet> tsList3 = FBE_Test_Utility.createTimeSheet(7, srList, Null);
            //insert tsList3;
            
            /* List<TimeSheet> tsList4 = new List<TimeSheet>();
//for(int i=0;i<=7;i++){
TimeSheet ts3 = new TimeSheet();
ts3.StartDate = (System.today()).addDays(1);
ts3.EndDate = (System.today()).addDays(1) ;
ts3.ServiceResourceId = srList[0].Id; 
ts3.FBE_Service_Appointment__c =Null;
ts3.Status = 'New';
tsList4.add(ts3);
// }
insert tsList4;

FBE_SetTimeCard.createTimeCard(tsList4, key ); */
            for(Timesheet timesheet : lstTimeSheet){
                for(pse__Timecard_Header__c tch : tcList ){
                    FBE_SetTimeCard.updateTimeCard(tch,timesheet); 
                }
                
            } 
            for(Timesheet timesheet : lstTimeSheet){
                FBE_SetTimeCard.updateTaskTime(tt2,timesheet,key2);
            }
            
            FBE_SetTimeCard.createTaskTimeFromTimecard(tc,tss,key);
            
            FBE_SetTimeCard.updateTimeCard(tc,tss);
            //FBE_SetTimeCard.updateTimeCard(tc2,tss);
            
            FBE_SetTimeCard.updateTaskTime(tt2,tss,key);
            FBE_SetTimeCard.lockTimeSheetEntryRecord(timeSheetIdList);
            
            
            
            
            for(Timesheet timesheet : lstTimeSheet){
                FBE_SetTimeCard.updateTaskTime(ttNew,timesheet,key);
            }
            Test.stopTest();
            
        }
    }
    
    // }
    
    @isTest static void testMethod1() {
        List<Id> timeSheetIdList = new List<Id>();
        pse__Timecard_Header__c tc = new pse__Timecard_Header__c();
        List<Contact> contactList = new List<Contact>();
        list<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            Profile p1= [SELECT Id FROM Profile WHERE Name = 'PSA Direct Manager'];
            List < User > userLst1 = new List < User > ();
            for (Integer i = 0; i < =1; i++) {
                User u = new User(Alias = 'st' + i + 'add',Email = 'a' + 'test1'+ i + 'trfouser@testor.com', LocaleSidKey = 'en_US',
                                  EmailEncodingKey = 'UTF-8', LastName = 'Testing123',EmployeeNumber='12346', LanguageLocaleKey = 'en_US', ProfileId = p1.Id,
                                  TimeZoneSidKey = 'America/Los_Angeles', UserName = 'a1' + 'dd2'+ i + 'trfouser@testor.com');
                userLst1.add(u);
                
            }
            insert userLst1;
            Profile p = [SELECT Id FROM Profile WHERE Name = 'PSA Project Manager'];
            List < User > userLst = new List < User > ();
            for (Integer i = 0; i < =1; i++) {
                User u = new User(Alias = 'st' + i + 'add',Email = 'a' + 'test1'+ i + 'trfouser@testorg.com', LocaleSidKey = 'en_US',
                                  EmailEncodingKey = 'UTF-8', LastName = 'Testing',EmployeeNumber='1234', LanguageLocaleKey = 'en_US', ProfileId = p.Id,
                                  TimeZoneSidKey = 'America/Los_Angeles', UserName = 'a' + 'dd'+ i + 'trfouser@testorg.com',ManagerId=userLst1[0].Id);
                userLst.add(u);
                
            }
            insert userLst;
            
            List<Account> accountList = FBE_Test_Utility.createAccount(1);
            insert accountList;
            
            Contact contactOne = new Contact(
                FirstName = 'Test Contact',
                LastName = 'One',
                Phone = '9876567890',
                Email = 'test@testone.com',
                Badge_ID__c = '483426',
                AccountId = accountList[0].Id,
                pse__Is_Resource_Active__c = True,
                pse__Is_Resource__c =True,
                pse__Salesforce_User__c = userLst[0].Id
                
            );
            
            contactList.add(contactOne);
            insert contactList;
            List<pse__Proj__c> projList = FBE_Test_Utility.createProject(1);
            insert projList; 
            
            //List<pse__Practice__c> practiceList =[Select Id,name from pse__Practice__c where name='Global Practice'];
            List<pse__Practice__c> practiceList = FBE_Test_Utility.createPractice();
            insert practiceList;
            List<pse__Permission_Control__c> pcPracticeList = FBE_Test_Utility.createPermissionControlForPractice(1, practiceList, loginUser);
            insert pcPracticeList; 
            
            List<pse__Permission_Control__c> pcResourceList = FBE_Test_Utility.createPermissionControlForResource(1, contactList, loginUser);
            insert pcResourceList;
            
            List<pse__Permission_Control__c> pcProjectList = FBE_Test_Utility.createPermissionControlForProject(1, projList, loginUser);
            insert pcProjectList;
            
            List<ServiceResource> srList = FBE_Test_Utility.createServiceResource(1, loginUser);
            insert srList;
            
            List<pse__Schedule__c> scheduleList = FBE_Test_Utility.createSchedule(1);
            insert scheduleList;
            
            List<pse__Assignment__c> assignmentList = FBE_Test_Utility.createAssignment(1, contactList, projList, scheduleList,NULL);
            insert assignmentList; 
            
            
            List<pse__Project_Task__c> ptList = FBE_Test_Utility.createProjectTask(1, projList);
            insert ptList;
            
            List<WorkOrder> woList = FBE_Test_Utility.createWorkOrder(1,ptList);
            insert woList;
            
            
            List<ServiceAppointment> saList = FBE_Test_Utility.createServiceAppointment(1, woList, assignmentList, contactList, projList);
            insert saList;
            /*List<pse__Assignment__c> assignmentList = FBE_Test_Utility.createAssignment(1, contactList, projList, scheduleList,NULL);
insert assignmentList; 
*/
            Test.startTest(); 
            List<pse__Timecard_Header__c> tcList = FBE_Test_Utility.createTimeCard(1,contactList, projList, assignmentList);
            insert tcList;
             RecursiveTriggerHandler.hasRun = false;
            
            List<TimeSheet> tsList = FBE_Test_Utility.createTimeSheet(7, srList, saList);
            insert tsList;
           
            
            SYstem.debug('tsList===='+tsList);
            
            for(TimeSheet ts : tsList){
                timeSheetIdList.add(ts.Id);   
            }  
            
            FBE_SetTimeCard.createUpdateTimecard(timeSheetIdList);
            
            List<pse__Timecard_Header__c> newRecord = new List<pse__Timecard_Header__c>();
            for(pse__Timecard_Header__c ptc1: tcList){
                ptc1.pse__Status__c='Approved';
                newRecord.add(ptc1);
                
            }
            update newRecord;
            RecursiveTriggerHandler.hasRun = false;
            Approval.ProcessSubmitRequest app1 = new Approval.ProcessSubmitRequest();
            app1.setObjectId(newRecord[0].id);
            Approval.ProcessResult result1 = Approval.process(app1);
            List<pse__Timecard_Header__c> tcList2 = [Select Id, Name, pse__Approver__c, (Select TargetObjectId, LastActorId From ProcessInstances) from pse__Timecard_Header__c where Id=: newRecord[0].Id];
            for(pse__Timecard_Header__c ptc : tcList2){
                for(ProcessInstance pi : tc.ProcessInstances){
                    ptc.pse__Approver__c = pi.LastActorId;
                }
                update ptc;
            }
            
            RecursiveTriggerHandler.hasRun = false;
            FBE_SetTimeCard.updateApproveronTimecard();
            //FBE_SetTimeCard.setApprover(newRecord);            
        }    
    }
}