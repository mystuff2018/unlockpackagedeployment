/*
      Purpose:
            Clone related work orders and work order skills from Service Appointment when status is 'Cannot Complete'
            
      Author	: Pawan Kumar
      Company	: OAC Services INC.
      Created	: 1/8/19

	=============================================================================================================
	Modification History:
	----------------------------------------------------------------------------
	Name		Date		Company				Description
	----------------------------------------------------------------------------
	Thomas D    2/7/19      FinancialForce.com  Modified class to make sure the
	                                            correct Schedule Type is set on
	                                            cloned Work Orders
    Orlando M   10/7/19     FinancialForce.com  Added Project_Location__c field
                                                to WorkOrder query 
	----------------------------------------------------------------------------
*/

public class ServiceAppointmentCloneWorkOrders 
{
	public static void cloneWorkOrders( Map<Id, String> workOrderIdToScheduleTypeMap )
    {
        //------------------------------------------------------------
        	Map<WorkOrder, String> mapWO = new Map<WorkOrder, String>();
        //------------------------------------------------------------
        
        //Get Work Orders
        if(!workOrderIdToScheduleTypeMap.isEmpty())
        {
            mapWO = getWorkOrders(workOrderIdToScheduleTypeMap);
        }
        system.debug('workOrderIds '+workOrderIdToScheduleTypeMap.keySet());
        system.debug('WO '+mapWO);
        
        //clone work orders and work order skills
        if( !mapWO.isEmpty() )
        {
            runWorkOrderCloning(mapWO);

            List<WorkOrder> woUpdates = new List<WorkOrder>();
            for (WorkOrder wo : mapWO.keySet())
            {
                wo.Status = 'FF - Closed';
                woUpdates.add(wo);
            }
            if(woUpdates.size()>0){ //Added if and size check as a part of checkMarx
                update woUpdates;
            }
        }

    }
    
    public static void runWorkOrderCloning( Map<WorkOrder, String> mapWO )
    {
        //------------------------------------------------------------
            map<Id,WorkOrder> mapClonedWOs = new map<Id,WorkOrder>();
            list<Work_Order_Skill__c> clonedWOS = new list<Work_Order_Skill__c>();
            WorkOrder newWO;
            Work_Order_Skill__c newWOS;
        //------------------------------------------------------------
        
        for( WorkOrder objWO : mapWO.keySet() )
        {
            newWO = objWO.clone(false); 
            newWO.Schedule_Type__c = mapWO.get(objWO);
            mapClonedWOs.put(objWO.Id,newWO);
        }
        
        //insert Cloned WO's
        database.insert(mapClonedWOs.values(),true);
        
        system.debug('Cloned WO '+mapClonedWOs);
        
        //Cloning Work Order Skills
        for(WorkOrder objWO : mapWO.keySet())
        {
            if(mapClonedWOs != NULL && mapClonedWOs.get(objWO.Id) != NULL && mapClonedWOs.get(objWO.Id).Id != NULL)
            {
                for(Work_Order_Skill__c objWOS : objWO.Work_Orders_Skills__r)
                {
                    newWOS = objWOS.clone(false);
                    newWOS.Work_Order__c = mapClonedWOs.get(objWO.Id).Id;
                    clonedWOS.add(newWOS);
                }
            }
        }
        If(clonedWOS.size()>0){ //Added if and size check as a part of CheckMarx
        //insert Cloned WOS
        database.insert(clonedWOS,true);
        system.debug('WOS '+clonedWOS);
    	}
    }
    
    public static Map<WorkOrder, String> getWorkOrders( Map<Id, String> workOrderIdToScheduleTypeMap)
    {
        //Get list of Work Orders and Work Order Items along with fields to be cloned
        
        list<WorkOrder> listWO = [SELECT Id,
                                  			Address,
                                  			Duration,
                                  			WorkTypeId,
                                  			Delivery_Method__c,
                                  			Schedule_Type__c,
                                  			Resource_Type__c,
                                  			Description,
                                  			CurrencyIsoCode,
                                  			AccountId,
                                  			Project_Task__c,
                                  			OwnerId,
                                  			recordTypeId,
                                            ContactId,
                                            Subject,
                                            Street,
                                            City,
                                            Country,
                                            PostalCode,
                                            State,
                                  			Project__c,
                                            Project_Location__c,
                                  			(
                                                SELECT Id,Name, 
                                            		OwnerId,
                                                	Skill_Certification__c,
                                                	CurrencyIsoCode
                                                FROM Work_Orders_Skills__r
                                            )
                                 	FROM WorkOrder
                                 	WHERE Id IN: workOrderIdToScheduleTypeMap.keySet()];
        system.debug('listWO '+listWO);

        Map<WorkOrder, String> returnMap = new Map<WorkOrder, String>();

        for (WorkOrder wo : listWO)
        {
            returnMap.put(wo, workOrderIdToScheduleTypeMap.get(wo.Id));
        }

        return returnMap;

    }
}