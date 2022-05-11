/***************************************************************************************
* Created By - Vinod Kumar ( Appirio JDC)/LavaKumar T (DELL-FED)
* Created On - FBE-21,2021.
* Related Task - S-677105
* Purpose - Handler class for pse__Milestone__c object trigger
****************************************************************************************/
public class MilestoneTriggerHandler extends TriggerHandler{
    //Trigger maps
    public Map<Id, pse__Milestone__c> triggerNewMap { get; set; }
    public Map<Id, pse__Milestone__c> triggerOldMap { get; set; }
    public List<pse__Milestone__c> triggerNew { get; set; }
    public List<pse__Milestone__c> triggerOld { get; set; }

    //FF variables
    private List<ExceptionLogger__c> exceptions = new List<ExceptionLogger__c>();
    private Set<pse__Milestone__c> milestonesAllApprovedAndCanceled = new Set<pse__Milestone__c>();
    private Set<pse__Milestone__c> milestonesApprovedAndCanceled = new Set<pse__Milestone__c>();
    private static final String STATUS_CANCELED = 'Canceled';
    private static final String STATUS_APPROVED = 'Approved';
    private static final String THIRTY_DAY_MILESTONE_NAME = '30 Day Support';
    private static Set<Id> projectIgnoreThirtyDay = new Set<Id>();

    public MilestoneTriggerHandler(){
        if(TriggerHandler.isBypassed(MilestoneTriggerHandler.class.getName()))
            return;
        filterRecordsByRecordType();
    }

    //Since we don't really have any RT for Milestones, all records will be added to the trigger maps
    private void filterRecordsByRecordType() {
        this.triggerNewMap = new Map<Id, pse__Milestone__c>();
        this.triggerOldMap = new Map<Id, pse__Milestone__c>();
        this.triggerNew = new List<pse__Milestone__c>();
        this.triggerOld = new List<pse__Milestone__c>();

        //mount triggerNewMap
        if (Trigger.NewMap != null) {
            this.triggerNewMap = (Map<Id, pse__Milestone__c>)Trigger.NewMap;
        }
        //mount triggerOldMap
        if (Trigger.OldMap != null) {
            this.triggerOldMap = (Map<Id, pse__Milestone__c>) Trigger.OldMap;
        }
        //mount triggerNew
        if (Trigger.New != null) {
            this.triggerNew = (List<pse__Milestone__c>) Trigger.New;
        }
        //mount triggerOld
        if (Trigger.Old != null) {
            this.triggerOld = (List<pse__Milestone__c>) Trigger.Old;
        }
    }

    public override void afterInsert() {
        //FF code START
        verifyMilestonesCurrentLogicInTheProject((Map<Id, pse__Milestone__c>) Trigger.NewMap, (Map<Id, pse__Milestone__c>) Trigger.OldMap, true);
        verifyMilestonesStatusChange((Map<Id, pse__Milestone__c>) Trigger.NewMap, (Map<Id, pse__Milestone__c>) Trigger.OldMap, true);
        //NextMilestone.setNextMilestoneOnProject((Map<Id, pse__Milestone__c>) Trigger.NewMap, (Map<Id, pse__Milestone__c>) Trigger.OldMap, true,false,false);
        verifyAnyThirtyDayMilestoneCreated((Map<Id, pse__Milestone__c>) Trigger.NewMap);
        //FF code END

        //Appirio code START
        map<id,pse__Proj__c> mapUpdatedProject = new map<id,pse__Proj__c>();
        rollUpAmountOnProjectEACRevenueAndFiedPriceRevenue(mapUpdatedProject,this.triggerNew,null);
        updateProjects(mapUpdatedProject);
        //Appirio code END
    }

    public override void beforeUpdate() {
        //FF code START
        findMilestonesApprovedOrCanceled();
        updateFieldsWhenApproved();
        updatesWhenStatusChange();
        INSERT exceptions;
        //FF code END
    }

    public override void afterUpdate() {
        //FF code START
        verifyMilestonesCurrentLogicInTheProject((Map<Id, pse__Milestone__c>) Trigger.NewMap, (Map<Id, pse__Milestone__c>) Trigger.OldMap, false);
        verifyMilestonesStatusChange((Map<Id, pse__Milestone__c>) Trigger.NewMap, (Map<Id, pse__Milestone__c>) Trigger.OldMap, false);
        //NextMilestone.setNextMilestoneOnProject((Map<Id, pse__Milestone__c>) Trigger.NewMap, (Map<Id, pse__Milestone__c>) Trigger.OldMap, false,false,True);
        //FF code END

        //Appirio code START
        map<id,pse__Proj__c> mapUpdatedProject = new map<id,pse__Proj__c>();
        rollUpAmountOnProjectEACRevenueAndFiedPriceRevenue(mapUpdatedProject,this.triggerNew,this.triggerOldMap);
        updateProjects(mapUpdatedProject);
        //Appirio code END
    }

    public override void beforeDelete() {
        List<OrderItemMilestoneAssociation__c> junctions = [ //new
                SELECT Id, Milestone__c
                FROM OrderItemMilestoneAssociation__c
                WHERE Milestone__c IN:Trigger.old
        ];
        Map<Id, OrderItemMilestoneAssociation__c> junctionMap = new Map<Id, OrderItemMilestoneAssociation__c>();
        for (OrderItemMilestoneAssociation__c junction : junctions) {
            junctionMap.put(junction.Milestone__c, junction);
        }
        for (pse__Milestone__c milestone : (List<pse__Milestone__c>) Trigger.old) {
            if (junctionMap.get(milestone.Id) != null) {
                milestone.addError('Milestone cannot be deleted if Order Items are associated to it');
            }
        }
        //NextMilestone.setNextMilestoneOnProject((Map<Id, pse__Milestone__c>) Trigger.NewMap, (Map<Id, pse__Milestone__c>) Trigger.OldMap, false,true,false);
    	
	}

    public override void afterDelete() {
        map<id,pse__Proj__c> mapUpdatedProject = new map<id,pse__Proj__c>();
        rollUpAmountOnProjectEACRevenueAndFiedPriceRevenue(mapUpdatedProject,this.triggerOld,null);
        updateProjects(mapUpdatedProject);
    }

    public override void afterUnDelete() {
        map<id,pse__Proj__c> mapUpdatedProject = new map<id,pse__Proj__c>();
        rollUpAmountOnProjectEACRevenueAndFiedPriceRevenue(mapUpdatedProject,this.triggerNew,null);
        updateProjects(mapUpdatedProject);
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
                milestonesAllApprovedAndCanceled.add(milestone);
                System.debug('tt1t 1 milestonesAllApprovedAndCanceled'+milestonesAllApprovedAndCanceled);
            }
        }
    }

    //Update OrderItem and Project fields when Milestone Status change
    private void updatesWhenStatusChange() {
        List<Id> orderItemsWith30DaysSupport = new List<Id>();
        List<Id> projWithActiveDistinctMilestones = new List<Id>();
        Map<Id, OrderItem> orderItemToUpdate = new Map<Id, OrderItem>();
        Set<pse__Proj__c> projectToUpdate = new Set<pse__Proj__c>();
        Boolean sendToRevRec = false;

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


        projWithActiveDistinctMilestones = verifyIfProjectHasDistinctActiveMilestone(milestonesAllApprovedAndCanceled);

        orderItemsWith30DaysSupport = verifyIfCommonMilestoneHas30DaysOrderItems(milestonesAllApprovedAndCanceled);

        sendToRevRecDistinctMilestoneWhenTheLastOneClose(orderItemsWith30DaysSupport,projWithActiveDistinctMilestones, milestonesAllApprovedAndCanceled);


        for(pse__Milestone__c milestone : milestonesAllApprovedAndCanceled){
            System.debug('tt1t 2 milestone ' + milestone);
            List<OrderItem> orderItemList = orderItemsByMilestoneId.get(milestone.Id);
            Id projectId = milestone.pse__Project__c;

            if(projWithActiveDistinctMilestones.contains(milestone.pse__Project__c) && milestone.pse__Status__c == STATUS_APPROVED){
                System.debug('tt1t 3 Milestone project Contains open Distinct ' + projWithActiveDistinctMilestones.contains(milestone.pse__Project__c));
                continue;
            }//If exist open distinct milestones in the proj the system should not send the milestone to Rev Rec

            if(orderItemList != null){
                if (milestone.pse__Status__c == STATUS_APPROVED) {
                    System.debug('tt1t 4 status aproved'+milestone.pse__Status__c);
                    for(OrderItem orderItem: orderItemList){
                        if(orderItemsWith30DaysSupport.contains(orderItem.Id)){
                            System.debug('tt1t 5 orderItemsWith30DaysSupport' +orderItemsWith30DaysSupport.contains(orderItem.Id));
                            if(milestone.Name != THIRTY_DAY_MILESTONE_NAME){
                                System.debug('tt1t 6 Name != '+THIRTY_DAY_MILESTONE_NAME +'Name:' + milestone.Name);
                                continue;
                            }
                        }
                        sendToRevRec = true;
                        updateOrderItemFields(orderItem, sendToRevRec);
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
                        System.debug('tt1t 7B Populate order item fields When STATUS_CANCELED:'+orderItem);
                    }

                    // Validate if project has not canceled milestones yet
                    List<Id> milestoneFromProject = milestonesNotCanceledByProject.get(projectId);
                    milestoneFromProject = removeCanceledMilestones(milestone, milestoneFromProject);

                    milestonesNotCanceledByProject.put(projectId, milestoneFromProject);

                    if(milestoneFromProject.isEmpty()){
                        pse__Proj__c project = updateProjectField(projectId, false);
                        projectToUpdate.add(project);
                    }
                    System.debug('tt1t 7C Populate Proj fields When STATUS_CANCELED:'+projectToUpdate);
                }
            }
        }


        List<Database.SaveResult> updateResultOrderItem = Database.update(orderItemToUpdate.values(), false);
        exceptions.addAll(SaveResultExceptionLogger.saveResultsLog(updateResultOrderItem, null, null, 'MilestoneHandler', 'Update orderItem from Milestone status'));
        System.debug('tt1t 8 orderItemToUpdate'+orderItemToUpdate+'  -  updateResultOrderItem:  '+updateResultOrderItem);
        //TriggerHandler.bypass(FFProjectTriggerHandler.class.getName());
        List<Database.SaveResult> updateResultProject = Database.update(new List<pse__Proj__c>(projectToUpdate), false);
        exceptions.addAll(SaveResultExceptionLogger.saveResultsLog(updateResultProject, null, null, 'MilestoneHandler', 'Update Project from Milestone status'));
        //TriggerHandler.clearBypass(FFProjectTriggerHandler.class.getName());
        System.debug('tt1t 9 updateResultProject'+projectToUpdate+'  -  updateResultProject:  '+updateResultProject);
    }

    private List<OrderItemMilestoneAssociation__c> getAllMilestonesFromProject(){
        Set<Id> projectIds = new Set<Id>();
        for(pse__Milestone__c milestone: milestonesAllApprovedAndCanceled){
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
        System.debug('tt1t 7 Populate order item fields:'+orderItem);
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
                                milestoneProj.Current__c = false;
                                milestonesUpdate.add(milestoneProj);
                            }
                        }
                    }

                }
            }
        }
        if(!milestonesUpdate.isEmpty()){
            //TriggerHandler.bypass(MilestoneTriggerHandler.class.getName());
                 UPDATE milestonesUpdate;
            //TriggerHandler.clearBypass(MilestoneTriggerHandler.class.getName());
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
        if(!milestonesUpdate2.isEmpty()){
            //TriggerHandler.bypass(MilestoneTriggerHandler.class.getName());
            update milestonesUpdate2;
            //TriggerHandler.clearBypass(MilestoneTriggerHandler.class.getName());
        }
    }

    public void verifyAnyThirtyDayMilestoneCreated(Map<Id, pse__Milestone__c> milestoneMap){
        for(pse__Milestone__c milestone : milestoneMap.values()) {
            if(milestone.Name == THIRTY_DAY_MILESTONE_NAME)
                projectIgnoreThirtyDay.add(milestone.pse__Project__c);
        }
    }

    //Appirio Customization
    public void updateProjects(map<id,pse__Proj__c> mapUpdatedProject) {
        //TriggerHandler.bypass(FFProjectTriggerHandler.class.getName());
        //TriggerHandler.bypass(ESProjectTriggerHandler.class.getName());
        UPDATE mapUpdatedProject.values();
        //TriggerHandler.clearBypass(FFProjectTriggerHandler.class.getName());
        //TriggerHandler.clearBypass(ESProjectTriggerHandler.class.getName());
    }

    /************************************************************************************
    * Created By - Vinod Kumar ( Appirio JDC)
    * Created On - November 10, 2020
    * Related Task/Story - S-677105
    * Purpose -  Roll up Amount on Project.EAC_Revenue__c and Project.Fixed_Price_Planned_Revenue__c
    *       - If Project is Fixed Price and Milestone status is not cancelled
    ***********************************************************************************/
    public void rollUpAmountOnProjectEACRevenueAndFiedPriceRevenue(map<id,pse__Proj__c> mapUpdatedProject,list<pse__Milestone__c> newList,Map<Id, pse__Milestone__c> oldMap) {
        set<id> projId = new set<id>();
        set<id> milestoneIdSet = new set<id>();

        for(pse__Milestone__c ms : newList){
            if( ms.pse__Project__c != Null &&  (oldMap == Null ||
                    oldMap.get(ms.Id).pse__Milestone_Amount__c != ms.pse__Milestone_Amount__c ||
                    oldMap.get(ms.Id).pse__Status__c != ms.pse__Status__c))
            {
                if(!projectIgnoreThirtyDay.contains(ms.pse__Project__c))
                    projId.add(ms.pse__Project__c);
            }
        }

        if(!projId.isEmpty()){
            for(pse__Milestone__c milestone : [SELECT Id,pse__Milestone_Amount__c,pse__Project__r.pse__Billing_Type__c From pse__Milestone__c Where pse__Project__c In :projId and pse__Project__r.pse__Billing_Type__c = 'Fixed Price' and pse__Milestone_Amount__c != null and pse__Status__c !='Canceled']){
                if(!mapUpdatedProject.containsKey(milestone.pse__Project__c)){
                    mapUpdatedProject.put(milestone.pse__Project__c, new pse__Proj__c(ID=milestone.pse__Project__c,EAC_Revenue__c = null,Fixed_Price_Planned_Revenue__c =null ));
                }
                pse__Proj__c project = mapUpdatedProject.get(milestone.pse__Project__c);
                project.EAC_Revenue__c  = project.EAC_Revenue__c  == null ? milestone.pse__Milestone_Amount__c : (project.EAC_Revenue__c + milestone.pse__Milestone_Amount__c) ;
                project.Fixed_Price_Planned_Revenue__c  = project.Fixed_Price_Planned_Revenue__c  == null ? milestone.pse__Milestone_Amount__c : (project.Fixed_Price_Planned_Revenue__c + mileStone.pse__Milestone_Amount__c) ;
            }

        }
        // handle all delete
        for(Id pID : projId){
            if(!mapUpdatedProject.containsKey(pID)){
                // all Milestone deleted
                pse__proj__c project = new pse__Proj__c(Id = pID);
                project.EAC_Revenue__c = null;
                project.Fixed_Price_Planned_Revenue__c = null;
                mapUpdatedProject.put(project.Id,project);
            }
        }
    }

    private List<Id> verifyIfProjectHasDistinctActiveMilestone(Set<pse__Milestone__c> milestonesSet) {
        List<Id> projects = new List<Id>();
        List<String> SKUNumber = new List<String>();
        List<Id> distinctProject = new List<Id>();
        for (pse__Milestone__c milestoneUpdated : milestonesSet) {
            if (milestoneUpdated.pse__Project__c != null) {
                projects.add(milestoneUpdated.pse__Project__c);

            }
        }

        List<pse__Milestone__c> milestoneList = new List<pse__Milestone__c>([
                SELECT Id,pse__Project__c, (SELECT Id,Order_Product__c,Order_Product__r.SKU_Number__c FROM OrderItemMilestoneAssociations__r)
                FROM pse__Milestone__c
                WHERE pse__Project__c IN :projects AND (NOT Id IN :milestonesSet) AND (pse__Status__c = 'Open' OR pse__Status__c = 'Planned')
        ]);

        for (pse__Milestone__c milestone : milestoneList){
            for (OrderItemMilestoneAssociation__c OrderItemMilestoneAssociationsList1 : milestone.OrderItemMilestoneAssociations__r) {
                if (OrderItemMilestoneAssociationsList1.Order_Product__r.SKU_Number__c != null) {
                    SKUNumber.add(OrderItemMilestoneAssociationsList1.Order_Product__r.SKU_Number__c);
                }
            }//Verify if I set the sku number in the order product
        }
        List<SKU_Number__c> skuNumberList = [SELECT Id,SKU_Number__c,
                SKU_to_Effort_Mapping__r.Distinct_Project__c
        FROM SKU_Number__c WHERE SKU_Number__c IN :SKUNumber AND SKU_to_Effort_Mapping__r.Distinct_Project__c = TRUE];

        Map<String, Boolean> distinctMilestones = new Map<String, Boolean>();
        if(skuNumberList.size() >= 1){
            for (SKU_Number__c skuEffort : skuNumberList) {
                distinctMilestones.put(skuEffort.SKU_Number__c, skuEffort.SKU_to_Effort_Mapping__r.Distinct_Project__c);
            }
        }

        for (pse__Milestone__c milestone : milestoneList) {
            for (OrderItemMilestoneAssociation__c OrderItemMilestoneAssociationList2 : milestone.OrderItemMilestoneAssociations__r) {
                if (OrderItemMilestoneAssociationList2.Order_Product__r.SKU_Number__c != null) {
                    if(distinctMilestones.get(OrderItemMilestoneAssociationList2.Order_Product__r.SKU_Number__c) != null){
                        if (distinctMilestones.get(OrderItemMilestoneAssociationList2.Order_Product__r.SKU_Number__c) == true) {
                            distinctProject.add(milestone.pse__Project__c);
                        }
                    }
                }
            }
        }
        return distinctProject;
    }

    private void sendToRevRecDistinctMilestoneWhenTheLastOneClose(List<Id> orderItemsWith30DaysSupport, List<Id> projWithOpenDistinctMilestone, Set<pse__Milestone__c> milestonesApprovedAndCanceled) {
        List<Id> projList = new List<Id>();
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
        for (pse__Milestone__c milestone : milestonesApprovedAndCanceled) {
            if (!projWithOpenDistinctMilestone.contains(milestone.pse__Project__c)) {
                projList.add(milestone.pse__Project__c);
            }
        }

        List<OrderItemMilestoneAssociation__c> allMilestonesFromProject = [
                SELECT Id, Milestone__c, Milestone__r.pse__Status__c, Order_Product__r.Id, Order_Product__r.Service_Is_Delivered__c,
                        Order_Product__r.Service_Is_Not_Delivered__c, Order_Product__r.Approved_Rejected_Timestamp__c
                FROM OrderItemMilestoneAssociation__c
                WHERE Milestone__c IN (SELECT Id FROM pse__Milestone__c WHERE pse__Project__c IN :projList AND ( pse__Status__c = 'Approved' OR pse__Status__c = 'Canceled'))
        ];
        for (OrderItemMilestoneAssociation__c OrderItemMilestoneAssociation : allMilestonesFromProject) {
            Integer index = null;
            if(orderItemsWith30DaysSupport.contains(OrderItemMilestoneAssociation.Order_Product__r.Id)){
                continue;
            }
            If(OrderItemMilestoneAssociation.Milestone__r.pse__Status__c == 'Approved'){
                OrderItemMilestoneAssociation.Order_Product__r.Service_Is_Delivered__c = true;
                OrderItemMilestoneAssociation.Order_Product__r.Service_Is_Not_Delivered__c = false;

            }else if(OrderItemMilestoneAssociation.Order_Product__r.Service_Is_Delivered__c != true){
                OrderItemMilestoneAssociation.Order_Product__r.Service_Is_Delivered__c = false;
                OrderItemMilestoneAssociation.Order_Product__r.Service_Is_Not_Delivered__c = true;
            }

            if(orderItemsToUpdate.size()>= 1) {
                if (orderItemsToUpdate.contains(OrderItemMilestoneAssociation.Order_Product__r)) {
                    for (Integer i = 0; i < orderItemsToUpdate.size(); i++) {
                        if (orderItemsToUpdate[i] == OrderItemMilestoneAssociation.Order_Product__r) {
                            index = i;
                            break;
                        }
                    }
                    if (index != null) {
                        orderItemsToUpdate.remove(index);
                        orderItemsToUpdate.add(OrderItemMilestoneAssociation.Order_Product__r);
                    }
                }else {
                    orderItemsToUpdate.add(OrderItemMilestoneAssociation.Order_Product__r);
                }
            }else{
                orderItemsToUpdate.add(OrderItemMilestoneAssociation.Order_Product__r);
            }
        }

        List<Database.SaveResult> updateResultOrderItem = Database.update(orderItemsToUpdate, false);
        exceptions.addAll(SaveResultExceptionLogger.saveResultsLog(updateResultOrderItem, null, null, 'MilestoneHandler', 'Update Is Delivered status from order item when last Milestone status'));
        Database.insert(exceptions, false);
    }

    private List<Id> verifyIfCommonMilestoneHas30DaysOrderItems(Set<pse__Milestone__c> milestonesSet) {
        List<String> SKUNumber = new List<String>();
        List<Id> OrdItem30daysSupport = new List<Id>();

        List<pse__Milestone__c> milestoneList = new List<pse__Milestone__c>([
                SELECT Id,pse__Project__c, Name,(SELECT Id,Order_Product__c,Order_Product__r.SKU_Number__c FROM OrderItemMilestoneAssociations__r)
                FROM pse__Milestone__c
                WHERE Id IN :milestonesSet]);

        for (pse__Milestone__c milestone : milestoneList) {
            for (OrderItemMilestoneAssociation__c OrderItemMilestoneAssociationsList1 : milestone.OrderItemMilestoneAssociations__r) {
                if (OrderItemMilestoneAssociationsList1.Order_Product__r.SKU_Number__c != null) {
                    SKUNumber.add(OrderItemMilestoneAssociationsList1.Order_Product__r.SKU_Number__c);
                }
            }
        }

        List<SKU_Number__c> skuEffortMap = [
                SELECT Id,SKU_Number__c,SKU_to_Effort_Mapping__r.X30_Day_Support__c
                FROM SKU_Number__c WHERE SKU_Number__c IN :SKUNumber];


        Map<String, Boolean> distinctMilestones = new Map<String, Boolean>();
        for (SKU_Number__c skuEffort : skuEffortMap) {
            distinctMilestones.put(skuEffort.SKU_Number__c, skuEffort.SKU_to_Effort_Mapping__r.X30_Day_Support__c);
        }

        for (pse__Milestone__c milestone : milestoneList) {
            for (OrderItemMilestoneAssociation__c OrderItemMilestoneAssociationList2 : milestone.OrderItemMilestoneAssociations__r) {
                if (OrderItemMilestoneAssociationList2.Order_Product__r.SKU_Number__c != null) {
                    if (distinctMilestones.get(OrderItemMilestoneAssociationList2.Order_Product__r.SKU_Number__c) == true) {
                        OrdItem30daysSupport.add(OrderItemMilestoneAssociationList2.Order_Product__c);
                    }
                }
            }
        }
        return OrdItem30daysSupport;
    }
}