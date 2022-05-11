/**
 *   
 *  Date             Developer           Tag           Summary of Changes 
 *  *********************************************************************************************************************
 *  05/09/2019       Orlando Monsalve    OM20190905    Changed the creation of the object Site for the creation of the object
 *                                                     Location (Schema.Location) and the object Address (Schema.Address)
 *  11/09/2019       Orlando Monsalve    OM20190911    Added Validations for the creation of the 'Install at Contact' address 
 *                                                     type and for the 'Shipping' address type
 *  24/09/2019       Orlando Monsalve    OM20190924    Changed the future call from CreateAndAssociateLocation to
 *                                                     sendToAssociation
 *  
 */
public with sharing class SiteManager {
    // // private static Site__c GetExistingSite(String street, String postalCode, List<Site__c> sites) {
    // //     for (Site__c site : sites) {
    // //         if (site.Address_1__c == street && site.Postal_Code__c == postalCode) {
    // //             return site;
    // //         }
    // //     }

    // //     return null;
    // // }

    // private static Schema.Location GetExistingLocations(String street, String postalCode, List<Schema.Location> lstLocations) 
    // {
        // for (Schema.Location objLocation : lstLocations) 
        // {
            // List<Schema.Address> lstAddress = objLocation.Addresses;
            
            // if (lstAddress[0].Street == street && lstAddress[0].PostalCode == postalCode) 
            // {
                // return objLocation;
            // }
        // }

        // return null;
    // }

    // // private static Boolean ProjectSiteExists(List<Project_Site__c> projectSites, Id siteId, String addressType) {
    // //     for (Project_Site__c projectSite : projectSites) {
    // //         if (projectSite.Site__C == siteId && projectSite.Address_Type__c == addressType) {
    // //             return true;
    // //         }
    // //     }

    // //     return false;
    // // }

    // @TestVisible 
    // private static Boolean ProjectLocationExists(List<Project_Location__c> projectLocations, Id locationId, String addressType) 
    // {
        // if (!projectLocations.isEmpty() && projectLocations !=null)
        // {
            // for (Project_Location__c projectLocation : projectLocations) 
            // {
                // if (projectLocation.Location__c == locationId && projectLocation.Address_Type__c == addressType) 
                // {
                    // return true;
                // }
            // }
        // }

        // return false;
    // }

    // private static Project_Location__c ProjectLocationAddressTypeExists(List<Project_Location__c> projectLocations, String OrderId, String addressType) 
    // {
        // if (!projectLocations.isEmpty() && projectLocations !=null)
        // {
            // for (Project_Location__c projectLocation : projectLocations) 
            // {
                // System.debug('OrderId '+OrderId);
                // System.debug('projectLocation.Order__r.Id '+projectLocation.Order__r.Id);
                // if (projectLocation.Address_Type__c == addressType && OrderId == projectLocation.Order__r.Id) 
                // {
                    // return projectLocation;
                // }
            // }
        // }

        // return null;
    // }
    
    // // private static void CreateAndAssociateSite(Id orderId, Id accountId, Id projectId, Id contactId, String contactType) {
    // // @future 
    // @TestVisible 
    // private static void CreateAndAssociateLocation(Id orderId, Id accountId, Id projectId, Id contactId, String contactType) 
    // {
        // Contact contact = [SELECT MailingStreet,
                                  // MailingPostalCode,
                                  // MailingCountry,
                                  // MailingCity,
                       		      // MailingState,
                       		      // Mailing_State__c
                             // FROM Contact
                            // WHERE Id = :contactId];
        
        // List<Schema.Location> dellLocations = [SELECT Id,
                                                // Name,
                                                // (SELECT Address,
                                                        // LocationType,
                                                        // PostalCode,
                                                        // Street
                                                // FROM Addresses)
                                        // FROM Location
                                        // WHERE Account__c =: accountId];
        // system.debug('dellLocations.size(): ' + dellLocations.size());
        // system.debug('dellLocations: ' + dellLocations);
        
        // List<Project_Location__c> projectLocations = [SELECT Id, Location__c, Address_Type__c, Default_Address__c, Order__c, Order__r.Id, Name FROM Project_Location__c WHERE Project__c =:projectId];
        // System.debug('projectLocations '+ projectLocations);

        // if(contactType.equalsIgnoreCase('Install At Contact') )
        // {
            // Project_Location__c shippingObjLocation = ProjectLocationAddressTypeExists(projectLocations, orderId, 'Shipping');
            // System.debug('shippingObjLocation '+shippingObjLocation);
            // if( shippingObjLocation != null)
            // {
                // shippingObjLocation.Default_Address__c = false;
                // update shippingObjLocation;
            // }
            
            // Schema.Location objLocation = GetExistingLocations(contact.MailingStreet, contact.MailingPostalCode, dellLocations);

            // if (objLocation != null) 
            // {
                // if (!ProjectLocationExists(projectLocations, objLocation.Id, contactType)) 
                // {
                    // System.debug('---------Existe-------- ' + contactType);
                    // Project_Location__c projectLocation = new Project_Location__c (
                        // Address_Type__c = contactType,
                        // Location__c = objLocation.Id,
                        // Project__c = projectId,
                        // Name = objLocation.Name,
                        // Order__c = orderId,
                        // Default_Address__c = true
                    // );
                    // insert projectLocation;
                // }
            // }
            // else 
            // {
                // System.debug('---------No Existe-------- ' + contactType);
                // Schema.Location objNewLocation = new Schema.Location ();
                // objNewLocation.Account__c = accountId;
                // objNewLocation.Status__c = 'Active';

                // if (contact.MailingCity != null){
                    // objNewLocation.Name = contact.MailingStreet.left(39)+'_'+contact.MailingCity;
                // }
                // else{
                    // objNewLocation.Name = contact.MailingStreet.left(80);
                // }

                // insert objNewLocation;

                // Schema.Address objNewAddress = new Schema.Address();
                // objNewAddress.Street = contact.MailingStreet;
                // objNewAddress.City = contact.MailingCity;
                // objNewAddress.Country = contact.MailingCountry;
                // objNewAddress.PostalCode = contact.MailingPostalCode;
                // objNewAddress.State = contact.Mailing_State__c;
                // objNewAddress.ParentId = objNewLocation.Id;
                // objNewAddress.Primary_Address__c = true;

                // insert objNewAddress;
                // Project_Location__c projectLocation = new Project_Location__c (
                    // Address_Type__c = contactType,
                    // Location__c = objNewLocation.Id,
                    // Project__c = projectId,
                    // Name = objNewLocation.Name,
                    // Order__c = orderId,
                    // Default_Address__c = true
                // );
                
                // insert projectLocation;
            // }
        // }
        // else if(contactType.equalsIgnoreCase('Shipping'))
        // {
            // Project_Location__c installAtObjLocation = ProjectLocationAddressTypeExists(projectLocations, orderId, 'Install At Contact');
            // System.debug('installAtObjLocation '+installAtObjLocation);
            // if( installAtObjLocation == null)
            // {
                // Schema.Location objLocation = GetExistingLocations(contact.MailingStreet, contact.MailingPostalCode, dellLocations);

                // if (objLocation != null) 
                // {
                    // if (!ProjectLocationExists(projectLocations, objLocation.Id, contactType)) 
                    // {
                        // System.debug('---------Existe-------- ' + contactType);
                        // Project_Location__c projectLocation = new Project_Location__c (
                            // Address_Type__c = contactType,
                            // Location__c = objLocation.Id,
                            // Project__c = projectId,
                            // Name = objLocation.Name,
                            // Order__c = orderId,
                            // Default_Address__c = true
                        // );
                        // insert projectLocation;
                    // }
                // }
                // else 
                // {
                    // System.debug('---------No Existe-------- ' + contactType);
                    // Schema.Location objNewLocation = new Schema.Location ();
                    // objNewLocation.Account__c = accountId;
                    // objNewLocation.Status__c = 'Active';

                    // if (contact.MailingCity != null){
                        // objNewLocation.Name = contact.MailingStreet.left(39)+'_'+contact.MailingCity;
                    // }
                    // else{
                        // objNewLocation.Name = contact.MailingStreet.left(80);
                    // }

                    // insert objNewLocation;

                    // Schema.Address objNewAddress = new Schema.Address();
                    // objNewAddress.Street = contact.MailingStreet;
                    // objNewAddress.City = contact.MailingCity;
                    // objNewAddress.Country = contact.MailingCountry;
                    // objNewAddress.PostalCode = contact.MailingPostalCode;
                    // objNewAddress.State = contact.Mailing_State__c;
                    // objNewAddress.ParentId = objNewLocation.Id;
                    // objNewAddress.Primary_Address__c = true;

                    // insert objNewAddress;
                    // Project_Location__c projectLocation = new Project_Location__c (
                        // Address_Type__c = contactType,
                        // Location__c = objNewLocation.Id,
                        // Project__c = projectId,
                        // Name = objNewLocation.Name,
                        // Order__c = orderId,
                        // Default_Address__c = true
                    // );
                    
                    // insert projectLocation;
                // }
            // }
            // if(installAtObjLocation != null || Test.isRunningTest())
            // {
                // Schema.Location objLocation = GetExistingLocations(contact.MailingStreet, contact.MailingPostalCode, dellLocations);

                // if (objLocation != null) 
                // {
                    // if (!ProjectLocationExists(projectLocations, objLocation.Id, contactType)) 
                    // {
                        // System.debug('---------Existe-------- ' + contactType);
                        // Project_Location__c projectLocation = new Project_Location__c (
                            // Address_Type__c = contactType,
                            // Location__c = objLocation.Id,
                            // Project__c = projectId,
                            // Order__c = orderId,
                            // Name = objLocation.Name,
                            // Default_Address__c = false
                        // );
                        // insert projectLocation;
                    // }
                // }
                // else 
                // {
                    // System.debug('---------No Existe-------- ' + contactType);
                    // Schema.Location objNewLocation = new Schema.Location ();
                    // objNewLocation.Account__c = accountId;
                    // objNewLocation.Status__c = 'Active';

                    // if (contact.MailingCity != null){
                        // objNewLocation.Name = contact.MailingStreet.left(39)+'_'+contact.MailingCity;
                    // }
                    // else{
                        // objNewLocation.Name = contact.MailingStreet.left(80);
                    // }

                    // insert objNewLocation;

                    // Schema.Address objNewAddress = new Schema.Address();
                    // objNewAddress.Street = contact.MailingStreet;
                    // objNewAddress.City = contact.MailingCity;
                    // objNewAddress.Country = contact.MailingCountry;
                    // objNewAddress.PostalCode = contact.MailingPostalCode;
                    // objNewAddress.State = contact.Mailing_State__c;
                    // objNewAddress.ParentId = objNewLocation.Id;
                    // objNewAddress.Primary_Address__c = true;

                    // insert objNewAddress;
                    // Project_Location__c projectLocation = new Project_Location__c (
                        // Address_Type__c = contactType,
                        // Location__c = objNewLocation.Id,
                        // Project__c = projectId,
                        // Order__c = orderId,
                        // Name = objNewLocation.Name,
                        // Default_Address__c = false
                    // );
                    
                    // insert projectLocation;
                // }
            // }
        // }
        // /*else 
        // {
            // // List<Site__c> dellSites = [SELECT Address_1__c, 
            // //                                        Postal_Code__c,
            // //                                 	   Name
            // //                                   FROM site__c 
            // //                                  WHERE Account__c = :accountId];



            // // List<Project_Site__c> projectSites = [SELECT Site__C, Address_Type__c FROM Project_Site__c WHERE Project__c = :projectId];

            // // Site__c site = GetExistingSite(contact.MailingStreet, contact.MailingPostalCode, dellSites);
            // Schema.Location objLocation = GetExistingLocations(contact.MailingStreet, contact.MailingPostalCode, dellLocations);

            // if (objLocation != null) 
            // {
                // if (!ProjectLocationExists(projectLocations, objLocation.Id, contactType)) {
                // System.debug('---------Existe-------- ' + contactType);
                // // Project_Site__c projectSite = new Project_Site__c (
                // Project_Location__c projectLocation = new Project_Location__c (
                    // Address_Type__c = contactType,
                    // // Site__c = site.Id,
                    // Location__c = objLocation.Id,
                    // Project__c = projectId,
                    // Order__c = orderId,
                    // // Name = site.Name
                    // Name = objLocation.Name,
                    // Default_Address__c = false
                // );
                // // insert projectSite;
                // insert projectLocation;
                // }
            // }
            // else 
            // {
                // System.debug('---------No Existe-------- ' + contactType);
                // // Site__c newSite = new Site__C (
                // //     Address_1__c = contact.MailingStreet,
                // //     City__c = contact.MailingCity,
                // //     Country__c = contact.MailingCountry,
                // //     Postal_Code__c = contact.MailingPostalCode,
                // //     State__c =  contact.Mailing_State__c,
                // //     Status__c = 'Active',
                // //     Account__c = accountId
                // // );

                // Schema.Location objNewLocation = new Schema.Location ();
                // objNewLocation.Account__c = accountId;
                // objNewLocation.Status__c = 'Active';

                // if (contact.MailingCity != null){
                    // objNewLocation.Name = contact.MailingStreet+'_'+contact.MailingCity;
                // }
                // else{
                    // objNewLocation.Name = contact.MailingStreet;
                // }

                // insert objNewLocation;

                // Schema.Address objNewAddress = new Schema.Address();
                // // objNewAddress.Address = contact.MailingStreet;
                // objNewAddress.Street = contact.MailingStreet;
                // objNewAddress.City = contact.MailingCity;
                // objNewAddress.Country = contact.MailingCountry;
                // objNewAddress.PostalCode = contact.MailingPostalCode;
                // objNewAddress.State = contact.Mailing_State__c;
                // objNewAddress.ParentId = objNewLocation.Id;
                // objNewAddress.Primary_Address__c = true;

                // insert objNewAddress;
                // // if (contact.MailingCity != null){
                // //     newSite.Name = contact.Mailing_State__c+'_'+contact.MailingCity;
                // // }
                // // else{
                // //     newSite.Name = contact.Mailing_State__c;
                // // }
                // // if (String.isNotBlank(newSite.Name)) {
                // //     newSite.Name += ' Site';
                // // }
                // // insert newSite;
                // // Project_Site__c projectSite = new Project_Site__c (
                // Project_Location__c projectLocation = new Project_Location__c (
                    // Address_Type__c = contactType,
                    // Location__c = objNewLocation.Id,
                    // Project__c = projectId,
                    // Order__c = orderId,
                    // Name = objNewLocation.Name,
                    // Default_Address__c = false
                // );
                
                // insert projectLocation;
            // }
        // }*/
    // }

    // // @future
    // private static void sendToAssociation (String strSerializedOrder)
    // {
        // Map<String, Order> mpStrXOrder = (Map<String, Order>) JSON.deserialize(strSerializedOrder.unescapeHtml4(), Map<String, Order>.Class);
        // Order objOrder = mpStrXOrder.get('Order');
        // //  if (objOrder.Sold_to_Contact__c != null) {
        // //     System.debug('Sold to');
        // //     CreateAndAssociateLocation(objOrder.Id, objOrder.accountId, objOrder.Project__c, objOrder.Sold_to_Contact__c, 'Sold to');
        // // }
        
        // if (objOrder.ShipToContactId != null) {
            // System.debug('Shipping');
            // CreateAndAssociateLocation(objOrder.Id, objOrder.accountId, objOrder.Project__c, objOrder.ShipToContactId, 'Shipping');
        // }
        
        // // if (objOrder.BillToContactId != null) {
        // //     System.debug('Billing -- CONTACT ID');
        // //     CreateAndAssociateLocation(objOrder.Id, objOrder.accountId, objOrder.Project__c, objOrder.BillToContactId, 'Billing');
        // // }
        
        // // if (objOrder.Direct_Contact__c != null) {
        // //     System.debug('Billing -- DIRECT CONTACT');
        // //     CreateAndAssociateLocation(objOrder.Id, objOrder.accountId, objOrder.Project__c, objOrder.Direct_Contact__c, 'Direct');
        // // }
        // if (objOrder.Install_At_Contact__c != null) {
            // System.debug('Install At Contact');
            // CreateAndAssociateLocation(objOrder.Id, objOrder.accountId, objOrder.Project__c, objOrder.Install_At_Contact__c, 'Install At Contact');
        // }
    // } 

    // @InvocableMethod(label = 'Create and associate Sites to Order Account and Order Project')
    // public static void CreateAndAssociateOrderSites(List<Id> orderIds) {
        // List<Order> orders = [SELECT Sold_to_Contact__c,
                              		 // ShipToContactId,
                              		 // BillToContactId,
                              		 // Direct_Contact__c,
                                    // Install_At_Account__c,
                                    // Install_At_Contact__c,
                              		 // AccountId,
                              		 // Project__c,
                                       // Id
                         	    // FROM Order 
                        	   // WHERE Id IN :orderIds];
         
        // for (Order order : orders) {

            // Map<String, Order> mpStrXOrder = new Map<String, Order>();
            // mpStrXOrder.put('Order', order);

            // String strSerializedOrder = JSON.serialize(mpStrXOrder);
            // Boolean boolContext = System.isFuture();
            // if(!boolContext)
            // {
                // sendToAssociation(strSerializedOrder);
            // }

            // // if (order.Sold_to_Contact__c != null) {
            // //     CreateAndAssociateLocation(order.Id, order.accountId, order.Project__c, order.Sold_to_Contact__c, 'Sold to');
            // // }
            
            // // if (order.ShipToContactId != null) {
            // //     CreateAndAssociateLocation(order.Id, order.accountId, order.Project__c, order.ShipToContactId, 'Shipping');
            // // }
            
            // // if (order.BillToContactId != null) {
            // //     CreateAndAssociateLocation(order.Id, order.accountId, order.Project__c, order.BillToContactId, 'Billing');
            // // }
            
            // // if (order.Direct_Contact__c != null) {
            // //     CreateAndAssociateLocation(order.Id, order.accountId, order.Project__c, order.Direct_Contact__c, 'Billing');
            // // }
            // // if (order.Install_At_Contact__c != null) {
            // //     CreateAndAssociateLocation(order.Id, order.accountId, order.Project__c, order.Install_At_Contact__c, 'Install At Contact');
            // // }
        // }
    // }
    // //LocationName = “MailingStreet” + “_” + “MailingCity”

}