// Cretaed this class as part of Story 8910255: Internal Tech Debt : SFDC - Optimize the existing test class
// the methods containing this class used to build set up data related Objects which are mainily used in Sales.

public class FBE_UtilityFactory_Test {
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
     * Method name :  createUser
     * Description :  This method is used to create User without any userrole assigned
     * Param       :  Profile name, Number of Users, String 
     * Returns     :  User
     */
    
    public static List < User > createUser(String prof, Integer NoOfUsers, String add , String userRole) {
       // Tech Debt - added UserRole
        Profile p = [SELECT Id FROM Profile WHERE Name =: prof];
        Id userRoleId;
        if(userRole != NULL){
            userRoleId = [SELECT id FROM UserRole WHERE Name=:userRole].Id;
        }
        List < User > userLst = new List < User > ();
        for (Integer i = 0; i < NoOfUsers; i++) {
            User u = new User(Alias = 'st' + i + add, Email = 'a' + add + i + 'trfouser@testorg.com', LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing',EmployeeNumber='1234', LanguageLocaleKey = 'en_US', ProfileId = p.Id,UserRoleId=userRoleId,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'a' + add + i + 'trfouser@testorg.com'
                             /*
                              FederationIdentifier='testsvcFBE_SBL@dell.com',Federal_User__c=false,Federal_Access__c=false,
                         Dell_NTUserID__c='TESTNT', File_Source__c='WorkDay', OSP__c='Yes', Service_User_Type__c='DEV'
                            */);
            userLst.add(u);

        }
        insert userLst;
        return userLst;
    }
  
    
    /* 
     * Method name :  createAccount
     * Description :  This method is used to create Account 
     * Param       :  count of Accounts (Integer)
     * Returns     :  Account
     */
    public Static List < Account > createAccount(Integer Count , String actType) {
        // Tech Debt - added actType
        List < Account > lacc = new List < Account > ();
        for (Integer i = 0; i < count; i++) {
            Account acc = new Account();
            acc.Name = 'Test Account'+i;
            acc.FBE_Account_Class__c = 'Direct';
            acc.FBE_Status__c = 'Active';
            acc.Type = actType;
            /*acc.FBE_Territory__c = 'FED SELECT';*/
            lacc.add(acc);
        }
        return lacc;
    }
        /* 
     * Method name :  createContact
     * Description :  This method is used to create Contact from an Account 
     * Param       :  count of Accounts (Integer), Account ID
     * Returns     :  Contacts
     */
    public static List < Contact > createContact(Integer noOfRecords, Id AccountId) {
        // Tech Debt - updated indexes
        List < Contact > contactList = new List < Contact > ();
        for (Integer count = 0; count < noOfRecords; count++) {
            Contact contactRecord = new Contact();
            contactRecord.firstName = count+ ' TestFirstName';
            contactRecord.lastName = count+ ' TestLastName';
            contactRecord.Email = 'Test'+count +'@email.com';
            contactRecord.Phone = '9999999999';
            contactRecord.AccountId = AccountId;
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
            DealRecord.Name = 'Test Deal'+i;           
            DealRecord.FBE_Deal_Product_Classification__c = 'EMC Products';
           // DealRecord.FBE_Price_Book_Id__c = '01sr00000004tlYAAQ';
            DealRecord.FBE_Customer__c = '65000909';
            DealRecord.FBE_Deal_Reg_Partner_Direct__c = '65000909'+i;
            DealRecord.FBE_Solution_Domain__c = 'Business Solutions';
            DealList.add(DealRecord);
        }
        return DealList;
    }
 
    // Tech Debt - new method
    public static User getIntegrationUser(){
        return [SELECT Id FROM User WHERE FBE_Integration_User__c = true limit 1];
    }
    
    
    // Tech debt - new method
    public static List < Deal_Registration__c > createDealwithAccnt(Integer count,Id actId, Id euActId, Id fsIActId, Id resVarActId, Id distiActId, Id oemAcntId) {
        List < Deal_Registration__c > DealList = new List < Deal_Registration__c > ();
        for (Integer i = 0; i < count; i++) {
            Deal_Registration__c DealRecord = new Deal_Registration__c();
            DealRecord.Name = 'Test Deal';           
            DealRecord.FBE_Deal_Product_Classification__c = 'EMC Products';
           // DealRecord.FBE_Price_Book_Id__c = '01sr00000004tlYAAQ';
            DealRecord.FBE_Customer__c = '65000909';
            DealRecord.FBE_Deal_Reg_Partner_Direct__c = '65000909'+i;
            DealRecord.FBE_Solution_Domain__c = 'Business Solutions';
            DealRecord.FBE_Account__c = actId;
            DealRecord.FBE_End_User_Account__c = euActId;
            DealRecord.FBE_FSI_Account__c = fsIActId;
            DealRecord.FBE_Reseller_VAR_Account__c = resVarActId;
            DealRecord.FBE_Distributor_Account__c = distiActId;
            DealRecord.FBE_OEM_Account__c = oemAcntId;
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
     * Method name :  createOpportunity
     * Description :  This method is used to create Opportunity from an Account 
     * Param       :  count of Accounts (Integer), Account ID
     * Returns     :  Opportunity
     * Modification Log : [AK] 01/03/2019 - Added required fields to method
                          [AK] 01/08/2019 - Added required fields to method (FBE_Pursuit_Type__c)
     */

    public Static List < Opportunity > createOpportunity(Integer count,Id actId, Id euActId, Id fsIActId, Id resVarActId, Id distiActId, Id oemAcntIdD) {
        //tech debt - updated account params
        List < Opportunity > lOppty = new List < Opportunity > ();
        for (Integer i = 0; i < count; i++) {
            Opportunity oppty = new Opportunity();
            oppty.Name = 'Test_Opportunity_'+ i;
            oppty.Accountid = actId;
             oppty.FBE_End_User__c = euActId;
            oppty.FBE_FSI_Account__c = fsIActId;
            	if(fsIActId == null || fsIActId == '' ) oppty.FBE_FSI_Not_Applicable__c =true;
            oppty.FBE_VAR_Seller__c = resVarActId;
            	if(resVarActId == null || resVarActId == '' ) oppty.FBE_Reseller_VAR_Not_Applicable__c =true;
            oppty.FBE_Distributor__c = distiActId;
            	if(distiActId == null || distiActId == '' ) oppty.FBE_Distributor_Not_Applicable__c =true;
            oppty.FBE_Alliance_OEM_Provider__c = oemAcntIdD;
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
    
    
    //Tech debt - new method
    public Static List < Opportunity > createOptywithAccounts(Integer count, Id actId, Id euActId, Id fsIActId, Id resVarActId, Id distiActId, Id oemAcntId) {
        List < Opportunity > lOppty = new List < Opportunity > ();
        for (Integer i = 0; i < count; i++) {
            Opportunity oppty = new Opportunity();
            oppty.Name = 'Test_Opportunity_'+ i;
            oppty.Accountid = actId;
            oppty.FBE_End_User__c = euActId;
            oppty.FBE_FSI_Account__c = fsIActId;
            	if(fsIActId == null || fsIActId == '' ) oppty.FBE_FSI_Not_Applicable__c =true;
            oppty.FBE_VAR_Seller__c = resVarActId;
            	if(resVarActId == null || resVarActId == '' ) oppty.FBE_Reseller_VAR_Not_Applicable__c =true;
            oppty.FBE_Distributor__c = distiActId;
            	if(distiActId == null || distiActId == '' ) oppty.FBE_Distributor_Not_Applicable__c =true;
            oppty.FBE_Alliance_OEM_Provider__c = oemAcntId;
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


}