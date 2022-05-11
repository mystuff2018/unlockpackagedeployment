public class IdsProjectClosureHandler {

    private static final String DEAL_TYPE_CUSTOM = 'Custom';
    private static final String DEAL_TYPE_STANDARD = 'Standard';
    private static final String STAGE_ON_HOLD = 'On Hold';
    private static final String STAGE_CLOSURE = 'Closure';
    private static final String STATUS_OPEN = 'Open';
    private static final String STATUS_PLANNED = 'Planned';
    private static final String STATUS_APPROVED = 'Approved';
    private static final String STATUS_CANCELED = 'Canceled';
    private static final String ON_HOLD_REASON_30_DAYS = '30 Day Support';
    private static final String PHASE_CLOSE = 'Close';
    private static final String CLOSURE_REASON_DELIVERED = 'Services Delivered';
    private static final String CLOSURE_REASON_NOT_DELIVERED = 'Services Not Delivered';
    private static Map<Id, List<pse__Milestone__c>> projectIdToMilestones = new Map<Id, List<pse__Milestone__c>>();

    private class OrderItemSupportInfo {
        public Boolean HasThirtyDaySupport { get; set; }
        public Boolean IsCustomProject { get; set; }
        public OrderItem OrderItem { get; set; }
    }

    public static void handleClosure(Map<Id, pse__Proj__c> oldProjsMap, Map<Id, pse__Proj__c> newProjsMap) {
        setProjectIdToMilestones(newProjsMap.keySet());
        handleClosureReason(oldProjsMap, newProjsMap);
        handleClosureStage(oldProjsMap, newProjsMap);
    }

    private static void setProjectIdToMilestones(Set<Id> projectIds) {
        if (projectIdToMilestones != null) {
            for(pse__Proj__c proj : [SELECT Id, (SELECT Id, pse__Status__c FROM pse__Milestones__r) FROM pse__Proj__c WHERE Id IN :projectIds]) {
                projectIdToMilestones.put(proj.Id, proj.pse__Milestones__r);
            }
        }
    }

    public static void handleClosureReason (Map<Id, pse__Proj__c> oldProjsMap, Map<Id, pse__Proj__c> newProjsMap){
        for (pse__Proj__c project : newProjsMap.values()) {

            pse__Proj__c oldProject = oldProjsMap.get(project.Id);
            List<pse__Milestone__c> milestoneList = projectIdToMilestones.get(project.Id);
            List<pse__Milestone__c> milestoneCanceled = new List<pse__Milestone__c>();
            Boolean isChangingClosureReason = oldproject.Closure_Reason__c != project.Closure_Reason__c;

            if(isChangingClosureReason && !milestoneList.isEmpty()){
                if(project.Closure_Reason__c == CLOSURE_REASON_NOT_DELIVERED){
                    for(pse__Milestone__c milestone : milestoneList){
                        if(milestone.pse__Status__c == STATUS_APPROVED){
                            project.AddError('Projects with Milestones Approved can not be set as "Services Not Delivered".');
                        }
                    }
                }else if(project.Closure_Reason__c == CLOSURE_REASON_DELIVERED){
                    for(pse__Milestone__c milestone : milestoneList){
                        if(milestone.pse__Status__c == STATUS_CANCELED){
                            milestoneCanceled.Add(milestone);
                        }
                    }

                    if(milestoneCanceled.size() == milestoneList.size()){
                        project.AddError('Projects with all Milestones canceled can not be set as "Services Delivered".');
                    }
                }
            }
        }
    }

    public static void handleClosureStage(Map<Id, pse__Proj__c> oldProjsMap, Map<Id, pse__Proj__c> newProjsMap) {
        Map<Id, pse__Proj__c> projects = getStageChangedToClosure(oldProjsMap, newProjsMap);

        if (projects.size() > 0) {

            Map<Id, List<OrderItemSupportInfo>> projectOrderItemsInfo = getOrdersSupportInfo(projects);
            Map<Id, pse__Milestone__c> thirtyDaySupportMilestones = new Map<Id, pse__Milestone__c>();

            for (pse__Proj__c proj : projects.values()) {

                if(proj.Deal_Type__c == DEAL_TYPE_CUSTOM){
                    if(hasMilestonePlannedOrOpen(projectIdToMilestones.get(proj.Id))) {
                        proj.addError('Please approve milestones in Planned/Open status before closing the project.');
                    }
                } else if (proj.Deal_Type__c == DEAL_TYPE_STANDARD) {
                    pse__Proj__c oldProj = oldProjsMap.get(proj.Id);
                    List<OrderItemSupportInfo> orderItemsInfo = projectOrderItemsInfo.get(proj.Id);
                    if (hasThirtyDaySupport(orderItemsInfo) && proj.On_Hold_Date__c == null ) {
                        setProjectToOnHold(proj);
                        notifyProjectOwner(proj);
                        set30DaysToProject(proj);
                    }
                }
            }
            thirtyDaySupportMilestones = createThirtyDaySupportMilestones(projectOrderItemsInfo);
            updateMilestonesAmounts(thirtyDaySupportMilestones, projectOrderItemsInfo);
        }
    }

    private static void updateMilestonesAmounts(Map<Id, pse__Milestone__c> projectToMilestoneThirtyDay, Map<Id, List<OrderItemSupportInfo>> projectOrderItemsInfo) {

        List<OrderItemMilestoneAssociation__c> orderItemMilestoneAssociationList = new List<OrderItemMilestoneAssociation__c>();
        List<pse__Milestone__c> milestonesToUpdate = new List<pse__Milestone__c>();
        for (Id projectId : projectToMilestoneThirtyDay.keySet()) {
            List<Id> orderItemThirtyDayIds = new List<Id>();
            pse__Milestone__c milestone = projectToMilestoneThirtyDay.get(projectId);
            List<OrderItemSupportInfo> orderItemsInfo = projectOrderItemsInfo.get(projectId);
            for(OrderItemSupportInfo orderItemInfo : orderItemsInfo) {
                if(orderItemInfo.HasThirtyDaySupport) {
                    orderItemThirtyDayIds.add(orderItemInfo.OrderItem.Id);
                }
            }
            MassEditOrdersController.OrderItemMilestoneInfo orderItemMilestoneInfo = MassEditOrdersController.updateMilestonesToProjectByOrderItems(projectId, milestone.Id, orderItemThirtyDayIds);
            orderItemMilestoneAssociationList.addAll(orderItemMilestoneInfo.orderItemMilestoneAssociationList);
            milestonesToUpdate.addAll(orderItemMilestoneInfo.milestones); //error It receive many order itens
        }

        UPDATE orderItemMilestoneAssociationList;

        //TriggerHandler.bypass(MilestoneTriggerHandler.class.getName());
        UPDATE milestonesToUpdate;
        //TriggerHandler.clearBypass(MilestoneTriggerHandler.class.getName());
    }

    private static Boolean hasMilestonePlannedOrOpen(List<pse__Milestone__c> milestones) {
        for(pse__Milestone__c milestone : milestones) {
            if(milestone.pse__Status__c == STATUS_OPEN || milestone.pse__Status__c == STATUS_PLANNED) {
                return true;
            }
        }
        return false;
    }

    @testVisible
    private static Map<Id, List<pse__Milestone__c>> getMilestonesFromProjects(Set<Id> projectIds) {
        Map<Id, List<pse__Milestone__c>> projectIdToMilestones = new Map<Id, List<pse__Milestone__c>>();

        for(pse__Proj__c proj : [SELECT Id, (SELECT Id, pse__Status__c FROM pse__Milestones__r) FROM pse__Proj__c WHERE Id IN :projectIds]) {
            projectIdToMilestones.put(proj.Id, proj.pse__Milestones__r);
        }

        return projectIdToMilestones;
    }


    private static Map<Id, pse__Proj__c> getStandardFilteredProject(Map<Id, pse__Proj__c> projects) {
        Map<Id, pse__Proj__c> standardProjects = new Map<Id, pse__Proj__c>();

        for (pse__Proj__c proj : projects.values()) {
            if (proj.Deal_Type__c == DEAL_TYPE_STANDARD) {
                standardProjects.put(proj.Id, proj);
            }
        }

        return standardProjects;
    }

    public static void handleMilestones(Map<Id, pse__Proj__c> oldProjsMap, Map<Id, pse__Proj__c> newProjsMap){

        // This filter was included because the 30 days support rule is applicable only to standard projects.
        Map<Id, pse__Proj__c> standardOldProjects = getStandardFilteredProject(oldProjsMap);
        Map<Id, pse__Proj__c> standardNewProjects = getStandardFilteredProject(newProjsMap);

        Map<Id, pse__Proj__c> projects = getStageChangedToClosure(standardOldProjects, standardNewProjects);

        if (projects.size() > 0) {
            updateMilestones(projects);
        }
        else {
            Map<Id, pse__Proj__c> projectsThirtyDaysFlag = getOnHoldReasonChangedToThirtyDaysSupport(standardNewProjects);
            if (projectsThirtyDaysFlag.size() > 0) {
                updateMilestones(projectsThirtyDaysFlag);
            }
            else {
                Map<Id, pse__Proj__c> projectsAfterOnHoldDate = getClosureChangedAfterOnHoldDate(standardNewProjects);
                if(projectsAfterOnHoldDate.size() > 0) {
                    updateMilestones(projectsAfterOnHoldDate);
                }
            }
        }
    }

    private static Boolean hasThirtyDaySupport(List<OrderItemSupportInfo> orderItemsInfo) {
        if (orderItemsInfo != null) {
            for (OrderItemSupportInfo orderItemSupportInfo : orderItemsInfo) {
                if (orderItemSupportInfo.HasThirtyDaySupport) {
                    return true;
                }
            }
        }

        return false;
    }

    private static Boolean hasCustomProject(List<OrderItemSupportInfo> orderItemsInfo) {
        if (orderItemsInfo != null) {
            for (OrderItemSupportInfo orderItemSupportInfo : orderItemsInfo) {
                if (orderItemSupportInfo.IsCustomProject) {
                    return true;
                }
            }
        }

        return false;
    }

    private static Void avoidChangeToCloseWhenOnHold(Map<Id, pse__Proj__c> onHoldProjs,Map<Id, pse__Proj__c> oldProjsMap) {
        for (pse__Proj__c Projs : onHoldProjs.values()) {
            Projs.pse__Stage__c = STAGE_ON_HOLD;
            Projs.On_Hold_Reason__c = ON_HOLD_REASON_30_DAYS;
            Projs.addError('Cannot close this project within 30 day support period.');
        }
    }

    private static Map<Id, pse__Proj__c> getStageChangedToClosure(Map<Id, pse__Proj__c> oldProjs, Map<Id, pse__Proj__c> newProjs) {
        Map<Id, pse__Proj__c> projs = new Map<Id, pse__Proj__c>();
        Map<Id, pse__Proj__c> onHoldProjs = new Map<Id, pse__Proj__c>();

        for (pse__Proj__c oldProj : oldProjs.values()) {
            for (pse__Proj__c newProj : newProjs.values()) {
                Boolean wasStageChangedToClosure = validateStageChangeToClosure(oldProj.pse__Stage__c, newProj.pse__Stage__c, newProj.pse__Project_Phase__c);

                if (oldProj.Id == newProj.Id && wasStageChangedToClosure && oldProj.On_Hold_Date__c == null && oldProj.Closure_Reason__c == CLOSURE_REASON_DELIVERED) { //oldProj.On_Hold_Date__c !=null && oldProj.On_Hold_Date__c <= date.today() ||
                    projs.put(newProj.Id, newProj);
                }
                //Below if block is added as part of DEFECT 10425142
				if (oldProj.Id == newProj.Id && wasStageChangedToClosure
                    && oldProj.Closure_Reason__c == CLOSURE_REASON_NOT_DELIVERED) {
                    projs.put(newProj.Id, newProj);
                }
                
                if (oldProj.Id == newProj.Id && wasStageChangedToClosure
                        && oldProj.pse__Stage__c == STAGE_ON_HOLD && oldProj.On_Hold_Date__c >= date.today()  && oldProj.On_Hold_Reason__c == ON_HOLD_REASON_30_DAYS) {
                    onHoldProjs.put(newProj.Id, newProj);
                }
            }
        }
        avoidChangeToCloseWhenOnHold(OnHoldProjs,oldProjs);

        return projs;
    }

    private static Map<Id, pse__Proj__c> getOnHoldReasonChangedToThirtyDaysSupport(Map<Id, pse__Proj__c> newProjs) {

        Map<Id, pse__Proj__c> projs = new Map<Id, pse__Proj__c>();

        for (pse__Proj__c newProj : newProjs.values()) {
            if (newProj.On_Hold_Reason__c == ON_HOLD_REASON_30_DAYS && newProj.pse__Stage__c == STAGE_ON_HOLD) {
                projs.put(newProj.Id, newProj);
            }
        }

        return projs;
    }

    private static Map<Id, pse__Proj__c> getClosureChangedAfterOnHoldDate(Map<Id, pse__Proj__c> newProjs) {
        Map<Id, pse__Proj__c> projs = new Map<Id, pse__Proj__c>();

        for (pse__Proj__c newProj : newProjs.values()) {
            if (newProj.On_Hold_Date__c < System.today() && newProj.pse__Stage__c == STAGE_CLOSURE) {
                projs.put(newProj.Id, newProj);
            }
        }

        return projs;
    }

    private static Boolean validateStageChangeToClosure(String oldStage, String newStage, String projPhase) {
        if (oldStage != newStage && newStage == STAGE_CLOSURE && projPhase == PHASE_CLOSE) {
            return true;
        }
        else {
            return false;
        }
    }

    private static void setProjectToOnHold(pse__Proj__c project){
        project.pse__Stage__c = STAGE_ON_HOLD;
        project.On_Hold_Reason__c = ON_HOLD_REASON_30_DAYS;
    }

    private static void set30DaysToProject(pse__Proj__c project){
        project.On_Hold_Date__c = Date.today().addDays(29);
    }

    private static void updateMilestones(Map<Id, pse__Proj__c> projects) {
        List<pse__Milestone__c> milestonesToUpdate = new List<pse__Milestone__c>();
        List<pse__Milestone__c> milestones30DaysToUpdate = new List<pse__Milestone__c>();

        List<pse__Milestone__c> milestones = [
                SELECT Id, Name, pse__Status__c, pse__Project__c
                FROM pse__Milestone__c
                WHERE pse__Project__c IN :projects.keySet()
                AND (pse__Status__c = null OR pse__Status__c IN (:STATUS_PLANNED, :STATUS_OPEN))
                AND (Name != :ON_HOLD_REASON_30_DAYS OR (Name = :ON_HOLD_REASON_30_DAYS AND pse__Target_Date__c < :system.today()))
                //AND pse__Actual_Date__c = null AND pse__Include_In_Financials__c = false
        ];

        Boolean hasChangedStatus = false;
        pse__Milestone__c tempMilestone = new pse__Milestone__c();
        for (pse__Proj__c project : projects.values()) {
            for (pse__Milestone__c milestone : milestones) {
                if (project.Id == milestone.pse__Project__c && !milestonesToUpdate.contains(milestone))
                {
                    // Story 8859333
                    if(project.pse__Stage__c == STAGE_CLOSURE && project.On_Hold_Reason__c == ON_HOLD_REASON_30_DAYS
                            && project.On_Hold_Date__c < System.today() && milestone.pse__Status__c == STATUS_OPEN)
                    {
                        milestone.pse__Status__c = STATUS_APPROVED;
                        milestone.pse__Actual_Date__c = System.today();
                        hasChangedStatus = true;
                    }
                    else if (project.Closure_Reason__c == CLOSURE_REASON_DELIVERED && project.pse__Stage__c == STAGE_CLOSURE) {
                        milestone.pse__Status__c = STATUS_APPROVED;
                        hasChangedStatus = true;
                    }
                    else if (project.Closure_Reason__c == CLOSURE_REASON_DELIVERED && project.pse__Project_Phase__c == PHASE_CLOSE && project.pse__Stage__c == STAGE_ON_HOLD) {
                        milestone.pse__Status__c = STATUS_APPROVED;
                        hasChangedStatus = true;
                    }
                    else if (project.Closure_Reason__c == CLOSURE_REASON_NOT_DELIVERED) {
                        milestone.pse__Status__c = STATUS_CANCELED;
                        hasChangedStatus = true;
                    }

                    if(hasChangedStatus)
                    {
                        milestonesToUpdate.add(milestone);
                        hasChangedStatus = false;
                    }
                }
            }
        }
        if (!milestonesToUpdate.isEmpty()) {
            //TriggerHandler.bypass(MilestoneTriggerHandler.class.getName());
               UPDATE milestonesToUpdate;
            //TriggerHandler.clearBypass(MilestoneTriggerHandler.class.getName());
        }
    }

    private static Map<Id, pse__Milestone__c> createThirtyDaySupportMilestones(Map<Id, List<OrderItemSupportInfo>> projectOrdersInfo) {
        Map<Id, pse__Milestone__c> projectMilestones = new Map<Id, pse__Milestone__c>();

        for (Id projectId : projectOrdersInfo.keySet()) {

            List<OrderItemSupportInfo> orderItemsInfo = projectOrdersInfo.get(projectId);

            if (hasThirtyDaySupport(orderItemsInfo) && !hasCustomProject(orderItemsInfo)) {
                pse__Milestone__c milestone = new pse__Milestone__c(
                        Name = ON_HOLD_REASON_30_DAYS,
                        pse__Status__c = STATUS_OPEN,
                        pse__Target_Date__c = Date.today().addDays(29),
                        pse__Project__c = projectId
                );

                projectMilestones.put(projectId, milestone);
            }
        }

        if (projectMilestones.size() > 0) {
            //TriggerHandler.bypass(MilestoneTriggerHandler.class.getName());
            INSERT projectMilestones.values();
            //TriggerHandler.clearBypass(MilestoneTriggerHandler.class.getName());
        }

        return projectMilestones;
    }

    private static void notifyProjectOwner(pse__Proj__c projectOnHold) {
        //TODO: issue when owner is a Group
        String textWithMentions = projectOnHold.OwnerId + ', the project has been put on hold for 30 days.';

        if (!Test.isRunningTest()){
            ConnectApiHelper.postFeedItemWithMentions('internal', projectOnHold.Id, textWithMentions);
        }
    }

    private static Map<Id, List<OrderItemSupportInfo>> getOrdersSupportInfo(Map<Id, pse__Proj__c> projects) {
        Map<Id, OrderItemSupportInfo> orderItemsInfo = new Map<Id, OrderItemSupportInfo>();
        Map<Id, List<OrderItemSupportInfo>> projectOrderItemsInfo = new Map<Id, List<OrderItemSupportInfo>>();

        List<OrderItem> orderItems = [
                SELECT Id, SKU_Number__c, Order.Id, Order.Milestone__c
                FROM OrderItem
                WHERE Project__c IN :projects.keySet()
                AND Order.Status != 'CL'
        ];

        Set<String> skus = new Set<String>();

        for (OrderItem item : orderItems) {
            skus.add(item.SKU_Number__c);
        }

        /* NEW */

        List<SKU_Number__C> skuNumbers = [
                SELECT  Id,
                        SKU_Number__c,
                        SKU_to_Effort_Mapping__r.Name,
                        SKU_to_Effort_Mapping__r.X30_Day_Support__c
                FROM SKU_Number__C
                WHERE SKU_Number__c IN :skus
                AND SKU_to_Effort_Mapping__r.Active__c = true
        ];

        for (Id projectId : projects.keySet()) {
            pse__proj__c project = projects.get(projectId);
            if(project.Closure_Reason__c != CLOSURE_REASON_NOT_DELIVERED)
            for (OrderItem item : orderItems) {
                for (SKU_Number__c skuNumber : skuNumbers) {
                    if (item.SKU_Number__c == skuNumber.SKU_Number__c) {
                        OrderItemSupportInfo orderItemInfo = orderItemsInfo.get(item.Id);

                        if (orderItemInfo == null) {
                            orderItemInfo = new OrderItemSupportInfo();

                            orderItemInfo.HasThirtyDaySupport = skuNumber.SKU_to_Effort_Mapping__r.X30_Day_Support__c;
                            orderItemInfo.OrderItem = item;
                            orderItemInfo.IsCustomProject = project.Deal_Type__c == DEAL_TYPE_CUSTOM;

                            orderItemsInfo.put(orderItemInfo.OrderItem.Id, orderItemInfo);
                        }
                        else {
                            orderItemInfo.HasThirtyDaySupport |= skuNumber.SKU_to_Effort_Mapping__r.X30_Day_Support__c;
                        }

                        break;
                    }
                }
            }

            projectOrderItemsInfo.put(projectId, orderItemsInfo.values());
            orderItemsInfo.clear();
        }

        return projectOrderItemsInfo;
    }
}