import { LightningElement,wire,track,api} from 'lwc';
import leadDetails from '@salesforce/apex/SendEmailLead.leadDetails';
import emailServiceAddress from '@salesforce/apex/EmailMessages.emailServiceAddress';
import { CloseActionScreenEvent } from 'lightning/actions';



export default class SendEmailLead extends LightningElement {

@api recordId;
@track leadEmail;
@track body;
@track emailServiceAddress;
@track from;

connectedCallback(){
    leadDetails({
        recordId:this.recordId
    }).then(data=>{
        console.log('-data-'+data);
        this.leadEmail = data.Email;
        this.body = 'ref:'+this.recordId;


    });
    emailServiceAddress({
        recordId:this.recordId
    }).then(data=>{
            if(data){
                this.emailServiceAddress = data;
                this.from = data;
            }

    });

}
closeModal(){
    //this.dispatchEvent(new CloseActionScreenEvent());
    const closeQA = new CustomEvent('closepopup');
    // Dispatches the event.
    this.dispatchEvent(closeQA);

}

}