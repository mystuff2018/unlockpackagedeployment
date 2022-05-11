/**************
*@ Class Name        : FBE_IndirectOptyOwnerAssignment
*@ Description       : This class called from Process Builder "Update AE,ISR on Opportunity", assign Owners to Indirect (created on deal approval) Opportunity based on Sold To Account Team Member having Role = SR & min Employee Number.
*@ CreatedBy         : Deloitte Consulting
*@ CreatedOn         : 09-20-2019
*@ Modification Log  : 
***************/
public without sharing class FBE_IndirectOptyOwnerAssignment {
    
    @InvocableMethod
    public static void assignOptyOwner(List<Opportunity> optyList) {
        try{
            Set<Id> accntIds = new Set<Id>();
            List<AccountTeamMember> accTeamList = new List<AccountTeamMember>();
            List<Opportunity> optyToUpdate = new List<Opportunity>();
            list<AccountTeamMember> tempaccTeamList = new list<AccountTeamMember>();
            list<AccountTeamMember> accTeamForOptyAcc = new List<AccountTeamMember>();
            Integer minEmpNum=0; String optyOwnerId;
            AccountTeamMember minaccTMem = null;
            for (Opportunity opp : optyList) { System.debug('Assign Owner Called'+opp);
                if(opp.FBE_Pursuit_Type__c == 'Indirect' && opp.FBE_Linked_DealReg__c != null){  System.debug('Assign Owner Called INdirect Opty: ');
                    accntIds.add(opp.AccountId);   
                }
            }
            if(!accntIds.isEmpty()){
                accTeamList = [SELECT Id,AccountId, UserId,User.EmployeeNumber,TeamMemberRole FROM AccountTeamMember WHERE AccountId IN: accntIds and TeamMemberRole = 'SR' ];
            }
            if(!accTeamList.isEmpty()){System.debug('Assign Owner Called accTeamList: '+accTeamList);
                for (Opportunity op : optyList) { 
                    for(AccountTeamMember accMem : accTeamList){
                        if(accMem.AccountId == op.AccountId){
                            accTeamForOptyAcc.add(accMem);
                        }
                    }            
                    if(accTeamForOptyAcc.size()>0){
                        for(AccountTeamMember accTeam : accTeamForOptyAcc){
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
                        if(minaccTMem != null)
                        {
                            //Assign to Team Member having minimum value for Employee Number
                            optyOwnerId =  minaccTMem.UserId;
                            //System.debug('Assigned user with Id: '+minaccTMem.UserId);
                        }
                    }
                    if(optyOwnerId != null){
                        //System.debug('Lead Owner Id:' +leadOwnerId);
                        Opportunity lRec = new Opportunity();
                        lRec.Id = op.Id;
                        lRec.OwnerId = optyOwnerId;
                        optyToUpdate.add(lRec);
                    }
                }
                update optyToUpdate;                
            }
        }catch(Exception e){
            System.debug('Error Occurred : ' +e.getMessage() + ' at line ' + e.getLineNumber().format());
        }
    }
}