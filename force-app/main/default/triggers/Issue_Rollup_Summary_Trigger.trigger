trigger Issue_Rollup_Summary_Trigger on pse__Issue__c (after insert, after update, after delete, after undelete ) {
    //Approach 2:
    List<Id> lstProjectIds = new List<Id>(); 
    if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete)
    {for(pse__Issue__c issue:Trigger.NEW){
        lstProjectIds.add(issue.pse__Project__c);
    }}
    if(Trigger.isUpdate || Trigger.isDelete)
    {for(pse__Issue__c issue:Trigger.Old)
    {
        lstProjectIds.add(issue.pse__Project__c);
    }}
    Issue_Rollup_Summary_Trigger_Handler.updateIssueCount(lstProjectIds);
    Risk_Rollup_Summary_Trigger_Handler.updateRiskCount(lstProjectIds);
    //Need to call Risk_Rollup_Summary_Trigger_Handler as well.
    /*
     //Approach 1:
     List<pse__Proj__c> lstProjectsToUpdate = new List<pse__Proj__c>();
    
    List<pse__Proj__c> lstProjects;
    List<Id> lstProjectIds = new List<Id>();//Needs to be removed.
    Map<Id,Id> mapIssueIdsToProjectIds = new Map<Id,Id>();
    Map<Id,pse__Proj__c> mapIssueToProjects = new Map<Id,pse__Proj__c>();
    Map<Id,pse__Proj__c> mapProjectIdsToProjects = new Map<Id,pse__Proj__c>();
    
    if(Trigger.isInsert)
    {
        for(pse__Issue__c issue:Trigger.NEW)
        {
            lstProjectIds.add(issue.pse__Project__c);
            mapIssueIdsToProjectIds.put(issue.Id, issue.pse__Project__c);
        }
        lstProjects = [SELECT Id, Budget_and_Staffing_Count__c,Budget_and_Staffing_Risk_Count__c,Delivery_Execution_Count__c,
                      Delivery_Execution_Risk_Count__c, Schedule_and_Quality_Count__c,Schedule_Quality_Risk_Count__c 
                      FROM pse__Proj__c WHERE Id IN:lstProjectIds];
        for(pse__Proj__c project:lstProjects)
        {
            mapProjectIdsToProjects.put(project.Id, project);
        }
        
        for(pse__Issue__c issue:Trigger.NEW)
        {
            if(issue.pse__Status__c != 'Closed - No action')
            {
                pse__Proj__c proj = mapProjectIdsToProjects.get(issue.pse__Project__c);
                if(issue.FBE_IDS_Issue_Type__c == 'Budget and Staffing')
                {
                    decimal newCount = proj.Budget_and_Staffing_Count__c ==null? 1 :proj.Budget_and_Staffing_Count__c + 1;
                    proj.Budget_and_Staffing_Count__c = newCount;
                    mapProjectIdsToProjects.put(issue.pse__Project__c,proj);
                }
                else if(issue.FBE_IDS_Issue_Type__c == 'Delivery Execution')
                {
                    decimal newCount = proj.Delivery_Execution_Count__c ==null? 1 :proj.Delivery_Execution_Count__c + 1;
                    proj.Delivery_Execution_Count__c = newCount;
                    mapProjectIdsToProjects.put(issue.pse__Project__c,proj);
                }
                else if(issue.FBE_IDS_Issue_Type__c == 'Schedule' || issue.FBE_IDS_Issue_Type__c == 'Quality')
                {
                    decimal newCount = proj.Schedule_and_Quality_Count__c ==null? 1 :proj.Schedule_and_Quality_Count__c + 1;
                    proj.Schedule_and_Quality_Count__c = newCount;
                    mapProjectIdsToProjects.put(issue.pse__Project__c,proj);
                }
            }
        }
     	update(mapProjectIdsToProjects.values());   
    }
    else if(Trigger.isUpdate || Trigger.isUndelete)
    {
        for(pse__Issue__c issue:Trigger.NEW)
        {
            lstProjectIds.add(issue.pse__Project__c);
            mapIssueIdsToProjectIds.put(issue.Id, issue.pse__Project__c);
        }
        lstProjects = [SELECT Id, Budget_and_Staffing_Count__c,Budget_and_Staffing_Risk_Count__c,Delivery_Execution_Count__c,
                      Delivery_Execution_Risk_Count__c, Schedule_and_Quality_Count__c,Schedule_Quality_Risk_Count__c 
                      FROM pse__Proj__c WHERE Id IN:lstProjectIds];
        for(pse__Proj__c project:lstProjects)
        {
            mapProjectIdsToProjects.put(project.Id, project);
        }
        
        for(pse__Issue__c issue:Trigger.NEW)
        {
            if(issue.pse__Status__c != Trigger.oldMap.get(issue.Id).pse__Status__c)
            {
                if(issue.pse__Status__c == 'Closed - No action')//Decrement
                {
                    pse__Proj__c proj = mapProjectIdsToProjects.get(issue.pse__Project__c);
                    if(issue.FBE_IDS_Issue_Type__c == 'Budget and Staffing')
                    {
                        decimal newCount = proj.Budget_and_Staffing_Count__c ==null || proj.Budget_and_Staffing_Count__c ==0? 0 :proj.Budget_and_Staffing_Count__c - 1;
                        proj.Budget_and_Staffing_Count__c = newCount;
                        mapProjectIdsToProjects.put(issue.pse__Project__c,proj);
                    }
                    else if(issue.FBE_IDS_Issue_Type__c == 'Delivery Execution')
                    {
                        decimal newCount = proj.Delivery_Execution_Count__c ==null || proj.Delivery_Execution_Count__c ==0? 0 :proj.Delivery_Execution_Count__c - 1;
                        proj.Delivery_Execution_Count__c = newCount;
                        mapProjectIdsToProjects.put(issue.pse__Project__c,proj);
                    }
                    else if(issue.FBE_IDS_Issue_Type__c == 'Schedule' || issue.FBE_IDS_Issue_Type__c == 'Quality')
                    {
                        decimal newCount = proj.Schedule_and_Quality_Count__c ==null || proj.Schedule_and_Quality_Count__c ==0? 0 :proj.Schedule_and_Quality_Count__c - 1;
                        proj.Schedule_and_Quality_Count__c = newCount;
                        mapProjectIdsToProjects.put(issue.pse__Project__c,proj);
                    }
                }
                else if(issue.pse__Status__c != 'Closed - No action')//Increment
                {
                    pse__Proj__c proj = mapProjectIdsToProjects.get(issue.pse__Project__c);
                    if(issue.FBE_IDS_Issue_Type__c == 'Budget and Staffing')
                    {
                        decimal newCount = proj.Budget_and_Staffing_Count__c ==null? 1 :proj.Budget_and_Staffing_Count__c + 1;
                        proj.Budget_and_Staffing_Count__c = newCount;
                        mapProjectIdsToProjects.put(issue.pse__Project__c,proj);
                    }
                    else if(issue.FBE_IDS_Issue_Type__c == 'Delivery Execution')
                    {
                        decimal newCount = proj.Delivery_Execution_Count__c ==null? 1 :proj.Delivery_Execution_Count__c + 1;
                        proj.Delivery_Execution_Count__c = newCount;
                        mapProjectIdsToProjects.put(issue.pse__Project__c,proj);
                    }
                    else if(issue.FBE_IDS_Issue_Type__c == 'Schedule' || issue.FBE_IDS_Issue_Type__c == 'Quality')
                    {
                        decimal newCount = proj.Schedule_and_Quality_Count__c ==null? 1 :proj.Schedule_and_Quality_Count__c + 1;
                        proj.Schedule_and_Quality_Count__c = newCount;
                        mapProjectIdsToProjects.put(issue.pse__Project__c,proj);
                    }
                }
            }
        }
     	update(mapProjectIdsToProjects.values());   
    }
    else if(Trigger.isDelete)
    {
        
    }*/
}