public class DAL_Practice {
    public static Map<Id, String> getBusinessSegmentByPracticeId(List<Id> practiceIds) {
        Map<Id, String> practiceToBusinessSegment = new Map<Id,String>();
        List<Item_Class__c> itemClassWithBusinessSegment = [SELECT id, Practice__c, Tower__c FROM Item_Class__c WHERE Practice__c = :practiceIds];
        System.debug('@@DPitemClassWithBusinessSegment@@'+itemClassWithBusinessSegment);
        for(Item_Class__c itemClass : itemClassWithBusinessSegment) {
            practiceToBusinessSegment.put(itemClass.Practice__c, itemClass.Tower__c);
            System.debug('@@DAL_PracticepracticeToBusinessSegment@@'+practiceToBusinessSegment);
        }
        return practiceToBusinessSegment;
    }
}