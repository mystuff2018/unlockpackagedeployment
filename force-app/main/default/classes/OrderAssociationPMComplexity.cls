/**
 * @File Name          : OrderAssociationTaskCreation.cls
 * @Description        : Create top tasks, child tasks and junction objects into project
 * @Author             : Leonardo Santos | 2/18/2020
**/

public class OrderAssociationPMComplexity {
    
    /**
    * @description Set PM Complexity based on order items - sku effort map entries
    * @author Leonardo Santos | 2/18/2020 
    * @param project
    * @param projectOrderItems
    * @param skuEffortMap 
    * @return void 
    **/
    public static void setPMComplexity(pse__Proj__c project, List<OrderItem> projectOrderItems, Map<String, Sku_Effort_Map__c> skuEffortMap){

        List<String> pickListValues = getTierValuesList();
        Integer maxPMComplexity = 0;

        if(projectOrderItems == null || projectOrderItems.size() == 0){
            return;
        }
        // Find the max complexity from sku entries
        for (OrderItem orderItem : projectOrderItems) {
            if(skuEffortMap != null) {
                Sku_Effort_Map__c skuEffort = skuEffortMap.get(orderItem.SKU_Number__c);

                if (skuEffort != null && skuEffort.SKU_Effort_Map_Entries__r != null && skuEffort.SKU_Effort_Map_Entries__r.size() > 0) {
                    List<SKU_Effort_Map_Entry__c> orderItemEntries = skuEffort.SKU_Effort_Map_Entries__r;

                    for (SKU_Effort_Map_Entry__c entry : orderItemEntries) {

                        if (maxPMComplexity < pickListValues.indexOf(entry.Project_Complexity_Tier__c)) {
                            maxPMComplexity = pickListValues.indexOf(entry.Project_Complexity_Tier__c);
                        }
                    }
                }
            }
        }

        project.PM_Complexity__c = pickListValues[maxPMComplexity];
    }

    /**
    * @description Return a list with all options from entry field picklist
    * @author Leonardo Santos | 2/18/2020 
    * @return List<String> 
    **/
    private static List<String> getTierValuesList(){

        /* !! Take care of ordernation of values into the field Project_Complexity_Tier__c, this
        method is using this to classificate the complexities!! */
        
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Sku_Effort_Map_Entry__c.Project_Complexity_Tier__c.getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for(Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }

        return pickListValuesList;
    }

}