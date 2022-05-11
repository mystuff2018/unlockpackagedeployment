/**
 * Created by Bruno_Frosi on 1/14/2020.
 */

@IsTest
private class OrderCreatedValidateCountryStateTest {
    @IsTest
    static void testMailingCountryAndState() {
        Order order = OPRTestFactory.createOrderStateCountry('United States', 'Texas', 'United States', 'Texas', 'United States', 'Texas');
        Set<Id> orderIds = new Set<Id>();
        orderIds.add(order.Id);

        OrderCreatedDataContext context = new OrderCreatedDataContext(orderIds);

        //Act
        OrderCreatedValidateCountryState.validateOrderCountryState(context);
        UPSERT context.orderMap.values();
        UPSERT context.contactMap.values();
        Order result = [SELECT Id, BillToContact.MailingCountry, BillToContact.MailingState FROM Order WHERE Id =:order.Id LIMIT 1];
        system.debug(result);
        //Assert
        System.assert(result != null);
        System.assertEquals(result.BillToContact.MailingCountry, 'United States');
        System.assertEquals(result.BillToContact.MailingState, 'Texas');
    }

    @IsTest
    static void testBillingCountryAndState() {
        Order order = OPRTestFactory.createOrderStateCountry(null, null, 'United States', 'Texas', null, null);
        Set<Id> orderIds = new Set<Id>();
        orderIds.add(order.Id);

        OrderCreatedDataContext context = new OrderCreatedDataContext(orderIds);

        //Act
        OrderCreatedValidateCountryState.validateOrderCountryState(context);
        UPSERT context.orderMap.values();
        UPSERT context.contactMap.values();
        Order result = [SELECT Id, BillingCountry, BillingState FROM Order WHERE Id =:order.Id LIMIT 1];
        system.debug(result);
        //Assert
        System.assert(result != null);
        System.assertEquals(result.BillingCountry, 'United States');
        System.assertEquals(result.BillingState, 'Texas');
    }

    @IsTest
    static void testShippingCountryAndState() {
        Order order = OPRTestFactory.createOrderStateCountry(null, null, null, null, 'United States', 'Texas');
        Set<Id> orderIds = new Set<Id>();
        orderIds.add(order.Id);

        OrderCreatedDataContext context = new OrderCreatedDataContext(orderIds);

        //Act
        OrderCreatedValidateCountryState.validateOrderCountryState(context);
        UPSERT context.orderMap.values();
        UPSERT context.contactMap.values();
        Order result = [SELECT Id, ShippingCountry, ShippingState FROM Order WHERE Id =:order.Id LIMIT 1];
        system.debug(result);
        //Assert
        System.assert(result != null);
        System.assertEquals(result.ShippingCountry, 'United States');
        System.assertEquals(result.ShippingState, 'Texas');
    }

    @IsTest
    static void testInvalidMailingCountryAndState() {
        String invalidCountry = 'UnitedStates';
        Order order = OPRTestFactory.createOrderStateCountry(invalidCountry, 'Texas', null, null, null, null);
        Set<Id> orderIds = new Set<Id>();
        orderIds.add(order.Id);

        OrderCreatedDataContext context = new OrderCreatedDataContext(orderIds);

        //Act
        OrderCreatedValidateCountryState.validateOrderCountryState(context);
        UPSERT context.orderMap.values();
        UPSERT context.contactMap.values();
        UPSERT context.exceptionLoggers;

        Order result = [SELECT Id, BillToContact.MailingCountry, BillToContact.MailingState FROM Order WHERE Id =:order.Id LIMIT 1];
        ExceptionLogger__c exceptionLogger = [SELECT Description__c,Apex_Class__c from ExceptionLogger__c where Apex_Class__c = 'ValidateCountryAndState' LIMIT 1];

        system.debug(result);
        //Assert
        System.assert(result != null);
        System.assertEquals(result.BillToContact.MailingCountry, null);
        System.assertEquals(result.BillToContact.MailingState, null);
        System.assertEquals('Invalid Country: '+ invalidCountry , exceptionLogger.Description__c);
        System.assertEquals('ValidateCountryAndState' , exceptionLogger.Apex_Class__c);
    }

}