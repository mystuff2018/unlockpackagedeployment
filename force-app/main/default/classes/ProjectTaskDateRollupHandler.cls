/**
* @author Thomas Davis <thdavis@financialforce.com>
* @date 2020-03-04
* @description Handler class to rollup pse__Project_Task__c dates to their parent pse__Proj__c.
* TFS Stories 7978722 and 7978728.
*/
public class ProjectTaskDateRollupHandler
{
    /*******************************************************************************************************
    * @description Map with a pse__Project_Task__c as the key, and a pse__Proj__c as the value. Set by
    * the setProjectTaskToProjectStartDateMap() method that is called inside the public rollupDatesToProject()
    * method.
    */
    private static Map<pse__Project_Task__c, pse__Proj__c> projectTaskToProjectStartDateMap;
    /*******************************************************************************************************
    * @description Map with a pse__Project_Task__c as the key, and a pse__Proj__c as the value. Set by
    * the setProjectTaskToProjectEndDateMap() method that is called inside the public rollupDatesToProject()
    * method.
    */
    private static Map<pse__Project_Task__c, pse__Proj__c> projectTaskToProjectEndDateMap;
    /*******************************************************************************************************
    * @description Used to determine if the values within projectTaskToProjectStartDateMap need to be updated.
    */
    private static Boolean updateStart = false;
    /*******************************************************************************************************
    * @description Used to determine if the values within projectTaskToProjectEndDateMap need to be updated.
    */
    private static Boolean updateEnd = false;

    public static Set<Id> setOfIds = new Set<Id>();

    /*******************************************************************************************************
    * @description Used to perform the date rollups from the pse__Project_Task__c to the pse__Proj__c.
    * @param projectTasks List of pse__Project_Task__c records.
    * @return void
    * @example
    * ProjectTaskDateRollupHandler.rollupDatesToProject(Trigger.new);
    */
    public static void rollupDatesToProject(List<pse__Project_Task__c> projectTasks)
    {
        List<pse__Project_Task__c> pts = new List<pse__Project_Task__c>();

        for (pse__Project_Task__c projectTask : projectTasks)
        {
            if (!setOfIds.contains(projectTask.Id))
            {
                pts.add(projectTask);
            }
        }

        if (!pts.isEmpty())
        {
            setProjectTaskToProjectStartDateMap(pts);
            setProjectTaskToProjectEndDateMap(pts);

            for (pse__Project_Task__c projectTask : pts)
            {
                if (taskStartEarlierThanProjectStart(projectTask, projectTaskToProjectStartDateMap.get(projectTask)))
                {
                    pse__Proj__c project = projectTaskToProjectStartDateMap.get(projectTask);

                    if (project.pse__Project_Tasks__r != null && !project.pse__Project_Tasks__r.isEmpty())
                    {
                        project.pse__Start_Date__c = project.pse__Project_Tasks__r[0].pse__Start_Date_Time__c.date();
                        updateStart = true;
                    }
                }

                if (taskEndLaterThanProjectEnd(projectTask, projectTaskToProjectEndDateMap.get(projectTask)))
                {
                    pse__Proj__c project = projectTaskToProjectEndDateMap.get(projectTask);

                    if (project.pse__Project_Tasks__r != null && !project.pse__Project_Tasks__r.isEmpty())
                    {
                        project.pse__End_Date__c = project.pse__Project_Tasks__r[0].pse__End_Date_Time__c.date();
                        updateEnd = true;
                    }
                }

                setOfIds.add(projectTask.Id);
            }

            try
            {
                if (updateStart)
                {
                    update projectTaskToProjectStartDateMap.values();
                }

                if (updateEnd)
                {
                    update projectTaskToProjectEndDateMap.values();
                }
            }
            catch (Exception e)
            {
                ExceptionLogger__c exceptionLogger = new ExceptionLogger__c(
                        Apex_Class__c = 'ProjectTaskDateRollupHandler',
                        Method_Name__c = 'rollupDatesToProject()',
                        Description__c = e.getMessage() + '\n' + e.getStackTraceString() + '\n' +
                                e.getCause() + '\n' + e.getLineNumber()
                );

                insert exceptionLogger;
            }
        }
    }

    /*******************************************************************************************************
    * @description Returns true if the pse__Project_Task__c record's pse__Start_Date_Time__c field is
    * earlier than its pse__Proj__c record's pse__Start_Date__c.
    * @param projectTask
    * @param project
    * @return Boolean
    * @example
    * taskStartEarlierThanProjectStart(projectTask, projectTaskToProjectStartDateMap.get(projectTask));
    */
    private static Boolean taskStartEarlierThanProjectStart(pse__Project_Task__c projectTask, pse__Proj__c project)
    {
        if (projectTask.pse__Start_Date_Time__c != null)
        {
            return projectTask.pse__Start_Date_Time__c.date() < project.pse__Start_Date__c;
        }

        return false;
    }

    /*******************************************************************************************************
    * @description Returns true if the pse__Project_Task__c record's pse__End_Date_Time__c field is
    * later than its pse__Proj__c record's pse__End_Date__c.
    * @param projectTask
    * @param project
    * @return Boolean
    * @example
    * taskEndLaterThanProjectEnd(projectTask, projectTaskToProjectEndDateMap.get(projectTask));
    */
    private static Boolean taskEndLaterThanProjectEnd(pse__Project_Task__c projectTask, pse__Proj__c project)
    {
        if (projectTask.pse__End_Date_Time__c != null)
        {
            return projectTask.pse__End_Date_Time__c.date() > project.pse__End_Date__c;
        }

        return false;
    }

    /*******************************************************************************************************
    * @description Used to set the map variable projectTaskToProjectStartDateMap. Called within the
    * rollupDatesToProject() method.
    * @param projectTasks
    * @return void
    * @example
    * setProjectTaskToProjectStartDateMap(projectTasks);
    */
    private static void setProjectTaskToProjectStartDateMap(List<pse__Project_Task__c> projectTasks)
    {
        Set<Id> projectIds = new Set<Id>();

        for (pse__Project_Task__c projectTask : projectTasks)
        {
            projectIds.add(projectTask.pse__Project__c);
        }

        List<pse__Proj__c> projects =
        [
                SELECT pse__Start_Date__c,
                (
                        SELECT pse__Start_Date_Time__c
                        FROM pse__Project_Tasks__r
                        WHERE pse__Start_Date_Time__c != NULL
                        ORDER BY pse__Start_Date_Time__c
                        LIMIT 1
                )
                FROM pse__Proj__c
                WHERE Id IN :projectIds
        ];

        projectTaskToProjectStartDateMap = new Map<pse__Project_Task__c, pse__Proj__c>();

        for (pse__Proj__c project : projects)
        {
            for (pse__Project_Task__c projectTask : projectTasks)
            {
                if (projectTask.pse__Project__c == project.Id)
                {
                    projectTaskToProjectStartDateMap.put(projectTask, project);
                }
            }
        }
    }

    /*******************************************************************************************************
    * @description Used to set the map variable projectTaskToProjectEndDateMap. Called within the
    * rollupDatesToProject() method.
    * @param projectTasks
    * @return void
    * @example
    * setProjectTaskToProjectEndDateMap(projectTasks);
    */
    private static void setProjectTaskToProjectEndDateMap(List<pse__Project_Task__c> projectTasks)
    {
        Set<Id> projectIds = new Set<Id>();

        for (pse__Project_Task__c projectTask : projectTasks)
        {
            projectIds.add(projectTask.pse__Project__c);
        }

        List<pse__Proj__c> projects =
        [
                SELECT pse__End_Date__c,
                (
                        SELECT pse__End_Date_Time__c
                        FROM pse__Project_Tasks__r
                        WHERE pse__End_Date_Time__c != NULL
                        ORDER BY pse__End_Date_Time__c DESC
                        LIMIT 1
                )
                FROM pse__Proj__c
                WHERE Id IN :projectIds
        ];

        projectTaskToProjectEndDateMap = new Map<pse__Project_Task__c, pse__Proj__c>();

        for (pse__Proj__c project : projects)
        {
            for (pse__Project_Task__c projectTask : projectTasks)
            {
                if (projectTask.pse__Project__c == project.Id)
                {
                    projectTaskToProjectEndDateMap.put(projectTask, project);
                }
            }
        }
    }
}