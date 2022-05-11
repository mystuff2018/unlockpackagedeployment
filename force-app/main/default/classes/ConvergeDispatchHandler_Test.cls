@isTest
public class ConvergeDispatchHandler_Test {
    //private static Account acnt;
//    private static Asset ast;
//    private static Case cse;
//    private static User u;
//    private static Contact co;
//    private static WorkOrder wo;
//    private static Address_Data_GCC__c gccadd;
//    private static ServiceAppointment srvapp;
//    private static DispatchDSPDLP__c dspdlp;
//    private static Preference__c pref;
//    private static DispatchPartsOrder__c po;
//    private static WorkOrder wo2;
//    private static WorkOrderLineItem woLi;
//    private static WorkOrderLineItem wol;
//    private static WorkOrderLineItem wol2;
//    private static  List<WorkOrderLineItem> wolList;
//    private static Product2 prd;
//    private static DispatchPartsOrderLine__c dpLines;
//    private static DispatchPartsOrder__c dporder;
//    private static DispatchDefaults__c dd;
//    private static DispatchInstruction__c instruction; 
//    private static List<String> WoIdList;
//    private static DispatchPartsOrder__c dPartsOrder;
//    
//    /* This method creates the test data */
//    // @TestSetup 
//    private static void setupTestData() {
//        /// Create a unique UserName
//        //String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@dell.com';
//        //u = new User(Alias='auser', Email='adminuser@dell.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', FederationIdentifier='1234526',LocaleSidKey='en_US', ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,TimeZoneSidKey='America/Los_Angeles',UserName=uniqueUserName,OSP__c='Yes');
//        u = SRVS_CreateTestDataFactory.createUser('System Administrator');
//        insert u;
//
//  
//        //create a test account
//        String uniqueAccntName = 'Test Account'+DateTime.now().getTime();
//        acnt=SRVS_CreateTestDataFactory.createSingleAccountRecord();
//        acnt.Name=uniqueAccntName;
//        acnt.Industry='Fashion';
//        acnt.Type = 'Prospect';
//        acnt.Account_Identifier__c = 'S360';
//        
//        insert acnt;
//        
//        //create a new product
//        prd=SRVS_CreateTestDataFactory.createProduct2();
//        prd.Product_Identifier__c='S360';
//        prd.External_Id__c = 'IB370';
//        prd.Name='TestProduct';
//        prd.LOB_Code__c='4SV';
//        insert prd;                
//        
//        //create a test asset
//        String uniqueAssetName = 'Test Asset'+DateTime.now().getTime();
//        ast=SRVS_CreateTestDataFactory.createSingleAsset(acnt.id);
//        ast.Product2Id=prd.Id;
//        ast.Name = uniqueAssetName;
//        ast.Status = 'Installed';
//        ast.InstallDate = System.Today();
//        ast.UsageEndDate = System.Today();
//        ast.serialNumber='TestNumber89768';
//        ast.Country__c = 'BR';
//        ast.State__c = 'SP';
//        ast.Invoice_Date__c =Date.today();
//        //ast = new Asset(Name = 'Test Asset',Status = 'Installed',AccountId = acnt.Id, Product2Id=prd.Id,InstallDate = System.Today(),UsageEndDate = System.Today(),serialNumber='TestNumber89768');
//        insert ast;
//        
//        //create a test contact
//        co=SRVS_CreateTestDataFactory.createContactRecord(acnt);
//        co.Email = 'testtag@test.com';
//        co.firstname = 'firstname';
//        co.LastName = 'testtag';
//        co.Accountid = acnt.id;
//        //co = new Contact(Email = 'testtag@test.com',firstname = 'firstname',LastName = 'testtag',Accountid = acnt.id);
//        insert co;
//        
//        //create a test LiveChatVisitor
//        LiveChatVisitor visitor=SRVS_CreateTestDataFactory.createLiveChatVisitor();
//        insert visitor;
//        
//        // create a LiveChatTranscript
//        LiveChatTranscript lct=SRVS_CreateTestDataFactory.createLiveChatTranscript(visitor,ast);
//        insert lct;
//        
//        // create a LiveChatTranscript without Asset
//        LiveChatTranscript lct1=new LiveChatTranscript(LiveChatVisitorId=visitor.Id);
//        lct1.Asset__c=null;
//        insert lct1;
//        
//        //create a test case
//        cse=SRVS_CreateTestDataFactory.createSingleCase(ast.id,acnt.id,co.id);
//        cse.subject='Test Controller Acct Case';
//        cse.Service_Tag__c = 'TESTTAG';
//        cse.AssetId=ast.id;
//        cse.NonAgentContactEmail__c = 'testtag@test.com';
//        cse.NonAgentContactFirstName__c = 'firstname';
//        cse.NonAgentContactLastName__c = 'testtag';
//        cse.NonAgentContactPhone__c = '800-123-4567';
//        cse.TranscriptId__c = lct.Id;
//        cse.Delta_SR__c = '1234567890';
//        //cse = new Case(Subject='Test Case',AccountId=acnt.Id,AssetId=ast.Id,ContactId=co.Id);
//        insert cse;
//        
//        wo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
//        wo.Subject = 'test tnqjnyghdqajkx';
//        wo.status = 'Work In Progress';
//        wo.Sub_Status__c='';
//        wo.AddressBUID__c = '';
//        wo.DLP__c = '';//need to check value
//        wo.Region__c = '1';
//        wo.DPS_Sub_Region__c = 'LA';
//        wo.Service_Option__c = 'Next Business Day-8x5';
//        wo.Service_Type__c = 'Parts Only';
//        wo.StateCode__c = 'NY';
//        wo.PostalCode = '10065';
//        wo.DSP__c = 'CLICK';
//        wo.CountryCode = 'US';
//        wo.DPS_Region__c = 'AMERICAS';
//        wo.Ground_Shipment_Flag__c = false;
//        wo.City_APJ__c = 'NEW YORK';
//        wo.KYC__c = false;
//        wo.KYHD__c = false;
//        wo.Reprocessed_Count__c = 7;
//        wo.WO_Type__c ='Parts Only';
//        wo.City = '';
//        wo.Latitude = null;
//        wo.Longitude = null;
//        wo.State__c='NY';
//        wo.Onsite_Stocking_Location__c = 'NY';
//        wo.Timezone__c = 'USABCDEF';
//        wo.AD_Count__c = 1;
//        wo.AssetId = ast.id;
//        wo.Schedule_Enable_Flag__c='Y';
//        //wo.ScheduleStartDate__c = String.valueOf(Date.today() + 5);
//        wo.EntitlementStartDate__c = String.valueOf(DateTime.now());
//        wo.EntitlementEndDate__c = String.valueOf(DateTime.now());
//        insert wo;
//        
//        
//        
//        po = new DispatchPartsOrder__c();
//        po.Work_Order__c = wo.Id;
//        po.Name = 'Test';
//        po.ISP_Shipping_Location__c='';
//        po.ISP_Shipping_Method__c='';
//        po.ISP_Shipping_Method_Id__c='';
//        po.ISP_PlanDeliveryMode__c='';
//        po.ISP_Part_ETA__c='';
//        po.ISP_Carrier_Name__c='';
//        po.ISP_Carrier_Id__c='';
//        po.Locator_Mode__c='';
//        po.Locator_Request_Time__c='';
//        insert po;
//        
//        dspdlp = new DispatchDSPDLP__c();
//        dspdlp.Type__c = 'DSP';
//        dspdlp.PartnerName__c = 'DLP';
//        dspdlp.Active__c = true;
//        dspdlp.CountryCode__c = 'US';
//        insert dspdlp;
//        
//        pref = new Preference__c();
//        pref.Preference_Type__c = 'Shipping Contact';
//        pref.Contact__c = co.id;
//        pref.Account__c= acnt.id;
//        insert pref;
//        
//        //cr = new Customer_Reminder__c();
//        //cr.Type__c = 
//        
//        gccadd = new Address_Data_GCC__c();
//        gccadd.COUNTRYNAME__c = 'US';
//        gccadd.COUNTRYCODE__c = 'US';
//        gccadd.STATENAME__c = 'TX';
//        gccadd.STATECODE__c = 'TX';
//        gccadd.BUCODE__c = '456';
//        gccadd.POSTCODE__c= '78664';
//        gccadd.Name = 'ROUND';
//        insert gccadd;
//        
//        
//        //instructions = new list<DispatchInstruction__c>();
//        instruction = new DispatchInstruction__c();
//        instruction.Receiver__c='All Providers';
//        instruction.Visibility__c='External (Public)';
//        instruction.Instruction__c= 'Test';
//        instruction.Type_of_Instruction__c='Outbound';
//        instruction.Audience__c='Carrier';
//        instruction.Work_Order__c = wo.id;
//        
//        insert instruction;
//        
//        Work_Order_Pending_Site_Access__c woSAP = new Work_Order_Pending_Site_Access__c();
//        woSAP.WorkOrder__c = wo.id;
//        insert woSAP;
//        
//        Address_Data_GCC__c indAdress = new Address_Data_GCC__c ();
//        indAdress.Name='VILE PARLE WEST';
//        indAdress.POSTCODE__c='400056';
//        indAdress.COUNTRYCODE__c='IN';
//        indAdress.STATENAME__c ='MRT:MUMBAI';
//        insert indAdress;
//        
//        List<ServiceAppointment> serviceAppointmentList = new List<ServiceAppointment>();
//        ServiceAppointment testServiceAppointment1 = new ServiceAppointment(
//            Work_Order__c =wo.id,
//            EarliestStartTime = System.now(),
//            DueDate = System.now() + 7,
//            ParentRecordId = wo.id,
//            Duration = 8,
//            Latitude = -34.64646377383453,
//            Longitude = -58.39512164685306,
//            Assignee__c = co.Id,
//            Primary_Contact__c = co.Id,
//            Scheduling_Contact__c = co.Id,
//            Service_Start__c='2020-02-17T09:00:00-06:00',
//            Country__c = 'US',
//            Address_Line_1__c= 'US', Address_Line_2__c= 'US', Address_Line_3__c= 'US', Address_Line_4__c= 'US',
//                          City__c= 'US', State__c= 'US',State_Code__c= 'US' ,  Zip__c= 'US'
//        );
//        
//        ServiceAppointment testServiceAppointment2 = new ServiceAppointment(
//            Work_Order__c = wo.id,
//            EarliestStartTime = System.now(),
//            DueDate = System.now() + 7,
//            ParentRecordId = wo.id,
//            Duration = 8,
//            Latitude = -34.6464637738345,
//            Longitude = -58.3951216468530,
//            Assignee__c = co.Id,
//            Primary_Contact__c = co.Id,
//            Scheduling_Contact__c = co.Id,
//
//            Country__c = 'US'
//        );
//        
//        serviceAppointmentList.add(testServiceAppointment1);
//        serviceAppointmentList.add(testServiceAppointment2);
//        insert serviceAppointmentList; 
//        
//        DispatchPendingApproval__c dpa = new DispatchPendingApproval__c();
//        dpa.Work_Order__c = wo.id;
//        insert dpa;
//        
//        Maintenance_Calendar__c mainCal = new Maintenance_Calendar__c(
//            Day__c='Monday',End_Time__c=Time.newInstance(1, 3, 4, 5),
//            Start_Time__c=Time.newInstance(1, 2, 3, 4), 
//            Account__c=acnt.id       
//        );
//        
//        insert mainCal;
//        
//    }
//    @isTest
//    static void getServiceAddressInfoTest(){
//        setupTestData();
//        system.runAs(u) {
//            Test.startTest();
//    
//            ConvergeDispatchHandler.getServiceAddressInfo(wo.id, acnt.id);
//            ConvergeDispatchHandler.mockGSCVAddressId = null;
//            Group grp = new Group();
//            grp.name = 'Test Group1';
//            grp.Type = 'queue'; 
//            grp.DeveloperName='S_S_Queue';
//            Insert grp;
//            ConvergeDispatchHandler.getQueueID('test queue');
//            
//            Test.stopTest();
//        }
//    }
//    
//      
//    static void hidePartsDeliverySectiontest2(){
//        setupTestData();
//        system.runAs(u) {
//        Test.startTest();
//
//
//
//        wo.CheckForServiceTypeEqualsLaborOnly__c=true;
//
//
//        ConvergeDispatchHandler.hidePartsDeliverySection(wo.id);
//
//        }
//    }
//    
//
//    
//    static void hidePartsDeliverySectiontest3(){
//        setupTestData();
//        system.runAs(u) {
//        Test.startTest();
//
//        ConvergeDispatchHandler.hidePartsDeliverySection(woId);
//
//        }
//    }
//
//   /* 
//    static void getWorkOrderListtest(){
//        setupTestData();
//        system.runAs(u) {
//        Test.startTest();
//        ConvergeDispatchHandler.getWorkOrderList('TestData');
//
//        }
//    } */
//    
//        @isTest
//    static void getServiceAddressInfoTest2(){
//        setupTestData();
//        system.runAs(u) {
//            Test.startTest();
//    ConvergeDispatchHandler.mockGSCVAddressId = gccadd.Id;
//
//
//
//
//            ConvergeDispatchHandler.getServiceAddressInfo(wo.id, acnt.id);
//            ConvergeDispatchHandler.mockGSCVAddressId = null;
//        Group grp = new Group();
//        grp.name = 'Test Group1';
//        grp.Type = 'queue'; 
//         grp.DeveloperName='S_S_Queue';
//        Insert grp;
//            ConvergeDispatchHandler.getQueueID('test queue');
//    Test.stopTest();
//        }
//    }
//    
//    @isTest
//    static void updateShippingDetailsTest(){
//        setupTestData();
//        system.runAs(u) {
//            Test.startTest();
//            
//            ast.Country__c = 'AI';
//            update ast;
//            ConvergeDispatchHandler.updateShippingDetails(wo.id);
//            ast.Country__c = 'AF';
//            update ast;
//            ConvergeDispatchHandler.updateShippingDetails(wo.id);
//            ast.Country__c = 'JP';
//            ast.Zip__c = '78664';
//            update ast;
//            gccadd.COUNTRYCODE__c = 'JP';
//            update gccadd;
//            ConvergeDispatchHandler.updateShippingDetails(wo.id);
//            ast.Country__c = 'US';
//            update ast;
//            
//            
//            
//            ConvergeDispatchHandler.updateShippingDetails(wo.id);
//            acnt.Shipping_country__c = 'United States';
//            acnt.ShippingCountry = 'United States';
//            acnt.ShippingStreet = '19th main street';
//            acnt.ShippingState ='Texas';
//            //acnt.ShippingStateCode = 'TX';
//            acnt.ShippingCity = 'Round Rock';
//            acnt.ShippingPostalCode = '78664';
//            update acnt;
//            ConvergeDispatchHandler.updateShippingDetails(wo.id);
//            pref.Preference_Type__c = 'After Hour Contact';
//            update pref;
//            
//            ConvergeDispatchHandler.updateShippingDetails(wo.id);
//
//
//
//            
//            acnt.Account_Identifier__c = 'S360';
//            acnt.Shipping_country__c = 'United States';
//            acnt.ShippingCountry = 'United States';
//            acnt.ShippingCountryCode = 'US';
//            acnt.ShippingStateCode = 'TX';
//            acnt.ShippingCity = 'ANDREWS';
//            acnt.ShippingPostalCode = '79714';
//            acnt.ShippingStreet = '200 S LAUREL AVE';
//            update acnt;
//
//            Address_Data_GCC__c gccTest = new Address_Data_GCC__c(Name = acnt.ShippingCity, 
//                                                                  COUNTRYCODE__c = acnt.Shipping_country__c,
//                                                                  POSTCODE__c = acnt.ShippingPostalCode,
//                                                                  COUNTRYNAME__c = 'United States',
//                                                                  STATENAME__c = 'TEXAS',
//                                                                  STATECODE__c = 'TX');
//            insert gccTest;
//          
//            ConvergeDispatchHandler.updateShippingDetails(wo.id);
//            
//
//        }
//    }
//    
//    @isTest
//    static void testMethod2(){
//        setupTestData();
//        system.runAs(u) {
//            Test.startTest();
//            ConvergeDispatchHandler.getServiceEvents(wo.id);
//            ConvergeDispatchHandler.getInstructions(wo.id);
//            DispatchDSPDLP__c mockedDsp = new DispatchDSPDLP__c(Type__c='DSP', PartnerCode__c='UNICORN', CountryCode__c='US', PartnerName__c='QLX');            
//            ConvergeDispatchHandler.mockedDSPDLP.add(mockedDsp);            
//            ConvergeDispatchHandler.getDASPDSPValues('UNICORN',wo.id);
//            ConvergeDispatchHandler.getDASPValues('US');
//            ConvergeDispatchHandler.getMaintenanceCalendar(acnt.id);
//            ConvergeDispatchHandler.timeFormat('2376547682');
//            ConvergeDispatchHandler.cancelServiceAppointment(wo.id);
//            ConvergeDispatchHandler.getWorkOrder(wo.id);
//            Id woId = null;
//            ConvergeDispatchHandler.getWorkOrder(woId);
//            ConvergeDispatchHandler.getContactPreference(wo.id);
//            ConvergeDispatchHandler.getContactPreference(woId);
//            ConvergeDispatchHandler.updateShippingDetails(wo.id);
//            ConvergeDispatchHandler.getGCCAddressDetails('US','TX','ROUND','78664');
//            Test.stopTest();
//        }
//    }
//    @isTest
//    static void testMethod111(){
//        setupTestData();
//        system.runAs(u){
//            Test.startTest();
//             ConvergeDispatchHandler.getESupportURL(wo.id);
//            Test.stopTest();
//        }
//    }
//    
//    @isTest
//    static void testMethod3(){
//        setupTestData();
//        system.runAs(u){
//            Test.startTest();
//            id woId = null;
//            //ConvergeDispatchHandler.getESupportURL(wo.id);
//            ESupportUrlResponse__x eSupportResp = new ESupportUrlResponse__x(ResponseCode__c='100', EsupportUrl__c='www.EsupportUrl__c.com', EsupportCalendarUrl__c = 'www.EsupportCalendarUrl__c.com');
//        
//            ConvergeDispatchHandler.getWorkOrderRecord(wo.id);
//            ConvergeDispatchHandler.getESupportURL(wo.id);
//            ConvergeDispatchHandler.getESupportURL(woId);
//            ConvergeDispatchHandler.deleteServiceAppointment(wo.id);
//            ConvergeDispatchHandler.deleteServiceAppointment(woId);
//            ConvergeDispatchHandler.checkLaborDisplayView(wo.id);
//            ConvergeDispatchHandler.laborFlagCheck(wo.id);
//            ConvergeDispatchHandler.laborFlagCheck(woId);
//            ConvergeDispatchHandler.hideLaborButton(wo.id);
//            ConvergeDispatchHandler.getOwnerID(wo.id);
//            ConvergeDispatchHandler.hidePartsDeliverySection(wo.id);
//            ConvergeDispatchHandler.fetchDateAndHours(System.today());
//            ConvergeDispatchHandler.getWOPendingSADetails(wo.id);
//            ConvergeDispatchHandler.getAssetHoldStatus(ast.id);
//            DispatchPendingApproval__c dpa = new DispatchPendingApproval__c();
//            dpa.Work_Order__c = wo.id;
//            insert dpa;
//            ConvergeDispatchHandler.getWOPendingApprovalDetails(dpa.id);
//            ConvergeDispatchHandler.getWOData(wo.id);
//            ConvergeDispatchHandler.fetchStatusFieldsData(wo.id);
//            ConvergeDispatchHandler.GCCEditCheck(wo.id);
//            ConvergeDispatchHandler.GCCEditCheck(woId);
//            ConvergeDispatchHandler.checkRepeatDispatchInAsset(cse.id, 'US');
//            ConvergeDispatchHandler.checkRepeatDispatchInAsset(wo.id, 'US');
//            ConvergeDispatchHandler.checkRepeatDispatchInAsset('', 'US');
//            ConvergeDispatchHandler.isLAPUser();
//            ConvergeDispatchHandler.getGCCConfigurations('US');
//            ConvergeDispatchHandler.changeWorkOrderOwnerInElevatedQueue(wo.id, u.id);
//            ConvergeDispatchHandler.getRecordsToSubmitWorkOrder(wo.id, u.id, ast.id);
//            ConvergeDispatchHandler.getRecordsToSubmitWorkOrder(woId, woId, woId);
//            ConvergeDispatchHandler.getPreferenceRecords(acnt.id);
//            pref.Preference_Type__c = 'After Hour Contact';
//            update pref;
//            ConvergeDispatchHandler.getPreferenceRecords(acnt.id);
//            ConvergeDispatchHandler.createServiceAppointment(wo.id);
//            ast.Country__c = 'JP';
//            update ast;
//            ConvergeDispatchHandler.createServiceAppointment(wo.id);
//            ast.Country__c = 'IN';
//            update ast;
//            ConvergeDispatchHandler.createServiceAppointment(wo.id);
//            ast.Country__c = 'TEST';
//            update ast;
//            ConvergeDispatchHandler.createServiceAppointment(wo.id);
//            ast.Country__c = 'TEST';
//            ast.State__c = 'TEST';
//            update ast;
//            gccadd.COUNTRYCODE__c = 'TEST';
//            gccadd.STATECODE__c = 'TEST';
//            update gccadd;
//            ConvergeDispatchHandler.createServiceAppointment(wo.id);
//            Test.stopTest();
//        }
//    }
//    
//    @isTest
//    static void testMethod1(){
//        setupTestData();
//        
//        system.runAs(u) {
//            Test.startTest();
//            Id woid = null;
//            ConvergedTimeZone__mdt mockedMdt = new ConvergedTimeZone__mdt(MasterLabel='11 hrs-8x5', DeveloperName='X_11_hrs_8x5',
//                                                                 CountryCode__c = 'US', Default_Delta_Timezone__c='America/Mexico_City', 
//                                                                 Default_SFDC_Timezone__c = 'America/Mexico_City');
//            ServiceLevelSlot__x sla = new ServiceLevelSlot__x(Start__c='2020-02-17T08:00:00-06:00', 
//                                                                                     End__c='2020-02-17T18:00:00-06:00', ResponseCode__c='100', 
//                ResponseDetails__c='Operation Successful', ResponseMessage__c='Operation completed successfully', TimeZone__c='America/Mexico_City');
//            ConvergeDispatchHandler.mockedServiceLevelSlot.add(sla);
//            ConvergeDispatchHandler.ServiceAppointmentWrap wrap1= new ConvergeDispatchHandler.ServiceAppointmentWrap();
//            ConvergeDispatchHandler.SubmitWorkOrderWrap wrap2= new ConvergeDispatchHandler.SubmitWorkOrderWrap();
//            ConvergeDispatchHandler.OverrideEntitlementWrap wrap3 = new ConvergeDispatchHandler.OverrideEntitlementWrap();
//            wo.Timezone__c=null;
//            wo.Service_Type__c='Parts and Labor';
//            update wo;
//            ConvergeDispatchHandler.updateEntitlementDates(wo.id);
//            ConvergeDispatchHandler.checkUserPermission();
//            ConvergeDispatchHandler.createAlert('2',wo.id);
//            ConvergeDispatchHandler.getWorkOrder(wo.id);
//            ConvergeDispatchHandler.getWorkOrder(woid);
//            ConvergeDispatchHandler.getContactPreference(wo.id);
//            ConvergeDispatchHandler.getContactPreference(woid);
//            ConvergeDispatchHandler.updateShippingDetails(wo.id);
//            ConvergeDispatchHandler.getGCCAddressDetails('US','TX','ROUND','78664');
//            //ConvergeDispatchHandler.validatePPID(pplist,'ABCDEFGHIJ');
//            //ConvergeDispatchHandler.mockAutovalidateParts.add(AutovalidateParts);
//            ConvergeDispatchHandler.getWorkOrderData(woid);
//            ConvergeDispatchHandler.createReminders(wo.id);
//            wo.status = 'Service Complete';
//            update wo;
//            ConvergeDispatchHandler.createReminders(wo.id);
//            ConvergeDispatchHandler.fetchStatusFieldsData(wo.id);
//            ConvergeDispatchHandler.createAccidentalDamageAlerts(wo.id);
//            ConvergeDispatchHandler.getRecordsToOverrideEntitlement(wo.id);
//            ConvergeDispatchHandler.entitlementADDetails(wo.id);
//            //ConvergeDispatchHandler.entitlementADDetails(wo.id);
//            ConvergeDispatchHandler.checkForInstruction(wo.id);
//            ConvergeDispatchHandler.getCustomerReminders(wo.id,'Parts Only');
//            ConvergeDispatchHandler.getPartnerCodeForGCC('DLP','US');
//            ConvergeDispatchHandler.getRecordsToOverrideEntitlement(woid);
//            
//            acnt.Site_Access_Required__c = 'Yes';
//            acnt.Customer_Confirmation_Required__c = 'Yes';
//            acnt.Site_Access_Requirement_Type__c = 'Labor';
//            update acnt;
//            ConvergeDispatchHandler.getContactPreference(wo.Id);
//            Test.stopTest();
//        }
//        
//    }
//    
//    @isTest
//    static void testMethod5(){
//        setupTestData();
//        
//        system.runAs(u) {
//            Test.startTest();
//            WorkOrder w = [Select Id, WorkOrderNumber from WorkOrder LIMIT 1];
//            Id woId = null;
//            ConvergeDispatchHandler.getProductClassification('');
//            ConvergeDispatchHandler.getServiceEvents(woId);
//            ConvergeDispatchHandler.getInstructions(woId);
//            ConvergeDispatchHandler.getDASPValues('');
//            // ConvergeDispatchHandler.getQueueID('test');
//            id usrId = null;
//            ConvergeDispatchHandler.getSandASUserId(usrId);
//            ConvergeDispatchHandler.getSandASUserId(u.id);
//            ConvergeDispatchHandler.getMaintenanceCalendar(woId);
//            // ConvergeDispatchHandler.timeFormat('');
//            ConvergeDispatchHandler.updateServiceEvent(wo.id,'AV');
//            ConvergeDispatchHandler.userProfile(usrId);
//            ConvergeDispatchHandler.userProfile(u.id);
//            ConvergedAvailableOptions__x options = new ConvergedAvailableOptions__x(
//            ServiceHours__c='10x5',ServiceLevel__c='Next Business Day',
//                AvailableOption__c='Next Business Day-10x5',BestAvailableOption__c='Next Business Day-10x5',
//                AvailableOptionRank__c='Next Business Day-10x5',BestAvailableOptionRank__c='Next Business Day-10x5'
//                ,AvailableOptionPeriodRank__c='Next Business Day-10x5',BestAvailableOptionPeriodRank__c = 'Next Business Day-10x5' );
//            ConvergeDispatchHandler.mockedServiceOptions.add(options);
//            ConvergeDispatchHandler.getServiceOptions('Labor Only','','','MA','MA','12323','test','US','Yes',true, true, w.WorkOrderNumber);
//            ConvergeDispatchHandler.getSpecialOptions('', '','','','', '','', '');
//            SpecialOptions__x spcOptions = new SpecialOptions__x(ServiceSubType__c='Parts Only',
//                                                                 ServiceLevel__c='Next Business Day',SpecialOption__c='option1',
//                                                                ServiceType__c='Parts Only', ServiceHours__c='10x5', Country__c='US',
//                                                                OconusFederalFlag__c='', ServiceBuid__c='8217', ServiceProvider__c='UNISYS');
//            ConvergeDispatchHandler.mockedSpecialOptions.add(spcOptions);
//            
//            ConvergeDispatchHandler.getSpecialOptions('Labor', 'Labor Only','','MA','MA', '','8217', 'UNISYS');
//            ConvergeDispatchHandler.getSpecialOptions('', '','','','', '','', '');
//            
//            ConvergeDispatchHandler.isGCCuser();
//            wo.Status='Awaiting acknowledgement';
//            update wo;
//            ConvergeDispatchHandler.fetchStatusFieldsData(wo.id);
//            wo.Status='Cancellation Request';
//            update wo;
//            ConvergeDispatchHandler.fetchStatusFieldsData(wo.id);
//            //ConvergeDispatchHandler.getQueueID('');
//            Test.stopTest();
//        }
//        
//    }
//    @isTest
//    static void testMethod6(){
//        setupTestData();
//        system.runAs(u) {
//            Test.startTest();
//            PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Work_Order_GCC_User'];
//            insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id );
//            
//            WorkOrder workorder = [select id, status from WorkOrder where id=:wo.id];
//            workorder.status = 'Problem';
//            ConvergeDispatchHandler.GCCEditCheck(wo.Id);
//            ConvergeDispatchHandler.fetchStatusFieldsData(workorder.id);
//            wo.Status='Awaiting acknowledgement';
//            update wo;
//            ConvergeDispatchHandler.fetchStatusFieldsData(wo.id);
//            wo.Status='Service Complete';
//            update wo;
//            ConvergeDispatchHandler.fetchStatusFieldsData(wo.id);
//            wo.Status='Delay/Service Interruption';
//            update wo;
//            ConvergeDispatchHandler.fetchStatusFieldsData(wo.id);
//            Test.stopTest();
//        }
//        
//    }
//    
//    @isTest
//    static void testMethod7(){
//        setupTestData();
//        system.runAs(u) {
//            Test.startTest();
//            List<String> pplist = new List<String>();
//            pplist.add('123TEST12345678');
//            pplist.add('123TEST123456789');
//            pplist.add('123TEST123456780');
//            ValidateReturnParts__x  AutovalidateParts = new ValidateReturnParts__x(PartNumber__c='PART1',
//                                                                                   ResponseMessage__c='100', 
//                                                                                   ResponseCode__c='100', ValidPart__c='PART1',
//                                                                                   ItemExists__c='Y', FunctionalDescription__c='PART1');
//             ConvergeDispatchHandler.mockAutovalidateParts.add(AutovalidateParts);
//            ConvergeDispatchHandler.validatePPID(pplist,'8021');
//            ConvergeDispatchHandler.entitlementADDetails('71T172S');
//            ConvergeDispatchHandler.getServiceOptions(null,null,null,null,null,null,null,null,null,null,null,null);
//              wo.Status='Delay/Service Interruption';
//            update wo;
//            ConvergeDispatchHandler.fetchStatusFieldsData(wo.id);
//            wo.Status='Pending Review';
//             update wo;
//            ConvergeDispatchHandler.fetchStatusFieldsData(wo.id);
//            PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Work_Order_GCC_User'];
//            insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id );
//            ConvergeDispatchHandler.fetchStatusFieldsData(wo.id);
//            
//            Test.stopTest();
//        }
//        
//    }
//     
//    @isTest
//    static void testMethod8(){
//        setupTestData();
//        
//        system.runAs(u) {
//            Test.startTest();
//            DispatchDefaults__c dd = new DispatchDefaults__c(Service_Options_Picklist_values__c = 'NextDay-8x5', Service_Type__c = 'Parts Only',
//            PO_Number__c = '18458', selected_service_option__c = 'Available-24x5', OutOfWarranty__c = True,
//            Service_Configurations__c = 'XPS Notebooks', SpecialOptions__c = 'CBBF', Bill_To__c = 'Customer',
//            Keep_Your_Components__c = True, Bill_To_Order_Number__c = 'test Order Number',
//            AvailableCoverages__c = '|| Available-24x5 || NextDay-8x5 ||', CompleteCareOption__c = True,
//            OrderNumber__c = '124563', Work_Order__c = wo.Id, AD_Override__c = 'CSAT', DPSType__c = 'test', DefaultDPSType__c = 'test',
//            CallType__c = 'test', DefaultCallType__c = 'test', ServiceLevel__c = 'test', ServiceHours__c = 'test',
//            Billable__c = 'Y', KYHDOption__c = true, OconusDispatch__c = 'N', PremierCode__c = 'yy', OutOfHours__c = true,BasicEntitlement__c=true);
//            insert dd;
//            ConvergeDispatchHandler.hideLaborButton(wo.id);
//            dd.Service_Type__c='Parts and Labor';
//            update dd;
//            ConvergeDispatchHandler.hideLaborButton(wo.id);
//            wo.Bill_To__c='Customer';
//            wo.Status='Cancellation Request';
//            wo.CheckForServiceTypeEqualsLaborOnly__c=true;
//            update WO;
//            ConvergeDispatchHandler.fetchStatusFieldsData(wo.id);
//            ConvergeDispatchHandler.checkLaborDisplayView(wo.id);
//            ConvergeDispatchHandler.hideLaborButton(wo.id);
//             PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Work_Order_GCC_User'];
//            insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id );
//            ConvergeDispatchHandler.fetchStatusFieldsData(wo.id);
//            Test.stopTest();
//        }
//        
//    }
//     @isTest
//    static void testMethod9(){
//        setupTestData();
//        system.runAs(u) {
//            Test.startTest();
//             Maintenance_Calendar__c mainCal = new Maintenance_Calendar__c(
//            Day__c='Monday;Tuesday',End_Time__c=Time.newInstance(1, 3, 4, 5),
//            Start_Time__c=Time.newInstance(1, 2, 3, 4), 
//            Account__c=acnt.id       
//        );
//        
//        insert mainCal;
//             ConvergeDispatchHandler.getMaintenanceCalendar(acnt.id);
//             wo.Status='Problem';
//              wo.Service_Type__c='Parts and Labor';
//             wo.Bill_To__c='Customer';
//            update wo;
//             ConvergeDispatchHandler.checkLaborDisplayView(wo.id);
//            ConvergeDispatchHandler.fetchStatusFieldsData(wo.id);
//            PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Work_Order_GCC_User'];
//            insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id );
//            ConvergeDispatchHandler.fetchStatusFieldsData(wo.id);
//            Test.stopTest();
//        }
//        
//    }
//    @isTest
//    static void testMethod10(){
//        setupTestData();
//        system.runAs(u) {
//            Test.startTest();
//            PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Work_Order_GCC_User'];
//            insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id );
//            
//            WorkOrder workorder = [select id, status from WorkOrder where id=:wo.id];
//            workorder.status = 'Rework';
//            ConvergeDispatchHandler.fetchStatusFieldsData(workorder.id);
//            wo.Status='Approved';
//            update wo;
//            ConvergeDispatchHandler.fetchStatusFieldsData(wo.id);
//            wo.Status='Open';
//            update wo;
//            ConvergeDispatchHandler.fetchStatusFieldsData(wo.id);
//            wo.Status='Cancelled';
//            update wo;
//            ConvergeDispatchHandler.fetchStatusFieldsData(wo.id);
//            Test.stopTest();
//        }
//        
//    }
//    @isTest
//    static void testMethod11(){
//  
//    
//         List<ServiceAppointment> serviceRecords = new List<ServiceAppointment>();
//        // get service address
//        serviceRecords = [ Select Id, GSCV_Address__c From ServiceAppointment Where Work_Order__c =: wo.id ];
//        serviceRecords[0].GSCV_Address__c = gccadd.Id;
//        update serviceRecords;
//        ConvergeDispatchHandler.getServiceAddressInfo(wo.id, acnt.Id);
//       
//        DispatchDefaults__c dd = new DispatchDefaults__c(Service_Options_Picklist_values__c = 'NextDay-8x5', Service_Type__c = 'Parts Only',
//            PO_Number__c = '18458', selected_service_option__c = 'Available-24x5', OutOfWarranty__c = True,
//            Service_Configurations__c = 'XPS Notebooks', SpecialOptions__c = 'CBBF', Bill_To__c = 'Customer',
//            Keep_Your_Components__c = True, Bill_To_Order_Number__c = 'test Order Number',
//            AvailableCoverages__c = '|| Available-24x5 || NextDay-8x5 ||', CompleteCareOption__c = True,
//            OrderNumber__c = '124563', Work_Order__c = wo.id, AD_Override__c = 'CSAT', DPSType__c = 'test', DefaultDPSType__c = 'test',
//            CallType__c = 'test', DefaultCallType__c = 'test', ServiceLevel__c = 'test', ServiceHours__c = 'test',
//            Billable__c = 'Y', KYHDOption__c = true, OconusDispatch__c = 'N', PremierCode__c = 'yy', OutOfHours__c = true,BasicEntitlement__c=true);
//            insert dd;
//        ConvergeDispatchHandler.getDispatchDefaults(wo.id);
//        
//        
//        ConvergeDispatchHandler.timeFormat('1584446400');
//        
//        wo.S_AS_Queue__c = 'Other';
//        wo.Unscheduled_Reason__c = 'Site Access Consolidation Pending';
//        update  wo;
//        
//        ConvergeDispatchHandler.changeWorkOrderOwnerInElevatedQueue(wo.id, u.id);
//        
//        Test.stopTest();
//    }
//    @isTest
//    static void getContactPreference_Test(){
//        setupTestData();
//        
//        system.runAs(u) {
//            Test.startTest();
//            Id woid = null;
//            Account acntTest = [Select Id, Site_Access_Required__c, Customer_Confirmation_Required__c, Site_Access_Requirement_Type__c, Max_Min_Resource_Limit__c FROM Account LIMIT 1];
//            acntTest.Site_Access_Required__c = 'Yes';
//            acntTest.Customer_Confirmation_Required__c = 'Yes';
//            acntTest.Site_Access_Requirement_Type__c = 'Labor';
//            acntTest.Max_Min_Resource_Limit__c = '1';
//            update acntTest;
//            //User != null, Contact and Permit = null
//            Preference__c prefTest = new Preference__c();
//            prefTest.Contact_Type__c = 'Resource';
//            prefTest.Preference_Type__c = 'Permanent Access Resource';
//            prefTest.Contact__c = null;
//            prefTest.Account__c= acntTest.id;
//            prefTest.Permit__c = null;
//            prefTest.User__c = u.Id;
//            insert prefTest;
//            Integer prefCount = [Select Count() From Preference__c Where Preference_Type__c = 'Permanent Access Resource' And Account__c =:  acntTest.Id];
//        
//            system.assertEquals(Integer.valueOf(acntTest.Max_Min_Resource_Limit__c), prefCount);        
//            ConvergeDispatchHandler.getContactPreference(wo.id);
//            Test.stopTest();
//        }
//    }
//    @isTest
//    static void getServiceAddressInfo_Test(){
//        setupTestData();
//        system.runAs(u) {
//            Test.startTest();
//    
//        
//            acntTest.BillingCountry = 'United States';
//            acntTest.BillingCountryCode = 'US';
//            acntTest.BillingStateCode = 'TX';
//            acntTest.BillingCity = 'ANDREWS';
//            acntTest.BillingPostalCode = '79714';
//            acntTest.BillingStreet = '200 S LAUREL AVE';
//            update acntTest;
//
//            Address_Data_GCC__c gccTest = new Address_Data_GCC__c(Name = acntTest.BillingCity, 
//                                                                  COUNTRYCODE__c = acntTest.Billing_Country__c,
//                                                                  POSTCODE__c = acntTest.BillingStateCode,
//                                                                  COUNTRYNAME__c = 'United States',
//                                                                  STATENAME__c = 'TEXAS',
//                                                                  STATECODE__c = 'TX');
//            insert gccTest;
//            ConvergeDispatchHandler.getServiceAddressInfo(wo.id, acntTest.id);
//            Address_Data_GCC__c gccRecord = [ Select Id, COUNTRYNAME__c, COUNTRYCODE__c, STATENAME__c, STATECODE__c, Name, POSTCODE__c
//                          From Address_Data_GCC__c 
//                          Where COUNTRYCODE__c =: acntTest.Billing_Country__c 
//                          AND Name =: acntTest.BillingCity 
//                          AND POSTCODE__c =: acntTest.BillingStateCode Limit 1 ];
//            gccRecord.POSTCODE__c='79714';
//            update gccRecord;
//            ConvergeDispatchHandler.getServiceAddressInfo(wo.id, acntTest.id);            
//            Test.stopTest();
//        }
//    }
//    @isTest
//    static void updateShippingDetails_Test(){
//        setupTestData();
//        system.runAs(u) {
//            Test.startTest();
//            ast.Address_Line_1__c = 'Test 1';
//            ast.Address_Line_2__c = 'Test 2';
//            ast.Country__c = 'US'; 
//            update ast;
//            acnt.Account_Identifier__c = 'S360';
//            acnt.Shipping_country__c = 'United States';
//            acnt.ShippingCountry = 'United States';
//            acnt.ShippingCountryCode = 'US';
//            acnt.ShippingPostalCode = '79714';
//            acnt.ShippingStreet = '200 S LAUREL AVE';
//            acnt.Shipping_Street_2__c = 'Test 3';
//            acnt.ShippingState = null;
//            acnt.ShippingCity = null;
//            update acnt;
//            ConvergeDispatchHandler.updateShippingDetails(wo.id);
//    
//        }
//    }
//    @isTest
//    static void getProductClassification_Test(){
//        setupTestData();
//        
//        system.runAs(u) {
//            Test.startTest();
//            ConvergeDispatchHandler.getProductClassification('4SS');
//            ConvergeDispatchHandler.getProductClassification('Test');
//            Test.stopTest();
//        }
//    }
//    @isTest
//    static void timeFormat_Test(){
//        setupTestData();
//        
//        system.runAs(u) {
//            Test.startTest();
//            String timeTest;
//            timeTest = ConvergeDispatchHandler.timeFormat('0084446400');
//        
//        
//        }
//        
//    }
//    @isTest
//    static void validatePPID_Test(){
//        setupTestData();
//        system.runAs(u) {
//            Test.startTest();
//            List<String> pplist = new List<String>();
//            pplist.add('123TEST12345678');
//            pplist.add('123TEST123456789');
//            pplist.add('123TEST123456780');
//            ValidateReturnParts__x  AutovalidateParts1 = new ValidateReturnParts__x(PartNumber__c='TEST1',
//                                                                                   ResponseMessage__c='100', 
//                                                                                   ResponseCode__c='100', ValidPart__c='true',
//                                                                                   ItemExists__c='Y', FunctionalDescription__c='PART1');
//            ConvergeDispatchHandler.mockAutovalidateParts.add(AutovalidateParts1);
//            ValidateReturnParts__x  AutovalidateParts2 = new ValidateReturnParts__x(PartNumber__c='TEST1',
//                                                                                   ResponseMessage__c='100', 
//                                                                                   ResponseCode__c='100', ValidPart__c='false',
//                                                                                   ItemExists__c='Y', FunctionalDescription__c='PART1');
//            ConvergeDispatchHandler.mockAutovalidateParts.add(AutovalidateParts2);
//            ValidateReturnParts__x  AutovalidateParts3 = new ValidateReturnParts__x(PartNumber__c='PART1',
//                                                                                   ResponseMessage__c='100', 
//                                                                                   ResponseCode__c='100', ValidPart__c='false',
//                                                                                   ItemExists__c='Y', FunctionalDescription__c='PART1');
//            ConvergeDispatchHandler.mockAutovalidateParts.add(AutovalidateParts3);
//            ConvergeDispatchHandler.validatePPID(pplist,'8021');
//            Test.stopTest();
//        }
//    }
//    @isTest
//    static void fetchWorkOrderOwnerInElevatedQueue_Test(){
//        setupTestData();
//        system.runAs(u) {
//            Test.startTest();
//            WorkOrder relatedWo = SRVS_CreateTestDataFactory.createSingleWorkOrder(ast.id,acnt.id,co.id, cse.id);
//            relatedWo.Subject = 'test tnqjnyghdqajkx';
//            relatedWo.status = 'Work In Progress';
//            relatedWo.Sub_Status__c='';
//            relatedWo.AddressBUID__c = '';
//            relatedWo.DLP__c = '';//need to check value
//            relatedWo.Region__c = '1';
//            relatedWo.DPS_Sub_Region__c = 'LA';
//            relatedWo.Service_Option__c = 'Next Business Day-8x5';
//            relatedWo.Service_Type__c = 'Parts Only';
//            relatedWo.StateCode__c = 'NY';
//            relatedWo.PostalCode = '10065';
//            relatedWo.DSP__c = 'CLICK';
//            relatedWo.CountryCode = 'US';
//            relatedWo.DPS_Region__c = 'AMERICAS';
//            relatedWo.Ground_Shipment_Flag__c = false;
//            relatedWo.City_APJ__c = 'NEW YORK';
//            relatedWo.KYC__c = false;
//            relatedWo.KYHD__c = false;
//            relatedWo.S_AS_Queue__c = 'Other';
//            relatedWo.Unscheduled_Reason__c = 'Site Access Consolidation Pending';
//            relatedWo.WO_Type__c ='Parts Only';
//            relatedWo.City = '';
//            relatedWo.Latitude = null;
//            relatedWo.Longitude = null;
//            relatedWo.State__c='NY';
//            relatedWo.Onsite_Stocking_Location__c = 'NY';
//            relatedWo.Timezone__c = 'USABCDEF';
//            relatedWo.AD_Count__c = 1;
//            relatedWo.AssetId = ast.id;
//            relatedWo.Schedule_Enable_Flag__c='Y';
//            relatedWo.EntitlementStartDate__c = String.valueOf(DateTime.now());
//            relatedWo.EntitlementEndDate__c = String.valueOf(DateTime.now());
//            insert relatedWo;
//            ConvergeDispatchHandler.fetchWorkOrderOwnerInElevatedQueue(wo.Id, u.Id);
//            ConvergeDispatchHandler.changeWorkOrderOwnerInElevatedQueue(wo.Id, u.Id);
//            
//            Test.stopTest();
//        }
//    }
//    
//    
//    @isTest static void testUpdateReschedulingDates(){
//        setupTestData();
//        List<ServiceAppointment> resSA = new List<ServiceAppointment>();
//        system.runAs(u) {
//        Test.startTest();
//            WorkOrder wo = [Select Id from WorkOrder Limit 1];
//            String ServiceDate = 'Thu, Apr 23, 2020, 05:12AM - Sat, Apr 25, 2020, 10:15AM';
//            String starDateTime = '2020-04-23T05:12:00+02:00';
//            String endDateTime = '2020-04-25T10:15:00+02:00';   
//            resSA = ConvergeDispatchHandler.UpdateReschedulingDates(wo.Id,ServiceDate,starDateTime,endDateTime,starDateTime,endDateTime); 
//        Test.stopTest();
//        // System.assertEquals(true, resSA.size() > 0, 'Updated scheduling dates successfully');
//        }
//    }
//
//    @isTest static void testGetRescheduleDetails(){
//        setupTestData();
//        system.runAs(u) {
//            Test.startTest();
//            WorkOrder wo = [Select Id from WorkOrder Limit 1];
//            wo.Service_Type__c = 'Parts and Labor';
//            wo.PDL_Type__c = 'Test';
//            wo.Parts_Status__c = 'Open';
//            update wo;
//            ConvergeDispatchHandler.getRescheduleDetails(wo.Id); 
//            ServiceAppointment sa = [Select Id from ServiceAppointment where Work_Order__c =:wo.Id Limit 1];
//            sa.Event_Type__c = 'Part Pick Up';
//            update sa;
//            ConvergeDispatchHandler.getRescheduleDetails(wo.Id); 
//            Test.stopTest();
//        }
//    }          
}