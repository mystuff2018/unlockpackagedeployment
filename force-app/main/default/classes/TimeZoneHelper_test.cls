@isTest
public with sharing class TimeZoneHelper_test 
{
	
	@isTest
	public static void testTimeZoneHelper()
	{
		// Cannot insert custom meta data types in Test mode so nothing to assert here as contents will
		// be dependant on whichever org this has been ran in.
		map<String,String> tz_map = TimeZoneHelper.getTimeZones( new set<String>() );
		
		// Argentina chosen as it does not observe daylight saving so will always be GMT - 3
		TimeZone fromTimeZone;
		try
		{
			fromTimeZone = TimezoneHelper.getTimeZone( null );		 	
			system.assert(false, 'TimezoneHelper did not throw error for unknown Timezone');
		}
		catch(Exception ex)
		{
			// Do nothing Excetion Expected.
			system.assert( ex.getMessage().contains('Null or blank timezone supplied') , 'Wrong error message');			
		}
		try
		{
			fromTimeZone = TimezoneHelper.getTimeZone( 'Test Fail' );			
			system.assert(false, 'TimezoneHelper did not throw error for unknown Timezone');
		}
		catch(Exception ex)
		{
			// Do nothing Excetion Expected. 
			system.assert( ex.getMessage().contains('Unknown Timezone with ID of :') , 'Wrong error message');			
		}

		// All test time zones chosen as they don't observe daylight saving, which would result in the
		// GMT time asserted against being out
		Datetime dt = DateTime.newInstance( 2019, 01, 01, 9, 0, 0); // 3PM
		fromTimeZone = TimezoneHelper.getTimeZone( 'America/Buenos_Aires' );			
		Datetime convertedDt = TimeZoneHelper.convertFrom( dt, fromTimeZone.getId() );
		system.assertEquals( 12, convertedDt.hourGMT(), 'Time not converted correctly '); 

		dt = DateTime.newInstance( 2019, 01, 01, 19, 0, 0); // 3PM
		fromTimeZone = TimezoneHelper.getTimeZone( 'Asia/Bangkok' );			
		convertedDt = TimeZoneHelper.convertFrom( dt, fromTimeZone.getId() );
		system.assertEquals( 12, convertedDt.hourGMT(), 'Time not converted correctly '); 

		dt = DateTime.newInstance( 2019, 01, 01, 8, 0, 0); // 3PM
		fromTimeZone = TimezoneHelper.getTimeZone( 'America/Caracas' );			
		convertedDt = TimeZoneHelper.convertFrom( dt, fromTimeZone.getId() );
		system.assertEquals( 12, convertedDt.hourGMT(), 'Time not converted correctly '); 

		// For display purposes only
		TimezoneHelper.getLocalDateString(convertedDt);
		
	}
    
}