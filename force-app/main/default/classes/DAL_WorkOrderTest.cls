/*
 * @class DAL_WorkOrder
 * @authors Pablo Dunke and Romulo Spier
 * @date 04/29/2020
 */

@IsTest
private class DAL_WorkOrderTest 
{
       @IsTest
       static void testGetBySetProjectTaskId() 
       {
    //     // Create the data
           pse__Proj__c project = OPRTestFactory.createProject();

           pse__Project_Task__c projectTask = new pse__Project_Task__c();
           projectTask.pse__Project__c = project.Id;
           projectTask.Name = 'Initiate';
           insert projectTask;

           WorkOrder workOrder = new WorkOrder();
           workOrder.Project_Task__c = projectTask.Id;
           workOrder.Status = 'FF - New';
           insert workOrder;

           Set<Id> setProjectTaskId = new Set<Id>();
           setProjectTaskId.add(projectTask.Id);

    //     // Action
           Test.startTest();
           List<WorkOrder> listWorkOrder = DAL_WorkOrder.getBySetProjectTaskId(setProjectTaskId);
           Test.stopTest();

    //     // Assertion
           System.assertEquals(1, listWorkOrder.size());
      }
}