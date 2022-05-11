public class OrderDisassociationDealType {
    /**
    * @description Check if the project has at least 1 Order Item with CUSTOM SKU 
    *              AND Item_Class_Description__c as part of Item Class mapped in Practice              
    *              TO change project type to Custom 
    * @author Filipe Hoffmeister | 2/11/2019 
    * @param context 
    * @return void 
    **/
    public static void updateDealType(OrderDisassociationDataContext context){
      /*  OrderDealType orderDealType = new OrderDealType(context.projectMap, context.projectWithRemainingOrderItemsMap,
                                                            context.skuEffortMapForRemainingItems, context.customSku, context.listItemClassDescription);

        orderDealType.updateDealType(); */
     } 
}