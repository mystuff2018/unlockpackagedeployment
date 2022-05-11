/**
 * @File Name          : OrderDisassociationResourceSkillRequest.cls
 * @Description        : Call the ResourceRequestSkillAutomator to recalculate the resource skill request for 
 *                       the resource request in the order item desassociation context
 * @Author             : Leonardo Santos & Elson Paim
**/
public class OrderDisassociationResourceSkillRequest {
    /**
    * @description recalculate the resource skill request to the resource request tied to the project after desassociation
    * @author Leonardo Santos & Elson Paim | 5/25/2020
    * @return void
    **/
    public static void updateResourceSkillRequest(OrderDisassociationDataContext context) {

        ResourceRequestSkillAutomator.recalculateResourceSkillRequest(context.projectMap, context.skillsSKUByProjectId);
        
    }
}