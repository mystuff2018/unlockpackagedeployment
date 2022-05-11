/****************************************************************************************************
 * Author         : Dell Team - CPQ [Ravi Sirigiri - STORY 11263048]
 * Description    : Federal Partner Self Service Quote :  View Quote related list. 
 * Date Created   : 03-Nov-2021
 * Version        : 1.0
 * Modification Log    Developer       Last Modified Date   Description
 * 1.0                 Ravi Sirigiri   03-Nov-2021
 *                     Ravi Sirigiri   08-Dec-2021         Defect 11647229 : FBE:DEV Defect :CPQ : Mismatch of Background colour of QUOTE(S) Button on Opty page in SFDC FPRM Portal
 * 
 * ***************************************************************************************************/

import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import FBE_FPRM_Partner_Full_URL from '@salesforce/label/c.FBE_FPRM_Partner_Full_URL';

import getQuoteData from '@salesforce/apex/FBE_CPQ_OptyRelatedListController.getQuoteData';

export default class FBE_CPQ_OpptyQuoteRelatedList extends NavigationMixin (LightningElement) {
    @api recordId;
    @api strTitle;
    @api isShowOpty = false;
    @api IsHideComponent = false;
    @api isportalUser = false;
    @api userType;

    connectedCallback() {        
        //console.log('recordId for quote:::',this.recordId);
        this.isPortalUser = (this.userType) ? this.userType === 'Community' : false;
         
        //console.log(this.userType,'isPortalUser:::',this.isPortalUser);
        this.isShowOpty = (this.recordId && this.recordId.startsWith("006")) ? true : false;
    }
    
    
    quoteDataList;
    @wire(getQuoteData, { opptyId: '$recordId' })
    wiredQuotedata( { error, data } ){
        if(error){
            console.log('Quote data error ::::', error);
        }
        else if(data){
            var dataList = JSON.parse(JSON.stringify(data));
            if(dataList){
                dataList.forEach(currentItem => {
                        //console.log('currentItem:::',currentItem.files);
                        if(currentItem && currentItem.quoteRec.ExpirationDate){
                            currentItem.quoteRec.ExpirationDate = this.getFormattedDate(currentItem.quoteRec.ExpirationDate);
                        }
                        if(currentItem && currentItem.quoteRec.FBE_CPQ_Quote_Total__c){
                           currentItem.quoteRec.FBE_CPQ_Quote_Total__c  = new Intl.NumberFormat('en-US',  { style: 'currency', currency: 'USD' }).format(currentItem.quoteRec.FBE_CPQ_Quote_Total__c)
                        }
                });                
            }           

            if(this.isShowOpty && dataList.length > 0){
                this.isShowOpty = dataList[0].isShowComponent;
                this.IsHideComponent = true;
            }
            //console.log('this.isShowOpty :::::', this.isShowOpty);
            //console.log('this.IsHideComponent :::::', this.IsHideComponent);
           var title = 'Quotes';
            if(dataList.length>3)
            {
                this.strTitle = title + ' (3+) ';
                this.quoteDataList = dataList.slice(0, 3);
            }
            else{
                this.strTitle = title + '('+ dataList.length +')';
                this.quoteDataList = dataList;
            } 
            
        }
    }

    getFormattedDate(dateValue) {   
       // console.log('dateValue::',dateValue);
        var date = new Date(dateValue);   
        var dd = String(date.getDate()).padStart(2, '0');
        var mm = String(date.getMonth() + 1).padStart(2, '0');
        var yyyy = date.getFullYear();
        return mm + "-" + dd + "-" + yyyy;
    }

    handleMenuItem(event) 
    {
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
    viewQuote (event)
    {
        var optyReturnId = event.target.dataset.recordId
        console.log('Quote Rec id nav::'+event.target.dataset.recordId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: optyReturnId,
                objectApiName: 'Quote',
                actionName: 'view'
            },
        });
    }

    handleNavigation(event)
    {
        
        event.preventDefault();
        // Navigate to a URL        
        if(this.isPortalUser){
            console.log('log Navigation for portal::');
            this.viewAllNavigationExternalUsers();
        }else{
            console.log('log Navigation for Internal::');
            this.viewAllNavigationInternalUsers();
        }         
       
    }

    viewAllNavigationExternalUsers(){
        
        this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/quoteviewall-page?recordId='+this.recordId
                }
            },
            false //Replaces the current page in your browser history with the URL
        );
    }
    viewAllNavigationInternalUsers(){
        var compDefinition = {
            componentDef: "c:fBE_CPQ_QuoteChild",
            attributes: {
                recordId : this.recordId
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
    }
    
}