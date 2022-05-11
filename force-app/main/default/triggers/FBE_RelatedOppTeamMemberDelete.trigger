/*
 *@ Trigger Name                                                  : FBE_RelatedOppTeamMemberDelete
 *@ Description                                                   : This trigger is created on Opportunity Team Member. This is executed
                                                                    every time a team member is deleted. The method executed is called under the class 'FBE_TriggerHandler'.
 *@ CreatedBy                                                     : Deloitte Consulting
 *@ CreatedOn                                                     : 26-04-2017 [Namita Verma]
 *@ Modification Log                                              :                     
 */
trigger FBE_RelatedOppTeamMemberDelete on OpportunityTeamMember(before delete) {
    FBE_TriggerHandler handler = new FBE_TriggerHandler(Trigger.isExecuting, Trigger.size);
    if (Trigger.isDelete && Trigger.isBefore) {
        handler.onRelatedOppTeamMemberDelete(Trigger.old);
    }
}