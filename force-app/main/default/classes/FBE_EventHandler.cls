public class FBE_EventHandler {
    public static void UpdateEventOwner(List<Event> newEvent){            
        List <User> userList=[SELECT Id, Name FROM User where Name IN ('Boomi Prod IntUser Boomi Prod IntUser', 'Christy Rivas', 'Joe Drago') Order By Name];       
        List<Group> leadQueue = [SELECT Id FROM Group Where Name IN ('aISR Queue' , 'Lead Qualification Team') Order BY Name];         
        List<Event> eveList = new List<Event>();
        for (Event e:newEvent){
            if(e.ownerId==userList[0].Id)
            {          
                for(Event eve : [select id , ownerId , whoId from Event where Id =: e.id]){                   
                   for(Lead leadList : [Select id,OwnerId from Lead where Id =: e.whoid]){                   
                    if(leadList.OwnerId==leadQueue[0].Id){                  
                        eve.OwnerId=userList[2].Id;                       
                    }
                    if(leadList.OwnerId==leadQueue[1].Id){                    
                        eve.OwnerId=userList[1].Id;
                    }
                    if(leadList.OwnerId!=leadQueue[0].Id && leadList.OwnerId!=leadQueue[1].Id){                 
                        eve.OwnerId=leadList.OwnerId;
                    }
                    eveList.add(eve);                    
                }  
                }                                                        
            }
        }       
        if(eveList.size()>0){
            update eveList;            
        }
    }
}