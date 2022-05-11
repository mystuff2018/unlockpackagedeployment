trigger FBE_ConfigaratorTrigger on FBE_Configurator__c (after Update) {
    FBE_ConfiguratorHandler.onAfterUpdate(trigger.new,trigger.oldMap);
}