/**
 * Created by Christopher Michel and Magaiver Oliveira on 4/14/2020
 */

public class CalculationRulesUtils {
    
    public static Amounts amountCalculate(Map<Id, OrderItem> orderItems){
        
        Decimal totalAmount = 0;
        Decimal totalAmountUSD = 0;
        Decimal skuCost = 0;
        Decimal skuCostUSD = 0;

        for(Id orderItemId : orderItems.keySet()){
            
            
			OrderItem item = orderItems.get(orderItemId);
            //if(item.order.Order_Processing_Code__c != 'C'){
                
            
                if(item.Quantity == 0){
                    continue;
                }
                system.debug('item '+item);
                system.debug('item '+item.Unit_Selling_Price_Local__c);
                if (item.Unit_Selling_Price_Local__c != null && item.Unit_Selling_Price_Local__c != 0) {
                    totalAmount += item.Unit_Selling_Price_Local__c * item.Quantity;
                }
                system.debug('item '+item.Unit_Selling_Price_USD__c);
               if (item.Unit_Selling_Price_USD__c != 0 && item.Unit_Selling_Price_USD__c!=NULL) {                
                    totalAmountUSD += item.Unit_Selling_Price_USD__c * item.Quantity;                
                }
                if (item.SKU_Cost_Local__c!=NULL && item.SKU_Cost_Local__c != 0) {
                    skuCost += item.SKU_Cost_Local__c * item.Quantity;
                }
                if (item.SKU_Cost_USD__c != 0 && item.SKU_Cost_USD__c!=NULL) {
                  skuCostUSD += item.SKU_Cost_USD__c * item.Quantity;
                }
            //}
            }
    
            Amounts amounts = new Amounts();
            amounts.amount = totalAmount;
            amounts.amountUSD = totalAmountUSD;
            amounts.skuCost = skuCost;
            amounts.skuCostUSD = skuCostUSD;

        return amounts;
    }
}