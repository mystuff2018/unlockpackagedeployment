@isTest (seeAllData = false)
public class ResourceAbsenceHandlerTest {
    @isTest
    static void testCreateTSForAbsence2(){
        //Test.startTest();
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        List<Contact> contactList = new List<Contact>();
        Map <Id,AssignedResource> mapAppointmentVsResource = new Map <Id,AssignedResource>();
        Map<Id, ServiceResource>serviceResourceMap = new Map<Id, ServiceResource>();
        List<Id> timeSheetIdList = new List<Id>();
        system.runAs(loginUser[0]){
            Test.startTest();
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
                pse__Is_Resource__c =True
                
            );

            contactList.add(contactOne);
            insert contactList;
            
            
            List<pse__Proj__c> projList = FBE_Test_Utility.createGlobalProject(1);
            insert projList;
            
            List<pse__Proj__c> projList2 = FBE_Test_Utility.createProject(1);
            insert projList2;
            
           
            
            FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
            List<ServiceResource> srList = FBE_Test_Utility.createServiceResource(1, loginUser);
            insert srList;
                     

            List<ResourceAbsence> raList = FBE_Test_Utility.createResourceAbsence(1,srList);
            insert raList;
          
            List<TimeSheet> timeSheetList = [Select Id from TimeSheet where FBE_Resource_Absence__c IN : raList];
			//system.assertEquals(6,timeSheetList.size());
            List<TimeSheetEntry> tsentryList = [SELECT Id, TimeSheetId FROM TimeSheetEntry];
            //system.assertEquals(6,tsentryList.size());
            
            List<ResourceAbsence> raList2 = new List<ResourceAbsence>();
            for(ResourceAbsence ra: raList){
            ra.Start = system.today()+2;
            ra.End = system.today()+6;
            raList2.add(ra);
            }
            update raList2;
            Date startDate,endDate;
            Integer count=0;
            for(ResourceAbsence ra: raList2){
                startDate = (ra.Start).date();
            	endDate = (ra.End).date();
            	count = startDate.daysBetween(endDate);
            }
            List<TimeSheet> timeSheetList2 = [Select Id,StartDate,FBE_Resource_Absence__c from TimeSheet where FBE_Resource_Absence__c IN : raList];
            //system.assertEquals(count+1, timeSheetList2.size());
            List<TimeSheetEntry> tsentryList2 = [SELECT Id, TimeSheetId FROM TimeSheetEntry];
            //system.assertEquals(timeSheetList2.size(),tsentryList2.size());
            
            Delete raList2;
            timeSheetList2 = null;
            timeSheetList2 = [Select Id,StartDate,FBE_Resource_Absence__c from TimeSheet where FBE_Resource_Absence__c IN : raList2];
            system.assertEquals(0, timeSheetList2.size());
            Test.stopTest();
			
            //ResourceAbsenceHandler.createTimeSheet(raList);
 
            System.assertEquals(projList[0].Name, 'Vacation');
            
        }

    }
    /*
    @isTest
    
    static void testCreateTSForAbsence3(){
       /** List<User> user =[Select id from User Limit 1];
        List<Contact> contactList = new List<Contact>();
        //Map<Id, AssignedResource> mapAppointmentResource = new Map<Id, AssignedResource>();
        List<Id> timeSheetIdList = new List<Id>(); **/
        
        /*List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        List<Contact> contactList = new List<Contact>();
        Map <Id,AssignedResource> mapAppointmentVsResource = new Map <Id,AssignedResource>();
        Map<Id, ServiceResource>serviceResourceMap = new Map<Id, ServiceResource>();
        List<Id> timeSheetIdList = new List<Id>();
        system.runAs(loginUser[0]){
            Test.startTest();
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
            
            List<OperatingHours> ohList = FBE_Test_Utility.createOperatingHours();
            insert ohList;
            
            List <ServiceTerritory> stList = FBE_Test_Utility.createServiceTerritory(ohList);
            insert stList;
                       
            List<pse__Practice__c> practiceList = FBE_Test_Utility.createPractice();
            insert practiceList;
            
            
            List<pse__Proj__c> projList2 = FBE_Test_Utility.createProject(1);
            insert projList2;
            
            List<pse__Permission_Control__c> pcProjectList = FBE_Test_Utility.createPermissionControlForProject(1, projList2, loginUser);
            insert pcProjectList;
            
            List<pse__Permission_Control__c> pcResourceList = FBE_Test_Utility.createPermissionControlForResource(1, contactList, loginUser);
            insert pcResourceList;
                
            List<ServiceResource> srList = FBE_Test_Utility.createServiceResource(1, loginUser);
            insert srList;
            
            List<ServiceTerritoryMember> stmList = FBE_Test_Utility.createServiceTerritoryMember(stList, srList);
            insert stmList;
            
            List<pse__Project_Task__c> ptList = FBE_Test_Utility.createProjectTask(1,projList2);
            insert ptList;            
            
            List<WorkOrder> woList = FBE_Test_Utility.createWorkOrder(1, ptList);
            insert woList;
                        
            List<pse__Schedule__c> scheduleList = FBE_Test_Utility.createSchedule(1);
            insert scheduleList;
            
            List<pse__Assignment__c> assignmentList = FBE_Test_Utility.createAssignment(1, contactList, projList2, scheduleList);
            insert assignmentList;
            
            List<ServiceAppointment> saList = FBE_Test_Utility.createServiceAppointment(1, woList, assignmentList, contactList, projList2);
            insert saList;
            
            
            FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
            List<AssignedResource> arList = FBE_Test_Utility.createAssignedResource(1, saList, srList);
            insert arList;
            
            for(AssignedResource ar : arList){
                mapAppointmentVsResource.put(ar.ServiceAppointmentId, ar);
                
            }
            
            Test.stopTest();

           AssignedResourceTriggerHandler.populateAssignee(mapAppointmentVsResource);
           TimeSheetTriggerHandler.createTimeSheet(saList, arList);
 

            
        }

    }*/
    
     
}