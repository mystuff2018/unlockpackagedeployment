/***************************************************************************************
* Created By - Umang Gupta ( Appirio JDC)
* Created On - November 24, 2020
* Related Task - 
* Purpose - Handler Class for  ExpenseReportTrigger 
****************************************************************************************/
public class ExpenseReportTriggerHandler extends TriggerHandler {
    public Map<Id, pse__Expense_Report__c> triggerNewMap { get; set; }
    public Map<Id, pse__Expense_Report__c> triggerOldMap { get; set; }
    public List<pse__Expense_Report__c> triggerNew { get; set; }
    public List<pse__Expense_Report__c> triggerOld { get; set; }
    
    public ExpenseReportTriggerHandler(){
        system.debug('Before Bypass');
        if(TriggerHandler.isBypassed(ExpenseReportTriggerHandler.class.getName()))
            return;
        filterRecordsByRecordType();
    }
    private void filterRecordsByRecordType() {
        system.debug('Called Trigger::::::');
        this.triggerNewMap = new Map<Id, pse__Expense_Report__c>();
        this.triggerOldMap = new Map<Id, pse__Expense_Report__c>();
        this.triggerNew = new List<pse__Expense_Report__c>();
        this.triggerOld = new List<pse__Expense_Report__c>();
        
        //mount triggerNewMap
        if (Trigger.NewMap != null) {
            this.triggerNewMap = (Map<Id, pse__Expense_Report__c>)Trigger.NewMap;
        }
        //mount triggerOldMap
        if (Trigger.OldMap != null) {
            this.triggerOldMap = (Map<Id, pse__Expense_Report__c>)Trigger.OldMap;
        }
        //mount triggerNew
        if (Trigger.New != null) {
            this.triggerNew = (List<pse__Expense_Report__c>) Trigger.New;
        }
        //mount triggerOld
        if (Trigger.Old != null) {
            this.triggerOld = (List<pse__Expense_Report__c>) Trigger.Old;
        }
        
    }
    
    public override void afterUpdate() {
        rollUpAmountOnProject(this.triggerNew,this.triggerOldMap);
    }
    
    
    public static void rollUpAmountOnProject(list<pse__Expense_Report__c> newList,Map<Id, pse__Expense_Report__c> oldMap){
        set<id> projId = new set<id>();
        list<pse__Expense_Report__c> filterExpenseReportLst = new list<pse__Expense_Report__c>();
        for(pse__Expense_Report__c ex : newList){
            if( ex.pse__Project__c != Null && ex.pse__Approved__c  && oldMap != Null &&
                 oldMap.get(ex.Id).pse__Approved__c != ex.pse__Approved__c)
                 {
                    projId.add(ex.pse__Project__c);
                    filterExpenseReportLst.add(ex);
                }	
        }
        system.debug('projId:::::'+projId);
        if(!projId.isEmpty()){
            map<ID,list<pse__Budget__c>> mapProjectWithBudget = new map<ID,list<pse__Budget__c>>();
            Integer currentMonth = Date.today().month(); 
            Integer currentYear = Date.today().year();
            for(pse__Budget__c budget : [Select id,Actual_Expenses__c,ByPassValidation__c,pse__Project__c,pse__Effective_Date__c,pse__Amount__c from pse__Budget__c
                                         Where pse__Project__c In : projId ]){
                                             if(!mapProjectWithBudget.containsKey(budget.pse__Project__c)){
                                                 mapProjectWithBudget.put(budget.pse__Project__c,new list<pse__Budget__c>());
                                             }
                                             mapProjectWithBudget.get(budget.pse__Project__c).add(budget);
                                         }
        	// check the current month day budget
        	system.debug('mapProjectWithBudget:::::'+mapProjectWithBudget);
        	list<pse__Budget__c> lstUpdatedBudget = new list<pse__Budget__c>();
        	for(pse__Expense_Report__c exp : filterExpenseReportLst){
                if(mapProjectWithBudget.containsKey(exp.pse__Project__c)){
                    //
                    pse__Budget__c budget ;
                    for(pse__Budget__c b : mapProjectWithBudget.get(exp.pse__Project__c)){
                        if(b.pse__Effective_Date__c != null && exp.pse__First_Expense_Date__c != null && 
                           b.pse__Effective_Date__c.Month() == exp.pse__First_Expense_Date__c.Month()
                          ){
                            budget = b;
                        }
                    }
                    if(budget != null && exp.pse__Total_Billable_Amount__c != null && budget.pse__Amount__c != null){
                        budget.Actual_Expenses__c = budget.Actual_Expenses__c == null ? exp.pse__Total_Billable_Amount__c : budget.Actual_Expenses__c + exp.pse__Total_Billable_Amount__c ;
                        // genrate a muniq number to populate in ByPassValidation__c
                        // in validation we are using this field. if this field is changed then never fired the validation
                        // this field will not be UI
                        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
						Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
						String hexDigest = EncodingUtil.convertToHex(hash);
                        budget.ByPassValidation__c = hexDigest;
                        lstUpdatedBudget.add(budget);
                    }
                }
            }
            if(lstUpdatedBudget.size() > 0){
                update lstUpdatedBudget;
            }
        }
        
    }
}