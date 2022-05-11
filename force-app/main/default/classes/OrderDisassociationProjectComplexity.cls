public with sharing class OrderDisassociationProjectComplexity {
    public static void calculateProjectComplexity(OrderDisassociationDataContext context) {

        OrderProjectComplexity complexityCalculator = new OrderProjectComplexity(context.projectMap.values(), createMapWithRemainingBudgets(context), 
                                                                                    context.projectWithRemainingOrderItemsMap, context.skuEffortMapForRemainingItems);
        
        complexityCalculator.calculateProjectComplexity();
    }


     /**
     * Create a map with remaining budgets to calculate Project Complexity
     */
    private static Map<Id, List<pse__Budget__c>> createMapWithRemainingBudgets(OrderDisassociationDataContext context) {
        System.debug('context.projectWithAllBudgetMap: ' + context.projectWithAllBudgetMap); 
        System.debug('context.mapBudgetToDelete: ' + context.mapBudgetToDelete);
        for (Id projectId : context.projectWithAllBudgetMap.keySet()) {
            for (pse__Budget__c budget : context.projectWithAllBudgetMap.get(projectId)) { 
                if (!context.mapBudgetToDelete.containsKey(budget.Id)) {
                    if(!context.projectWithRemainingBudgetMap.containsKey(projectId)){
                        context.projectWithRemainingBudgetMap.put(projectId, new List<pse__Budget__c>());
                    }
                    List<pse__Budget__c> budgets = context.projectWithRemainingBudgetMap.get(projectId);
                    budgets.add(budget);
                    context.projectWithRemainingBudgetMap.put(projectId, budgets);
                }
            }
        }

        System.debug('context.projectWithRemainingBudgetMap: ' + context.projectWithRemainingBudgetMap);
        return context.projectWithRemainingBudgetMap;
    }
}