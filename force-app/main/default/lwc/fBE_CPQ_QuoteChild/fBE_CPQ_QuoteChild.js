import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import NAME_FIELD from "@salesforce/schema/Opportunity.Name";
import FBE_FPRM_Partner_Full_URL from '@salesforce/label/c.FBE_FPRM_Partner_Full_URL';
const fields = [NAME_FIELD];
import getQuoteData from '@salesforce/apex/FBE_CPQ_OptyRelatedListController.getQuoteData';

export default class FBE_CPQ_QuoteChild extends NavigationMixin(LightningElement) {
    @api recordId;
    @api strTitle;
    @api isShowOpty = false;
    @api count;

    isportalUser = false;

    @api userType;

    tableClass = '';

    @wire(getRecord, {
        recordId: "$recordId",
        fields
    })
    opportunity;

    get name() {
        return getFieldValue(this.opportunity.data, NAME_FIELD);
    }
    connectedCallback() {
        this.strTitle = 'Quotes';
        //console.log('recordId for quote:::', this.recordId);
        this.isShowOpty = this.recordId ? this.recordId.startsWith("006") ? true : false : false;
        this.isPortalUser = (this.userType) ? this.userType === 'Community' : false;
        this.tableClass = this.isPortalUser ? 'tableFixHead' : '';
       // console.log(this.userType,'isPortalUser:::',this.isPortalUser);
    }
    quoteDataList;
    @wire(getQuoteData, { opptyId: '$recordId' })
    wiredQuotedata({ error, data }) {
        if (error) {
            console.log('Quote data error ::::', error);
        }
        else if (data) {
            var dataList = JSON.parse(JSON.stringify(data));
           // console.log('dataList>>> ',dataList);
            if (dataList) {
                dataList.forEach(currentItem => {                    
                    //console.log('currentItem:::', currentItem);
                    if (currentItem && currentItem.quoteRec.ExpirationDate) {
                        currentItem.quoteRec.ExpirationDate = this.getFormattedDate(currentItem.quoteRec.ExpirationDate);
                    }
                    if (currentItem && currentItem.quoteRec.FBE_CPQ_Quote_Total__c) {
                        currentItem.quoteRec.FBE_CPQ_Quote_Total__c = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(currentItem.quoteRec.FBE_CPQ_Quote_Total__c)
                    }
                });
            }
            this.quoteDataList = dataList;
            //console.log('Quote data :::::', data);
            this.count = dataList.length;
            this.strTitle = this.strTitle + '(' + dataList.length + ')';
            if (this.isShowOpty && dataList.length > 0) {
                this.isShowOpty = dataList[0].isShowComponent;
            }
        }
    }

    getFormattedDate(dateValue) {
       // console.log('dateValue::', dateValue);
        var date = new Date(dateValue);
        var dd = String(date.getDate()).padStart(2, '0');
        var mm = String(date.getMonth() + 1).padStart(2, '0');
        var yyyy = date.getFullYear();
        return mm + "-" + dd + "-" + yyyy;
    }
    
    handleMenuItem(event) {       
       console.log(event.currentTarget.dataset.recid+': Event Details:: '+event.detail.value);      
       let currentDocId = event.detail.value;
       var downloadurl = '';
       if(this.isPortalUser){
           downloadurl =  `${FBE_FPRM_Partner_Full_URL}/sfc/servlet.shepherd/document/download/${currentDocId}`;
       }else{
           downloadurl = `/sfc/servlet.shepherd/document/download/${currentDocId}`;
       } 
       this.returnId =  window.open(downloadurl);
    }
    viewQuote(event) {
        var optyReturnId = event.target.dataset.recordId
        this.gotoRecord(optyReturnId, 'Quote');
    }
    navigateToParent() {
        this.gotoRecord(this.recordId, 'Opportunity');

    }
    gotoRecord(recId, objectName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                objectApiName: objectName,
                actionName: 'view'
            },
        });
    }
}