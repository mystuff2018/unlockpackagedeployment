/***************************************************************************************
* Created By - Saurav Raj (Wipro)
* Created On - September 28, 2021
* Related Task - I-423624
* Purpose - Utility class for flow Project_Manager_Assignment_Automation to create PTA
****************************************************************************************/
public class UtilityClass {
@InvocableMethod 
    public static void CreateProjectAssignment(list<Id>lstId){
        createAssignment(lstId);
    }
        
    @future(callout = true)
    public static void createAssignment(list<Id>lstId){
    	list<pse__Assignment__c> lstAssignment = new list<pse__Assignment__c>();  
        set<ID> setProjectID = new set<ID>();
        for(pse__Assignment__c ass: [Select ID,pse__Project__c,pse__Resource_Request__c,pse__Resource__c,pse__Resource__r.pse__Resource_Role__c from pse__Assignment__c where id = : lstId[0] FOR UPDATE]){
           lstAssignment.add(ass); 
           setProjectID.add(ass.pse__Project__c);
        }    
        map<ID,ID>mapProjectIdWithPmtaskID = new map<ID,ID>();
        for(pse__Project_Task__c pt :[Select ID,pse__Project__c from pse__Project_Task__c where pse__Project__c =: setProjectID and Name ='PM Time Entry' FOR UPDATE]){
            mapProjectIdWithPmtaskID.put(pt.pse__Project__c,pt.Id);
        }
        list<pse__Project_Task_Assignment__c> lstPTA = new list<pse__Project_Task_Assignment__c>();
        for(pse__Assignment__c ass : lstAssignment){
            if(mapProjectIdWithPmtaskID.containsKey(ass.pse__Project__c)){
                pse__Project_Task_Assignment__c pta = new pse__Project_Task_Assignment__c();
                pta.pse__Assignment__c = ass.ID;
                pta.pse__Project_Task__c = mapProjectIdWithPmtaskID.get(ass.pse__Project__c);
                pta.pse__Resource_Request__c = ass.pse__Resource_Request__c;
                pta.pse__Resource_Role__c = ass.pse__Resource__r.pse__Resource_Role__c;
                pta.pse__Resource__c = ass.pse__Resource__c;
                lstPTA.add(pta);
            }            
        }
        insert lstPTA; 
    
    }
}