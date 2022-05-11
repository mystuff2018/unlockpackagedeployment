/*
 *@ Trigger Name                                                  : FBE_RelatedRelationshipDelete 
 *@ Description                                                   : This trigger is created on Account Contact Relationship. This is executed
                                                                    every time an account contact is deleted. The method executed is called under the class 'FBE_TriggerHandler'.
 *@ CreatedBy                                                     : Deloitte Consulting
 *@ CreatedOn                                                     : 26-04-2017 [Namita Verma]
 *@ Modification Log                                              :                     
 */
trigger FBE_RelatedRelationshipDelete on AccountContactRelation(before delete) {
    FBE_TriggerHandler handler = new FBE_TriggerHandler(Trigger.isExecuting, Trigger.size);
    if (Trigger.isDelete && Trigger.isBefore) {
        handler.onRelatedConRelationshipDelete(Trigger.old);
    }
}