/*
 * @test OrderAssociationProjectLocationTest
 * @author Pablo Dunke and Christopher Michel
 * @date 02/12/2020
 * @description This class is a refactored version of the class SiteManager
 */

public with sharing class OrderAssociationProjectLocation
{
    public static void createAndAssociateProjectLocation(OrderAssociationDataContext context)
    {
        //createLocation(context);
        createLocationfromAccount(context);
        saveLocation(context);
        associateProjectLocation(context);
    }

    public static void createLocationfromAccount(OrderAssociationDataContext context){
        List<Order> listOrder = context.orderMap.values();
        List<Schema.Location> listLocations = new List<Schema.Location>();
        context.mapAccountIdLocation = new  Map<Id, Schema.Location>();
        for(Order orderRec : listOrder){
            if(context.mapAccountIdListLocation != null && context.mapAccountIdListLocation.get(orderRec.accountId) != null)
                listLocations = context.mapAccountIdListLocation.get(orderRec.accountId);
            Schema.Location existingLocation = getExistingLocations(context, orderRec.ShippingStreet, orderRec.ShippingPostalCode, listLocations);
			system.debug('existingLocation '+existingLocation);
            if(existingLocation == null)
            {
                Schema.Location location = new Schema.Location();
                location.Account__c = orderRec.accountId;
                location.Status__c = 'Active';
                location.Name = (orderRec.ShippingCity != null) ? orderRec.ShippingStreet + '_' + orderRec.ShippingCity : orderRec.ShippingStreet;
                context.mapAccountIdLocation.put(orderRec.accountId, location);

                listLocations.add(location);
                context.mapAccountIdListLocation.put(orderRec.accountId, listLocations);
            }
        }
    }
    public static void createLocation(OrderAssociationDataContext context)
    {
        List<Order> listOrder = context.orderMap.values();
        for(Order forOrder: listOrder)
        {
            if(forOrder.Install_At_Contact__c != null)
                createLocationByContact(context, forOrder.accountId, forOrder.Install_At_Contact__c);

            if(forOrder.ShipToContactId != null)
                createLocationByContact(context, forOrder.accountId, forOrder.ShipToContactId);
        }
    }

    public static void createLocationByContact(OrderAssociationDataContext context, Id accountId, Id contactId)
    {
        Contact contact = context.mapContact.get(contactId);
        if(contact != null)
        {
            List<Schema.Location> listLocations = new List<Schema.Location>();
            if(context.mapAccountIdListLocation != null && context.mapAccountIdListLocation.get(accountId) != null)
                listLocations = context.mapAccountIdListLocation.get(accountId);

            Schema.Location existingLocation = getExistingLocations(context, contact.MailingStreet, contact.MailingPostalCode, listLocations);

            if(existingLocation == null)
            {
                Schema.Location location = new Schema.Location();
                location.Account__c = accountId;
                location.Status__c = 'Active';
                location.Name = (contact.MailingCity != null) ? contact.MailingStreet + '_' + contact.MailingCity : contact.MailingStreet;
                context.mapContactIdLocation.put(contact.Id, location);

                listLocations.add(location);
                context.mapAccountIdListLocation.put(accountId, listLocations);
            }
        }
    }

    public static void saveLocation(OrderAssociationDataContext context)
    {
       // upsert context.mapContactIdLocation.values();
      // system.debug('Acc Loc '+context.mapAccountIdLocation.values());
        if(context.mapAccountIdLocation.values().size() > 0){
            upsert context.mapAccountIdLocation.values(); 
        }
       
       /*List<Schema.location> listLocation = new List<Schema.location>();
       for(List<Schema.location> loc : context.mapAccountIdListLocation.values() ){
           listLocation.addAll(loc);
       }      
       upsert listLocation;*/
    }

    public static void associateProjectLocation(OrderAssociationDataContext context)
    {
        Set<String> setState = new Set<String>();
        Schema.DescribeFieldResult describeState = User.statecode.getDescribe();
        for(Schema.PicklistEntry forEntry: describeState.getPicklistValues())
            setState.add(forEntry.getLabel().toLowerCase());

        for(Id forProjectId: context.projectMap.keySet())
        {
            for(Id forOrderId: context.projectWithOrdersMap.get(forProjectId))
            {
                Order forOrder = context.orderMap.get(forOrderId);
                if(forOrder != null)
                {
                    /*if(forOrder.Install_At_Contact__c != null) 
                    {
                        createProjectLocation(context, forOrder, forProjectId, 'Install At Contact', setState);
                    }
                    if(forOrder.ShipToContactId != null) 
                    {
                        createProjectLocation(context, forOrder, forProjectId, 'Shipping', setState);
                    }*/
                    createProjectLocationWithAccount(context, forOrder, forProjectId, setState);
                }
            }
        }
    }
 @TestVisible
   private static Project_Location__c updateShippingLocation(Project_Location__c location)
    {
        location.Default_Address__c = false;
        return location;
    }
	
    private static void createProjectLocationWithAccount(OrderAssociationDataContext context, Order order, Id projectId, Set<String> setState){
        List<Schema.Location> listLocations = new List<Schema.Location>();

        Boolean hasList = context.mapAccountIdListLocation != null;
        Boolean hasLocationByAccountId = context.mapAccountIdListLocation.get(order.accountId) != null;
        if(hasList && hasLocationByAccountId)
            listLocations = context.mapAccountIdListLocation.get(order.accountId);
        List<Project_Location__c> projectLocations = context.mapProjectIdListProjectLocation.get(projectId);
        Schema.Location objLocation = getExistingLocations(context, order.ShippingStreet, order.ShippingPostalCode, listLocations);
        if(objLocation != null) 
        {
            if(!projectLocationExistsForAcccount(projectLocations, objLocation.Id)) 
            {
                Project_Location__c newProjectLocation = createProjectLocationObjectForAccount(objLocation, order.Id, projectId, false);
                context.saveProjectLocation.add(newProjectLocation);
    
                if(projectLocations == null)
                    projectLocations = new List<Project_Location__c>();
                projectLocations.add(newProjectLocation);
                context.mapProjectIdListProjectLocation.put(projectId, projectLocations);
            }
        }
        else 
        {
            Boolean isValidState = (setState != null && order.ShippingState != null) ? setState.contains(order.ShippingState.toLowerCase()) : false;

            Schema.Location location = context.mapAccountIdLocation.get(order.AccountId);
            Schema.Address address = createAddressObjectWithOrder(order, location, isValidState);
            context.saveAddress.add(address);

            List<Schema.Address> listAddress = context.mapLocationIdListAddress.get(location.Id);
            if(listAddress == null)
                listAddress = new List<Schema.Address>();
            listAddress.add(address);
            context.mapLocationIdListAddress.put(location.Id, listAddress);

            Project_Location__c newProjectLocation = createProjectLocationObjectForAccount(location, order.Id, projectId, false);
            context.saveProjectLocation.add(newProjectLocation);

            List<Project_Location__c> listProjectLocationByOrder = context.mapProjectIdListProjectLocation.get(projectId);

            if(listProjectLocationByOrder == null)
                listProjectLocationByOrder = new List<Project_Location__c>();
            listProjectLocationByOrder.add(newProjectLocation);
            context.mapProjectIdListProjectLocation.put(projectId, listProjectLocationByOrder);
        }
    }
     
    private static void createProjectLocation(OrderAssociationDataContext context, Order order, Id projectId, String contactType, Set<String> setState)
    {
        Id contactId = (contactType.equals('Install At Contact')) ? order.Install_At_Contact__c : order.ShipToContactId;
        Contact contact = context.mapContact.get(contactId);
        
        List<Schema.Location> listLocations = new List<Schema.Location>();

        Boolean hasList = context.mapAccountIdListLocation != null;
        Boolean hasLocationByAccountId = context.mapAccountIdListLocation.get(order.accountId) != null;
        if(hasList && hasLocationByAccountId)
            listLocations = context.mapAccountIdListLocation.get(order.accountId);

        List<Project_Location__c> projectLocations = context.mapProjectIdListProjectLocation.get(projectId);

        Project_Location__c installAtObjLocation = projectLocationAddressTypeExists(projectLocations, order.Id, 'Install At Contact');
        Boolean defaultAddress = (((contactType.equals('Shipping')) && (installAtObjLocation != null)) ? false : true);

        if(contactType.equals('Install At Contact') == true)
        {
            Project_Location__c shippingObjLocation = projectLocationAddressTypeExists(projectLocations, order.Id, 'Shipping');

            if(shippingObjLocation != null)
                context.saveProjectLocation.add(updateShippingLocation(shippingObjLocation));
        }

        Schema.Location objLocation = getExistingLocations(context, contact.MailingStreet, contact.MailingPostalCode, listLocations);
        if(objLocation != null) 
        {
            if(!projectLocationExists(projectLocations, objLocation.Id, contactType)) 
            {
                Project_Location__c newProjectLocation = createProjectLocationObject(contact, objLocation, order.Id, projectId, contactType, defaultAddress);
                context.saveProjectLocation.add(newProjectLocation);
    
                if(projectLocations == null)
                    projectLocations = new List<Project_Location__c>();
                projectLocations.add(newProjectLocation);
                context.mapProjectIdListProjectLocation.put(projectId, projectLocations);
            }
        }
        else 
        {
            Boolean isValidState = (setState != null && contact.Mailing_State__c != null) ? setState.contains(contact.Mailing_State__c.toLowerCase()) : false;

            Schema.Location location = context.mapContactIdLocation.get(contactId);
            Schema.Address address = createAddressObject(contact, location, isValidState);
            context.saveAddress.add(address);

            List<Schema.Address> listAddress = context.mapLocationIdListAddress.get(location.Id);
            if(listAddress == null)
                listAddress = new List<Schema.Address>();
            listAddress.add(address);
            context.mapLocationIdListAddress.put(location.Id, listAddress);

            Project_Location__c newProjectLocation = createProjectLocationObject(contact, location, order.Id, projectId, contactType, defaultAddress);
            context.saveProjectLocation.add(newProjectLocation);

            List<Project_Location__c> listProjectLocationByOrder = context.mapProjectIdListProjectLocation.get(projectId);

            if(listProjectLocationByOrder == null)
                listProjectLocationByOrder = new List<Project_Location__c>();
            listProjectLocationByOrder.add(newProjectLocation);
            context.mapProjectIdListProjectLocation.put(projectId, listProjectLocationByOrder);
        }
    }
 @TestVisible
    private static Schema.Address createAddressObject(Contact contact, Schema.Location location, Boolean isValidState)
    {
        Schema.Address address = new Schema.Address();
        address.Street = contact.MailingStreet;
        address.City = contact.MailingCity;
        address.Country = contact.MailingCountry;
        address.PostalCode = contact.MailingPostalCode;
        address.ParentId = location.Id;
        address.Primary_Address__c = true;
        address.State = (isValidState == true && contact.MailingCountry != null) ? contact.Mailing_State__c : '';
        return address;
    }
    private static Schema.Address createAddressObjectWithOrder(Order order, Schema.Location location, Boolean isValidState)
    {
        Schema.Address address = new Schema.Address();
        address.Street = order.ShippingStreet;
        address.City = order.ShippingCity;
        address.Country = order.ShippingCountry;
        address.PostalCode = order.ShippingPostalCode;
        address.ParentId = location.Id;
        address.Primary_Address__c = true;
        address.State = (isValidState == true && order.ShippingCountry != null) ? order.ShippingState : '';
        return address;
    }
 @TestVisible
    private static Project_Location__c createProjectLocationObject(Contact contact, Schema.Location location, Id orderId, Id projectId, String contactType, Boolean defaultAddress)
    {
        Project_Location__c projectLocation = new Project_Location__c();
        projectLocation.Address_Type__c = contactType;
        projectLocation.Location__c = location.Id;
        projectLocation.Project__c = projectId;
        projectLocation.Name = (location.Name != null) ? location.Name.Abbreviate(80) : '-';
        projectLocation.Order__c = orderId;
        projectLocation.Default_Address__c = defaultAddress;

        return projectLocation;
    }
    private static Project_Location__c createProjectLocationObjectForAccount( Schema.Location location, Id orderId, Id projectId, Boolean defaultAddress)
    {
        Project_Location__c projectLocation = new Project_Location__c();
        projectLocation.Address_Type__c = 'Shipping';
        projectLocation.Location__c = location.Id;
        projectLocation.Project__c = projectId;
        projectLocation.Name = (location.Name != null) ? location.Name.Abbreviate(80) : '-';
        projectLocation.Order__c = orderId;
        //projectLocation.Default_Address__c = true;
        projectLocation.Default_Address__c = true;

        return projectLocation;
    }

   /* private static Schema.Contact_Address__c creteContactAddress(Contact contact, Schema.Address address)
    {
        Schema.Contact_Address__c contactAddress = new Schema.Contact_Address__c();
        contactAddress.Contact__c = contact.Id;
        contactAddress.CountryCode__c = '';
        contactAddress.StateCode__c = '';

        return contactAddress;
    }*/

    private static Schema.Location getExistingLocations(OrderAssociationDataContext context, String street, String postalCode, List<Schema.Location> listLocation) 
    {
        for(Schema.Location forLocation: listLocation) 
        {
            List<Schema.Address> listAddress = context.mapLocationIdListAddress.get(forLocation.Id);
            if(listAddress != null && !listAddress.isEmpty())
            {
                for(Schema.Address forAddress: listAddress)
                {
                    if(forAddress.Street == street && forAddress.PostalCode == postalCode) 
                    {
                        return forLocation;
                    }
                }
            }
        }

        return null;
    }
 @TestVisible
    private static Boolean projectLocationExists(List<Project_Location__c> projectLocations, Id locationId, String addressType) 
    {
        if(projectLocations != null && !projectLocations.isEmpty())
        {
            for(Project_Location__c projectLocation: projectLocations) 
            {
                if(projectLocation.Location__c == locationId && projectLocation.Address_Type__c == addressType) 
                {
                    return true;
                }
            }
        }

        return false;
    }
    
     @TestVisible
    private static Boolean projectLocationExistsForAcccount(List<Project_Location__c> projectLocations, Id locationId) 
    {
        if(projectLocations != null && !projectLocations.isEmpty())
        {
            for(Project_Location__c projectLocation: projectLocations) 
            {
                if(projectLocation.Location__c == locationId) 
                {
                    return true;
                }
            }
        }

        return false;
    }

    private static Project_Location__c projectLocationAddressTypeExists(List<Project_Location__c> projectLocations, Id orderId, String addressType) 
    {
        if(projectLocations != null && !projectLocations.isEmpty())
        {
            for(Project_Location__c projectLocation: projectLocations) 
            {
                if(projectLocation.Address_Type__c == addressType && orderId == projectLocation.Order__c) 
                {
                    return projectLocation;
                }
            }
        }

        return null;
    }

    public static void populateSchemaLocation(Map<Id, List<Schema.Location>> mapAccountIdListLocation, Map<Id, List<Schema.Address>> mapLocationIdListAddress, List<Schema.Location> listLocation) 
    {                     
        Set<Id> setLocationId = new Set<Id>();

        // Populate a map with a list of schema locations for a account id
        for(Schema.Location forLocation: listLocation)
        {
            setLocationId.add(forLocation.Id);

            List<Schema.Location> listLocationByAccount = mapAccountIdListLocation.get(forLocation.Account__c);
            if(listLocationByAccount == null)
                listLocationByAccount = new List<Schema.Location>();

            listLocationByAccount.add(forLocation);
            mapAccountIdListLocation.put(forLocation.Account__c, listLocationByAccount);
        }

        List<Schema.Address> listAddress = DAL_Address.getListAddressBySetParentId(setLocationId);

        // Populate a map with schema addresses for a location id
        for(Schema.Address forAddress: listAddress)
        {
            List<Schema.Address> forListAddress = mapLocationIdListAddress.get(forAddress.ParentId);

            if(forListAddress == null)
                forListAddress = new List<Schema.Address>();

            forListAddress.add(forAddress);
            mapLocationIdListAddress.put(forAddress.ParentId, forListAddress);
        }
    }

    public static void populateProjectLocation(Map<Id, List<Project_Location__c>> mapProjectIdListProjectLocation, List<Project_Location__c> listProjectLocation) 
    {
        // Populate a map with project locations for a project id 
        for(Project_Location__c forProjectLocation: listProjectLocation)
        {
            List<Project_Location__c> forListProjectLocation = mapProjectIdListProjectLocation.get(forProjectLocation.Project__c);

            if(forListProjectLocation == null)
                forListProjectLocation = new List<Project_Location__c>();

            forListProjectLocation.add(forProjectLocation);
            mapProjectIdListProjectLocation.put(forProjectLocation.Project__c, forListProjectLocation);
        }
    }
}