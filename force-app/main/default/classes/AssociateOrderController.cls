public with sharing class AssociateOrderController {
    private ApexPages.StandardSetController setCon;
    public List<Order> selectedOrders { get;set; }

    public AssociateOrderController(ApexPages.StandardSetController controller)
    {
        setCon = controller;
  
        selectedOrders = (List<Order>) setCon.getSelected();
    }
    
    public List<Order> getOrders()
    {
        return (List<Order>) setCon.getRecords();
    }
    
}