/**
* @author Thomas Davis <thdavis@financialforce.com>
* @date 2020-03-17
* @description Handler class to prevent Project Start Date and End Date to be shorter than Task Dates.
* TFS Story 8014293.
*/
public class ProjectDateHandler
{
    /*******************************************************************************************************
    * @description Map with a pse__Proj__c Id as its key, and the earliest pse__Start_Date_Time__c of the
    * pse__Proj__c record's children pse__Project_Task__c records. This variable is set within the private
    * setMaps() method which is called from the public preventDateUpdates() method.
    */
    private static Map<Id, Datetime> projectIdToEarliestTaskStartDateMap;
    /*******************************************************************************************************
    * @description Map with a pse__Proj__c Id as its key, and the latest pse__End_Date_Time__c of the
    * pse__Proj__c record's children pse__Project_Task__c records. This variable is set within the private
    * setMaps() method which is called from the public preventDateUpdates() method.
    */
    private static Map<Id, Datetime> projectIdToLatestTaskEndDateMap;

    public static Set<Id> setOfIds = new Set<Id>();

    /*******************************************************************************************************
    * @description Prevents updates to the pse__Proj__c fields pse__Start_Date__c and pse__End_Date__c.
    * If pse__Start_Date__c is set to a value that is less than the earliest pse__Start_Date_Time__c of the
    * pse__Proj__c record's children pse__Project_Task__c records, an error is added. If pse__End_Date__c is
    * set to a value that is greater than the latest pse__End_Date_Time__c of the pse__Proj__c record's children
    * pse__Project_Task__c records, an error is added.
    * @param oldProjects Map of old pse__Proj__c records, with pse__Proj__c as the key and a pse__Proj__c SObject
    * as the value.
    * @param newProjects Map of new pse__Proj__c records, with pse__Proj__c as the key and a pse__Proj__c SObject
    * as the value.
    * @return void
    * @example
    * ProjectDateHandler.preventDateUpdates(Trigger.oldMap, Trigger.newMap);
    */
    public static void preventDateUpdates(Map<Id, pse__Proj__c> oldProjects, Map<Id, pse__Proj__c> newProjects)
    {
        Map<Id, pse__Proj__c> projectMap = new Map<Id, pse__Proj__c>();

        for (pse__Proj__c proj : newProjects.values())
        {
            if (!setOfIds.contains(proj.Id))
            {
                projectMap.put(proj.Id, proj);
            }
        }

        if (!projectMap.isEmpty())
        {
            setMaps(projectMap.keySet());

            for (pse__Proj__c project : projectMap.values())
            {
                if (project.pse__Project_Tasks__r != null)
                {
                    if (oldProjects.get(project.Id).pse__Start_Date__c != project.pse__Start_Date__c &&
                            projectIdToEarliestTaskStartDateMap.containsKey(project.Id))
                    {
                        if (project.pse__Start_Date__c > projectIdToEarliestTaskStartDateMap.get(project.Id).date())
                        {
                            project.addError('Project Start Date cannot be later than earliest Task Start Date.');
                        }
                    }

                    if (oldProjects.get(project.Id).pse__End_Date__c != project.pse__End_Date__c &&
                            projectIdToLatestTaskEndDateMap.containsKey(project.Id))
                    {
                        if (project.pse__End_Date__c < projectIdToLatestTaskEndDateMap.get(project.Id).date())
                        {
                            project.addError('Project End Date cannot be earlier than latest Task End Date.');
                        }
                    }
                }

                setOfIds.add(project.Id);
            }
        }
    }

    /*******************************************************************************************************
    * @description Sets the two Map variables within this class. Called within its public method,
    * preventDateUpdates().
    * @param projectIds a Set of pse__Proj__c record Ids.
    * @return void
    * @example
    * setMaps(Trigger.newMap.keySet());
    */
    private static void setMaps(Set<Id> projectIds)
    {
        List<pse__Proj__c> projectsWithEarliestTaskStartDateTime =
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

        projectIdToEarliestTaskStartDateMap = new Map<Id, Datetime>();

        for (pse__Proj__c project : projectsWithEarliestTaskStartDateTime)
        {
            if (!project.pse__Project_Tasks__r.isEmpty())
            {
                projectIdToEarliestTaskStartDateMap.put(project.Id, project.pse__Project_Tasks__r[0].pse__Start_Date_Time__c);
            }
        }

        List<pse__Proj__c> projectsWithLatestTaskEndDateTime =
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

        projectIdToLatestTaskEndDateMap = new Map<Id, Datetime>();

        for (pse__Proj__c project : projectsWithLatestTaskEndDateTime)
        {
            if (!project.pse__Project_Tasks__r.isEmpty())
            {
                projectIdToLatestTaskEndDateMap.put(project.Id, project.pse__Project_Tasks__r[0].pse__End_Date_Time__c);
            }
        }
    }
}