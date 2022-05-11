@isTest
public class LocationTimeZoneBatch_Test {
 @testSetup
    public static void setup()
    {
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            Account acc = new Account(
                Name = 'YY09DD181005 QE TEST',                     // Account
                Customer_Type__c = 'Inherit',                      // Customer Type
                BUID__c = '11',                                    // Account BUID
                Installed_At__c = false,                           // Installed At
                Site_Visibility__c = 'Open',                       // Site Visibility
                Controlled_Support_Type__c = 'Unrestricted',       // Controlled Support Type
                Controlled_Support_Strategy__c = 'Unrestricted',   // Controlled Support Strategy
                Controlled_Support_Country__c = 'Unrestricted'    // Controlled Support Country
            );
            INSERT acc;
            
            List<Schema.Location> locs = new List<Schema.Location>();
            for(integer i=0;i<90;i++)
            {
                Schema.Location loc = new Schema.Location(
                    Name = 'California_EL CAMINO',                                       // Location Name
                    LocationType = 'Warehouse',  // Time Zone
                    Account__c = acc.Id,                                     // Account
                    Status__c = 'Active',                                               // Status
                    TimeZone = 'America/Los_Angeles'
                );
                locs.add(loc);
            }
            INSERT locs;
            
            List<Schema.Address> addrs = new List<Schema.Address>();
            for(integer i=0;i<90;i++)
            {
                Schema.Address adr = new Schema.Address(
                    ParentId = locs[i].Id,// Parent
                    LocationType = 'Warehouse',       // Location Type
                    AddressType = 'Mailing',          // Address Type
                    Primary_Address__c = true,        // Primary Address
                    city = 'EL CAMINO',
                    country = 'United States',
                    countryCode = 'US',
                    geocodeAccuracy = 'ExtendedZip',
                    latitude = 33.9234,
                    longitude = -118.3939,
                    postalCode = '90245-3457',
                    state = 'California',
                    stateCode = 'CA', 
                    street = '1940 DUNKIRK AVE'
                );
                addrs.add(adr);
            }
            INSERT addrs;
        }
    }
    
    @isTest
    public static void test1()
    {
        LocationTimeZoneBatch.ExecuteBatch();
    }
    
        @isTest
    public static void test2()
    {
        LocationTimeZoneBatch obj = new LocationTimeZoneBatch('SELECT Id FROM Location WHERE TimeZone = NULL');
        database.ExecuteBatch(obj);
    }
 }