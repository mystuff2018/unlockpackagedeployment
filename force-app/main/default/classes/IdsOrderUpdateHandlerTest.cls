@isTest()
public class IdsOrderUpdateHandlerTest {

    static void createSkill(string name, string externalId){
        pse__Skill__c skill = new pse__Skill__c(
                Name = name,
                pse__External_Id__c = externalId

        );
        insert skill;
    }

    static pse__Proj__c createProject(Id accountId) {

        pse__Practice__c practice = createPracticesItemClass();
        pse__Proj__c project = new pse__Proj__c(
                                    Name='Test Project',
                                    pse__Is_Template__c = false,
                                    pse__Is_Active__c = true,
                                    pse__Start_Date__c = Date.today(),
                                    pse__Account__c = accountId,
                                    pse__Practice__c = practice.Id

        );

        insert project;

        return project;
    }

    static pse__Proj__c createProjectAutoDispatch(Id accountId) {

        pse__Practice__c practice = createPracticesItemClass();
        pse__Proj__c project = new pse__Proj__c(
                                    Name='Test Project 2',
                                    pse__Is_Template__c = false,
                                    pse__Is_Active__c = true,
                                    pse__Start_Date__c = Date.today(),
                                    pse__Account__c = accountId,
                                    pse__Practice__c = practice.Id);
        insert project;

        return project;
    }

    static Order createOrder(string name, string orderNumber, string status){
        Order order;
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            Account account = new Account();
            account.Name = name;
            insert(account);

            pse__Proj__c project = createProject(account.Id);

            order = new Order();
            order.OrderNumber__c = orderNumber;
            order.EffectiveDate = Date.valueOf('2018-07-17');
            order.AccountId = account.Id;
            order.CurrencyIsoCode = 'USD';
            order.BUID__c = '11';
            order.Status = 'BK';
            order.Order_Status__c = status;
            order.Pricebook2Id = Test.getStandardPricebookId(); 
            order.Milestone__c = createMilestone(project.Id).Id;
            order.Project__c = project.Id;
            order.FF_Feed__c = true;

            insert order;
            
            createOrderItem(order.Id);
        }
        return order;
    } 
    
    static Order createOrderToOrderItemSKUNumber(string name, string orderNumber, string status){
        Order order;
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            Account account = new Account();
            account.Name = name;
            insert(account);
            
            pse__Proj__c project = createProjectAutoDispatch(account.Id);
            
            order = new Order();
            order.OrderNumber__c = orderNumber;
            order.EffectiveDate = Date.valueOf('2018-07-17');
            order.AccountId = account.Id;
            order.CurrencyIsoCode = 'USD';
            order.BUID__c = '11';
            order.Status = status;
            order.Pricebook2Id = Test.getStandardPricebookId(); 
            order.FF_Feed__c = true;      

            insert order;
            
            createOrderItemSkuNumber(order.Id);
            order.Milestone__c = createMilestone(project.Id).Id;
            order.Project__c = project.Id;
            update  order;
        }
        return order;
    } 
    
    static pse__Milestone__c createMilestone(Id projectId) {

        pse__Milestone__c milestone = new pse__Milestone__c();
        milestone.pse__Project__c = projectId;
        milestone.pse__Target_Date__c = Date.valueOf('2018-07-17');
        milestone.pse__Milestone_Cost__c = 1;
        
        insert milestone;
        
        return milestone;
    }
    
    static PricebookEntry createPricebookEntry(){
        Product2 product = new Product2();
        product.Name = 'Order Status Test Product';
        insert(product);
        
       /* List<PricebookEntry> pbentry = [Select ID from PricebookEntry where Product2Id =:product.Id limit 1];
        if(pbentry == null && pbentry.size() == 0){*/
            PricebookEntry entry = new PricebookEntry();
            entry.CurrencyIsoCode = 'USD';
            entry.Pricebook2Id = Test.getStandardPricebookId(); 
            entry.UnitPrice = 0;
            entry.UseStandardPrice = false;
            entry.Product2Id = product.Id;
            insert(entry);
           // pbentry.add(entry);
       // }
        
       // return pbentry[0]; 
       return entry;
    }
    
    static OrderItem createOrderItem(Id orderId){

        OrderItem item = new OrderItem();
        item.OrderId = orderId;
        item.PricebookEntryId = createPricebookEntry().Id;
        item.UnitPrice = 10;
        item.Quantity = 1;
        item.Item_Class_Description__c = 'SVC EDT INSTLN Test';
        
        insert(item);
        return item;
    }
    
    static OrderItem createOrderItemSkuNumber(Id orderId){

        OrderItem item = new OrderItem();
        item.OrderId = orderId;
        item.PricebookEntryId = createPricebookEntry().Id;
        item.UnitPrice = 10;
        item.Quantity = 1;
        item.SKU_Number__c ='555-5555';
        item.SKU_Cost__c = 100;
        item.Unit_Selling_Price_USD__c = 1;
        item.SKU_Cost_USD__c = 1;
        item.Item_Class_Description__c = 'SVC EDT INSTLN Test';
        
        insert(item);
        return item;
    }
    
    static  WO_SKU_Effort_Map__c setWOSkuEfforMapToAutoDispatch(){
        
        pse__Proj__c templateProject = new pse__Proj__c(
            Name = 'Phased Project Template - Custom - Global',
            pse__Is_Template__c = true,
            pse__Is_Active__c = true,
            pse__Start_Date__c = Date.today()
        );

        insert(templateProject);

        List<pse__Project_Task__c> templateTasks = new List<pse__Project_Task__c>();

        pse__Project_Task__c t1 = new pse__Project_Task__c(
            Name = 'Initiate',
            pse__Project__c = templateProject.Id
        );

        templateTasks.add(t1);

        pse__Project_Task__c t2 = new pse__Project_Task__c(
            Name = 'Plan',
            pse__Project__c = templateProject.Id
        );

        templateTasks.add(t2);

        pse__Project_Task__c t3 = new pse__Project_Task__c(
            Name = 'Execute',
            pse__Project__c = templateProject.Id
        );

        templateTasks.add(t3);

        pse__Project_Task__c t4 = new pse__Project_Task__c(
            Name = 'Close',
            pse__Project__c = templateProject.Id
        );

        templateTasks.add(t4);

        pse__Project_Task__c t5 = new pse__Project_Task__c(
            Name = 'PM Activities',
            pse__Project__c = templateProject.Id
        );

        templateTasks.add(t5);

        insert(templateTasks);
        
        SKU_Effort_Map__c skuEffortMap = new SKU_Effort_Map__c(
            Active__c = true,
            Description__c = 'Test SKU Number  True to project Auto-Dispatch'
        );
        insert skuEffortMap;

        SKU_Number__c skuNumber = new SKU_Number__c();
        skuNumber.SKU_Number__c = '555-5555';
        skuNumber.SKU_to_Effort_Mapping__c = skuEffortMap.Id;
        insert skuNumber;
        
        List<SKU_Effort_Map_Entry__c> entries = new List<SKU_Effort_Map_Entry__c>();
        
        SKU_Effort_Map_Entry__c entry1 = new SKU_Effort_Map_Entry__c(
            Phase__c = 'Initiate',
            Project_Complexity_Tier__c = 'Low',
            SKU_Effort_Map__c = skuEffortMap.id,
            Estimated_Hours__c = 4,
            project__c = templateProject.Id,
            Name__c = 'Physical Installation'
        );
        insert(entry1);
        
        WO_SKU_Effort_Map__c woSkuEffortMap1 = new WO_SKU_Effort_Map__c(
            Calculation_Type__c = 'By SKU Quantity',
            Delivery_Method__c = 'OnSite',
            Description__c = 'Prepare Installation',
            Duration__c = 20,
            SKU_Effort_Mapping_Entry__c = entry1.Id,
            Wo_Record_Type__c = 'FF - Unknown',
            Auto_Dispatch__c= True
        );

        insert woSkuEffortMap1;

        return woSkuEffortMap1;
    }


    static void createSkills() {

        List<pse__Skill__c> skills = new List<pse__Skill__c>();
        skills.add(new pse__Skill__c(Name = 'Project Management (Low)',pse__External_Id__c='9321'));
        skills.add(new pse__Skill__c(Name = 'Project Management (Medium)',pse__External_Id__c='9322'));
        skills.add(new pse__Skill__c(Name = 'Project Management (High)',pse__External_Id__c='9323'));

        insert skills;
    }

    static pse__Practice__c createPracticesItemClass(){
        
         pse__Proj__c projectTemplate = TestDataUtility.createProject(true);

        pse__Practice__c practice = new pse__Practice__c();
        practice.Name = 'Custom Practice Test';
        practice.Standard_Project_Template__c = projectTemplate.Id;
        insert practice;

        Item_Class__c itemClass = new Item_Class__c();
        itemClass.Item_Class_Description__c = 'SVC EDT INSTLN Test';
        itemClass.Practice__c = practice.Id;
        itemClass.Key_Practice__c = true;
        insert itemClass;

        return practice;

    }

    static string ConvertStatus(string status){
        Custom_Order_Status_to_Order_Status_Map__mdt[] mapping = [
            SELECT Custom_Status__c, Order_Status__c, Status_Order__c
            FROM Custom_Order_Status_to_Order_Status_Map__mdt
            WHERE Custom_Status__c =: status
            LIMIT 1
        ];

        if(mapping.size() == 0) {
            return null;
        }

        return mapping[0].Order_Status__c;
    }

    @testSetup static void setup() {
        createSkill('Project Management (Low)','123456');
        createSkill('Project Management (Medium)','2345');
        createSkill('Project Management (High)','52314');
    }

    @isTest()
    static void handleUpdateTest() {
        // arrange

        List<Order> newOrders = new List<Order>();

        Order newOrder = createOrder('Test Order1', '12345', 'BK');
        newOrder.Status = 'CL';
        newOrders.add(newOrder);

        List<Order> oldOrders = new List<Order>(newOrders);

        // act
        IdsOrderUpdateHandler.HandleOrderUpdate(newOrders, oldOrders);

        // assert
        system.assert(true);
    }

    @isTest()
    static void handleStatusUpdateTest() {
        //arrange
        Order newOrder = createOrder('Test Order1', '12345', 'EC');

        List<Order> newOrders = new List<Order>();
        newOrders.add(newOrder);

        Order oldOrder = new Order(Id=newOrder.Id, Order_Status__c='BK', Status = 'BK');
        List<Order> oldOrders = new List<Order>();
        oldOrders.add(oldOrder);

        List<Custom_Order_Status_to_Order_Status_Map__mdt> maps = [SELECT Id, Custom_Status__c, Order_Status__c, Status_Order__c FROM Custom_Order_Status_to_Order_Status_Map__mdt];

        //act
        IdsOrderUpdateHandler.HandleStatusUpdate(newOrders, oldOrders, maps);

        //assert
        system.assert(true);
    }

    @isTest()
    static void handlePODStatusUpdateTest() {
        //arrange
        Order newOrder = createOrder('Test Order1', '12345', 'POD');        

        List<Order> newOrders = new List<Order>();
        newOrders.add(newOrder);
        
        Order oldOrder = new Order(Id=newOrder.Id, Order_Status__c='BK', Status = 'BK');
        List<Order> oldOrders = new List<Order>();
        oldOrders.add(oldOrder);
        
        List<Custom_Order_Status_to_Order_Status_Map__mdt> maps = [SELECT Id, Custom_Status__c, Order_Status__c, Status_Order__c FROM Custom_Order_Status_to_Order_Status_Map__mdt];
        
        //act
        IdsOrderUpdateHandler.HandleStatusUpdate(newOrders, oldOrders, maps);
        
        //assert
        system.assert(true);
    }

    @isTest()
    static void handleRDDStatusUpdateTest() {
        //arrange
        Order newOrder = createOrder('Test Order1', '12345', 'RDD');        

        List<Order> newOrders = new List<Order>();
        newOrders.add(newOrder);
        
        Order oldOrder = new Order(Id=newOrder.Id, Order_Status__c='BK', Status = 'BK');
        List<Order> oldOrders = new List<Order>();
        oldOrders.add(oldOrder);
        
        List<Custom_Order_Status_to_Order_Status_Map__mdt> maps = [SELECT Id, Custom_Status__c, Order_Status__c, Status_Order__c FROM Custom_Order_Status_to_Order_Status_Map__mdt];
        
        //act
        IdsOrderUpdateHandler.HandleStatusUpdate(newOrders, oldOrders, maps);
        
        //assert
        system.assert(true);
    }
    
    
}