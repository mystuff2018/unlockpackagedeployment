/*
 *@ Trigger Name                                                  : FBE_CPQ_QuoteAttachmentSharing ####11432375
 *@ Description                                                   : This trigger is used to share the quote attachemnts with partner user####11432375
 *@ CreatedBy                                                     : Varsha Singh  
 *@Test Class                                                     : FBE_CPQ_QuoteAttachmentSharing_Test
 */
trigger FBE_CPQ_QuoteAttachmentSharing on ContentDocumentLink (before insert) {
 if (Trigger.isBefore && Trigger.isInsert) {
       system.debug('isBefore');
        FBE_CPQ_QuoteAttachmentSharingHelper.quoteFileSharing(Trigger.new);
    }
}