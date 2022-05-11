/*
 * @test OrderAssociationSalesRepTest
 * @authors Pablo Dunke and Christopher Michel
 * @date 01/31/2020
 * @Modification Log: Version 1.0 - [Deloitte - Abhishek Kawle] : Modified code to update Sales Rep field on Order with Contact
 *                                  The Sales Rep Badge Id is received from Order Interlock and it is queried in FF for existing Contacts. 
 *                                  In case contact with a badge Id does not exist, a new contact is created and updated on Order. 
 *                                  Created as part of Feature #7865383.
 */

public class OrderAssociationSalesRep
{
    public static void setProjectSalesRep(OrderAssociationDataContext context)
    {
        List<Order> orderList = new List<Order>();
        List<Contact> contactsList =  new List<Contact>();
        Set<String> contactsToQuery = new Set<String>();
        List<Order> ordersToUpdate = new List<Order>();
        List<Contact> contactsToInsert = new List<Contact>();
        Map<Id, pse__Proj__c> mapProjectToUpdate = new Map<Id, pse__Proj__c>();

        String defaultAccountName = System.label.FBE_Order_Interlock_Sales_Rep_Account;
        
        //Query Default Account under which Contacts get added for FF
        List<Account> defaultAccount = [SELECT Id
                                       FROM Account
                                       WHERE Name =:defaultAccountName
                                       LIMIT 1];

        for(Id orderIds : context.orderMap.keySet()){
            Order order = context.orderMap.get(orderIds);
            if(order.FBE_Sales_Rep_Badge_Id__c != null){
                contactsToQuery.add(order.FBE_Sales_Rep_Badge_Id__c);
            }
        }

        if(!contactsToQuery.isEmpty()){
            contactsList = [SELECT Id, 
                            Badge_ID__c
                            FROM Contact
                            Where Account.Name =:defaultAccountName
                            AND Badge_ID__c IN :contactsToQuery];
        }

        for(Id orderIds : context.orderMap.keySet()){
            Order order = context.orderMap.get(orderIds);
            boolean contactFound = false;
            for(Contact eachContact : contactsList){
                if(order.FBE_Sales_Rep_Badge_Id__c == eachContact.Badge_ID__c){
                    
                    if(order.Sales_Rep__c != eachContact.Id){
                        Order orderObj = new Order(
                            id = order.Id,
                            Sales_Rep__c = eachContact.Id
                        );
                        ordersToUpdate.add(orderObj);
                        //Update the OrderMap with the Sales Rep Association
                        order.Sales_Rep__c = eachContact.Id;
                        context.orderMap.put(orderIds, order);
                        }
                    
                    contactFound = true;
                }   
            }

            //Since no contact exists for badge ID, script creates a new contact.
            if(!contactFound && !contactsToQuery.isEmpty()){
                System.debug('<<Contact with Badge Id not found for Order: '+order.Id+ ' <<Order with Badge Id: '+order.FBE_Sales_Rep_Badge_Id__c);
                string contactName = order.Sales_Rep_Name__c;
                Contact contactObj = new Contact(
                    FirstName = contactName.substringBefore(' '),
                    LastName = contactName.substringAfter(' '),
                    Phone = order.FBE_Sales_Rep_Phone__c,
                    Email = order.FBE_Sales_Rep_Email__c,
                    Badge_ID__c = order.FBE_Sales_Rep_Badge_Id__c,
                    AccountId = defaultAccount[0].Id
                    //,pse__Is_Resource_Active__c = true
                    //,pse__Is_Resource__c = true
                    ,RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Internal_Employee').getRecordTypeId()
                );
                
                System.debug('<<Contact to be inserted: '+contactName+ ' <<Badge Id: '+ order.FBE_Sales_Rep_Badge_Id__c);
                contactsToInsert.add(contactObj);
            }
        }

        //Insert Contacts
        if(!contactsToInsert.isEmpty()){
            Set<Id> objectList = new Set<Id>();
            objectList.addAll(context.orderMap.keySet());
            List<Database.UpsertResult> contactsInsertResults = Database.upsert(contactsToInsert, false);
            context.exceptionLoggers.addAll(
                SaveResultExceptionLogger.saveResultsLog(null, contactsInsertResults, objectList, 'OrderAssociationSalesRepTest.setProjectSalesRep', 'Sales Rep Contact Upsert')
            );  
            
            
            //Map Contact Ids for above contacts with related Orders, matched using Badge Id
            for(Id orderIds : context.orderMap.keySet()){
            Order order = context.orderMap.get(orderIds);
                for(Contact eachContact : contactsToInsert){
                    
                    if(order.FBE_Sales_Rep_Badge_Id__c == eachContact.Badge_ID__c){
                        Order orderObj = new Order(
                            id = order.Id,
                            Sales_Rep__c = eachContact.Id
                        );
                        
                        ordersToUpdate.add(orderObj);
                        //Update the OrderMap with the Sales Rep Association
                        order.Sales_Rep__c = eachContact.Id;
                        context.orderMap.put(orderIds, order);
                    }
                }
            }
        }
        
        System.debug('<<Following Orders will be updated: '+ordersToUpdate);
        if(!ordersToUpdate.isEmpty()){
            Set<Id> objectList = new Set<Id>();
            objectList.addAll(context.orderMap.keySet());
            List<Database.UpsertResult> ordersUpdateResult = Database.upsert(ordersToUpdate, false);
            context.exceptionLoggers.addAll(
                SaveResultExceptionLogger.saveResultsLog(null, ordersUpdateResult, objectList, 'OrderAssociationSalesRepTest.setProjectSalesRep', 'Order Sales Rep Upsert')
            );
        } 


        for(Id forProjectId: context.projectWithOrdersMap.keySet()) 
        {
            pse__Proj__c project = context.projectMap.get(forProjectId);

            // Project does not have sales rep
            if(project.Sales_Rep__c == null)
            {
                Set<Id> setOrder = context.projectWithOrdersMap.get(forProjectId);

                for(Id forOrderId: setOrder)
                {
                    Order order = context.orderMap.get(forOrderId);

                    // Update the project sales rep to the same sales rep as the order
                    project.Sales_Rep__c = order.Sales_Rep__c;

                    mapProjectToUpdate.put(project.Id, project);

                    // Leave after the first order
                    break;
                }
            }
        }

        context.projectMap.putAll(mapProjectToUpdate);
    }
}