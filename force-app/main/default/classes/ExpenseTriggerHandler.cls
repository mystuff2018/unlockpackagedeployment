/***************************************************************************************
* Created By - Abhishek Sharma ( Appirio JDC)
* Created On - April 05, 2021
* Related Task - S-680629
* Purpose - Creating Miscellaneous Adjustment Record on After insert
****************************************************************************************/
public class ExpenseTriggerHandler extends TriggerHandler {
    
    //Trigger maps
    public Map<Id, pse__Expense__c> triggerNewMap { get; set; }
    public Map<Id, pse__Expense__c> triggerOldMap { get; set; }
    public List<pse__Expense__c> triggerNew { get; set; }
    public List<pse__Expense__c> triggerOld { get; set; }
    
    public ExpenseTriggerHandler(){
        if(TriggerHandler.isBypassed(ExpenseTriggerHandler.class.getName()))
            return;
        filterRecordsByRecordType();
    }
    
    private void filterRecordsByRecordType() {
        this.triggerNewMap = new Map<Id, pse__Expense__c>();
        this.triggerOldMap = new Map<Id, pse__Expense__c>();
        this.triggerNew = new List<pse__Expense__c>();
        this.triggerOld = new List<pse__Expense__c>();
        
        //mount triggerNewMap
        if (Trigger.NewMap != null) {
            this.triggerNewMap = (Map<Id, pse__Expense__c>)Trigger.NewMap;
        }
        //mount triggerOldMap
        if (Trigger.OldMap != null) {
            this.triggerOldMap = (Map<Id, pse__Expense__c>) Trigger.OldMap;
        }
        //mount triggerNew
        if (Trigger.New != null) {
            this.triggerNew = (List<pse__Expense__c>) Trigger.New;
        }
        //mount triggerOld
        if (Trigger.Old != null) {
            this.triggerOld = (List<pse__Expense__c>) Trigger.Old;
        }
    }
    
    public override void afterUpdate() {
        createMiscellaneousAdjustment(this.triggerNew, this.triggerOldMap);
    }
    
    /************************************************************************************
* Created By - ( Appirio JDC)
* Created On - April 1, 2021
* Related Task/Story T-919610/T-919652
* Purpose -  create Miscellaneous Adjustment if Epense has Assignment and Assignment has 
* 		  - PO Resquest populated
***********************************************************************************/
    public void createMiscellaneousAdjustment(list<pse__Expense__c> newList, Map<Id,pse__Expense__c> expenseOldMap) {
        System.debug('called createMiscellaneousAdjustment');
        list<pse__Expense__c> lstSelectedExpense = new list<pse__Expense__c>();
        set<ID> setAssignmentIds = new set<ID>();
        for(pse__Expense__c ex : newList){
            if(ex.pse__Assignment__c != null && ex.pse__Status__c == 'Approved' && ex.pse__Status__c != expenseOldMap.get(ex.Id).pse__Status__c){
                lstSelectedExpense.add(ex);
                setAssignmentIds.add(ex.pse__Assignment__c);
            }
        }
        if(!lstSelectedExpense.isEmpty()){
            // get all selected assignment to check PO Resquest is there
            // if related assignment has PO Resquest then create a Miscellaneous Adjustment for that Expense
            map<ID,pse__Assignment__c> mapAssignment = new map<ID,pse__Assignment__c>([select PO_Request__c from pse__Assignment__c where id in :setAssignmentIds and PO_Request__c != null]);
            if(!mapAssignment.isEmpty()){
                List<pse__Miscellaneous_Adjustment__c> listMiscellaneusAdj= new List<pse__Miscellaneous_Adjustment__c>();
                for(pse__Expense__c ex : lstSelectedExpense){
                    if(mapAssignment.containsKey(ex.pse__Assignment__c)){
                        pse__Miscellaneous_Adjustment__c MiscellaneusAdj = new pse__Miscellaneous_Adjustment__c();
                        MiscellaneusAdj.Name = 'Billable Expense Offset(' + ex.name + ')';
                        if(ex.pse__Amount__c >= 0){
                            MiscellaneusAdj.pse__Amount__c = ex.pse__Amount__c * (-1); 
                        }else{
                            MiscellaneusAdj.pse__Amount__c = ex.pse__Amount__c;
                        }
                        MiscellaneusAdj.pse__Project__c = ex.pse__Project__c;
                        MiscellaneusAdj.pse__Include_In_Financials__c = true;
                        MiscellaneusAdj.pse__Status__c = 'Approved';
                        MiscellaneusAdj.pse__Approved__c = true;
                        MiscellaneusAdj.pse__Exclude_from_Billing__c = true;
                        MiscellaneusAdj.Expense__c = ex.ID;
                        MiscellaneusAdj.CurrencyIsoCode =ex.CurrencyIsoCode;
                        MiscellaneusAdj.pse__Transaction_Category__c = 'Expense Cost';
                        MiscellaneusAdj.pse__Description__c = 'Reversal of PO-Related Cost'; 
                        listMiscellaneusAdj.add(MiscellaneusAdj);
                    }
                }
                insert listMiscellaneusAdj;
            }
        }
    }
}