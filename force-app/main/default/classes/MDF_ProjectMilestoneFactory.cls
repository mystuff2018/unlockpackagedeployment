@isTest
public class MDF_ProjectMilestoneFactory {
	private pse__Milestone__c current;

	public MDF_ProjectMilestoneFactory(pse__Milestone__c current){
		this.current = current;
	}

	public static MDF_ProjectMilestoneFactory start() {
		return new MDF_ProjectMilestoneFactory(
            new pse__Milestone__c(
                Name = 'Milestone Test',
                pse__Target_Date__c = System.today(),
                pse__Milestone_Amount__c = 20
        ));
	}
    
    public MDF_ProjectMilestoneFactory project(pse__Proj__c project) {
		current.pse__Project__c = project.Id;
		return this;
	}

	public pse__Milestone__c create() {
		insert current;
		return current;
	}
}