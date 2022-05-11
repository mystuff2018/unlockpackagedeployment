/**
* Created by Bruno_Frosi on 1/20/2020.
* Modified by Christopher_Michel on 3/16/2020
Version  DeveloperName      Comeents
V1      Yamini Kayam       Making Include In Forecasting true for DEFECT 10867126 
*/


public with sharing class CreateProjectTriggerHandler extends TriggerHandler {
    
    private FFProcessControlSettings__c executionControl = FFProcessControlSettings__c.getOrgDefaults();
    private final Integer PLATFORM_EVENT_SIZE = executionControl != null ? Integer.valueOf(executionControl.CreateProjectSize__c) : 5;
    Set<Id> orderIds = new Set<Id>();
    Map<Id, Id> orderItemToPracticeIds = new Map<Id, Id>();
    Map<Id, Id> orderItemToEngagementIds = new Map<Id, Id>();
    Map<Id, String> orderItemToGroupingKeyIds = new Map<Id, String>();
    List<Create_Project__e> events = new List<Create_Project__e>();
    CreateProjectDataContext context;
    
    public CreateProjectTriggerHandler() {
        
        Integer counter = 0;
        events.addAll((List<Create_Project__e>)Trigger.new);
        for(Create_Project__e event :(List<Create_Project__e>)Trigger.new) {
            
            counter ++;
            if(counter > PLATFORM_EVENT_SIZE) {
                break;
            }
            
            EventBus.TriggerContext.currentContext().setResumeCheckpoint(event.ReplayId);
            
            List<String> orderItemList = event.OrderItemList__c.split(';');
            system.debug(' orderItemList '+orderItemList);
            if (orderItemList != null && orderItemList.size() > 0) {
                for(String orderItemId : orderItemList){
                    orderIds.add(Id.valueOf(event.Order_ID__c));
                    orderItemToPracticeIds.put(Id.valueOf(orderItemId), Id.valueOf(event.Practice_Id__c));
                    orderItemToEngagementIds.put(Id.valueOf(orderItemId), Id.valueOf(event.Engagement_Id__c));
                    orderItemToGroupingKeyIds.put(Id.valueOf(orderItemId), event.Grouping_key__c);
                }
            }
        }
        System.debug('CreateProjectTriggerHandler');
        context = new CreateProjectDataContext(orderIds, orderItemToPracticeIds, orderItemToEngagementIds, orderItemToGroupingKeyIds);
    }
    
    public override void afterInsert() {
        try {
            createProject();
            
            context.populateOrderItemsByProjectMap();
            
            ProjectEndDateConfiguration.setProjectEndDateByOrderItem(context.orderItemsByProjectMap);
            
            System.debug('context: ' + JSON.serialize(context, false));
            context.Save();
        }
        catch(Exception e) {
            insert SaveResultExceptionLogger.createExceptionLogger(e, CreateProjectTriggerHandler.Class.getName(), 'Create Project (After Insert)');
        }
    }
    //Commented method definition because calling is commented for below method
    public Id getProjectOwnerId(Id regionId, Id practiceId) {
        System.debug('@@regionId@@'+regionId);
        System.debug('@@practiceId@@'+practiceId);
        String businessSegment = context.practiceIdToBusinessSegment.get(practiceId);
        System.debug('@@businessSegment@@'+businessSegment);
        if(regionId != null)
        {
            pse__Region__c region = context.mapRegion.get(regionId);
            System.debug('@@CPTHregion@@'+region);
            if(region == null)
            {
                region = context.regionStatesMap.get(regionId);
                if(region != null) {
                    if(region.Is_State__c) {
                        region = context.mapRegion.get(region.pse__Parent_Region__c);
                        System.debug('@@CPTHregion2@@'+region);
                    } 
                }
            }
            
            String queueName = context.regionNameToQueueNames.get(businessSegment.toUpperCase()+region.pse__Parent_Region__r.Name.toLowerCase());
            System.debug('@@CPTHqueueName@@'+queueName);
            if(queueName != null) {
                Group queue = context.queueNameToQueue.get(queueName.toLowerCase());
                if (queue != null) {
                    return queue.Id;
					 
                }
            }

        }
        String queueName = context.regionNameToQueueNames.get(context.globalRegion.Name.toLowerCase());
        System.debug('@@CPTHqueueName2@@'+queueName);
        if(queueName != null) {
            Group queue = context.queueNameToQueue.get(queueName.toLowerCase());
            if (queue != null) {
                return queue.Id;
            }
        }

        return null;
    }
    
    public pse.CreateProjectFromTemplateService.CreateProjectFromTemplateRequest getProjectCreateRequestFromTemplate(pse__Proj__c template, Order order, String groupingKey) {
        Account account = context.accountMap.get(order.AccountId);
        pse.SObjectCloneMapper cloneMapper = new pse.SObjectCloneMapper(pse__Proj__c.SObjectType, CreateProjectFieldMapper.getFields(context, order, account, template, groupingKey));
        pse.CreateProjectFromTemplateService.CreateProjectFromTemplateRequest createProjectRequest = new pse.CreateProjectFromTemplateService.CreateProjectFromTemplateRequest(template.Id, Date.today());
        createProjectRequest.ProjectName = account.Name.left(60) + ' ' + Datetime.now().format('MMM dd yyyy HHmmss');
        createProjectRequest.IsActive = true;
        createProjectRequest.IsTemplate = false;
        createProjectRequest.Mappers = new List<pse.SObjectCloneMapper>{cloneMapper};
            createProjectRequest.ProjectOwnerId = UserInfo.getUserId();
        return createProjectRequest;
    }
    
    private void createProject(){
        List<pse.CreateProjectFromTemplateService.CreateProjectFromTemplateRequest> listProjectCreateRequest = new List<pse.CreateProjectFromTemplateService.CreateProjectFromTemplateRequest>();
        Set<Id> projectIds = new Set<Id>();
        List<String> groupingKeyOrdered = new List<String>();
        if(context.listOfGroupedOrderItens.size() > 0) {
            system.debug('listOfGroupedOrderItens '+context.listOfGroupedOrderItens);
            for (String groupingKey : context.listOfGroupedOrderItens.keySet()) {
                OrderItemGroupingCompositeKey compositeKey = new OrderItemGroupingCompositeKey(groupingKey);
                Set<Id> groupedOrderItens = context.listOfGroupedOrderItens.get(groupingKey);
                OrderItem orderItem = context.orderItemMap.get(new List<Id> (groupedOrderItens)[0]);
                Order order = context.orderMap.get(orderItem.OrderId);
                
                context.executionControl.setProcessLog(order.Id, 'Creating project for orderItem: ' + orderItem.SKU_Number__c, 'Create project');
                context.executionControl.setProcessLog(order.Id, 'context.practiceIdToTemplate: ' + context.practiceIdToTemplate, 'CreateProject');	
                if(context.practiceIdToTemplate.containsKey(compositeKey.practice)){	
                    listProjectCreateRequest.add(getProjectCreateRequestFromTemplate(context.practiceIdToTemplate.get(compositeKey.practice), order, groupingKey));	
                    groupingKeyOrdered.add(groupingKey);	
                    context.executionControl.setProcessLog(order.Id, 'Creating project for orderItem: ' + orderItem.SKU_Number__c, 'Create project');	
                    
                }else{	
                    context.executionControl.setProcessLog(order.Id, 'No template found for practice to OrderItem: ' + orderItem.SKU_Number__c, 'Create project');	
                }	
                
            }	
            
            List<pse.CreateProjectFromTemplateService.CreateProjectResponse> listCreateProjectResponses = new List<pse.CreateProjectFromTemplateService.CreateProjectResponse>();	
            try{	
                listCreateProjectResponses = pse.CreateProjectFromTemplateService.createProjectsFromTemplates(listProjectCreateRequest);	
            }catch(DmlException e) {	
                if (e.getMessage().contains('UNABLE_TO_LOCK_ROW')){	
                    listCreateProjectResponses = pse.CreateProjectFromTemplateService.createProjectsFromTemplates(listProjectCreateRequest);	
                } else {	
                    throw e;	
                }	
            }
            
            Integer i = 0;
            for(pse.CreateProjectFromTemplateService.CreateProjectResponse response :listCreateProjectResponses)
            {
                if(response != null) {
                    Set<Id> orderItems = new Set<Id>(context.listOfGroupedOrderItens.get(groupingKeyOrdered[i]));
                    OrderItem orderItem = context.orderItemMap.get(new List<Id> (orderItems)[0]);
                    if (response.isSuccess()) {
                        projectIds.add(response.NewProjectId);
                        context.projectToOrderItemMap.put(response.NewProjectId, orderItems);
                    }
                    // I'm assuming that the response comes in the same order as the requests. That's the only way to relate project to order.
                    // Also, as the object Clone_Project_Info__c has an Lookup for project I'm only using the first order from the groupedOrders to link it.
                    
                    if(String.isNotEmpty(response.QueuedJobId)){
                        context.cloneProjectInfo.add(new Clone_Project_Info__c(Order__c = orderItem.OrderId, Project__c = response.NewProjectId, Queued_Job_Id__c = response.QueuedJobId));
                    }
                }
                i++;
            }
            if(projectIds.size() > 0)
            {
                system.debug('projectIds '+projectIds);
                context.projectMap.putAll(DAL_Project.getProjectByIds(projectIds));
                if(context.projectMap.size() > 0)
                {
                    for(Id projectId :context.projectMap.keySet())
                    {
                        pse__Proj__c project = context.projectMap.get(projectId);
                        Set<Id> orderItemIds = context.projectToOrderItemMap.get(projectId);
                        Id orderItemId = new List<Id> (orderItemIds)[0];
                        Id engagementId = orderItemToEngagementIds.get(orderItemId);
                        Id practiceId = orderItemToPracticeIds.get(orderItemId);
                        project.OwnerId = getProjectOwnerId(project.pse__Region__c, practiceId);
                        System.debug('CPTHprojectOwnerId'+project.OwnerId);
                        project.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('Small Project Tier').getRecordTypeId();
                        project.pse__Parent_Project__c = engagementId;
                        project.pse__Practice__c = practiceId;
                        //V1 Starts
                        project.pse__Include_In_Forecasting__c=true;
                        //V1 Ends
                        //Completar informações do projeto
                        
                        pse__Resource_Request__c resourceRequest = new pse__Resource_Request__c(
                            pse__Resource_Role__c = 'Project Manager',
                            pse__SOW_Hours__c = 1,
                            pse__Project__c = project.Id,
                            pse__End_Date__c = project.pse__End_Date__c,
                            pse__Start_Date__c = project.pse__Start_Date__c,
                            pse__Region__c = project.pse__Region__c,
                            pse__Practice__c = project.pse__Practice__c,
                            CurrencyIsoCode = project.CurrencyIsoCode
                        );
                        context.listResourceRequest.add(resourceRequest);
                    }
                }
            }
        }
    }
}