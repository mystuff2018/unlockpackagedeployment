/**************
*@ Class Name                                                    : FBE_LeadConvertCtrl_Test
*@ Description                                                   : Test class for FBE_LeadConvertCtrl. Created for Story#8506722.
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 06-23-2020
*@ Modification Log                                              : 
***************/ 
@isTest
public class FBE_LeadConvertCtrl_Test {
    @testSetup static void setup() {
        List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        List < User > lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 4, 'ab','Inside Sales Manager');
        List<Lead> insLeadList = new List<Lead>();
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(2,null);
        for(Integer i=0 ;i <lAcc.size() ; i++){
            lAcc[i].name = 'SFDC Test Account'+i;
        }
        system.runAs(lUsr[0]) {
            //Create an Account
            
            insert lAcc;
            system.assertNotEquals(null, lAcc[0].id, 'Account Record not found');
            system.assertNotEquals(null, lAcc[1].id, 'Account Record not found');
            
            
            List < Campaign > campaignList = FBE_UtilityFactory_Test.createCampaign(1);
            insert campaignList;
            for(Integer i=0 ;i<=1 ;i ++){
                Lead leadRecord = new Lead();
                leadRecord.Company = 'Company_Test'+i;
                leadRecord.FirstName = 'Lead Fname'+i;
                leadRecord.LastName = 'Lead LName'+i;
                leadRecord.FBE_Lead_Type__c = 'Inbound';
                leadRecord.Email = 'testleadabc@abc.com';
                leadRecord.Phone = '1232789';
                leadRecord.FBE_Sales_Role__c = 'SR';
                leadRecord.FBE_Campaign__c = campaignList[0].Id;
                leadRecord.FBE_Account_Name__c = lAcc[0].id;
                leadRecord.FBE_End_User_Account__c = lAcc[1].id;
                leadRecord.ownerid = lUsrNonIntegration[0].id;
                leadRecord.Opportunity_Product_Classification__c = 'Dell Products';
                leadRecord.LeadSource = 'Email';
                leadRecord.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
                leadRecord.FBE_Lead_Type__c ='Inbound';
                insLeadList.add(leadRecord);
            }
            insert insLeadList;
            
        }
    }
    
    @isTest
    static void convertLeadTest(){
        List<Lead> allLeads = [SELECT Id,FirstName, LastName, Phone, Email,FBE_End_User_Account__c,FBE_Account_Name__c,FBE_End_User_Account__r.Name,FBE_Account_Name__r.Name,
                               FBE_Campaign__c,Opportunity_Product_Classification__c,FBE_Funding_Source__c,FBE_Customer_Comments__c,FBE_Project_ID__c,
                               FBE_Expected_Opportunity_Type__c,Company FROM Lead WHERE FirstName LIKE 'Lead Fname%' AND LastName LIKE 'Lead LName%' AND Email ='testleadabc@abc.com'];
        System.debug('allLeads size: '+allLeads.size()+ ' - ' +allLeads);
        
        Id oppStdRecTypeId = [SELECT Id,Name FROM RecordType WHERE sObjectType='Opportunity' AND Name='Standard Opportunity'].Id;
        System.debug('oppStdRecTypeId: '+oppStdRecTypeId);
        
        
        //For getLeadDetails()
        Lead convLead = FBE_LeadConvertCtrl.getLeadDetails(allLeads[0].Id);
        System.debug('convLead: '+convLead);
        
        //For new Cont,new Opty
        Contact newCont = new Contact(FirstName='SFDC-new',LastName='TestCont-new',Phone='123456789',Email='sfdctestnewcont123@tescon.com',Country_Code_CAM__c = '91');
        
        Opportunity newOppty = new Opportunity(Name='SFDC Test Opty',StageName='Plan - 1%',FBE_Opportunity_Classification__c='Dell Products',
                                               FBE_Contracting_Status__c='UFR',FBE_Pursuit_Type__c='Direct',CloseDate=System.today(),Type='Deal/Bid - Direct',
                                               FBE_Funding_Source__c='FUNDED-Prior Year Carryover',RecordtypeId=oppStdRecTypeId,FBE_Storage_Selling_Motion__c='Greenfield');
        
        
        FBE_LeadConvertCtrl.wrapResult wr= FBE_LeadConvertCtrl.LeadConvert(convLead, newCont, newOppty, null, null, convLead.FBE_End_User_Account__c, 'Converted to New Opportunity', UserInfo.getUserId());
        System.debug('wr:: '+wr);
        
        //For Existing Con,existing Opty
        Lead convLead2 = FBE_LeadConvertCtrl.getLeadDetails(allLeads[1].Id);
        System.debug('convLead2 ::'+convLead2);
        
        Contact existCont = new Contact(FirstName='SFDC-exist',LastName='TestCont-new',Phone='123456789',Email='sfdctestexistcont123@tescon.com', Country_Code_CAM__c='91');
        System.assertEquals('SFDC-exist', existCont.FirstName);
        INSERT existCont;
        test.startTest();
        Opportunity existOpy = new Opportunity(Name='SFDC Test Exist Opty',StageName='Plan - 1%',FBE_Opportunity_Classification__c='Dell Products',
                                               FBE_Contracting_Status__c='UFR',FBE_Pursuit_Type__c='Direct',CloseDate=System.today(),Type='Deal/Bid - Direct',
                                               FBE_Funding_Source__c='FUNDED-Prior Year Carryover',RecordtypeId=oppStdRecTypeId,
                                               FBE_FSI_Not_Applicable__c=true,FBE_Distributor_Not_Applicable__c=true,FBE_Reseller_VAR_Not_Applicable__c=true,
                                               AccountId=allLeads[0].FBE_End_User_Account__c,FBE_Campaigns__c=allLeads[0].FBE_Campaign__c,FBE_Storage_Selling_Motion__c='Greenfield');
        INSERT existOpy;
        test.stopTest();
        FBE_LeadConvertCtrl.wrapResult wr2= FBE_LeadConvertCtrl.LeadConvert(convLead2, null, null, existOpy.Id, existCont.Id, convLead2.FBE_End_User_Account__c, 'Converted to Existing Opportunity', UserInfo.getUserId());
        System.debug('wr2:: '+wr2);
        
        //handling exception during conversion - trying to convert the above converted lead
        FBE_LeadConvertCtrl.wrapResult wr3= FBE_LeadConvertCtrl.LeadConvert(convLead2, null, null, existOpy.Id, existCont.Id, convLead2.FBE_End_User_Account__c, 'Converted to Existing Opportunity', UserInfo.getUserId());
        System.debug('wr3:: '+wr3);
        
        
        
        // For getRelatedOppty()
        List<Opportunity> optyList = FBE_LeadConvertCtrl.getRelatedOppty(convLead2.FBE_End_User_Account__c);
        
        // For getSearchedOppty()
        List<Opportunity> filterdOpties = FBE_LeadConvertCtrl.getSearchedOppty(convLead2.FBE_End_User_Account__c, 'testString');
        
        //To handle Failure saveResult - past Book date
        Contact newCon = new Contact(FirstName='SFDC-new',LastName='TestCont-new',Phone='123456789',Email='sfdctestnewcont123@tescon.com',Country_Code_CAM__c='91');
        Opportunity newOpp = new Opportunity(Name='SFDC Test Opty',StageName='Plan - 1%',FBE_Opportunity_Classification__c='Dell Products',
                                             FBE_Contracting_Status__c='UFR',FBE_Pursuit_Type__c='Direct',CloseDate=System.today()-1,Type='Deal/Bid - Direct',
                                             FBE_Funding_Source__c='FUNDED-Prior Year Carryover',RecordtypeId=oppStdRecTypeId);
        
        FBE_LeadConvertCtrl.wrapResult wr4= FBE_LeadConvertCtrl.LeadConvert(convLead, newCon, newOpp, null, null, convLead.FBE_End_User_Account__c, 'Converted to New Opportunity', UserInfo.getUserId());
        System.debug('wr4:: '+wr4);
        
        
        
        //For getCurrentUser
        //boolean getloggedinUser = FBE_LeadConvertCtrl.getCurrentUser();
        
        //For getUpdateValues()
        //List<sObject> sObjList = FBE_LeadConvertCtrl.getUpdateValues(convLead2.FBE_End_User_Account__c, existOpy.Id, existCont.Id);
    }
    
    @isTest
    static void getRelatedActContsTest(){
        List<Account> actList = [SELECT Id FROM Account WHERE Name LIKE 'SFDC Test Account%'];
        System.debug('actList: '+actList.size());
        System.assertEquals(2, actList.size());
        if(actList.size() > 0){
            List<Contact> conList = FBE_LeadConvertCtrl.getRelatedActConts(actList[0].Id);
        }
    }
   
    @isTest
    static void getListViewsTest(){
        List<ListView> lv = FBE_LeadConvertCtrl.getListViews();
    }
   
}