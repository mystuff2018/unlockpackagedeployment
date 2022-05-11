/**
* @author Thomas Davis <thdavis@financialforce.com>
* @date 2020-02-25
* @description Handler class to rollup ServiceAppointment dates to their associated pse__Project_Task__c.
* TFS Story 7693685.
*/
public class SADateRollupHandler
{
    /*******************************************************************************************************
    * @description Map with ServiceAppointment Id as the key, and its WorkOrder record as the value. Set by
    * the setSAIdToWorkOrderMap() method that is called inside the public rollupDatesToProjectTask() method.
    */
    private static Map<Id, WorkOrder> saIdToWorkOrderMap;

    /*******************************************************************************************************
    * @description Used to perform the date rollups from the ServiceAppointment to the pse__Project_Task__c.
    * @param oldSAs Map of old ServiceAppointment records.
    * @param newSAs Map of new ServiceAppointment records.
    * @return void
    * @example
    * SADateRollupHandler.rollupDatesToProjectTask(Trigger.oldMap, Trigger.newMap);
    */
    public static void rollupDatesToProjectTask(Map<Id, ServiceAppointment> oldSAs, Map<Id, ServiceAppointment> newSAs)
    {
        setSAIdToWorkOrderMap(newSAs.values());

        List<pse__Project_Task__c> projectTaskUpdates = new List<pse__Project_Task__c>();

        for (ServiceAppointment sa : newSAs.values())
        {
            if (saIdToWorkOrderMap.get(sa.Id) != null && saDateUpdated('SchedStartTime', oldSAs.get(sa.Id), sa) &&
                    (sa.SchedStartTime < saIdToWorkOrderMap.get(sa.Id).Project_Task__r.pse__Start_Date_Time__c || saIdToWorkOrderMap.get(sa.Id).Project_Task__r.pse__Start_Date_Time__c == null))
            {
                saIdToWorkOrderMap.get(sa.Id).Project_Task__r.pse__Start_Date_Time__c = sa.SchedStartTime;

                if (!projectTaskUpdates.contains(saIdToWorkOrderMap.get(sa.Id).Project_Task__r))
                {
                    projectTaskUpdates.add(saIdToWorkOrderMap.get(sa.Id).Project_Task__r);
                }
            }

            if (saIdToWorkOrderMap.get(sa.Id) != null && saDateUpdated('SchedEndTime', oldSAs.get(sa.Id), sa) &&
                    (sa.SchedEndTime > saIdToWorkOrderMap.get(sa.Id).Project_Task__r.pse__End_Date_Time__c || saIdToWorkOrderMap.get(sa.Id).Project_Task__r.pse__End_Date_Time__c == null))
            {
                saIdToWorkOrderMap.get(sa.Id).Project_Task__r.pse__End_Date_Time__c = sa.SchedEndTime;

                if (!projectTaskUpdates.contains(saIdToWorkOrderMap.get(sa.Id).Project_Task__r))
                {
                    projectTaskUpdates.add(saIdToWorkOrderMap.get(sa.Id).Project_Task__r);
                }
            }

            if (saIdToWorkOrderMap.get(sa.Id) != null && saDateUpdated('ActualStartTime', oldSAs.get(sa.Id), sa) &&
                    (sa.ActualStartTime < saIdToWorkOrderMap.get(sa.Id).Project_Task__r.pse__Actual_Start_Date_Time__c || saIdToWorkOrderMap.get(sa.Id).Project_Task__r.pse__Actual_Start_Date_Time__c == null))
            {
                saIdToWorkOrderMap.get(sa.Id).Project_Task__r.pse__Actual_Start_Date_Time__c = sa.ActualStartTime;

                if (!projectTaskUpdates.contains(saIdToWorkOrderMap.get(sa.Id).Project_Task__r))
                {
                    projectTaskUpdates.add(saIdToWorkOrderMap.get(sa.Id).Project_Task__r);
                }
            }

            if (saIdToWorkOrderMap.get(sa.Id) != null && saDateUpdated('ActualEndTime', oldSAs.get(sa.Id), sa) &&
                    (sa.ActualEndTime > saIdToWorkOrderMap.get(sa.Id).Project_Task__r.pse__Actual_End_Date_Time__c || saIdToWorkOrderMap.get(sa.Id).Project_Task__r.pse__Actual_End_Date_Time__c == null))
            {
                saIdToWorkOrderMap.get(sa.Id).Project_Task__r.pse__Actual_End_Date_Time__c = sa.ActualEndTime;

                if (!projectTaskUpdates.contains(saIdToWorkOrderMap.get(sa.Id).Project_Task__r))
                {
                    projectTaskUpdates.add(saIdToWorkOrderMap.get(sa.Id).Project_Task__r);
                }
            }
        }

        if (!projectTaskUpdates.isEmpty())
        {
            try
            {
                update projectTaskUpdates;
            }
            catch (Exception e)
            {
                ExceptionLogger__c exceptionLogger = new ExceptionLogger__c(
                        Apex_Class__c = 'SADateRollupHandler',
                        Method_Name__c = 'rollupDatesToProjectTask()',
                        Description__c = e.getMessage() + '\n' + e.getStackTraceString() + '\n' +
                                e.getCause() + '\n' + e.getLineNumber()
                );

                insert exceptionLogger;
            }
        }
    }

    /*******************************************************************************************************
    * @description Used to set the map variable saIdToWorkOrderMap. Called within the
    * rollupDatesToProjectTask() method.
    * @param serviceAppointments List of ServiceAppointments.
    * @return void
    * @example
    * setSAIdToWorkOrderMap(newSAs.values());
    */
    private static void setSAIdToWorkOrderMap(List<ServiceAppointment> serviceAppointments)
    {
        Set<Id> workOrderIds = new Set<Id>();

        for (ServiceAppointment sa : serviceAppointments)
        {
            SYstem.debug('sa.Work_Order__c'+sa.Work_Order__c);
            if(sa.Work_Order__c!=Null )//&& sa.Work_Order__c!='')
            	workOrderIds.add(sa.Work_Order__c);
        }

        List<WorkOrder> workOrders =
        [
                SELECT Project_Task__r.pse__Start_Date_Time__c, Project_Task__r.pse__End_Date_Time__c,
                        Project_Task__r.pse__Actual_Start_Date_Time__c, Project_Task__r.pse__Actual_End_Date_Time__c
                FROM WorkOrder
                WHERE Id IN :workOrderIds
                AND Project_Task__c != NULL
        ];

        saIdToWorkOrderMap = new Map<Id, WorkOrder>();

        for (WorkOrder wo : workOrders)
        {
            for (ServiceAppointment sa : serviceAppointments)
            {
                if (sa.Work_Order__c == wo.Id)
                {
                    saIdToWorkOrderMap.put(sa.Id, wo);
                }
            }
        }
    }

    /*******************************************************************************************************
    * @description Checks to see if the Date field on a ServiceAppointment (passed as this method's first
    * argument) has changed.
    * @param saDateAPIName a ServiceAppointment Date/Datetime field API name.
    * @param oldSA old version of a ServiceAppointment.
    * @param newSA new version of a ServiceAppointment.
    * @return true if the date has changed, false otherwise.
    * @example
    * saDateUpdated('SchedStartTime', oldSAs.get(sa.Id), sa);
    */
    private static Boolean saDateUpdated(String saDateAPIName, ServiceAppointment oldSA, ServiceAppointment newSA)
    {
        return oldSA.get(saDateAPIName) != newSA.get(saDateAPIName);
    }
}