import {LightningElement,api,track} from 'lwc';
import getDiligence from '@salesforce/apex/InspectionHelper.associatedInspection';
export default class DiligenceSection extends LightningElement {
    @api recordId;
    @track diligence;
    @api open;
    @api label;
    get sectionClass() {
        return this.open ? 'slds-section slds-is-open' : 'slds-section';
    }
    connectedCallback(){
        if (typeof this.open === 'undefined') this.open = true;
        //alert('=recordId='+JSON.stringify(this.recordId));
        getDiligence({recordId:this.recordId})
        .then(result=>{
            //alert('=result='+JSON.stringify(result));
            this.diligence = result;
        })
    }
    handleClick() {
        //alert('=open='+this.open);
        this.open = !this.open;
    }
}