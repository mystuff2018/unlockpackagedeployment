@isTest
public class FBE_EventHandlerTest {
    @isTest
    public static void testMethodEventTriggerHandler()
    {        
        List<Lead> leadList = new List<Lead>();
        Lead leadRecord = new Lead();
        leadRecord.Company = 'Company';
        leadRecord.FirstName='Lead';
        leadRecord.LastName= 'XYZ';
        leadRecord.FBE_Lead_Type__c='Inbound';
        leadRecord.Email ='abc@abc.com';
        leadList.add(leadRecord);
        insert leadList;            
        List <User> userList=[SELECT Id, Name FROM User where Name IN ('Boomi Prod IntUser Boomi Prod IntUser', 'Christy Rivas', 'Joe Drago') Order By Name];       
        List<Event> e = new List<Event>();      
        Event ev= new Event();             
        ev.Subject='call';
        ev.OwnerId=userList[0].id;       
        ev.StartDateTime = datetime.newInstance(2021, 9, 15, 12, 30, 0);
        ev.EndDateTime = datetime.newInstance(2021, 9, 15, 13, 30, 0);
        ev.WhoId=leadList[0].id;
        e.add(ev); 
        insert e;
        Test.startTest();              
        FBE_EventHandler.UpdateEventOwner(e);        
        Test.stopTest();        
        system.assertEquals('Boomi Prod IntUser Boomi Prod IntUser',userList[0].Name);
        system.assertEquals('Christy Rivas', userList[1].Name);
        system.assertEquals(ev.WhoId,leadList[0].id);
        system.assertNOTEquals(null,ev.OwnerID);
    }
}