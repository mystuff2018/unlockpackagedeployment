import { LightningElement, track,api } from 'lwc';
import getOrders from '@salesforce/apex/OrdersToEngagementController.getOrders';
import getAccountNameByAccountIdMap from '@salesforce/apex/OrdersToEngagementController.getAccountNameByAccountIdMap';

export default class FindOrdersToAssociateToEngagement extends LightningElement {    
    @track orderNumbers;
    @api ordersList;
    @track accountsId = [];
    loading = false;
    errorBool = false;
    errorMessage = '';
    orderNotFound = false;

    
    @api findOrdersByOrderNumbers(){
        var textarea;
        var orderCount;        
        this.errorBool = false;
        this.errorMessage = '';
        this.orderNotFound = false;
        
        textarea = this.template.querySelector('[data-id="txtOrderNumbers"]');              
        if (textarea.value == null){
            this.errorBool = true;
            this.errorMessage = 'Order Number(s) field is required.';
            return;
        }

        this.orderNumbers = textarea.value.replace(/,+/g,",").replace(/(,\s*$)|(^,*)/, "");
        this.orderNumbers = this.orderNumbers.replace(/\s/g,'');       
        orderCount = this.orderNumbers.split(',');
        if (orderCount != null){
            if (orderCount.length > 20){
                this.errorBool = true;
                this.errorMessage = 'The limit is 20 orders at the same time.';
                return;  
            }            
        }                      

        if (!this.orderNumbers) {            
            this.loading = false;          
        }else{
            getOrders({orderNumbers :this.orderNumbers})
            .then(result =>{
                if(result){
                    this.loading = true;
                    this.ordersList = result;
                                    
                    for (var i=0, item; item = this.ordersList[i]; i++) {
                        this.accountsId[i] = item.AccountId;
                    }
                    
                    getAccountNameByAccountIdMap({accountsId : this.accountsId.toString()})
                    .then(results =>{                    
                        if(results){
                            const retrieveAccountNameEvent = new CustomEvent('retrieveaccountname', {detail: results});
                            this.dispatchEvent(retrieveAccountNameEvent);                        
                            const retrieveOrdersEvent = new CustomEvent('retrieveorders', {detail: this.ordersList});
                            this.dispatchEvent(retrieveOrdersEvent);
                            this.loading = false;        
                        }            
                    })
                    .catch(error=>{
                        this.errorBool = true;                        
                        this.errorMessage = 'Error searching for accounts: ' + Object.values(error)[1].exceptionType + '-' +
                        Object.values(error)[1].message + '-' +  Object.values(error)[1].stackTrace;            
                        console.log('error in get accountNameByOrderNumberMap map>>>',error);
                        this.loading = false;           
                    });                
                }else{
                    this.orderNotFound = true;
                    this.loading = false;                    
                }            
            })
            .catch(error=>{
                this.errorBool = true;
                this.errorMessage = 'Error searching for orders: ' + Object.values(error)[1].exceptionType + '-' +
                Object.values(error)[1].message + '-' +  Object.values(error)[1].stackTrace;               
                console.log('error in get orders list>>>',error);
                this.loading = false;          
            });
        }        
    }
    
    disableNotification(event){
        this.orderNotFound = false;    
    }

    disableError(event){
        this.errorBool = false;    
    }
}