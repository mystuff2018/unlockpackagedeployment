/**
 * Created by Bruno_Frosi on 1/30/2020.
 */

public with sharing class DAL_Milestone {
    public static Map<Id, List<pse__Milestone__c>> getMilestonesByProjectId(Map<Id, pse__Proj__c> projectMap)
    {
        Map<Id, List<pse__Milestone__c>> projectIdToMilestoneListMap = new Map<Id, List<pse__Milestone__c>>();
        for(Id projectId :projectMap.keySet())
        {
            projectIdToMilestoneListMap.put(projectId, new List<pse__Milestone__c>());
        }

        Map<Id, pse__Milestone__c> milestones = new Map<Id, pse__Milestone__c>([SELECT Id, pse__Project__c, Current__c, pse__Status__c, Name
                                                FROM pse__Milestone__c
                                                WHERE pse__Project__c IN :projectMap.keySet()]);
        if(milestones.size() > 0)
        {
            for(Id msId :milestones.keySet())
            {
                pse__Milestone__c milestone = milestones.get(msId);

                List<pse__Milestone__c> ms = projectIdToMilestoneListMap.get(milestone.pse__Project__c);
                if(ms == null)
                {
                    ms = new List<pse__Milestone__c>();
                }
                ms.add(milestone);
                projectIdToMilestoneListMap.put(milestone.pse__Project__c, ms);
            }

        }
        return projectIdToMilestoneListMap;
    }
    
    public static Map<Id, OrderItemMilestoneAssociation__c> getApprovedMilestonesByOrderItemIds(Set<Id> orderItemIdsSet) {
        
        return new Map<Id, OrderItemMilestoneAssociation__c>([SELECT Id, 
                                               Milestone__c, 
                                               Order_Product__c,
                                               Order_Product__r.OrderId
                                               FROM OrderItemMilestoneAssociation__c 
                                               WHERE Order_Product__c IN :orderItemIdsSet 
                                               AND Milestone__r.pse__Status__c = 'Approved']);
        
    }
    public static Map<Id, OrderItemMilestoneAssociation__c> getMilestonesByOrderItemIds(Set<Id> orderItemIdsSet) {
        
        return new Map<Id, OrderItemMilestoneAssociation__c>([SELECT Id, 
                                               Milestone__c,
                                               Milestone__r.pse__Status__c, 
                                               Order_Product__c,
                                               Order_Product__r.OrderId
                                               FROM OrderItemMilestoneAssociation__c 
                                               WHERE Order_Product__c IN :orderItemIdsSet]);
        
    }
    
    public static Map<Id, pse__Milestone__c> getApprovedMilestonesByIds(Set<Id> milestoneIds) {
        
        return new Map<Id, pse__Milestone__c>([SELECT id, pse__Status__c 
                                               FROM pse__Milestone__c 
                                               WHERE pse__Status__c = 'Approved' 
                                               AND Id IN :milestoneIds]);
        
    }
    
}