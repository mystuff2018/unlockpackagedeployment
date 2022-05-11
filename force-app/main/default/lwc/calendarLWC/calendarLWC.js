import {LightningElement, wire, track} from 'lwc';
import getWrapperClassList from '@salesforce/apex/DisplayServapptResAbsCntrl.getWrapperClassList'
import { NavigationMixin } from 'lightning/navigation';

export default class calendarLWC extends NavigationMixin(LightningElement) {
    @track wrapList = [];
    
    @wire(getWrapperClassList) wrapperList;
    debugger;

    viewRecord(event) {
        // Navigate to Account record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.currentTarget.dataset.value,
                "objectApiName": "ServiceAppointment",
                "actionName": "view"
            },
        });
    }

    viewRARecord(event) {
        // Navigate to Account record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.currentTarget.dataset.value,
                "objectApiName": "ResourceAbsence",
                "actionName": "view"
            },
        });
    }

    navigateToObjectHome() {
        // Navigate to the Account home page
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Event',
                actionName: 'home',
            },
        });
    }
}