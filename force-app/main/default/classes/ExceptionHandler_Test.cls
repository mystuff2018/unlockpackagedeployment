/* -----------------------------------------------------------------------------------------------------------------------
Name:       ExceptionHandler_Test
Description:  Test class for ExceptionHandler which Logs the exception into Salesforce Object called ExceptionLogger__c
----------------------------------------------------------------------------------------------------------------------------
Date         Version          Author             Summary of Changes 
-----------  -------  ------------------------  ------------------------------------------------------------------------------
01/4/2017     1.0       Amitabh Wankhede   		  Initial Release
01/17/2018    1.1       Roselin Hephzibah 		  Chaneges are based on Code Review Defect 4561213
01/23/2018    1.2       R.Hari Krishna   		  Chaneges are based on Code Review Defect 4561213
01/24/2018    1.3       Srikanth Parvathareddy    Changes are based on Code Review Defect #4561229
03/13/2018	  1.4		Srikanth P				  System.runas() included  - Defect #4777313	
03/20/2018	  1.5       Surya					  insert a; included in setUpData() method - Code Review
-------------------------------------------------------------------------------------------------------------------------- */


@isTest
private class ExceptionHandler_Test { 
   /*
*  @author          : Srikanth Parvathareddy
*  @description     : Method to create test data
*  @params          : N/A
*  @returns         : N/A
*/
    //setting up test data
    @testSetup
    private static void setUpData() {
     //   user testUser = SRVS_CreateTestDataFactory.createUser('Standard User');
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
			Account a = SRVS_CreateTestDataFactory.createSingleAccountRecord();
			insert a;
			List<contact> listOfContact = SRVS_CreateTestDataFactory.createMultipleContactRecords(a,200); 
			insert listOfContact;
			List<ExceptionLogger__c> listOfExceptionLogger = SRVS_CreateTestDataFactory.createMultipleExceptionLoggerRecords(200);
			insert listOfExceptionLogger;
		}	
    }
    class appexception extends exception{}
// Method Handles Insert record error exception async
   /* @isTest  
    private static void logHandledExceptionsAsync() {
        test.startTest();
        ExceptionHandler.logHandledExceptionsAsync(new appexception(), 'TestClassFailure', 'TestMethodFailure', 'TestModule');
        Test.stopTest();
        system.assertEquals(true , [select id from ExceptionLogger__c].size()>0);
    
    
    } // end of handlegenericExceptionMethod()
    */
// Method Handles Insert record error exception
    @isTest  
    private static void handleInsertDSRExceptionMethod() {
        User u1=SRVS_CreateTestDataFactory.createUser('Standard User');
        system.runAs(u1){  
        Test.startTest(); 
        List<Contact> lstOfCons = new List<contact>();
        List<contact> c=[select id from contact];
        for (Contact conObj : c) {
            // contact without LastName            
            conObj.lastname = '';
            lstOfCons.add(conObj);
        }

        Database.SaveResult[] lsr = Database.insert(lstOfCons, false);
        List<Database.SaveResult> listOfSR = new List <Database.SaveResult>();
        for (Database.SaveResult sr: lsr) {
            if (!sr.isSuccess()) {
                listOfSR.add(sr);
            } // end of If
        } // end of for
        ExceptionHandler.logHandledExceptions(listOfSR, 'TestClassFailure', 'TestMethodFailure', 'TestModule');
        Test.stopTest();
        system.assertEquals(200, listOfSR.size());
        }      
    } // end of handlegenericExceptionMethod()
    
//**********************************************************************
// Method Handles Generic Exception
    @isTest
    private static void handleGenericExceptionMethod() {
        User u2=SRVS_CreateTestDataFactory.createUser('Standard User');
        system.runAs(u2){
        Test.startTest();
        List<Contact> lstOfCons1 = new List<contact>();
        List<Contact> cs=[select id,lastname from contact];
        for (Contact conObj1 : cs) {
            // contact without LastName            
            conObj1.lastname = '';
            lstOfCons1.add(conObj1);
        }
        // testing mandatory field check
        if (lstOfCons1 != null && lstOfCons1.size() > 0) {
            try {
                insert lstOfCons1;
            } catch (Exception Ex) {
                ExceptionHandler.logHandledExceptions(Ex, 'TestClassFailure', 'TestMethodFailure', 'TestModule');
            } // end of catch
        } // end of if
        Test.stopTest();
        System.assertEquals(200,lstOfCons1.size());    
        }      
    } // end of handleGenericExceptionMethod()
    
//******************************************************************************
// Method Handles error occured in deleting record
    @isTest
    private static void handleDSRExceptionMethod() {
	    List < Database.DeleteResult > listOfDR = new List < Database.DeleteResult > (); 
        User u3=SRVS_CreateTestDataFactory.createUser('Standard User');
        system.runAs(u3){
		Test.startTest();
        List<ExceptionLogger__c> loe=[select id from ExceptionLogger__c];
        List < ExceptionLogger__c > listOfDeleteExceptionLogger = new List<ExceptionLogger__c >();
        if (loe != null && loe.size() > 0) {            
                listOfDeleteExceptionLogger= loe.clone();                
                Approval.LockResult[] lrList = Approval.lock(loe, false);            
        } //end of if
    //    user testUser1 = SRVS_CreateTestDataFactory.createUser('Standard User');        
     //   system.runAs(testUser1){       
        listOfDR = new List < Database.DeleteResult >();     
        Database.DeleteResult[] ldr = Database.delete(listOfDeleteExceptionLogger, false);                    
        for (Database.DeleteResult dr: ldr) {
            if (!dr.isSuccess()) {
                listOfDR.add(dr);
            } // end of If
        } // end of for
        ExceptionHandler.logHandledExceptions(listOfDR, 'TestClassFailure', 'TestMethodFailure', 'TestModule');
       //   } //end of systemrunas
        Test.stopTest();
        system.assertEquals(200, listOfDR.size());
        }      
    } // end of handleDSRExceptionMethod()
//**********************************************************************
//
// Methods handles upsert record error
	@isTest
    private static void handleUpsertExceptionMethod() {        
        User u4=SRVS_CreateTestDataFactory.createUser('Standard User');
        system.runAs(u4){
        Test.startTest();
        list<contact> ct=[select id from contact];
        List < Contact> listOfUpsertContact = new List < Contact > ();
        List < Database.UpsertResult > listOfUR = new List < Database.UpsertResult > ();
        if (ct != null && ct.size() > 0) {            
                listOfUpsertContact = ct.clone();
                for(contact objCon3 : listOfUpsertContact ){
                    objCon3.LastName = '';
                }// end of for
           } //end of if
        Database.UpsertResult[] ldr = Database.upsert(listOfUpsertContact, false);
        for (Database.UpsertResult ur: ldr) {
            if (!ur.isSuccess()) {
                listOfUR.add(ur);
            } // end of If
        } // end of for
        ExceptionHandler.logHandledExceptions(listOfUR, 'TestClassFailure', 'TestMethodFailure', 'TestModule');
        try{
        delete ct;
        delete ct;        
        }catch(Exception Ex){
            ExceptionHandler.logHandledExceptions(Ex, 'TestClassFailure', 'TestMethodFailure', 'TestModule');
        }
        Test.stopTest();
        System.assertEquals(200,listOfUR.size());
        }
    } // end of handleUpsertExceptionMethod()    
    
    
    //**********************************************************************
	// Method Handles API Callout Exception
    @isTest
    private static void handleApiExceptionMethod() {
        
        Test.setMock(HttpCalloutMock.class, new ApiExceptionMockGenerator());
        User u5=SRVS_CreateTestDataFactory.createUser('Standard User');
        system.runAs(u5){
        Test.startTest();
        ExceptionLogger__c newAPIException= new ExceptionLogger__c();
        
        newAPIException.Error_Code__c = '401';
        newAPIException.Apex_Class__c = 'classname';
        newAPIException.API_Status_Message__c = 'GateWay Failure';
        newAPIException.Object_Name__c = 'Case';
        newAPIException.Module__c = 'Case Module';
        insert newAPIException;
        

        List<ExceptionLogger__c > newlist = [select Error_Code__c,Apex_Class__c,API_Status_Message__c, 
                                                    Object_Name__c, Module__c  from ExceptionLogger__c ];
        ExceptionHandler.logCalloutErrors(null, 'className', newAPIException.id, 'testModule');
        
        Test.stopTest();
        system.assertEquals(true,newlist.size()>0);
        }      
    }
    
    /* Generates the mock response */
    public class ApiExceptionMockGenerator implements HttpCalloutMock {
        // Implement this interface method
      	public HTTPResponse respond(HTTPRequest req) {
          	System.assertEquals('POST', req.getMethod());
          	// Create a fake response
          	HttpResponse res = new HttpResponse();
          	res.setStatusCode(400);
          	return res;
      	}
  	}
    
} // end of class