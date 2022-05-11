public class Risk_Rollup_Summary_Trigger_Handler {
	public static void updateRiskCount(List<Id> lstProjectIds)
    {
        Map<pse__Risk__c,pse__Proj__c> mapRiskToProject;
	List<pse__Risk__c> lstRisks;
    List<pse__Proj__c> lstProjects;
    Map<Id,pse__Proj__c> mapProjectIdToProjects = new Map<Id,pse__Proj__c>();
    Map<Id,pse__Risk__c> mapRiskIdToRisks = new Map<Id,pse__Risk__c>();
    Map<Id,List<pse__Risk__c>> mapProjectIdToListOfRisks = new Map<Id,List<pse__Risk__c>>();
    List<pse__Proj__c> lstProjectsToUpdate = new List<pse__Proj__c>();
    
    lstRisks = [Select Id,pse__Project__c, pse__Status__c,pse__Issue__r.FBE_IDS_Issue_Type__c 
                 FROM pse__Risk__c where pse__Project__c IN : lstProjectIds ];
    lstProjects = [SELECT Id, Budget_and_Staffing_Count__c,Budget_and_Staffing_Risk_Count__c,Delivery_Execution_Count__c,
                      Delivery_Execution_Risk_Count__c, Schedule_and_Quality_Count__c,Schedule_Quality_Risk_Count__c 
                      FROM pse__Proj__c WHERE Id IN:lstProjectIds];
        
	for(pse__Proj__c project:lstProjects)
    {
        mapProjectIdToProjects.put(project.Id, project);
    }
        
    for(pse__Risk__c Risk:lstRisks)
    {
        mapRiskIdToRisks.put(Risk.Id,Risk);
        List<pse__Risk__c> lstRisksUnderProject;
        if(mapProjectIdToListOfRisks.containsKey(Risk.pse__Project__c))
        {
            lstRisksUnderProject = mapProjectIdToListOfRisks.get(Risk.pse__Project__c);
        }
        else
        {
            lstRisksUnderProject = new List<pse__Risk__c>();
        }
        lstRisksUnderProject.add(Risk);
        
        mapProjectIdToListOfRisks.put(Risk.pse__Project__c,lstRisksUnderProject);
    }
    
    for(Id projId:mapProjectIdToListOfRisks.keySet())
    {
        if(mapProjectIdToProjects.containsKey(projId)){ 
            pse__Proj__c project = mapProjectIdToProjects.get(projId);
            List<pse__Risk__c> lstRisksUnderProject = mapProjectIdToListOfRisks.get(projId);
            decimal BudgetAndStaffingRiskCount=0;
            decimal DeliveryAndExecutionRiskCount=0;
            decimal ScheduleAndQualityRiskCount=0;
            for(pse__Risk__c Risk:lstRisksUnderProject)
            {
               
                if(Risk.pse__Status__c != 'Closed'){
                    if(Risk.pse__Issue__r.FBE_IDS_Issue_Type__c == 'Budget and Staffing')
                    {
                        
                        BudgetAndStaffingRiskCount=BudgetAndStaffingRiskCount+1;
                    
                    }
                    else if(Risk.pse__Issue__r.FBE_IDS_Issue_Type__c == 'Delivery Execution')
                    {
                                            
                        
                        DeliveryAndExecutionRiskCount=DeliveryAndExecutionRiskCount+1;
                        
                    }
                    else if(Risk.pse__Issue__r.FBE_IDS_Issue_Type__c == 'Schedule' || Risk.pse__Issue__r.FBE_IDS_Issue_Type__c == 'Quality')
                        {
                                                
                            ScheduleAndQualityRiskCount=ScheduleAndQualityRiskCount+1;
                        
                        }
                     
                }
            }
            
                
            project.Delivery_Execution_Risk_Count__c = DeliveryAndExecutionRiskCount;
            project.Budget_and_Staffing_Risk_Count__c = BudgetAndStaffingRiskCount;
            project.Schedule_Quality_Risk_Count__c = ScheduleAndQualityRiskCount;
            lstProjectsToUpdate.add(project);
        }      
    }
    if(!lstProjectsToUpdate.isEmpty()){
    	update lstProjectsToUpdate;
    }     
    }
}