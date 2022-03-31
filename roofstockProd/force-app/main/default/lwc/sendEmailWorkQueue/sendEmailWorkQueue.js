import { LightningElement,api,track } from 'lwc';
import investmentAccount from '@salesforce/apex/SendEmailWorkQueue.investmentAccount';
import primaryContact from '@salesforce/apex/SendEmailWorkQueue.primaryContactEmail';
import emailServiceAddress from '@salesforce/apex/EmailMessages.emailServiceAddress';
import fromAddress from '@salesforce/apex/EmailMessages.fromAddress';



export default class SendEmailWorkQueue extends LightningElement {
    @api recordId;
    @track primaryContactEmail;
    @track body;
    @track from;
    @track showEmailForm;
    @track showPrimaryContact;

        connectedCallback(){
            this.showEmailForm = true;
            this.body = 'ref:'+this.recordId;
            investmentAccount({
                recordId:this.recordId
            }).then(data=>{
                primaryContact({
                    investmentAccountId:data
                }).then(data=>{
                    this.primaryContactEmail = data;
                    emailServiceAddress({
                        recordId:this.recordId
                    }).then(data=>{
                        this.emailServiceAddress = data;
                        fromAddress({
                            recordId:this.recordId
                        }).then(data=>{
                            this.from = data;
                        })                       

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