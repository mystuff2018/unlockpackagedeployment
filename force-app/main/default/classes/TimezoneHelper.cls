/**
 *	Time Zone Helper
 *	----------------
 * 	@Author 	-	Luis Valenzuela (FinancialForce.com, Inc).
 * 	@date		-	2019-06-12
 *
 * 	Helper class to assist with Timezone conversion
 * 	
 *	Date			Developer			Tag				Summary of Changes 
 *	*********************************************************************************************************************
 *	20190612     	Luis Valenzuela		LV20190612		Creation
 */
public with sharing class TimezoneHelper 
{
	public static map<String,String> javaTimeZone_map = new map<String,String>(); 
	
	/********************************************************************************************************************
	 *	Get Time Zones
	 *	--------------
	 *	@desc		-	Retrieve Timezone Custom MDT if not already in the static map		
	 */
	public static map<String,String> getTimeZones( set<String> siteTimeZoneApi_set )
	{
		if( javaTimeZone_map.keyset().containsAll(siteTimeZoneApi_set) == false )
		{
			for( TimezoneJavaMapping__mdt tz : [SELECT MasterLabel, SitePicklistAPI__c FROM TimezoneJavaMapping__mdt WHERE SitePicklistAPI__c in :siteTimeZoneApi_set] )
			{
				javaTimeZone_map.put(tz.SitePicklistAPI__c, tz.MasterLabel );
			}
		}
		return javaTimeZone_map;
	}

	
	/********************************************************************************************************************
	 *	Convert From
	 *	------------
	 *	@desc		-	Convert Datetime passed in another TZ to the current local timezone.		
	 */
	public static dateTime convertFrom(  dateTime dt, String fromTimeZoneId ) 
	{
		TimeZone tz = getTimeZone( fromTimeZoneId );
		integer offsetMins = (tz.getOffset(dt) - UserInfo.getTimeZone().getOffset(dt) )/ (1000*60);
		DateTime returnDt = dt.addMinutes( -offsetMins );
		return returnDt;
	}


	public static TimeZone getTimeZone( String timeZoneId )
	{
		if( timeZoneId ==  null || timeZoneId == '')
		{
			throw new TimezoneException('Null or blank timezone supplied.');
		}
		TimeZone tz = Timezone.getTimeZone(timeZoneId);
		if( timeZoneId != tz.getId() )
		{
			throw new TimezoneException('Unknown Timezone with ID of :' + timeZoneId);
		}
		return tz;
	}

	public static String getLocalDateString( DateTime dt )
	{
		return  dt.Year() +':'+ dt.Month() +':'+ dt.Day() +' _ '+ dt.Hour() +':'+ dt.Minute() +':'+ dt.second();
	}

	public static Datetime conversionDateToDateTime(Date conversionDate, Integer offset){
        Datetime result = (conversionDate != null) ?  Datetime.newInstanceGmt(conversionDate, Time.newInstance(offset, 0, 0, 0)) : null;
        return result;
    }
	
	public class TimezoneException extends Exception{}
    
}