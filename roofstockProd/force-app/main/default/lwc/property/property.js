import { LightningElement, track, api, wire } from 'lwc';

import getPropertyDetails from '@salesforce/apex/TransactionDetails.getPropertyDetails';
import getContactName from '@salesforce/apex/TransactionDetails.getContactName';
import { NavigationMixin } from 'lightning/navigation';

export default class Property extends NavigationMixin(LightningElement) {

    @api objectApiName;

    @api recordId;
    @api isshowpath = false;
    @track propertydetailsList = [];

    pactiveSections = ['property section'];
    ProperyURL = '/';
    columns = [
        { label: 'Address', fieldName: 'Name' },
        { label: 'Beds', fieldName: 'Bedrooms__c' },
        { label: 'Baths', fieldName: 'Bathrooms__c' },
        { label: 'Sq Feet', fieldName: 'Square_Feet__c' },
        { label: 'Inspected Bedrooms', fieldName: 'Inspected_Bedrooms__c' },
        { label: 'Inspected Bathrooms', fieldName: 'Inspected_Bathrooms__c' },
        { label: 'Occupancy', fieldName: 'Occupancy_at_Closing__c' },
        { label: 'Monthly Rent', fieldName: 'Monthly_Rent__c', type: 'currency' },
        { label: 'Lease Start', fieldName: 'Lease_Start__c', type: 'date' },
        { label: 'Lease End', fieldName: 'Lease_End__c', type: 'date' },
        { label: 'Move Out Date', fieldName: 'Move_Out_Date__c' }

    ];
    refreshTheTransactionView() {
        eval("$A.get('e.force:refreshView').fire();");
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Transaction__c',
                actionName: 'view'
            },
        });
    }

    isContractQC = false;
    sellerAgent='';
    connectedCallback() {
        this.getPropertyDetails();

    }
    propertyUnitList = [];

    getPropertyDetails() {
        getPropertyDetails({ recordId: this.recordId }).then(result => {
            if (result != undefined && result.length > 0) {
                this.propertydetailsList = result;
                this.ProperyURL += this.propertydetailsList[0].Id;
                 getContactName({contactId:this.propertydetailsList[0].Seller_Agent__c}).then(results => {                    
                    if (results != undefined && results.length > 0) {
                        this.sellerAgent=results;                       
                    }
                 })
                this.isshowpath = true;
                this.propertyUnitList = result[0].Property_Units__r;

            }
       })
    }

}