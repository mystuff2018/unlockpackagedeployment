/*
      Purpose:
            Test ProjectTaskHandler, which rolls up custom "Standard Hours" field on project task to top of WBS.
            
      Initiative: Dell Thunderbolt PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    9/18/18
*/

@IsTest
private class ProjectTaskHandlerTest {
    @IsTest
    static void testSingleLevelRollupToSingleParentAfterInsert() {
        pse__Proj__c testProject = new pse__Proj__c(Name = 'Test Project', pse__Is_Active__c = true );
        insert testProject;
        Schema.Location objLocation = new Schema.Location();
        objLocation.OwnerId = UserInfo.getUserId();
        objLocation.Name = '233 N Michigan Ave_Chicago';
        objLocation.CurrencyIsoCode = 'USD';
        objLocation.LocationType = 'Site';
        objLocation.IsMobile = false;
        objLocation.IsInventoryLocation = false;
        insert objLocation;

        Schema.Address objAddress = new Schema.Address();
        objAddress.CurrencyIsoCode = 'USD';
        objAddress.ParentId = objLocation.Id;
        objAddress.LocationType = 'Warehouse';
        objAddress.AddressType = 'Mailing';
        objAddress.Street = '233 North Michigan Avenue';
        objAddress.City = 'Chicago';
        objAddress.State = 'Illinois';
        objAddress.PostalCode = '60601';
        objAddress.Country = 'United States';
        objAddress.StateCode = 'IL';
        objAddress.CountryCode = 'US';
        objAddress.Latitude = 41.887140000000000;
        objAddress.Longitude = -87.623288000000000;
        objAddress.GeocodeAccuracy = 'Address';
        insert objAddress;
        // Site__c site = new Site__c(Address_1__c = 'Test', City__c = 'test', Country__c = 'test', Postal_Code__c = '12200000', Status__c = 'Active');
        // insert site;
        // Project_Location__c projectSites = new Project_Location__c(Address_Type__c = 'Install At Contact',
        //         Project__c = testProject.Id, Site__c = site.Id);
        // insert projectSites;

        Project_Location__c projectSite = new Project_Location__c(
            Address_Type__c = 'Install At Contact',
            // Site__c = site.Id,
            Location__c = objLocation.Id,
            Project__c = testProject.Id,
            // Order__c = order.Id,
            Default_Address__c = true
        );
        insert projectSite;

        
        pse__Project_Task__c testParentTask = createProjectTask(testProject, null, 'Test Parent Task', null);
        insert testParentTask;
        List<pse__Project_Task__c> testSubTasks = new List<pse__Project_Task__c>();
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 1', 13));
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 2', 3));
        insert testSubTasks;
        testParentTask = [SELECT PSA_Standard_Hours__c, pse__Project__c FROM pse__Project_Task__c WHERE Id = :testParentTask.Id];


        //System.assertEquals(16, testParentTask.PSA_Standard_Hours__c);
    }
    @IsTest
    static void testSingleLevelRollupToSingleParentAfterUpdate() {
        pse__Proj__c testProject = new pse__Proj__c(Name = 'Test Project', pse__Is_Active__c = true );
        insert testProject;
        // Site__c site = new Site__c(Address_1__c = 'Test', City__c = 'test', Country__c = 'test', Postal_Code__c = '12200000', Status__c = 'Active');
        // insert site;
        // Project_Location__c projectSites = new Project_Location__c(Address_Type__c = 'Shipping',
        //         Project__c = testProject.Id, Site__c = site.Id);
        // insert projectSites;
        Schema.Location objLocation = new Schema.Location();
        objLocation.OwnerId = UserInfo.getUserId();
        objLocation.Name = '233 N Michigan Ave_Chicago';
        objLocation.CurrencyIsoCode = 'USD';
        objLocation.LocationType = 'Site';
        objLocation.IsMobile = false;
        objLocation.IsInventoryLocation = false;
        insert objLocation;

        Schema.Address objAddress = new Schema.Address();
        objAddress.CurrencyIsoCode = 'USD';
        objAddress.ParentId = objLocation.Id;
        objAddress.LocationType = 'Warehouse';
        objAddress.AddressType = 'Mailing';
        objAddress.Street = '233 North Michigan Avenue';
        objAddress.City = 'Chicago';
        objAddress.State = 'Illinois';
        objAddress.PostalCode = '60601';
        objAddress.Country = 'United States';
        objAddress.StateCode = 'IL';
        objAddress.CountryCode = 'US';
        objAddress.Latitude = 41.887140000000000;
        objAddress.Longitude = -87.623288000000000;
        objAddress.GeocodeAccuracy = 'Address';
        insert objAddress;
        
        Project_Location__c projectSite = new Project_Location__c(
            Address_Type__c = 'Install At Contact',
            // Site__c = site.Id,
            Location__c = objLocation.Id,
            Project__c = testProject.Id,
            // Order__c = order.Id,
            Default_Address__c = true
        );
        insert projectSite;
        pse__Project_Task__c testParentTask = createProjectTask(testProject, null, 'Test Parent Task', null);
        insert testParentTask;
        List<pse__Project_Task__c> testSubTasks = new List<pse__Project_Task__c>();
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 1', 13));
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 2', 3));
        insert testSubTasks;
        testSubTasks[1].PSA_Standard_Hours__c += 5;
        update testSubTasks[1];
        testParentTask = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testParentTask.Id];
        //System.assertEquals(21, testParentTask.PSA_Standard_Hours__c);
    }
    @IsTest
    static void testSingleLevelRollupToSingleParentAfterDelete() {
        pse__Proj__c testProject = new pse__Proj__c(Name = 'Test Project', pse__Is_Active__c = true );
        insert testProject;
        pse__Project_Task__c testParentTask = createProjectTask(testProject, null, 'Test Parent Task', null);
        insert testParentTask;
        List<pse__Project_Task__c> testSubTasks = new List<pse__Project_Task__c>();
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 1', 13));
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 2', 3));
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 3', 5));
        insert testSubTasks;
        delete testSubTasks[1];
        testParentTask = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testParentTask.Id];
        //System.assertEquals(18, testParentTask.PSA_Standard_Hours__c);
    }
    @IsTest
    static void testMultipleLevelRollupToSingleParentAfterInsert() {
        pse__Proj__c testProject = new pse__Proj__c(Name = 'Test Project', pse__Is_Active__c = True);
        insert testProject;
        pse__Project_Task__c testParentTask = createProjectTask(testProject, null, 'Test Parent Task', null);
        insert testParentTask;
        List<pse__Project_Task__c> testSubTasks = new List<pse__Project_Task__c>();
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 1', null));
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 2', 3));
        insert testSubTasks;
        List<pse__Project_Task__c> testSubSubTasks = new List<pse__Project_Task__c>();
        testSubSubTasks.add(createProjectTask(testProject, testSubTasks[0], 'Test Subsubtask 1.1', 7));
        testSubSubTasks.add(createProjectTask(testProject, testSubTasks[0], 'Test Subsubtask 1.2', 6));
        insert testSubSubTasks;
        testParentTask = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testParentTask.Id];
        testSubTasks[0] = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testSubTasks[0].Id];
        //System.assertEquals(16, testParentTask.PSA_Standard_Hours__c);
        //System.assertEquals(13, testSubTasks[0].PSA_Standard_Hours__c);

    }
    @IsTest
    static void testMultipleLevelRollupToSingleParentAfterUpdate() {
        pse__Proj__c testProject = new pse__Proj__c(Name = 'Test Project', pse__Is_Active__c = true );
        insert testProject;
        pse__Project_Task__c testParentTask = createProjectTask(testProject, null, 'Test Parent Task', null);
        insert testParentTask;
        List<pse__Project_Task__c> testSubTasks = new List<pse__Project_Task__c>();
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 1', null));
        testSubTasks.add(createProjectTask(testProject, testParentTask, 'Test Subtask 2', 3));
        insert testSubTasks;
        List<pse__Project_Task__c> testSubSubTasks = new List<pse__Project_Task__c>();
        testSubSubTasks.add(createProjectTask(testProject, testSubTasks[0], 'Test Subsubtask 1.1', 7));
        testSubSubTasks.add(createProjectTask(testProject, testSubTasks[0], 'Test Subsubtask 1.2', 2));
        insert testSubSubTasks;
        testSubSubTasks[1].PSA_Standard_Hours__c = 6;
        update testSubSubTasks;
        testParentTask = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testParentTask.Id];
        testSubTasks[0] = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testSubTasks[0].Id];
        //System.assertEquals(16, testParentTask.PSA_Standard_Hours__c);
        //System.assertEquals(13, testSubTasks[0].PSA_Standard_Hours__c);

    }
    @IsTest
    static void testMultipleLevelRollupsToMultipleParentsAfterInsert() {
        pse__Proj__c testProject = new pse__Proj__c(Name = 'Test Project', pse__Is_Active__c = true );
        insert testProject;
        List<pse__Project_Task__c> testParentTasks = new List<pse__Project_Task__c>();
        testParentTasks.add(createProjectTask(testProject, null, 'Test Parent Task 1', null));
        testParentTasks.add(createProjectTask(testProject, null, 'Test Parent Task 2', null));
        insert testParentTasks;
        List<pse__Project_Task__c> testSubTasks = new List<pse__Project_Task__c>();
        testSubTasks.add(createProjectTask(testProject, testParentTasks[0], 'Test Subtask 1.1', null));
        testSubTasks.add(createProjectTask(testProject, testParentTasks[0], 'Test Subtask 1.2', 3));
        testSubTasks.add(createProjectTask(testProject, testParentTasks[1], 'Test Subtask 2.1', null));
        testSubTasks.add(createProjectTask(testProject, testParentTasks[1], 'Test Subtask 2.2', 5));
        insert testSubTasks;
        List<pse__Project_Task__c> testSubSubTasks = new List<pse__Project_Task__c>();
        testSubSubTasks.add(createProjectTask(testProject, testSubTasks[0], 'Test Subsubtask 1.1.1', 7));
        testSubSubTasks.add(createProjectTask(testProject, testSubTasks[0], 'Test Subsubtask 1.1.2', 6));
        testSubSubTasks.add(createProjectTask(testProject, testSubTasks[2], 'Test Subsubtask 2.1.1', 17));
        insert testSubSubTasks;
        testParentTasks[0] = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testParentTasks[0].Id];
        testParentTasks[1] = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testParentTasks[1].Id];
        testSubTasks[0] = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testSubTasks[0].Id];
        testSubTasks[2] = [SELECT PSA_Standard_Hours__c FROM pse__Project_Task__c WHERE Id = :testSubTasks[2].Id];
        //System.assertEquals(16, testParentTasks[0].PSA_Standard_Hours__c);
        //System.assertEquals(13, testSubTasks[0].PSA_Standard_Hours__c);
        //System.assertEquals(22, testParentTasks[1].PSA_Standard_Hours__c);
        //System.assertEquals(17, testSubTasks[2].PSA_Standard_Hours__c);

    }
    public static pse__Project_Task__c createProjectTask(pse__Proj__c project, pse__Project_Task__c parent, String name, Decimal stdHours) {
        return new pse__Project_Task__c(
                Name = name,
                pse__Project__c = project.Id,
                pse__Parent_Task__c = parent != null ? parent.Id : null,
                PSA_Standard_Hours__c = stdHours
        );
    }

    // omonsalve 05-04-2019
    public static testMethod void  updateProjectStatus()
    {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            Account objAccount = TestDataGenerator.createAccount();
            insert objAccount;
            pse__Time_Period__c objTimePeriod = TestDataGenerator.createTimePeriod();
            insert objTimePeriod;
            pse__Region__c objRegion = TestDataGenerator.createRegion(objTimePeriod.Id);
            insert objRegion;
            pse__Practice__c objPractice = TestDataGenerator.createPractice(objTimePeriod.Id);
            insert objPractice;
            pse__Work_Calendar__c objWorkCalendar = TestDataGenerator.createWorkCalendar();
            insert objWorkCalendar;
            User objUser = TestDataGenerator.createUser('Steve','Julian','61');
            insert objUser;
            User objUserAux = TestDataGenerator.createUser('August','Phill','23');
            insert objUserAux;
            Contact objContact = TestDataGenerator.createContact('Smith12','Julian12', objAccount.Id, objRegion.Id, objPractice.Id, objWorkCalendar.Id, objUser.Id);
            insert objContact;
            Contact objContactAux = TestDataGenerator.createContact('Bonanza12','Phill12', objAccount.Id, objRegion.Id, objPractice.Id, objWorkCalendar.Id, objUserAux.Id);
            insert objContactAux;
            WorkType objWorkType = TestDataGenerator.createWorkType();
            insert objWorkType;
            pse__Proj__c objProject = TestDataGenerator.createProject(objAccount.Id, objContact.Id, objContactAux.Id, objTimePeriod.Id, objRegion.Id, objPractice.Id);
            objProject.Reason_Not_To_Survey__c = GetDefaultValueForReasonNotToSurvey();
            insert objProject;
            pse__Project_Task__c objParentProjectTask = TestDataGenerator.createParentProjectTask(objProject.Id);
            insert objParentProjectTask;
            Site__c objSite = TestDataGenerator.createSite();
            insert objSite;
            Project_Location__c objProjectSite = TestDataGenerator.createProjectSite(objProject.Id, objSite.Id);
            insert objProjectSite;
            pse__Project_Task__c objProjectTask = TestDataGenerator.createProjectTask(objParentProjectTask.Id, objProject.Id, objProjectSite.Id);
            insert objProjectTask;
            objProjectTask.pse__Started__c = true;
            objProjectTask.pse__Completed__c = true;
            // FF - Submitted // FF - Work In Progress // FF - Cancelled // FF - Closed // FF - Cancellation Request
            // FF - New // FF - Invalid // FF - Partial Complete // FF - Partial Cancelled
            Test.startTest();
            //   List<WorkOrder> lstWorkOrders = new List<WorkOrder>();
            //   WorkOrder objWorkOrder = TestDataGenerator.createWorkOrder('FF - New', objAccount.Id, objProject.Id, objProjectTask.Id, objWorkType.Id);
            //   lstWorkOrders.add(objWorkOrder);    
            //   WorkOrder objWorkOrderAUX = TestDataGenerator.createWorkOrder('FF - New', objAccount.Id, objProject.Id, objProjectTask.Id, objWorkType.Id);
            //   lstWorkOrders.add(objWorkOrderAUX);
            //   insert lstWorkOrders;
              
            //     for (Integer i = 0; i < lstWorkOrders.size(); i++) 
            //     {
            //         if(i==0)
            //         {
            //           lstWorkOrders[i].Status = 'FF - Submitted';
            //         }
            //         else 
            //         {
            //           lstWorkOrders[i].Status = 'FF - Cancelled';
            //         }
            //     }
            //     update lstWorkOrders;

            //     WorkOrder objWOAux = new WorkOrder();
            //     for (WorkOrder objWO : lstWorkOrders) 
            //     {
            //         if(objWO.Status.equals('FF - Submitted'))
            //         {
            //           objWO.Status = 'FF - Closed';
            //           objWOAux = objWO;
            //         }
            //     }
            //     update objWOAux;
            Test.stopTest();  
        }
    }

    // Luis Campos 12-10-2019
    @isTest
    static void  testPreventDeletionOnTasksWithWorkOrder()
    {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            Account objAccount = TestDataGenerator.createAccount();
            insert objAccount;
            pse__Time_Period__c objTimePeriod = TestDataGenerator.createTimePeriod();
            insert objTimePeriod;
            pse__Region__c objRegion = TestDataGenerator.createRegion(objTimePeriod.Id);
            insert objRegion;
            pse__Practice__c objPractice = TestDataGenerator.createPractice(objTimePeriod.Id);
            insert objPractice;
            pse__Work_Calendar__c objWorkCalendar = TestDataGenerator.createWorkCalendar();
            insert objWorkCalendar;
            
            // List of allowed profiles to apply the prevent task validation and the System Administrator as control profile
            List<String> allowedProfiles = new List<String>();
            allowedProfiles.add('PSA Administrator');
            allowedProfiles.add('PSA Intake');
            allowedProfiles.add('PSA Project Manager');
            allowedProfiles.add('System Administrator');
            map<String, Id > profilesMap = new map<String, Id>();

            for(Profile prof : [Select Id, Name from Profile where Name IN :allowedProfiles]){
                profilesMap.put(prof.Name, prof.Id);
            }
            
            // Create the users to perform the test
            List<User> usersToInsert = new List<User>();
            User userPSAAdministrator = TestDataGenerator.createUser('Smrithika','Julian','41');
            userPSAAdministrator.ProfileId = profilesMap.get('PSA Administrator');
            usersToInsert.add(userPSAAdministrator);
            User userPSAProjectSupportLead = TestDataGenerator.createUser('Brignanza','Phil','26');
            userPSAProjectSupportLead.ProfileId = profilesMap.get('PSA Intake');
            usersToInsert.add(userPSAProjectSupportLead);
            User userPSAProjectManager = TestDataGenerator.createUser('Smithali','Jeniffer','37');
            userPSAProjectManager.ProfileId = profilesMap.get('PSA Project Manager');
            usersToInsert.add(userPSAProjectManager);
            User userSysAdmin = TestDataGenerator.createUser('Pence','Yves','46');
            userSysAdmin.ProfileId = profilesMap.get('System Administrator');
            usersToInsert.add(userSysAdmin);
            insert usersToInsert;
            Contact objContact = [select id,firstname, lastname from Contact where firstname = 'Julian' and lastname = 'Smrithika' limit 1];
            Contact objContactAux = [select id,firstname, lastname from Contact where firstname = 'Phil' and lastname = 'Brignanza' limit 1];
            // Create the Contacts
            /* List<Contact> contactsToInsert = new List<Contact>();
            Contact objContact = TestDataGenerator.createContact('Smith5566','Julian11223', objAccount.Id, objRegion.Id, objPractice.Id, objWorkCalendar.Id, userPSAAdministrator.Id);
            objContact.pse__Region__c = objRegion.Id;
            contactsToInsert.add(objContact);
            
            Contact objContactAux = TestDataGenerator.createContact('Bonanza12','Phill12', objAccount.Id, objRegion.Id, objPractice.Id, objWorkCalendar.Id, userPSAProjectSupportLead.Id);
            objContactAux.pse__Region__c = objRegion.Id;
            contactsToInsert.add(objContactAux);

            insert contactsToInsert; */
            
            WorkType objWorkType = TestDataGenerator.createWorkType();
            insert objWorkType;
            pse__Proj__c objProject = TestDataGenerator.createProject(objAccount.Id, objContact.Id, objContactAux.Id, objTimePeriod.Id, objRegion.Id, objPractice.Id);
            objProject.Reason_Not_To_Survey__c = GetDefaultValueForReasonNotToSurvey();
            insert objProject;

            pse__Project_Task__c objParentProjectTask = TestDataGenerator.createParentProjectTask(objProject.Id);
            insert objParentProjectTask;
            Site__c objSite = TestDataGenerator.createSite();
            insert objSite;
            Project_Location__c objProjectSite = TestDataGenerator.createProjectSite(objProject.Id, objSite.Id);
            insert objProjectSite;
            pse__Project_Task__c objProjectTask = TestDataGenerator.createProjectTask(objParentProjectTask.Id, objProject.Id, objProjectSite.Id);
            insert objProjectTask; 

            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.Project_Task__c = objProjectTask.Id;
            testWorkOrder.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            testWorkOrder.Account = objAccount;
            testWorkOrder.AccountId = objAccount.Id;
            insert testWorkOrder;

            String triggerErrorMessage = 'This Project Task cannot be deleted because it has related Work Orders and/or has Time entered against it.';

            Test.startTest();

            objProjectTask.OwnerId = userPSAAdministrator.Id;
            update objProjectTask;
            System.runAs(userPSAAdministrator) {
                try{
                    Database.DeleteResult deleteResult = Database.delete(objProjectTask.Id);
                }catch(Exception e){
                    Boolean expectedExceptionThrown = e.getMessage().contains(triggerErrorMessage) ? true : false;
                    //System.AssertEquals(expectedExceptionThrown, true, 'It is not expected that a PSA Administrator deletes a linked project task.');
                }
            }

            //objProjectTask.OwnerId = userPSAProjectSupportLead.Id;
            //update objProjectTask;
            System.runAs(userPSAProjectSupportLead) {
                try{
                    Database.DeleteResult deleteResult = Database.delete(objProjectTask.Id);
                }catch(Exception e){
                    Boolean expectedExceptionThrown = e.getMessage().contains(triggerErrorMessage) ? true : false;
                    //System.AssertEquals(expectedExceptionThrown, true, 'It is not expected that a PSA Intake deletes a project task.');
                }
            }

            //objProjectTask.OwnerId = userPSAProjectManager.Id;
            //update objProjectTask;
            System.runAs(userPSAProjectManager) {
                try{
                    Database.DeleteResult deleteResult = Database.delete(objProjectTask.Id);
                }catch(Exception e){
                    System.debug('LCDebug exception: ' + e);
                    Boolean expectedExceptionThrown = e.getMessage().contains(triggerErrorMessage) ? true : false;
                    //System.AssertEquals(expectedExceptionThrown, true, 'It is not expected that a PSA Project Manager deletes a linked project task.');
                }
            }

            //objProjectTask.OwnerId = userSysAdmin.Id;
            //update objProjectTask;
            System.runAs(userSysAdmin) {
                try{
                    Database.DeleteResult deleteResult = Database.delete(objProjectTask.Id);
                    System.AssertEquals(true, deleteResult.isSuccess(), 'It is expected that a linked project task can be deleted by the System Administrator');
                }catch(Exception e){
                }
            }
            Test.stopTest(); 
        }
    }

    // Luis Campos 12-10-2019
   @isTest
    static void  testPreventDeletionOnTasksWithTimeRecords()
    {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
        Account objAccount = TestDataGenerator.createAccount();
        insert objAccount;
        
        pse__Time_Period__c objTimePeriod = TestDataGenerator.createTimePeriod();
        insert objTimePeriod;
        
        pse__Region__c objRegion = TestDataGenerator.createRegion(objTimePeriod.Id);
        insert objRegion;
        
        pse__Proj__c objBasicProject = TestDataGenerator.createBasicProject();
        insert objBasicProject;
        
        pse__Practice__c objPractice = OPRTestFactory.createPracticesItemClass();
        pse__Work_Calendar__c objWorkCalendar = TestDataGenerator.createWorkCalendar();
        insert objWorkCalendar;
        
        // List of allowed profiles to apply the prevent task validation and the System Administrator as control profile
        List<String> allowedProfiles = new List<String>();
        allowedProfiles.add('PSA Administrator');
        allowedProfiles.add('PSA Intake');
        allowedProfiles.add('PSA Project Manager');
        allowedProfiles.add('System Administrator');
        map<String, Id > profilesMap = new map<String, Id>();

        for(Profile prof : [Select Id, Name from Profile where Name IN :allowedProfiles]){
            profilesMap.put(prof.Name, prof.Id);
        }
        
        // Create the users to perform the test
        List<User> usersToInsert = new List<User>();
            User userPSAAdministrator = TestDataGenerator.createUser('Melendez','Julien','199');
            userPSAAdministrator.ProfileId = profilesMap.get('PSA Administrator');
            usersToInsert.add(userPSAAdministrator);
            User userPSAProjectSupportLead = TestDataGenerator.createUser('Russo','Philer','412');
            userPSAProjectSupportLead.ProfileId = profilesMap.get('PSA Intake');
            usersToInsert.add(userPSAProjectSupportLead);
            User userPSAProjectManager = TestDataGenerator.createUser('Smoth','Jhonny','313');
            userPSAProjectManager.ProfileId = profilesMap.get('PSA Project Manager');
            usersToInsert.add(userPSAProjectManager);
            User userSysAdmin = TestDataGenerator.createUser('Pencil','Yvesana','342');
            userSysAdmin.ProfileId = profilesMap.get('System Administrator');
            usersToInsert.add(userSysAdmin);
            insert usersToInsert;

        // Create the Contacts
            /* List<Contact> contactsToInsert = new List<Contact>();
            Contact objContact = TestDataGenerator.createContact('Smith1234','Julianard', objAccount.Id, objRegion.Id, objPractice.Id, objWorkCalendar.Id, userPSAAdministrator.Id);
            objContact.pse__Region__c = objRegion.Id;
            contactsToInsert.add(objContact);
            
            Contact objContactAux = TestDataGenerator.createContact('Bonanza12','Phill12', objAccount.Id, objRegion.Id, objPractice.Id, objWorkCalendar.Id, userPSAProjectSupportLead.Id);
            objContactAux.pse__Region__c = objRegion.Id;
            contactsToInsert.add(objContactAux); 

            insert contactsToInsert;*/
            Contact objContact = [select id,firstname, lastname from Contact where firstname = 'Julien' and lastname = 'Melendez' limit 1];
            Contact objContactAux = [select id,firstname, lastname from Contact where firstname = 'Philer' and lastname = 'Russo' limit 1];
        
        WorkType objWorkType = TestDataGenerator.createWorkType();
        insert objWorkType;
        
        pse__Proj__c objProject = TestDataGenerator.createProject(objAccount.Id, objContact.Id, objContactAux.Id, objTimePeriod.Id, objRegion.Id, objPractice.Id);
        objProject.Reason_Not_To_Survey__c = GetDefaultValueForReasonNotToSurvey();
        objProject.Accounting_acknowledgement_status__c = 'PROCESSED';
        insert objProject;
        objProject.pse__Closed_for_Time_Entry__c = false;
        update objProject;

        //Id taskRecordTypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('PSA_Task').getRecordTypeId();
        
        pse__Project_Task__c objParentProjectTask = TestDataGenerator.createParentProjectTask(objProject.Id);        
        insert objParentProjectTask;
        
        Site__c objSite = TestDataGenerator.createSite();
        insert objSite;
        
        Project_Location__c objProjectSite = TestDataGenerator.createProjectSite(objProject.Id, objSite.Id);
        insert objProjectSite;
        
        pse__Project_Task__c objProjectTask = TestDataGenerator.createProjectTask(objParentProjectTask.Id, objProject.Id, objProjectSite.Id);
        //objProjectTask.RecordTypeId = taskRecordTypeId;
        insert objProjectTask; 

        Test.startTest();
        // Grant Permissions
        List<pse__Permission_Control__c> permissionsToInsert = new List<pse__Permission_Control__c>();
        pse__Permission_Control__c permissionControlForContact = new pse__Permission_Control__c(
                pse__User__c = userSysAdmin.Id,
                pse__Resource__c = objContact.Id,
                pse__Cascading_Permission__c = true,
                pse__Staffing__c = true,
                pse__Expense_Entry__c = true,
                pse__Expense_Ops_Edit__c = true,
                pse__Team_Edit__c = true,
                pse__Resource_Request_Entry__c = true,
                pse__Billing__c = true,
                pse__Timecard_Entry__c = true,
                pse__Team_View__c = true,
                pse__Team_Create__c = true,
                pse__Skills_And_Certifications_View__c = true,
                pse__Skills_And_Certifications_Entry__c = true
        ) ;

        permissionsToInsert.add(permissionControlForContact);

        pse__Permission_Control__c permissionControlForProject = new pse__Permission_Control__c(
                pse__User__c = userSysAdmin.Id,
                pse__Project__c = objProject.Id,
                pse__Cascading_Permission__c = true,
                pse__Staffing__c = true,
                pse__Expense_Entry__c = true,
                pse__Expense_Ops_Edit__c = true,
                pse__Team_Edit__c = true,
                pse__Resource_Request_Entry__c = true,
                pse__Billing__c = true,
                pse__Timecard_Entry__c = true,
                pse__Team_View__c = true,
                pse__Team_Create__c = true,
                pse__Skills_And_Certifications_View__c = true,
                pse__Skills_And_Certifications_Entry__c = true
        ) ;
        permissionsToInsert.add(permissionControlForProject);

        pse__Permission_Control__c permissionControlForRegion = new pse__Permission_Control__c(
                pse__Region__c = objRegion.Id,
                pse__User__c = userSysAdmin.Id,
                pse__Cascading_Permission__c = true,
                pse__Staffing__c = true,
                pse__Expense_Entry__c = true,
                pse__Expense_Ops_Edit__c = true,
                pse__Team_Edit__c = true,
                pse__Resource_Request_Entry__c = true,
                pse__Billing__c = true,
                pse__Timecard_Entry__c = true,
                pse__Team_View__c = true,
                pse__Team_Create__c = true,
                pse__Skills_And_Certifications_View__c = true,
                pse__Skills_And_Certifications_Entry__c = true
        ) ;
        permissionsToInsert.add(permissionControlForRegion);

        insert permissionsToInsert;

        // Create the Schedule
        pse__Schedule__c schedule = new pse__Schedule__c();
        schedule.pse__Start_Date__c = objProject.pse__Start_Date__c;
        schedule.pse__End_Date__c = objProject.pse__End_Date__c;

        insert schedule;
        
        System.runAs(userSysAdmin) {
            // Create the Assignment
            pse__Assignment__c assignment = new pse__Assignment__c(
                pse__Resource__c = objContact.Id,
                pse__Resource__r = objContact,
                pse__Project__c = objProject.Id,
                pse__Project__r = objProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = schedule.Id,
                pse__Schedule__r = schedule,
                pse__Closed_for_Expense_Entry__c = false
            );
            insert assignment;
        
            // Create the Time Card
            pse__Timecard_Header__c objTimecardTest = new pse__Timecard_Header__c(
                pse__Project__c = objProject.Id,
                pse__Status__c = 'Approved',
                pse__Resource__c = objContact.Id,
                pse__Approved__c = true,
                pse__Submitted__c = true,
                pse__Start_Date__c = Datetime.newInstanceGmt(2008, 12, 1, 12, 30, 2).date(),
                pse__End_Date__c = Datetime.newInstanceGmt(2008, 12, 1, 12, 30, 2).addDays(6).date(),
                pse__Assignment__c = assignment.Id
            );
            insert objTimecardTest;

            pse__Task_Time__c timeRecord = new pse__Task_Time__c();
            timeRecord.pse__Timecard__c = objTimecardTest.Id;
            timeRecord.pse__Project_Task__c = objProjectTask.Id;
            insert timeRecord;
        }
        
        String triggerErrorMessage = 'This Project Task cannot be deleted because it has related Work Orders and/or has Time entered against it.';

        objProjectTask.OwnerId = userPSAAdministrator.Id;
        update objProjectTask;
        System.runAs(userPSAAdministrator) {
            try{
                Database.DeleteResult deleteResult = Database.delete(objProjectTask.Id);
            }catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains(triggerErrorMessage) ? true : false;
                //System.AssertEquals(expectedExceptionThrown, true, 'It is not expected that a PSA Administrator deletes a linked project task.');
            }
        }

        ProjectTaskHandler.preventDeletionActiveTasksCreated = false;

        objProjectTask.OwnerId = userPSAProjectSupportLead.Id;
        update objProjectTask;
        System.runAs(userPSAProjectSupportLead) {
            try{
                Database.DeleteResult deleteResult = Database.delete(objProjectTask.Id);
            }catch(Exception e){
                Boolean expectedExceptionThrown = e.getMessage().contains(triggerErrorMessage) ? true : false;
                //System.AssertEquals(expectedExceptionThrown, true, 'It is not expected that a PSA Intake deletes a project task.');
            }
        }

        ProjectTaskHandler.preventDeletionActiveTasksCreated = true;

        //objProjectTask.OwnerId = userPSAProjectManager.Id;
        //update objProjectTask;
        //System.runAs(userPSAProjectManager) {
        //    try{
        //        Database.DeleteResult deleteResult = Database.delete(objProjectTask.Id);
        //    }catch(Exception e){
        //        Boolean expectedExceptionThrown = e.getMessage().contains(triggerErrorMessage) ? true : false;
        //        System.AssertEquals(expectedExceptionThrown, true, 'It is not expected that a PSA Project Manager deletes a linked project task.');
        //    }
        //}

        objProjectTask.OwnerId = userSysAdmin.Id;
        update objProjectTask;
        System.runAs(userSysAdmin) {
            try{
                Database.DeleteResult deleteResult = Database.delete(objProjectTask.Id);
                //System.AssertEquals(true, deleteResult.isSuccess(), 'It is expected that a linked project task can be deleted by the System Administrator');
            }catch(Exception e){
            }
        }
        Test.stopTest();  
        }
    }

    public static String GetDefaultValueForReasonNotToSurvey(){
        String defaultVal = '';
        Schema.DescribeFieldResult F = pse__Proj__c.Reason_Not_To_Survey__c.getDescribe();
        List <Schema.PicklistEntry> pickVals = F.getPicklistValues();
        if(!pickVals.isEmpty()){
            defaultVal = pickVals.get(0).getValue();     
            for (Schema.PicklistEntry pv: pickVals) {
                if (pv.isDefaultValue()) {
                    defaultVal = pv.getValue();
                }    
            }
        }
        return defaultVal;
    }

    // Luis Campos 12-10-2019
    @isTest
    static void  testPreventDeletionOnTasksWithAssignments()
    {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            Account objAccountPSA = TestDataGenerator.createAccountPSA();
            insert objAccountPSA;
            Account objAccount = TestDataGenerator.createAccount();
            insert objAccount; 
            pse__Time_Period__c objTimePeriod = TestDataGenerator.createTimePeriod();
            insert objTimePeriod;
            pse__Region__c objRegion = TestDataGenerator.createRegion(objTimePeriod.Id);
            insert objRegion;
            pse__Practice__c objPractice = TestDataGenerator.createPractice(objTimePeriod.Id);
            insert objPractice;
            pse__Work_Calendar__c objWorkCalendar = TestDataGenerator.createWorkCalendar();
            insert objWorkCalendar;
            
            // List of allowed profiles to apply the prevent task validation and the System Administrator as control profile
            List<String> allowedProfiles = new List<String>();
            allowedProfiles.add('PSA Intake');
            allowedProfiles.add('PSA Project Manager');            
            allowedProfiles.add('PSA Direct Manager');
            allowedProfiles.add('PSA Technical Resource');
            allowedProfiles.add('System Administrator');
            map<String, Id > profilesMap = new map<String, Id>();

            for(Profile prof : [Select Id, Name from Profile where Name IN :allowedProfiles]){
                profilesMap.put(prof.Name, prof.Id);
            }
                    
            // Create the users to perform the test
            List<User> usersToInsert = new List<User>();
            User userPSADirectManager = TestDataGenerator.createUser('Brutus','Julian','13');
            userPSADirectManager.ProfileId = profilesMap.get('PSA Direct Manager');
            usersToInsert.add(userPSADirectManager);
            User userPSAProjectSupportLead = TestDataGenerator.createUser('Ceaser','Phil','28');
            userPSAProjectSupportLead.ProfileId = profilesMap.get('PSA Intake');
            usersToInsert.add(userPSAProjectSupportLead);
            User userPSAProjectManager = TestDataGenerator.createUser('Shaun','David','37');
            userPSAProjectManager.ProfileId = profilesMap.get('PSA Project Manager');
            usersToInsert.add(userPSAProjectManager);
            User userPSATechResource = TestDataGenerator.createUser('Burno','Mars','46');
            userPSATechResource.ProfileId = profilesMap.get('PSA Technical Resource');
            usersToInsert.add(userPSATechResource);
            User userSysAdmin = TestDataGenerator.createUser('Rachel','Chandler','54');
            userSysAdmin.ProfileId = profilesMap.get('System Administrator');
            usersToInsert.add(userSysAdmin);
            insert usersToInsert;

            // Create the Contacts
            List<Contact> contactsToInsert = new List<Contact>();
            Contact objContact = TestDataGenerator.createContact('Smith','Julian', objAccount.Id, objRegion.Id, objPractice.Id, objWorkCalendar.Id, userPSADirectManager.Id);
            objContact.pse__Region__c = objRegion.Id;
            contactsToInsert.add(objContact);
            
            Contact objContactAux = TestDataGenerator.createContact('Bonanza','Phill', objAccount.Id, objRegion.Id, objPractice.Id, objWorkCalendar.Id, userPSAProjectSupportLead.Id);
            objContactAux.pse__Region__c = objRegion.Id;
            contactsToInsert.add(objContactAux);

            //insert contactsToInsert;
            
            WorkType objWorkType = TestDataGenerator.createWorkType();
            insert objWorkType;
            pse__Proj__c objProject = TestDataGenerator.createProject(objAccount.Id, objContact.Id, objContactAux.Id, objTimePeriod.Id, objRegion.Id, objPractice.Id);
            objProject.Reason_Not_To_Survey__c = GetDefaultValueForReasonNotToSurvey();
            insert objProject;

            pse__Project_Task__c objParentProjectTask = TestDataGenerator.createParentProjectTask(objProject.Id);
            insert objParentProjectTask;
            Site__c objSite = TestDataGenerator.createSite();
            insert objSite;
            Project_Location__c objProjectSite = TestDataGenerator.createProjectSite(objProject.Id, objSite.Id);
            insert objProjectSite;
            pse__Project_Task__c objProjectTask = TestDataGenerator.createProjectTask(objParentProjectTask.Id, objProject.Id, objProjectSite.Id);
            insert objProjectTask; 

            pse__Project_Task_Assignment__c objProjectTaskAssignment = new pse__Project_Task_Assignment__c();
            objProjectTaskAssignment.CurrencyIsoCode = 'USD';
            objProjectTaskAssignment.pse__Project_Task__c = objProjectTask.Id;
            objProjectTaskAssignment.pse__Resource_Role__c = 'Service Delivery Engineer 2';
            objProjectTaskAssignment.pse__Resource__c = objContact.Id;

            insert objProjectTaskAssignment;

            String triggerErrorMessage = 'This Project Task cannot be deleted because it has related assignments.';

            Test.startTest();

            objProjectTask.OwnerId = userPSADirectManager.Id;
            update objProjectTask;
            System.runAs(userPSADirectManager) {
                try{
                    Database.DeleteResult deleteResult = Database.delete(objProjectTask.Id);
                }catch(Exception e){
                    System.debug('LCDebug: e ' + e);
                    System.debug('LCDebug: e ' + e.getStackTraceString());
                    Boolean expectedExceptionThrown = e.getMessage().contains(triggerErrorMessage) ? true : false;
                    //System.AssertEquals(expectedExceptionThrown, true, 'It is not expected that a PSA Direct Manager deletes a project task with assignments.');
                }
            }

            //objProjectTask.OwnerId = userPSAProjectSupportLead.Id;
            //update objProjectTask;
            System.runAs(userPSAProjectSupportLead) {
                try{
                    Database.DeleteResult deleteResult = Database.delete(objProjectTask.Id);
                }catch(Exception e){
                    System.debug('LCDebug: e ' + e);
                    Boolean expectedExceptionThrown = e.getMessage().contains(triggerErrorMessage) ? true : false;
                    //System.AssertEquals(expectedExceptionThrown, true, 'It is not expected that a PSA Intake deletes a project task with assignments');
                }
            }

            /*
            PSA tech Resource profile doesn't have access to the Project Task object.
            objProjectTask.OwnerId = userPSATechResource.Id;
            update objProjectTask;
            System.runAs(userPSATechResource) {
                try{
                    Database.DeleteResult deleteResult = Database.delete(objProjectTask.Id);
                }catch(Exception e){
                    Boolean expectedExceptionThrown = e.getMessage().contains(triggerErrorMessage) ? true : false;
                    System.AssertEquals(expectedExceptionThrown, true, 'It is not expected that a PSA Tech Resource Lead deletes a project task with assignments');
                }
            }*/

            //objProjectTask.OwnerId = userPSAProjectManager.Id;
            //update objProjectTask;
            System.runAs(userPSAProjectManager) {
                try{
                    Database.DeleteResult deleteResult = Database.delete(objProjectTask.Id);
                }catch(Exception e){
                    Boolean expectedExceptionThrown = e.getMessage().contains(triggerErrorMessage) ? true : false;
                    //System.AssertEquals(expectedExceptionThrown, true, 'It is not expected that a PSA Project Manager deletes a project task with assignments');
                }
            }
            
            //objProjectTask.OwnerId = userSysAdmin.Id;
            //update objProjectTask;
            System.runAs(userSysAdmin) {
                try{
                    Database.DeleteResult deleteResult = Database.delete(objProjectTask.Id);
                    //System.AssertEquals(true, deleteResult.isSuccess(), 'It is expected that a linked project task can be deleted by the System Administrator');
                }catch(Exception e){
                }
            }
            Test.stopTest();
        }
    }
    
   //wrote as a part of test coverage.
    @isTest
    static void  sendProjectTaskDetailsToNovoraAfterUpdate()
    {
        //List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        
        //system.runAs(loginUser[0]){
            
         pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
            
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
                Primary_Phone__c = '5565565556',
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
            
            
          pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Initiate',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'In Progress',
                pse__Project_Manager__c = testContact.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
            );
            
            insert testProject;
            
        pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 30,
                pse__Estimated_Hours__c = 8,
                pse__Description__c = 'Test Description',
                pse__Started__c = true,
                FBE_IDS_Task_IntegrationStatus__c = 'Initiate',
                pse__Project__c = testProject.Id
            );
           
            List<pse__Project_Task__c> addtasktolist = new List<pse__Project_Task__c>();
            addtasktolist.add(testProjectTask);
            insert addtasktolist;
     
            ProjectTaskHandler.sendProjectTaskDetailsToNovoraAfterUpdate(addtasktolist);
            ProjectTaskHandler.insertProjectTaskIntegrationStatus(addtasktolist);
        
            Test.startTest();
            testProjectTask.FBE_IDS_Task_IntegrationStatus__c= 'Pending Sync';
            update testProjectTask;

            Test.stopTest();
            
            pse__Project_Task__c result = [Select Id,Name,pse__Start_Date_Time__c,pse__Project__c,FBE_IDS_Task_IntegrationStatus__c,pse__End_Date_Time__c,pse__Description__c,pse__Started__c from pse__Project_Task__c where Id = : testProjectTask.Id];
            System.assertEquals(result.FBE_IDS_Task_IntegrationStatus__c, 'Pending Sync');
    }
   // }
   // 
   @IsTest
    public static void preventProjectTaskCreationBelowWorkOrderLevelTest(){
        String msg = 'You cannot add a Project Task below another Project Task with an existing Work Order.';
        Id recordTypeInstallationBadge = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
        
        pse__Proj__c project = TestDataGenerator.createBasicProject();
        insert project;
        pse__Project_Task__c parentTask = TestDataGenerator.createParentProjectTask(project.Id);
        insert parentTask;
        WorkOrder workOrder = new WorkOrder(Project_Task__c = parentTask.Id, RecordTypeId = recordTypeInstallationBadge);
        insert workOrder;
		pse__Project_Task__c newTask = new pse__Project_Task__c(
            pse__Parent_Task__c = parentTask.Id,
            Name = 'New Task',
            pse__Start_Date_Time__c = System.Today(),
            pse__End_Date_Time__c = System.Today());

        Test.startTest();
        try {
            insert newTask;
        } catch (Exception e) {
            System.assertEquals(true, e.getMessage().contains(msg));
        }
        Test.stopTest();
    }
   
}