/****************************************************************************************************
 * Author         : Dell Team - CPQ [Sireesha Myla- STORY 11510028]
 * Description    : Ability to view the Attachments. 
 * Date Created   : 13-Nov-2021
 * Version        : 1.0
 * Modification Log           Developer          Last Modified Date           Description
 * 1.0                        Sireesha Myla      23-Nov-2021                  STORY-11510028
 ****************************************************************************************************/
import { LightningElement, api,track, wire } from 'lwc';
import FBE_FPRM_Partner_Full_URL from '@salesforce/label/c.FBE_FPRM_Partner_Full_URL';
import getQuoteFilesData from '@salesforce/apex/FBE_CPQ_OptyRelatedListController.getQuoteFilesData';

export default class FBE_CPQ_QuoteHeader extends LightningElement 
{
    @api recordId; 
    @api userType;
    isOnlyQuote;
    isportalUser = false;

    @track quoteData;
    returnId;
    connectedCallback() {
      console.log('recordId:::',this.recordId);
      this.isPortalUser = (this.userType) ? this.userType === 'Community' : false;
      console.log('this.isPortalUser:::',this.isPortalUser);
     }
   
  @wire(getQuoteFilesData, {
        quoteId: "$recordId"
      })
    wiredQuotedata( { error, data } ){
        if(error){
            console.log('Quote data error ::::', error);
        }
        else if(data){
          this.isOnlyQuote = this.recordId ? this.recordId.startsWith("0Q0") ? true : false : false;
           // this.quoteDataList = data;
            console.log('Quote data :::::', data);          
            this.quoteData = data;
            
        }
    }

    handleMenuItem(event) 
    {
      console.log(': Event Details:: '+event.detail.value);      
       let currentDocId = event.detail.value;
       //var downloadurl = `${FBE_FPRM_Partner_Full_URL}/sfc/servlet.shepherd/document/download/${currentDocId}`;
       var downloadurl = '';
       if(this.isPortalUser){
           downloadurl =  `${FBE_FPRM_Partner_Full_URL}/sfc/servlet.shepherd/document/download/${currentDocId}`;
       }else{
           downloadurl = `/sfc/servlet.shepherd/document/download/${currentDocId}`;
       } 
     
       this.returnId =  window.open(downloadurl);
       //this.returnId = window.open(`/sfc/servlet.shepherd/document/download/${currentDocId}`);
    }

}