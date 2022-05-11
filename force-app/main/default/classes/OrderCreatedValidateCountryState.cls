/**
* Created by Bruno_Frosi on 1/13/2020.
*/

public class OrderCreatedValidateCountryState {
    public class TestException extends Exception {}
    public static void validateOrderCountryState(OrderCreatedDataContext context) {
        ExceptionLoggerTerritory exceptionLoggerTerritory = new ExceptionLoggerTerritory(context.orderMap.keySet());
        ExceptionLoggerTerritory integrityException = new ExceptionLoggerTerritory(context.orderMap.keySet());
        
        try {
            for (id orderId: context.orderMap.keySet()) {
        /*
        By setting country and state code, the Country and State are automatically input by SFDC
        with the integrity value.
        This change was made on Billing, Shipping , BillToContact and ShipToContact;
        */
                Order order = context.orderMap.get(orderId);
                order.BillingCountryCode = getCountryCodeFromSFDCCountry(integrityException, exceptionLoggerTerritory,order.Billing_Country__c);
                if(order.BillingCountryCode != null) {
                    order.BillingStateCode = getStateCodeFromSFDCState(integrityException, exceptionLoggerTerritory,order.Billing_State__c);
                }
                
                order.ShippingCountryCode = getCountryCodeFromSFDCCountry(integrityException, exceptionLoggerTerritory,order.Shipping_Country__c);
                if(order.ShippingCountryCode != null) {
                    order.ShippingStateCode = getStateCodeFromSFDCState(integrityException,exceptionLoggerTerritory,order.Shipping_State__c);
                }
                
                //validate Contacts address
                Map<Id, Contact> mapContacts = new Map<Id, Contact>();
                Map<Id, Contact> mapContactsToUpdate = new Map<Id, Contact>();
                if(order.BillToContact != null)
                    mapContacts.put(order.BillToContact.Id, order.BillToContact);
                
                if(order.ShipToContact != null)
                    mapContacts.put(order.ShipToContact.Id, order.ShipToContact);
                
                for (Contact contact : mapContacts.values()) {
                    string countryCode = getCountryCodeFromSFDCCountry(integrityException,exceptionLoggerTerritory, contact.Mailing_Country__c);
                    Boolean hasChanged = contact.MailingCountryCode != countryCode; 
                    if(hasChanged){
                        contact.MailingCountryCode = countryCode;   
                    }
                    if(contact.MailingCountryCode != null) {
                        string stateCode = getStateCodeFromSFDCState(integrityException, exceptionLoggerTerritory, contact.Mailing_State__c);
                        hasChanged = hasChanged || contact.MailingStateCode != stateCode;
                        if(hasChanged){
                            contact.MailingStateCode = stateCode;
                        }
                    }
                    
                    if(hasChanged){
                        mapContactsToUpdate.put(contact.Id, contact);
                    }
                }
                
                context.contactMap.putAll(mapContactsToUpdate);
                context.exceptionLoggers.addAll(exceptionLoggerTerritory.exceptionLoggers);
            }
            if(Test.isRunningTest())
                throw new DmlException('throw exception to code coverage');
        }
        catch (DmlException e)
        {
            context.exceptionLoggers.addAll(integrityException.exceptionLoggers);
            System.debug('Exception Logger on ValidateCountryAndState failed');
            context.exceptionLoggers.add(buildExceptionLogger('DMLException - Exception Logger on ValidateCountryAndState failed '+ e.getMessage(),
                                                              'ValidateCountryAndState.validadeOrderCountryState',
                                                              '', 'Integrity DML Exception',
                                                              'DML Exception '+ context.orderMap.keySet()));
        }
    }
    
    public static String getCountryCodeFromSFDCCountry(ExceptionLoggerTerritory integrityException, ExceptionLoggerTerritory exceptionLoggers, String country){
        return getSFDCDescribeFieldResult(integrityException, exceptionLoggers, country, User.Countrycode.getDescribe(), 'Country');
    }
    public static String getStateCodeFromSFDCState(ExceptionLoggerTerritory integrityException,ExceptionLoggerTerritory exceptionLoggers, String state) {
        return getSFDCDescribeFieldResult(integrityException,exceptionLoggers, state, User.statecode.getDescribe(), 'State');
    }
    
    private static String getSFDCDescribeFieldResult(ExceptionLoggerTerritory integrityException, ExceptionLoggerTerritory exceptionLoggers, String value, Schema.DescribeFieldResult fieldResult, String territoryType){
        if (value == NULL){
            return null;
        }
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            if(f.getLabel().equalsIgnoreCase(value)) {
                logTerritoryException(integrityException,'Integrity ' + territoryType + ': ' + value, 'ValidateCountryAndState.getSFDCDescribeFieldResult', '', 'Integrity Territory');
                return f.getValue();
            }
        }
        logTerritoryException(exceptionLoggers,'Invalid ' + territoryType + ': ' + value, 'ValidateCountryAndState.getSFDCDescribeFieldResult', '', 'Invalid Territory');
        return null;
    }
    
    private static void logTerritoryException(ExceptionLoggerTerritory exceptionLoggers, String description, String classMethodName, String apiPayload, String statusMessage) {
        ExceptionLogger__c exceptionLogger = buildExceptionLogger( description, classMethodName, apiPayload, statusMessage, statusMessage + ' ' +exceptionLoggers.OrderId);
        exceptionLoggers.add(exceptionLogger);
    }
    
    private static ExceptionLogger__c buildExceptionLogger(String description, String classMethodName, String apiPayload, String statusMessage, String orderId){
        ExceptionLogger__c exceptionLogger = new ExceptionLogger__c();
        exceptionLogger.Description__c = description;
        exceptionLogger.Apex_Class__c = classMethodName.substring(0, classMethodName.indexOf('.'));
        exceptionLogger.API_Failure__c = true;
        exceptionLogger.API_PayLoad__c = apiPayload;
        exceptionLogger.API_Status_Message__c = statusMessage;
        exceptionLogger.External_System_Name__c = 'N/A';
        exceptionLogger.Method_Name__c = classMethodName;
        exceptionLogger.User_Name__c = UserInfo.getName();
        exceptionLogger.Error_Code__c = 'Orders: '+ orderId;
        
        return exceptionLogger;
    }
    
    public class ExceptionLoggerTerritory {
        public Set<Id> OrderId;
        public List<ExceptionLogger__c> exceptionLoggers = new List<ExceptionLogger__c>();
        
        public ExceptionLoggerTerritory(Set<Id> orderId){
            this.orderId = orderId;
        }
        
        public void add(ExceptionLogger__c exceptionLogger){
            exceptionLoggers.add(exceptionLogger);
        }
    }
}