trigger FBE_EventTrigger on Event (After insert) {
    if(Trigger.isInsert){
        FBE_EventHandler.UpdateEventOwner(trigger.new);
    }
}