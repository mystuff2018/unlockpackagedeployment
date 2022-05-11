/**
 * @File Name          : ProjectEndDateConfiguration.cls
 * @Description        : Configuration Project End Date 
 * @Author             : Magaiver Oliveira e Tiago Ferreira  | 10/12/2019 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 12/12/2019 11:03:59
 **/
public class ProjectEndDateConfiguration {
    
    private static final Integer PROJECT_PHASE_SETUP = 1;
    
    public static void populateProjectEndDate(OrderAssociationDataContext context){
        
        //TODO: Add fileds (project.Phase_Number__c, pse__Practice__r.Order_Association_Approval_Phase_Number__c) to apex class Dal_Project 
        Map<pse__Proj__c, List<OrderItem>> orderItemsByProjectMap = new Map<pse__Proj__c, List<OrderItem>>();

        for(Id projectId : context.projectWithAllOrderItems.keySet()){
            
            if(context.projectMap.containskey(projectId)){
                pse__Proj__c project = context.projectMap.get(projectId);
                
                System.debug('@ Order_Association_Approval_Phase_Number__c'+ project.pse__Practice__r.Order_Association_Approval_Phase_Number__c );
                System.debug('@ Phase_Number__c:'+ project.Phase_Number__c);
                
                if(project.Phase_Number__c > PROJECT_PHASE_SETUP && project.Phase_Number__c < project.pse__Practice__r.Order_Association_Approval_Phase_Number__c){

                    for(Id orderId : context.projectWithOrdersMap.get(projectId)){
                        System.debug('orderId:'+orderId);
                        orderItemsByProjectMap.put(project, context.projectWithAllOrderItems.get(projectId));
                    }
                }
            }
        }
        
        setProjectEndDateByOrderItem(orderItemsByProjectMap);        
    }

    private static Boolean hasThirtySupport = false;
    
    public static Map<Id, pse__Practice__c> mapProjectIdPractice;    

    /**
    * @description Set Project End Date From Practice default duration (Call this in trigger before insert)
    * @author Magaiver Oliveira e Tiago Ferreira | 11/12/2019 
    * @param projects 
    * @return void 
    **/
    public static void setProjectEndDateFromPractice(List<pse__Proj__c> projects) {
        
        List<pse__Proj__c> projectsManually = new List<pse__Proj__c>();
        Id defaultRecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
        for(pse__proj__c project : projects) {
            if (!project.Created_Automatically__c && project.RecordTypeId != defaultRecordTypeId) {
                projectsManually.add(project);               
            }
        }

        updateProjectEndDateFromPractice(projectsManually);
    }

    /**
    * @description Set Project End Date from Practice Default Duration 
    * @author Magaiver Oliveira e Tiago Ferreira  | 10/12/2019 
    * @param projects 
    * @return void 
    **/
    private static void updateProjectEndDateFromPractice(List<pse__proj__c> projects){
        List<Id> practiceIds = new List<Id>();

        for(pse__proj__c project : projects) {
            practiceIds.add(project.pse__Practice__c);
        }

        for(pse__Practice__c practice : [SELECT Id, Default_Duration__c FROM pse__Practice__c WHERE Id IN :practiceIds]) {
            Integer durationDays = practice.Default_Duration__c == null ? 0 : Integer.valueOf(practice.Default_Duration__c);
            for(pse__proj__c project : projects) {
                if (project.pse__Practice__c == practice.Id) {
                    project.pse__End_Date__c = project.pse__Start_Date__c.addDays(durationDays);
                }
            }    
        }
    }

    /**
    * @description Set Project End Date From Sku Effort Mapping Duration Days 
    * @author Magaiver Oliveira e Tiago Ferreira  | 11/12/2019 
    * @param mapOrderIdProject 
    * @return List<pse__Proj__c> 
    **/
    public static List<pse__Proj__c> setProjectEndDateBySkuEffortMap(Map<Id, pse__Proj__c> mapOrderIdProject) {
        
        Map<Id, List<SKU_Effort_Map__c>> skuEffortMapsFromOrder = SKUEffortDataManager.getSKUEffortMapFromOrders(new List<Id> (mapOrderIdProject.keySet()));
        Map<Id, Boolean> mapOrderIdAllSkuMapped = SKUEffortDataManager.mapOrderIdAllSkuMapped;
       
        setMapProjectIdPractice(mapOrderIdProject.values());
        
        List<pse__Proj__c> projects = new List<pse__Proj__c>();
        List<pse__Proj__c> projectsWithoutSkuEffortMap = new List<pse__Proj__c>();
        
        Id actualProject;

        for(Id orderId : mapOrderIdProject.keySet()) {
            
            if(actualProject != mapOrderIdProject.get(orderId).Id){
                hasThirtySupport = false;
            }
            
            List<SKU_Effort_Map__c> skuEffortMaps = skuEffortMapsFromOrder.get(orderId);  
            pse__Proj__c project = mapOrderIdProject.get(orderId);

            Boolean allSkuMapped = mapOrderIdAllSkuMapped.containsKey(orderId) ? mapOrderIdAllSkuMapped.get(orderId) : false;
            
            Integer durationDays = getDefaultDurationInSkuEffortMap(skuEffortMaps, project, allSkuMapped);  
           
            Date newEndDate = project.pse__Start_Date__c.addDays(durationDays);
            
            if (durationDays != null && durationDays > 0) {
                
                if(newEndDate > project.pse__End_Date__c || project.pse__End_Date__c == null){
                	project.pse__End_Date__c = newEndDate;
            	}
                
                projects.add(project);
                
            } else {
                projectsWithoutSkuEffortMap.add(project);
            }
            
            actualProject = mapOrderIdProject.get(orderId).Id;
        }

        if (!projectsWithoutSkuEffortMap.isEmpty()) {
            updateProjectEndDateFromPractice(projectsWithoutSkuEffortMap);
            projects.addAll(projectsWithoutSkuEffortMap);
        }
        
        
        Map<Id, pse__Proj__c> uniqueProjectsMap = new Map<Id, pse__Proj__c>();
        for(pse__Proj__c project: projects){
            uniqueProjectsMap.put(project.Id, project);
        }

        return uniqueProjectsMap.values();        
    }

    public static void setProjectEndDateByOrderItem(Map<pse__Proj__c, List<OrderItem>> orderItemsByProjectMap){
      
        Set<String> skuNumbers = new Set<String>();
        for(List<OrderItem> orderItemList: orderItemsByProjectMap.values()){
            for(OrderItem orderItem: orderItemList){
                skuNumbers.add(orderItem.SKU_Number__c);
            }
        }

        List<SKU_Number__c> skuNumberList = [
            SELECT Id, SKU_Number__c, SKU_to_Effort_Mapping__c, SKU_to_Effort_Mapping__r.Duration_Days__c, SKU_to_Effort_Mapping__r.X30_Day_Support__c 
            FROM SKU_Number__c 
            WHERE SKU_Number__c IN : skuNumbers 
                AND SKU_to_Effort_Mapping__r.active__c = true
        ];

        Map<String, SKU_Number__c> skuNumberBySku = new Map<String, SKU_Number__c>();
        for(SKU_Number__c sku: skuNumberList){
            skuNumberBySku.put(sku.SKU_Number__c, sku);
        }
        
        setMapProjectIdPractice(new List<pse__Proj__c>(orderItemsByProjectMap.keySet()));
    
        List<pse__Proj__c> projects = new List<pse__Proj__c>();
        List<pse__Proj__c> projectsWithoutSkuEffortMap = new List<pse__Proj__c>();
        Map<Id, List<SKU_Effort_Map__c>> skuEffortMapByProjectId = new Map<Id, List<SKU_Effort_Map__c>>(); 
        Map<Id, Boolean> allSkuMappedMap = new Map<Id, Boolean>();

        Id actualProject;
        
        for(pse__Proj__c project: orderItemsByProjectMap.keySet()){

            if(!skuEffortMapByProjectId.containsKey(project.Id)){
                skuEffortMapByProjectId.put(project.Id, new List<SKU_Effort_Map__c>());
            }

            List<OrderItem> orderItemList = orderItemsByProjectMap.get(project);
            for(OrderItem orderItem: orderItemList){

                if(skuNumberBySku.containsKey(orderItem.SKU_Number__c)){

                    SKU_Number__c SKUNumber = skuNumberBySku.get(orderItem.SKU_Number__c);
                    
                    SKU_Effort_Map__c SKUMap = new SKU_Effort_Map__c(
                        Id = SKUNumber.SKU_to_Effort_Mapping__c,
                        Duration_Days__c = SKUNumber.SKU_to_Effort_Mapping__r.Duration_Days__c,
                        X30_Day_Support__c = SKUNumber.SKU_to_Effort_Mapping__r.X30_Day_Support__c
                    );

                    List<SKU_Effort_Map__c> lstSKUMap = skuEffortMapByProjectId.get(project.Id);
                    
                    lstSKUMap.add(SKUMap);
                    
                    skuEffortMapByProjectId.put(project.Id, lstSKUMap);
                   
                }
            }

            List<SKU_Effort_Map__c> skuEffortMaps = skuEffortMapByProjectId.get(project.Id);
            Boolean allSkuNumber = skuEffortMaps != null && orderItemList != null && orderItemList.size() == skuEffortMaps.size();
            allSkuMappedMap.put(project.Id, allSkuNumber);
            
            if(actualProject != project.Id){
                hasThirtySupport = false;
            }

            Boolean allSkuMapped = allSkuMappedMap.containsKey(project.Id) ? allSkuMappedMap.get(project.Id) : false;
            
            Integer durationDays = getDefaultDurationInSkuEffortMap(skuEffortMaps, project, allSkuMapped);  
           
            Date newEndDate = project.pse__Start_Date__c.addDays(durationDays);
            
            if (durationDays != null && durationDays > 0) {
                
                if(newEndDate > project.pse__End_Date__c || project.pse__End_Date__c == null){
                 	project.pse__End_Date__c = newEndDate;
            	}
                
            } else {
                projectsWithoutSkuEffortMap.add(project);
            }
            
            actualProject = project.Id;
        }

        if (!projectsWithoutSkuEffortMap.isEmpty()) {
            updateProjectEndDateFromPractice(projectsWithoutSkuEffortMap);
        }
    }

    /**
    * @description 
    * @author Magaiver Oliveira e Tiago Ferreira  | 11/12/2019 
    * @param skuEffortMaps 
    * @return Integer 
    **/
    private static Integer getDefaultDurationInSkuEffortMap(List<SKU_Effort_Map__c> skuEffortMaps, pse__Proj__c project, Boolean allSkuMapped) {
        Integer mainDurationDay = 0;
        //Boolean hasThirtySupport = false;
        Boolean shouldGetDurationFromPratice = false;
        
        if (skuEffortMaps != null && !skuEffortMaps.isEmpty()) {
            for (SKU_Effort_Map__c skuEffort : skuEffortMaps) {
                Integer durationDays = skuEffort.Duration_Days__c == null ? 0 : Integer.valueOf(skuEffort.Duration_Days__c);

                // check if we should get duration from practice
                if (!shouldGetDurationFromPratice && durationDays == 0) {
                    shouldGetDurationFromPratice = true;
                }
                
                // check if the sku effor has thirty days support
                if (!hasThirtySupport && skuEffort.X30_Day_Support__c) {
                    hasThirtySupport = true;
                }

                if (durationDays > mainDurationDay) {
                    mainDurationDay = durationDays;
                }
            }
        }
        if((mainDurationDay == 0 || !allSkuMapped) && mapProjectIdPractice.containsKey(project.Id)){
            pse__Practice__c practice = mapProjectIdPractice.get(project.Id);
            mainDurationDay = (practice.Default_Duration__c != null && practice.Default_Duration__c > mainDurationDay) 
                 ? Integer.valueOf(practice.Default_Duration__c) 
                 : mainDurationDay;
        }
        /*if((shouldGetDurationFromPratice || !allSkuMapped) && mapProjectIdPractice.containsKey(project.Id)) {
            // call method where shoud return the duration from practice.
            pse__Practice__c practice = mapProjectIdPractice.get(project.Id);

            //mainDurationDay = (practice.Default_Duration__c != null && practice.Default_Duration__c > mainDurationDay) 
            //     ? Integer.valueOf(practice.Default_Duration__c) 
            //     : mainDurationDay;
            
            if(practice.Default_Duration__c != null && practice.Default_Duration__c > mainDurationDay){
                mainDurationDay = Integer.valueOf(practice.Default_Duration__c) ;
            }
            
            // If duration of practice is bigger than sku duration, return zero to get duration from practice
            //if(practice.Default_Duration__c != null && practice.Default_Duration__c > mainDurationDay){
			//	mainDurationDay = 0;
			//	return mainDurationDay;
            //}
        }*/

        if (hasThirtySupport) {
            mainDurationDay += 30;
        }
		system.debug('mainDurationDay '+mainDurationDay);
        return mainDurationDay;
    }
    
    private static void setMapProjectIdPractice(List<pse__Proj__c> projects) {
        List<Id> practiceIds = new List<Id>();

        for(pse__proj__c project : projects) {
            practiceIds.add(project.pse__Practice__c);
        }

        mapProjectIdPractice = new Map<Id, pse__Practice__c>();

        for(pse__Practice__c practice : [SELECT Id, Default_Duration__c FROM pse__Practice__c WHERE Id IN :practiceIds]) {
            
            for(pse__proj__c project : projects) {
                if (project.pse__Practice__c == practice.Id) {
                    mapProjectIdPractice.put(project.Id, practice);
                }
            }    
        }
    }
    
    /**
    * @description Update project end date when a new order being associated with an existing project 
    * @author Christopher Michel/Elson Paim  | 23/12/2019 
    * @param projectIds 
    * @return List<pse__Proj__c>
    **/
    
	@InvocableMethod(label = 'Update project end date when a new order being associated with an existing project')
    public static List<pse__Proj__c> setProjectEnddateByProjectId (List<Id> projectIds){
        
        List<Order> listOrders = new List<Order>([SELECT Id, project__c, Project__r.pse__Start_Date__c, Project__r.pse__End_Date__c, Project__r.pse__Practice__c FROM Order WHERE Project__c in :projectIds]);        
        Map<Id,pse__Proj__c> mapOrderIdProject = new Map<Id,pse__Proj__c>();
        
        for (Order order : listOrders){
            mapOrderIdProject.put(order.Id,order.project__r);       
        }
        List<pse__Proj__c> projects = setProjectEndDateBySkuEffortMap(mapOrderIdProject);
        update projects;
        return projects;
    }
}