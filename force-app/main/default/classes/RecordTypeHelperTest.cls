@isTest
public class RecordTypeHelperTest {
	@isTest
    public static void method1() {
        RecordTypeHelper.getRecordTypeIds(RecordTypeHelper.getTriggerHandlerConfig('WorkOrder', 'Submitted'));
    }
	@isTest
    public static void method2() {
        RecordTypeHelper.getRecordTypeIds(RecordTypeHelper.getTriggerHandlerConfig('WorkOrder', 'ARR'));
    }
	@isTest
    public static void method3() {
        RecordTypeHelper.getRecordTypeIds(RecordTypeHelper.getTriggerHandlerConfig('WorkOrder', 'FF - Unknown'));
    }
	@isTest
    public static void method4() {
        RecordTypeHelper.getRecordTypeIds(RecordTypeHelper.getTriggerHandlerConfig('WorkOrder', 'Installation Badge'));
    }
	@isTest
    public static void method5() {
        RecordTypeHelper.getRecordTypeIds(RecordTypeHelper.getTriggerHandlerConfig('WorkOrder', 'Installation DSP'));
    }
    @isTest
    public static void method6() {
        RecordTypeHelper.getRecordTypeIds(RecordTypeHelper.getTriggerHandlerConfig('FAIL', 'Submitted'));
    }
        
}