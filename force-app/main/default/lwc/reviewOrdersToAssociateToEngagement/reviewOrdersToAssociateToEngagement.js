import { LightningElement, api } from 'lwc';
import associateOrdersToEngagement from '@salesforce/apex/OrdersToEngagementController.associateOrdersToEngagement';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ReviewOrdersToAssociateToEngagement extends LightningElement {
    @api orderListToReview;
    @api recordId;
    loading = false;
    
    gridColumns = [
        {
            type: 'text',
            fieldName: 'OrderNumber__c',
            label: 'Order Number',
            initialWidth: 130,
        },
        {
            type: 'text',
            fieldName: 'Status',
            label: 'Order Status',
            initialWidth: 120,
        },
        {
            type: 'text',
            fieldName: 'BUID__c',
            label: 'BUID',
            initialWidth: 80,
        },
        {
            type: 'text',
            fieldName: 'AccountName',
            label: 'Account Name',
            initialWidth: 200,
        },
        {
            type: 'text',
            fieldName: 'LineItems',
            label: 'Line Items',
            initialWidth: 107,
        },
        {
            type: 'text',
            fieldName: 'TotalAmount',
            label: 'Order Amount',
            initialWidth: 148,
        }
    ];

    gridData=[];
    ordersId=[];

    connectedCallback(){
        var i;
        var item;
        var orders;
        var ordersObject;
        
        ordersObject = Object.values(this.orderListToReview);
        for (i=0, item; i < ordersObject.length; i++) {
            item = ordersObject[i];            
            orders = {
                OrderNumber__c: item.OrderNumber__c,
                BUID__c:item.BUID__c,
                Status:item.Status,
                AccountName:item.AccountName,
                LineItems:item.LineItems,
                TotalAmount:item.TotalAmount,
                OrderUrl: item.OrderUrl
            };
            this.gridData[i] = orders;
            this.ordersId[i] = item.Id;            
        }
    }

    @api
    handleAssociateOrders(){        
        associateOrdersToEngagement({ordersId :this.ordersId, engagementId: this.recordId})
        .catch(error=>{            
            console.log('error in associate orders >>>',error);         
        });
    }
}