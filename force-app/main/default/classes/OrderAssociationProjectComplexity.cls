public with sharing class OrderAssociationProjectComplexity{

    public static void calculateProjectComplexity(OrderAssociationDataContext context) {
        OrderProjectComplexity complexityCalculator = new OrderProjectComplexity(context.projectMap.values(), createMapWithAllBudgets(context), 
                                                                                 context.projectWithAllOrderItems, context.skuEffortMap);
        
        complexityCalculator.calculateProjectComplexity();
        
    }

    /**
     * Create a map with all budgets being created plus all budgets pre existence
     */
    private static Map<Id, List<pse__Budget__c>> createMapWithAllBudgets(OrderAssociationDataContext context) {
        Map<Id, List<pse__Budget__c>> projectIdToAllBudgetListMap = new Map<Id, List<pse__Budget__c>>();
        //Add all budgets being created
        for (Id projectId : context.projectIdToBudgetListMap.keySet()) {
            projectIdToAllBudgetListMap.put(projectId, context.projectIdToBudgetListMap.get(projectId));
        }

        for (Id projectId : context.projectIdToExistentBudgetListMap.keySet()) {
            // For each projects with budgets in database add in a full list
            List<pse__Budget__c> budgets = projectIdToAllBudgetListMap.get(projectId);
            budgets.addAll(context.projectIdToExistentBudgetListMap.get(projectId));
            projectIdToAllBudgetListMap.put(projectId, budgets);
        }

        return projectIdToAllBudgetListMap;
    }
}