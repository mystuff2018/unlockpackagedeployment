import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AssociateOrdersToEngagement extends LightningElement {
    @api loading = false;
    @api ordersList;
    @api accountNameByOrderIdMap;
    @api selectedOrdersList;
    @api recordId;
    ordersLength = 0;

    isFindStep = true;
    isSelectStep = false;
    isReviewStep = false;
    
    
    handleOrderSearch(){        
        this.template.querySelector("c-find-orders-to-associate-to-engagement").findOrdersByOrderNumbers();
    }

    handleOrdersRetrieve(event){
        this.orderList = event.detail;      
        this.isFindStep = false;
        this.isSelectStep = true;    
    }

    handleAccountNameRetrieve(event){
        this.accountNameByOrderIdMap = event.detail;        
    }

    handleRetrieveSelectedOrders(event){
        this.ordersLength = 0;
        this.selectedOrdersList = event.detail;        
        this.ordersLength = Object.values(this.selectedOrdersList).length;

        this.isSelectStep = false;
        this.isReviewStep = true;            
    }

    handleOrderSelection(){
        this.template.querySelector("c-select-orders-to-associate-to-engagement").handleOrderSelection();
    }

    handleAssociateOrders(){        
        this.template.querySelector("c-review-orders-to-associate-to-engagement").handleAssociateOrders();        
        const evt = new ShowToastEvent({
            title: 'Order association was successful',
            message: this.ordersLength + ' order(s) was associated.',
            variant: 'success',
        });
        this.dispatchEvent(evt);

        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }

    handleCancel(){
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }    
}