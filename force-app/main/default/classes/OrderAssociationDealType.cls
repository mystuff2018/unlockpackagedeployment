/**
 * @File Name          : OrderAssociationDealType.cls
 * @Description        : Change the deal type (old project type) by Sku/Item class configuration
 * @Author             : Leonardo Santos  | 4/24/2020 
**/
public class OrderAssociationDealType {
    /**
    * @description Check if the project has at least 1 Order Item with CUSTOM SKU 
    *              AND Item_Class_Description__c as part of Item Class mapped in Practice              
    *              TO change project type to Custom 
    * @author Filipe Hoffmeister | 2/11/2019 
    * @param context 
    * @return void 
    **/
    public static void updateDealType(OrderAssociationDataContext context){
        system.debug('In class OrderAssociationDealType---'+context);
        OrderDealType orderDealType = new OrderDealType(context.projectMap, context.projectWithAllOrderItems,
                                                            context.skuEffortMap, context.customSku, context.listItemClassDescription);

        orderDealType.updateDealType();
    }
}