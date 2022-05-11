public with sharing class OrderAssociationBudget {

    public static void createProjectBudget(OrderAssociationDataContext context){
		system.debug('createProjectBudget Enter');
        context.projectIdToBudgetListMap = new Map<Id, List<pse__Budget__c>>();

        for(Id projectId : context.projectWithOrdersMap.keySet()){

            List<pse__Budget__c> newBudgets = new List<pse__Budget__c>();

            for(Id orderId : context.projectWithOrdersMap.get(projectId)){
                
                Order ord = context.orderMap.get(orderId);

                // Get the product items of order
                Map<Id, OrderItem> orderItems = new Map<Id, OrderItem>();

                for(Id orderItemId : context.orderItemsToBeAssociated.keySet()) {
                    Id projectIdFromOrderItemId = context.orderItemsToBeAssociated.get(orderItemId);
					
                    OrderItem orderItem = context.orderItemMap.get(orderItemId);
                    
                    if(orderItem != null && orderItem.OrderId == orderId && projectIdFromOrderItemId == projectId) {                    
                        orderItems.put(orderItemId, orderItem);     
                    }
                }

                Amounts amounts = CalculationRulesUtils.amountCalculate(orderItems);

                pse__Budget__c budget = createBudget(
                    ord.OrderNumber, orderId, projectId, ord.CurrencyIsoCode, amounts.amount, amounts.amountUSD, false);
                    
                pse__Budget__c internalBudget = createBudget(
                    ord.OrderNumber, orderId, projectId, ord.CurrencyIsoCode, amounts.skuCost, amounts.skuCostUSD, true);

                newBudgets.add(budget);
                newBudgets.add(internalBudget);                    
            }
			system.debug('createProjectBudget Enter'+newBudgets);
            // Add new budget to context map
            context.projectIdToBudgetListMap.put(projectId, newBudgets);
        }
    }

    private static pse__Budget__c createBudget(String orderNumber, Id orderId, Id projectId, String currencyIsoCode, 
        Decimal amount, Decimal amountUSD, Boolean isInternal){
        
        pse__Budget__c budget = new pse__Budget__c();
        budget.Name = 'Budget from Order ' + orderNumber;
        budget.Order__c = orderId;
        budget.Pse__Project__c = projectId;
        budget.Pse__Amount__c = amount;
        budget.Amount_USD__c = amountUSD;
        budget.CurrencyIsoCode = currencyIsoCode;
        budget.Pse__Status__c = 'Approved';
        budget.Pse__Include_In_Financials__c = true;
        budget.Pse__Type__c = 'Customer Purchase Order';
        
        if(isInternal){
            budget.Name = 'Internal ' + budget.Name;
            budget.Pse__Type__c = 'Internal Budget';
        }

        return budget;
    }
}