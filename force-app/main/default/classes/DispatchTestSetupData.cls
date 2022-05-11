/**
*    @author Prakhar Sinha
*    @date   9th April 18
*    @description  Class for creating test data                            
*     
*     Modification Log:
*------------------------------------------------------------------------------------
*       Developer             Date                Description
*------------------------------------------------------------------------------------
*       Prakhar Sinha       09th April 18         Original Version  
*/

 // @isTest --> Added by Harsha Reddy
public class DispatchTestSetupData {
    public static List < Account > createAccountList() {
		
        List < Account > acclist = new List < Account > ();
		List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
			for (Integer i = 0; i < 100; i++) {
				Account objAccount = new Account();
				objAccount.name = 'testAccount' + i;
				acclist.add(objAccount);
			}
			insert acclist;
		}
        return acclist;
    }
    public static List < Asset > createAssetList(Id AccountId) {
        List < Asset > assetlist = new List < Asset > ();
        for (Integer i = 0; i < 100; i++) {
            Asset objAsset = new Asset();
            objAsset.name = 'testAsset' + i;
            ObjAsset.AccountId = AccountId;
            assetlist.add(objAsset);
        }
        insert assetlist;
        return assetlist;

    }

    public static List < Contact > createContactList(Id AccountId) {
        List < Contact > contactlist = new List < Contact > ();
        for (Integer i = 0; i < 100; i++) {
            Contact objContact = new Contact();
            objContact.LastName = 'testContact' + i;
            objContact.FirstName = 'testContact' + i;
            objContact.AccountId = AccountId;
            objContact.Country_Code__c = 'Bermuda (441)';
            objContact.email = 'test' + i + '@gmail.com';
            objContact.Primary_Phone__c = '673487234872';
            objContact.Phone='1234567890';
            contactlist.add(objContact);
        }
        insert contactlist;

        return contactlist;
    }

    public static List < Case > createCaseList(Id AccountId, Id AssetId, Id ContactId) {
        List < Case > caselist = new List < Case > ();
        for (Integer i = 0; i < 10; i++) {
            Case objCase = new Case();
            objCase.AccountId = AccountId;
            objCase.AssetId = AssetId;
            objCase.ContactId = ContactId;
            objCase.status = 'In Progress';
            objCase.Priority = 'Low';
            //objCase.Service_Tag__c = 'test' + i;

            caselist.add(objCase);
        }
        insert caselist;
        return caselist;
    }

    public static List < WorkOrder > createworkorderList(Id AccountId, Id AssetId, Id ContactId, Id caseId) {
        List < WorkOrder > workorderList = new List < WorkOrder > ();
        for (Integer i = 0; i < 10; i++) {
            WorkOrder objWorkOrder = new WorkOrder();
            objWorkOrder.AccountId = AccountId;
            objWorkOrder.AssetId = AssetId;
            objWorkOrder.ContactId = ContactId;
            objWorkOrder.AddressBUID__c = '3696';
            objWorkOrder.CaseId = caseId;
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
            objWorkOrder.Region__c='1';
            workorderList.add(objWorkOrder);
        }
        insert workorderList;
        return workorderList;
    }
    public static List < WorkOrderLineItem > createworkorderListItem(Id workorderId, String lineItemType) {
		List < WorkOrderLineItem > workorderItemList = new List < WorkOrderLineItem > ();
        //create a test account
        /*List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
			Account acnt = new Account(Name = 'Test Company', Industry = 'Fashion',Type = 'Customer');
			insert acnt;
			
			//create a new product
			//Product2 prd = new Product2( ProductCode='12345',Description='test description',Name='Test Product',LOB_Code__c='4SV');
			Product2 prd = new Product2( ProductCode='12345',Description='test description',Name='Test Product');
			insert prd;
			
			//create a test asset
			Asset ast = new Asset(Name = 'Test Asset',Status = 'Installed',AccountId = acnt.Id, Product2Id=prd.Id,
							InstallDate = System.Today(),UsageEndDate = System.Today());
			insert ast;
			
			// Create Work Order Line Items
			for (Integer i = 0; i < 10; i++) {
				WorkOrderLineItem objWorkOrderLineItem = new WorkOrderLineItem();
				objWorkOrderLineItem.WorkOrderId = workorderId;
				objWorkOrderLineItem.PartNumber__c = '1234';
				objWorkOrderLineItem.PartPrice__c = '1234';
				objWorkOrderLineItem.PartType__c = 'type';
				objWorkOrderLineItem.Line_Item_Type__c = lineItemType;
				objWorkOrderLineItem.PartCommodity__c = 'HARD DRIVE';
				objWorkOrderLineItem.Selected_By_user__c = true;
				objWorkOrderLineItem.DefectiveComponent__c = 'test';
				objWorkOrderLineItem.ServiceBUID__c = 'test';
				objWorkOrderLineItem.Part_Quantity__c = '1';
				objWorkOrderLineItem.AssetId = ast.Id;
				workorderItemList.add(objWorkOrderLineItem);
			}
			insert workorderItemList; 
		}	*/
        return workorderItemList;
    }
}