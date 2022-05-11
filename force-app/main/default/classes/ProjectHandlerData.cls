public class ProjectHandlerData {


    public static List<pse__Proj__c> getProjectInformation(Set<Id> setProjectId) {
        
        List<pse__Proj__c> projects = [
            SELECT Id, 
            Site_ID__c,
            Primary_Contact__c
            FROM pse__Proj__c 
            WHERE Id IN :setProjectId];
             System.debug('@@12 projects :::: ' +projects);   
            return projects;                
    }  

    public static List<WO_SKU_Effort_Map__c> getWoSkuEffortMapByEntry(Set<Id> entriesId){             
        
        List<WO_SKU_Effort_Map__c> woSkuEffortMaps = [
        SELECT Id,
        Description__c,
        Calculation_Type__c,
        Duration__c,
        Name,
        SKU_Effort_Mapping_Entry__c,
        Delivery_Method__c,
        Threshold_Value__c,
        Low_Threshold_Duration__c,
        High_Threshold_Duration__c,
        Phase__c,
        SKU_Effort_Mapping_Entry__r.Phase__r.Name,
        Phase__r.Name,
        Resource_Type__c,
        Schedule_Type__c,
        Auto_Dispatch__c,
        WO_Record_Type__c,
        DPS_Type__r.Name,
        SKU_Effort_Mapping_Entry__r.SKU_Effort_Map__c,
        SR_Type__c,
        WO_Type__c,
        Event_Type__c,
        On_Demand_WO_Creation__c
        FROM WO_SKU_Effort_Map__c
        WHERE SKU_Effort_Mapping_Entry__c IN :entriesId
        //                AND (Phase__r.Name = :proj.pse__Project_Phase__c OR (Phase__c = null AND SKU_Effort_Mapping_Entry__r.Phase__r.Name = :proj.pse__Project_Phase__c))
        ];            
        System.debug('@@64 woSkuEffortMaps :::: ' +woSkuEffortMaps);
        return woSkuEffortMaps;
    }
    
    public static List<Schema.Location> getlocationsByProjectsId(Set<Id> setProjectId) {

        List<Schema.Location> locations = [SELECT Id, Default_Address__c, Project__c, Order__c , TimeZone__c
        FROM Location 
        WHERE Project__c in :setProjectId AND Default_Address__c = true];
        System.debug('@@55 locations :::: ' +locations);
        return locations;
    }

    public static List<Schema.Address> getAddressesByLocations(Set<Id> setLocations){
                       
        List<Schema.Address> addressesQuery = [SELECT Address, City, Country, Id, Name, ParentId, PostalCode, State, Street
        FROM Address
        WHERE ParentId IN:setLocations];
        System.debug('@@64 addressesQuery :::: ' +addressesQuery);
       return addressesQuery;
    }

      //Review !!!!!!
    public static List<Order> getOrdersByProject(Set<Id> setProjectId){
        List<Order> orders = [SELECT Id, Project__c
        FROM Order
        WHERE Project__c IN :setProjectId ];
          System.debug('@@73 orders :::: ' +orders);
       return orders;
    }

    public static List<Order_Item_Sku_Effort_Map__c> getOrderItemSkuEffortMapsBySkuEffortMappingsAndProject(List<WO_SKU_Effort_Map__c> woSkuEffortMapList, Set<Id> setProjectId){
        Set<Id> skuEffortMapIds = new Set<Id>();
        for (WO_SKU_Effort_Map__c woSkuEffortMap : woSkuEffortMapList) {
            skuEffortMapIds.add(woSkuEffortMap.SKU_Effort_Mapping_Entry__r.SKU_Effort_Map__c);
             System.debug('@@81 woSkuEffortMap :::: ' +woSkuEffortMap);
        }
        
        List<Order_Item_Sku_Effort_Map__c> orderItemSkuEffortMaps = [
        SELECT Id,Order_Product__c,Order_Product__r.OrderId, SKU_to_Effort_Mapping__c, Project_Task__c,Order_Product__r.Project__c
        FROM Order_Item_Sku_Effort_Map__c
        WHERE SKU_to_Effort_Mapping__c IN :skuEffortMapIds AND Order_Product__r.Project__c IN :setProjectId
        ];
         System.debug('@@89 orderItemSkuEffortMaps :::: ' +orderItemSkuEffortMaps);
       return  orderItemSkuEffortMaps;       
    }

    public static List<Project_Task_WO_Sku_Map__c> getProjectTasksWOSkuMapsByProjectAndWoSkuEffMappingEntry(Set<Id> workOrderIds, Set<Id> setProjectId){
       
        List<Project_Task_WO_Sku_Map__c> projectTaskWOSkuMaps = [
        SELECT Id, WO_SKU_Effort_Mapping_Entry__c, Project_Task__c, Processed__c
        FROM Project_Task_WO_Sku_Map__c
        WHERE Project_Task__r.pse__Project__c IN :setProjectId
        AND WO_SKU_Effort_Mapping_Entry__c IN :workOrderIds
        ];
        System.debug('@@101 projectTaskWOSkuMaps :::: ' +projectTaskWOSkuMaps);        
        return projectTaskWOSkuMaps;        
    }


    public static List<Project_Task_SKU_Effort_Mapping_Entry__c> getProjectTaskSkuEffortMappingEntriesByProjectsId(Set<Id> setProjectId) {
        
        List<Project_Task_SKU_Effort_Mapping_Entry__c> projectTaskSkuEffortMappingEntries = [
        SELECT Id, SKU_Effort_Mapping_Entry__c,SKU_Effort_Mapping_Entry__r.SKU_Effort_Map__c, Project_Task__c, Name, SKU_Quantity__c, Project_Task__r.pse__Estimated_Hours__c,
        Project_Task__r.pse__Start_Date_Time__c, Project_Task__r.pse__End_Date_Time__c, Processed__c, Project_Task__r.pse__Project__c
        FROM Project_Task_SKU_Effort_Mapping_Entry__c
        WHERE Project_Task__r.pse__Project__c in :setProjectId
        ];
        System.debug('@@114 projectTaskSkuEffortMappingEntries :::: ' +projectTaskSkuEffortMappingEntries);      
        return projectTaskSkuEffortMappingEntries;
        
    }


    public static List<Project_Task_Skill__c> getProjectTaskSillsByProjectTasks(Set<Id> tasks) {
        
        List<Project_Task_Skill__c> projectTaskSkills = [
        SELECT Id,
        Project_Task__c,
        Skill_Certification__c,
        Minimum_Rate__c
        FROM Project_Task_Skill__c
        WHERE Project_Task__c IN :tasks
        ];
         System.debug('@@130 projectTaskSkills :::: ' +projectTaskSkills);  
        return projectTaskSkills;
        
    }

    public static List<pse__Milestone__c> getPseMilestonesByPseProjects(List<pse__Proj__c> projects) {
        
        List<pse__Milestone__c> milestones = [SELECT Id, Name, pse__Status__c FROM pse__Milestone__c
            WHERE pse__Project__c in : projects
            AND pse__Status__c NOT IN ('Approved','Canceled')
            ];
        System.debug('@@141 milestones :::: ' +milestones); 
        return milestones;
        
    }
  

    public static List<OrderItem> getOrderItemByProject(Set<Id> project){
                
        List<OrderItem> orderItemList = [
        SELECT Id,Project__c, Quantity, SKU_Cost__c, Unit_Selling_Price_USD__c, SKU_Number__c, SKU_Description__c
        FROM OrderItem
        WHERE Project__c IN :project
        ];
        
        return orderItemList;
        
    }

    public static List<pse__Proj__c>  getProjectsWithChildrenProjectContacts(List<pse__Proj__c> projects){
                
        List<pse__Proj__c> projectsWithChildrenProjectContacts =
        [
        SELECT Id,
        (SELECT Project__c, Contact__c FROM Project_Contacts__r WHERE Contact_Role__c = 'On Site')
        FROM pse__Proj__c
        WHERE Id IN :projects
        ];
        
        return projectsWithChildrenProjectContacts;
        
    }


    public static  List<SKU_Effort_Map_Entry__c> getskuEffortMapWithChildrenSkills(Set<Id> skuToEffortMappingEntryIds){
                
        List<SKU_Effort_Map_Entry__c> skuEffortMapWithChildrenSkills =
        [
        SELECT Id,
        (SELECT Skill_Certification__r.Name, Minimum_Rate__c, SKU_Effort_Map_Entry__r.SKU_Effort_Map__c FROM Skill_SKU_Effort_Map_Entries__r)
        FROM SKU_Effort_Map_Entry__c
        WHERE Id IN :skuToEffortMappingEntryIds
        ];

        return skuEffortMapWithChildrenSkills;
        
    }


    public static List<Activity_Type__mdt> getActivityTypeMdts(){
                
        List<Activity_Type__mdt> lstActivityMdt =
        [SELECT MasterLabel, Is_Multiple_Activities__c, DeveloperName FROM Activity_Type__mdt];

        return lstActivityMdt;        
    }           

}