import { LightningElement,wire,track,api } from 'lwc';
import emailServiceAddress from '@salesforce/apex/EmailMessages.emailServiceAddress';

export default class SendEmailOpportunity extends LightningElement {
@api recordId;
@track body;
@track emailServiceAddress;
@track from;

connectedCallback(){
    
    emailServiceAddress({
        recordId:this.recordId
        }).then(data=>{
            console.log('-data-'+data);
            this.emailServiceAddress = data;
            this.from = data;
            this.body = 'ref:'+this.recordId;
        })

}
closeModal(){
    //this.dispatchEvent(new CloseActionScreenEvent());
    const closeQA = new CustomEvent('closepopup');
    // Dispatches the event.
    this.dispatchEvent(closeQA);

}
}