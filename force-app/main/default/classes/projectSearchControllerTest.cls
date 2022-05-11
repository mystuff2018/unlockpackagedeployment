@isTest
     public class projectSearchControllerTest {

     @testSetup
         static void makeData(){
             //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
             List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
             system.runAs(loginUser[0]){ 
                 pse__Proj__c engagement1 = new pse__Proj__c(
                     Name = 'Engagement Test 1', 
                     DP__c = '1',
                    RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId()
                 );
                 pse__Proj__c engagement2 = new pse__Proj__c(
                     Name = 'Engagement Test 2', 
                     DP__c = '2',
                     RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId()
                 );
                 insert new List<pse__Proj__c>{engagement1, engagement2};
                     
                 List<pse__Proj__c> childprojList = new List<pse__Proj__c>(); 
                 
                 pse__Proj__c childProject1 = OPRTestFactory.createSimpleProject();
                 childProject1.pse__Parent_Project__c = engagement1.Id;
                 childProject1.Name = 'Project Deliver 1005';
                 childProject1.pse__Stage__c = 'Draft';
                 childProject1.pse__Start_Date__c = System.Today().addDays(0);
                 childProject1.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Tier_1').getRecordTypeId();
                 childprojList.add(childProject1);
                 
                 pse__Proj__c childProject2 = childProject1.clone(false, true, false, false);
                 childProject2.Name = 'Project Deliver 1015';
                 childProject2.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Tier_1').getRecordTypeId();
                 //childProject2.CreatedDate = System.Today().addDays(-10);
                 childprojList.add(childProject2);

                 pse__Proj__c childProject3 = childProject1.clone(false, true, false, false);
                 childProject3.Name = 'Project Deliver 1015';
                 childProject3.pse__Stage__c = 'Closure';
                 childProject3.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Tier_1').getRecordTypeId();
                 //childProject3.CreatedDate = System.Today().addDays(-10);
                 childprojList.add(childProject3);

                 pse__Proj__c childProject4 = childProject1.clone(false, true, false, false);
                 childProject4.Name = 'Project Deliver 1020';
                 childProject4.pse__Stage__c = 'Cancelled';
                 childProject4.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Tier_1').getRecordTypeId();
                 //childProject4.CreatedDate = System.Today().addDays(-10);
                 childprojList.add(childProject4);

                 pse__Proj__c childProject5 = OPRTestFactory.createSimpleProject();
                 childProject5.pse__Parent_Project__c = engagement2.Id;
                 childProject5.Name = 'Project Anonymous 8520';
                 childProject5.pse__Stage__c = 'Draft';
                 childProject5.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Tier_1').getRecordTypeId();
                 childprojList.add(childProject5);                
                 
                 pse__Proj__c childProject6 = OPRTestFactory.createSimpleProject();
                 childProject6.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Tier_1').getRecordTypeId();
                 childprojList.add(childProject6);
                 
                 upsert childprojList;         

                 Account acc1 = new Account(Id = childProject1.pse__Account__c, Name = 'Deliver Deliver Deliver');
                 Account acc2 = new Account(Id = childProject5.pse__Account__c, Name = 'Deliver Anonymous Association');
                 update new List<Account>{acc1, acc2};
                     }
         }

        @isTest
        static void shouldSearchReturnResult(){

            List<pse__Proj__c> projectList = [
                SELECT Id, Name, pse__Project_ID__c
                FROM pse__Proj__c
            ];

            List<Id> fixedSearchResults = new List<Id>();
            for(pse__proj__c proj: projectList){
                fixedSearchResults.add(proj.Id);
            }
            
            Test.setFixedSearchResults(fixedSearchResults);

            Test.startTest();

            String result = projectSearchController.searchEngagements('deliver', null, String.valueOf(System.Today().addDays(-30)), String.valueOf(System.Today().addDays(1)), false, false);
            List<projectSearchController.SearchResult> resultList = (List<projectSearchController.SearchResult>)JSON.deserialize(result, List<projectSearchController.SearchResult>.class);
            System.debug('@resultList: ' + resultList);

            Test.stopTest();

            //System.assertEquals(2, resultList.size(), 'Search should return two results');
        }
        
        @isTest
        static void shouldSearchReturnNothing(){

            List<pse__Proj__c> projectList = [
                SELECT Id, Name, pse__Project_ID__c
                FROM pse__Proj__c
                WHERE pse__Start_Date__c < :System.Today().addDays(-30)
            ];

            List<Id> fixedSearchResults = new List<Id>();
            for(pse__proj__c proj: projectList){
                fixedSearchResults.add(proj.Id);
            }
            
            Test.setFixedSearchResults(fixedSearchResults);

            Test.startTest();
            String result = projectSearchController.searchEngagements('deliver', null, String.valueOf(System.Today().addDays(-30)), String.valueOf(System.Today()), false, false);
            List<projectSearchController.SearchResult> resultList = (List<projectSearchController.SearchResult>)JSON.deserialize(result, List<projectSearchController.SearchResult>.class);
            System.debug('@resultList: ' + resultList);

            Test.stopTest();

            System.assertEquals(0, resultList.size(), 'Search should return no result');
        }

        @isTest
        static void shouldSearchBasedOnCustomerName(){

            List<Account> accList = [
                SELECT Id
                FROM Account
            ];
            
            List<Id> fixedSearchResults = new List<Id>();
            for(Account acc : accList) {
                fixedSearchResults.add(acc.Id);
            }

            System.debug('@fixedSearchResults: ' + fixedSearchResults);
            Test.setFixedSearchResults(fixedSearchResults);

            Test.startTest();

            String result = projectSearchController.searchEngagements(null, 'Deliver', String.valueOf(System.Today().addDays(-30)), String.valueOf(System.Today()), false, false);
            List<projectSearchController.SearchResult> resultList = (List<projectSearchController.SearchResult>)JSON.deserialize(result, List<projectSearchController.SearchResult>.class);
            System.debug('@resultList: ' + resultList);

            Test.stopTest();

            //System.assertEquals(1, resultList.size(), 'Search should return one result');
        }

        @isTest
        static void shouldSearchIncludingCancelled(){

            List<pse__Proj__c> projectList = [
                SELECT Id, Name, pse__Project_ID__c
                FROM pse__Proj__c
            ];

            List<Id> fixedSearchResults = new List<Id>();
            for(pse__proj__c proj: projectList){
                fixedSearchResults.add(proj.Id);
            }
            
            Test.setFixedSearchResults(fixedSearchResults);

            Test.startTest();

            String result = projectSearchController.searchEngagements('deliver', null, String.valueOf(System.Today().addDays(-30)), String.valueOf(System.Today().addDays(1)), true, false);
            List<projectSearchController.SearchResult> resultList = (List<projectSearchController.SearchResult>)JSON.deserialize(result, List<projectSearchController.SearchResult>.class);
            System.debug('@resultList: ' + resultList);

            Test.stopTest();

           // System.assertEquals(2, resultList.size(), 'Search should return two results');
        }
        
        @isTest
        static void shouldSearchIncludingClosure(){

            List<pse__Proj__c> projectList = [
                SELECT Id, Name, pse__Project_ID__c
                FROM pse__Proj__c
            ];

            List<Id> fixedSearchResults = new List<Id>();
            for(pse__proj__c proj: projectList){
                fixedSearchResults.add(proj.Id);
            }
            
            Test.setFixedSearchResults(fixedSearchResults);

            Test.startTest();

            String result = projectSearchController.searchEngagements('deliver', null, String.valueOf(System.Today().addDays(-30)), String.valueOf(System.Today().addDays(1)), false, true);
            List<projectSearchController.SearchResult> resultList = (List<projectSearchController.SearchResult>)JSON.deserialize(result, List<projectSearchController.SearchResult>.class);
            System.debug('@resultList: ' + resultList);

            Test.stopTest();

            //System.assertEquals(2, resultList.size(), 'Search should return two results');
        }
        
        @isTest
        static void shouldValidateStageList(){

            Test.startTest();
            Set<String> stageMap1 = projectSearchController.retrieveStageList(false, false);
            Set<String> stageMap2 = projectSearchController.retrieveStageList(true, false);
            Set<String> stageMap3 = projectSearchController.retrieveStageList(false, true);
            Set<String> stageMap4 = projectSearchController.retrieveStageList(true, true);
            Test.stopTest();

            System.assertEquals(true, stageMap1.contains('Closure'), 'Stage map should contains closure key');
            System.assertEquals(true, stageMap1.contains('Cancelled'), 'Stage map should contains cancelled key');
            System.assertEquals(true, stageMap2.contains('Closure'), 'Stage map should contains closure key');
            System.assertEquals(false, stageMap2.contains('Cancelled'), 'Stage map should not contains cancelled key');
            System.assertEquals(false, stageMap3.contains('Closure'), 'Stage map should not contains closure key');
            System.assertEquals(true, stageMap3.contains('Cancelled'), 'Stage map should contains cancelled key');
            System.assertEquals(false, stageMap4.contains('Closure'), 'Stage map should not contains closure key');
            System.assertEquals(false, stageMap4.contains('Cancelled'), 'Stage map should not contains cancelled key');
        }

        @isTest
        static void shouldRetrieveChildProject(){

            Id parentProjectId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();

            List<pse__Proj__c> engagements = [
                SELECT Id 
                FROM pse__Proj__c
                WHERE RecordTypeId= :parentProjectId
                AND DP__c like '%1'
            ];
            Test.startTest();
            String result = projectSearchController.retrieveChildProjects(engagements[0].Id);
            List<projectSearchController.SearchResult> resultList = (List<projectSearchController.SearchResult>)JSON.deserialize(result, List<projectSearchController.SearchResult>.class);
            System.debug('@resultList: ' + resultList);

            Test.stopTest();

            //System.assertEquals(4, resultList.size(), 'Search should return four child projects for the first engagement.');
        }

        @isTest
        static void shouldRetrieveOrderInformation(){
            
            Order order = OPRTestFactory.createSimpleOrder();

            Test.startTest();
            String result = projectSearchController.retrieveOrderNumbers(new List<String>{order.Id});
            List<projectSearchController.OrderInformation> resultList = (List<projectSearchController.OrderInformation>)JSON.deserialize(result, List<projectSearchController.OrderInformation>.class);
            Test.stopTest();

            System.assertEquals(order.Id, resultList[0].Id, 'Return Id should be equal order Id');
            System.assertEquals(false, resultList[0].hasProject, 'Order does not has project.');
        }

        @isTest
        static void shouldPublishEventToAssociate(){

            Id parentProjectId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();

            List<pse__Proj__c> engagements = [
                SELECT Id
                FROM pse__Proj__c
                WHERE RecordTypeId = :parentProjectId
                AND DP__c like '%1'
            ];

            Order order = OPRTestFactory.createSimpleOrder();

            Test.startTest();
            Boolean publishResult = projectSearchController.associateOrdersToProject(order.Id, engagements[0].Id);
            Test.stopTest();

            System.assertEquals(true, publishResult, 'Association event should be published succesfully');

        }

     }