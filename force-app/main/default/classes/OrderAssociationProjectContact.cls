/*
 * @test OrderAssociationProjectContactTest
 * @authors Pablo Dunke and Tiago Ferreira
 * @date 02/05/2020
 * 
 * @modified Pablo Dunke and Marcelo Acioli
 * @date 03/16/2020
 */

public class OrderAssociationProjectContact {
    
    public static void populateProjectContacts(OrderAssociationDataContext context) {

        for(Id forProjectId: context.projectWithOrdersMap.keySet()) {
            pse__Proj__c project = context.projectMap.get(forProjectId);

            Set<Id> setOrder = context.projectWithOrdersMap.get(forProjectId);

            Map<Id, Boolean> mapContactIsPrimary = new Map<Id, Boolean>();
            for(Id forOrderId: setOrder) {
                Order order = context.orderMap.get(forOrderId);

                List<Project_Contact__c> listProjectContact = context.projectIdProjectContactMap.get(forProjectId);

                if(listProjectContact == null || listProjectContact.isEmpty()) {
                    if(order.Install_At_Contact__c != null && !mapContactIsPrimary.containsKey(order.Install_At_Contact__c)) {
                        mapContactIsPrimary.put(order.Install_At_Contact__c, true);
                    }

                    if(order.Direct_Contact__c != null && !mapContactIsPrimary.containsKey(order.Direct_Contact__c)) {
                        mapContactIsPrimary.put(order.Direct_Contact__c, false);
                    }

                    if(order.BillToContactId != null && !mapContactIsPrimary.containsKey(order.BillToContactId)) {
                        mapContactIsPrimary.put(order.BillToContactId, false);
                    }

                    if(order.ShipToContactId != null && !mapContactIsPrimary.containsKey(order.ShipToContactId)) {
                        mapContactIsPrimary.put(order.ShipToContactId, false);
                    }
                }
            }

            for(Id forContactId: mapContactIsPrimary.keySet()){
                Project_Contact__c projectContact = createProjectContact(project.Id, forContactId, mapContactIsPrimary.get(forContactId));
                context.newProjectContact.add(projectContact);
            }
        }
        system.debug('context.newProjectContact '+context.newProjectContact);
    }

    public static Project_Contact__c createProjectContact(Id projectId, Id contactId, Boolean primaryContact) {
        Project_Contact__c projectContact = new Project_Contact__c();
        projectContact.Project__c = projectId;
        projectContact.Contact__c = contactId;
        projectContact.Contact_Role__c = 'End User';
        projectContact.Contact_Type__c = 'Customer';
        projectContact.Primary_Contact__c = primaryContact;
        return projectContact;
    }
}