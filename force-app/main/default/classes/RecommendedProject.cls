/*
 * @test RecommendedProjectTest
 * @authors Pablo Dunke and Guilherme Chiossi
 * @date 04/13/2020
 */

public with sharing class RecommendedProject 
{
    public static List<SuggestedProjectAssociation> getSetRecommendedEngagementIdByOrderId(Id pOrderId) 
    {
        Set<Id> setRecommendedProjectId = new Set<Id>();
        List<SuggestedProjectAssociation> listSuggestedProject = new List<SuggestedProjectAssociation>();

        Map<Id, Order> mapOrder = DAL_Order.getOrdersByIds(new Set<Id>{pOrderId});
        if(mapOrder.size() == 1)
        {
            Order order = mapOrder.get(pOrderId);

            Map<Id, pse__Proj__c> mapIdProject = DAL_Project.getMapRecommendedEngagementForOrderGrouping(order.PoNumber, order.Deal_ID__c, order.DPID__c);
            
            for(pse__Proj__c forProject: mapIdProject.values())
            {
                // PO Number
                List<String> listOrderCustomer = new List<String>();

                if(order.Install_At_Customer_Number__c != null) {
                    listOrderCustomer.add(order.Install_At_Customer_Number__c);
                }
                if(order.Direct_Customer_Number__c != null) {
                    listOrderCustomer.add(order.Direct_Customer_Number__c);
                }
                if(order.End_User_Customer_Number__c != null) {
                    listOrderCustomer.add(order.End_User_Customer_Number__c);
                }
                if(order.Shipping_Customer_Number__c != null) {
                    listOrderCustomer.add(order.Shipping_Customer_Number__c);
                }
                
                for(String forOrderCustomer: listOrderCustomer)
                {
                    if(order.PoNumber != null && forProject.Po_Number__c == order.PoNumber)
                    {
                        if(forProject.Customer_Number_Account__c == forOrderCustomer)
                        {
                            setRecommendedProjectId.add(forProject.Id);
                            break;
                        }
                    }
                }
                
                // Deal ID
                if(order.Deal_ID__c != null && forProject.Deal__c == order.Deal_ID__c)
                {
                    setRecommendedProjectId.add(forProject.Id);
                }

                // DP ID
                if(order.DPID__c != null && forProject.DP__c == order.DPID__c)
                {
                    setRecommendedProjectId.add(forProject.Id);
                }
            }

            for(Id forRecommendedId: setRecommendedProjectId)
            {
                SuggestedProjectAssociation newSuggestion = new SuggestedProjectAssociation();
                //newSuggestion.addReason(reason); 
                newSuggestion.project = mapIdProject.get(forRecommendedId);
                listSuggestedProject.add(newSuggestion);
            }
        }

        return listSuggestedProject;
    }
}