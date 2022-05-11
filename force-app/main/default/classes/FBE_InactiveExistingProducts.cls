/**************
*@ Class Name                                                    : FBE_InactiveExistingProducts
*@ Description                                                   : This class is written to inactivate all the existing products.
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 03-31-2020 [Lavakumar Tonupunuri]
*@ Modification Log                                              : 
***************/ 
public with sharing class FBE_InactiveExistingProducts implements Database.Batchable<product2>,Database.Stateful {
    public list<String> productsCsv;
	public ID parentId;
	public List<Product2> productsToInactive;
    public Map<String,Id> prodLobWithId;
    public FBE_InactiveExistingProducts (List<product2> productsToInactive,List<string> productsCsv,ID parentId,Map<string,ID> prodLobWithId){
        this.productsCsv = productsCsv;
		this.parentId = parentId;
		this.productsToInactive = productsToInactive;
        this.prodLobWithId = prodLobWithId;
    }
    public Iterable<product2> start(Database.BatchableContext BC) {
        return productsToInactive;
    }
    public void execute(Database.BatchableContext info, List<product2> productsToUpdate) {
        system.debug('productsToUpdate '+productsToUpdate);
		system.debug('HEAP SIZE 1 '+Limits.getHeapSize() );
		if(productsToUpdate.size() > 0){
            system.debug('productsToUpdate  '+productsToUpdate.size());
            system.debug('productsToUpdate  '+productsToUpdate);
			Database.UPDATE(productsToUpdate);
		}
		system.debug('HEAP SIZE 2 '+Limits.getHeapSize() );
        
    }

    public void finish(Database.BatchableContext info) {
        system.debug('productsCsv   finish '+productsCsv.size());
		Id jobId = Database.executeBatch(new FBE_ProductsProcess(productsCsv,parentId,prodLobWithId), 1000);
	}
}