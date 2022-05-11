@isTest
public without sharing class FBE_Test_Utility {
    /* 
     * Method name :  createUser
     * Description :  This method is used to create User without any userrole assigned
     * Param       :  Profile name, Number of Users, String 
     * Returns     :  User
     */
    public static List < User > createUser(String prof, Integer NoOfUsers, String add) {
              Profile p = [SELECT Id FROM Profile WHERE Name =: prof];
        List < User > userLst = new List < User > ();
        for (Integer i = 0; i < NoOfUsers; i++) {
            User u = new User(Alias = 'st' + i + add, Email = 'a' + add + i + 'trfouser@testorg.com', LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing',EmployeeNumber='1234', LanguageLocaleKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'a' + add + i + 'trfouser@testorg.com');
            userLst.add(u);

        }
            insert userLst;
       // createServiceResource(1, userLst);
        return userLst;
    }
    /* 
     * Method name :  createAccount
     * Description :  This method is used to create Account 
     * Param       :  count of Accounts (Integer)
     * Returns     :  Account
     */
    public Static List < Account > createAccount(Integer Count) {
        List < Account > lacc = new List < Account > ();
        for (Integer i = 0; i < count; i++) {
            Account acc = new Account();
            acc.Name = 'Test Account';
            acc.FBE_Account_Class__c = 'Direct';
            acc.FBE_Status__c = 'Active';
            acc.FBE_Territory__c = 'FED SELECT';
            lacc.add(acc);
        }
        return lacc;
    }
        /* 
     * Method name :  createContact
     * Description :  This method is used to create Contact from an Account 
     * Param       :  count of Accounts (Integer), Account ID
     * Returns     :  Contacts
     * Modification Log: [07/15/2020] : Abhishek Kawle - Added record type 'Customer Contact' as part of changes related to IDS Feature #7868086
     * Modification Log: [08/23/2021] : Siva Kumar Valluru - Added Phone & Country Code as part of recent changes related to Quantam Feature #10483266.
     */
    public static List < Contact > createContact(Integer noOfRecords, Id AccountId) {
        List < Contact > contactList = new List < Contact > ();
        for (Integer count = 0; count < noOfRecords; count++) {
            Contact contactRecord = new Contact();
            contactRecord.firstName = 'TestFirstName'+'__'+count;
            contactRecord.lastName = 'TestLastName';
            contactRecord.Email = 'Test'+'__'+count+'@email.com';
            contactRecord.phone = '9876543210';
            contactRecord.Country_Code_CAM__c = '1';
            contactRecord.AccountId = AccountId;
            contactRecord.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('FBE_Customer_Contact').getRecordTypeId();
            contactList.add(contactRecord);
        }
        return contactList;
    }
           /* 
     * Method name :  Create Deal
     * Description :  This method is used to create Deal 
     * Param       :  count of Accounts (Integer), Account ID
     * Returns     :  Deals
     */
    public static List < Deal_Registration__c > createDeal(Integer count) {
        List < Deal_Registration__c > DealList = new List < Deal_Registration__c > ();
        for (Integer i = 0; i < count; i++) {
            Deal_Registration__c DealRecord = new Deal_Registration__c();
            DealRecord.Name = 'Test Deal';           
            DealRecord.FBE_Deal_Product_Classification__c = 'EMC Products';
           // DealRecord.FBE_Price_Book_Id__c = '01sr00000004tlYAAQ';
            DealRecord.FBE_Customer__c = '65000909';
            DealRecord.FBE_Deal_Reg_Partner_Direct__c = '65000909'+i;
            DealRecord.FBE_Solution_Domain__c = 'Business Solutions';
            DealList.add(DealRecord);
        }
        return DealList;
    }
 
           /* 
     * Method name :  Create Deal
     * Description :  This method is used to create Deal 
     * Param       :  count of Accounts (Integer), Account ID
     * Returns     :  Deals
     */
    public static List < Deal_Registration__c > createDealwithAccnt(Integer count,List<Account> laccnt) {
        List < Deal_Registration__c > DealList = new List < Deal_Registration__c > ();
        for (Integer i = 0; i < count; i++) {
            Deal_Registration__c DealRecord = new Deal_Registration__c();
            DealRecord.Name = 'Test Deal';           
            DealRecord.FBE_Deal_Product_Classification__c = 'EMC Products';
           // DealRecord.FBE_Price_Book_Id__c = '01sr00000004tlYAAQ';
            DealRecord.FBE_Customer__c = '65000909';
            DealRecord.FBE_Deal_Reg_Partner_Direct__c = '65000909'+i;
            DealRecord.FBE_Solution_Domain__c = 'Business Solutions';
            DealRecord.FBE_Account__c = laccnt[2].id;
            DealRecord.FBE_End_User_Account__c = laccnt[1].id;
            DealRecord.FBE_FSI_Account__c = laccnt[4].id;
            DealRecord.FBE_Reseller_VAR_Account__c = laccnt[3].id;
            DealRecord.FBE_Distributor_Account__c = laccnt[2].id;
            DealRecord.FBE_OEM_Account__c = laccnt[0].id;
            DealList.add(DealRecord);
        }
        return DealList;
    }
    
     /* 
     * Method name :  createDealProducts
     * Description :  This method is used to create Deal Products related to an opportunity 
     * Param       :  count of Deal Products (Integer), Deal ID, Product Id
     * Returns     : Deal Products/Line Items
     */
    public static List < Deal_Product__c > createDealProducts(Integer noOfRecords, Id DealId, Id ProductId) {
        List < Deal_Product__c > DealProdList = new List <  Deal_Product__c > ();
        for (Integer count = 0; count < noOfRecords; count++) {
            Deal_Product__c DealProdRecord = new  Deal_Product__c();
            DealProdRecord.Deal_Registration_Name__c = DealId;            
            DealProdRecord.FBE_Product__c = ProductId;
            DealProdList.add(DealProdRecord);
        }
        return DealProdList;
    }
    /* 
     * Method name :  createProducts
     * Description :  This method is used to create Products in Standard Price Book Entry
     * Param       :  count of Products (Integer), Opportunity ID
     * Returns     :  Products
     */
    
    public static List < Product2 > createProducts(Integer noOfRecords) {
        List < Product2 > ProdList = new List < Product2 > ();
        for (Integer count = 0; count < noOfRecords; count++) {
            Product2 ProdRecord = new Product2();
            ProdRecord.Name = 'ABC';
            ProdRecord.IsActive = True;
            ProdList.add(ProdRecord);
        }
        return ProdList;
    }
        /* 
     * Method name :  createStdPriceBookEntry
     * Description :  This method is used to create Products in Standard Price Book Entry
     * Param       :  count of Products (Integer), Opportunity ID
     * Returns     :  Products
     */
   /* public static List < Pricebook2 > createPriceBook(Integer noOfRecords) {
        List < Pricebook2 > priceBookList = new List < Pricebook2 > ();
        for (Integer count = 0; count < noOfRecords; count++) {
            Pricebook2 PBRecord = new Pricebook2();
            PBRecord.Name = 'Custom PB';
            PBRecord.IsActive = True;
            priceBookList.add(PBRecord);
        }
        return priceBookList;
    }*/
     /* 
     * Description :  This method is used to create Products in Standard Price Book Entry
     * Param       :  count of Products (Integer), Opportunity ID
     * Returns     :  Products
     * Method name :  createStdPriceBookEntry
     */
  /*  public static List < PricebookEntry > createStdPriceBookEntry(Integer noOfRecords, Id ProductId) {
        Id pricebookId = Test.getStandardPricebookId();
        List < PricebookEntry > priceBookEntryList = new List < PricebookEntry > ();
        for (Integer count = 0; count < noOfRecords; count++) {
            PricebookEntry PBEntryRecord = new PricebookEntry();
            PBEntryRecord.Product2Id = ProductId;
            PBEntryRecord.PriceBook2Id = pricebookId;
            PBEntryRecord.IsActive = True;
            PBEntryRecord.UnitPrice = 500;
            priceBookEntryList.add(PBEntryRecord);
        }
        return priceBookEntryList;
    }
        public static List < PricebookEntry > createCustomPriceBookEntry(Integer noOfRecords, Id ProductId) {
        Id pricebookId = Test.getStandardPricebookId();
        List < PricebookEntry > priceBookEntryList = new List < PricebookEntry > ();
        for (Integer count = 0; count < noOfRecords; count++) {

            

            PricebookEntry PBEntryRecord = new PricebookEntry();
            PBEntryRecord.Product2Id = ProductId;
            PBEntryRecord.PriceBook2Id = pricebookId;
            PBEntryRecord.IsActive = True;
            PBEntryRecord.UnitPrice = 500;
            priceBookEntryList.add(PBEntryRecord);
        }
        return priceBookEntryList;
        }*/
    /* 
     * Method name :  createOpportunity
     * Description :  This method is used to create Opportunity from an Account 
     * Param       :  count of Accounts (Integer), Account ID
     * Returns     :  Opportunity
     * Modification Log : [AK] 01/03/2019 - Added required fields to method
                          [AK] 01/08/2019 - Added required fields to method (FBE_Pursuit_Type__c)
     */

    public Static List < Opportunity > createOpportunity(Integer count, ID AccID) {
        List < Opportunity > lOppty = new List < Opportunity > ();
        for (Integer i = 0; i < count; i++) {
            Opportunity oppty = new Opportunity();
            oppty.Name = 'Test_Opportunity_'+ i;
            oppty.Accountid = AccID;
            oppty.FBE_FSI_Account__c = AccID;
            oppty.FBE_VAR_Seller__c = AccID;
            oppty.FBE_Distributor__c = AccID;
            oppty.FBE_Alliance_OEM_Provider__c = AccID;
            oppty.StageName = 'Plan - 1%';
            oppty.CloseDate = System.today();
            oppty.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            oppty.FBE_Opportunity_Classification__c ='Dell Products';
            oppty.FBE_Contracting_Status__c='Funded';
            oppty.FBE_Pursuit_Type__c = 'Direct';
           // oppty.Pricebook2Id = PriceBookId;
            lOppty.add(oppty);
        }
        return lOppty;
    }
    /* 
     * Method name :  createTask
     * Description :  This method is used to create Task related to an opportunity 
     * Param       :  count of Tasks (Integer), Opportunity ID
     * Returns     :  Tasks
     */
    public static List < Task > createTask(Integer noOfRecords, Id OpportunityId) {
        List < Task > taskList = new List < Task > ();
        for (Integer count = 0; count < noOfRecords; count++) {
            Task taskRecord = new Task();
            taskRecord.WhatId = OpportunityId;
            taskRecord.Type = 'DFS';
            taskRecord.FBE_Project_Type__c = 'RFx';
            taskRecord.FBE_End_Date_del__c = Date.Today();
            taskRecord.FBE_Primary_Work_Delivery_State_Province__c = 'abc';
            taskRecord.FBE_Primary_Work_Delivery_Country__c = 'IN';
            taskRecord.FBE_Unweighted_Rev_Services__c = 1000;
            taskList.add(taskRecord);
        }
        return taskList;
    }

    /* 
     * Method name :  createOpptyProducts
     * Description :  This method is used to create Opportunity Products related to an opportunity 
     * Param       :  count of Products (Integer), Opportunity ID
     * Returns     :  Opportunity Products/Line Items
     */
    public static List < OpportunityLineItem > createOpptyProducts(Integer noOfRecords, Id OpportunityId, Id ProductId) {
        List < OpportunityLineItem > OpptyProdList = new List < OpportunityLineItem > ();
        for (Integer count = 0; count < noOfRecords; count++) {
            OpportunityLineItem OpptyProdRecord = new OpportunityLineItem();
            OpptyProdRecord.OpportunityId = OpportunityId;
            //OpptyProdRecord.Product2Id = ProductId;
            //OpptyProdRecord.PriceBookEntryId = PbEntryId;
            OpptyProdRecord.Quantity = 5;
            OpptyProdRecord.TotalPrice = 500;
            OpptyProdList.add(OpptyProdRecord);
        }
             return OpptyProdList;
    }
    /* 
     * Method name :  createRoles
     * Description :  This method is used to create Roles
     * Param       :  count of Roles (Integer), 
     * Returns     :  Products
     */
    
    public static List < UserRole > createRoles(Integer noOfRecords) {
        List < UserRole > roleList = new List < UserRole > ();
        for (Integer count = 0; count < noOfRecords; count++) {
            UserRole uRole = new UserRole();
            uRole.Name = 'Role_'+count;
            roleList.add(uRole);
        }
        return roleList;
    }
    
    /* 
     * Method name :  createLead
     * Description :  This method is used to create Leads
     * Param       :  count of Leads(Integer), 
     * Returns     :  Leads
     */
    public static List<Lead> createLead(Integer noOfRecords, String leadType){
        List<Lead> leadList = new List<Lead>();
        List<Campaign> campaignList = FBE_Test_Utility.createCampaign(1);
        insert campaignList;
        for (Integer count = 0; count < noOfRecords; count++) {
            Lead leadRecord = new Lead();
            leadRecord.Company = 'Company_'+count;
            leadRecord.FirstName='Lead_';
            leadRecord.LastName= String.valueOf(count);
            leadRecord.FBE_Lead_Type__c=leadType;
            leadRecord.Email = 'abc@abc.com';
            if(leadType == 'Outbound'){
                leadRecord.FBE_Sales_Role__c = 'SR';
            }
            
            if(!campaignList.isEmpty()){
                //Yogesh - part of code refactoring removed insert campaign statment from loop
                leadRecord.FBE_Campaign__c = campaignList[0].Id;
            }
            leadList.add(leadRecord);
        }
        return leadList;     
    }

    /* 
     * Method name :  createCampaign
     * Description :  This method is used to create Campaigns
     * Param       :  count of Campaign(Integer), 
     * Returns     :  Campaigns
     */    
    public static List<Campaign> createCampaign(Integer noOfRecords){
        List<Campaign> campaignList = new List<Campaign>();
        for (Integer count = 0; count < noOfRecords; count++) {
            Campaign campaignRecord = new Campaign();
            campaignRecord.Name='Campaign_'+count;
            campaignRecord.StartDate = Date.Today();
            campaignRecord.EndDate = Date.Today()+10;
            campaignRecord.FBE_Funnel_Objective__c = 'Awareness';
            campaignRecord.FBE_Parent_Vehicle__c = 'Content Development';
            campaignRecord.FBE_Campaign_Vehicle__c = 'Account Intelligence';
            campaignRecord.FBE_Sub_Region__c = 'US';
            campaignRecord.FBE_Follow_up__c = 'Account Executive';
            campaignRecord.FBE_Secondary_Role__c = 'Account Executive';
            campaignRecord.FBE_Route_To_Market__c = 'Dell-to-Market';
            campaignList.add(campaignRecord);
        }
        return campaignList;
    }
    
    /* 
     * Method name :  createWorkload
     * Description :  This method is used to create Workloads
     * Param       :  count of Workload(Integer), 
     * Returns     :  Workloads
     */    
    public static List<FBE_Workloads__c> createWorkload(Integer noOfRecords, String accountId){
        List<FBE_Workloads__c> wrkldList = new List<FBE_Workloads__c>();
        for (Integer count = 0; count < noOfRecords; count++) {
            FBE_Workloads__c wrkldRecord = new FBE_Workloads__c();
            wrkldRecord.FBE_Account__c = accountId;
            wrkldList.add(wrkldRecord);
        }
        return wrkldList;
    }
    
    /* 
     * Method name :  createOptywithAccounts
     * Description :  This method is used to create Opportunity from an Account 
     * Param       :  count of Accounts (Integer), List<Account>
     * Returns     :  Opportunity
     * Modification Log : 
     */

    public Static List < Opportunity > createOptywithAccounts(Integer count, List<Account> lacnt) {
        List < Opportunity > lOppty = new List < Opportunity > ();
        for (Integer i = 0; i < count; i++) {
            Opportunity oppty = new Opportunity();
            oppty.Name = 'Test_Opportunity_'+ i;
            oppty.Accountid = lacnt[2].Id;
            oppty.FBE_End_User__c = lacnt[1].id;
            oppty.FBE_FSI_Account__c = lacnt[3].Id;
            oppty.FBE_VAR_Seller__c = lacnt[4].Id;
            oppty.FBE_Distributor__c = lacnt[1].Id;
            oppty.FBE_Alliance_OEM_Provider__c = lacnt[0].Id;
            oppty.StageName = 'Plan - 1%';
            oppty.CloseDate = System.today();
            oppty.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            oppty.FBE_Opportunity_Classification__c ='Dell Products';
            oppty.FBE_Contracting_Status__c='Funded';
            oppty.FBE_Pursuit_Type__c = 'Direct';
           // oppty.Pricebook2Id = PriceBookId;
            lOppty.add(oppty);
        }
        return lOppty;
    }

    /* 
     * Method name :  createOrder
     * Description :  This method is used to create Orders
     * Param       :  count of Orders(Integer) to be created
     * Returns     :  List of Orders
     */ 
    public static List<Order> createOrder(Integer count){
        List<Order> orderList = new List<Order>();
        
        List<Account> accountList = createAccount(1);
        insert accountList;
        for(Integer i=0; i<count; i++){
            Order eachOrder = new Order(
                OrderNumber__c = '1231'+i,
                EffectiveDate = System.today(),
                AccountId = accountList[0].id,
                CurrencyIsoCode = 'USD',
                Status = 'BK',
                BUID__c = '11'
            );
            orderList.add(eachOrder);
        }
        
        return orderList;
        
    }
    
    /* 
     * Method name :  createOperatingHours
     * Description :  This method is used to create OperatingHours
     * Returns     :  List of OperatingHours
     */
    public static List<OperatingHours> createOperatingHours(){
        List<OperatingHours> ohList = new List<OperatingHours>();
        OperatingHours oh = new OperatingHours();
        oh.Name = 'PDT';
        oh.TimeZone = 'America/Los_Angeles';
        ohList.add(oh);
        return ohList;
    }
    
     /* 
     * Method name :  createServiceTerritory
     * Description :  This method is used to create ServiceTerritory
     * Returns     :  List of ServiceTerritory
     */
    public static List<ServiceTerritory> createServiceTerritory(List<OperatingHours> ohList){
        List<ServiceTerritory> stList = new List<ServiceTerritory>();
        ServiceTerritory st = new ServiceTerritory();
        st.Name = 'PDT 2';
        st.IsActive = true;
        st.OperatingHoursId = ohList[0].Id;
        stList.add(st);
        return stList;
    }
    
    
    /* 
     * Method name :  createServiceTerritoryMember
     * Description :  This method is used to create ServiceTerritoryMember
     * Returns     :  List of ServiceTerritoryMember
     */
    public static List<ServiceTerritoryMember> createServiceTerritoryMember(List<ServiceTerritory> stList, List<ServiceResource> srList){
        List<ServiceTerritoryMember> stmList = new List<ServiceTerritoryMember>();
        ServiceTerritoryMember stm = new ServiceTerritoryMember();
        stm.ServiceResourceId = srList[0].Id;
        stm.ServiceTerritoryId = stList[0].Id;
        stm.TerritoryType = 'P';
        stm.EffectiveStartDate = System.Today();
        stmList.add(stm);
        return stmList;
    }
    
    
    
     /* 
     * Method name :  createPractice
     * Description :  This method is used to create practice
     * Returns     :  List of practice
     */
    
    public static List<pse__Practice__c> createPractice(){
        TriggerHandler.bypass(FFProjectTriggerHandler.class.getName());
                pse__Proj__c projectTemplate = new pse__Proj__c(
                        Name='Phased Project Template - Custom - Global',
                        pse__Is_Template__c = true,
                        pse__Is_Active__c = true,
                        pse__Start_Date__c = Date.today(),
                        Po_Number__c = '54764648',
                        Deal__c = '54764648',
                        DP__c = '54764648'
                );
                insert projectTemplate;
                TriggerHandler.clearByPass(FFProjectTriggerHandler.class.getName());
        List<pse__Practice__c> practiceList = new List<pse__Practice__c>();
        pse__Practice__c practice = new pse__Practice__c();
        practice.Name= 'Global Practice';
        practice.CurrencyIsoCode = 'USD';
        practice.Standard_Project_Template__c = projectTemplate.Id;
        practiceList.add(practice);
        return practiceList;
    }
    
        /* 
     * Method name :  createServiceResource
     * Description :  This method is used to create ServiceResource 
     * Param       :  count of ServiceResource (Integer)
     * Returns     :  ServiceResource
     */
    
    public static List<ServiceResource> createServiceResource(Integer count, List<User> userList){
        List<ServiceResource> srList = new List<ServiceResource>();
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true Limit 1];
        for(Integer i=0; i<count; i++){
            ServiceResource sr = new ServiceResource();
            sr.Name = 'Test Contact One';
            sr.IsActive = true;
            sr.ResourceType = 'T';
            sr.RelatedRecordId = loginUser[0].Id;
            srList.add(sr);
        }
      //  insert srList;
        return srList;
        
    }
                /* 
     * Method name :  createResourceAbsence
     * Description :  This method is used to create ResourceAbsence 
     * Param       :  count of ResourceAbsence (Integer)
     * Returns     :  ResourceAbsence
     */
    
    public static List<ResourceAbsence> createResourceAbsence(Integer count, List<ServiceResource> srList){
        List<ResourceAbsence> raList = new  List<ResourceAbsence>();
        for(Integer i=0; i<count; i++){
            ResourceAbsence raObj = new ResourceAbsence();
            raObj.ResourceId = srList[0].Id;
            raObj.Start = System.today();
            raObj.End = System.today() +5;
            raObj.Type = 'Vacation';
            raList.add(raObj); 
        }
        return raList;
        
    }
    
            /* 
     * Method name :  createProject
     * Description :  This method is used to create Project 
     * Param       :  count of Project (Integer)
     * Returns     :  Project
     */
    
    public static List<pse__Proj__c> createProject(Integer count){
        List<pse__Proj__c> projList = new List<pse__Proj__c>();
        Id projectRecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('Small Project Tier').getRecordTypeId();
 
        for(Integer i=0; i<count; i++){
            pse__Proj__c proj = new pse__Proj__c();
            proj.Name ='Test Project';
            proj.CurrencyIsoCode = 'USD';
            proj.Project_Visibility__c = 'ALL';
            proj.Reason_Not_To_Survey__c ='Survey Project';
           // proj.pse__Account__c = accountList[0].Id; 
            proj.RecordTypeId = projectRecordTypeId;
            //proj.pse__Closed_for_Time_Entry__c = false;
            proj.pse__Is_Active__c = true;
            proj.pse__Is_Billable__c = true;
            Proj.pse__Start_Date__c = System.today();
            Proj.pse__End_Date__c = System.today().addDays(30);
            projList.add(proj);
        }
        return projList;
        
    }
    
     /* 
     * Method name :  createProjectTask
     * Description :  This method is used to create Project Task
     * Param       :  count of Project Task (Integer)
     * Returns     :  Project Task
     */
    
    public static List<pse__Project_Task__c> createProjectTask(Integer count, List<pse__Proj__c> projList){
        List<pse__Project_Task__c> ptList = new List<pse__Project_Task__c>();
        for(Integer i=0; i<=count; i++){
        pse__Project_Task__c pt = new pse__Project_Task__c();
        pt.Name = 'Test';
        pt.pse__Project__c = projList[0].Id;
        ptList.add(pt);  
        }
        return ptList;
    }
    
     /* 
     * Method name :  createGlobalProject
     * Description :  This method is used to create Global Project 
     * Param       :  count of ServiceResource (Integer)
     * Returns     :  Project
     */
    
    public static List<pse__Proj__c> createGlobalProject(Integer count){
        List<pse__Proj__c> projList = new List<pse__Proj__c>();
        Id projectRecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('Small Project Tier').getRecordTypeId();
 
        for(Integer i=0; i<count; i++){
            pse__Proj__c proj = new pse__Proj__c();
            proj.Name ='Vacation';
            proj.CurrencyIsoCode = 'USD';
            proj.Project_Visibility__c = 'ALL';
            proj.Reason_Not_To_Survey__c ='Survey Project';
           // proj.pse__Account__c = accountList[0].Id; 
            proj.RecordTypeId = projectRecordTypeId;
            proj.pse__Is_Active__c = true;
            proj.pse__Is_Billable__c = true;
            proj.pse__Allow_Timecards_Without_Assignment__c = true;
            projList.add(proj);
        }
        return projList;
        
    }
     /* 
     * Method name :  createSchedule
     * Description :  This method is used to create Schedule 
     * Param       :  count of Schedule (Integer)
     * Returns     :  Schedule
     */ 
    public static List<pse__Schedule__c> createSchedule(Integer count){
        List<pse__Schedule__c> scheduleList = new List<pse__Schedule__c>();
        for(Integer i=0; i<=count; i++){
            pse__Schedule__c sc = new pse__Schedule__c();
            sc.pse__Start_Date__c = System.today();
            sc.pse__End_Date__c = System.today() +6;
            sc.pse__Monday_Hours__c = 0;
            sc.pse__Tuesday_Hours__c = 0;
            sc.pse__Wednesday_Hours__c = 0;
            sc.pse__Thursday_Hours__c = 0;
            sc.pse__Friday_Hours__c = 0;
            sc.pse__Saturday_Hours__c = 0;
            sc.pse__Sunday_Hours__c = 0;
            scheduleList.add(sc);
        }
        return scheduleList;
    }
    
      /* 
     * Method name :  createAssignment
     * Description :  This method is used to create Assignment 
     * Param       :  count of Assignment (Integer)
     * Returns     :  Assignment
     */
    
    public static List<pse__Assignment__c> createAssignment(Integer count, List<Contact> conList,List<pse__Proj__c> projList, List<pse__Schedule__c>scheduleList, List<pse__Rate_Card__c> rateCardList){
        List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
        for(Integer i=0; i<=count; i++){
            pse__Assignment__c  assignment = new pse__Assignment__c ();
            assignment.pse__Project__c = projList[0].Id;
            assignment.Name ='Test Assignmnet';
            assignment.pse__Role__c = 'Project Manager Sr. Advisor';
            assignment.pse__Resource__c = conList[0].Id;
            assignment.CurrencyIsoCode = 'USD';
            assignment.pse__Schedule__c = scheduleList[0].Id;
            assignment.pse__Bill_Rate__c =0;
            assignment.pse__Cost_Rate_Amount__c =0;
            if(rateCardList != NULL && rateCardList.size() > 0){
                assignment.pse__Rate_Card__c = rateCardList[0].id;
            }
            assignmentList.add(assignment);
        }
        return assignmentList;
        
    }
    
 
         /* 
     * Method name :  createRateCard
     * Description :  This method is used to create Rate Card 
     * Param       :  count of Rate Card (Integer)
     * Returns     :  Rate Card
     */ 
    
    public static List<pse__Rate_Card__c> createRateCard(Integer count){
        List<pse__Rate_Card__c> rcList = new List<pse__Rate_Card__c>(); 
         for(Integer i=0; i<=count; i++){
          pse__Rate_Card__c rc = new pse__Rate_Card__c();
             rc.pse__Role__c = 'Project Manager Advisor';
             rc.pse__Suggested_Bill_Rate__c = 83300;
             rc.pse__Average_Cost_Rate__c = 83;
             rcList.add(rc);
             
         }
         return rcList;
    }
    
         /* 
     * Method name :  createPermissionControlForPractice
     * Description :  This method is used to create PermissionControl 
     * Param       :  count of PermissionControl (Integer)
     * Returns     :  PermissionControl
     */

    public static List<pse__Permission_Control__c> createPermissionControlForPractice(Integer count, List<pse__Practice__c> practiceList, List<User>userList){
        List<pse__Permission_Control__c> pcList = new List<pse__Permission_Control__c>();
        for(Integer i=0; i<=count; i++){
            pse__Permission_Control__c pc = new pse__Permission_Control__c();
            pc.pse__User__c = userList[0].Id;
            if(practiceList!=NULL && practiceList.size()>0)
            pc.pse__Practice__c =practiceList[0].Id;
            pc.pse__Staffing__c = true; 
            pc.pse__Timecard_Entry__c   = true;
            pc.pse__Resource_Request_Entry__c =true;
            pc.pse__Cascading_Permission__c = true;
            pc.pse__Start_Date__c = System.today();
            pc.pse__Skills_And_Certifications_Entry__c = true;
            pc.pse__Skills_And_Certifications_View__c = true;
            pc.pse__Create_Project_Version__c = true;
            pc.pse__Timecard_Entry__c = true;
            pc.pse__Team_Create__c = true;
            pc.pse__Team_Edit__c = true;
            pc.pse__Team_View__c = true;
            pc.pse__Timecard_Ops_Edit__c = true;
                
            pcList.add(pc);    
        }
        return pcList;
    }
     /* 
     * Method name :  createPermissionControlForResource
     * Description :  This method is used to create PermissionControl 
     * Param       :  count of PermissionControl (Integer)
     * Returns     :  PermissionControl
     */

    public static List<pse__Permission_Control__c> createPermissionControlForResource(Integer count, List<Contact> conList, List<User>userList){
        List<pse__Permission_Control__c> pcList = new List<pse__Permission_Control__c>();
        for(Integer i=0; i<=count; i++){
            pse__Permission_Control__c pc = new pse__Permission_Control__c();
            pc.pse__User__c = userList[0].Id;
            pc.pse__Resource__c = conList[0].Id;
            pc.pse__Staffing__c = true; 
            pc.pse__Resource_Request_Entry__c   = true;
            pc.pse__Resource_Request_Entry__c =true;
            pc.pse__Timecard_Entry__c =true;
            pcList.add(pc);    
        }
        return pcList;
    } 
    
    /*
     * Method name :  createPermissionControlForProject
     * Description :  This method is used to create PermissionControl 
     * Param       :  count of PermissionControl (Integer)
     * Returns     :  PermissionControl
     */

    public static List<pse__Permission_Control__c> createPermissionControlForProject(Integer count, List<pse__Proj__c> projList, List<User> userList){
        List<pse__Permission_Control__c> pcList = new List<pse__Permission_Control__c>();
        for(Integer i=0; i<=count; i++){
            pse__Permission_Control__c pc2 = new pse__Permission_Control__c();    
            pc2.pse__User__c = userList[0].Id;
            pc2.pse__Project__c = projList[0].Id;
            pc2.pse__Staffing__c = true;
            pc2.pse__Timecard_Entry__c  = true;
            pc2.pse__Resource_Request_Entry__c =true;
            pcList.add(pc2);    
        }
        return pcList;
    } 
     /* 
     * Method name :  createWorkOrder
     * Description :  This method is used to create WorkOrder 
     * Param       :  count of WorkOrder (Integer)
     * Returns     :  WorkOrder
     */  
    
    public static List<WorkOrder> createWorkOrder(Integer count, List<pse__Project_Task__c>ptList){
        List<WorkOrder> woList = new List<WorkOrder>();
        Id workOrderRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Installation Badge').getRecordTypeId();
        
        for(Integer i=0; i<count; i++){
            WorkOrder wo = new WorkOrder();
            wo.RecordTypeId = workOrderRecordTypeId;
            wo.CurrencyIsoCode = 'USD';
            wo.Project_Task__c = ptList[0].Id;
            woList.add(wo);
        }
        return woList;
    }
    
         /* 
     * Method name :  createServiceAppointment
     * Description :  This method is used to create ServiceAppointment 
     * Param       :  count of ServiceAppointment (Integer)
     * Returns     :  ServiceAppointment
     */  
    
    public static List<ServiceAppointment> createServiceAppointment(Integer count, List<WorkOrder> woList, List<pse__Assignment__c> assignmentList, List<Contact> contactList, List<pse__Proj__c> projList){
        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        Id appointmentRecordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
        for(Integer i=0; i<count; i++){
            ServiceAppointment sa = new ServiceAppointment();
            sa.EarliestStartTime = System.today();
            sa.DueDate = System.today() +10;
           // sa.ParentRecordId = accountList[0].Id;
            sa.Assignee__c = contactList[0].id;
            sa.Work_Order__c = woList[0].Id;
            sa.ParentRecordId = woList[0].Id;
            sa.RecordTypeId = appointmentRecordTypeId;
            sa.Assignment__c = assignmentList[0].Id;
            sa.Project__c = ProjList[0].Id;
            sa.Status = 'New';
            sa.SchedStartTime = System.today().addDays(1);
            sa.SchedEndTime = System.today().addDays(7);
            saList.add(sa);
        }
        return saList;
    }
    
    /* 
     * Method name :  createAssignedResource
     * Description :  This method is used to create Assigned Resource 
     * Param       :  count of AssignedResource (Integer)
     * Returns     :  AssignedResource
     */
    
    public static List<AssignedResource> createAssignedResource(Integer Count,List<ServiceAppointment> saList, List<ServiceResource>srList){
        List<AssignedResource> arList = new List<AssignedResource>();
         for(Integer i=0; i<Count; i++){
             AssignedResource ar = new AssignedResource();
             ar.ServiceAppointmentId = saList[0].Id;
             ar.ServiceResourceId = srList[0].Id;
             arList.add(ar);
           }
        return arList;
    }
    
     /* 
     * Method name :  createTimeSheetForAbsence
     * Description :  This method is used to create TimeSheet 
     * Param       :  count of TimeSheet (Integer)
     * Returns     :  TimeSheet
     */
    
    public static List<TimeSheet> createTimeSheetForAbsence(Integer Count, List<ServiceResource>srList, List<pse__Proj__c>projectList){
        List<TimeSheet> tsList = new List<TimeSheet>();
         for(Integer i=0; i<=Count; i++){
             TimeSheet ts = new TimeSheet();
             ts.StartDate = (System.today()).addDays(i);
             ts.EndDate = (System.today()).addDays(i+1) ;
             ts.ServiceResourceId = srList[0].Id; 
             ts.Status = 'New';
             ts.FBE_Project__c = projectList[0].Id;
             tsList.add(ts);
           }
        return tsList;
    }
    
     /* 
     * Method name :  createTimeSheet
     * Description :  This method is used to create TimeSheet 
     * Param       :  count of TimeSheet (Integer)
     * Returns     :  TimeSheet
     */
    
    public static List<TimeSheet> createTimeSheet(Integer Count, List<ServiceResource> srList, List<ServiceAppointment> saList){
        List<TimeSheet> tsList = new List<TimeSheet>();
         for(Integer i=0; i<=Count; i++){
             TimeSheet ts = new TimeSheet();
             ts.StartDate = (System.today()).addDays(i);
             ts.EndDate = (System.today()).addDays(i) ;
             ts.ServiceResourceId = srList[0].Id; 
             ts.FBE_Service_Appointment__c =saList[0].Id;
             ts.Status = 'New';
             tsList.add(ts);
           }
        return tsList;
    }
    
      /* 
     * Method name :  createTimeSheetEntry
     * Description :  This method is used to create TimeSheetEntry 
     * Param       :  count of TimeSheetEntry (Integer)
     * Returns     :  TimeSheetEntry
     */
    
    public static List<TimeSheetEntry> createTimeSheetEntry(List<TimeSheet> tsList){
        List<TimeSheetEntry> tseList = new List<TimeSheetEntry>();
        for(TimeSheet ts: tsList){
            Time myTime = Time.newInstance(8, 0, 0, 0);
            Time myTime2 = Time.newInstance(16, 0, 0, 0);
            TimeSheetEntry objTSE = new TimeSheetEntry();
            objTSE.TimeSheetId = ts.Id;
            objTSE.StartTime =  DateTime.newInstance(ts.StartDate, myTime);
            objTSE.EndTime = DateTime.newInstance(ts.EndDate, myTime2);
            tseList.add(objTSE);         
        } 
        return tseList;
    }
    
     /* 
     * Method name :  createTimeCard
     * Description :  This method is used to create TimeCard 
     * Param       :  count of TimeCard (Integer)
     * Returns     :  TimeCard
     */
    
    public static List<pse__Timecard_Header__c> createTimeCard(Integer count, List<Contact> contactList, List<pse__Proj__c>proList, List<pse__Assignment__c> assignmentList){
        List<pse__Timecard_Header__c> tcList = new List<pse__Timecard_Header__c>();
        for(Integer i=0; i<=count; i++){
            pse__Timecard_Header__c tc = new pse__Timecard_Header__c();
            tc.pse__Start_Date__c = System.today();
            tc.pse__End_Date__c = System.today() +6;
            tc.pse__Resource__c = contactList[0].Id;
            tc.pse__Project__c = proList[0].Id;
            tc.CurrencyIsoCode = 'USD';
            tc.pse__Assignment__c = assignmentList[0].Id;
            tc.pse__Monday_Hours__c = 1;
            tc.pse__Tuesday_Hours__c = 1;
            tc.pse__Wednesday_Hours__c = 1;
            tc.pse__Thursday_Hours__c = 1;
            tc.pse__Friday_Hours__c = 1;
            tc.pse__Saturday_Hours__c = 1;
            tc.pse__Sunday_Hours__c = 1;
            tcList.add(tc);
                
        }
        return tcList;
    }
    
      /* 
     * Method name :  createTaskTime
     * Description :  This method is used to create TaskTime 
     * Param       :  count of TaskTime (Integer)
     * Returns     :  TaskTime
     */
    
    public static List<pse__Task_Time__c> createTaskTime(Integer count, List<pse__Timecard_Header__c> tcList, List<pse__Project_Task__c> ptList){
        List<pse__Task_Time__c> ttList = new List<pse__Task_Time__c>();
        for(Integer i=0; i<=count; i++){
            pse__Task_Time__c tt = new pse__Task_Time__c();
            tt.pse__Timecard__c = tcList[0].Id;
            tt.pse__Project_Task__c = ptList[0].Id;
            tt.CurrencyIsoCode = 'USD';
            tt.pse__Monday_Hours__c = 1;
            tt.pse__Tuesday_Hours__c = 1;
            tt.pse__Wednesday_Hours__c = 1;
            tt.pse__Thursday_Hours__c = 1;
            tt.pse__Friday_Hours__c = 1;
            tt.pse__Saturday_Hours__c = 1;
            tt.pse__Sunday_Hours__c = 1;
            ttList.add(tt);
        }
        return ttList;
    }
    
    public static void createTransferDealCheckCustomSetting(Boolean transferDeal){
        Profile adminProfile = [Select Id,Name from profile where Name='System Administrator' limit 1];      
        List<FBE_FPRM_Transfer_Deal_Check__c> customSettingList = new List<FBE_FPRM_Transfer_Deal_Check__c>();            
        FBE_FPRM_Transfer_Deal_Check__c transferDealCS = new FBE_FPRM_Transfer_Deal_Check__c(
            SetupOwnerId = adminProfile.Id, Name = 'Test',Is_Transfer_Deal__c = transferDeal); 
        customSettingList.add(transferDealCS);                     
        INSERT customSettingList;
    }
}