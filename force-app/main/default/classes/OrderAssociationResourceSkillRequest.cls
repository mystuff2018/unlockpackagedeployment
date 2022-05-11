/**
 * @File Name          : OrderAssociationResourceSkillRequest.cls
 * @Description        : Create the resource skill request for the resource request in the order item association context
 * @Author             : Magaiver Oliveira
**/
public class OrderAssociationResourceSkillRequest {

    /**
    * @description create an resource skill request to the resource request tied to the project
    * @author Magaiver Oliveira | 2/20/2020 
    * @return void
    **/
    public static void updateResourceSkillRequest(OrderAssociationDataContext context) {

        ResourceRequestSkillAutomator.recalculateResourceSkillRequest(context.projectMap, context.skillsFromProject);
        
    }
}