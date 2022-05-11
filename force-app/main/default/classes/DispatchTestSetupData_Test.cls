/* -----------------------------------------------------------------------------------------------------------------------
Name:       DispatchTestSetupData_Test
Description:  This is unit test class for DispatchTestSetupData
Date         Version    Author                  Summary of Changes 
-----------  -------  -----------------        ------------------------------------------------------------------------------
22-04-2019    v1        Rishika Bandyopadhyay   May release text class fix   

-------------------------------------------------------------------------------------------------------------------------- */

@isTest
public class DispatchTestSetupData_Test {
    private static Account objAccount;
    private static Asset objAsset;
    private static Contact objContact;
    private static Case objCase;
    private static WorkOrder objWorkOrder;
    private static List<Account> lstAccount;
    private static List<Asset> lstAsset;
    private static List<Contact> lstContact;
    private static List<Case> lstCase;
    private static List<WorkOrder> lstWO;
    @TestSetup
    static void makeData(){
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            objAccount = new Account();
            objAccount.name = 'testAccount';
            insert objAccount;

            objAsset = new Asset();
                objAsset.name = 'testAsset';
                ObjAsset.AccountId = objAccount.Id;
                insert objAsset;

            objContact = new Contact();
                objContact.LastName = 'testContact';
                objContact.FirstName = 'testContact';
                objContact.AccountId = objAccount.Id;
                objContact.Country_Code__c = 'Bermuda (441)';
                objContact.email = DateTime.now().getTime() + 'test' +  '@gmail.com';
                objContact.Primary_Phone__c = '673487234872';
                objContact.Phone='1234567890';
                insert objContact;

            objCase = new Case();
                objCase.AccountId = objAccount.Id;
                objCase.AssetId = objAsset.Id;
                objCase.ContactId = objContact.Id;
                objCase.status = 'In Progress';
                objCase.Priority = 'Low';
                //objCase.Service_Tag__c = 'test';
                insert objCase;


        
            objWorkOrder = new WorkOrder();
                objWorkOrder.AccountId = objAccount.id;
                objWorkOrder.AssetId = objAsset.Id;
                objWorkOrder.ContactId = objContact.Id;
                objWorkOrder.AddressBUID__c = '3696';
                objWorkOrder.CaseId = objCase.Id;
                objWorkOrder.Entitlement_Details__c = 'KYHD';
                objWorkOrder.KYHD__c = true;
                objWorkOrder.City = 'Round Rock';
                objWorkOrder.CountryCode = 'US';
                objWorkOrder.StateCode = 'TX';
                objWorkOrder.Street = 'Dell Way123';
                objWorkOrder.PostalCode = '78664';
                objWorkOrder.Dispatch_Country__c='US and EMEA';
                ObjWorkorder.Status='Open';
                objWorkOrder.WO_Type__c='Break Fix';
                insert objWorkOrder;
            }
    }   

@IsTest
static void testcreateAccountList(){
    
    Test.startTest();
    
    List<Account> a = DispatchTestSetupData.createAccountList();   

    Test.stopTest();
    
}

@IsTest
static void testcreateAssetList(){
    lstAccount = [SELECT Id from Account limit 1];
    Test.startTest();
    
    List<Asset> a = DispatchTestSetupData.createAssetList(lstAccount[0].Id);   

    Test.stopTest();
    
}
@IsTest
static void testcreateContactList(){
    lstAccount = [SELECT Id from Account limit 1];
    Test.startTest();
    
    List<Contact> a = DispatchTestSetupData.createContactList(lstAccount[0].Id);   

    Test.stopTest();
    
}

@IsTest
static void testcreateCaseList(){
    lstAccount = [SELECT Id from Account limit 1];
    lstAsset = [SELECT Id from Asset limit 1];
    lstContact = [SELECT Id from Contact limit 1];
    Test.startTest();
    
    List<Case> a = DispatchTestSetupData.createCaseList(lstAccount[0].id, lstAsset[0].id, lstContact[0].Id);   

    Test.stopTest();
    
}
@IsTest
static void testcreateworkorderList(){
    lstAccount = [SELECT Id from Account limit 1];
    lstAsset = [SELECT Id from Asset limit 1];
    lstContact = [SELECT Id from Contact limit 1];
    lstCase = [SELECT Id from Case limit 1];
    Test.startTest();
    
    List<WorkOrder> a = DispatchTestSetupData.createworkorderList(lstAccount[0].id, lstAsset[0].id, lstContact[0].Id, lstCase[0].id);   

    Test.stopTest();
    
}
@IsTest
static void testcreateworkorderListItem(){
    lstWO = [SELECT Id from WorkOrder limit 1];
    Test.startTest();
    
    List<WorkOrderLineItem> a = DispatchTestSetupData.createworkorderListItem(lstWO[0].id, 'APS');   

    Test.stopTest();
    
}
}