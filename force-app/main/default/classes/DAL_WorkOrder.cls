/*
 * @test DAL_WorkOrderTest
 * @authors Pablo Dunke and Romulo Spier
 * @date 04/29/2020
 * @description Data access layer for the Work Order Object
 */

public with sharing class DAL_WorkOrder 
{
    public static List<WorkOrder> getBySetProjectTaskId(Set<Id> pSetProjectTaskId)
    {
        List<WorkOrder> listWorkOrder = [SELECT Id
                                                , Project_Task__c
                                                , Status 
                                            FROM WorkOrder 
                                            WHERE Project_Task__c IN: pSetProjectTaskId];

        return listWorkOrder;
    }
}