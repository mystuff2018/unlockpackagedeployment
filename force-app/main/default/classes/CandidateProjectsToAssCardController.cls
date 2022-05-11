/*
 * @test CandidateProjectsToAssCardControllerTest
 * @authors Pablo Dunke and Guilherme Chiossi
 * @date 04/14/2020
 */

public class CandidateProjectsToAssCardController 
{
    @AuraEnabled
    public static void associateOrderToEngagement(Id pOrderId, Id pEngagementId)
    {
        Order order = new Order(Id = pOrderId);
        order.Project__c = pEngagementId;
        update order;

        Order_Item_Grouping__e event = new Order_Item_Grouping__e(
            Order_ID__c = pOrderId,
            Engagement_ID__c = pEngagementId
        );
		
        EventBus.publish(event);
        system.debug('Event Fired');
    }
}