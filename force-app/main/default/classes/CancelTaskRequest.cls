/**
 * Thomas Davis
 * 2018-11-02
 * FinancialForce.com, Inc.
 * thdavis@financialforce.com
 * 
 * This class mimics the JSON payload expected from Click FSE when calling out to their CancelTask API.
 * An instance of this class is instantiated, serialized, and sent to Click FSE in ServiceAppointmentHandler.cancelClickTask().
 */

public class CancelTaskRequest
{
    public Boolean ReturnAssignment { get; set; }
    /**public Task Task { get; set; }
    public Boolean ReturnSchedulingError { get; set; }
    public List<String> TaskRequestedProperties { get; set; }
    public List<String> AssignmentRequestedProperties { get; set; }

   	public CancelTaskRequest()
    {
        this.Task = new Task();
        this.TaskRequestedProperties = new List<String>();
        this.AssignmentRequestedProperties = new List<String>();
    }

    public class Status
    {
        public String Name { get; set; }

        public Status()
        {

        }
    }

    public class Task
    {
        public String objectType { get; set; }
        public Boolean createOrUpdate { get; set; }
        public String CallID { get; set; }
        public String ExternalRefID { get; set; }
        public Integer Number_Z { get; set; } // in json: Number
        public Status Status { get; set; }

        public Task()
        {
            this.Status = new Status();
        }
    }
**/
}