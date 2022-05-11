trigger EmailMessageTrigger on EmailMessage (after insert){

    new ServiceEmailMessageHandler().handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
}