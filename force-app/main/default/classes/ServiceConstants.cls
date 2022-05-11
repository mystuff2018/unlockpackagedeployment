public class ServiceConstants {
    public static final String CASE_STATUS_OPEN = 'Open';

    public static final String CASE_ORIGIN_CHAT = 'Chat';
    public static final String CASE_ORIGIN_EMAIL = 'Email';

    public static final String QUEUE_US_CC_FEd_SUPPORT_Email = 'US_CC_Fed_Support_Email';
    public static final String QUEUE_US_CC_FEd_DISTRESSED_SHIPMENTS_EMAIL = 'US_CC_Fed_Distressed_Shipments_Email';
    public static final String QUEUE_US_COMM_FEDERAL_TS_EMAIL = 'US_Comm_Federal_TS_Email';
    public static final String QUEUE_TS_FEDERAL_DISPATCH_EMAIL = 'TS_Federal_Dispatch_Email';

    public static final String CASE_REASON_CUSTOMER_CARE = 'Customer Care';
    public static final String CASE_REASON_DISTRESSED_SHIPMENTS = 'Distressed Shipments';
    public static final String CASE_REASON_TECHNICAL_SUPPORT = 'Technical Support';
    public static final String CASE_REASON_DISPATCH = 'Dispatch';

    //Siebel SR integration
    public static final String SR_ACTION_TYPE_CHAT = 'Chat';
    public static final String SR_ACTION_TYPE_EMAIL_OUTBOUND = 'Email - Outbound';
    public static final String SR_ACTION_TYPE_EMAIL_INBOUND = 'Email - Inbound';
    public static final String SR_ACTION_TYPE_INBOUND = 'Inbound';
    
    public static final String CASE_NUMBER_TEXT = 'Case Number: ';

    //Siebel sync status
    public static final String EMAIL_MESSAGE_NOT_SYNCED = 'Not synced';
    public static final String EMAIL_MESSAGE_FAILED = 'Failed';
    public static final String EMAIL_MESSAGE_SYNCED_TO_SIEBEL = 'Synced to Siebel';
}