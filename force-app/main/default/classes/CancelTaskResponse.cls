/**
 * Thomas Davis
 * 2018-11-02
 * FinancialForce.com, Inc.
 * thdavis@financialforce.com
 *
 * This class mimics the JSON payload received from Click FSE after calling out to their CancelTask API.
 * It is used to deserialize the Click FSE response in ServiceAppointmentHandler.cancelClickTask(). 
 */
public class CancelTaskResponse
{

    public class Task
    {
        public String objectType { get; set; }
        public Integer Key { get; set; }
        public Integer Revision { get; set; }
        public String CallID { get; set; }
        public Integer Number_Z { get; set; } // in json: Number
        public String ExternalRefID { get; set; }

        public Task(JSONParser parser)
        {
            while (parser.nextToken() != System.JSONToken.END_OBJECT)
            {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
                {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                    {
                        if (text == 'objectType')
                        {
                            objectType = parser.getText();
                        }
                        else if (text == 'Key')
                        {
                            Key = parser.getIntegerValue();
                        }
                        else if (text == 'Revision')
                        {
                            Revision = parser.getIntegerValue();
                        }
                        else if (text == 'CallID')
                        {
                            CallID = parser.getText();
                        }
                        else if (text == 'Number')
                        {
                            Number_Z = parser.getIntegerValue();
                        }
                        else if (text == 'ExternalRefID')
                        {
                            ExternalRefID = parser.getText();
                        }
                        else
                        {
                            System.debug(LoggingLevel.WARN, 'Task consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public String ReturnCode { get; set; }
    public Task Task { get; set; }
    public Object Assignment { get; set; }
    public Object LinkedTasks { get; set; }
    public Object SchedulingError { get; set; }

    public CancelTaskResponse(JSONParser parser)
    {
        while (parser.nextToken() != System.JSONToken.END_OBJECT)
        {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
            {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL)
                {
                    if (text == 'ReturnCode')
                    {
                        ReturnCode = parser.getText();
                    }
                    else if (text == 'Task')
                    {
                        Task = new Task(parser);
                    }
                    else if (text == 'Assignment')
                    {
                        Assignment = parser.readValueAs(Object.class);
                    }
                    else if (text == 'LinkedTasks')
                    {
                        LinkedTasks = parser.readValueAs(Object.class);
                    }
                    else if (text == 'SchedulingError')
                    {
                        SchedulingError = parser.readValueAs(Object.class);
                    }
                    else
                    {
                        System.debug(LoggingLevel.WARN, 'CancelTaskResponse consuming unrecognized property: ' + text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }


    public static CancelTaskResponse parse(String json)
    {
        System.JSONParser parser = System.JSON.createParser(json);
        return new CancelTaskResponse(parser);
    }

    public static void consumeObject(System.JSONParser parser)
    {
        Integer depth = 0;
        do
        {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT ||
                    curr == System.JSONToken.START_ARRAY)
            {
                depth++;
            }
            else if (curr == System.JSONToken.END_OBJECT ||
                    curr == System.JSONToken.END_ARRAY)
            {
                depth--;
            }
        }
        while (depth > 0 && parser.nextToken() != null);
    }


}