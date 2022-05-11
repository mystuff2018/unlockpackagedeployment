@isTest
public class IdsProjectHandlerTest {
	
     @testSetup
    static void setup() {
        Profile profile = [
                SELECT Id 
                FROM Profile 
                WHERE Name = 'PSA Project Manager'
            ];
        List<User> userlst = new List<User>();
        
        User usertst = new User(
                UserName = 'chamku_user@dell.com',
                LastName = 'Onesta',
                Email = 'chamku_user@dell.com',
                Alias = 'Z1',
                CommunityNickname = 'Z1',
                Federal_Access__c = false,
                FederationIdentifier = '22324466',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profile.Id,
                LanguageLocaleKey = 'en_US',
                OSP__c = 'No',
                Dell_NTUserID__c = 'CHAMKU_USER',
                Service_User_Type__c = 'Service Account',
                External_ID__c = '23234466',
                Organization__c = 'Test Org',
                File_Source__c = 'AMS - System Admin',
                EmployeeNumber='12349789'
            );
            userlst.add(usertst);
        insert userlst;
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            
            Schema.Location objLocation = new Schema.Location();
            objLocation.OwnerId = UserInfo.getUserId();
            objLocation.Name = '233 N Michigan Ave_Chicago';
            objLocation.CurrencyIsoCode = 'USD';
            objLocation.LocationType = 'Site';
            objLocation.IsMobile = false;
            objLocation.IsInventoryLocation = false;
            insert objLocation;
            
            Schema.Address objAddress = new Schema.Address();
            objAddress.CurrencyIsoCode = 'USD';
            objAddress.ParentId = objLocation.Id;
            objAddress.LocationType = 'Warehouse';
            objAddress.AddressType = 'Mailing';
            objAddress.Street = '233 North Michigan Avenue';
            objAddress.City = 'Chicago';
            objAddress.State = 'Illinois';
            objAddress.PostalCode = '60601';
            objAddress.Country = 'United States';
            objAddress.StateCode = 'IL';
            objAddress.CountryCode = 'US';
            objAddress.Latitude = 41.887140000000000;
            objAddress.Longitude = -87.623288000000000;
            objAddress.GeocodeAccuracy = 'Address';
            insert objAddress;
            
            pse__Work_Calendar__c workCalendar = new pse__Work_Calendar__c(
                Name = 'Test Work Calendar'
            );
            
            insert workCalendar;
            
            Account account = new Account(
                Name = 'Test account',
                Site_Access_Required__c = 'Yes'
            );
            
            insert account;
            
            pse__Region__c region = new pse__Region__c(
                Name = 'Test R1',
                ISO_Country_Code__c = 'R1'
            );
            
            insert region;
            
            Contact conco = new Contact(
                FirstName = 'Jugnu',
                LastName = 'Sook',
                Email = 'chamku_user@dell.com',
                AccountId = account.Id,
               // RecordTypeId = conRecordType,
                Phone = '4326781255',
                Primary_Phone__c = '4326781255',
                pse__Salesforce_User__c = userlst[0].Id,
                pse__Region__c = region.Id,
                pse__Work_Calendar__c = workCalendar.Id,
                pse__Is_Resource_Active__c = true,
                pse__Is_Resource__c = true
            );
            
            insert conco;
            
            //User objUser = TestDataGenerator.createUser('Smith','Julian','1');
           
            User objUser     =   new User();
        objUser.Username = 'testuser@dellteam.com.dellservices.dev1';
        objUser.LastName = 'user';
        objUser.FirstName = 'test phase';
        objUser.Email = 'testuserinsert@dellteam.com';
        objUser.EmailPreferencesAutoBcc = true;
        objUser.EmailPreferencesAutoBccStayInTouch = false;
        objUser.EmailPreferencesStayInTouchReminder = true;
        objUser.Alias = 'test';
        //objUser.CommunityNickname ='testuserphase';
        objUser.IsActive = true;
        objUser.TimeZoneSidKey = 'America/Los_Angeles';
        objUser.LocaleSidKey = 'en_US';
        objUser.ReceivesInfoEmails = true;
        objUser.ReceivesAdminInfoEmails = true;
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.DefaultCurrencyIsoCode = 'USD';
        objUser.CurrencyIsoCode = 'USD';
        objUser.ProfileId = UserInfo.getProfileId();
        objUser.LanguageLocaleKey = 'en_US';
        objUser.UserPermissionsMarketingUser = false;
        objUser.UserPermissionsOfflineUser = false;
        objUser.UserPermissionsAvantgoUser = false;
        objUser.UserPermissionsCallCenterAutoLogin = false;
        objUser.UserPermissionsMobileUser = false;
        objUser.UserPermissionsSFContentUser = false;
        objUser.UserPermissionsKnowledgeUser = false;
        objUser.UserPermissionsInteractionUser = false;
        objUser.UserPermissionsSupportUser = false;
       // objUser.UserPermissionsLiveAgentUser = false;
        objUser.ForecastEnabled = false;
        objUser.UserPreferencesActivityRemindersPopup = true;
        objUser.UserPreferencesEventRemindersCheckboxDefault = true;
        objUser.UserPreferencesTaskRemindersCheckboxDefault = true;
        objUser.UserPreferencesReminderSoundOff = false;
        objUser.UserPreferencesDisableAllFeedsEmail = false;
        objUser.UserPreferencesDisableFollowersEmail = false;
        objUser.UserPreferencesDisableProfilePostEmail = false;
        objUser.UserPreferencesDisableChangeCommentEmail = false;
        objUser.UserPreferencesDisableLaterCommentEmail = false;
        objUser.UserPreferencesDisProfPostCommentEmail = false;
        objUser.UserPreferencesContentNoEmail = false;
        objUser.UserPreferencesContentEmailAsAndWhen = false;
        objUser.UserPreferencesApexPagesDeveloperMode = false;
        objUser.UserPreferencesHideCSNGetChatterMobileTask = false;
        objUser.UserPreferencesDisableMentionsPostEmail = false;
        objUser.UserPreferencesDisMentionsCommentEmail = false;
        objUser.UserPreferencesHideCSNDesktopTask = false;
        objUser.UserPreferencesHideChatterOnboardingSplash = false;
        objUser.UserPreferencesHideSecondChatterOnboardingSplash = false;
        objUser.UserPreferencesDisCommentAfterLikeEmail = false;
        objUser.UserPreferencesDisableLikeEmail = true;
        objUser.UserPreferencesSortFeedByComment = true;
        objUser.UserPreferencesDisableMessageEmail = false;
        objUser.UserPreferencesDisableBookmarkEmail = false;
        objUser.UserPreferencesDisableSharePostEmail = false;
        objUser.UserPreferencesEnableAutoSubForFeeds = false;
        objUser.UserPreferencesDisableFileShareNotificationsForApi = false;
        objUser.UserPreferencesShowTitleToExternalUsers = true;
        objUser.UserPreferencesShowManagerToExternalUsers = false;
        objUser.UserPreferencesShowEmailToExternalUsers = false;
        objUser.UserPreferencesShowWorkPhoneToExternalUsers = false;
        objUser.UserPreferencesShowMobilePhoneToExternalUsers = false;
        objUser.UserPreferencesShowFaxToExternalUsers = false;
        objUser.UserPreferencesShowStreetAddressToExternalUsers = false;
        objUser.UserPreferencesShowCityToExternalUsers = false;
        objUser.UserPreferencesShowStateToExternalUsers = false;
        objUser.UserPreferencesShowPostalCodeToExternalUsers = false;
        objUser.UserPreferencesShowCountryToExternalUsers = false;
        objUser.UserPreferencesShowProfilePicToGuestUsers = false;
        objUser.UserPreferencesShowTitleToGuestUsers = false;
        objUser.UserPreferencesShowCityToGuestUsers = false;
        objUser.UserPreferencesShowStateToGuestUsers = false;
        objUser.UserPreferencesShowPostalCodeToGuestUsers = false;
        objUser.UserPreferencesShowCountryToGuestUsers = false;
        objUser.UserPreferencesPipelineViewHideHelpPopover = false;
        //objUser.UserPreferencesHideS1BrowserUI = false;
        objUser.UserPreferencesDisableEndorsementEmail = false;
        objUser.UserPreferencesPathAssistantCollapsed = false;
        objUser.UserPreferencesCacheDiagnostics = false;
        objUser.UserPreferencesShowEmailToGuestUsers = false;
        objUser.UserPreferencesShowManagerToGuestUsers = false;
        objUser.UserPreferencesShowWorkPhoneToGuestUsers = false;
        objUser.UserPreferencesShowMobilePhoneToGuestUsers = false;
        objUser.UserPreferencesShowFaxToGuestUsers = false;
        objUser.UserPreferencesShowStreetAddressToGuestUsers = false;
        objUser.UserPreferencesLightningExperiencePreferred = true;
        objUser.UserPreferencesPreviewLightning = false;
        objUser.UserPreferencesHideEndUserOnboardingAssistantModal = false;
        objUser.UserPreferencesHideLightningMigrationModal = false;
        objUser.UserPreferencesHideSfxWelcomeMat = true;
        objUser.UserPreferencesHideBiggerPhotoCallout = false;
        objUser.UserPreferencesGlobalNavBarWTShown = false;
        objUser.UserPreferencesGlobalNavGridMenuWTShown = false;
        objUser.UserPreferencesCreateLEXAppsWTShown = false;
        objUser.UserPreferencesFavoritesWTShown = false;
        objUser.UserPreferencesRecordHomeSectionCollapseWTShown = false;
        objUser.UserPreferencesRecordHomeReservedWTShown = false;
        objUser.UserPreferencesFavoritesShowTopFavorites = false;
        objUser.UserPreferencesExcludeMailAppAttachments = false;
        objUser.UserPreferencesSuppressTaskSFXReminders = false;
        objUser.UserPreferencesSuppressEventSFXReminders = false;
        objUser.UserPreferencesPreviewCustomTheme = false;
        objUser.UserPreferencesHasCelebrationBadge = false;
        objUser.UserPreferencesUserDebugModePref = false;
        objUser.UserPreferencesNewLightningReportRunPageEnabled = false;
        objUser.FederationIdentifier = '1196894';
        objUser.DigestFrequency = 'D';
        objUser.DefaultGroupNotificationFrequency = 'N';
        objUser.OSP__c = 'No';
        objUser.Dell_Remote_Assist__c = false;
        objUser.Dell_NTUserID__c = 'TEST_N';
        objUser.External_ID__c = '1196894';
        objUser.File_Source__c = 'AMS - System Admin';
        objUser.Organization__c = 'Dell';
        objUser.Service_User_Type__c = 'Service Account';
		objUser.EmployeeNumber='12349999';
     	insert objUser;
            
            pse__Time_Period__c objTimePeriod = TestDataGenerator.createTimePeriod();
            insert objTimePeriod;
            
            pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
          
            pse__Practice__c objPractice = new pse__Practice__c();
            objPractice.Name = 'Infrastructure Delivery Services';
            objPractice.Standard_Project_Template__c = projectTemplate.Id;
            objPractice.pse__Current_Time_Period__c = objTimePeriod.Id;
            insert objPractice;
            
            Contact objContact = TestDataGenerator.createContact('Smith','Julian', account.Id, region.Id, objPractice.Id, workCalendar.Id, objUser.Id);
            insert objContact;
            
            pse__Region__c r1 = [
                SELECT Id 
                FROM pse__Region__c
            ];
            
            List<pse__Proj__c> projlist = new List<pse__Proj__c>();
            
            pse__Proj__c engagement1 = new pse__Proj__c(
                Name = 'Engagement Project 1',
                RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId(),
                pse__Parent_Project__c = null
            );
            projlist.add(engagement1);
            
            pse__Proj__c engagement2 = new pse__Proj__c(
                Name = 'Engagement Project 2',
                RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId(),
                pse__Parent_Project__c = null
            );
            projlist.add(engagement2);
            
            pse__Proj__c testProj1 = new pse__Proj__c(
                Name = 'Test Proj 1',
                pse__Project_Phase__c = 'Setup',
                pse__Is_Template__c = true,
                pse__Is_Active__c = true,
                pse__Start_Date__c = Date.today(),
                pse__Region__c = r1.Id,
                pse__Stage__c = 'Draft',
                Project_Visibility__c = 'All',
                PM_Complexity__c = 'Low',
                Project_Complexity__c = 'Low',
                Initiate_Customer_Contact__c = true,
                Planning_and_Design__c = true,
                Delivery_and_Implementation__c = true,
                Closure_Reason__c = 'Services Delivered',
                pse__Project_Manager__c = conco.Id,
                Project_Support_Analyst__c = objContact.Id,
                pse__Account__c = account.Id,
                pse__Account__r = account,
                pse__Parent_Project__c = engagement1.Id
            );
            projlist.add(testProj1);
            
            pse__Proj__c testProj2 = new pse__Proj__c(
                Name = 'Test Proj 2',
                pse__Project_Phase__c = 'Setup',
                pse__Is_Template__c = false,
                pse__Is_Active__c = true,
                pse__Start_Date__c = Date.today(),
                pse__Region__c = r1.Id,
                Project_Visibility__c = 'All',
                PM_Complexity__c = 'Low',
                Project_Complexity__c = 'Low',
                Initiate_Customer_Contact__c = true,
                Planning_and_Design__c = true,
                Delivery_and_Implementation__c = true,
                Closure_Reason__c = 'Services Delivered',
                pse__Project_Manager__c = conco.Id,
                pse__Account__c = account.Id,
                pse__Account__r = account,
                pse__Parent_Project__c = engagement2.Id
            );
            projlist.add(testProj2);
            insert projlist;
            
           /* List<pse__Budget__c> listBudget = new List<pse__Budget__c>();
            
            pse__Budget__c budget = new pse__Budget__c (
                Amount_USD__c = 100,
                pse__Project__c = testProj1.Id
            );
            listBudget.add(budget);
            
            pse__Budget__c budget2 = new pse__Budget__c (
                Amount_USD__c = 100,
                pse__Project__c = testProj2.Id
            );
            listBudget.add(budget2);
            
            
            List<pse__Milestone__c> milestones = new List<pse__Milestone__c>();
            
            pse__Milestone__c milestone1 = new pse__Milestone__c(
                Name = 'Forecast Completion Date',
                pse__Status__c = 'Open',
                pse__Target_Date__c = Date.today(),
                pse__Project__c = testProj1.Id, Current__c = true
            );
            
            milestones.add(milestone1);
            
            pse__Milestone__c milestone2 = new pse__Milestone__c(
                Name = 'Next Follow Up Date',
                pse__Status__c = 'Open',
                pse__Target_Date__c = Date.today(),
                pse__Project__c = testProj1.Id, Current__c = false
            );
            
            milestones.add(milestone2);
            
            pse__Milestone__c milestone3 = new pse__Milestone__c(
                Name = 'Milestoine Planned 1',
                pse__Status__c = 'Planned',
                pse__Target_Date__c = Date.today(),
                pse__Project__c = testProj2.Id, Current__c = true
            );
            
            milestones.add(milestone3);
            
            pse__Milestone__c milestone4 = new pse__Milestone__c(
                Name = 'Milestone Planned 2',
                pse__Status__c = 'Planned',
                pse__Target_Date__c = Date.today(),
                pse__Project__c = testProj2.Id, Current__c = false
            );
            
            milestones.add(milestone4);
            
            insert milestones;*/
            
            Order order = new Order(
                AccountId = account.Id,
                EffectiveDate = Date.today(),
                Status = 'BK',
                PoNumber = '888999',
                Deal_ID__c = '000111',
                OrderNumber__c = '555666',
                BUID__c = '11',
                PriceBook2Id = Test.getStandardPricebookId(),
                Project__c = engagement1.Id, 
                FF_Feed__c = true
            );
            insert order;
            
            List<Project_Location__c> listProjectLocation = new List<Project_Location__c>();
            
            Project_Location__c projectSite = new Project_Location__c(
                Address_Type__c = 'Install At Contact',
                Location__c = objLocation.Id,
                Project__c = testProj1.Id,
                Order__c = order.Id,
                Default_Address__c = true
            );
            
            listProjectLocation.add(projectSite);
            
            Project_Location__c projectSite2 = new Project_Location__c(
                Address_Type__c = 'Shipping',
                Location__c = objLocation.Id,
                Project__c = testProj1.Id,
                Order__c = order.Id
            );
            
            listProjectLocation.add(projectSite2);
            
            insert listProjectLocation;
            
            Product2 product = new Product2(
                Name = 'Test product'
            );
            
            insert product;
            
            PriceBookEntry priceBookEntry = new PriceBookEntry(
                PriceBook2Id = order.Pricebook2Id,
                Product2Id = product.Id,
                IsActive = true,
                UnitPrice = 1
            );
            
            insert priceBookEntry;
            
            List<pse__Project_Task__c> tasks = new List<pse__Project_Task__c>();
            tasks.add(new pse__Project_Task__c(Name='Initiate', pse__Project__c = testProj1.Id));
            insert tasks;
            System.debug(tasks[0].Id);
            
            List<OrderItem> orderItems = new List<OrderItem>();
            
            orderItems.Add(new OrderItem(
                SKU_Description__c = 'ProDeploy Dell Storage SC Series vXXXX SAN - Deployment Verification',
                SKU_Number__c = '777-1000',
                Quantity = 1,
                UnitPrice = 2,
                Item_Class_Description__c = 'SVC EDT INSTLN',
                Tie_Number__c = '1',
                OrderId = order.Id,
                Project__c = testProj1.Id,
                PriceBookEntryId = priceBookEntry.Id)
                          );
            
            insert orderItems;
            
            Order order2 = new Order(
                AccountId = account.Id,
                EffectiveDate = Date.today(),
                Status = 'BK',
                PoNumber = '888999',
                Deal_ID__c = '000111',
                OrderNumber__c = '555666',
                BUID__c = '11',
                PriceBook2Id = Test.getStandardPricebookId(),
                Project__c = engagement2.Id,
                FF_Feed__c = true
            );
            
            insert order2;
            
            Product2 product2 = new Product2(
                Name = 'Test product'
            );
            
            insert product2;
            
            PriceBookEntry priceBookEntry2 = new PriceBookEntry(
                PriceBook2Id = order2.Pricebook2Id,
                Product2Id = product2.Id,
                IsActive = true,
                UnitPrice = 1
            );
            
            insert priceBookEntry2;
            
            List<OrderItem> orderItems2 = new List<OrderItem>();
            
            orderItems2.Add(new OrderItem(
                SKU_Description__c = 'SKU Desc 1',
                SKU_Number__c = '777-1000',
                Quantity = 1,
                UnitPrice = 2,
                Item_Class_Description__c = 'SVC EDT INSTLN',
                Tie_Number__c = '1',
                Project__c = testProj2.Id,
                OrderId = order2.Id,
                PriceBookEntryId = priceBookEntry2.Id));
            
            insert orderItems2;
            
            SKU_Effort_Map__c skuEffortMap = new SKU_Effort_Map__c(
                Active__c = true,
                Description__c = 'ProDeploy Dell Storage SC Series vXXXX SAN - Deployment Verification',
                Practice__c = objPractice.Id
            );
            insert skuEffortMap;
            
            SKU_Number__c skuNumber = new SKU_Number__c();
            skuNumber.Sku_Name__c = 'ProDeploy Dell Storage SC Series vXXXX SAN - Deployment Verification';            
            skuNumber.SKU_Number__c = '777-1000';
            skuNumber.SKU_to_Effort_Mapping__c = skuEffortMap.Id;
            insert skuNumber;
            
            List<pse__Skill__c> skills = new List<pse__Skill__c>();
            
            pse__Skill__c lowSkill = new pse__Skill__c(Name = 'Project Management (Low)',pse__External_Id__c='9321');
            skills.add(lowSkill);
            
            pse__Skill__c mediumSkill = new pse__Skill__c(Name = 'Project Management (Medium)',pse__External_Id__c='9322');
            skills.add(mediumSkill);
            
            pse__Skill__c highSkill = new pse__Skill__c(Name = 'Project Management (High)',pse__External_Id__c='9323');
            skills.add(highSkill);
            
            insert skills;
            
            SKU_Effort_Map_Entry__c effortMapEntry = new SKU_Effort_Map_Entry__c(project__c = testProj1.Id,
                                                                                 Name__c = 'Remote Config',
                                                                                 SKU_Effort_Map__c = skuEffortMap.Id,
                                                                                 Phase__c = tasks[0].Id,
                                                                                 Role__c = 'Project Manager',
                                                                                 Project_Complexity_Tier__c = 'Tier 1',
                                                                                 Estimated_Hours__c = 10);
            
            insert effortMapEntry;
            
            /* Asset ast = new Asset();
ast.Order_Number__c = order.OrderNumber__c;
ast.Order_Tie_Number__c = 1;
ast.Name = 'AssetName';
insert ast; */
            
            Project_Task_SKU_Effort_Mapping_Entry__c projMapEntry = new Project_Task_SKU_Effort_Mapping_Entry__c();
            projMapEntry.SKU_Effort_Mapping_Entry__c = effortMapEntry.Id;
            projMapEntry.Project_Task__c = tasks[0].Id;
            projMapEntry.SKU_Quantity__c = 2;
            insert projMapEntry;
            
            //Create on Phase: Project ID EQUALS WO SKU Effort Mapping Entry: Template ID
            WO_SKU_Effort_Map__c woSkuEffortMap1 = new WO_SKU_Effort_Map__c(
                Calculation_Type__c = 'By SKU Quantity',
                Delivery_Method__c = 'OnSite',
                Description__c = 'Planning Appointment',
                Duration__c = 20,
                SKU_Effort_Mapping_Entry__c = effortMapEntry.Id,
                Wo_Record_Type__c = 'FF - Unknown',
                Auto_Dispatch__c= True	
            );
            insert woSkuEffortMap1;
            
            WO_SKU_Effort_Map__c woSkuEffortMap2 = new WO_SKU_Effort_Map__c(
                Calculation_Type__c = 'By Threshold',
                Delivery_Method__c = 'OnSite',
                Description__c = 'Scoping Appointment',
                Duration__c = 20,
                SKU_Effort_Mapping_Entry__c = effortMapEntry.Id,
                Wo_Record_Type__c = 'FF - Unknown',
                Auto_Dispatch__c= True	
            );
            insert woSkuEffortMap2;
            
            WorkType resale = new WorkType();
            resale.EstimatedDuration = 60;
            resale.Name = 'FSE Task';
            insert resale;
            
            Order_Item_Sku_Effort_Map__c orderItemSkuEffortMap = new Order_Item_Sku_Effort_Map__c(
                Order_Product__c = orderItems.get(0).Id, 
                SKU_to_Effort_Mapping__c = skuEffortMap.Id, 
                Project_Task__c = tasks[0].Id
            );
            insert orderItemSkuEffortMap;
            
            Project_Task_Skill__c newProjectTaskSkill = new Project_Task_Skill__c(
                Project_Task__c = tasks[0].Id,
                Skill_Certification__c = skills.get(0).Id
            );
            insert newProjectTaskSkill;
            
            List<Project_Complexity_Threshold__c> projComplexities = new List<Project_Complexity_Threshold__c>();
            
            projComplexities.add(new Project_Complexity_Threshold__c (
                Name = 'R1',
                Low_Threshold__c = 1000,
                High_Threshold__c = 2000
            ));
            
            insert projComplexities;
            
            List<Project_Complexity_Mapping__c> projComplexityMappings = new List<Project_Complexity_Mapping__c>();
            
            projComplexityMappings.add(new Project_Complexity_Mapping__c (
                Overall_Project_Complexity__c = 'Low',
                PM_Complexity__c = 'Low',
                Revenue_Threshold__c = 'Low'
            ));
            
            projComplexityMappings.add(new Project_Complexity_Mapping__c (
                Overall_Project_Complexity__c = 'Medium',
                PM_Complexity__c = 'Medium',
                Revenue_Threshold__c = 'Medium'
            ));
            
            projComplexityMappings.add(new Project_Complexity_Mapping__c (
                Overall_Project_Complexity__c = 'High',
                PM_Complexity__c = 'High',
                Revenue_Threshold__c = 'High'
            ));
            
            insert projComplexityMappings;
        }
    }

     @isTest
     static void shouldCreateWorkOrderWhenPhaseChange(){
         
          Test.startTest();
        
         List<pse__Proj__c> oldProjs = [select Id, Name, pse__Project_Phase__c, pse__Account__c, Primary_Contact__c from pse__Proj__c Where Name = 'Test Proj 1'];
		System.debug('oldProjs'+oldProjs[0].Id);
         pse__Proj__c newProj = oldProjs[0].clone(true, true, true, true);
         newProj.pse__Project_Phase__c = 'Initiate';
        
         List<pse__Proj__c> newProjs = new List<pse__Proj__c>();
         newProjs.add(newProj);
     
         IdsProjectHandler.HandlePhaseChange(oldProjs, newProjs);

         Test.stopTest();

         List<WorkOrder> workOrderList = [select Id from WorkOrder];
         System.debug('workOrderList'+workOrderList[0].Id);
         System.assert(workOrderList.size() > 0);
     }
    
     @isTest
     static void shouldValidatePhaseChange(){
        
         System.assertEquals(true, IdsProjectHandler.validatePhaseChange('Setup', 'Initiate'));
         System.assertEquals(true, IdsProjectHandler.validatePhaseChange('Initiate', 'Plan'));
         System.assertEquals(true, IdsProjectHandler.validatePhaseChange('Plan', 'Execute'));
         System.assertEquals(true, IdsProjectHandler.validatePhaseChange('Execute', 'Close'));
        
         System.assertEquals(false, IdsProjectHandler.validatePhaseChange('Initiate', 'Setup'));
      
     }
    
     @isTest
     static void shouldValidatePhaseChangeToInitiate(){
        
         System.assertEquals(true, IdsProjectHandler.validatePhaseChangeToInitiate('Setup', 'Initiate'));
        
         System.assertEquals(false, IdsProjectHandler.validatePhaseChangeToInitiate('Initiate', 'Plan'));
        
     }
    
    
}