/**************
* @Class       : FBE_LeadEmailTemplate
* @Description   : This is controller class for FBE_LeadListOfOwner & FBE_LeadManagerList which are used in Email tempalates
					FBE_LeadStatusManagerNotification,FBE_LeadStatusOwnerNotification.
* @CreatedBy     : DeLL Team
* @CreatedOn     : 03-04-2020 [Soumithri Rekha, Sai]
***************/

public class FBE_LeadEmailTemplate {
    public integer count {get;set;}
    public integer countUsers {get;set;}
    public String managerid {get;set;}
    public Id userID {get;set;}
    
    public List<lead> getLeadList()
    {
        List<Lead> managerLeads;
        if(managerid != null){
            managerLeads = [select owner.Name,FBE_Lead_Tracking_ID__c,FirstName,LastName,FBE_Days_Since_Lead_Created_Date__c,Days_Since_Last_Owner_Reassignment_Date__c,
                            Company,Status from lead where Status in('New','Working') and FBE_Lead_Type__c = 'Inbound' and FBE_LeadOwnerMangerId__c =:managerid];
            count = managerLeads.size();
        }
        return managerLeads;
    }
    public List<lead> getownerLeadList()
    {
        List<Lead> allLeads;
        allLeads = [select owner.Name,FBE_Lead_Tracking_ID__c,FirstName,LastName,FBE_Days_Since_Lead_Created_Date__c,Days_Since_Last_Owner_Reassignment_Date__c,Company,Status from lead where Status in('New','Working') and FBE_Lead_Type__c = 'Inbound' and ownerid =: userID];
        system.debug('allLeads'+allLeads);
        countUsers = allLeads.size();
        return allLeads;
    }
}