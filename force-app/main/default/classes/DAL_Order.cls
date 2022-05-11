/**
 * Created by Bruno_Frosi on 1/9/2020.
 *
 * Data access layer for Order Object.
 * This class should be used to concentrate avery SOQL query for Order.
 * Pay attention to implement reusable queries.
 * @ Modification Log  : Version 1.0 - [Deloitte - Abhishek Kawle] : Modified code - getOrdersByIds() to query Order > Sales Rep related fields Feature #7865383
 * 						 Version 2.0 - [Deloitte - Abhishek Kawle] : Added new code - getAllOrderForGrouping to query Orders belonging to same PO Number.
 */

public with sharing class DAL_Order
{
    public static Map<Id, Order> getOrdersByIds(Set<Id> orderIds)
    {
        system.debug('getOrdersByIds');
        Map<Id, Order> orderMap = new Map<Id, Order>([
        SELECT Id,
                Name,
                AccountId,
                Billing_Country__c,
                Billing_State__c,
                BillingCountry,
                BillingState,
                BillToContact.Mailing_Country__c,
                BillToContact.Mailing_State__c,
                BillToContact.MailingCountry,
            	BillToContact.MailingCountryCode,
                BillToContact.MailingState,
            	BillToContact.MailingStateCode,
                BUID__c,
                CurrencyIsoCode,
                CustomerNumber__c,
                Deal_ID__c,
            	Direct_Account__c,
                Direct_Contact__c,
                Direct_Customer_Number__c,
                DPID__c,
                EffectiveDate,
                End_User_Customer_Number__c,
            	End_User_Account__c,
                End_User_Contact__c,
                FF_Feed__c,
                Install_At_Account__c,
                Install_At_Contact__c,
                Install_At_Customer_Number__c,
                Local_Channel__c,
                OCI_Order_Type__c,
                OPR_Is_Federal__c,
                Order_Status__c,
                OrderNumber,
                OrderNumber__c,
                Order_Processing_Code__c,
                Payment_Term__c,
                PoNumber,
                Project__c,
                Project__r.Name,
                Project__r.pse__Closed_for_Expense_Entry__c,
                Project__r.pse__Closed_for_Time_Entry__c,
                Project__r.pse__End_Date__c,
                Project__r.pse__Is_Active__c,
                Project__r.pse__Is_Billable__c,
                Project__r.pse__Notes__c,
                Project__r.pse__Practice__c,
                Project__r.pse__Project_Manager__c,
                Project__r.pse__Region__c,
                Project__r.pse__Stage__c,
                Project__r.pse__Start_Date__c,
                Project__r.RecordTypeId,
                Sales_Channel__c,
                Sales_Rep__c, 
                Shipping_Country__c,
                Shipping_Customer_Number__c,
                Shipping_State__c,
                ShippingCountry,
                ShippingState,
                ShipToContact.Mailing_Country__c,
                ShipToContact.Mailing_State__c,
                ShipToContact.MailingCountry,
                ShipToContact.MailingCountryCode,
                ShipToContact.MailingState,
            	ShipToContact.MailingStateCode,
                ShipToContactId,
                Sold_to_Contact__c,
                Sold_to_Contact__r.MailingCountryCode,
                Status,
                Shipping_Account__c,
                Type,
                TotalAmount,
                Unassociated__c,
                Billing_Account__r.BUID__c,
                Billing_Account__r.CCN__c,
                FBE_Sales_Rep_Badge_Id__c,
                FBE_Sales_Rep_Email__c,
                Sales_Rep_Name__c,
                FBE_Sales_Rep_Phone__c,
            	ShippingStreet,
            	ShippingPostalCode,
            	ShippingCity,
            	FBE_Install_At_Country__c,
                FBE_Install_At_City__c,
                FBE_Install_At_State__c,
                FBE_Install_At_Street__c,
                FBE_Install_At_Postal_Code__c,
                ShippingCountryCode,
                BillingCountryCode,
                    (SELECT Id, 
                            SKU_Number__c, 
                            Item_Class_Description__c, 
                            TotalPrice, SKU_Cost__c, 
                            Quantity, 
                            SKU_Cost_USD_formula__c, 
                            Total_Price_USD_formula__c,
                            Project__c,
                            Unit_Selling_Price_Local__c,
                            Unit_Selling_Price_USD__c,
                     		SKU_Cost_Local__c, 
                     		SKU_Cost_USD__c,
                     		OrderId
                    FROM OrderItems)
        FROM Order WHERE Id IN :orderIds ORDER BY AccountId]);

        if(orderMap.size() > 0){
            return orderMap;
        }
        return null;
    }

    public static Map<Id, Order> getMapOrderWithProjectBySetId(Set<Id> setOrderId)
    {
        Map<Id, Order> mapOrder = new Map<Id, Order>([SELECT Id
                                                            , Deal_ID__c
                                                            , Direct_Account__c
                                                            , DPID__c
                                                            , End_User_Account__c
                                                            , Install_At_Account__c 
                                                            , Name
                                                      		, OrderNumber__c
                                                            , PoNumber
                                                            , Project__c
                                                            , Project__r.Name
                                                            , Project__r.pse__Closed_for_Expense_Entry__c
                                                            , Project__r.pse__Closed_for_Time_Entry__c
                                                            , Project__r.pse__End_Date__c
                                                            , Project__r.pse__Is_Active__c
                                                            , Project__r.pse__Is_Billable__c
                                                            , Project__r.pse__Notes__c
                                                            , Project__r.pse__Practice__c
                                                            , Project__r.pse__Project_Manager__c
                                                            , Project__r.pse__Region__c
                                                            , Project__r.pse__Stage__c
                                                            , Project__r.pse__Start_Date__c
                                                            , Project__r.RecordTypeId
                                                            , Shipping_Account__c
                                                        FROM Order 
                                                        WHERE Id IN: setOrderId]);
        return mapOrder;
    }

    public static Map<Id, Order> getOrderWithoutProjectByIds(Set<Id> orderIds) {
        Map<Id, Order> orders = getOrdersByIds(orderIds);

        if (!orders.isEmpty()) {
            for (Order order: orders.values()) {
                if (order.Project__c != null) {
                    orders.remove(order.Id);
                }
            }
        }

        return orders;
    }

	//[Deloitte - Abhishek Kawle] : Added new code to find orders based on PO Number. This method is reference in OrderCreatedGroupingRules class. 
    public static Map<Id, Order> getAllOrderForGrouping(Set<String> poNumberSet){
        Map<Id, Order> mapOrder = new Map<Id, Order>([ SELECT Id
                                                      , Name
                                                      , OrderNumber__c
                                                      , PoNumber
                                                      , Project__c
                                                      , Project__r.Name 
                                                      , ShippingCountry
                                                      , ShippingState
                                                      , ShippingStreet
                                                      , ShippingPostalCode
                                                      , ShippingCity
                                                      , FBE_Install_At_Country__c
                                                      , FBE_Install_At_City__c
                                                      , FBE_Install_At_State__c
                                                      , FBE_Install_At_Street__c
                                                      , FBE_Install_At_Postal_Code__c
                                                      FROM Order 
                                                      WHERE PoNumber IN :poNumberSet
                                                      AND Project__c != ''
                                                      AND Project__r.pse__Stage__c != 'Closure' 
                                                      AND Project__r.pse__Stage__c != 'Cancelled'
                                                     ]);
        if(mapOrder.size() > 0){
            return mapOrder;
        }
        return null;
    }
}