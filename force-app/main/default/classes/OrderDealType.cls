public with sharing class OrderDealType {
    private String DEAL_TYPE_CUSTOM = 'Custom';
    private String DEAL_TYPE_STANDARD = 'Standard';
    
    private Map<Id, pse__Proj__c> projectMap {get;set;}
    private Map<Id, List<OrderItem>> projectWithAllOrderItems {get;set;}
    private Map<String, Sku_Effort_Map__c> skuEffortMap {get;set;}
    private Sku_Effort_Map__c customSku  {get;set;}
    private List<String> listItemClassDescription {get;set;}
    
    public OrderDealType(Map<Id, pse__Proj__c> projectMap, Map<Id, List<OrderItem>> projectWithAllOrderItems,
                            Map<String, Sku_Effort_Map__c> skuEffortMap, Sku_Effort_Map__c customSku,
                            List<String> listItemClassDescription) {
        this.projectMap = projectMap;
        this.projectWithAllOrderItems = projectWithAllOrderItems;
        this.skuEffortMap = skuEffortMap;
        this.customSku = customSku;
        this.listItemClassDescription = listItemClassDescription;
        						system.debug('projectMap--'+projectMap);
                                system.debug('projectWithAllOrderItems--'+projectWithAllOrderItems);
                                system.debug('listItemClassDescription--'+listItemClassDescription);
                                system.debug('customSku--'+customSku);
                                system.debug('skuEffortMap--'+skuEffortMap);
                                
    }   

   

    /**
    * @description Check if the project has at least 1 Order Item with CUSTOM SKU 
    *              AND Item_Class_Description__c as part of Item Class mapped in Practice              
    *              TO change project type to Custom 
    * @author Filipe Hoffmeister | 2/11/2019 
    * @return void 
    **/
    public void updateDealType(){

        for(Id projectId: this.projectMap.keySet()) {
            List<OrderItem> orderItens = this.projectWithAllOrderItems.get(projectId);
            
            if(orderItens != null && orderItens.size() > 0)
            {
                for (OrderItem orderItem : orderItens) {
                    Id orderItemSkuEffortMap;
                    //if(this.skuEffortMap.get(orderItem.SKU_Number__c) != NULL)
                    	orderItemSkuEffortMap = this.skuEffortMap.get(orderItem.SKU_Number__c).Id;
                    if (this.customSku != NULL && orderItemSkuEffortMap == this.customSku.Id) {
                        if (this.listItemClassDescription.contains(orderItem.Item_Class_Description__c)) {
                            this.projectMap.get(projectId).Deal_Type__c = DEAL_TYPE_CUSTOM;
                            break;
                        }
                    }
                    this.projectMap.get(projectId).Deal_Type__c = DEAL_TYPE_STANDARD;
                    system.debug('this.projectMap.get(projectId).Deal_Type__c '+this.projectMap.get(projectId).Deal_Type__c);
                }
            }
        }
    }
}