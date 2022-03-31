import { LightningElement,api,track } from 'lwc';
import fromAddress from '@salesforce/apex/EmailMessages.emailServiceAddress';

export default class EmailMessagesLead extends LightningElement {
    @api recordId;
    @track from;
    
    connectedCallback(){
        fromAddress({
            recordId:this.recordId
        }).then(data=>{
            this.from = data;
        })
    }
}