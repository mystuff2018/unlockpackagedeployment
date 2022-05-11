/**
 * Created by Bruno_Frosi on 3/11/2020.
 */

@IsTest
private class FFWorkOrderTriggerHandlerTest {
    @TestSetup
    public static void setup()
    {
        TriggerHandler.bypass('FBE_TriggerHandler'); 
        TriggerHandler.bypass('ContactTriggerHandler'); 
        TriggerHandler.bypass('ProjectTriggerHandler'); 
        TriggerHandler.bypass('LocationTriggerHandler'); 
        TriggerHandler.bypass('ProjectLocationTriggerHandler'); 
        TriggerHandler.bypass('FFServiceAppointmentTriggerHandler'); 
		List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){	
            
            List<Account> lstAccount = new List<Account>();
			Account objAccount = TestDataGenerator.createAccount();
			//insert objAccount;
			lstAccount.add(objAccount);
			Account objAccountPSA = TestDataGenerator.createAccountPSA();
            lstAccount.add(objAccountPSA);
			//insert objAccountPSA;
			insert lstAccount;
			pse__Time_Period__c objTimePeriod = TestDataGenerator.createTimePeriod();
			insert objTimePeriod;
			pse__Region__c objRegion = TestDataGenerator.createRegion(objTimePeriod.Id);
			insert objRegion;
            
             pse__Proj__c projToPractice = MDF_ProjectTemplateFactory.start()
            .projectPhase('Setup')
            .projectType('Standard')
            .stage('Draft')
            .isActive(true)
            .create();
            
            pse__Practice__c objPractice = TestDataGenerator.createPractice(objTimePeriod.Id, projToPractice.Id);
            objPractice.Id = null;
            objPractice.Standard_Project_Template__c = projToPractice.Id;
            insert objPractice;
            
			/*pse__Practice__c objPractice = TestDataGenerator.createPractice(objTimePeriod.Id);
			insert objPractice;*/
			pse__Work_Calendar__c objWorkCalendar = TestDataGenerator.createWorkCalendar();
			insert objWorkCalendar;
            List<User> lstUser = new List<User>();
			User objUser = TestDataGenerator.createUser('Smith24','jhon','97');
			//insert objUser;
			lstUser.add(objUser);
			User objUserAux = TestDataGenerator.createUser('Bonanza','Phill','2');
			//insert objUserAux;
			lstUser.add(objUserAux);
            insert lstUser;
            List<Contact> lstContact = new List<Contact>();
			Contact objContact = TestDataGenerator.createContact('Smith','Julian', objAccountPSA.Id, objRegion.Id, objPractice.Id, objWorkCalendar.Id, objUser.Id);
			//insert objContact;
			lstContact.add(objContact);
			Contact objContactAux = TestDataGenerator.createContact('Bonanza','Phill', objAccountPSA.Id, objRegion.Id, objPractice.Id, objWorkCalendar.Id, objUserAux.Id);
			//insert objContactAux;
			lstContact.add(objContactAux);
            insert lstContact;
			WorkType objWorkType = TestDataGenerator.createWorkType();
			insert objWorkType;
			pse__Proj__c objProject = TestDataGenerator.createProject(objAccount.Id, objContact.Id, objContactAux.Id, objTimePeriod.Id, objRegion.Id, objPractice.Id);
			insert objProject;

			Project_Location__c objProjectSite = TestDataGenerator.createProjectSite(objProject.Id, null);
			insert objProjectSite;
			pse__Project_Task__c objParentProjectTask = TestDataGenerator.createParentProjectTask(objProject.Id);
			objParentProjectTask.pse__Status__c = 'Complete';
			insert objParentProjectTask;
			pse__Project_Task__c objProjectTask = TestDataGenerator.createProjectTask(objParentProjectTask.Id, objProject.Id, objProjectSite.Id);
			objProjectTask.pse__Status__c = 'Complete';
			insert objProjectTask;
        			
			List<WorkOrder> lstWorkOrders = new List<WorkOrder>();
			WorkOrder objWorkOrder = TestDataGenerator.createWorkOrder('FF - New', objAccount.Id, objProject.Id, objProjectTask.Id, objWorkType.Id);
            objWorkOrder.Project_Location__c = objProjectSite.id;
			lstWorkOrders.add(objWorkOrder);
			WorkOrder objWorkOrderAUX = TestDataGenerator.createWorkOrder('FF - New', objAccount.Id, objProject.Id, objProjectTask.Id, objWorkType.Id);
			lstWorkOrders.add(objWorkOrderAUX);
            //insert lstWorkOrders;            
            
            Id workrecordtypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Installation DSP').getRecordTypeId();
            WorkOrder wo = new WorkOrder();
            wo.Status = 'FF - New';
            wo.AccountId = objAccount.Id;
            wo.Project__c = objProject.Id;
            wo.Project_Task__c = objProjectTask.Id;
            wo.WorkTypeId = objWorkType.Id;
            wo.RecordTypeId = workrecordtypeId;
            //insert wo;
            lstWorkOrders.add(wo);
            
            Id workrecordtypeId1 = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Delta Dispatch').getRecordTypeId();
            WorkOrder wo1 = new WorkOrder();
            wo1.Status = 'FF - New';
            wo1.AccountId = objAccount.Id;
            wo1.Project__c = objProject.Id;
            wo1.Project_Task__c = objProjectTask.Id;
            wo1.WorkTypeId = objWorkType.Id;
            wo1.RecordTypeId = workrecordtypeId1;
            //insert wo1;
 			lstWorkOrders.add(wo1);
            insert lstWorkOrders;
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            
            ServiceAppointment testSA = new ServiceAppointment(
                Work_Order__c = lstWorkOrders[0].Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = lstWorkOrders[0].Id,
                RecordTypeId = installationBadgeRecordType
            );
            insert testSA;
        }	
        TriggerHandler.clearAllBypasses();
    }
    
    @IsTest
    public static void preventWOCreationOnTaskWithChildrenTest(){
        String msg = System.Label.Prevent_WO_Creation_On_Task_With_Children;
        Test.startTest();
        //Id recordTypeInstallationBadge = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
        List<pse__Project_Task__c> projectTask = [SELECT Id FROM pse__Project_Task__c LIMIT 1];
        WorkOrder workOrder = new WorkOrder(Project_Task__c = projectTask[0].Id);
        try {
            insert workOrder;
        } catch (Exception e) {
            System.assertEquals(true, e.getMessage().contains(msg));
        }
        Test.stopTest();
    }

    @IsTest
    public static void updateProjectStatus()
    {
        Test.startTest();
        List<WorkOrder> lstWorkOrders = [SELECT Id, Project_Task__c FROM WorkOrder LIMIT 1];
        pse__Proj__c objProject = [SELECT Id FROM pse__Proj__c LIMIT 1];
        
        Set<Id> setPTAux = new Set<Id>();

        for (WorkOrder objWo : lstWorkOrders)
        {
            setPTAux.add(objWo.Project_Task__c);
        }

        List<pse__Project_Task__c> mapIdxPT = [SELECT Id, pse__Summary__c,pse__Completed__c,pse__Status__c
        FROM pse__Project_Task__c
        WHERE Id IN:setPTAux LIMIT 1];
        for(pse__Project_Task__c pt :mapIdxPT)
        {
            pt.pse__Status__c = 'Complete';
            pt.pse__Summary__c = false;
            pt.pse__Completed__c = true;
            pt.pse__Started__c  = true;
        }
        UPDATE mapIdxPT;

        Project_Location__c objProjectSite = TestDataGenerator.createProjectSite(objProject.Id, null);
        insert objProjectSite;
                
        
        for(WorkOrder wo :lstWorkOrders)
        {
            wo.Project_Location__c = objProjectSite.Id;
            wo.Status = 'FF - Submitted';
        }
        
        UPDATE lstWorkOrders;

        Test.stopTest();
    }

    @IsTest
    public static void updateWorkOrderStatus()
    {
        Test.startTest();
        List<WorkOrder> lstWorkOrders = [SELECT Id, Project_Task__c FROM WorkOrder LIMIT 1];

        Set<Id> setPTAux = new Set<Id>();

        for (WorkOrder objWo : lstWorkOrders)
        {
            setPTAux.add(objWo.Project_Task__c);
        }

        List<pse__Project_Task__c> mapIdxPT = [SELECT Id, pse__Parent_Task__c, pse__Summary__c,pse__Completed__c,pse__Status__c
                                               FROM pse__Project_Task__c
                                               WHERE Id IN:setPTAux LIMIT 1];
        for(pse__Project_Task__c pt :mapIdxPT)
        {
            pt.pse__Status__c = 'Complete';
            pt.pse__Summary__c = false;
            pt.pse__Started__c  = true;
            pt.pse__Completed__c = true;
        }
        UPDATE mapIdxPT;

        for(WorkOrder wo :lstWorkOrders)
        {
            wo.Status = 'FF - Closed';
        }
        
        UPDATE lstWorkOrders;
      
        
        Test.stopTest();
    }
  
        
    /*@IsTest
    public static void CancelWorkOrderStatus()
    {
        test.startTest();
        List<WorkOrder> lstWorkOrders = [SELECT Id,Status, Project_Task__c FROM WorkOrder];
        
        for(WorkOrder wo :lstWorkOrders)
        {
            wo.Status = 'Cancelled';
        }
        
        UPDATE lstWorkOrders;
        
         test.stopTest(); 
        
    }*/
}