@isTest
public class Issue_Rollup_Trigger_Handler_Test {
    @isTest
    static void startTest()
    {
        System.debug('abhi:startTest started');
         pse__Region__c region = new pse__Region__c (Name='CA',CurrencyIsoCode='USD');
        insert region;
        System.debug('abhi:region='+region);
        Account account = TestDataUtility.createAccounts(1, true)[0];
       System.debug('abhi:account='+account);
        pse__Proj__c project = TestDataUtility.createProject(account.Id,region.Id,true);
        System.debug('abhi:project='+project);
        
        project = [Select id,Budget_and_Staffing_status_text__c From pse__Proj__c where Id=:project.Id][0];
        System.debug('abhi:project='+project);
        System.assertEquals('Green - No issue/risk', project.Budget_and_Staffing_status_text__c, 'Budget and Staffing Status should be Green - No issues/risks');
        pse__Issue__c issue = new pse__Issue__c();
        issue.pse__Issue_Name__c = 'Test Issue 1';
        issue.pse__Status__c = 'Not Yet Started';
        issue.FBE_IDS_Issue_Type__c = 'Budget and Staffing';
        issue.pse__Project__c = project.Id;
        issue.Category__c = 'Regular';
        issue.DO_Currency__c = '200';
        issue.DO_Request_Type__c = 'New Request';
        issue.DO_Value__c = '2';
        issue.SubCategory__c = 'Normal';
        issue.Which_Partner__c = 'Test'; 
        insert issue;
        
        project = [Select id,Budget_and_Staffing_status_text__c,Delivery_Execution_Status_text__c,
                   Schedule_and_Quality_Status_text__c, Overall_Status_text__c From pse__Proj__c 
                   where Id=:project.Id][0];
        System.debug('abhi:project='+project);
        System.assertEquals('Yellow - Minor issue/risk', project.Budget_and_Staffing_status_text__c, 'Budget and Staffing Status not updated correctly.');
    	
        pse__Issue__c issue2 = new pse__Issue__c();
        issue2.pse__Issue_Name__c = 'Test Issue 2';
        issue2.pse__Status__c = 'Not Yet Started';
        issue2.FBE_IDS_Issue_Type__c = 'Budget and Staffing';
        issue2.pse__Project__c = project.Id;
        issue2.Category__c = 'Regular';
        issue2.DO_Currency__c = '200';
        issue2.DO_Request_Type__c = 'New Request';
        issue2.DO_Value__c = '2';
        issue2.SubCategory__c = 'Normal';
        issue2.Which_Partner__c = 'Test'; 
        insert issue2;
        
        project = [Select id,Budget_and_Staffing_status_text__c,Delivery_Execution_Status_text__c,
                   Schedule_and_Quality_Status_text__c, Overall_Status_text__c From pse__Proj__c 
                   where Id=:project.Id][0];
        System.assertEquals('Red - Major issue/risk', project.Budget_and_Staffing_status_text__c, 'Budget and Staffing Status not updated correctly.');
        
        issue2.pse__Status__c = 'Closed - No action';
        issue2.pse__Closed_Date__c = Date.today();
        update issue2;
        
        pse__Issue__c issue3 = new pse__Issue__c();
        issue3.pse__Issue_Name__c = 'Test Issue 3';
        issue3.pse__Status__c = 'Not Yet Started';
        issue3.FBE_IDS_Issue_Type__c = 'Delivery Execution';
        issue3.pse__Project__c = project.Id;
        issue3.Category__c = 'Regular';
        issue3.DO_Currency__c = '200';
        issue3.DO_Request_Type__c = 'New Request';
        issue3.DO_Value__c = '2';
        issue3.SubCategory__c = 'Normal';
        issue3.Which_Partner__c = 'Test'; 
        insert issue3;
        
        project = [Select id,Budget_and_Staffing_status_text__c,Delivery_Execution_Status_text__c,
                   Schedule_and_Quality_Status_text__c, Overall_Status_text__c From pse__Proj__c 
                   where Id=:project.Id][0];
        System.assertEquals('Yellow - Minor issue/risk', project.Delivery_Execution_Status_text__c, 'Delivery Execution Status not updated correctly.');
        
        pse__Issue__c issue4 = new pse__Issue__c();
        issue4.pse__Issue_Name__c = 'Test Issue 4';
        issue4.pse__Status__c = 'Not Yet Started';
        issue4.FBE_IDS_Issue_Type__c = 'Schedule';
        issue4.pse__Project__c = project.Id;
        issue4.Category__c = 'Regular';
        issue4.DO_Currency__c = '200';
        issue4.DO_Request_Type__c = 'New Request';
        issue4.DO_Value__c = '2';
        issue4.SubCategory__c = 'Normal';
        issue4.Which_Partner__c = 'Test'; 
        insert issue4;
        
        project = [Select id,Budget_and_Staffing_status_text__c,Delivery_Execution_Status_text__c,
                   Schedule_and_Quality_Status_text__c, Overall_Status_text__c From pse__Proj__c 
                   where Id=:project.Id][0];
        System.assertEquals('Yellow - Minor issue/risk', project.Schedule_and_Quality_Status_text__c, 'Schedule and Quality Status not updated correctly.');
        
        pse__Issue__c issue5 = new pse__Issue__c();
        issue5.pse__Issue_Name__c = 'Test Issue 5';
        issue5.pse__Status__c = 'Not Yet Started';
        issue5.FBE_IDS_Issue_Type__c = 'Quality';
        issue5.pse__Project__c = project.Id;
        issue5.Category__c = 'Regular';
        issue5.DO_Currency__c = '200';
        issue5.DO_Request_Type__c = 'New Request';
        issue5.DO_Value__c = '2';
        issue5.SubCategory__c = 'Normal';
        issue5.Which_Partner__c = 'Test'; 
        insert issue5;
        
        project = [Select id,Budget_and_Staffing_status_text__c,Delivery_Execution_Status_text__c,
                   Schedule_and_Quality_Status_text__c, Overall_Status_text__c From pse__Proj__c 
                   where Id=:project.Id][0];
        System.assertEquals('Red - Major issue/risk', project.Schedule_and_Quality_Status_text__c, 'Schedule and Quality Status not updated correctly.');
    }
}