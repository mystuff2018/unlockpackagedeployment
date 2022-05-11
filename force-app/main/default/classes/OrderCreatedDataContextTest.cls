/**
 * Created by Bruno_Frosi on 1/13/2020.
 */

@IsTest
private class OrderCreatedDataContextTest {
    @IsTest
    static void testBehavior() {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){     
            List<Account> listAcc = new List<Account>();
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '111'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '123'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '234'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '345'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '456'));
            INSERT listAcc;

            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','3452644569');
            INSERT contact;

            Order ordr = OPRTestFactory.newOrderWithItem('123123', listAcc[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                    listAcc[1].Id,
                    listAcc[2].Id,
                    listAcc[3].Id,
                    listAcc[4].Id);

            Set<Id> setIdOrders = new Set<Id>();
            setIdOrders.add(ordr.Id);

            Test.startTest();
            OrderCreatedDataContext context = new OrderCreatedDataContext(setIdOrders);
            Test.stopTest();
        }   
    }

    @IsTest
    static void testBehavior2() {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){     
            List<Account> listAcc = new List<Account>();
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '111'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '123'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '234'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '345'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '456'));
            INSERT listAcc;

            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','3431784569');
            INSERT contact;

            Order ordr = OPRTestFactory.newOrderWithItem('123123', listAcc[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                    listAcc[1].Id,
                    listAcc[2].Id,
                    listAcc[3].Id,
                    listAcc[4].Id);

            Set<Id> setIdOrders = new Set<Id>();
            setIdOrders.add(ordr.Id);

            Test.startTest();
            OrderCreatedDataContext context = new OrderCreatedDataContext(setIdOrders);
            context.Refresh(setIdOrders);
            Test.stopTest();
        }   
    }

    @IsTest
    static void testBehavior3() {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){   
            List<Account> listAcc = new List<Account>();
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '111'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '123'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '234'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '345'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '456'));
            INSERT listAcc;

            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','3452736569');
            INSERT contact;

            Order ordr = OPRTestFactory.newOrderWithItem('123123', listAcc[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                    listAcc[1].Id,
                    listAcc[2].Id,
                    listAcc[3].Id,
                    listAcc[4].Id);

            Set<Id> setIdOrders = new Set<Id>();
            setIdOrders.add(ordr.Id);

            Order_Processing__c orderProcessing = new Order_Processing__c(OrderId__c = ordr.Id, ProcessStatus__c = 'Pending');
            insert orderProcessing;

            Test.startTest();
            OrderCreatedDataContext context = new OrderCreatedDataContext(setIdOrders);
            context.listOrderProcessing = new List<Order_Processing__c>{orderProcessing};
            context.Save();
            Test.stopTest();
        }   
    }

    @IsTest
    static void testBehaviorCOMPLETE() {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){     
            List<Account> listAcc = new List<Account>();
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '111'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '123'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '234'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '345'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '456'));
            INSERT listAcc;

            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','3452762569');
            INSERT contact;

            Order ordr = OPRTestFactory.newOrderWithItem('123123', listAcc[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                    listAcc[1].Id,
                    listAcc[2].Id,
                    listAcc[3].Id,
                    listAcc[4].Id);

            Set<Id> setIdOrders = new Set<Id>();
            setIdOrders.add(ordr.Id);
            
            Order_Processing__c orderProcessing = new Order_Processing__c(OrderId__c = ordr.Id, ProcessStatus__c = 'Pending');
            insert orderProcessing;

            Test.startTest();
            OrderCreatedDataContext context = new OrderCreatedDataContext(setIdOrders);
            context.listOrderProcessing = new List<Order_Processing__c>{orderProcessing};
            context.Refresh(setIdOrders);
            context.Save();
            Test.stopTest();
        }   
    }

    @IsTest
    static void testBehaviorCOMPLETE2() {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){   
            List<Account> listAcc = new List<Account>();
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '111'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '123'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '234'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '345'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '456'));
            INSERT listAcc;

            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','8452784569');
            INSERT contact;

            Order ordr = OPRTestFactory.newOrderWithItem('123123', listAcc[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                    listAcc[1].Id,
                    listAcc[2].Id,
                    listAcc[3].Id,
                    listAcc[4].Id);

            Set<Id> setIdOrders = new Set<Id>();
            setIdOrders.add(ordr.Id);

            Account acc2 = OPRTestFactory.newAccount('Account for testing', '123', '11', '987');
            pse__Proj__c project = OPRTestFactory.createProject(acc2.Id, '111', '222', '333');

            pse__Skill__c lowSkill = new pse__Skill__c(Name = 'Project Management (Low)', pse__External_Id__c='9321');
            pse__Skill__c mediumSkill = new pse__Skill__c(Name = 'Project Management (Medium)', pse__External_Id__c='9323');
            pse__Skill__c highSkill = new pse__Skill__c(Name = 'Project Management (High)', pse__External_Id__c='9324');
            List<pse__Skill__c> skills = new List<pse__Skill__c>();
            skills.add(lowSkill);
            skills.add(mediumSkill);
            skills.add(highSkill);
            insert skills;
            
            Order_Processing__c orderProcessing = new Order_Processing__c(OrderId__c = ordr.Id, ProcessStatus__c = 'Pending');
            insert orderProcessing;

            Test.startTest();
            OrderCreatedDataContext context = new OrderCreatedDataContext(setIdOrders);
            context.listOrderProcessing = new List<Order_Processing__c>{orderProcessing};

            context.Refresh(setIdOrders);
            context.orderToProjectAssociate.put(ordr.Id, project.Id);
            context.Save();
            Test.stopTest();
        }   
    }
}