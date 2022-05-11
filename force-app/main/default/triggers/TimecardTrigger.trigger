trigger TimecardTrigger on pse__Timecard_Header__c (before insert, before update, after update) {
        if(trigger.isbefore && trigger.isinsert && RecursiveTriggerHandler.isFirstTime()){
            FBE_SetTimeCard.setApprover(trigger.new);
            System.debug('I am in Before Timecard');
        }
    
    if(trigger.isafter && trigger.isupdate && RecursiveTriggerHandler.isFirstTime()){
        FBE_SetTimeCard.updateApproveronTimecard();
        // ShivaKumari Novora InterLock -  Feature 8432644
        if(FBE_IDS_NovoraInterLock.runOnceNovoraInterlocks()){
            FBE_IDS_NovoraInterLock.SendTimecardDetailsToNovora(trigger.new);
        }
        System.debug('I am in After Timecard');
    }
}