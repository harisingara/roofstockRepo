import { LightningElement,api,track } from 'lwc';
import primaryContact from '@salesforce/apex/SendEmailInvestmentAccount.primaryContactEmail';
import emailServiceAddress from '@salesforce/apex/EmailMessages.emailServiceAddress';
import fromAddress from '@salesforce/apex/EmailMessages.fromAddress';

export default class SendEmailInvestmentAccount extends LightningElement {
    @api recordId;
    @track primaryContactEmail;
    @track body;
    @track from;
    @track showEmailForm;
    connectedCallback(){
        this.showEmailForm = true;
        this.body = 'ref:'+this.recordId;
        primaryContact({
            recordId:this.recordId
        }).then(data=>{
            console.log('email-'+data);
            this.primaryContactEmail = data;
                    emailServiceAddress({
                        recordId:this.recordId
                    }).then(data=>{
                        console.log('es-'+data);
                        this.emailServiceAddress = data;
                        fromAddress({
                            recordId:this.recordId
                        }).then(data=>{
                            console.log('from-'+data);
                            this.from = data;
                    })   
                })
        })
    }

    closeModal(){
        //this.dispatchEvent(new CloseActionScreenEvent());
        const closeQA = new CustomEvent('closepopup');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    
    }


}