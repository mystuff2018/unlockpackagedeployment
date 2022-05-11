/*
 * @class OrderAssociationProjectLocation
 * @authors Pablo Dunke
 * @date 02/17/2020
 * @Modification Log: [Deloitte - Abhishek Kawle] : Updated Script to set Project Locations based on Order > Address fields.
 */

@IsTest
private class OrderAssociationProjectLocationTest 
{
     @IsTest
    static void testWithOrderAndProject() 
    {
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            // Create the data
            pse__Proj__c project = OPRTestFactory.createProject();
            
            
            Contact installAt = OPRTestFactory.createSimpleContact();
            installAt.MailingPostalCode = '10800';
            installAt.MailingStreet = '2nd Street';
            installAt.MailingCity = 'Los Angeles';
            installAt.Mailing_State__c = 'California';
            installAt.MailingCountry = 'United States';
            installAt.Phone = '2367895624';
            update installAt;
            
            Contact shipTo = OPRTestFactory.createSimpleContact();
            shipTo.MailingPostalCode = '18730';
            shipTo.MailingStreet = '3rd Street';
            shipTo.MailingCity = 'Dallas';
            shipTo.Mailing_State__c = 'Texas';
            shipTo.MailingCountry = 'United States';
            shipTo.Phone = '2367895624';
            update shipTo;
            
            Order order = OPRTestFactory.createOrderStateCountry(null, null, null, null, 'United States', 'Texas');
            order.Install_At_Contact__c = installAt.Id;
            order.ShipToContactId = shipTo.Id;
            order.Project__c = project.Id;
            
            //Set Shipping and Install-At Address Fields on Order
            order.ShippingPostalCode = '10800';
            order.ShippingStreet = '2nd Street';
            order.ShippingCity = 'Los Angeles';
            order.ShippingState = 'California';
            order.ShippingCountry = 'United States';
            
            order.FBE_Install_At_Postal_Code__c = '18730';
            order.FBE_Install_At_Street__c = '3rd Street';
            order.FBE_Install_At_City__c = 'Dallas';
            order.FBE_Install_At_State__c = 'Alabama';
            order.FBE_Install_At_Country__c = 'United States';
            update order;
            
            OrderItem orderItem = createOrderItem(order.Id);
            
            // Create the event
            Order_Association__e event = new Order_Association__e();
            event.Order_ID__c = order.Id;
            event.Project_ID__c = project.Id;
            event.Order_Item_Id__c = orderItem.Id;
            
            Schema.Location location = new Schema.Location();
            location.Account__c = order.AccountId;
            location.Status__c = 'Active';
            location.Name = order.ShippingState + '_' + order.ShippingCity;
            insert location;
            
            Project_Location__c projectLocation1 = new Project_Location__c();
            projectLocation1.Address_Type__c = 'Install At Contact';
            projectLocation1.Location__c = location.Id;
            projectLocation1.Project__c = order.Project__c;
            projectLocation1.Name = location.Name.Abbreviate(80);
            projectLocation1.Order__c = order.Id;
            projectLocation1.Default_Address__c = true;
            insert projectLocation1;
            
            
            List<Order_Association__e> listEvent = new List<Order_Association__e>();
            listEvent.add(event);
            
            OrderAssociationDataContext context = new OrderAssociationDataContext(listEvent);
            
            // Action
            Test.startTest();
            
            OrderAssociationProjectLocation.createAndAssociateProjectLocation(context);
            upsert context.saveAddress;
            upsert context.saveProjectLocation;
            
            Test.stopTest();
            
            //     // Assertion
            List<Project_Location__c> result = [SELECT Id, Project__c, Order__c, Default_Address__c FROM Project_Location__c WHERE Project__c =: project.Id];
            System.debug('@@82 ' +result);
            System.assertEquals(2, result.size());
            System.assertEquals(1, context.saveProjectLocation.size());
            
            List<Project_Location__c> resultInstallAt = [SELECT Id, Project__c, Address_Type__c, Default_Address__c FROM Project_Location__c WHERE Project__c =: project.Id AND Address_Type__c = 'Install At Contact'];
            System.debug('@@87 ' +resultInstallAt);
            System.assertEquals(1, resultInstallAt.size());
            
            List<Project_Location__c> resultShipping = [SELECT Id, Project__c, Address_Type__c, Default_Address__c FROM Project_Location__c WHERE Project__c =: project.Id AND Address_Type__c = 'Shipping'];
            System.debug('@@91 ' +resultShipping);
            System.assertEquals(1, resultShipping.size());
            
            System.assertEquals(true, resultShipping.get(0).Default_Address__c);
            System.assertEquals(true, resultInstallAt.get(0).Default_Address__c);
        }
    }

    @IsTest
    static void testWithShipToOnly() 
    {
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            // Create the data
            pse__Proj__c project = OPRTestFactory.createProject();
            
            Contact shipTo = OPRTestFactory.createSimpleContact();
            shipTo.MailingPostalCode = '18730';
            shipTo.MailingStreet = '3rd Street';
            shipTo.MailingCity = 'Dallas';
            shipTo.Mailing_State__c = 'Texas';
            shipTo.MailingCountry = 'United States';
            update shipTo;
            
            Order order = OPRTestFactory.createOrderStateCountry(null, null, null, null, 'United States', 'Texas');
            //order.Install_At_Contact__c = null;
            order.ShipToContactId = shipTo.Id;
            order.Project__c = project.Id;
            
            //Set Shipping Address Fields on Order
            order.ShippingPostalCode = '18730';
            order.ShippingStreet = '3rd Street';
            order.ShippingCity = 'Dallas';
            order.ShippingState = 'Texas';
            order.ShippingCountry = 'United States';
            update order;
            
            OrderItem orderItem = createOrderItem(order.Id);
            
            // Create the event
            Order_Association__e event = new Order_Association__e();
            event.Order_ID__c = order.Id;
            event.Project_ID__c = project.Id;
            event.Order_Item_Id__c = orderItem.Id;
            
            List<Order_Association__e> listEvent = new List<Order_Association__e>();
            listEvent.add(event);
            
            OrderAssociationDataContext context = new OrderAssociationDataContext(listEvent);
            
            // Action
            Test.startTest();
            
            OrderAssociationProjectLocation.createAndAssociateProjectLocation(context);
            upsert context.saveAddress;
            upsert context.saveProjectLocation;
            
            Test.stopTest();
            
            // Assertion
            List<Project_Location__c> resultShipping = [SELECT Id, Project__c, Address_Type__c, Default_Address__c FROM Project_Location__c WHERE Project__c =: project.Id AND Address_Type__c = 'Shipping'];
            System.assertEquals(1, resultShipping.size());
            System.assertEquals(true, resultShipping.get(0).Default_Address__c);
        }
    }

     /*@IsTest
     static void testWithInstallAtOnly() 
     {
         // Create the data
         pse__Proj__c project = OPRTestFactory.createProject();

         Contact installAt = OPRTestFactory.createSimpleContact();
         installAt.MailingPostalCode = '10800';
         installAt.MailingStreet = '2nd Street';
         installAt.MailingCity = 'Los Angeles';
         installAt.Mailing_State__c = 'California';
         installAt.MailingCountry = 'United States';
         update installAt;

         Order order = OPRTestFactory.createOrderStateCountry(null, null, null, null, 'United States', 'Texas');
         order.Install_At_Contact__c = installAt.Id;
         //order.ShipToContactId = null;
         order.Project__c = project.Id;
         
         order.FBE_Install_At_Postal_Code__c = '18730';
         order.FBE_Install_At_Street__c = '3rd Street';
         order.FBE_Install_At_City__c = 'Dallas';
         order.FBE_Install_At_State__c = 'Alabama';
         order.FBE_Install_At_Country__c = 'United States';
         update order;
        
         OrderItem orderItem = createOrderItem(order.Id);

         // Create the event
         Order_Association__e event = new Order_Association__e();
        event.Order_ID__c = order.Id;
        event.Project_ID__c = project.Id;
         event.Order_Item_Id__c = orderItem.Id;
        
         List<Order_Association__e> listEvent = new List<Order_Association__e>();
         listEvent.add(event);

         OrderAssociationDataContext context = new OrderAssociationDataContext(listEvent);

         // Action
         Test.startTest();

         OrderAssociationProjectLocation.createAndAssociateProjectLocation(context);
         upsert context.saveAddress;
         upsert context.saveProjectLocation;

         Test.stopTest();

         // Assertion
         List<Project_Location__c> resultInstallAt = [SELECT Id, Project__c, Address_Type__c, Default_Address__c FROM Project_Location__c WHERE Project__c =: project.Id AND Address_Type__c = 'Install At Contact'];
         System.assertEquals(1, resultInstallAt.size());
         System.assertEquals(true, resultInstallAt.get(0).Default_Address__c);
     } */
    
    @IsTest
    static void testWithOneProjectAndTwoOrders() 
    {
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            // Create the data
            pse__Proj__c project = OPRTestFactory.createProject();
            
            Contact installAt = OPRTestFactory.createSimpleContact();
            installAt.MailingPostalCode = '10800';
            installAt.MailingStreet = '2nd Street';
            installAt.MailingCity = 'Los Angeles';
            installAt.Mailing_State__c = 'California';
            installAt.MailingCountry = 'United States';
            update installAt;
            
            Contact shipTo = OPRTestFactory.createSimpleContact();
            shipTo.MailingPostalCode = '18730';
            shipTo.MailingStreet = '3rd Street';
            shipTo.MailingCity = 'Dallas';
            shipTo.Mailing_State__c = 'Texas';
            shipTo.MailingCountry = 'United States';
            update shipTo;
            
            Order order = OPRTestFactory.createOrderStateCountry(null, null, null, null, 'United States', 'Texas');
            order.Install_At_Contact__c = installAt.Id;
            order.ShipToContactId = shipTo.Id;
            order.Project__c = project.Id;
            
            //Set Shipping and Install-At Address Fields on Order
            order.ShippingPostalCode = '10800';
            order.ShippingStreet = '2nd Street';
            order.ShippingCity = 'Los Angeles';
            order.ShippingState = 'California';
            order.ShippingCountry = 'United States';
            
            order.FBE_Install_At_Postal_Code__c = '18730';
            order.FBE_Install_At_Street__c = '3rd Street';
            order.FBE_Install_At_City__c = 'Dallas';
            order.FBE_Install_At_State__c = 'Alabama';
            order.FBE_Install_At_Country__c = 'United States';
            update order;
            
            OrderItem orderItem = createOrderItem(order.Id);
            
            Order another = new Order();
            another.OrderNumber__c = '987654322';
            another.Project__c = project.Id;
            another.Billing_Country__c = shipTo.MailingCountry;
            another.Billing_State__c = shipTo.Mailing_State__c;
            another.Shipping_Country__c = shipTo.MailingCountry;
            another.Shipping_State__c = shipTo.Mailing_State__c;
            another.BillToContactId = shipTo.Id;
            another.ShipToContactId = shipTo.Id;
            another.Install_At_Contact__c = installAt.Id;
            another.AccountId = order.AccountId;
            another.EffectiveDate = Date.valueOf('2020-02-20');
            another.Pricebook2Id = Test.getStandardPricebookId();
            another.Status = 'BK';
            another.BUID__c = '11';
            //Set Shipping and Install-At Address Fields on Order
            another.ShippingPostalCode = '10800';
            another.ShippingStreet = '2nd Street';
            another.ShippingCity = 'Los Angeles';
            another.ShippingState = 'California';
            another.ShippingCountry = 'United States';
            
            another.FBE_Install_At_Postal_Code__c = '18730';
            another.FBE_Install_At_Street__c = '3rd Street';
            another.FBE_Install_At_City__c = 'Dallas';
            another.FBE_Install_At_State__c = 'AL';
            another.FBE_Install_At_Country__c = 'United States';
            insert another;
            
            OrderItem anotherOrderItem = createOrderItem(another.Id);
            
            // Create the event
            Order_Association__e event = new Order_Association__e();
            event.Order_ID__c = order.Id;
            event.Project_ID__c = project.Id;
            event.Order_Item_Id__c = orderItem.Id;
            
            Order_Association__e event2 = new Order_Association__e();
            event2.Order_ID__c = another.Id;
            event2.Project_ID__c = project.Id;
            event2.Order_Item_Id__c = anotherOrderItem.Id;
            
            List<Order_Association__e> listEvent = new List<Order_Association__e>();
            listEvent.add(event);
            listEvent.add(event2);
            
            OrderAssociationDataContext context = new OrderAssociationDataContext(listEvent);
            
            // Action
            Test.startTest();
            
            OrderAssociationProjectLocation.createAndAssociateProjectLocation(context);
            upsert context.saveAddress;
            upsert context.saveProjectLocation;
            System.debug('@@312 ' +context.saveProjectLocation);
            
            Test.stopTest();
            
            // Assertion
            List<Project_Location__c> result = [SELECT Id, Project__c, Order__c, Default_Address__c FROM Project_Location__c WHERE Project__c =: project.Id];
             System.debug('@@318 ' +result);
            System.assertEquals(1, result.size());
            System.assertEquals(1, context.saveProjectLocation.size());
        }
    }
    
    @IsTest
    static void testWithTwoProjectsAndTwoOrders() 
    {
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            // Create the data
            pse__Proj__c project = OPRTestFactory.createProject();
            
            pse__Proj__c anotherProject = new pse__Proj__c();
            anotherProject.Name = 'Project 2';
            anotherProject.Project_Complexity__c = 'Low';
            anotherProject.pse__Account__c = project.pse__Account__c;
            anotherProject.pse__Is_Active__c = true;
            anotherProject.pse__Practice__c = project.pse__Practice__c;
            anotherProject.pse__Project_Manager__c = project.pse__Project_Manager__c;
            anotherProject.pse__Region__c = project.pse__Region__c;
            anotherProject.pse__Start_Date__c = Date.today();
            insert anotherProject;
            
            Contact installAt = OPRTestFactory.createSimpleContact();
            installAt.MailingPostalCode = '10800';
            installAt.MailingStreet = '2nd Street';
            installAt.MailingCity = 'Los Angeles';
            installAt.Mailing_State__c = 'California';
            installAt.MailingCountry = 'United States';
            update installAt;
            
            Contact shipTo = OPRTestFactory.createSimpleContact();
            shipTo.MailingPostalCode = '18730';
            shipTo.MailingStreet = '3rd Street';
            shipTo.MailingCity = 'Dallas';
            shipTo.Mailing_State__c = 'Texas';
            shipTo.MailingCountry = 'United States';
            update shipTo;
            
            Order order = OPRTestFactory.createOrderStateCountry(null, null, null, null, 'United States', 'Texas');
            order.Install_At_Contact__c = installAt.Id;
            order.ShipToContactId = shipTo.Id;
            order.Project__c = project.Id;
            order.ShippingPostalCode = '10800';
            order.ShippingStreet = '2nd Street';
            order.ShippingCity = 'Los Angeles';
            order.ShippingState = 'California';
            order.ShippingCountry = 'United States';
            
            order.FBE_Install_At_Postal_Code__c = '18730';
            order.FBE_Install_At_Street__c = '3rd Street';
            order.FBE_Install_At_City__c = 'Dallas';
            order.FBE_Install_At_State__c = 'Alabama';
            order.FBE_Install_At_Country__c = 'United States';       
            update order;
            
            OrderItem orderItem = createOrderItem(order.Id);
            
            Account account = OPRTestFactory.newAccount('Test Account', '112');
            insert account;
            
            Order anotherOrder = new Order();
            anotherOrder.OrderNumber__c = '987654322';
            anotherOrder.Project__c = anotherProject.Id;
            anotherOrder.Billing_Country__c = shipTo.MailingCountry;
            anotherOrder.Billing_State__c = shipTo.Mailing_State__c;
            anotherOrder.Shipping_Country__c = shipTo.MailingCountry;
            anotherOrder.Shipping_State__c = shipTo.Mailing_State__c;
            anotherOrder.BillToContactId = shipTo.Id;
            anotherOrder.ShipToContactId = shipTo.Id;
            anotherOrder.Install_At_Contact__c = installAt.Id;
            anotherOrder.AccountId = account.Id;
            anotherOrder.EffectiveDate = Date.valueOf('2020-02-20');
            anotherOrder.Pricebook2Id = Test.getStandardPricebookId();
            anotherOrder.Status = 'BK';
            anotherOrder.BUID__c = '11';
            //Set Shipping and Install-At Address Fields on Order
            anotherOrder.ShippingPostalCode = '10800';
            anotherOrder.ShippingStreet = '2nd Street';
            anotherOrder.ShippingCity = 'Los Angeles';
            anotherOrder.ShippingState = 'California';
            anotherOrder.ShippingCountry = 'United States';
            
            anotherOrder.FBE_Install_At_Postal_Code__c = '18730';
            anotherOrder.FBE_Install_At_Street__c = '3rd Street';
            anotherOrder.FBE_Install_At_City__c = 'Dallas';
            anotherOrder.FBE_Install_At_State__c = 'AL';
            anotherOrder.FBE_Install_At_Country__c = 'United States';
            insert anotherOrder;
            
            OrderItem anotherOrderItem = createOrderItem(anotherOrder.Id);
            
            // Create the event
            Order_Association__e event = new Order_Association__e();
            event.Order_ID__c = order.Id;
            event.Project_ID__c = project.Id;
            event.Order_Item_Id__c = orderItem.Id;
            
            Order_Association__e event2 = new Order_Association__e();
            event2.Order_ID__c = anotherOrder.Id;
            event2.Project_ID__c = anotherProject.Id;
            event2.Order_Item_Id__c = anotherOrderItem.Id;
            
            List<Order_Association__e> listEvent = new List<Order_Association__e>();
            listEvent.add(event);
            listEvent.add(event2);
            
            OrderAssociationDataContext context = new OrderAssociationDataContext(listEvent);
            
            // Action
            Test.startTest();
            
            OrderAssociationProjectLocation.createAndAssociateProjectLocation(context);
            upsert context.saveAddress;
            upsert context.saveProjectLocation;
            
            Test.stopTest();
            
            // Assertion
            System.assertEquals(2, context.saveProjectLocation.size());
            
            List<Project_Location__c> resultFirstProject = [SELECT Id, Project__c, Order__c, Default_Address__c FROM Project_Location__c WHERE Project__c =: project.Id];
            System.debug('@@44 ' +resultFirstProject);
            System.assertEquals(1, resultFirstProject.size());
            
            List<Project_Location__c> resultSecondProject = [SELECT Id, Project__c, Order__c, Default_Address__c FROM Project_Location__c WHERE Project__c =: anotherProject.Id];
            System.assertEquals(1, resultSecondProject.size());
        }
    }
    
    @IsTest
    //Also using the same address for Shipping and Install-At Address
    static void testWithSameContact() 
    {
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            // Create the data
            pse__Proj__c project = OPRTestFactory.createProject();
            
            Contact contact = OPRTestFactory.createSimpleContact();
            contact.MailingPostalCode = '10800';
            contact.MailingStreet = '2nd Street';
            contact.MailingCity = 'Los Angeles';
            contact.Mailing_State__c = 'California';
            contact.MailingCountry = 'United States';
            update contact;
            
            Order order = OPRTestFactory.createOrderStateCountry(null, null, null, null, 'United States', 'Texas');
            order.Install_At_Contact__c = contact.Id;
            order.ShipToContactId = contact.Id;
            order.Project__c = project.Id;
            
            //Set Shipping and Install-At Address Fields on Order
            order.ShippingPostalCode = '10800';
            order.ShippingStreet = '2nd Street';
            order.ShippingCity = 'Los Angeles';
            order.ShippingState = 'California';
            order.ShippingCountry = 'United States';
            
            order.FBE_Install_At_Postal_Code__c = '10800';
            order.FBE_Install_At_Street__c = '2nd Street';
            order.FBE_Install_At_City__c = 'Los Angeles';
            order.FBE_Install_At_State__c = 'California';
            order.FBE_Install_At_Country__c = 'United States';
            update order;
            
            OrderItem orderItem = createOrderItem(order.Id);
            
            // Create the event
            Order_Association__e event = new Order_Association__e();
            event.Order_ID__c = order.Id;
            event.Project_ID__c = project.Id;
            event.Order_Item_Id__c = orderItem.Id;
            
            List<Order_Association__e> listEvent = new List<Order_Association__e>();
            listEvent.add(event);
            
            OrderAssociationDataContext context = new OrderAssociationDataContext(listEvent);
            
            // Action
            Test.startTest();
            
            OrderAssociationProjectLocation.createAndAssociateProjectLocation(context);
            upsert context.saveAddress;
            upsert context.saveProjectLocation;
            
            Test.stopTest();
            
            // Assertion
            System.assertEquals(1, context.saveAddress.size());
            System.assertEquals(1, context.saveProjectLocation.size());
        }
    }
    
    @IsTest
    static void testWithShipToDefaultAddressTrue() 
    {
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            // Create the data
            pse__Proj__c project = OPRTestFactory.createProject();
            
            Contact installAt = OPRTestFactory.createSimpleContact();
            installAt.MailingPostalCode = '10800';
            installAt.MailingStreet = '2nd Street';
            installAt.MailingCity = 'Los Angeles';
            installAt.Mailing_State__c = 'California';
            installAt.MailingCountry = 'United States';
            update installAt;
            
            Contact shipTo = OPRTestFactory.createSimpleContact();
            shipTo.MailingPostalCode = '18730';
            shipTo.MailingStreet = '3rd Street';
            shipTo.MailingCity = 'Dallas';
            shipTo.Mailing_State__c = 'Texas';
            shipTo.MailingCountry = 'United States';
            update shipTo;
            
            Order order = OPRTestFactory.createOrderStateCountry(null, null, null, null, 'United States', 'Texas');
            order.Install_At_Contact__c = installAt.Id;
            order.ShipToContactId = shipTo.Id;
            order.Project__c = project.Id;
            
            order.ShippingPostalCode = '10800';
            order.ShippingStreet = '2nd Street';
            order.ShippingCity = 'Los Angeles';
            order.ShippingState = 'California';
            order.ShippingCountry = 'United States';
            
            order.FBE_Install_At_Postal_Code__c = '18730';
            order.FBE_Install_At_Street__c = '3rd Street';
            order.FBE_Install_At_City__c = 'Dallas';
            order.FBE_Install_At_State__c = 'Texas';
            order.FBE_Install_At_Country__c = 'United States';
            update order;
            
            OrderItem orderItem = createOrderItem(order.Id);
            
            Schema.Location location = new Schema.Location();
            location.Account__c = order.AccountId;
            location.Status__c = 'Active';
            location.Name = order.ShippingState + '_' + order.ShippingCity;
            insert location;
           
            
            Schema.Address address = new Schema.Address();
            address.Street = order.ShippingStreet;
            address.City = order.ShippingCity;
            address.Country = order.ShippingCountry;
            address.PostalCode = order.ShippingPostalCode;
            address.ParentId = location.Id;
            address.Primary_Address__c = true;
            address.State = order.ShippingState;
            insert address;
            
            list<Project_Location__c> projectLocationList = new list<Project_Location__c>();
            Project_Location__c projectLocation = new Project_Location__c();
            projectLocation.Address_Type__c = 'Shipping';
            projectLocation.Location__c = location.Id;
            projectLocation.Project__c = order.Project__c;
            projectLocation.Name = location.Name.Abbreviate(80);
            projectLocation.Order__c = order.Id;
            projectLocation.Default_Address__c = true;
            insert projectLocation;
            projectLocationList.add(projectLocation);
            
            Project_Location__c projectLocation1 = new Project_Location__c();
            projectLocation1.Address_Type__c = 'Install At Contact';
            projectLocation1.Location__c = location.Id;
            projectLocation1.Project__c = order.Project__c;
            projectLocation1.Name = location.Name.Abbreviate(80);
            projectLocation1.Order__c = order.Id;
            projectLocation1.Default_Address__c = true;
            insert projectLocation1;
            projectLocationList.add(projectLocation1);
            
            
            // Create the event
            Order_Association__e event = new Order_Association__e();
            event.Order_ID__c = order.Id;
            event.Project_ID__c = project.Id;
            event.Order_Item_Id__c = orderItem.Id;
            
            List<Order_Association__e> listEvent = new List<Order_Association__e>();
            listEvent.add(event);
            
            OrderAssociationDataContext context = new OrderAssociationDataContext(listEvent);
            
            // Action
            Test.startTest();
            
            OrderAssociationProjectLocation.createAndAssociateProjectLocation(context);
            OrderAssociationProjectLocation.createLocation(context);
            OrderAssociationProjectLocation.updateShippingLocation(projectLocation1);
            OrderAssociationProjectLocation.createAddressObject(installAt,location,true);
            OrderAssociationProjectLocation.createProjectLocationObject(installAt,location, order.id,project.id,'Install At Contact',true);
            OrderAssociationProjectLocation.projectLocationExists(projectLocationList,location.id,'Shipping');
            OrderAssociationProjectLocation.projectLocationExistsForAcccount(projectLocationList,location.id);
            upsert context.saveAddress;
            upsert context.saveProjectLocation;
            
           Test.stopTest();
            
            // Assertion
           // System.assertEquals(1, context.saveAddress.size());
           // System.assertEquals(3, context.saveProjectLocation.size());
            
            List<Project_Location__c> resultInstallAt = [SELECT Id, Project__c, Address_Type__c, Default_Address__c FROM Project_Location__c WHERE Project__c =: project.Id AND Address_Type__c = 'Install At Contact'];
            System.assertEquals(1, resultInstallAt.size());
            
            List<Project_Location__c> resultShipping = [SELECT Id, Project__c, Address_Type__c, Default_Address__c FROM Project_Location__c WHERE Project__c =: project.Id AND Address_Type__c = 'Shipping'];
            System.assertEquals(1, resultShipping.size());
            
            System.assertEquals(true, resultInstallAt.get(0).Default_Address__c);
            System.assertEquals(true, resultShipping.get(0).Default_Address__c);
            
        }
    }
    
    private static OrderItem createOrderItem(Id orderId){
        
        // Order Product
        Product2 product = new Product2();
        product.Name='Product Test';
        insert product;
        
        
        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.UseStandardPrice = false; 
        pricebookEntry.UnitPrice = 1;
        insert pricebookEntry;
        
        // Order Item
        OrderItem oi = new OrderItem();
        oi.SKU_Description__c = 'SKU Desc 1';
        oi.SKU_Number__c = '777-1000';
        oi.Quantity = 1;
        oi.UnitPrice = 1;
        oi.Item_Class_Description__c = 'SVC EDT INSTLN';
        oi.Tie_Number__c = '1';
        oi.OrderId = orderId;
        oi.PriceBookEntryId = priceBookEntry.Id;
        oi.SKU_Cost__c = 1;
        oi.Unit_Selling_Price_USD__c = 1;
        oi.SKU_Cost_USD__c = 1;
        insert oi;
        
        return oi;
    }
}