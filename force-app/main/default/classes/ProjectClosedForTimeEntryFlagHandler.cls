public with sharing class ProjectClosedForTimeEntryFlagHandler {

    public static void setProjectCloseForTimeEntryFlag(OrderAssociationDataContext context) {
        for (pse__Proj__c project : context.projectMap.values()) {
            if (project.RecordType.Name != 'Parent Project' && project.RecordType.Name != 'Allocation' && project.RecordType.Name != 'Global') {
                project.pse__Closed_For_Time_Entry__c = true;
            }
        }
    }
}