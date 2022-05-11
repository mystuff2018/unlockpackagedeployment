public class DisplayServapptResAbsCntrl {
    @AuraEnabled(cacheable=true)
    public static List<wrapperClass> getWrapperClassList() {
        User user = [Select Id, TimeZoneSidKey FROM User WHERE Id =: userinfo.getUserId() limit 1];
        System.debug('user'+user);
        String strSTTZ = user.TimeZoneSidKey;
        List<wrapperClass> wrapperList = new List<wrapperClass>();
        List<ServiceAppointment> saList = [SELECT Id, AppointmentNumber, Project__r.Name, Subject, SchedStartTime, SchedEndTime, (SELECT ServiceResource.RelatedRecordId FROM ServiceResources Where ServiceResource.RelatedRecordId =: user.Id) FROM ServiceAppointment Where SchedStartTime = TODAY OR SchedEndTime = TODAY OR (SchedStartTime <= TODAY AND SchedEndTime >= TODAY)];
        System.debug('SA'+saList);
        List<ResourceAbsence> resabsList = [SELECT Id, AbsenceNumber, Start, End, Type, Resource.RelatedRecordId FROM ResourceAbsence Where (End = TODAY OR Start = TODAY OR (Start <= TODAY AND End >= TODAY)) AND Resource.RelatedRecordId =: user.Id];
        System.debug('RA'+resabsList);
        if(!saList.isEmpty()){
            for(ServiceAppointment sa: saList){
                wrapperClass wc = new wrapperClass();
                wc.saId = sa.Id;
                wc.saNo = sa.AppointmentNumber;
                wc.subject = sa.Subject;
                wc.proj = sa.Project__r.Name;
                wc.schedStart =  sa.SchedStartTime;
                wc.LocalschedStart = sa.SchedStartTime.format('HH:mm a', strSTTZ);
                wrapperList.add(wc);
            }
        }
        if(!resabsList.isEmpty()){
            for(ResourceAbsence resab: resabsList){
                wrapperClass wc = new wrapperClass();
                wc.resId = resab.Id;
                wc.resNo = resab.AbsenceNumber;
                wc.resType = resab.Type;
                wc.resStart = resab.Start;
                wc.resEnd = resab.End;
                wc.LocalStart = resab.Start.format('HH:mm a', strSTTZ);
                wc.LocalEnd = resab.End.format('HH:mm a', strSTTZ);
                wrapperList.add(wc);
            }
        }
        return wrapperList;
    }
    
    public class wrapperClass{
        @AuraEnabled public String saId;
        @AuraEnabled public String saNo;
        @AuraEnabled public String subject;
        @AuraEnabled public String proj;
        @AuraEnabled public DateTime schedStart;
        @AuraEnabled public String LocalschedStart;
        @AuraEnabled public String resId;
        @AuraEnabled public String resNo;
        @AuraEnabled public String resType;
        @AuraEnabled public DateTime resStart;
        @AuraEnabled public String LocalStart;
        @AuraEnabled public DateTime resEnd;
        @AuraEnabled public String LocalEnd;
	}
}