import {LightningElement,api,track} from 'lwc';
import getTransaction from '@salesforce/apex/InspectionHelper.associatedTransactionToInspection';

export default class ShowTransactionDataInInspection extends LightningElement {
    @api recordId;
    @track transaction;
    @api open;
    @api label;
    get sectionClass() {
        return this.open ? 'slds-section slds-is-open' : 'slds-section';
    }
    connectedCallback(){
        if (typeof this.open === 'undefined') this.open = true;
        //alert('=recordId='+JSON.stringify(this.recordId));
        getTransaction({recordId:this.recordId})
        .then(result=>{
            //alert('=result='+JSON.stringify(result));
            this.transaction = result;
        })
    }
    handleClick() {
        //alert('=open='+this.open);
        this.open = !this.open;
    }
}