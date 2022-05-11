@isTest
public class TimeZoneOffset_Test {
    @isTest
    public static void TimeZoneOffset_Test1()
    {
        TimeZoneOffset tzo = new TimeZoneOffset();
        tzo.offset = 'test';
        tzo.abbreviation = 'test';
        tzo.tz_name = 'test';
        tzo.tz_sfdc = 'test';
    }
}