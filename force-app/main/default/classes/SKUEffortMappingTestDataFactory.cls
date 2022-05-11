@isTest
public class SKUEffortMappingTestDataFactory {
    
    public static pse__Proj__c createProjectWithTask(string taskName) {
        pse__Proj__c project = new pse__Proj__c(Name='Test Project', Project_Visibility__c='All', pse__Is_Active__c = true);
        insert project;
        
        pse__Project_Task__c task = new pse__Project_Task__c(Name=taskName, pse__Project__c=project.Id);
        insert task;
        
        return project;
    }
    
    
    public static pse__Proj__c createProjectWithTaskAndSubTask(string taskName, string subTaskName, decimal subTaskEstimatedhours) {
        pse__Proj__c project = new pse__Proj__c(Name='Test Project', Project_Visibility__c='All', pse__Is_Active__c = true,
                buid__c = '11',
                local_channel__c = '11');
        insert project;
        
        pse__Project_Task__c task = new pse__Project_Task__c(Name=taskName, pse__Project__c=project.Id);
        insert task;
        
        pse__Project_Task__c subTask = new pse__Project_Task__c(Name=subTaskName, pse__Estimated_Hours__c=subTaskEstimatedhours, pse__Project__c=project.Id, pse__Parent_Task__c=task.Id);
        insert subTask;
        
        return project;
    }
    
    public static OrderItem createOrderAndOrderItems(decimal orderItemQtd) {
        Account account = new Account(Name='Test Account');
        insert account;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Order order = new Order(OrderNumber__c='990088123', AccountId=account.Id, EffectiveDate=Date.today(), Status='IP', Pricebook2Id=pricebookId,BUID__c = '11');
        insert order;
        
        Product2 product = new Product2(Name='Product Test');
        insert product;
        
		List<PricebookEntry> pbentry = [Select ID from PricebookEntry where Product2Id =:product.Id limit 1];
		if(pbentry == null || pbentry.size() == 0){
			PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id=pricebookId, Product2Id=product.Id,  UseStandardPrice=false, UnitPrice=1);
			insert pricebookEntry;
			pbentry.add(pricebookEntry);
		}
        
        OrderItem orderItem = new OrderItem(SKU_Number__c='444-999', Quantity=orderItemQtd, OrderId=order.Id, PricebookEntryId=pbentry[0].Id, UnitPrice=1);
        insert orderItem;
        
        return orderItem;
    }
    
    public static pse__Proj__c createProjectWithPractice(string taskName) {
        pse__Practice__c practice = new pse__Practice__c();
        practice.Name = 'Custom Practice Test';
        insert practice;
        
        Item_Class__c itemClass = new Item_Class__c();
        itemClass.Item_Class_Description__c = 'SVC EDT INSTLN Test';
        itemClass.Practice__c = practice.Id;
        itemClass.Key_Practice__c = true;
        insert itemClass;
        
        pse__Proj__c project = new pse__Proj__c(Name='Test Project', Project_Visibility__c='All', pse__Practice__c = practice.Id, pse__Is_Active__c = true);
        insert project;
        
        pse__Project_Task__c task = new pse__Project_Task__c(Name=taskName, pse__Project__c=project.Id);
        insert task;
        
        return project;
    }
    public static List<OrderItem> createCustomOrderAndOrderItems(decimal orderItemQtd) {
        Account account = new Account(Name='Test Account');
        insert account;
        
        pse__Practice__c practice = new pse__Practice__c();
        practice.Name = 'Global Practice';
        insert practice;
        
        Item_Class__c itemClass = new Item_Class__c();
        itemClass.Item_Class_Description__c = 'SVC EDT INSTLN';
        itemClass.Practice__c = practice.Id;
        itemClass.Key_Practice__c = true;
        insert itemClass;
        Item_Class__c[] itemClasses = [SELECT Id, Item_Class_Description__c FROM Item_Class__c WHERE Practice__c = :practice.id AND Key_Practice__c = true];
        pse__Proj__c project = new pse__Proj__c();
        project.Name='Test Project';
        project.pse__Account__c = account.Id;
        project.Project_Visibility__c='All';
        project.pse__Practice__c = practice.Id;
        project.pse__Is_Active__c = true;
        insert project;
        
        pse__Project_Task__c task = new pse__Project_Task__c(Name='Planning', pse__Project__c=project.Id);
        insert task;
        
        Id pricebookId = Test.getStandardPricebookId();
        Order order = new Order();
        order.OrderNumber__c='990088543';
        order.Project__c = project.Id;
        order.Status='BK';
        order.BUID__c='11';
        order.Order_Status__c='BK';
        order.AccountId=account.Id;
        order.EffectiveDate=Date.today();
        order.Pricebook2Id=pricebookId;
        order.Type='IDS';
        insert order;
        
        Order order2 = new Order();
        order2.OrderNumber__c='99008845543';
        order2.Project__c = project.Id;
        order2.Status='BK';
        order2.BUID__c='11';
        order2.Order_Status__c='BK';
        order2.AccountId=account.Id;
        order2.EffectiveDate=Date.today();
        order2.Pricebook2Id=pricebookId;
        order2.Type='IDS';
        insert order2;
        
        Product2 product = new Product2(Name='Product Test');
        insert product;
        
		List<PricebookEntry> pbentry = [Select ID from PricebookEntry where Product2Id =:product.Id limit 1];
		if(pbentry == null && pbentry.size() == 0){
			PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id=pricebookId, Product2Id=product.Id,  UseStandardPrice=false, UnitPrice=1);
			insert pricebookEntry;
			pbentry.add(pricebookEntry);
		}
        
        OrderItem orderItem = new OrderItem();
        orderItem.SKU_Number__c='444-9545';
        orderItem.Quantity=orderItemQtd;
        orderItem.OrderId=order2.Id;
        orderItem.PricebookEntryId=pbentry[0].Id;
        orderItem.UnitPrice=1;
        orderItem.Item_Class_Description__c='SVC EDT INSTLN';
        orderItem.Item_Class__c = 'TBD';
        orderItem.LOB_Description__c='Software PBU';
        orderItem.SKU_Description__c='ProDeploy Dell Storage SC Series vXXXX SAN - Deployment Verification';
        orderItem.Description='ProDeploy Dell Storage SC Series vXXXX SAN - Deployment Verification';
        orderItem.Tie_Number__c='2';
        orderItem.SKU_Type__c='IDS';
        orderItem.Item_Class_Code__c='HY002';
        orderItem.Service_Tower__c='SVC EDT CNSLT';
        orderItem.CFO_Lang_SKU_Description__c='8';
        orderItem.Model_Description__c='DELL KACE K2200S';
        insert orderItem;
        
        
        OrderItem orderItem2 = new OrderItem(SKU_Number__c='444-999', Quantity=2, OrderId=order.Id, PricebookEntryId=pbentry[0].Id, UnitPrice=1);
        insert orderItem2;
        
        OrderItem orderItem3 = new OrderItem();
        orderItem3.SKU_Number__c='444-95215';
        orderItem3.Quantity=orderItemQtd;
        orderItem3.OrderId=order.Id;
        orderItem3.PricebookEntryId=pbentry[0].Id;
        orderItem3.UnitPrice=1;
        orderItem3.Item_Class_Description__c='SVC EDT INSTLN';
        orderItem3.Item_Class__c = 'TBD';
        orderItem3.LOB_Description__c='Software PBU';
        orderItem3.SKU_Description__c='ProDeploy Dell Storage SC Series vXXXX SAN - Deployment Verification';
        orderItem3.Description='ProDeploy Dell Storage SC Series vXXXX SAN - Deployment Verification';
        orderItem3.Tie_Number__c='2';
        orderItem3.SKU_Type__c='IDS';
        orderItem3.Item_Class_Code__c='HY002';
        orderItem3.Service_Tower__c='SVC EDT CNSLT';
        orderItem3.CFO_Lang_SKU_Description__c='8';
        orderItem3.Model_Description__c='DELL KACE K2200S';
        insert orderItem3;
        
        List<OrderItem> orderItemList = new List<OrderItem>();
        orderItemList.add(orderItem);
        orderItemList.add(orderItem2);
        orderItemList.add(orderItem3);
        
        return orderItemList;
        
    }
    
    public static SKU_Effort_Map_Entry__c createEffortMapEntryCustom(string phaseName, string taskName, decimal estimatedHours, boolean skuEfforMapActive) {
        pse__Proj__c template = new pse__Proj__c(pse__Is_Template__c=true, Name='IDS Standart', Project_Visibility__c='All',pse__Is_Active__c = true);
        insert template;
        
        pse__Project_Task__c task = new pse__Project_Task__c(Name=phaseName, pse__Project__c=template.Id);
        insert task;   
        
        SKU_Effort_Map__c effortMap = new SKU_Effort_Map__c(Description__c=taskName, Active__c=skuEfforMapActive);
        insert effortMap;
        
        SKU_Number__c skuNumber = new SKU_Number__c(SKU_Number__c='444-9545', SKU_to_Effort_Mapping__c=effortMap.Id);
        insert skuNumber;
        
        SKU_Effort_Map_Entry__c effortMapEntry = new SKU_Effort_Map_Entry__c(project__c=template.Id, 
                                                                             Name__c=taskName, 
                                                                             SKU_Effort_Map__c=effortMap.Id,
                                                                             Phase__c=task.Id,
                                                                             Role__c= 'Project Manager', 
                                                                             Project_Complexity_Tier__c='Tier 1', 
                                                                             Estimated_Hours__c=estimatedHours);
        insert effortMapEntry;
        
        
        
        Skill_SKU_Effort_Map_Entry__c skillMapping = new Skill_SKU_Effort_Map_Entry__c(SKU_Effort_Map_Entry__c=effortMapEntry.Id);
        
        SKU_Effort_Map__c effortMap2 = new SKU_Effort_Map__c(Description__c=taskName, Active__c=skuEfforMapActive);
        insert effortMap2;
        SKU_Number__c skuNumber2 = new SKU_Number__c(SKU_Number__c='444-999', SKU_to_Effort_Mapping__c=effortMap2.Id);
        insert skuNumber2;
        
        SKU_Effort_Map_Entry__c effortMapEntry2 = new SKU_Effort_Map_Entry__c(project__c=template.Id, 
                                                                              Name__c=taskName, 
                                                                              SKU_Effort_Map__c=effortMap.Id,
                                                                              Phase__c=task.Id,
                                                                              Role__c= 'Project Manager', 
                                                                              Project_Complexity_Tier__c='Tier 1', 
                                                                              Estimated_Hours__c=estimatedHours);
        insert effortMapEntry2;
        
        
        
        Skill_SKU_Effort_Map_Entry__c skillMapping2 = new Skill_SKU_Effort_Map_Entry__c(SKU_Effort_Map_Entry__c=effortMapEntry.Id);
        
        pse__Practice__c practice = [SELECT Id FROM pse__Practice__c WHERE Name = 'Global Practice'];
        SKU_Effort_Map__c effortMap3 = new SKU_Effort_Map__c(Description__c='Custom SKU', Practice__c = practice.Id, Active__c=skuEfforMapActive);
        insert effortMap3;
        SKU_Number__c skuNumber3 = new SKU_Number__c(SKU_Number__c='Custom SKU', SKU_to_Effort_Mapping__c=effortMap3.Id);
        insert skuNumber3;
        
        
        SKU_Effort_Map_Entry__c effortMapEntry3 = new SKU_Effort_Map_Entry__c(project__c=template.Id,
                                                                              Name__c=taskName,
                                                                              SKU_Effort_Map__c=effortMap3.Id,
                                                                              Phase__c=task.Id,
                                                                              Role__c= 'Project Manager',
                                                                              Project_Complexity_Tier__c='Tier 1',
                                                                              Estimated_Hours__c=estimatedHours);
        insert effortMapEntry3;
        
        return effortMapEntry;
    }
    public static SKU_Effort_Map_Entry__c createEffortMapEntry(string phaseName, string taskName, decimal estimatedHours, boolean skuEfforMapActive) {
        pse__Proj__c template = new pse__Proj__c(pse__Is_Template__c=true, Name='IDS Standart', Project_Visibility__c='All',pse__Is_Active__c = true);
        insert template;
        
        pse__Project_Task__c task = new pse__Project_Task__c(Name=phaseName, pse__Project__c=template.Id);
        insert task;   
        
        SKU_Effort_Map__c effortMap = new SKU_Effort_Map__c(Description__c=taskName, Active__c=skuEfforMapActive);
        insert effortMap;
        SKU_Number__c skuNumber4 = new SKU_Number__c(SKU_Number__c='444-999', SKU_to_Effort_Mapping__c=effortMap.Id);
        insert skuNumber4;
        
        SKU_Effort_Map_Entry__c effortMapEntry = new SKU_Effort_Map_Entry__c(project__c=template.Id, 
                                                                             Name__c=taskName, 
                                                                             SKU_Effort_Map__c=effortMap.Id,
                                                                             Phase__c=task.Id,
                                                                             Role__c= 'Project Manager', 
                                                                             Project_Complexity_Tier__c='Tier 1', 
                                                                             Estimated_Hours__c=estimatedHours);
        insert effortMapEntry;
        
        
        
        Skill_SKU_Effort_Map_Entry__c skillMapping = new Skill_SKU_Effort_Map_Entry__c(SKU_Effort_Map_Entry__c=effortMapEntry.Id);
        
        return effortMapEntry;
    }
    
    public static SKU_Effort_Map_Entry__c createEffortMapEntry2(string phaseName, string taskName, decimal estimatedHours, boolean skuEfforMapActive) {
        pse__Proj__c template = new pse__Proj__c(pse__Is_Template__c=true, Name='IDS Standart', Project_Visibility__c='All');
        insert template;
        
        pse__Project_Task__c task = new pse__Project_Task__c(Name=phaseName, pse__Project__c=template.Id);
        insert task;
        
        SKU_Effort_Map__c effortMap = new SKU_Effort_Map__c(Description__c=taskName, Active__c=skuEfforMapActive);
        insert effortMap;
        SKU_Number__c skuNumber5 = new SKU_Number__c(SKU_Number__c='444-9545', SKU_to_Effort_Mapping__c=effortMap.Id);
        insert skuNumber5;
        
        SKU_Effort_Map_Entry__c effortMapEntry = new SKU_Effort_Map_Entry__c(project__c=template.Id,
                                                                             Name__c=taskName,
                                                                             SKU_Effort_Map__c=effortMap.Id,
                                                                             Phase__c=task.Id,
                                                                             Role__c= 'Project Manager',
                                                                             Project_Complexity_Tier__c='Tier 1',
                                                                             Estimated_Hours__c=estimatedHours);
        insert effortMapEntry;
        
        Skill_SKU_Effort_Map_Entry__c skillMapping = new Skill_SKU_Effort_Map_Entry__c(SKU_Effort_Map_Entry__c=effortMapEntry.Id);
        
        return effortMapEntry;
    }
    
    public static Order createOrderWithMultipleOrderItems() {
        Account account = new Account(Name='Test Account');
        insert account;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Order order = new Order(OrderNumber__c='880077123', AccountId=account.Id, EffectiveDate=Date.today(), Status='IP',BUID__c = '11', Pricebook2Id=pricebookId);
        insert order;
        
        Product2 product = new Product2(Name='Product Test two');
        insert product;
        
		List<PricebookEntry> pbentry = [Select ID from PricebookEntry where Product2Id =:product.Id limit 1];
		if(pbentry == null && pbentry.size() == 0){
			PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id=pricebookId, Product2Id=product.Id,  UseStandardPrice=false, UnitPrice=1);
			insert pricebookEntry;
			pbentry.add(pricebookEntry);
        }
        List<OrderItem> orderItems = new List<OrderItem>(); 
        orderItems.add(new OrderItem(SKU_Number__c='444-999', Quantity=2, OrderId=order.Id, PricebookEntryId=pbentry[0].Id, UnitPrice=1));
        orderItems.add(new OrderItem(SKU_Number__c='555-999', Quantity=1, OrderId=order.Id, PricebookEntryId=pbentry[0].Id, UnitPrice=1));
        orderItems.add(new OrderItem(SKU_Number__c='666-999', Quantity=1, OrderId=order.Id, PricebookEntryId=pbentry[0].Id, UnitPrice=1));
        
        insert orderItems;
        
        return order;
    }
    
    public static List<SKU_Effort_Map_Entry__c> createMultiplesEffortMapEntries() {
        pse__Proj__c template = new pse__Proj__c(pse__Is_Template__c=true, Name='IDS Standart', Project_Visibility__c='All');
        insert template;
        
        List<pse__Project_Task__c> tasks = new List<pse__Project_Task__c>();
        tasks.add(new pse__Project_Task__c(Name='Planning', pse__Project__c=template.Id));
        tasks.add(new pse__Project_Task__c(Name='Initiating', pse__Project__c=template.Id));
        insert tasks;   
        
        SKU_Effort_Map__c effortMap = new SKU_Effort_Map__c(Description__c='Description Test', Active__c=true);
        insert effortMap;
        SKU_Number__c skuNumber5 = new SKU_Number__c(SKU_Number__c='444-999', SKU_to_Effort_Mapping__c=effortMap.Id);
        insert skuNumber5;
        
        List<SKU_Effort_Map_Entry__c> effortMapEntries = new List<SKU_Effort_Map_Entry__c>();
        effortMapEntries.add(new SKU_Effort_Map_Entry__c(project__c=template.Id, 
                                                         Name__c='Remote Config', 
                                                         SKU_Effort_Map__c=effortMap.Id,
                                                         Phase__c=tasks.get(0).Id,
                                                         Role__c= 'Project Manager', 
                                                         Project_Complexity_Tier__c='Tier 1', 
                                                         Estimated_Hours__c=10));
        
        effortMapEntries.add(new SKU_Effort_Map_Entry__c(project__c=template.Id, 
                                                         Name__c='Onsite Installation', 
                                                         SKU_Effort_Map__c=effortMap.Id,
                                                         Phase__c=tasks.get(1).Id,
                                                         Role__c= 'Project Manager', 
                                                         Project_Complexity_Tier__c='Tier 1', 
                                                         Estimated_Hours__c=20));
        
        insert effortMapEntries;
        
        
        return effortMapEntries;
    }
    
}