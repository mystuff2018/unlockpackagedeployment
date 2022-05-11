trigger OrderTrigger on Order (before update, after update, before insert, after insert) {
   	FFOrderTriggerHandler.sendInactiveProjectNotification =True;
    //new OrderTriggerHandler().run();
    new FFOrderTriggerHandler().run();
}