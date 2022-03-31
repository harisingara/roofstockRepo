import { LightningElement,track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendEmail from '@salesforce/apex/GenericEmailNotification.sendEmail';


export default class GenericSendEmail extends LightningElement {
    @api toEmail;
    @api ccEmail;
    @api bccEmail;
    @api subject;
    @api body;
    @api objectApiName;
    @api existingFiles=[];
    @track fileNames=[];
    @track allFileNames=[];
    @track filesUploaded = [];
    @track uploadedFile = [];
    @track fileName='';
    @track fileSize;
    @api recordId;
    @api parentId;
    @api emailServiceAddress;
    @api emailType;
    @api forwardBody;
    @api from;

    connectedCallback(){
        if(this.existingFiles){
            this.fileNames.push(...this.existingFiles);
        }
        if(this.emailType == 'forward'){
            this.body = '';
            console.log('-body-'+this.body);
            console.log('-forwardbody-'+this.forwardBody);
            console.log('-body-'+this.body);
            console.log('-forwardbody-'+this.forwardBody);
            this.body = this.forwardBody;
            
        }

    }

    handleFileChange(event){
        if (event.target.files.length > 0) {
        this.uploadedFile = event.target.files;
        this.fileName = event.target.files[0].name;
        this.file = this.uploadedFile[0];
        if (this.file.size > this.MAX_FILE_SIZE) {
            const evt = new ShowToastEvent({
                title: "Error!",
                message: "File Size is to long. File size should be less then 5MB",
                variant: "error",
            });
            this.dispatchEvent(evt);
        } else {
        
        //this.fileName = event.target.files[0].name;
        //this.fileNames.push({name:this.fileName});
        
        if (event.target.files.length > 0) {
        let files = [];
        for(var i=0; i< event.target.files.length; i++){
            let file = event.target.files[i];
            let reader = new FileReader();
            reader.onload = e => {
                let base64 = 'base64,';
                let content = reader.result.indexOf(base64) + base64.length;
                let fileContents = reader.result.substring(content);
                this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
                this.fileNames.push({name:file.name});
                console.log('-fname-'+this.fileNames);
                
            };
            reader.readAsDataURL(file);
        }

        
        this.dispatchEvent(
            new ShowToastEvent({
                        title: 'Lead',
                        message: 'File attached Successfully!!',
                        variant: 'success',
                            }),
                    );
        }



        }
        
        }
    }

    /* Send Email */
handleClick(event){
    this.isLoading = true;
    let frm  = this.template.querySelector(".from").value;
    let to  = this.template.querySelector(".to").value;
    let cc = this.template.querySelector(".cc").value;
    let bcc = this.template.querySelector(".bcc").value;
    let subject  = this.template.querySelector(".subject").value;
    let body = this.template.querySelector(".body").value;
    
    if(!to && !body){
    this.isLoading = false;
    const evt = new ShowToastEvent({
        title: "Error!",
        message: "To and Email Body are Mandatory!",
        variant: "error",
    });
    this.dispatchEvent(evt);
    }
    else if(!body){
    this.isLoading = false;
    const evt = new ShowToastEvent({
        title: "Error!",
        message: "Email Body is Mandatory!",
        variant: "error",
    });
    this.dispatchEvent(evt);
    }
    else if(!to){
    this.isLoading = false;
    const evt = new ShowToastEvent({
        title: "Error!",
        message: "To is Mandatory!",
        variant: "error",
    });
    this.dispatchEvent(evt);
    }
    else if(!subject){
        this.isLoading = false;
    const evt = new ShowToastEvent({
        title: "Error!",
        message: "Subject is Mandatory!",
        variant: "error",
    });
    this.dispatchEvent(evt);
    
    }
    else{
        console.log('-current email recId-'+this.currentEmailRecordId);
    sendEmail({frm:frm,to:to,cc:cc,bcc:bcc,subject:subject,body:body,forwardBody:this.forwardBody,emailServiceAddress:this.emailServiceAddress,emailType:this.emailType,recordId:this.recordId,files: this.filesUploaded})
    .then(result => {
        if(result == true){
            this.isLoading = false;
            const evt = new ShowToastEvent({
                title: "Success!",
                message: "Email Sent Successfully!",
                variant: "success",
            });
            this.dispatchEvent(evt);
            const closeQA = new CustomEvent('send');
            // Dispatches the event.
            this.dispatchEvent(closeQA);
    
        }
        else{
            this.isLoading = false;
            const evt = new ShowToastEvent({
                title: "Error!",
                message: "Email failed to send",
                variant: "error",
            });
            this.dispatchEvent(evt);
    
        }
    
    })
    .catch(error => {
        this.isLoading = false;
        this.error = error;
    });
    
    }
    }

    closeQAction(){
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
        
        }

}