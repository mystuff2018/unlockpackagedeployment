/*
      Purpose	: Update Resource fields when User gets deactivated
      Author	: Pawan K
      Company	: OAC Services, INC.
      Created	: 1/3/19
*/
public  class UserResourceController 
{
	@testVisible
	private static boolean overrideTrigger = false;
	
    Public static void updateResource( Map<Id,User> userNewMap, Map<Id,User> userOldMap )
    {
        set<Id> resourceIds = new set<Id>();
        
        for( User objUser : userNewMap.values() )
        {
        	// Added to allow testing where impossible to change user active due to mixed DML
            if( overrideTrigger )
            {
                resourceIds.add(objUser.Id);
			}
            
			if( !objUser.IsActive && userOldMap.get(objUser.Id) != NULL && userOldMap.get(objUser.Id).IsActive )
			{
				resourceIds.add(objUser.Id);
			}
        }
        
        if(!resourceIds.isEmpty())
        {
			list<Contact> lstContacts = [SELECT Id,Name, 
                                         		pse__Salesforce_User__c,
                                         		pse__Is_Resource_Active__c,
                                         		pse__Last_Date__c,
                                         		pse__Exclude_from_Resource_Planner__c
                                         FROM Contact
                                         WHERE pse__Salesforce_User__c IN: resourceIds
                                        ];
            set<id> contId_set = new set<id>(); 
            for( Contact objCont : lstContacts )
            {
            	contId_set.add(objCont.id);
            }
            if( contId_set.isEmpty() == false )
            {
                //Below method commented by Siva for ContactEndDate batch class
	           // updateResources(contId_set);             	
            }
        }
    }

    /*
	@future
    Public static void updateResources(set<id> contactId_set )
    {
    	list<Contact> lstContacts = new list<Contact>();
        for( id contID : contactId_set )
        {
        	Contact cntct =  new Contact() ;
        	cntct.id = contID;
            cntct.pse__Is_Resource_Active__c = false;
            cntct.pse__Last_Date__c = system.today(); 
            cntct.pse__Exclude_from_Resource_Planner__c = true;  
            lstContacts.add(cntct);                  
        }
             update lstContacts; 
    }
*/
}