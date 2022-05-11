public  class OrderDisassociationBudget {

    public static void deleteProjectBudget(OrderDisassociationDataContext context) {
        for(Id projectId : context.projectWithAllBudgetMap.keySet()){
            for(pse__Budget__c budget : context.projectWithAllBudgetMap.get(projectId)){
                if(context.ordersByIds.containskey(budget.Order__c)){
                    context.mapBudgetToDelete.put(budget.Id, budget);
                }
            }
        }
    }
}