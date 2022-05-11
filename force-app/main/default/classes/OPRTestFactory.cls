/**
 * Created by Bruno_Frosi on 1/13/2020.
 */

@isTest
public class OPRTestFactory {
    public static Account newAccount(String accountName, String accountNumber)
    {
        return newAccount(accountName, accountNumber, null, null);
    }
    public static Account newAccount(String accountName, String accountNumber, String accountBUID, String CCN) {
        Account account = new Account();
        account.Name = accountName;
        account.AccountNumber = accountNumber;
        account.BUID__c = accountBUID;
        account.CCN__c = CCN;
        return account;
    }

    public static Contact newContact(String firstName, String lastName, String mailingCountry, String mailingState, String phone) {
        Contact contact = new Contact(
                FirstName=firstName,
                LastName=lastName,
                Mailing_Country__c=mailingCountry,
                Mailing_State__c=mailingState,
                MailingStreet='1 Dell Way',
                Email='test007@dell.com',
                Phone = '1234567890');
        return contact;
    }

    public static Order newOrderWithItem(
            String orderNumber,
            Id accId,
            Id contactId,
            string billingCountry,
            string billingState,
            string shippingCountry,
            string shippingState,
            String PoNumber,
            String DealId,
            String DPId,
            Id installAtCN,
            Id directCN,
            Id endUserCN,
            Id shippingCN) {
        return newOrderWithItem(
                orderNumber,
                accId,
                contactId,
                billingCountry,
                billingState,
                shippingCountry,
                shippingState,
                PoNumber,
                DealId,
                DPId,
                installAtCN,
                directCN,
                endUserCN,
                shippingCN,
                null,
                'SVC EDT INSTLN');
    }

    public static Order newOrderWithItem(
            String orderNumber,
            Id accId,
            Id contactId,
            string billingCountry,
            string billingState,
            string shippingCountry,
            string shippingState,
            String PoNumber,
            String DealId,
            String DPId,
            Id installAtCN,
            Id directCN,
            Id endUserCN,
            Id shippingCN,
            String localChannel,
            String itemClassDescription)
    {
        return newOrderWithItem(
                orderNumber,
                accId,
                contactId,
                billingCountry,
                billingState,
                shippingCountry,
                shippingState,
                PoNumber,
                DealId,
                DPId,
                installAtCN,
                directCN,
                endUserCN,
                shippingCN,
                localChannel,
                itemClassDescription,
                null);
    }
    public static Order newOrderWithItem(
            String orderNumber,
            Id accId,
            Id contactId,
            string billingCountry,
            string billingState,
            string shippingCountry,
            string shippingState,
            String PoNumber,
            String DealId,
            String DPId,
            Id installAtCN,
            Id directCN,
            Id endUserCN,
            Id shippingCN,
            String localChannel,
            String itemClassDescription,
            Id projectId)
    {
        return newOrderWithItem(
                orderNumber,
                accId,
                contactId,
                billingCountry,
                billingState,
                shippingCountry,
                shippingState,
                PoNumber,
                DealId,
                DPId,
                installAtCN,
                directCN,
                endUserCN,
                shippingCN,
                localChannel,
                itemClassDescription,
                projectId, null, null);
    }

    public static Order newOrderWithItem(
            String orderNumber,
            Id accId,
            Id contactId,
            string billingCountry,
            string billingState,
            string shippingCountry,
            string shippingState,
            String PoNumber,
            String DealId,
            String DPId,
            Id installAtCN,
            Id directCN,
            Id endUserCN,
            Id shippingCN,
            String localChannel,
            String itemClassDescription,
            Id projectId,
            Id approvalProjectId,
            Id approver)
    {
        // Create Order
        Order order = new Order();
        order.OrderNumber__c = orderNumber;
        order.EffectiveDate = Date.today();
        order.AccountId = accId;
        order.CurrencyIsoCode = 'USD';
        order.BUID__c = '11';
        order.Status = 'BK';
        order.Order_Status__c = 'EC';
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.OCI_Order_Type__c = 'US Order';
        order.FF_Feed__c = true;
        order.BillToContactId = contactId;
        order.ShipToContactId = contactId;
        order.Billing_Country__c = billingCountry;
        order.Billing_State__c = billingState;
        order.Shipping_Country__c = shippingCountry;
        order.Shipping_State__c = shippingState;
        order.PoNumber = PoNumber;
        order.Deal_ID__c = DealId;
        order.DPID__c = DPId;
        order.Direct_Account__c = directCN;
        order.End_User_Account__c = endUserCN;
        order.Install_At_Account__c = installAtCN;
        order.Shipping_Account__c = shippingCN;
        order.Local_Channel__c = localChannel;
        order.Project__c = projectId;
        order.Approval_Project_Id__c = approvalProjectId;
        order.Association_Approver__c = approver;

        insert order;

        // Order Product
        Product2 product = new Product2();
        product.Name='Product Test';
        insert product;

        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.UseStandardPrice = false;
        pricebookEntry.UnitPrice = 1;
        insert pricebookEntry;

        // Order Item
        OrderItem oi = new OrderItem();
        oi.SKU_Description__c = 'SKU Desc 1';
        oi.SKU_Number__c = '777-1000';
        oi.Quantity = 1;
        oi.UnitPrice = 2;
        oi.Item_Class_Description__c = itemClassDescription;
        oi.Tie_Number__c = '1';
        oi.OrderId = order.Id;
        oi.PriceBookEntryId = priceBookEntry.Id;
        oi.SKU_Cost__c = 2;
        oi.SKU_Cost_Local__c = 2;
        oi.Unit_Selling_Price_USD__c = 85000;
        oi.Unit_Selling_Price_Local__c = 85000;
        oi.SKU_Cost_USD__c = 85000;
        insert oi;

        order.OrderItems.add(oi);

        return order;
    }

    public static Order createOrderStateCountry(String mailingCountry, String mailingState,
            String billingCountry,
            String billingState,
            String shippingCountry,
            String shippingState) {
        Contact contact = newContact('firstName','lastName',mailingCountry,mailingState,'2367341534');
        INSERT contact;
             List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
         
        Account account = newAccount('Order Status Test Account', '111');
             system.runAs(loginUser[0]){ INSERT account;}
        Order order = new Order(
                OrderNumber__c='987654321',
                Billing_Country__c=billingCountry,
                Billing_State__c=billingState,
                Shipping_Country__c=shippingCountry,
                Shipping_State__c=shippingState,
                BillToContactId=contact.Id,
                ShipToContactId=contact.Id,
                AccountId=account.Id,
                EffectiveDate = Date.valueOf('2018-07-17'),
                Pricebook2Id = Test.getStandardPricebookId(),
                BUID__c = '11',
                Status='BK');
        insert order;
        List<pse__Skill__c> skills = new List<pse__Skill__c>();
        skills.add(new pse__Skill__c(Name = 'Project Management (Low)', pse__External_Id__c='9321'));
        skills.add(new pse__Skill__c(Name = 'Project Management (Medium)', pse__External_Id__c='9322'));
        skills.add(new pse__Skill__c(Name = 'Project Management (High)', pse__External_Id__c='9323'));
        insert skills;
        return order;
    }
    public static pse__Proj__c createProject(Id accountId, String PoNumber, String DealId, String DPId)
    {

        List<pse__Practice__c> practices = [
                SELECT Id
                FROM pse__Practice__c
        ];

        pse__Practice__c practice;
        if(practices.size() == 0){
            practice = createPracticesItemClass();
        }
        else{
            practice = practices[0];
        }

        pse__Proj__c project = new pse__Proj__c(
                Name='Test Project',
                pse__Is_Template__c = false,
                pse__Is_Active__c = true,
                //CreatedDate = System.Today().addDays(-90),
                pse__Start_Date__c = Date.today(),
                pse__Account__c = accountId,
                pse__Practice__c = practice.Id,
                Po_Number__c = PoNumber,
                Deal__c = DealId,
                DP__c = DPId,
                buid__c = '11',
                local_channel__c = '11'
        );
        return project;
    }

    public static pse__Proj__c createProject() {
        Account acc = createSimpleAccount();

        List<pse__Practice__c> practices = [
                SELECT Id
                FROM pse__Practice__c
        ];

        pse__Practice__c practice;
        if(practices.size() == 0){
            practice = createPracticesItemClass();
        }
        else{
            practice = practices[0];
        }

        Contact cnt = createSimpleContact();

        pse__Region__c region = OPRTestFactory.newRegion('United States', 'US', true);
        insert region;

        pse__Proj__c project = new pse__Proj__c(
                Name = 'Test Project 1',
                Project_Complexity__c = 'Low',
                pse__Account__c = acc.Id,
                pse__Is_Active__c = true,
                //CreatedDate = System.Today().addDays(-90),
                pse__Start_Date__c = Date.today(),
                pse__Practice__c = practice.Id,
                pse__Project_Manager__c = cnt.Id,
                pse__Region__c = region.Id,
                buid__c = '11',
                local_channel__c = '11');

        insert(project);
        return project;
    }

    public static pse__Proj__c createProjectTemplate(Id accountId, String PoNumber, String DealId, String DPId)
    {

        List<pse__Practice__c> practices = [
                SELECT Id
                FROM pse__Practice__c
        ];

        pse__Practice__c practice;
        if(practices.size() == 0){
            practice = createPracticesItemClass();
        }
        else{
            practice = practices[0];
        }

        pse__Proj__c project = new pse__Proj__c(
                Name='Phased Project Template - Custom - Global',
                pse__Is_Template__c = true,
                pse__Is_Active__c = true,
                //CreatedDate = System.Today().addDays(-90),
                pse__Start_Date__c = Date.today(),
                pse__Account__c = accountId,
                pse__Practice__c = practice.Id,
                Po_Number__c = PoNumber,
                Deal__c = DealId,
                DP__c = DPId,
                buid__c = '11',
                local_channel__c = '11'
        );
        return project;
    }

    public static pse__Practice__c createPracticesItemClass(){
        
        Account acc = createSimpleAccount();
        pse__Proj__c projectTemplate = new pse__Proj__c(
                Name='Phased Project Template - Custom - Global',
                pse__Project_Type__c = 'Concession Delivery',
                pse__Is_Template__c = true,
                pse__Is_Active__c = true,
                pse__Start_Date__c = Date.today(),
                pse__Account__c = acc.Id,
                //pse__Practice__c = practice2.Id,
                Po_Number__c = '54764648',
                Deal__c = '54764648',
                DP__c = '54764648'
        );
        insert projectTemplate;
        
        pse__Practice__c practice = new pse__Practice__c(Name = 'Custom Practice Test', Order_Association_Approval_Phase__c = 'Execute', Standard_Project_Template__c = projectTemplate.Id); 

        List<Item_Class__c> itemClasses = [
                SELECT Id
                FROM Item_Class__c
                WHERE Practice__c = :practice.Id
                AND Item_Class_Description__c LIKE '%SVC EDT INSTLN%'
        ];

        if(itemClasses.size() == 0){

            Item_Class__c itemClass = new Item_Class__c();
            itemClass.Item_Class_Description__c = 'SVC EDT INSTLN';
            itemClass.Practice__c = practice.Id;
            itemClass.Key_Practice__c = true;
            insert itemClass;

        }



        return practice;
    }

    public static pse__Practice__c createPracticesItemClassAndISGTemplate(){

        Account acc = createSimpleAccount();
        pse__Proj__c projectTemplate = new pse__Proj__c(
                Name='ISG Phased Project Template - Custom - Global',
                pse__Project_Type__c = 'Concession Delivery',
                pse__Is_Template__c = true,
                pse__Is_Active__c = true,
                pse__Start_Date__c = Date.today(),
                pse__Account__c = acc.Id,
                //pse__Practice__c = practice2.Id,
                Po_Number__c = '54764648',
                Deal__c = '54764648',
                DP__c = '54764648'
        );
        insert projectTemplate;

        pse__Practice__c practice = new pse__Practice__c(Name = 'Custom Practice Test', Order_Association_Approval_Phase__c = 'Execute');
        insert practice;

        List<Item_Class__c> itemClasses = [
                SELECT Id
                FROM Item_Class__c
                WHERE Practice__c = :practice.Id
                AND Item_Class_Description__c LIKE '%SVC EDT INSTLN%'
        ];

        if(itemClasses.size() == 0){

            Item_Class__c itemClass = new Item_Class__c();
            itemClass.Item_Class_Description__c = 'SVC EDT INSTLN';
            itemClass.Practice__c = practice.Id;
            itemClass.Key_Practice__c = true;
            insert itemClass;

        }



        return practice;
    }

    public static pse__Practice__c createPracticesItemClassAndISGTemplateForDeal(){

        Account acc = createSimpleAccount();
        pse__Proj__c projectTemplate = new pse__Proj__c(
                Name='ISG Phased Project Template - Custom - Global - For Deal',
                pse__Project_Type__c = 'Concession Delivery',
                pse__Is_Template__c = true,
                pse__Is_Active__c = true,
                pse__Start_Date__c = Date.today(),
                pse__Account__c = acc.Id,
                //pse__Practice__c = practice2.Id,
                Po_Number__c = '54764648',
                Deal__c = '54764648',
                DP__c = '54764648'
        );
        insert projectTemplate;

        pse__Practice__c practice = new pse__Practice__c(Name = 'Custom Practice Test', Order_Association_Approval_Phase__c = 'Execute');
        insert practice;

        List<Item_Class__c> itemClasses = [
                SELECT Id
                FROM Item_Class__c
                WHERE Practice__c = :practice.Id
                AND Item_Class_Description__c LIKE '%SVC EDT INSTLN%'
        ];

        if(itemClasses.size() == 0){

            Item_Class__c itemClass = new Item_Class__c();
            itemClass.Item_Class_Description__c = 'SVC EDT INSTLN';
            itemClass.Practice__c = practice.Id;
            itemClass.Key_Practice__c = true;
            insert itemClass;

        }



        return practice;
    }

    public static pse__Region__c newRegion(String name, String BUID, Boolean active)
    {
        pse__Region__c region = new pse__Region__c(
                Name = name,
                Active__c = active,
                ISO_Country_Code__c = BUID
        );
        return region;
    }

    public static pse__Region__c newRegionWithParent(String name, String BUID, Boolean active, Id parentId)
    {
        pse__Region__c region = new pse__Region__c(
                Name = name,
                Active__c = active,
                ISO_Country_Code__c = BUID,
                pse__Parent_Region__c = parentId
        );
        return region;
    }

    public static Group newGroup(String name, String devName) {
        Group newGroup = new Group(Name = name, DeveloperName = devName, Type = 'Queue');
        return newGroup;
    }

    public static Account createSimpleAccount(){
        // Create an account with prefilled fields
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        Account acc = newAccount('Account teste', '123');
         system.runAs(loginUser[0])
          {
           insert acc;
          }
        return acc;
    }

    public static Id contactRecordType = null;
    public static Contact createSimpleContact(){
        // Create a contact with prefilled fields

        if(contactRecordType == null){
            RecordType rt = [select Id,Name from RecordType 
                where sObjectType='Contact'
                and DeveloperName != 'Installation_Partner' limit 1];
            contactRecordType = rt.Id;
        }
         String randomNum = String.valueof((Math.random() * 100));
        // Added random numbers to avoid below error for order
        // System.DmlException: Insert failed. First exception on row 0; first error: DUPLICATES_DETECTED, You're creating a duplicate record. We recommend you use an existing record instead.
         String FirstName1='firstname'+randomNum;
         String LastName1='Lastname'+randomNum;
        Contact cnt = newContact(FirstName1, LastName1, 'Brazil', 'Sao Paulo','1235671007');
        cnt.RecordTypeId = contactRecordType;
        insert cnt;

        return cnt;
    }

    public static pse__Proj__c createSimpleProject(){
        // Create a project with prefilled fields

        Account acc = createSimpleAccount();

        pse__Proj__c project = createProject(acc.Id, '111','222','333');
        insert project;

        return project;
    }

    public static pse__Proj__c createSimpleProjectTemplate(){
        // Create a project with prefilled fields

        Account acc = createSimpleAccount();

        pse__Proj__c project = createProjectTemplate(acc.Id, '111','222','333');
        insert project;

        return project;
    }

    public static Order createSimpleOrderWithProjectToApproval(Id projectId, Id approver){
        // Create a order with prefilled fields

        Account acc = createSimpleAccount();

        Contact cnt = createSimpleContact();

        String randomOrderNumber = String.valueof((Math.random() * 1000000000));

        Order ord = newOrderWithItem(randomOrderNumber, acc.Id, cnt.Id, 'Brazil', 'Sao Paulo', 'Brazil', 'Sao Paulo',
                '1234567891', '', '', acc.Id, null, null, null, null, 'SVC EDT INSTLN', null, projectId, approver);

        return ord;
    }

    public static Order createSimpleOrderToProject(Id projectId){
        // Create a order with prefilled fields

        Account acc = createSimpleAccount();
          Id contactRecordType = null;
        //Contact cnt = createSimpleContact();
        if(contactRecordType == null){
            RecordType rt = [select Id,Name from RecordType 
                where sObjectType='Contact'
                and DeveloperName != 'Installation_Partner' limit 1];
            contactRecordType = rt.Id;
        }
        Contact cnt = newContact('FirstName0078', 'Lastname0078', 'Brazil', 'Sao Paulo','1235671007');
        cnt.RecordTypeId = contactRecordType;
        insert cnt;

        String randomOrderNumber = String.valueof((Math.random() * 1000000000));

        Order ord = newOrderWithItem(randomOrderNumber, acc.Id, cnt.Id, 'Brazil', 'Sao Paulo', 'Brazil', 'Sao Paulo',
                '1234567890', '', '', acc.Id, null, null, null, null, 'SVC EDT INSTLN', projectId);

        return ord;
    }

    public static Order createSimpleOrder(){
        // Create a order with prefilled fields

        Account acc = createSimpleAccount();
          
        Contact cnt = createSimpleContact();

        String randomOrderNumber = String.valueof((Math.random() * 1000000000));

        Order ord = newOrderWithItem(randomOrderNumber, acc.Id, cnt.Id, 'Brazil', 'Sao Paulo', 'Brazil', 'Sao Paulo',
                '1234567890', '', '', acc.Id, null, null, null, null, 'SVC EDT INSTLN');

        return ord;
    }

    public static SKU_Effort_Map__c createSkuEffortMap(List<String> skuList, Decimal duration, Boolean thirtyDays, Map<String, String> phaseByTask) {
        return createSkuEffortMap(skuList, duration, thirtyDays, phaseByTask, false);
    }
    public static SKU_Effort_Map__c createSkuEffortMap(List<String> skuList, Decimal duration, Boolean thirtyDays, Map<String, String> phaseByTask, Boolean distinct){

        /* Parameters:
        skuList: list of sku numbers that will belong the sku effort map - ['222-2222', '333-3333']
        duration: duration days of sku effort map
        thirtyDays: flag true/false to 30 days support
        phaseByTask: map with name of task by phase name: { 'Scoping':'Initiate', 'Configuration':'Execute'}
        */

        pse__Proj__c projectTemplate = createSimpleProjectTemplate();

        /*pse__Practice__c practice = [
                SELECT Id
                FROM pse__Practice__c
                LIMIT 1
        ];*/
         pse__Practice__c practice = new pse__Practice__c(Name = 'Custom Practice Test', Order_Association_Approval_Phase__c = 'Execute', Standard_Project_Template__c = projectTemplate.Id);

        // pse__Practice__c practice;
        // if(practices.size() == 0){
        //     practice = createPracticesItemClass();
        // }
        // else{
        //     practice = practices[0];
        // }

        SKU_Effort_Map__c skuEffortMap = new SKU_Effort_Map__c();
        skuEffortMap.Active__c = true;
        skuEffortMap.Description__c = 'Sku Effort Map Test - ' + skuList[0];
        skuEffortMap.Duration_Days__c = duration;
        skuEffortMap.X30_Day_Support__c = thirtyDays;
        skuEffortMap.Practice__c = practice.Id;
        skuEffortMap.Distinct_Project__c = distinct;
        insert skuEffortMap;

        List<SKU_Number__c> skuNumbersToInsert = new List<SKU_Number__c>();
        for(String sku: skuList){
            SKU_Number__c skuNumber = new SKU_Number__c();
            skuNumber.SKU_Number__c = sku;
            skuNumber.SKU_to_Effort_Mapping__c = skuEffortMap.Id;
            skuNumbersToInsert.add(skuNumber);
        }
        insert skuNumbersToInsert;

        Map<String, pse__Project_Task__c> phaseMap = new Map<String, pse__Project_Task__c>();
        for(String taskName: phaseByTask.keySet()){

            pse__Project_Task__c task = new pse__Project_Task__c();
            //task.RecordTypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('PSA_Task').getRecordTypeId();
            task.Name = phaseByTask.get(taskName);
            task.pse__Project__c = projectTemplate.Id;
            phaseMap.put(task.Name, task);

        }
        insert phaseMap.values();

        // Sku Effort Map Entries
        List<SKU_Effort_Map_Entry__c> entryToInsert = new List<SKU_Effort_Map_Entry__c>();
        for(String taskName: phaseByTask.keySet()){
            SKU_Effort_Map_Entry__c entry = new SKU_Effort_Map_Entry__c();
            entry.Name__c = taskName;
            entry.Phase__c = phaseMap.get(phaseByTask.get(taskName)).Id;
            entry.SKU_Effort_Map__c = skuEffortMap.Id;
            entry.Project_Complexity_Tier__c = 'Low';
            entry.Estimated_Hours__c = 10;
            entry.project__c = projectTemplate.Id;
            entryToInsert.add(entry);
        }
        insert entryToInsert;

        // Skill Sku Entry
        List<pse__Skill__c> existingSkills = [
                SELECT Id
                FROM pse__Skill__c
        ];

        if(existingSkills.size() == 0){

            List<pse__Skill__c> skillToInsert = new List<pse__Skill__c>();
            pse__Skill__c skill1 = new pse__Skill__c();
            skill1.Name = 'Skill Test 1';
            skill1.pse__External_Id__c = '32133';
            skillToInsert.add(skill1);

            pse__Skill__c skill2 = new pse__Skill__c();
            skill2.Name = 'Skill Test 2';
            skill2.pse__External_Id__c = '32134';
            skillToInsert.add(skill2);
            insert skillToInsert;
            existingSkills = skillToInsert;

        }

        List<Skill_SKU_Effort_Map_Entry__c> skillSkuEntriesToInsert = new List<Skill_SKU_Effort_Map_Entry__c>();
        for(SKU_Effort_Map_Entry__c entry: entryToInsert){
            // Create 2 skills sku to each entry
            for(pse__Skill__c skill: existingSkills){
                Skill_SKU_Effort_Map_Entry__c skillSkuEntry = new Skill_SKU_Effort_Map_Entry__c();
                skillSkuEntry.SKU_Effort_Map_Entry__c = entry.Id;
                skillSkuEntry.Skill_Certification__c = skill.Id;
                skillSkuEntry.Minimum_Rate__c = '5';
                skillSkuEntriesToInsert.add(skillSkuEntry);
            }
        }
        insert skillSkuEntriesToInsert;

        return skuEffortMap;

    }

    public static Order_Import_Queue__c createOrderImportQueue(Order order, pse__Proj__c project){
        Order_Import_Queue__c orderImportQueue = new Order_Import_Queue__c(
                BUID__c = order.BUID__c,
                Order_Number__c = order.OrderNumber__c,
                Project__c = project.Id
        );
        insert orderImportQueue;
        return orderImportQueue;
    }

    public static pse__Milestone__c newMilestone(Id projectId, String name) {
        pse__Milestone__c milestone = new pse__Milestone__c();
        milestone.name = name;
        milestone.pse__Project__c = projectId;
        milestone.pse__Target_Date__c = Date.today();
        milestone.Current__c = true;
        milestone.pse__Status__c = 'Open';
        return milestone;
    }

    public static OrderItemMilestoneAssociation__c newOrderItemMilestoneAssociation(Id orderItemId, Id milestoneId) {
        OrderItemMilestoneAssociation__c oima = new OrderItemMilestoneAssociation__c();
        oima.Order_Product__c = orderItemId;
        oima.Milestone__c = milestoneId;
        return oima;
    }
}