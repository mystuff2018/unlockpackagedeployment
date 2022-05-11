/**************
 * @ Class Name        : AssignedResourceTriggerHandlerTest
 * @ Description       : This class is created to test code coverage for AssignedResourceTrigger and handler classes.
 *                       Created as part of Feature #7946971.
 * @ CreatedBy         : Deloitte
 * @ CreatedOn         : 11/24/2020
 * @ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script
*********/

@IsTest 
public class AssignedResourceTriggerHandlerTest {
	/**************
     * @MethodName    : setup
     * @Trigger       : -
     * @Description   : This method creates test data for Assigned resource functions.
     ***************/
	@TestSetup
    static void setup(){
        TriggerHandler.bypass('FFServiceAppointmentTriggerHandler'); 
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            List<Account> accountList = FBE_Test_Utility.createAccount(1);
            insert accountList;
            
			Profile userProfile = [SELECT Id, Name FROM Profile WHERE Profile.Name = 'PSA Technical Resource' LIMIT 1];
            List<User> users = new List<User>();
            User user1 = new User();
            user1.FirstName = 'Test Enable';
            user1.LastName = 'Permission Contact';
            user1.External_ID__c = '1234587';
            user1.FederationIdentifier = '1234587';
            user1.Organization__c = 'Scott Pittman (633976)';
            user1.Username = 'userPermissionEnablamentUser1@dell.com.salesforce';
            user1.Email = 'userPermissionEnablamentUser1@dell.com';
            user1.Alias = 'Alias';
            user1.CommunityNickname = 'EnablePermissionTest1';
            user1.TimeZoneSidKey = 'Asia/Kolkata';
            user1.LocaleSidKey = 'en_US';
            user1.EmailEncodingKey = 'UTF-8';
            user1.ProfileId = userProfile.Id;
            user1.LanguageLocaleKey = 'en_US';
            user1.OSP__c = 'No';
            user1.Dell_NTUserID__c = 'NTUSERID';
            user1.File_Source__c = 'GIS - Bulk';
            user1.Phone = '8899889909';
            user1.Service_User_Type__c = 'Business';
            user1.IsActive = true;
            user1.Agent_Location_Country__c = 'United States';
            user1.Country = 'United States';
            user1.Default_Weekly_Hours__c = '40';
            user1.HR_Job_Title__c = 'Senior Advisor, Engineering Project Management';
            user1.CurrencyIsoCode = 'USD';
            user1.EmployeeNumber = '12345';
            users.add(user1);
            
            insert users;
            
            List<Contact> objContact = [SELECT Id FROM Contact WHERE pse__Salesforce_User__c = :users[0].Id];
            
            List<ServiceResource> objResource = [SELECT Id FROM ServiceResource WHERE RelatedRecordId =: users[0].Id];
       
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
            
            List<pse__Permission_Control__c> pcResourceList = FBE_Test_Utility.createPermissionControlForResource(1, objContact, loginUser);
            insert pcResourceList;
            
            List<ServiceTerritoryMember> stmList = FBE_Test_Utility.createServiceTerritoryMember(stList, objResource);
            insert stmList;
            
            List<pse__Project_Task__c> ptList = FBE_Test_Utility.createProjectTask(1, projList2 );
            insert ptList;
            
            List<WorkOrder> woList = FBE_Test_Utility.createWorkOrder(1, ptList);
            insert woList;
            
            List<pse__Schedule__c> scheduleList = FBE_Test_Utility.createSchedule(1);
            insert scheduleList;
            
            List<pse__Assignment__c> assignmentList = FBE_Test_Utility.createAssignment(1, objContact, projList2, scheduleList,NULL);
            insert assignmentList;
            
            List<ServiceAppointment> saList = FBE_Test_Utility.createServiceAppointment(1, woList, assignmentList, objContact, projList2);
			insert saList;
            
                        
            FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
            
            
        }
        TriggerHandler.clearAllBypasses();
    }
    
    @isTest
    static void shouldCreateProjectShareRecord(){
        Test.startTest();
        
        List<ServiceAppointment> saList = [SELECT Id FROM ServiceAppointment LIMIT 1];
		List<ServiceResource> srList = [SELECT Id FROM ServiceResource LIMIT 1];
		List<User> userList = [SELECT Id, Name FROM User WHERE Email = 'userPermissionEnablamentUser1@dell.com' LIMIT 1];
        
        List<pse__Proj__c> projectList = [SELECT Id FROM pse__Proj__c LIMIT 1];
        
        List<AssignedResource> arList = FBE_Test_Utility.createAssignedResource(1, saList, srList);
        insert arList;
        Test.stopTest();
        
        List<pse__Proj__Share> projectShare = [SELECT Id, ParentId, UserOrGroupId, UserOrGroup.Name, RowCause, AccessLevel
                                              FROM pse__Proj__Share 
                                              WHERE RowCause =:Schema.pse__Proj__Share.RowCause.PSA_Tech_Resource_Share__c
                                              LIMIT 1];
        
       System.assertEquals(userList[0].Id, projectShare[0].UserOrGroupId);
       //System.assertEquals(projectList[0].Id, projectShare[0].ParentId);
       System.assertEquals('Edit', projectShare[0].AccessLevel);
        
    }
  /**  //wrote as a part of test code coverage.
    @isTest
    static void DeleteAssignedResource(){
        Test.startTest();
        //Profile userProfile = [SELECT Id, Name FROM Profile WHERE Profile.Name = 'PSA Project Manager' LIMIT 1];
        List<User> users = new List<User>();
        users = FBE_Test_Utility.createUser('PSA Project Manager ',1,'test');
                   
        system.runAs(users[0]){
            List<ServiceAppointment> saList = [SELECT Id FROM ServiceAppointment LIMIT 1];
			List<ServiceResource> srList = [SELECT Id FROM ServiceResource LIMIT 1];
            
            List<AssignedResource> arList = FBE_Test_Utility.createAssignedResource(1, saList, srList);
        	insert arList;	
 
        Test.stopTest();
    }
    
} **/
}