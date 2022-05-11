public class Issue_Rollup_Summary_Trigger_Handler {
    public static void updateIssueCount(List<Id> lstProjectIds){
        Map<pse__Issue__c,pse__Proj__c> mapIssueToProject;
	List<pse__Issue__c> lstIssues;
    List<pse__Proj__c> lstProjects;
    Map<Id,pse__Proj__c> mapProjectIdToProjects = new Map<Id,pse__Proj__c>();
    Map<Id,pse__Issue__c> mapIssueIdToIssues = new Map<Id,pse__Issue__c>();
    Map<Id,List<pse__Issue__c>> mapProjectIdToListOfIssues = new Map<Id,List<pse__Issue__c>>();
    List<pse__Proj__c> lstProjectsToUpdate = new List<pse__Proj__c>();
    
    lstIssues = [Select Id,pse__Project__c, pse__Status__c,FBE_IDS_Issue_Type__c 
                 FROM pse__Issue__c where pse__Project__c IN : lstProjectIds ];
    lstProjects = [SELECT Id, Budget_and_Staffing_Count__c,Budget_and_Staffing_Risk_Count__c,Delivery_Execution_Count__c,
                      Delivery_Execution_Risk_Count__c, Schedule_and_Quality_Count__c,Schedule_Quality_Risk_Count__c 
                      FROM pse__Proj__c WHERE Id IN:lstProjectIds];
	for(pse__Proj__c project:lstProjects)
    {
        mapProjectIdToProjects.put(project.Id, project);
    }
    for(pse__Issue__c issue:lstIssues)
    {
        mapIssueIdToIssues.put(issue.Id,issue);
        List<pse__Issue__c> lstIssuesUnderProjects;
        if(mapProjectIdToListOfIssues.containsKey(issue.pse__Project__c))
        {
            lstIssuesUnderProjects = mapProjectIdToListOfIssues.get(issue.pse__Project__c);
        }
        else
        {
            lstIssuesUnderProjects = new List<pse__Issue__c>();
        }
        lstIssuesUnderProjects.add(issue);
        mapProjectIdToListOfIssues.put(issue.pse__Project__c,lstIssuesUnderProjects);
    }
    
    for(Id projId:mapProjectIdToListOfIssues.keySet())
    {
        pse__Proj__c project = mapProjectIdToProjects.get(projId);
        List<pse__Issue__c> lstIssuesUnderProjects = mapProjectIdToListOfIssues.get(projId);
		decimal BudgetAndStaffingCount=0;
        decimal DeliveryAndExecutionCount=0;
        decimal ScheduleAndQualityCount=0;
        for(pse__Issue__c issue:lstIssuesUnderProjects)
        {
            if(issue.pse__Status__c != 'Closed - No action' && issue.pse__Status__c != 'Completed'){
                if(issue.FBE_IDS_Issue_Type__c == 'Budget and Staffing')
                    BudgetAndStaffingCount=BudgetAndStaffingCount+1;
                else if(issue.FBE_IDS_Issue_Type__c == 'Delivery Execution')
                    DeliveryAndExecutionCount=DeliveryAndExecutionCount+1;
                else if(issue.FBE_IDS_Issue_Type__c == 'Schedule' || issue.FBE_IDS_Issue_Type__c == 'Quality')
                    ScheduleAndQualityCount=ScheduleAndQualityCount+1;
                 
            }
        }
        project.Delivery_Execution_Count__c = DeliveryAndExecutionCount;
        project.Budget_and_Staffing_Count__c = BudgetAndStaffingCount;
        project.Schedule_and_Quality_Count__c = ScheduleAndQualityCount;
        lstProjectsToUpdate.add(project);
    }
    update lstProjectsToUpdate;
    
    }
}