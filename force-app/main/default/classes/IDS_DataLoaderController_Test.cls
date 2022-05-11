@isTest(SeeAllData = true)
public class IDS_DataLoaderController_Test {
	@isTest
    public static void saveChunkTest(){
          User loginUser =  [Select Id from User where FBE_Integration_User__c = true];
          system.runAs(loginUser){ 
    string skuData = '256-10005;826-9391;826-9431;256-10015;826-9445;826-9405;256-10613;825-0185;825-0264;256-10615;256-10019;256-10000;256-10713~ProDeploy AddOn for Dell EMC Unity Cloud Tiering Software_Hybrid~45~0~Infrastructure Delivery Services~Initiate~Scoping~~High~1~Delivery - ProDeploy,3;Unity - Design,3~Scoping Activity~Remote~By Threshold~0.5~2~0.5~1~Activity~Installation Badge~~Initiate';
    
    // create a blob from our parameter value before we send it as part of the url
    Blob skuDatablob = Blob.valueOf(skuData);
        
    // base64 encode the blob that contains our url param value
    string skuDataBase64 = EncodingUtil.base64Encode(skuDatablob);
        string skuDataBase641 = EncodingUtil.urlEncode(skuDataBase64,'UTF-8');
         pse__proj__c proj = [select id from pse__proj__c where Name = 'ISG Phased Project Template - Base - Global'];
         pse__Practice__c testPractice = new pse__Practice__c(
                Name = 'Infrastructure Delivery Services',
                Standard_Project_Template__c = proj.Id
            );
            insert testPractice;
			
			  pse__Region__c testRegion = new pse__Region__c(
                Name = 'Test Region'
            );
            insert testRegion;
			
			Contact testContact = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
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
                Name = 'Phased Project Template - Custom - Global',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Initiate',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'In Progress',
                pse__Project_Manager__c = testContact.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true,
              	pse__Is_Template__c = true
            );
            
            insert testProject;
			
		pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'PM Activities',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 30,
                pse__Estimated_Hours__c = 0.8,
                pse__Description__c = 'Test Description',
                pse__Started__c = true,
                FBE_IDS_Task_IntegrationStatus__c = 'Initiate',
                pse__Project__c = testProject.Id
            );
        pse__Project_Task__c testProjectTask1 = new pse__Project_Task__c(
                Name = 'Initiate',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 30,
                pse__Estimated_Hours__c = 0.8,
                pse__Description__c = 'Test Description',
                pse__Started__c = true,
                //FBE_IDS_Task_IntegrationStatus__c = 'Initiate',
                pse__Project__c = testProject.Id
            );
        pse__Project_Task__c testProjectTask2 = new pse__Project_Task__c(
                Name = 'Plan',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 30,
                pse__Estimated_Hours__c = 0.8,
                pse__Description__c = 'Test Description',
                pse__Started__c = true,
                //FBE_IDS_Task_IntegrationStatus__c = 'Initiate',
                pse__Project__c = testProject.Id
            );
        pse__Project_Task__c testProjectTask3 = new pse__Project_Task__c(
                Name = 'Execute',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 30,
                pse__Estimated_Hours__c = 0.8,
                pse__Description__c = 'Test Description',
                pse__Started__c = true,
                //FBE_IDS_Task_IntegrationStatus__c = 'Initiate',
                pse__Project__c = testProject.Id
            );
        pse__Project_Task__c testProjectTask4 = new pse__Project_Task__c(
                Name = 'Close',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 30,
                pse__Estimated_Hours__c = 0.8,
                pse__Description__c = 'Test Description',
                pse__Started__c = true,
                //FBE_IDS_Task_IntegrationStatus__c = 'Initiate',
                pse__Project__c = testProject.Id
            );
    
           
			List<pse__Project_Task__c> addtasktolist = new List<pse__Project_Task__c>();
        	addtasktolist.add(testProjectTask);
        	addtasktolist.add(testProjectTask1);
        	addtasktolist.add(testProjectTask2);
        	addtasktolist.add(testProjectTask3);
        	addtasktolist.add(testProjectTask4);
            insert addtasktolist;
        IDS_DataLoaderController.saveChunk(NULL,NULL,skuDataBase641,NULL,NULL);
    }
    }
}