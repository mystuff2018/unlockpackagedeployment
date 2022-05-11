public class MilestoneHandler extends TriggerHandler {

    private List<ExceptionLogger__c> exceptions = new List<ExceptionLogger__c>();
    private Set<pse__Milestone__c> milestonesApprovedAndCanceled = new Set<pse__Milestone__c>();
    private static final String STATUS_CANCELED = 'Canceled'; 
    private static final String STATUS_APPROVED = 'Approved';
    
    public override void afterInsert() {
        verifyMilestonesCurrentLogicInTheProject((Map<Id, pse__Milestone__c>) Trigger.NewMap, (Map<Id, pse__Milestone__c>) Trigger.OldMap, true);
        verifyMilestonesStatusChange((Map<Id, pse__Milestone__c>) Trigger.NewMap, (Map<Id, pse__Milestone__c>) Trigger.OldMap, true);
    }

    public override void afterUpdate() {
        verifyMilestonesCurrentLogicInTheProject((Map<Id, pse__Milestone__c>) Trigger.NewMap, (Map<Id, pse__Milestone__c>) Trigger.OldMap, false);
        verifyMilestonesStatusChange((Map<Id, pse__Milestone__c>) Trigger.NewMap, (Map<Id, pse__Milestone__c>) Trigger.OldMap, false);
    }

    public override void beforeUpdate() {
        findMilestonesApprovedOrCanceled();
        updateFieldsWhenApproved();
        updatesWhenStatusChange();
        insert exceptions;
    }
    
    private void updateFieldsWhenApproved() {
        for(pse__Milestone__c milestone : (List<pse__Milestone__c>) Trigger.New) {
            Boolean statusIsChanged = milestone.pse__Status__c !=  ((Map<Id, pse__Milestone__c>) Trigger.OldMap).get(milestone.Id).pse__Status__c; 
            if(statusIsChanged && milestone.pse__Status__c == STATUS_APPROVED) {         
                milestone.pse__Actual_Date__c = Date.today();
                milestone.pse__Closed_for_Time_Entry__c = true;
                milestone.pse__Closed_for_Expense_Entry__c = true;
                milestone.pse__Approved__c = true;
                milestone.pse__Include_In_Financials__c = true;
            }	
        }
    }

    private void findMilestonesApprovedOrCanceled (){
        
        for(pse__Milestone__c milestone : (List<pse__Milestone__c>) Trigger.New) {
            Boolean statusIsChanged = milestone.pse__Status__c !=  ((Map<Id, pse__Milestone__c>) Trigger.OldMap).get(milestone.Id).pse__Status__c;
            if(statusIsChanged && (milestone.pse__Status__c == STATUS_APPROVED || milestone.pse__Status__c == STATUS_CANCELED)) {         
                milestonesApprovedAndCanceled.add(milestone);
            }
        }
    }

    //Update OrderItem and Project fields when Milestone Status change
    private void updatesWhenStatusChange() {
        
        Map<Id, OrderItem> orderItemToUpdate = new Map<Id, OrderItem>();
        Set<pse__Proj__c> projectToUpdate = new Set<pse__Proj__c>();

        List<OrderItemMilestoneAssociation__c> allMilestonesFromProject = getAllMilestonesFromProject();

        Map<Id, List<Id>> milestonesNotCanceledByOrderItem = new Map<Id, List<Id>>();
        Map<Id, List<Id>> milestonesNotCanceledByProject = new Map<Id, List<Id>>();
        
        Map<Id, List<OrderItem>> orderItemsByMilestoneId = new Map<Id, List<OrderItem>>();
        for(OrderItemMilestoneAssociation__c junction : allMilestonesFromProject){

            // Split into new method
            List<OrderItem> orderItemList = orderItemsByMilestoneId.get(junction.Milestone__c);
            
            if (orderItemList == null) {
                orderItemList = new List<OrderItem>();
            }
            orderItemList.add(junction.Order_Product__r);
            orderItemsByMilestoneId.put(junction.Milestone__c, orderItemList);

            if(junction.Milestone__r.pse__Status__c != STATUS_CANCELED){
                
                // Looking to the milestones tied to order items
                List<Id> milestoneListFromOrderItem = milestonesNotCanceledByOrderItem.get(junction.Order_Product__c);
                        
                if (milestoneListFromOrderItem == null) {
                    milestoneListFromOrderItem = new List<Id>();
                }
                milestoneListFromOrderItem.add(junction.Milestone__c);
                milestonesNotCanceledByOrderItem.put(junction.Order_Product__c, milestoneListFromOrderItem);

                // Looking to all milestones that are tied to project
                List<Id> milestoneListFromProject = milestonesNotCanceledByProject.get(junction.Milestone__r.pse__Project__c);
                if (milestoneListFromProject == null) {
                    milestoneListFromProject = new List<Id>();
                }
                milestoneListFromProject.add(junction.Milestone__c);
                milestonesNotCanceledByProject.put(junction.Milestone__r.pse__Project__c, milestoneListFromProject);
               
            }
        }

        for(pse__Milestone__c milestone : milestonesApprovedAndCanceled){
            
            List<OrderItem> orderItemList = orderItemsByMilestoneId.get(milestone.Id);
            Id projectId = milestone.pse__Project__c;

            if(orderItemList != null){

                if (milestone.pse__Status__c == STATUS_APPROVED) {
                    for(OrderItem orderItem: orderItemList){
                        updateOrderItemFields(orderItem, true);
                        orderItemToUpdate.put(orderItem.Id, orderItem);
                    }
                    pse__Proj__c project = updateProjectField(projectId, true);
                    projectToUpdate.add(project);
                }
                else if (milestone.pse__Status__c == STATUS_CANCELED){

                    for(OrderItem orderItem: orderItemList){
                        // Validate if order item has not canceled milestones yet
                        List<Id> milestoneFromOrderItem = milestonesNotCanceledByOrderItem.get(orderItem.Id);
                        milestoneFromOrderItem = removeCanceledMilestones(milestone, milestoneFromOrderItem);
                        milestonesNotCanceledByOrderItem.put(orderItem.Id, milestoneFromOrderItem);

                        if(milestoneFromOrderItem.isEmpty()){
                            updateOrderItemFields(orderItem, false);
                            orderItemToUpdate.put(orderItem.Id, orderItem);
                        }
                    }

                    // Validate if project has not canceled milestones yet
                    List<Id> milestoneFromProject = milestonesNotCanceledByProject.get(projectId);
                    milestoneFromProject = removeCanceledMilestones(milestone, milestoneFromProject);
                    
                    milestonesNotCanceledByProject.put(projectId, milestoneFromProject);

                    if(milestoneFromProject.isEmpty()){
                        pse__Proj__c project = updateProjectField(projectId, false);
                        projectToUpdate.add(project);
                    }
                }
            }
        }

        List<Database.SaveResult> updateResultOrderItem = Database.update(orderItemToUpdate.values(), false);
        exceptions.addAll(SaveResultExceptionLogger.saveResultsLog(updateResultOrderItem, null, null, 'MilestoneHandler', 'Update orderItem from Milestone status'));

        List<Database.SaveResult> updateResultProject = Database.update(new List<pse__Proj__c>(projectToUpdate), false);
        exceptions.addAll(SaveResultExceptionLogger.saveResultsLog(updateResultProject, null, null, 'MilestoneHandler', 'Update Project from Milestone status'));

    }

    private List<OrderItemMilestoneAssociation__c> getAllMilestonesFromProject(){
        Set<Id> projectIds = new Set<Id>();
        for(pse__Milestone__c milestone: milestonesApprovedAndCanceled){
            projectIds.add(milestone.pse__Project__c);
        }

        List<OrderItemMilestoneAssociation__c> allMilestonesFromProject = [
            SELECT Id, Milestone__c, Milestone__r.pse__Status__c, Milestone__r.pse__Project__r.Closure_Reason__c, Order_Product__c, Order_Product__r.Service_Is_Delivered__c, 
                Order_Product__r.Service_Is_Not_Delivered__c, Order_Product__r.Approved_Rejected_Timestamp__c
            FROM OrderItemMilestoneAssociation__c 
            WHERE Milestone__c IN (SELECT Id FROM pse__Milestone__c WHERE pse__Project__c IN :projectIds)
        ];

        return allMilestonesFromProject;
    }

    private void updateOrderItemFields(OrderItem orderItem, Boolean isDelivered){
   
        orderItem.Service_Is_Delivered__c = isDelivered;
        orderItem.Service_Is_Not_Delivered__c = !isDelivered;
        if(orderItem.Approved_Rejected_Timestamp__c == null){
            orderItem.Approved_Rejected_Timestamp__c = DateTime.Now();
        }
    }

    private static pse__Proj__c updateProjectField(Id projectId, Boolean isDelivered){
        
        pse__Proj__c project = new pse__Proj__c(Id = projectId); 

        if(isDelivered){
            project.Closure_Reason__c = 'Services Delivered';
        }else{
            project.Closure_Reason__c = 'Services Not Delivered';
        }
        return project;
    }

    private static List<Id> removeCanceledMilestones(pse__Milestone__c milestoneToSearch, List<Id> milestoneList){
		
        Set<Id> uniqueMilestoneList = new Set<Id>(milestoneList);
        
        for(Id milestoneId: uniqueMilestoneList){
            if(milestoneId == milestoneToSearch.Id){
                uniqueMilestoneList.remove(milestoneId);
            }
        }

        return new List<Id>(uniqueMilestoneList);
    }
    
    // When a Milestone is set as current, Unset previous one in the project.
    private static void verifyMilestonesCurrentLogicInTheProject(Map<Id,pse__Milestone__c> mNewMap, Map<Id,pse__Milestone__c> mOldMap, Boolean isInsert){
        List<pse__Milestone__c> milestonesUpdate = new List<pse__Milestone__c>();
        pse__Milestone__c reuseMilestone = null;
        for(pse__Milestone__c milestone : mNewMap.values()){
                      
            if(milestone.Current__c==true){
                if(isInsert || milestone.Current__c != mOldMap.get(milestone.Id).Current__c){
                    List<pse__Milestone__c> milestonesCurrentProject = [SELECT Id, Name, Current__c, pse__Status__c 
                                                                        FROM pse__Milestone__c 
                                                                        WHERE pse__Project__c =: milestone.pse__Project__c
                                                                        AND Id !=: milestone.Id ];    
                    if(milestonesCurrentProject != null && !milestonesCurrentProject.isEmpty()){ 
                        for(pse__Milestone__c milestoneProj : milestonesCurrentProject){
                            if(milestoneProj.Current__c == true){
                               // milestoneProj.Current__c = false;  
                                milestonesUpdate.add(milestoneProj);
                            }
                        }
                    }
                    
                }                 
            }    
        }
        if(!milestonesUpdate.isEmpty() || milestonesUpdate.size()>0 ){ //Added size check as a part of checkMarx
            update milestonesUpdate;
        }
    }
    
    /* When status Change to Approved or Canceled, and the milestone is current, then select other milestone with open status, if find,
    then set the new as current and uncheck this field in the previous */
    private static void verifyMilestonesStatusChange(Map<Id,pse__Milestone__c> mNewMap, Map<Id,pse__Milestone__c> mOldMap, Boolean isInsert){
        //Fix Error: Too Many SOQL queries: 101 -> Do not use SOQL inside for (Pattern)
        List<pse__Milestone__c> milestonesUpdate2 = new List<pse__Milestone__c>();
        Map<Id,pse__Milestone__c> mapMilestoneToUpdate = new Map<Id,pse__Milestone__c>();
        pse__Milestone__c reuseMilestone = null;
        for(pse__Milestone__c milest : mNewMap.values()){
            if(milest.pse__Status__c == STATUS_CANCELED || milest.pse__Status__c == STATUS_APPROVED){
                if(isInsert || milest.pse__Status__c != mOldMap.get(milest.Id).pse__Status__c) {         
                    if(milest.Current__c == true){
                        mapMilestoneToUpdate.put(milest.Id, milest);
                    }
                }	
            }
        }
        if(mapMilestoneToUpdate != null && mapMilestoneToUpdate.values().size() > 0){
            List<Id> idsProjects = new List<Id>();
            for(pse__Milestone__c milestone : mapMilestoneToUpdate.values()){
                idsProjects.add(milestone.pse__Project__c);
            }
            List<pse__Milestone__c> milestonesProject = [SELECT Id, Name, Current__c, pse__Status__c 
                                                         FROM pse__Milestone__c 
                                                         WHERE pse__Project__c in : idsProjects
                                                         AND Id not in: mapMilestoneToUpdate.keySet()];
            for(pse__Milestone__c milestoneProj : milestonesProject){
                if(milestoneProj.pse__Status__c != STATUS_CANCELED && milestoneProj.pse__Status__c != STATUS_APPROVED && milestoneProj.Current__c == false) { 
                    milestoneProj.Current__c = true;
                    reuseMilestone = milestoneProj;
                    break;
                }  
            }
            if(reuseMilestone != null) milestonesUpdate2.add(reuseMilestone);
        }
        if(!milestonesUpdate2.isEmpty() || milestonesUpdate2.size()>0 ){ //Added size check as a part of CheckMarx
            update milestonesUpdate2;
        }
    }
}