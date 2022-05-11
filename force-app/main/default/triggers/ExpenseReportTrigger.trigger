trigger ExpenseReportTrigger on pse__Expense_Report__c (after insert, after update, after delete, before update, before delete, before insert,after undelete) {
	 new ExpenseReportTriggerHandler().run();
}