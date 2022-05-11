/**
 * @File Name          : DAL_Budget.cls
 * @Description        : Data access layer for Budget related objects.
 * @Author             : Filipe Hoffmeister | 4/15/2020
**/
public with sharing class DAL_Budget {
    public static Map<Id, List<pse__Budget__c>> getBudgetsByProjectIds(Set<Id> projectIds){
        Map<Id, List<pse__Budget__c>> budgetsByProjectId = new Map<Id, List<pse__Budget__c>>();
        for(pse__Budget__c budget: [SELECT Id, pse__Project__c, pse__Type__c, Amount_USD__c, Order__c FROM pse__Budget__c WHERE pse__Project__c = :projectIds]){

            if(!budgetsByProjectId.containsKey(budget.pse__Project__c)){
                budgetsByProjectId.put(budget.pse__Project__c, new List<pse__Budget__c>());
            }
            List<pse__Budget__c> budgets = budgetsByProjectId.get(budget.pse__Project__c);
            budgets.add(budget);
            budgetsByProjectId.put(budget.pse__Project__c, budgets);
        }
        return budgetsByProjectId;
     }
}