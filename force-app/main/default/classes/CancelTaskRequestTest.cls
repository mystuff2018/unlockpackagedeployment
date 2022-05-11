@isTest

private class CancelTaskRequestTest {
    
    static testMethod void testCommented(){
        Test.StartTest();
        
        CancelTaskRequest obj = new CancelTaskRequest();
        obj.ReturnAssignment = false;
        
        system.assertNotEquals(null,obj);   
        Test.StopTest();
    }
}