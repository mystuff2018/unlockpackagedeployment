/**************
 *@ Class Name        : FBE_Format_DateTime
 *@ Description       : This class is written to convert date fields into required timezone depending on Custom Label. Used in email template - FBE Deal Approval Email Template
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 07-24-2019
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script to set Timezone
 ***************/
public class FBE_Format_DateTime {
    
    public DateTime date_time { get; set; } //property that reads the datetime value from component attribute tag
    public String defined_format { get; set;} //property that reads the string value from component attribute tag
    public String getFormattedDatetime()
    {
        //Timezone tz = UserInfo.getTimeZone();
        Timezone tz = Timezone.getTimeZone(Label.Deal_Email_Time_Zone); //Gets value from Custom Label such as CST.
        String timezoneId = tz.getID();
        String timeZoneName = tz.getDisplayName();
        if (date_time == null) {return ''; }
        else { 
            if (defined_format == null)
            {
                return date_time.format(); //return the full date/time in user's locale and time zone
            }
            else { 
                String dt = date_time.format(defined_format,timezoneId);
                String returnValue = dt + ' - ' + timeZoneName.substring(11);
                System.debug('Return Value: '+returnValue);
                return returnValue;
                 }
        }
    }
}