/**
 * Created by Bruno_Frosi on 1/27/2020.
 */

@IsTest
private class CreateProjectFieldMapperTest {
    @IsTest
    static void testBehavior() {
        //[Deloitte : Abhishek Kawle] : Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            List<Account> accs = new List<Account>();
            accs.add(OPRTestFactory.newAccount('Account for testing', '111', '11', '12'));
            accs.add(OPRTestFactory.newAccount('Account for testing', '111', '11', '12'));
            accs.add(OPRTestFactory.newAccount('Account for testing', '111', '11', '12'));
            accs.add(OPRTestFactory.newAccount('Account for testing', '222', '11', '12'));
            accs.add(OPRTestFactory.newAccount('Account for testing', '222', '11', '12'));
            accs.add(OPRTestFactory.newAccount('Account for testing', '222', '11', '12'));
            accs.add(OPRTestFactory.newAccount('Account for testing', '333', '11', '12'));
            accs.add(OPRTestFactory.newAccount('Account for testing', '333', '11', '12'));
            accs.add(OPRTestFactory.newAccount('Account for testing', '333', '11', '12'));
            accs.add(OPRTestFactory.newAccount('Account for testing', '444', '11', '12'));
            accs.add(OPRTestFactory.newAccount('Account for testing', '444', '11', '12'));
            accs.add(OPRTestFactory.newAccount('Account for testing', '444', '11', '12'));
            INSERT accs;
            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','1234567898');
            INSERT contact;
            
            Order ordr = OPRTestFactory.newOrderWithItem('123123', accs[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                                                         null,
                                                         null,
                                                         null,
                                                         accs[1].Id,
                                                         '123',
                                                         'SVC EDT INSTLN'
                                                        );
            
            pse__Proj__c project = OPRTestFactory.createProjectTemplate(accs[0].Id, '666', '777', '888');
            INSERT project;
            
            Set<Id> setIdOrders = new Set<Id>();
            Map<Id, Id> orderItemToPracticeIds = new Map<Id, Id>(); 
            Map<Id, Id> orderItemToEngagementIds = new Map<Id, Id>();
            Map<Id, String> orderItemToGroupingKeyIds = new Map<Id, String>();
            setIdOrders.add(ordr.Id);
            
            CreateProjectDataContext context = new CreateProjectDataContext(setIdOrders, orderItemToPracticeIds, orderItemToEngagementIds, orderItemToGroupingKeyIds);
            
            SKU_Effort_Map__c skuEffortMap = new SKU_Effort_Map__c(
                Active__c = true,
                Description__c = 'ProDeploy Dell Storage SC Series vXXXX SAN - Deployment Verification',
                X30_Day_Support__c = true
            );
            insert skuEffortMap;
            System.debug('@@55' +skuEffortMap);
            
            Test.startTest();
             CreateProjectFieldMapper.getFields(context, ordr, accs[0], project, (skuEffortMap.Id + ';' + skuEffortMap.Id + ';' + skuEffortMap.Id + ';' + skuEffortMap.Id + ';' + skuEffortMap.Id + ';' + skuEffortMap.Id + ';' + skuEffortMap.Id + ';' + skuEffortMap.Id + ';' + skuEffortMap.Id + ';' + skuEffortMap.Id));
             //CreateProjectFieldMapper.getFields(context, ordr, accs[0], project,skuEffortMap.id);
            Test.stopTest();
        }
    }
}