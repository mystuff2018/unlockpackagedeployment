@isTest
public class SearchResourcesController_Test {
    public static list<Contact>contactList;
    @testSetup static void setup() {
        Id userID  =  UserInfo.getUserId();
        // Create User
        User user1 = TestDataUtility.getUser('standarduser@dell.com');
        //   insert user1;
        
System.runAs(user1){
                   
            /* Commented by Siva this custom setting is not present in Org
            //Create Custom Domain
            TestDataUtility.createDomainSettings(1,false, true);
            */
            
            // Create Practice
            pse__Practice__c practice = TestDataUtility.getPractice(True);
            
            // Create Skills And Certification
            pse__Skill__c skills = TestDataUtility.getCertification(true);
            //Create region
            pse__Region__c region = TestDataUtility.getRegion(True);
          
            pse__Permission_Control__c pc = TestDataUtility.getPermissionControl(userID,region.id,false);
            pc.pse__Resource_Request_Entry__c = true;
            pc.pse__Staffing__c = true;
            insert pc;
            pse__Permission_Control__c pc2 = TestDataUtility.getPermissionControl(UserInfo.getUserId(),region.id,false);
            pc2.pse__Resource_Request_Entry__c = true;
            pc2.pse__Staffing__c = true;
            insert pc2;
        
            Id RecordTypeIdContact = Schema.SObjectType.pse__Skill__c.getRecordTypeInfosByName().get('Skill').getRecordTypeId();
            List<pse__Skill__c> skillsList = new List<pse__Skill__c>();
            List<pse__Skill__c> skillsListData = TestDataUtility.getSkills(5,false);
            for(pse__Skill__c skill : skillsListData){
                skill.recordtypeid = RecordTypeIdContact;
                skillsList.add(skill);
            }
            insert skillsList;
            
            //Create Account
            Account acc = TestDataUtility.createAccounts(5,false)[0];
            acc.ShippingLatitude = 26.9561696;
            acc.ShippingLongitude = 75.7104891;
          //  insert acc;
            
            // Create Project 
            pse__Proj__c project = TestDataUtility.createProject(false);    
            project.PDM__c = user1.Id;
            project.pse__Region__c = region.Id;
            project.pse__Account__c = acc.Id;
            insert project;
            
            pse__Permission_Control__c pc1 = TestDataUtility.getPermissionControl(UserInfo.getUserId(), null, false);
            pc1.pse__Resource_Request_Entry__c = true;
            pc1.pse__Staffing__c = true;
            pc1.pse__Project__c = project.Id;
            insert pc1; 
            
            //create resouce request
            pse__Resource_Request__c resourceRequest = TestDataUtility.getResourceRequest(false);
            resourceRequest.pse__Region__c = region.id;
            resourceRequest.pse__Project__c =  project.Id;
            resourceRequest.pse__Start_Date__c = Date.today();
            resourceRequest.pse__End_Date__c = Date.today()+15;
            resourceRequest.pse__Requested_Bill_Rate__c = 50;
            insert resourceRequest;
            //create work calendar
            pse__Work_Calendar__c wc = TestDataUtility.createWorkCalender(True);
            //Create holiday
            TestDataUtility.createHoliday(wc.id,True);
            contactList = TestDataUtility.createContacts(5,acc.id,false,True);
            integer i =0;
            for(Contact con : contactList){
                if(i == 0)
                con.pse__Salesforce_User__c = user1.Id;
                con.MailingStreet = 'Revendell Street';
                con.MailingCity = 'Edision';
                //con.MailingState= '';
                con.MailingCountry = 'United States';
                con.MailingPostalCode = '302021';
                con.pse__Resource_Role__c = 'Consultant';
                con.pse__Work_Calendar__c = wc.id;
                con.pse__Region__c = region.id; 
                con.MailingLatitude =26.8503054 ;
                con.MailingLongitude = 75.8003968;
				con.Phone='9876541234';
                i++;
            }
            insert contactList;      
            
            Id skillRecordTypeId = Schema.SObjectType.pse__Skill__c.getRecordTypeInfosByName().get('Skill').getRecordTypeId();
            pse__Skill__c testSkill = new pse__Skill__c();
            testSkill.recordTypeId = skillRecordTypeId;
            testSkill.Name = 'Test Skills1';
            testSkill.pse__External_Id__c = 'abcdef12345ghi';
            insert testSkill;
            
            //      pse__Skill__c testSkill = [SELECT ID FROM pse__Skill__c limit 1];
            TestDataUtility.getResourceRequestSkill(true, testSkill.Id, resourceRequest.Id);  
        }
        
    }
    static testMethod void  testAdjustHoursScheduleForAssign(){      
        pse__Resource_Request__c resourceRequest = [Select id,pse__Start_Date__c,pse__End_Date__c,pse__Resource_Role__c,
                                                    pse__SOW_Hours__c, pse__Status__c, pse__Requested_Bill_Rate__c from pse__Resource_Request__c limit 1];
        
        Contact con = [select id from Contact limit 1];
        Map<String,pse__Schedule__c> schduleMap = SearchResourcesController.adjustHoursSchedule(resourceRequest,con.id);
        System.assertNotEquals(null, schduleMap);
        insert schduleMap.values();
        System.debug('schduleMap1:::::'+schduleMap);
        pse__Region__c region = [SELECT Id, Name FROM pse__Region__c WHERE Name = 'Test'];
        Account acc = TestDataUtility.createAccounts(1,false)[0];
        acc.Name = 'Test Assign Account';
        acc.ShippingLatitude = 26.9561696;
        acc.ShippingLongitude = 75.7104891;
       // insert acc;
        pse__Proj__c project = TestDataUtility.createProject(false); 
        project.pse__Region__c = region.Id;
        project.pse__Account__c = acc.Id;
        insert project;
        resourceRequest.pse__Status__c ='Hold';
        resourceRequest.pse__Preferred_Schedule__c = schduleMap.get('CalculateEndDateIgnoreAvailability').Id;
        resourceRequest.pse__Planned_Bill_Rate__c = 100;
        resourceRequest.pse__Requested_Bill_Rate__c = 200;
        resourceRequest.pse__Resource__c = con.Id;
        //resourceRequest.pse__SOW_Hours__c = 100;
        resourceRequest.pse__Project__c = project.Id;
        update resourceRequest;
        System.debug('resourceRequest::::Assign'+resourceRequest);
       /* commented by siva below method not there in cls*/
        String sch = SearchResourcesController.assignHoldSchedulePatterns(schduleMap, 'CalculateEndDateIgnoreAvailability', con.Id, resourceRequest, 'assign',null);
        System.assertNotEquals(null, sch);

    }
    static testMethod void  testAdjustHoursScheduleForHold(){        
        pse__Resource_Request__c resourceRequest = [Select id,pse__Start_Date__c,pse__End_Date__c,pse__Resource_Role__c,
                                                    pse__SOW_Hours__c, pse__Status__c, pse__Requested_Bill_Rate__c from pse__Resource_Request__c limit 1];
        
        Contact con = [select id from Contact limit 1];
        Map<String,pse__Schedule__c> schduleMap = SearchResourcesController.adjustHoursSchedule(resourceRequest,con.id);
        System.assertNotEquals(null, schduleMap);
        System.debug('schduleMap2:::::'+schduleMap);
        insert schduleMap.values();
        resourceRequest.pse__Status__c ='Hold';
        resourceRequest.pse__Preferred_Schedule__c = schduleMap.get('CalculateEndDateIgnoreAvailability').Id;
        resourceRequest.pse__Planned_Bill_Rate__c = 100;
        resourceRequest.pse__Requested_Bill_Rate__c = 200;
        resourceRequest.pse__Requested_Bill_Rate__c = 200;
        resourceRequest.pse__Requested_Bill_Rate__c = 200;
        update resourceRequest;
      /* commented by Siva*/
        String sch = SearchResourcesController.assignHoldSchedulePatterns(schduleMap, 'CalculateEndDateLevelSchedule', con.Id, resourceRequest, 'hold',null);
        System.assertNotEquals(null, sch);
        String sch2 = SearchResourcesController.assignHoldSchedulePatterns(schduleMap, 'Custom', con.Id, resourceRequest, 'hold',null);
        String sch3 = SearchResourcesController.assignHoldSchedulePatterns(schduleMap, 'ZeroHourSchedule', con.Id, resourceRequest, 'hold',null);
}
    static testMethod void  testAdjustHoursScheduleForRelease(){
        pse__Region__c region = [SELECT Id, Name FROM pse__Region__c WHERE Name = 'Test'];
        pse__Resource_Request__c resourceRequest = [Select id,pse__Start_Date__c,pse__End_Date__c,pse__Resource_Role__c,
                                                    pse__SOW_Hours__c, pse__Status__c, pse__Requested_Bill_Rate__c from pse__Resource_Request__c limit 1];
        
        Contact con = [select id from Contact limit 1];
        Map<String,pse__Schedule__c> schduleMap = SearchResourcesController.adjustHoursSchedule(resourceRequest,con.id);
        System.assertNotEquals(null, schduleMap);
        System.debug('schduleMap3:::::'+schduleMap);
        insert schduleMap.values();
        Account acc = TestDataUtility.createAccounts(1,false)[0];
        acc.Name = 'Test Release Account';
        acc.ShippingLatitude = 26.9561696;
        acc.ShippingLongitude = 75.7104891;
       // insert acc;
        pse__Proj__c project = TestDataUtility.createProject(false); 
        project.pse__Region__c = region.Id;
        project.pse__Account__c = acc.Id;
        insert project;
        pse__Assignment__c testAssign = TestDataUtility.getAssignment(project.Id, con.Id, 0, false);
        testAssign.Name = 'Test Release';
        testAssign.pse__Schedule__c = schduleMap.get('CalculateEndDateIgnoreAvailability').Id;
        insert testAssign;
        resourceRequest.pse__Status__c ='Hold';
        resourceRequest.pse__Preferred_Schedule__c = schduleMap.get('CalculateEndDateIgnoreAvailability').Id;
        resourceRequest.pse__Planned_Bill_Rate__c = 100;
        resourceRequest.pse__Requested_Bill_Rate__c = 200;
        resourceRequest.pse__Staffer_Resource__c = con.Id;
        resourceRequest.pse__Assignment__c = testAssign.Id;
        update resourceRequest;
        /* commented by Siva below method is not there in cls*/
        String sch = SearchResourcesController.assignHoldSchedulePatterns(schduleMap, 'ZeroHourSchedule', con.Id, resourceRequest, 'release',null);
        System.assertNotEquals(null, sch);  

    }
    
    static testMethod void  testSearchDetails11(){
        SearchResourcesController.ColumnsSettings cs = new SearchResourcesController.ColumnsSettings();
        cs = SearchResourcesController.DisplayColumns1('Contact','Search_Resource_Screen');
        system.assert(cs.columns.size() > 0);
    }
    
    
    static testMethod void  testSearchDetails(){
        Contact con = [select id, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, Name, pse__Resource_Role__c from Contact limit 1];
        pse__Resource_Request__c resourceRequest = [Select id, Name, pse__Start_Date__c,pse__End_Date__c,pse__Resource_Role__c, SearchFilterForPDM__c,
                                                    pse__SOW_Hours__c, pse__Resource_Request__c.pse__Project__r.PDM__c from pse__Resource_Request__c limit 1];
        pse__Skill__c skills = [Select Id, name FROM pse__Skill__c limit 1];
        pse__Skill__c certifications = [Select Id, name FROM pse__Skill__c limit 1];
        SearchResourcesController.SearchDetails wrapper = new SearchResourcesController.SearchDetails();
        wrapper.street = con.MailingStreet;
        //     wrapper.resourceRequestName = 'Test';
        wrapper.city = con.MailingCity;
        wrapper.state = con.MailingState;
        wrapper.country =con.MailingCountry;
        wrapper.zipCode = con.MailingPostalCode;
        wrapper.startDate = String.valueOf(Date.today());
        wrapper.endDate = String.valueOf(Date.today());
        wrapper.name = con.Name;
        wrapper.resourceRequestName = resourceRequest.Name;
        wrapper.role = con.pse__Resource_Role__c;
        wrapper.workedWithCustomer = true;
        wrapper.availability =true;
        wrapper.availabilityValue = 'No Assignments';
        wrapper.internal = true;
        wrapper.internalValue = 'Yes';
        wrapper.distance = false;
        wrapper.distanceValue = '10';
        wrapper.customSettingValue =false;
        //wrapper.filterSkillLogic = 'Test Wrapper';
        wrapper.regionFilter = 'Equals';
        wrapper.regionValue = 'Test';
        wrapper.practiceFilter = 'Equals';
        wrapper.practiceValue = 'Test';
        wrapper.groupFilter = 'Equals';
        wrapper.groupValue = '';
        
        wrapper.defaultCostRateFilter = 'Less or Equals' ;
        wrapper.defaultCostRateValue = 0;
        wrapper.scheduledUtilizationFilter = 'Less or Equals';
        wrapper.openFromResourceReqScreen = false;
        wrapper.selectedResourceRequest = resourceRequest;
        wrapper.showSubmitForPdMApproval = false;
        wrapper.scheduledUtilizationValue = 10;
        wrapper.filterLogicCertification = 'And';
        
        list<SearchResourcesController.SkillCertificationSet> wrapperSkillListCertification = new list<SearchResourcesController.SkillCertificationSet>();
        SearchResourcesController.SkillCertificationSet wrapperSkillCertification = new SearchResourcesController.SkillCertificationSet();
        wrapperSkillCertification.skillCertification = skills;
        wrapperSkillCertification.showAndOrOperator = false;
        wrapperSkillCertification.index = 0;
        wrapperSkillCertification.skillExp = '';
        wrapperSkillCertification.andOrOperator = '';
        wrapperSkillCertification.isSelected= false;
        wrapperSkillListCertification.add(wrapperSkillCertification);
        wrapper.lstSkill = wrapperSkillListCertification;
        wrapper.lstCertification = wrapperSkillListCertification;
        wrapper.projlatitude = 100;
        wrapper.projLogitude = 100;
        wrapper.distance = true;
        SearchResourcesController.Response reponsewrapper = new SearchResourcesController.Response();
        reponsewrapper.responseCode = '404';
        reponsewrapper.responseMessage= 'Not Found';
        //Test.startTest();
        SearchResourcesController.ContactPageWrapper obj =  new SearchResourcesController.ContactPageWrapper();
        obj = SearchResourcesController.getFilteredContacts(wrapper, 1 ,5);
        System.assertNotEquals(null, obj);
        Wrapper.defaultCostRateFilter = 'Less';
        Wrapper.scheduledUtilizationFilter = 'Less';
        SearchResourcesController.ContactPageWrapper obj2 =  new SearchResourcesController.ContactPageWrapper();
        obj2 = SearchResourcesController.getFilteredContacts(wrapper, 1 ,5);
        
        SearchResourcesController.SearchDetails wrapperSearchDetails = new SearchResourcesController.SearchDetails();
        System.assertNotEquals(null, wrapperSearchDetails);
        
        list<SearchResourcesController.SkillCertificationSet> wrapperSkillListCertification2 = new list<SearchResourcesController.SkillCertificationSet>();
        SearchResourcesController.SkillCertificationSet wrapperSkillCertification2 = new SearchResourcesController.SkillCertificationSet();
        wrapperSkillCertification2.skillCertification = skills;
        wrapperSkillCertification2.showAndOrOperator = false;
        wrapperSkillCertification2.index = 0;
        wrapperSkillCertification2.skillExp = '';
        wrapperSkillCertification2.andOrOperator = '';
        wrapperSkillCertification2.isSelected= false;
        wrapperSkillListCertification2.add(wrapperSkillCertification);
        wrapperSearchDetails.lstSkill = wrapperSkillListCertification2;
        wrapperSearchDetails.lstCertification = wrapperSkillListCertification2;
        
        
        SearchResourcesController.SearchDetails searchDetailsSkill = SearchResourcesController.getSearchDetails(resourceRequest.Id);
        System.assertNotEquals(null, searchDetailsSkill);
        
        Id certificationRecordTypeId = Schema.SObjectType.pse__Skill__c.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
        pse__Skill__c testCert = TestDataUtility.getCertification(false);
        testCert.recordTypeId = certificationRecordTypeId;
        testCert.Name = 'Test Certification New';
        testCert.pse__External_Id__c = 'sdfj123';
        insert testCert;
        TestDataUtility.getResourceRequestSkill(true, testCert.Id, resourceRequest.Id);
        SearchResourcesController.SearchDetails searchDetailsCertification = SearchResourcesController.getSearchDetails(resourceRequest.Id);
        System.assertNotEquals(null, searchDetailsCertification);
        
        resourceRequest.SearchFilterForPDM__c = JSON.serialize(wrapperSearchDetails);
        update resourceRequest;
        SearchResourcesController.SearchDetails getsearchDetailsWrapper = SearchResourcesController.getSearchDetails(resourceRequest.Id);
        System.assertNotEquals(null, getsearchDetailsWrapper);
        
        List<pse__Resource_Request__c> resourceReqList = SearchResourcesController.getResourceRequests(resourceRequest.name);
        pse__Region__c pseRegion = [Select id, Name from pse__Region__c limit 1];
        List<pse__Region__c>regionList =  SearchResourcesController.getRegions(pseRegion.name);
        System.assertNotEquals(null, regionList);
        
        pse__Practice__c practice = [Select id, Name from pse__Practice__c limit 1];
        List<pse__Practice__c>practiceList =  SearchResourcesController.getPractices(practice.name);
        System.assertNotEquals(null, practiceList);
        
        resourceRequest.pse__Status__c = 'Approval Pending';
        String str = SearchResourcesController.submitForApprovalPDM(resourceRequest , wrapper );
        System.assertNotEquals(null, str);
        
        
        List<pse__Skill__c> skillsList = SearchResourcesController.getSkillsCertifications('Skill',  wrapperSkillListCertification, 'test');
        System.assertNotEquals(null, skillsList);
        List<Id> skillIdList = new List<Id>();
        pse__Skill__c testSkill = [SELECT ID FROM pse__Skill__c limit 1];
        skillIdList.add(testSkill.Id);
        List<SearchResourcesController.SkillCertificationSet> skillSetWrapper =  SearchResourcesController.getSkills(skillIdList, wrapperSkillListCertification);
        System.assertNotEquals(null, skillSetWrapper);
        
        List<Id> certIdList = new List<Id>();
        certIdList.add(testSkill.Id);            
        List<SearchResourcesController.SkillCertificationSet> certificationSetWrapper = SearchResourcesController.getCertifications(certIdList, wrapperSkillListCertification);
        System.assertNotEquals(null, certificationSetWrapper);
        
        SearchResourcesController.SearchDetails wrapperReset = new SearchResourcesController.SearchDetails();
        wrapperReset.selectedResourceRequest = resourceRequest;
        //Boolean change = SearchResourcesController.saveFilterForScreen(wrapper);
        //wrapperReset =  SearchResourcesController.resetValues();
        System.assertNotEquals(null, wrapperReset);
        
        List <pse__Resource_Request__c> resourceRequestList = [Select id,pse__Start_Date__c,pse__End_Date__c,pse__Resource_Role__c,
                                                               pse__SOW_Hours__c, pse__Status__c from pse__Resource_Request__c];
        Set<Id> assignmentOnSearchReq = SearchResourcesController.getAssignmentOnSearchReq(wrapper, resourceRequestList, String.valueOf(Date.today()), String.valueOf(Date.today()));
        List<pse__Resource_Request__c> resourceReqestList =  SearchResourcesController.getResourceReqList(wrapper);
        
        wrapper.resourceRequestName = con.Name;
        Boolean  saveFilter = SearchResourcesController.saveFilterForScreen(wrapper);
        
        List<Contact> conList  = [SELECT Id, mailinglatitude, mailinglongitude FROM Contact]; 
        pse__Work_Calendar__c testWorkCalendar = TestDataUtility.createWorkCalender(true);
        pse__HolidayObj__c testHoliday = new pse__HolidayObj__c();
        testHoliday.Name = 'Test';
        testHoliday.pse__Work_Calendar__c = testWorkCalendar.Id;
        testHoliday.pse__Date__c = Date.newInstance(2020, 07, 31);
        insert testHoliday;
        pse__HolidayObj__c testHoliday1 = new pse__HolidayObj__c();
        testHoliday1.Name = 'Test1';
        testHoliday1.pse__Work_Calendar__c = testWorkCalendar.Id;
        testHoliday1.pse__Date__c = Date.newInstance(2020, 07, 30);
        insert testHoliday1;
        pse__HolidayObj__c testHoliday2 = new pse__HolidayObj__c();
        testHoliday2.Name = 'Test2';
        testHoliday2.pse__Work_Calendar__c = testWorkCalendar.Id;
        testHoliday2.pse__Date__c = Date.newInstance(2020, 07, 29);
        insert testHoliday2;
        pse__HolidayObj__c testHoliday3 = new pse__HolidayObj__c();
        testHoliday3.Name = 'Test3';
        testHoliday3.pse__Work_Calendar__c = testWorkCalendar.Id;
        testHoliday3.pse__Date__c = Date.newInstance(2020, 08, 01);
        insert testHoliday3;
        pse__HolidayObj__c testHoliday4 = new pse__HolidayObj__c();
        testHoliday4.Name = 'Test4';
        testHoliday4.pse__Work_Calendar__c = testWorkCalendar.Id;
        testHoliday4.pse__Date__c = Date.newInstance(2020, 07, 28);
        insert testHoliday4;
        conList[0].pse__Work_Calendar__c = testWorkCalendar.Id;
        update conList[0];
      //  Account accountId = [SELECT Id FROM Account WHERE Name = 'TestAccount'  limit 1]; 
         Account accountId = TestDataUtility.createAccounts(5,false)[0];
        system.debug('mailinglatitude' + conList[0].mailinglatitude);
        system.debug('mailinglongitude' + conList[0].mailinglongitude);
        Double longitude = 26.9561696;
        Double latitude = 75.7104891;
        Location projLocation = Location.newInstance(longitude,latitude);
        Location contactLocation = Location.newInstance(conList[0].mailinglatitude,  conList[0].mailinglongitude);
        System.debug('location' + Location.getDistance(projLocation, contactLocation, 'Km'));
       /*Commented by Siva - one parameter is not there as main cls*/
        Map <ID,Contact> caldistance = SearchResourcesController.calculateDistance(conList, 'All', 'Km', latitude, longitude, true);
        caldistance = SearchResourcesController.calculateDistance(conList, 'All', 'Mi', latitude, longitude, true);
        
        Set<Id> workWithCustumer = SearchResourcesController.getWrokedWithCustomerResource(conList, accountId.Id);
        
        List<pse__Grp__c> groupList = SearchResourcesController.getGroups('test');
        
        //set<ID> skilledCertifiedContactsId = SearchResourcesController.getAllSkilledCertifiedCopntacts(conList, wrapper);
        
        SearchResourcesController.PercentageAllocationData percentWrapper = new SearchResourcesController.PercentageAllocationData(); 
        percentWrapper.startDate = Date.today();
        percentWrapper.endDate =Date.today();
        percentWrapper.percentageAllocation =50;
        percentWrapper.monHrs =8;
        percentWrapper.tueHrs = 8;
        percentWrapper.wedHrs = 8;
        percentWrapper.thrHrs = 8;
        percentWrapper.friHrs = 8;
        percentWrapper.satHrs = 0;
        percentWrapper.sunHrs = 0;
        percentWrapper.totalHours = 40;
        percentWrapper.schedule= new pse__Schedule__c(OwnerId = conList[0].Id);
        
        List<SearchResourcesController.WrapperPercentageAllocationRow> wrapperPercentageAllocationList = new List<SearchResourcesController.WrapperPercentageAllocationRow>();
        SearchResourcesController.WrapperPercentageAllocationRow wrapperPercentageAllocation =  new SearchResourcesController.WrapperPercentageAllocationRow();
        wrapperPercentageAllocation.startDate = Date.newInstance(2020, 07, 30);
        wrapperPercentageAllocation.endDate = wrapperPercentageAllocation.startDate.addDays(7);
        wrapperPercentageAllocation.percentageAllocation = 50;
        wrapperPercentageAllocation.schedule = new  Pse__Schedule__c();
        wrapperPercentageAllocation.totalHours = 100;
        wrapperPercentageAllocationList.add(wrapperPercentageAllocation);
        
        
        pse__Resource_Request__c resRequest = [SELECT ID, pse__Start_Date__c, pse__End_Date__c,pse__Resource_Role__c,
                                               pse__SOW_Hours__c, pse__Status__c, pse__Project__c, pse__Requested_Bill_Rate__c, pse__Suggested_Bill_Rate__c  from pse__Resource_Request__c];
        resRequest.pse__Start_Date__c = Date.newInstance(2020, 07, 29);
        resRequest.pse__End_Date__c = resRequest.pse__Start_Date__c.addDays(10);
        upsert resRequest;
        SearchResourcesController.PercentageAllocationData percentWrapperData  = new SearchResourcesController.PercentageAllocationData();
        percentWrapperData =  SearchResourcesController.getPercentageAllocationData(conList[0].Id,resRequest);
        
        System.debug('End Date ###' + resRequest.pse__End_Date__c);
        List<SearchResourcesController.WrapperPercentageAllocationRow> wrapperPercentageAllocationRowList = new List<SearchResourcesController.WrapperPercentageAllocationRow>();
        wrapperPercentageAllocationRowList = SearchResourcesController.updatePercentAllocationScheduleRows(resRequest, conList[0].Id, wrapperPercentageAllocationList, true, true, 'Assign',null);
        Test.startTest();
        wrapperPercentageAllocationRowList = SearchResourcesController.updatePercentAllocationScheduleRows(resRequest, conList[0].Id, wrapperPercentageAllocationList, false, false, 'Assign',null);
        wrapperPercentageAllocationRowList = SearchResourcesController.updatePercentAllocationScheduleRows(resRequest, conList[0].Id, wrapperPercentageAllocationList, false, true, 'Assign',null);

   //   SearchResourcesController.updateScheduleHours(new pse__Schedule__c().Id ,50);
        SearchResourcesController.WrapperPercentageAllocationRow percentAllocationScheduleRows =  new SearchResourcesController.WrapperPercentageAllocationRow();
        percentAllocationScheduleRows = SearchResourcesController.createPercentAllocationScheduleRows(resRequest, conList[0].Id, false, 40.0, 2);
        percentAllocationScheduleRows = SearchResourcesController.createPercentAllocationScheduleRows(resRequest, conList[0].Id, true, 40.0, 2);
        list<SearchResourcesController.WrapperPercentageAllocationRow>repList;
        repList = SearchResourcesController.getPercentAllocationRows(resRequest, conList[0].Id,repList,  false, 2);
        
        string testVar = SearchResourcesController.getPartiallyAllocatedResource();
        Test.stopTest();
        
    }
    static testMethod void  testSearchDetails2(){
        Contact con = [select id, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, Name, pse__Resource_Role__c from Contact limit 1];
        pse__Resource_Request__c resourceRequest = [Select id, Name, pse__Start_Date__c,pse__End_Date__c,pse__Resource_Role__c, SearchFilterForPDM__c,
                                                    pse__SOW_Hours__c, pse__Resource_Request__c.pse__Project__r.PDM__c from pse__Resource_Request__c limit 1];
        pse__Skill__c skills = [Select Id, name FROM pse__Skill__c limit 1];
        pse__Skill__c certifications = [Select Id, name FROM pse__Skill__c limit 1];
        SearchResourcesController.SearchDetails wrapper = new SearchResourcesController.SearchDetails();
        wrapper.street = con.MailingStreet;
        //     wrapper.resourceRequestName = 'Test';
        wrapper.city = con.MailingCity;
        wrapper.state = con.MailingState;
        wrapper.country =con.MailingCountry;
        wrapper.zipCode = con.MailingPostalCode;
        wrapper.startDate = String.valueOf(Date.today());
        wrapper.endDate = String.valueOf(Date.today());
        wrapper.name = con.Name;
        wrapper.resourceRequestName = resourceRequest.Name;
        wrapper.role = con.pse__Resource_Role__c;
        wrapper.workedWithCustomer = true;
        wrapper.availability =true;
        wrapper.availabilityValue = 'No Assignments';
        wrapper.internal = true;
        wrapper.internalValue = 'Yes';
        wrapper.distance = false;
        wrapper.distanceValue = '10';
        wrapper.customSettingValue =false;
        //wrapper.filterSkillLogic = 'Test Wrapper';
        wrapper.regionFilter = 'Is Null';
        wrapper.regionValue = 'Test';
        wrapper.practiceFilter = 'Not Equals';
        wrapper.practiceValue = 'Test';
        wrapper.groupFilter = 'Not Equals';
        wrapper.groupValue = '';
        
        wrapper.defaultCostRateFilter = 'Not Equals' ;
        wrapper.defaultCostRateValue = 0;
        wrapper.scheduledUtilizationFilter = 'Not Equals';
        wrapper.openFromResourceReqScreen = false;
        wrapper.selectedResourceRequest = resourceRequest;
        wrapper.showSubmitForPdMApproval = false;
        wrapper.scheduledUtilizationValue = 10;
        wrapper.filterLogicCertification = 'And';
        
        list<SearchResourcesController.SkillCertificationSet> wrapperSkillListCertification = new list<SearchResourcesController.SkillCertificationSet>();
        SearchResourcesController.SkillCertificationSet wrapperSkillCertification = new SearchResourcesController.SkillCertificationSet();
        wrapperSkillCertification.skillCertification = skills;
        wrapperSkillCertification.showAndOrOperator = false;
        wrapperSkillCertification.index = 0;
        wrapperSkillCertification.skillExp = '';
        wrapperSkillCertification.andOrOperator = '';
        wrapperSkillCertification.isSelected= false;
        wrapperSkillListCertification.add(wrapperSkillCertification);
        wrapper.lstSkill = wrapperSkillListCertification;
        wrapper.lstCertification = wrapperSkillListCertification;
        wrapper.projlatitude = 100;
        wrapper.projLogitude = 100;
        wrapper.distance = true;
        SearchResourcesController.Response reponsewrapper = new SearchResourcesController.Response();
        reponsewrapper.responseCode = '404';
        reponsewrapper.responseMessage= 'Not Found';
        //Test.startTest();
        SearchResourcesController.ContactPageWrapper obj =  new SearchResourcesController.ContactPageWrapper();
        obj = SearchResourcesController.getFilteredContacts(wrapper, 1 ,5);
        System.assertNotEquals(null, obj);
        Wrapper.practiceFilter = 'Is Null';
        Wrapper.groupFilter = 'Is Null';
        Wrapper.regionFilter = 'Not Equals';
        Wrapper.defaultCostRateFilter = 'Is Null';
        Wrapper.scheduledUtilizationFilter = 'Is Null';
        SearchResourcesController.ContactPageWrapper obj2 =  new SearchResourcesController.ContactPageWrapper();
        obj2 = SearchResourcesController.getFilteredContacts(wrapper, 1 ,5);
        Wrapper.defaultCostRateFilter = 'Equals';
        Wrapper.scheduledUtilizationFilter = 'Equals';
        SearchResourcesController.ContactPageWrapper obj3 =  new SearchResourcesController.ContactPageWrapper();
        obj3 = SearchResourcesController.getFilteredContacts(wrapper, 1 ,5);
        SearchResourcesController.SearchDetails wrapperSearchDetails = new SearchResourcesController.SearchDetails();
        System.assertNotEquals(null, wrapperSearchDetails);
        
        list<SearchResourcesController.SkillCertificationSet> wrapperSkillListCertification2 = new list<SearchResourcesController.SkillCertificationSet>();
        SearchResourcesController.SkillCertificationSet wrapperSkillCertification2 = new SearchResourcesController.SkillCertificationSet();
        wrapperSkillCertification2.skillCertification = skills;
        wrapperSkillCertification2.showAndOrOperator = false;
        wrapperSkillCertification2.index = 0;
        wrapperSkillCertification2.skillExp = '';
        wrapperSkillCertification2.andOrOperator = '';
        wrapperSkillCertification2.isSelected= false;
        wrapperSkillListCertification2.add(wrapperSkillCertification);
        wrapperSearchDetails.lstSkill = wrapperSkillListCertification2;
        wrapperSearchDetails.lstCertification = wrapperSkillListCertification2;
        
        
        SearchResourcesController.SearchDetails searchDetailsSkill = SearchResourcesController.getSearchDetails(resourceRequest.Id);
        System.assertNotEquals(null, searchDetailsSkill);
        
        Id certificationRecordTypeId = Schema.SObjectType.pse__Skill__c.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
        pse__Skill__c testCert = TestDataUtility.getCertification(false);
        testCert.recordTypeId = certificationRecordTypeId;
        testCert.Name = 'Test Certification New';
        testCert.pse__External_Id__c = 'sdfj123';
        insert testCert;
        TestDataUtility.getResourceRequestSkill(true, testCert.Id, resourceRequest.Id);
        SearchResourcesController.SearchDetails searchDetailsCertification = SearchResourcesController.getSearchDetails(resourceRequest.Id);
        System.assertNotEquals(null, searchDetailsCertification);
        
        resourceRequest.SearchFilterForPDM__c = JSON.serialize(wrapperSearchDetails);
        update resourceRequest;
        SearchResourcesController.SearchDetails getsearchDetailsWrapper = SearchResourcesController.getSearchDetails(resourceRequest.Id);
        System.assertNotEquals(null, getsearchDetailsWrapper);
        
        List<pse__Resource_Request__c> resourceReqList = SearchResourcesController.getResourceRequests(resourceRequest.name);
        pse__Region__c pseRegion = [Select id, Name from pse__Region__c limit 1];
        List<pse__Region__c>regionList =  SearchResourcesController.getRegions(pseRegion.name);
        System.assertNotEquals(null, regionList);
        
        pse__Practice__c practice = [Select id, Name from pse__Practice__c limit 1];
        List<pse__Practice__c>practiceList =  SearchResourcesController.getPractices(practice.name);
        System.assertNotEquals(null, practiceList);
        
        resourceRequest.pse__Status__c = 'Approval Pending';
        String str = SearchResourcesController.submitForApprovalPDM(resourceRequest , wrapper );
        System.assertNotEquals(null, str);
        
        
        List<pse__Skill__c> skillsList = SearchResourcesController.getSkillsCertifications('Skill',  wrapperSkillListCertification, 'test');
        System.assertNotEquals(null, skillsList);
        List<Id> skillIdList = new List<Id>();
        pse__Skill__c testSkill = [SELECT ID FROM pse__Skill__c limit 1];
        skillIdList.add(testSkill.Id);
        List<SearchResourcesController.SkillCertificationSet> skillSetWrapper =  SearchResourcesController.getSkills(skillIdList, wrapperSkillListCertification);
        System.assertNotEquals(null, skillSetWrapper);
        
        List<Id> certIdList = new List<Id>();
        certIdList.add(testSkill.Id);            
        List<SearchResourcesController.SkillCertificationSet> certificationSetWrapper = SearchResourcesController.getCertifications(certIdList, wrapperSkillListCertification);
        System.assertNotEquals(null, certificationSetWrapper);
        
        SearchResourcesController.SearchDetails wrapperReset = new SearchResourcesController.SearchDetails();
        wrapperReset.selectedResourceRequest = resourceRequest;
        //Boolean change = SearchResourcesController.saveFilterForScreen(wrapper);
        //wrapperReset =  SearchResourcesController.resetValues();
        System.assertNotEquals(null, wrapperReset);
        
        List <pse__Resource_Request__c> resourceRequestList = [Select id,pse__Start_Date__c,pse__End_Date__c,pse__Resource_Role__c,
                                                               pse__SOW_Hours__c, pse__Status__c from pse__Resource_Request__c];
        Set<Id> assignmentOnSearchReq = SearchResourcesController.getAssignmentOnSearchReq(wrapper, resourceRequestList, String.valueOf(Date.today()), String.valueOf(Date.today()));
        List<pse__Resource_Request__c> resourceReqestList =  SearchResourcesController.getResourceReqList(wrapper);
        
        wrapper.resourceRequestName = con.Name;
        Boolean  saveFilter = SearchResourcesController.saveFilterForScreen(wrapper);
        Test.startTest();
        List<Contact> conList  = [SELECT Id, mailinglatitude, mailinglongitude FROM Contact]; 
        pse__Work_Calendar__c testWorkCalendar = TestDataUtility.createWorkCalender(true);
        pse__HolidayObj__c testHoliday = new pse__HolidayObj__c();
        testHoliday.Name = 'Test';
        testHoliday.pse__Work_Calendar__c = testWorkCalendar.Id;
        testHoliday.pse__Date__c = Date.newInstance(2020, 07, 31);
        insert testHoliday;
        pse__HolidayObj__c testHoliday1 = new pse__HolidayObj__c();
        testHoliday1.Name = 'Test1';
        testHoliday1.pse__Work_Calendar__c = testWorkCalendar.Id;
        testHoliday1.pse__Date__c = Date.newInstance(2020, 08, 05);
        insert testHoliday1;
        pse__HolidayObj__c testHoliday2 = new pse__HolidayObj__c();
        testHoliday2.Name = 'Test2';
        testHoliday2.pse__Work_Calendar__c = testWorkCalendar.Id;
        testHoliday2.pse__Date__c = Date.newInstance(2020, 08, 04);
        insert testHoliday2;
        pse__HolidayObj__c testHoliday3 = new pse__HolidayObj__c();
        testHoliday3.Name = 'Test3';
        testHoliday3.pse__Work_Calendar__c = testWorkCalendar.Id;
        testHoliday3.pse__Date__c = Date.newInstance(2020, 08, 02);
        insert testHoliday3;
        pse__HolidayObj__c testHoliday4 = new pse__HolidayObj__c();
        testHoliday4.Name = 'Test4';
        testHoliday4.pse__Work_Calendar__c = testWorkCalendar.Id;
        testHoliday4.pse__Date__c = Date.newInstance(2020, 08, 03);
        insert testHoliday4;
        conList[0].pse__Work_Calendar__c = testWorkCalendar.Id;
        update conList[0];
      //  Account accountId = [SELECT Id FROM Account WHERE Name = 'TestAccount' limit 1]; 
         Account accountId = TestDataUtility.createAccounts(5,false)[0];
        system.debug('mailinglatitude' + conList[0].mailinglatitude);
        system.debug('mailinglongitude' + conList[0].mailinglongitude);
        Double longitude = 26.9561696;
        Double latitude = 75.7104891;
        Location projLocation = Location.newInstance(longitude,latitude);
        Location contactLocation = Location.newInstance(conList[0].mailinglatitude,  conList[0].mailinglongitude);
        System.debug('location' + Location.getDistance(projLocation, contactLocation, 'Km'));
      /* commented by Siva */
        Map<ID,Contact> caldistance = SearchResourcesController.calculateDistance(conList, 'All', 'Km', latitude, longitude, true);
        caldistance = SearchResourcesController.calculateDistance(conList, 'All', 'Mi', latitude, longitude, true);
        
        Set<Id> workWithCustumer = SearchResourcesController.getWrokedWithCustomerResource(conList, accountId.Id);
        
        List<pse__Grp__c> groupList = SearchResourcesController.getGroups('test');
        
        //set<ID> skilledCertifiedContactsId = SearchResourcesController.getAllSkilledCertifiedCopntacts(conList, wrapper);
        
        SearchResourcesController.PercentageAllocationData percentWrapper = new SearchResourcesController.PercentageAllocationData(); 
        percentWrapper.startDate = Date.today();
        percentWrapper.endDate =Date.today();
        percentWrapper.percentageAllocation =50;
        percentWrapper.monHrs =8;
        percentWrapper.tueHrs = 8;
        percentWrapper.wedHrs = 8;
        percentWrapper.thrHrs = 8;
        percentWrapper.friHrs = 8;
        percentWrapper.satHrs = 0;
        percentWrapper.sunHrs = 0;
        percentWrapper.totalHours = 40;
        percentWrapper.schedule= new pse__Schedule__c(OwnerId = conList[0].Id);
        
        List<SearchResourcesController.WrapperPercentageAllocationRow> wrapperPercentageAllocationList = new List<SearchResourcesController.WrapperPercentageAllocationRow>();
        SearchResourcesController.WrapperPercentageAllocationRow wrapperPercentageAllocation =  new SearchResourcesController.WrapperPercentageAllocationRow();
        wrapperPercentageAllocation.startDate = Date.newInstance(2020, 07, 30);
        wrapperPercentageAllocation.endDate = wrapperPercentageAllocation.startDate.addDays(7);
        wrapperPercentageAllocation.percentageAllocation = 50;
        wrapperPercentageAllocation.schedule = new  Pse__Schedule__c();
        wrapperPercentageAllocation.totalHours = 100;
        wrapperPercentageAllocationList.add(wrapperPercentageAllocation);
        
        
        pse__Resource_Request__c resRequest = [SELECT ID, pse__Start_Date__c, pse__End_Date__c,pse__Resource_Role__c,
                                               pse__SOW_Hours__c, pse__Status__c, pse__Project__c, pse__Requested_Bill_Rate__c, pse__Suggested_Bill_Rate__c  from pse__Resource_Request__c];
        resRequest.pse__Start_Date__c = Date.newInstance(2020, 07, 29);
        resRequest.pse__End_Date__c = resRequest.pse__Start_Date__c.addDays(10);
        upsert resRequest;
        SearchResourcesController.PercentageAllocationData percentWrapperData  = new SearchResourcesController.PercentageAllocationData();
        percentWrapperData =  SearchResourcesController.getPercentageAllocationData(conList[0].Id,resRequest);
        
        System.debug('End Date ###' + resRequest.pse__End_Date__c);
        List<SearchResourcesController.WrapperPercentageAllocationRow> wrapperPercentageAllocationRowList = new List<SearchResourcesController.WrapperPercentageAllocationRow>();
        wrapperPercentageAllocationRowList = SearchResourcesController.updatePercentAllocationScheduleRows(resRequest, conList[0].Id, wrapperPercentageAllocationList, true, true, 'Assign',null);
        //Test.startTest();
        wrapperPercentageAllocationRowList = SearchResourcesController.updatePercentAllocationScheduleRows(resRequest, conList[0].Id, wrapperPercentageAllocationList, false, false, 'Assign',null);
        wrapperPercentageAllocationRowList = SearchResourcesController.updatePercentAllocationScheduleRows(resRequest, conList[0].Id, wrapperPercentageAllocationList, false, true, 'Assign',null);

   //   SearchResourcesController.updateScheduleHours(new pse__Schedule__c().Id ,50);
        SearchResourcesController.WrapperPercentageAllocationRow percentAllocationScheduleRows =  new SearchResourcesController.WrapperPercentageAllocationRow();
        percentAllocationScheduleRows = SearchResourcesController.createPercentAllocationScheduleRows(resRequest, conList[0].Id, false, 40.0, 2);
        percentAllocationScheduleRows = SearchResourcesController.createPercentAllocationScheduleRows(resRequest, conList[0].Id, true, 40.0, 2);
        list<SearchResourcesController.WrapperPercentageAllocationRow>repList;
        repList = SearchResourcesController.getPercentAllocationRows(resRequest, conList[0].Id,repList,  false, 2);
        
        string testVar = SearchResourcesController.getPartiallyAllocatedResource();
        Test.stopTest();
        
    }
    static testMethod void  testSearchDetails3(){
        Contact con = [select id, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, Name, pse__Resource_Role__c from Contact limit 1];
        pse__Resource_Request__c resourceRequest = [Select id, Name, pse__Start_Date__c,pse__End_Date__c,pse__Resource_Role__c, SearchFilterForPDM__c,
                                                    pse__SOW_Hours__c, pse__Resource_Request__c.pse__Project__r.PDM__c from pse__Resource_Request__c limit 1];
        pse__Skill__c skills = [Select Id, name FROM pse__Skill__c limit 1];
        pse__Skill__c certifications = [Select Id, name FROM pse__Skill__c limit 1];
        SearchResourcesController.SearchDetails wrapper = new SearchResourcesController.SearchDetails();
        wrapper.street = con.MailingStreet;
        //     wrapper.resourceRequestName = 'Test';
        wrapper.city = con.MailingCity;
        wrapper.state = con.MailingState;
        wrapper.country =con.MailingCountry;
        wrapper.zipCode = con.MailingPostalCode;
        wrapper.startDate = String.valueOf(Date.today());
        wrapper.endDate = String.valueOf(Date.today());
        wrapper.name = con.Name;
        wrapper.resourceRequestName = resourceRequest.Name;
        wrapper.role = con.pse__Resource_Role__c;
        wrapper.workedWithCustomer = true;
        wrapper.availability =true;
        wrapper.availabilityValue = 'No Assignments';
        wrapper.internal = true;
        wrapper.internalValue = 'Yes';
        wrapper.distance = false;
        wrapper.distanceValue = '10';
        wrapper.customSettingValue =false;
        //wrapper.filterSkillLogic = 'Test Wrapper';
        wrapper.regionFilter = 'Not Is Null';
        wrapper.regionValue = 'Test';
        wrapper.practiceFilter = 'Not Is Null';
        wrapper.practiceValue = 'Test';
        wrapper.groupFilter = 'Not Is Null';
        wrapper.groupValue = '';
        
        wrapper.defaultCostRateFilter = 'Not Is Null' ;
        wrapper.defaultCostRateValue = 0;
        wrapper.scheduledUtilizationFilter = 'Not Is Null';
        wrapper.openFromResourceReqScreen = false;
        wrapper.selectedResourceRequest = resourceRequest;
        wrapper.showSubmitForPdMApproval = false;
        wrapper.scheduledUtilizationValue = 10;
        wrapper.filterLogicCertification = 'And';
        
        list<SearchResourcesController.SkillCertificationSet> wrapperSkillListCertification = new list<SearchResourcesController.SkillCertificationSet>();
        SearchResourcesController.SkillCertificationSet wrapperSkillCertification = new SearchResourcesController.SkillCertificationSet();
        wrapperSkillCertification.skillCertification = skills;
        wrapperSkillCertification.showAndOrOperator = false;
        wrapperSkillCertification.index = 0;
        wrapperSkillCertification.skillExp = '';
        wrapperSkillCertification.andOrOperator = '';
        wrapperSkillCertification.isSelected= false;
        wrapperSkillListCertification.add(wrapperSkillCertification);
        wrapper.lstSkill = wrapperSkillListCertification;
        wrapper.lstCertification = wrapperSkillListCertification;
        wrapper.projlatitude = 100;
        wrapper.projLogitude = 100;
        wrapper.distance = true;
        SearchResourcesController.Response reponsewrapper = new SearchResourcesController.Response();
        reponsewrapper.responseCode = '404';
        reponsewrapper.responseMessage= 'Not Found';
        //Test.startTest();
        SearchResourcesController.ContactPageWrapper obj =  new SearchResourcesController.ContactPageWrapper();
        obj = SearchResourcesController.getFilteredContacts(wrapper, 1 ,5);
        System.assertNotEquals(null, obj);
        Wrapper.defaultCostRateFilter = 'Greater';
        Wrapper.scheduledUtilizationFilter = 'Greater';
        SearchResourcesController.ContactPageWrapper obj4 =  new SearchResourcesController.ContactPageWrapper();
        obj4 = SearchResourcesController.getFilteredContacts(wrapper, 1 ,5);
        Wrapper.defaultCostRateFilter = 'Greater or Equals';
        Wrapper.scheduledUtilizationFilter = 'Greater or Equals';
        SearchResourcesController.ContactPageWrapper obj5 =  new SearchResourcesController.ContactPageWrapper();
        obj5 = SearchResourcesController.getFilteredContacts(wrapper, 1 ,5);
        
        SearchResourcesController.SearchDetails wrapperSearchDetails = new SearchResourcesController.SearchDetails();
        System.assertNotEquals(null, wrapperSearchDetails);
        
        list<SearchResourcesController.SkillCertificationSet> wrapperSkillListCertification2 = new list<SearchResourcesController.SkillCertificationSet>();
        SearchResourcesController.SkillCertificationSet wrapperSkillCertification2 = new SearchResourcesController.SkillCertificationSet();
        wrapperSkillCertification2.skillCertification = skills;
        wrapperSkillCertification2.showAndOrOperator = false;
        wrapperSkillCertification2.index = 0;
        wrapperSkillCertification2.skillExp = '';
        wrapperSkillCertification2.andOrOperator = '';
        wrapperSkillCertification2.isSelected= false;
        wrapperSkillListCertification2.add(wrapperSkillCertification);
        wrapperSearchDetails.lstSkill = wrapperSkillListCertification2;
        wrapperSearchDetails.lstCertification = wrapperSkillListCertification2;
        
        
        SearchResourcesController.SearchDetails searchDetailsSkill = SearchResourcesController.getSearchDetails(resourceRequest.Id);
        System.assertNotEquals(null, searchDetailsSkill);
        
        Id certificationRecordTypeId = Schema.SObjectType.pse__Skill__c.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
        pse__Skill__c testCert = TestDataUtility.getCertification(false);
        testCert.recordTypeId = certificationRecordTypeId;
        testCert.Name = 'Test Certification New';
        testCert.pse__External_Id__c = 'sdfj123';
        insert testCert;
        TestDataUtility.getResourceRequestSkill(true, testCert.Id, resourceRequest.Id);
        SearchResourcesController.SearchDetails searchDetailsCertification = SearchResourcesController.getSearchDetails(resourceRequest.Id);
        System.assertNotEquals(null, searchDetailsCertification);
        
        resourceRequest.SearchFilterForPDM__c = JSON.serialize(wrapperSearchDetails);
        update resourceRequest;
        SearchResourcesController.SearchDetails getsearchDetailsWrapper = SearchResourcesController.getSearchDetails(resourceRequest.Id);
        System.assertNotEquals(null, getsearchDetailsWrapper);
        
        List<pse__Resource_Request__c> resourceReqList = SearchResourcesController.getResourceRequests(resourceRequest.name);
        pse__Region__c pseRegion = [Select id, Name from pse__Region__c limit 1];
        List<pse__Region__c>regionList =  SearchResourcesController.getRegions(pseRegion.name);
        System.assertNotEquals(null, regionList);
        
        pse__Practice__c practice = [Select id, Name from pse__Practice__c limit 1];
        List<pse__Practice__c>practiceList =  SearchResourcesController.getPractices(practice.name);
        System.assertNotEquals(null, practiceList);
        
        resourceRequest.pse__Status__c = 'Approval Pending';
        String str = SearchResourcesController.submitForApprovalPDM(resourceRequest , wrapper );
        System.assertNotEquals(null, str);
        
        
        List<pse__Skill__c> skillsList = SearchResourcesController.getSkillsCertifications('Skill',  wrapperSkillListCertification, 'test');
        System.assertNotEquals(null, skillsList);
        List<Id> skillIdList = new List<Id>();
        pse__Skill__c testSkill = [SELECT ID FROM pse__Skill__c limit 1];
        skillIdList.add(testSkill.Id);
        List<SearchResourcesController.SkillCertificationSet> skillSetWrapper =  SearchResourcesController.getSkills(skillIdList, wrapperSkillListCertification);
        System.assertNotEquals(null, skillSetWrapper);
        
        List<Id> certIdList = new List<Id>();
        certIdList.add(testSkill.Id);            
        List<SearchResourcesController.SkillCertificationSet> certificationSetWrapper = SearchResourcesController.getCertifications(certIdList, wrapperSkillListCertification);
        System.assertNotEquals(null, certificationSetWrapper);
        
        SearchResourcesController.SearchDetails wrapperReset = new SearchResourcesController.SearchDetails();
        wrapperReset.selectedResourceRequest = resourceRequest;
        //Boolean change = SearchResourcesController.saveFilterForScreen(wrapper);
        //wrapperReset =  SearchResourcesController.resetValues();
        System.assertNotEquals(null, wrapperReset);
        
        List <pse__Resource_Request__c> resourceRequestList = [Select id,pse__Start_Date__c,pse__End_Date__c,pse__Resource_Role__c,
                                                               pse__SOW_Hours__c, pse__Status__c from pse__Resource_Request__c];
        Set<Id> assignmentOnSearchReq = SearchResourcesController.getAssignmentOnSearchReq(wrapper, resourceRequestList, String.valueOf(Date.today()), String.valueOf(Date.today()));
        List<pse__Resource_Request__c> resourceReqestList =  SearchResourcesController.getResourceReqList(wrapper);
        
        wrapper.resourceRequestName = con.Name;
        Boolean  saveFilter = SearchResourcesController.saveFilterForScreen(wrapper);
        Test.startTest();
        List<Contact> conList  = [SELECT Id, mailinglatitude, mailinglongitude FROM Contact]; 
        pse__Work_Calendar__c testWorkCalendar = TestDataUtility.createWorkCalender(true);
        pse__HolidayObj__c testHoliday = new pse__HolidayObj__c();
        testHoliday.Name = 'Test';
        testHoliday.pse__Work_Calendar__c = testWorkCalendar.Id;
        testHoliday.pse__Date__c = Date.newInstance(2020, 07, 31);
        insert testHoliday;
        pse__HolidayObj__c testHoliday1 = new pse__HolidayObj__c();
        testHoliday1.Name = 'Test1';
        testHoliday1.pse__Work_Calendar__c = testWorkCalendar.Id;
        testHoliday1.pse__Date__c = Date.newInstance(2020, 07, 30);
        insert testHoliday1;
        pse__HolidayObj__c testHoliday2 = new pse__HolidayObj__c();
        testHoliday2.Name = 'Test2';
        testHoliday2.pse__Work_Calendar__c = testWorkCalendar.Id;
        testHoliday2.pse__Date__c = Date.newInstance(2020, 07, 29);
        insert testHoliday2;
        pse__HolidayObj__c testHoliday3 = new pse__HolidayObj__c();
        testHoliday3.Name = 'Test3';
        testHoliday3.pse__Work_Calendar__c = testWorkCalendar.Id;
        testHoliday3.pse__Date__c = Date.newInstance(2020, 08, 01);
        insert testHoliday3;
        pse__HolidayObj__c testHoliday4 = new pse__HolidayObj__c();
        testHoliday4.Name = 'Test4';
        testHoliday4.pse__Work_Calendar__c = testWorkCalendar.Id;
        testHoliday4.pse__Date__c = Date.newInstance(2020, 07, 28);
        insert testHoliday4;
        conList[0].pse__Work_Calendar__c = testWorkCalendar.Id;
        update conList[0];
          Account accountId = TestDataUtility.createAccounts(5,false)[0];
       // Account accountId = [SELECT Id FROM Account WHERE Name = 'TestAccount' limit 1]; 
        system.debug('mailinglatitude' + conList[0].mailinglatitude);
        system.debug('mailinglongitude' + conList[0].mailinglongitude);
        Double longitude = 26.9561696;
        Double latitude = 75.7104891;
        Location projLocation = Location.newInstance(longitude,latitude);
        Location contactLocation = Location.newInstance(conList[0].mailinglatitude,  conList[0].mailinglongitude);
      /*commented by Siva
        System.debug('location' + Location.getDistance(projLocation, contactLocation, 'Km'));*/
        Map <ID,Contact> caldistance = SearchResourcesController.calculateDistance(conList, 'All', 'Km', latitude, longitude, true);
        caldistance = SearchResourcesController.calculateDistance(conList, 'All', 'Mi', latitude, longitude, true);
        
        Set<Id> workWithCustumer = SearchResourcesController.getWrokedWithCustomerResource(conList, accountId.Id);
        
        List<pse__Grp__c> groupList = SearchResourcesController.getGroups('test');
        
        //set<ID> skilledCertifiedContactsId = SearchResourcesController.getAllSkilledCertifiedCopntacts(conList, wrapper);
        
        SearchResourcesController.PercentageAllocationData percentWrapper = new SearchResourcesController.PercentageAllocationData(); 
        percentWrapper.startDate = Date.today();
        percentWrapper.endDate =Date.today();
        percentWrapper.percentageAllocation =50;
        percentWrapper.monHrs =8;
        percentWrapper.tueHrs = 8;
        percentWrapper.wedHrs = 8;
        percentWrapper.thrHrs = 8;
        percentWrapper.friHrs = 8;
        percentWrapper.satHrs = 0;
        percentWrapper.sunHrs = 0;
        percentWrapper.totalHours = 40;
        percentWrapper.schedule= new pse__Schedule__c(OwnerId = conList[0].Id);
        
        List<SearchResourcesController.WrapperPercentageAllocationRow> wrapperPercentageAllocationList = new List<SearchResourcesController.WrapperPercentageAllocationRow>();
        SearchResourcesController.WrapperPercentageAllocationRow wrapperPercentageAllocation =  new SearchResourcesController.WrapperPercentageAllocationRow();
        wrapperPercentageAllocation.startDate = Date.newInstance(2020, 07, 30);
        wrapperPercentageAllocation.endDate = wrapperPercentageAllocation.startDate.addDays(7);
        wrapperPercentageAllocation.percentageAllocation = 50;
        wrapperPercentageAllocation.schedule = new  Pse__Schedule__c();
        wrapperPercentageAllocation.totalHours = 100;
        wrapperPercentageAllocationList.add(wrapperPercentageAllocation);
        
        
        pse__Resource_Request__c resRequest = [SELECT ID, pse__Start_Date__c, pse__End_Date__c,pse__Resource_Role__c,
                                               pse__SOW_Hours__c, pse__Status__c, pse__Project__c, pse__Requested_Bill_Rate__c, pse__Suggested_Bill_Rate__c  from pse__Resource_Request__c];
        resRequest.pse__Start_Date__c = Date.newInstance(2020, 07, 29);
        resRequest.pse__End_Date__c = resRequest.pse__Start_Date__c.addDays(10);
        upsert resRequest;
        SearchResourcesController.PercentageAllocationData percentWrapperData  = new SearchResourcesController.PercentageAllocationData();
        percentWrapperData =  SearchResourcesController.getPercentageAllocationData(conList[0].Id,resRequest);
        
        System.debug('End Date ###' + resRequest.pse__End_Date__c);
        List<SearchResourcesController.WrapperPercentageAllocationRow> wrapperPercentageAllocationRowList = new List<SearchResourcesController.WrapperPercentageAllocationRow>();
        wrapperPercentageAllocationRowList = SearchResourcesController.updatePercentAllocationScheduleRows(resRequest, conList[0].Id, wrapperPercentageAllocationList, true, true, 'Assign',null);
        //Test.startTest();
        wrapperPercentageAllocationRowList = SearchResourcesController.updatePercentAllocationScheduleRows(resRequest, conList[0].Id, wrapperPercentageAllocationList, false, false, 'Assign',null);
        wrapperPercentageAllocationRowList = SearchResourcesController.updatePercentAllocationScheduleRows(resRequest, conList[0].Id, wrapperPercentageAllocationList, false, true, 'Assign',null);

   //   SearchResourcesController.updateScheduleHours(new pse__Schedule__c().Id ,50);
        SearchResourcesController.WrapperPercentageAllocationRow percentAllocationScheduleRows =  new SearchResourcesController.WrapperPercentageAllocationRow();
        percentAllocationScheduleRows = SearchResourcesController.createPercentAllocationScheduleRows(resRequest, conList[0].Id, false, 40.0, 2);
        percentAllocationScheduleRows = SearchResourcesController.createPercentAllocationScheduleRows(resRequest, conList[0].Id, true, 40.0, 2);
        list<SearchResourcesController.WrapperPercentageAllocationRow>repList;
        repList = SearchResourcesController.getPercentAllocationRows(resRequest, conList[0].Id,repList,  false, 2);
        
        string testVar = SearchResourcesController.getPartiallyAllocatedResource();
        Test.stopTest();
        
    }
    static testMethod void getAllSkilledContactsTest2(){
        contactList = [select ID from Contact limit 5];
        Id skillRecordTypeId = Schema.SObjectType.pse__Skill__c.getRecordTypeInfosByName().get('Skill').getRecordTypeId();
        pse__Skill__c testSkill = TestDataUtility.getCertification(false);
        testSkill.recordTypeId = skillRecordTypeId;
        testSkill.Name = 'javaScript';
        testSkill.pse__External_Id__c = 'sdfj1233gs';
        insert testSkill;
        pse__Skill__c testSkill2 = TestDataUtility.getCertification(false);
        testSkill2.recordTypeId = skillRecordTypeId;
        testSkill2.Name = 'Java';
        testSkill2.pse__External_Id__c = '35dgdgsh';
        insert testSkill2;
        pse__Skill_Certification_Rating__c objSkillRating= TestDataUtility.getCertification(testSkill.ID,contactList[0].ID,'externalIDDDD' , false);
        pse__Skill_Certification_Rating__c objSkillRating2 = TestDataUtility.getCertification(testSkill2.ID,contactList[1].ID,'IDDDDexternal' , false);
        objSkillRating2.pse__Rating__c = '1';
       // insert objSkillRating2;
        SearchResourcesController.SkillCertificationSet skill1 = new SearchResourcesController.SkillCertificationSet();
        skill1.skillCertification = testSkill;
        skill1.skillExp = 'NO';
        skill1.recType = 'Skill';
        skill1.isSelected = true;
        list<SearchResourcesController.SkillCertificationSet> lstSkill = new list<SearchResourcesController.SkillCertificationSet>();
        SearchResourcesController.SkillCertificationSet skill22 = new SearchResourcesController.SkillCertificationSet();
        skill22.skillCertification = testSkill2;
        skill22.skillExp = '1';
        skill22.recType = 'Skill';
        skill22.isSelected = true;
        lstSkill.add(skill22);
        SearchResourcesController.SearchDetails wrapper = new SearchResourcesController.SearchDetails();
        wrapper.lstSkill = lstSkill;
        wrapper.skillFilterCriteria = '1 OR 2';
        wrapper.filterLogicSkill = 'And';
       /** Commented by Siva method doesn't exist in controller*/
        SearchResourcesController.getAllSkilledCertifiedContacts(contactList, wrapper, wrapper.lstSkill);
        wrapper.skillFilterCriteria = null;
        wrapper.filterLogicSkill = 'And';
         /** Commented by Siva method doesn't exist in controller*/
        SearchResourcesController.getAllSkilledCertifiedContacts(contactList, wrapper, wrapper.lstSkill);
        
        wrapper.skillFilterCriteria = null;
        wrapper.filterLogicSkill = 'Or';
         /** Commented by Siva method doesn't exist in controller*/
        SearchResourcesController.getAllSkilledCertifiedContacts(contactList, wrapper, wrapper.lstSkill);
    }
    static testMethod void getAllCertifiedContactsTest2(){
            contactList = [select ID from Contact limit 5];
            Id skillRecordTypeId = Schema.SObjectType.pse__Skill__c.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
            pse__Skill__c testSkill = TestDataUtility.getCertification(false);
            testSkill.recordTypeId = skillRecordTypeId;
            testSkill.Name = 'Service';
            testSkill.pse__External_Id__c = 'Akjjj1233gs';
            insert testSkill;
            pse__Skill__c testSkill2 = TestDataUtility.getCertification(false);
            testSkill2.recordTypeId = skillRecordTypeId;
            testSkill2.Name = 'Net';
            testSkill2.pse__External_Id__c = '3wtetetdgsh';
            insert testSkill2;
            pse__Skill_Certification_Rating__c objSkillRating= TestDataUtility.getCertification(testSkill.ID,contactList[2].ID,'externalIDDDD' , false);
            pse__Skill_Certification_Rating__c objSkillRating2 = TestDataUtility.getCertification(testSkill2.ID,contactList[3].ID,'IDDDDexternal' , false);
            objSkillRating2.pse__Rating__c = '1';
           // insert objSkillRating2;
            SearchResourcesController.SkillCertificationSet skill1 = new SearchResourcesController.SkillCertificationSet();
            skill1.skillCertification = testSkill;
            skill1.skillExp = 'NO';
            skill1.recType = 'Certification';
            skill1.isSelected = true;
            list<SearchResourcesController.SkillCertificationSet> lstSkill = new list<SearchResourcesController.SkillCertificationSet>();
            SearchResourcesController.SkillCertificationSet skill22 = new SearchResourcesController.SkillCertificationSet();
            skill22.skillCertification = testSkill2;
            skill22.skillExp = '1';
            skill22.recType = 'Certification';
            skill22.isSelected = true;
            lstSkill.add(skill22);
            SearchResourcesController.SearchDetails wrapper = new SearchResourcesController.SearchDetails();
            wrapper.lstSkill = lstSkill;
            wrapper.lstCertification = lstSkill;
            wrapper.certificationFilterCriteria = '1 OR 2'; 
            wrapper.filterLogicCertification = 'And';
         /** Commented by Siva method doesn't exist in controller*/
            SearchResourcesController.getAllSkilledCertifiedContacts(contactList, wrapper, wrapper.lstCertification);
            wrapper.certificationFilterCriteria = null;
            wrapper.filterLogicCertification = 'And';
            /** Commented by Siva method doesn't exist in controller*/
        SearchResourcesController.getAllSkilledCertifiedContacts(contactList, wrapper, wrapper.lstCertification);
            wrapper.certificationFilterCriteria = null;
            wrapper.filterLogicCertification = 'Or';
            /** Commented by Siva method doesn't exist in controller*/
        SearchResourcesController.getAllSkilledCertifiedContacts(contactList, wrapper, wrapper.lstCertification);
    }
    static testMethod void testSendEmailToParticularResource(){
        SearchResourcesController.sendEmailToParticularResource('abc@gmail.com','Test Subject','Test Body');
    }
    static testMethod void testDisplayAssignmentsBasedOnResource(){
        List<Account> accountList = TestDataUtility.createAccounts(1, false);
        accountList[0].Name = 'TestDisplayAssignment';
        accountList[0].Phone = '0993111211';
       // insert accountList;
        List<Contact> contactList = TestDataUtility.createContacts(1 ,accountList[0].Id , false , true);
        List<pse__Assignment__c> testAssignmentList = SearchResourcesController.displayAssignmentsBasedOnResource(contactList[0].Id);
        System.assertEquals(testAssignmentList.size(), 0);
    }
    static testMethod void testCompetenceQualifications(){
        Id skillRecordTypeId =
            Schema.SObjectType.pse__Skill__c.getRecordTypeInfosByName().get('Skill').getRecordTypeId();
        Id certificationRecordTypeId =
            Schema.SObjectType.pse__Skill__c.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
        List<Account> accountList = TestDataUtility.createAccounts(1, false);
        accountList[0].Name = 'TestCompetenceQualifications';
        accountList[0].Phone = '7657657657';
       // insert accountList;
        List<Contact> contactList = TestDataUtility.createContacts(1 ,accountList[0].Id , false , true);
        pse__Skill__c testCertification = TestDataUtility.getCertification(false);
        testCertification.Name = 'nameTestCom123';
        testCertification.pse__External_Id__c = 'testCom123';
        testCertification.RecordTypeId = certificationRecordTypeId;
        insert testCertification;
        List<pse__Skill__c> testSkillList = TestDataUtility.getSkills(1, false);
        testSkillList[0].Name = 'nameTestComQual';
        testSkillList[0].pse__External_Id__c = 'testComQual';
        testSkillList[0].RecordTypeId = skillRecordTypeId;
        insert testSkillList;
        TestDataUtility.getCertification(testCertification.Id, contactList[0].Id, 'abcnew123', false);
        TestDataUtility.getCertification(testSkillList[0].Id, contactList[0].Id, 'abcnew1234', false);
        SearchResourcesController.SkillCertificationRatingWithRecordTypes wrapper = SearchResourcesController.getCompetenceQualifications(contactList[0].Id);
        System.assertEquals(wrapper.skillRatList.size(), 0);
        System.assertEquals(wrapper.certificationRatList.size(), 0);
    }
    static testMethod void testGetComplexProjectCount(){

         User user1 = [SELECT Id FROM USER LIMIT 1];
        System.runAs(user1){
            //Create region
            pse__Region__c region = TestDataUtility.getRegion(True);
            //Create perission Control
            pse__Permission_Control__c pc = TestDataUtility.getPermissionControl(user1.id,region.id,false);
            pc.pse__Staffing__c = true;
            insert pc;
            //Create Account
            Account acc = TestDataUtility.createAccounts(1,false)[0];
            acc.Name = 'Test Method New 1';
           // insert acc;
            //create work calendar
            pse__Work_Calendar__c wc = TestDataUtility.createWorkCalender(True);
            //Create holiday
            TestDataUtility.createHoliday(wc.id,True);
            //Create Resource
            Contact con = TestDataUtility.createContacts(1,acc.id,false,True)[0];
            con.pse__Salesforce_User__c = user1.Id;
            con.pse__Work_Calendar__c = wc.id;
            con.pse__Region__c = region.id;
           // insert con;
            Test.startTest();
            //Create Project
            pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,True);
            //create schedule
            pse__Schedule__c sc = new pse__Schedule__c();
            sc.pse__Start_Date__c = date.today();
            sc.pse__End_Date__c = date.today()+30;
            sc.pse__Monday_Hours__c = 0;
            sc.pse__Tuesday_Hours__c = 0;
            sc.pse__Wednesday_Hours__c = 0;
            sc.pse__Thursday_Hours__c = 0;
            sc.pse__Friday_Hours__c = 0;
            sc.pse__Saturday_Hours__c = 0;
            sc.pse__Sunday_Hours__c = 0;
            insert sc;
            //create assignment
            pse__Assignment__c assign =	TestDataUtility.getAssignment(proj.id,con.id,0,false);
        	assign.pse__Is_Billable__c = false;
        	assign.pse__Schedule__c = sc.Id;
        	//insert assign;
            List<Contact> lstForComplexProjectCount = new List<Contact>();
            lstForComplexProjectCount.add(con);
            Date startDate = Date.today();
            Date endDate = Date.today() + 30;
			SearchResourcesController.getComplexProjectCount(lstForComplexProjectCount, startDate, endDate);
            proj.Project_Complexity__c = 'Medium';
            update proj;
            SearchResourcesController.getComplexProjectCount(lstForComplexProjectCount, startDate, endDate);
            proj.Project_Complexity__c = 'High';
            update proj;
            SearchResourcesController.getComplexProjectCount(lstForComplexProjectCount, startDate, endDate);
            //Create Assignment Record
            Test.stopTest();
        }}
      /*  static testMethod void testaddResourceRequestSet(){
             
          User user1 = [SELECT Id FROM USER LIMIT 1];
          System.runAs(user1){
            //Create region
            pse__Region__c region = TestDataUtility.getRegion(True);
            //Create perission Control
            pse__Permission_Control__c pc = TestDataUtility.getPermissionControl(UserInfo.getUserId(),region.id,true);
            pc.pse__Staffing__c = true;
            insert pc;
            //Create Account
            Account acc = TestDataUtility.createAccounts(1,false)[0];
            acc.Name = 'Test Method New 1';
           // insert acc;
            //create work calendar
            pse__Work_Calendar__c wc = TestDataUtility.createWorkCalender(True);
            //Create Resource
            List<Contact> con = TestDataUtility.createContacts(2,acc.id,false,True);
            con[0].pse__Salesforce_User__c = user1.Id;
            con[0].pse__Work_Calendar__c = wc.id;
            con[0].pse__Region__c = region.id;
            con[1].pse__Work_Calendar__c = wc.id;
            con[1].pse__Region__c = region.id;
           // insert con;
            Test.startTest();
            //Create Project
            pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,false);
            proj.FBE_IDS_Residency__c =true;
            insert proj;
            pse__Skill__c skills = [Select Id, name FROM pse__Skill__c limit 1];
            //create resouce request
            pse__Resource_Request__c resourceRequest1 = TestDataUtility.getResourceRequest(false);
            resourceRequest1.pse__Region__c = region.id;
            resourceRequest1.pse__Project__c =  proj.Id;
            resourceRequest1.pse__Start_Date__c = Date.today();
            resourceRequest1.pse__End_Date__c = Date.today()+15;
            resourceRequest1.pse__Requested_Bill_Rate__c = 50;
            insert resourceRequest1;
            pse__Resource_Skill_Request__c skllReq = TestDataUtility.getResourceRequestSkill(false,skills.id,resourceRequest1.id);
            skllReq.pse__Minimum_Rating__c = '2';
            skllReq.pse__Skill_Certification__c = skills.id;
            skllReq.pse__Resource_Request__c = resourceRequest1.id;
            skllReq.pse__Match_All__c = true;
            skllReq.pse__Is_Primary__c = true;
            insert skllReq;
            Map<String,pse__Schedule__c> schduleMap = SearchResourcesController.adjustHoursSchedule(resourceRequest1,con[0].id);
            insert schduleMap.values();
            Map<String,pse__Schedule__c> schduleMap1 = SearchResourcesController.adjustHoursSchedule(resourceRequest1,con[1].id);
            insert schduleMap1.values();
            List<id> lstForResource = new List<id>();
            lstForResource.add(con[0].id);
            lstForResource.add(con[1].id);
            List<id> lstForResource2 = new List<id>();
            lstForResource2.add(con[1].id);
            //create resouce request
            pse__Resource_Request__c resourceRequest2 = TestDataUtility.getResourceRequest(false);
            resourceRequest2.pse__Region__c = region.id;
            resourceRequest2.pse__Project__c =  proj.Id;
            resourceRequest2.pse__Start_Date__c = Date.today();
            resourceRequest2.pse__End_Date__c = Date.today()+15;
            resourceRequest2.pse__Requested_Bill_Rate__c = 50;
            insert resourceRequest2;
            /* Commented by Siva method deosnt exisist in controller
            ID resourceRequestSetID = SearchResourcesController.addResourceRequestSet(schduleMap, lstForResource, resourceRequest1, 'Custom');
            pse__Resource_Request_Set__c resRequestSet = [SELECT ID from pse__Resource_Request_Set__c];
            System.debug(resRequestSet.id);
            System.debug(resourceRequestSetID);
            system.assertNotEquals(null, resRequestSet.id);
            ID resourceRequestSetID2= SearchResourcesController.addResourceRequestSet(schduleMap, lstForResource, resourceRequest1, 'ZeroHourSchedule');
            system.assertEquals(resourceRequestSetID, resourceRequestSetID2);
            ID resourceRequestSetID3= SearchResourcesController.addResourceRequestSet(schduleMap1, lstForResource2, resourceRequest2, 'CalculateEndDateLevelSchedule');
                   End   
       }
    }

}*/
}