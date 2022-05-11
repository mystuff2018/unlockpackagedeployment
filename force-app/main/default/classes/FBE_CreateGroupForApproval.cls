/**************
* @ClassName    : FBE_CreateGroupForApproval
* @Queable Class       : FBE_CreateGroupForApproval
* @Description   : This class is called from Handler=FBE_DealReg_ApproveDealsHandler. In this class,we create a dynamic queue with EU and FSI Account Team members
* @CreatedBy     : DeLL Team
* @CreatedOn     : 12-13-2019 [Soumithri Rekha, Sai]
***************/
public without sharing class FBE_CreateGroupForApproval implements Queueable{
    Id dealId;
    List<id> euUserID;
    List<id> aposUserID;
    String queueName;
    List<Id> aEManagerId;
	List<Id> fsiuserId;
    List<String> varDistiActIds; 
    public FBE_CreateGroupForApproval(Id dIds, List<ID> euUsID, List<Id> fsiId,List<ID> aposUsID,string qName ,List<Id> aEMgrId, List<String> vardistiActs){
        this.dealId = dIds;
        this.euUserID = euUsID;
        this.aposUserID = aposUsID;
        this.queueName = qName;
        this.aEManagerId = aEMgrId;
        this.varDistiActIds = vardistiActs;
		if(fsiId != NULL){
			this.fsiuserId = fsiId;
		}
    }
    public void execute(QueueableContext context) {
        Group eug;
        Group aposg;
		Group fsig;
        string objectIs = dealId.getSObjectType().getDescribe().getName();
        if( euUserID != null && euUserID.size()>0){
            if(objectIs == 'Deal_Registration__c'){
                eug = new Group(Type='Queue', Name='EU Team- '+queueName);
            insert eug;
            }else{
                eug = new Group(Type='Queue', Name='EU Extn Team- '+queueName);
            insert eug;
            }
            
            List<GroupMember> insertMemberList = new List<GroupMember>();
            for(Id i : euUserID){
                GroupMember member = new GroupMember();
                member.UserOrGroupId = i;
                member.GroupId = eug.id;
                insertMemberList.add(member);
            }
            if(insertMemberList != NULL && insertMemberList.size()>0){
                insert insertMemberList;   
            }
        }
        
        if(Test.isRunningTest()){
            this.fsiuserId = new List<Id>{userinfo.getUserId()};
        }
		if( (fsiuserId != null && fsiuserId.size()>0)){
            if(objectIs == 'Deal_Registration__c'){
            fsig = new Group(Type='Queue', Name='FSI Team- '+queueName);
            insert fsig;
            }
            else{
                fsig = new Group(Type='Queue', Name='FSI Extn Team- '+queueName);
            insert fsig;
            }
            List<GroupMember> insertMemberList = new List<GroupMember>();
            for(Id i : fsiuserId){
                GroupMember member = new GroupMember();
                member.UserOrGroupId = i;
                member.GroupId = fsig.id;
                insertMemberList.add(member);
            }
            if(insertMemberList != NULL && insertMemberList.size()>0){
                insert insertMemberList;   
            }
        }
        
      /*  if(aposUserID != null && aposUserID.size()>0){
            aposg = new Group(Type='Queue', Name='Apos Team- '+queueName);
            insert aposg; 
            List<GroupMember> insertMemberList = new List<GroupMember>();
            for(Id i : aposUserID){
                GroupMember member = new GroupMember();
                member.UserOrGroupId = i;
                member.GroupId = aposg.id;
                insertMemberList.add(member);
            }
            if(insertMemberList != NULL && insertMemberList.size()>0){
                insert insertMemberList; 
            }
        }*/
        if(!Test.isRunningTest()){
        System.enqueueJob(new FBE_CreateQueueForApproval(dealId,eug,fsig,aposg,aEManagerId,aposUserID,varDistiActIds));
        }
    }
}