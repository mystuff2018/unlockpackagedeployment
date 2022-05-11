@isTest class SiteManagerTest {
    // @isTest static void CreateAndAssociateOrderSites_Should_CreateSites() {
        // Account account = new Account(Name = 'Test account');
        
        // insert(account);
        
        // List<Contact> contacts = new List<Contact>();
        
        // Contact soldToContact = new Contact(
            // FirstName = 'Sold To',
            // LastName = 'Test',
            // Email = 'test@test.com',
            // MailingStreet = 'Av Ipiranga, 6800',
            // MailingPostalCode = '90123-000',
            // MailingCountry = 'Brazil',
            // MailingCity = 'Porto Alegre',
            // MailingState = 'Rio Grande do Sul',
            // Account_Id__c = account.Id
        // );
        
        // contacts.add(soldToContact);
        
        // Contact shipToContact = new Contact(
            // FirstName = 'Ship To',
            // LastName = 'Test',
            // Email = 'test@test.com',
            // MailingStreet = 'Av Ipiranga, 6800',
            // MailingPostalCode = '90123-000',
            // MailingCountry = 'Brazil',
            // MailingCity = 'Porto Alegre',
            // MailingState = 'Rio Grande do Sul',
            // Account_Id__c = account.Id
        // );
        
        // contacts.add(shipToContact);
        
        // Contact billToContact = new Contact(
            // FirstName = 'Bill To',
            // LastName = 'Test',
            // Email = 'test@test.com',
            // MailingStreet = 'Av Ipiranga, 6802',
            // MailingPostalCode = '90123-002',
            // MailingCountry = 'Brazil',
            // MailingCity = 'Porto Alegre',
            // MailingState = 'Rio Grande do Sul',
            // Account_Id__c = account.Id
        // );
        
        // contacts.add(billToContact);
        
        // Contact directContact = new Contact(
            // FirstName = 'Direct',
            // LastName = 'Test',
            // Email = 'test@test.com',
            // MailingStreet = 'Av Ipiranga, 6803',
            // MailingPostalCode = '90123-003',
            // MailingCountry = 'Brazil',
            // MailingCity = 'Porto Alegre',
            // MailingState = 'Rio Grande do Sul',
            // Account_Id__c = account.Id
        // );
        
        // contacts.add(directContact);
        
        // Contact installAtContact = new Contact(
            // FirstName = 'InstallAt',
            // LastName = 'Test',
            // Email = 'test@test.com',
            // MailingStreet = 'Av Ipiranga, 6803',
            // MailingPostalCode = '90123-003',
            // MailingCountry = 'Brazil',
            // MailingCity = 'Porto Alegre',
            // MailingState = 'Rio Grande do Sul',
            // Account_Id__c = account.Id
        // );
        // Contact installAtContact2 = new Contact(
            // FirstName = 'Install At Contact',
            // LastName = 'Test',
            // Email = 'test@test.com',
            // MailingStreet = 'Install At Contacta, 6803',
            // MailingPostalCode = '90123-003',
            // MailingCountry = 'Brazil',
            // MailingCity = 'Porto Alegre',
            // MailingState = 'Rio Grande do Sul',
            // Account_Id__c = account.Id
        // );
        
        // contacts.add(installAtContact);
        // contacts.add(installAtContact2);
        
        // insert contacts;
        
        // Order order = new Order(
            // Sold_to_Contact__c = soldToContact.Id,
            // ShipToContactId = shipToContact.Id,
            // BillToContactId = billToContact.Id,
            // Direct_Contact__c = directContact.Id,
            // AccountId = account.Id,
            // BUID__c = '11',
            // Install_At_Contact__c = installAtContact.Id,
            // EffectiveDate = Date.today(),
            // Status = 'BK',
            // OrderNumber__c = '112233'
        // );
        
        // insert(order);
        
        // Test.startTest();
        
        // SiteManager.CreateAndAssociateOrderSites(new List<Id>{
            // order.Id
                // });
        
        // Test.stopTest();
        
        // List<Schema.Location> lLoc = [SELECT Id, Name, (SELECT Address, LocationType, PostalCode, Street FROM Addresses) FROM Location];
        
        // system.debug('lLoc.size(): ' + lLoc.size());
        // system.debug('lLoc: ' + lLoc);
        
        // List<Project_Location__c> lProjLoc = [SELECT Id, Location__c, Address_Type__c FROM Project_Location__c];
        // system.debug('lProjLoc.size(): ' + lProjLoc.size()); 
        // system.debug('lProjLoc: ' + lProjLoc);  
        
        // SiteManager.ProjectLocationExists(lProjLoc, lProjLoc[0].Location__c, lProjLoc[0].Address_Type__c);
        // SiteManager.ProjectLocationExists(lProjLoc, installAtContact.Id, lProjLoc[0].Address_Type__c);
        // SiteManager.CreateAndAssociateLocation(order.Id, order.accountId, order.Project__c, order.Install_At_Contact__c, 'Install At Contact');
        // SiteManager.CreateAndAssociateLocation(order.Id, order.accountId, order.Project__c, order.Install_At_Contact__c, 'Shipping');
        
        // DELETE lProjLoc;
        // DELETE lLoc;
        // SiteManager.CreateAndAssociateLocation(order.Id, order.accountId, order.Project__c, order.Install_At_Contact__c, 'Install At Contact');
        
        // lLoc = [SELECT Id, Name, (SELECT Address, LocationType, PostalCode, Street FROM Addresses) FROM Location];
        // lProjLoc = [SELECT Id, Location__c, Address_Type__c FROM Project_Location__c];
        // DELETE lProjLoc;
        // DELETE lLoc;
        // SiteManager.CreateAndAssociateLocation(order.Id, order.accountId, order.Project__c, order.Install_At_Contact__c, 'Shipping');
    // }
}