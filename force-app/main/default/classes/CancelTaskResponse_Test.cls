/**
 * Thomas Davis
 * 2018-11-02
 * FinancialForce.com, Inc.
 * thdavis@financialforce.com
 *
 * Provides test code coverage for the following classes:
 *
 * CancelTaskResponse.cls
 */
@IsTest
public class CancelTaskResponse_Test
{

    // This test method should give 100% coverage
    static testMethod void testParse()
    {
        String json = '{' +
                '    \"ReturnCode\": \"ScheduleFailed\",' +
                '    \"Task\": {' +
                '        \"objectType\": \"Task\",' +
                '        \"Key\": 415506432,' +
                '        \"Revision\": 3,' +
                '        \"CallID\": \"PWA-100028\",' +
                '        \"Number\": 1,' +
                '        \"ExternalRefID\": \"PWA-100028\"' +
                '    },' +
                '    \"Assignment\": null,' +
                '    \"LinkedTasks\": null,' +
                '    \"SchedulingError\": null' +
                '}';
        CancelTaskResponse r = CancelTaskResponse.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        CancelTaskResponse.Task objTask = new CancelTaskResponse.Task(System.JSON.createParser(json));
        System.assert(objTask != null);
        System.assert(objTask.objectType == null);
        System.assert(objTask.Key == null);
        System.assert(objTask.Revision == null);
        System.assert(objTask.CallID == null);
        System.assert(objTask.Number_Z == null);
        System.assert(objTask.ExternalRefID == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        CancelTaskResponse objCancelTaskResponse = new CancelTaskResponse(System.JSON.createParser(json));
        System.assert(objCancelTaskResponse != null);
        System.assert(objCancelTaskResponse.ReturnCode == null);
        System.assert(objCancelTaskResponse.Task == null);
        System.assert(objCancelTaskResponse.Assignment == null);
        System.assert(objCancelTaskResponse.LinkedTasks == null);
        System.assert(objCancelTaskResponse.SchedulingError == null);
    }
}