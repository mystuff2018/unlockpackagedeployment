/**************
*@ Class Name        : FBE_LeadAssignmentController
*@ Description       : This class sets Lead Owners based on certain Assignment rules. It has following two methods:
                       1. getLeadDetails - Receives Lead record as a List from Process builder. It fetches required Lead parameters based on Lead Type
                                           and Lead - Campaign Role values.
                       2. assignLeadOwner - Sets Lead Owner based on following criteria. For an Outbound Lead, Sales Role is lookup in Account Team and user
                                            with lowest Employee Number is assigned the Lead. For an Inbound Lead, Campaign Follow-Up role is looked up in Account
                                            Team and user having lowest Employee Number is assigned the Lead. If no Follow-Up Role is present then Secondary
                                            Role value is picked. In either case, if Account has no users with Role value, then random Team member is assigned the Lead.
                                            If Account does not contain any team members for Outbound Lead, it is assigned to Lead Qualification Team.
*@ CreatedBy         : Deloitte Consulting
*@ CreatedOn         : 07-05-2019
*@ Modification Log  : Version 1.0 - [Yogesh Mishra] : Initially created script to assign Lead Owners
                       Version 1.1 - [Abhishek Kawle] : Updated script to pass Lead record as a List from process builder
                       Version 1.2 - [Rakesh Reddy 4/1/2022] : DEFECT 12315801/STORY 11415610 - updated logic to match the campaign roles with dell main and Account Team Member Roles(Abbreviated) 
***************/
public without sharing class FBE_LeadAssignmentController {
    
    @InvocableMethod
    public static void getLeadDetails(List<Lead> leadRecord) {
        try{
            Set<Id> accntIds = new Set<Id>();
            Set<String> salesRoles = new Set<String>();
            Set<String> cfRoles = new Set<String>();
            Set<String> csRoles = new Set<String>();
            List<String> followupRolesFromCMT = new List<String>();
            list<Lead> leadsToUpdate = new list<Lead>();
            Id leadId;
            String leadType;
            String leadSalesRole;
            Id leadAccountId;
            String campaignFollowUpRole;
            String campaignSecondaryRole;
            String leadOwnerId;
            list<AccountTeamMember> accTeamList = new list<AccountTeamMember>();
                        
            for(Lead leadRec: leadRecord){
               accntIds.add(leadRec.FBE_Account_Name__c); 
               salesRoles.add(leadRec.FBE_Sales_Role__c);
               cfRoles.add(leadRec.FBE_Campaign_Follow_Up_Role__c);
               csRoles.add(leadRec.FBE_Campaign_Secondary_Role__c); 
            //Get Lead Details from Lead record received in input.
             /*leadId = leadRec.Id;
             leadType = leadRec.FBE_Lead_Type__c;
             leadSalesRole = leadRec.FBE_Sales_Role__c;
             leadAccountId  = leadRec.FBE_Account_Name__c;
             campaignFollowUpRole = leadRec.FBE_Campaign_Follow_Up_Role__c;
             campaignSecondaryRole = leadRec.FBE_Campaign_Secondary_Role__c;         */       
            }
            
            accTeamList = [SELECT Id,AccountId, UserId,User.EmployeeNumber,TeamMemberRole FROM AccountTeamMember
                           WHERE AccountId IN: accntIds];
            List<Followup_Role_Mapping__mdt> CampaignRoleMapping = [SELECT Id,MasterLabel,Role_Name_in_Abbreviated_Form__c FROM Followup_Role_Mapping__mdt];
            
            for(Followup_Role_Mapping__mdt fpRole : CampaignRoleMapping){
                followupRolesFromCMT.add(fpRole.MasterLabel);
            }
            system.debug('followupRolesFromCMT ' +followupRolesFromCMT);
            //Commented Query to Fetch Account Team Members based on Role Names.
            //accTeamList = [SELECT Id,AccountId, UserId,User.EmployeeNumber,TeamMemberRole FROM AccountTeamMember
             //              WHERE AccountId IN: accntIds AND (TeamMemberRole IN: salesRoles OR TeamMemberRole IN:cfRoles OR TeamMemberRole IN:csRoles )];
            //System.debug('Account Team List: '+accTeamList);
            
            for(Lead leadRec: leadRecord){
              //Get Lead Details from Lead record received in input.
             leadId = leadRec.Id;
             leadType = leadRec.FBE_Lead_Type__c;
             leadSalesRole = leadRec.FBE_Sales_Role__c;
             leadAccountId  = leadRec.FBE_Account_Name__c;
             campaignFollowUpRole = leadRec.FBE_Campaign_Follow_Up_Role__c;
             campaignSecondaryRole = leadRec.FBE_Campaign_Secondary_Role__c;                
                       
            //Invoke Lead Assignment based on Lead Type
            if(leadType == 'Outbound'){
                //Assign based on Lead - Sales Role
                leadOwnerId = assignLeadOwner(leadId, leadType, leadSalesRole, leadAccountId,accTeamList); 
            }
            else if(leadType == 'Inbound'){
                if(campaignFollowUpRole != null && campaignFollowUpRole != ''){
                    //Assign based on Campaign Follow-Up Role
                    if(followupRolesFromCMT.contains(campaignFollowUpRole) || followupRolesFromCMT.contains(campaignSecondaryRole)){
                        for(Followup_Role_Mapping__mdt fpRole : CampaignRoleMapping){
                            if(fpRole.MasterLabel == campaignFollowUpRole){
                                leadOwnerId = assignLeadOwner(leadId, leadType, fpRole.Role_Name_in_Abbreviated_Form__c, leadAccountId,accTeamList);
                            }
                            else if(fpRole.MasterLabel == campaignSecondaryRole){
                                leadOwnerId = assignLeadOwner(leadId, leadType, fpRole.Role_Name_in_Abbreviated_Form__c, leadAccountId,accTeamList);
                            }
                        }
                    }
                    else{
                        //Assign to Lead Qualification Team if Primary and secondary Roles are not matching
                       leadOwnerId = assignLeadOwner(leadId, leadType, campaignFollowUpRole, leadAccountId,accTeamList);  
                    }                                 
                }
            }
            
            //Update lead record with new Owner
            if(leadOwnerId != null){
                //System.debug('Lead Owner Id:' +leadOwnerId);
                Lead lRec = new Lead();
                lRec.Id = leadId;
                lRec.OwnerId = leadOwnerId;
                lRec.FBE_Trigger_Lead_Assignment__c = false;
                leadsToUpdate.add(lRec);
            }
            }
            update leadsToUpdate; 
        }
        catch(Exception e){
            System.debug('Error Occurred : ' +e.getMessage() + ' at line ' + e.getLineNumber().format());
        }
    }

    
    public static String assignLeadOwner(Id leadId,String Type,String Role, Id accountId, list<AccountTeamMember> accTeamList){
        //try{
            list<AccountTeamMember> tempaccTeamList = new list<AccountTeamMember>();
            list<AccountTeamMember> accTeamForLeadAcc = new List<AccountTeamMember>();
            Integer minEmpNum=0; String leadOwnerId;
            AccountTeamMember minaccTMem = null;
            
        for(AccountTeamMember accMem : accTeamList){
            if(accMem.AccountId == accountId){
                accTeamForLeadAcc.add(accMem);
            }
        }
            
            if(accTeamForLeadAcc.size()>0){
                for(AccountTeamMember accTeam : accTeamList){
                    if(accTeam.TeamMemberRole == Role && accTeam.AccountId== accountId){
                        //System.debug('Now checking User with Role: '+accTeam.TeamMemberRole);
                        tempaccTeamList.add(accTeam);
                        if(tempaccTeamList.size()==1){
                            //System.debug('TemAccList Size: '+tempaccTeamList.size());
                            minEmpNum=Integer.ValueOf(accTeam.User.EmployeeNumber);
                            minaccTMem=accTeam;
                        }
                        if(minEmpNum>Integer.ValueOf(accTeam.User.EmployeeNumber)){
                            minEmpNum=Integer.ValueOf(accTeam.User.EmployeeNumber);
                            minaccTMem=accTeam;
                        }
                    }
                    else
                    {
                      /*  if(minaccTMem == null && accTeam.AccountId== accountId && Type == 'Outbound'){ 
                            //Assign to a random Account Team Member if Lead Type is outbound and no Team Members 
                            //with Lead Sales Role is present on Account.
                            minaccTMem=accTeam;
                            System.debug('Assigning Random Account Team Member');
                        }*/
                        
                        if(minaccTMem == null && accTeam.AccountId== accountId){
                            //Assign to a Lead Qualification Team  and no Team Members is present on Account.
                            leadOwnerId = Label.Lead_Qualification_Team_Queue_Id;
                        }
                    }
                }
                if(minaccTMem != null)
                {
                    //Assign to Team Member having minimum value for Employee Number
                    leadOwnerId =  minaccTMem.UserId;
                    System.debug('Assigned user with Id: '+minaccTMem.UserId);
                }
            }
                else
                {
                    if(Type == 'Outbound')
                    {
                        leadOwnerId = Label.Lead_Qualification_Team_Queue_Id;
                    }
                    else
                    {
                        //No change in Owner for Inbound Lead
                        leadOwnerId = Label.Lead_Qualification_Team_Queue_Id;
                    }
                }               
             return leadOwnerId;            
            
       // }
       // catch(Exception e){
         //   System.debug('Error Occurred : ' +e.getMessage() + ' at line ' + e.getLineNumber().format());
        //}
    }
}