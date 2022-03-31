import { LightningElement,track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import emailTemplates from '@salesforce/apex/GenericEmailNotification.getEmailTempaltes';
import sendEmails from '@salesforce/apex/GenericEmailNotification.sendEmails';


export default class GenericSendEmailNew extends LightningElement {
    @api toEmail;
    @api ccEmail;
    @api subject;
    @api body;
    @api originalBody;
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
    @api primaryContacts;
    @api showPrimaryContact;
    @track isLoading = false;
    @track contentDocumentIds=[];
    @track folders;
    @track emailFolderTemplates;
    @track emailTemplates;
    @track emailtemplateLists=[];
    @track selectedEmailTemplateId;
    @api bccEmail;
    currentRecordId;

    get isPrimary(){
        let showContacts = this.showPrimaryContact === 'true' ? true : false;
        return showContacts;
       }

    connectedCallback(){
        console.log('-toEmail-'+this.toEmail);
        console.log('-parentRecId-'+this.recordId);
        console.log('-bd-'+this.body);
        //emailTemplates
        //let currentRecordId;
        if(this.parentId){
            this.currentRecordId = this.parentId;
        }
        else{
            this.currentRecordId = this.recordId;
        }
        //this.subject = 'ref:'+this.currentRecordId;
        console.log('-currentRecordId-'+this.currentRecordId);
        console.log('-Curr-RecId-'+this.currentRecordId);
        emailTemplates({
            recordId:this.currentRecordId
        }).then(data=>{
            if(data){
                this.emailFolderTemplates = data;
            }
        let options = [];
        for (var key in data) {
	        options.push({ label: data[key].folderName, value: data[key].folderId });
        }
        this.folders = options;

        });

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
        console.log('-bdy-'+this.body);
        this.originalBody = this.body;

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
    let bcc = '';
    let frm  = this.template.querySelector(".from").value;
    let to  = this.template.querySelector(".to").value;
    let cc = this.template.querySelector(".cc").value;
    //let bcc = this.template.querySelector(".bcc").value;
    let subject  = this.template.querySelector(".subject").value;
    let body = this.template.querySelector(".body").value;
    console.log('-subject-'+subject);
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
    //sendEmail({frm:frm,to:to,cc:cc,subject:subject,body:body,forwardBody:this.forwardBody,emailServiceAddress:this.emailServiceAddress,emailType:this.emailType,recordId:this.recordId,files: this.filesUploaded})
    sendEmails({frm:frm,to:to,cc:cc,bcc:bcc,subject:subject,body:body,forwardBody:this.forwardBody,emailServiceAddress:this.emailServiceAddress,emailType:this.emailType,recordId:this.recordId,files: this.contentDocumentIds,selectedEmailTemplateId:this.selectedEmailTemplateId,emailParentId:this.parentId})
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
    fetchPrimaryContactsTo(event){
        let primayCons;
        primayCons= event.detail.primaryContacts;
        var inp=this.template.querySelectorAll("lightning-input");
        inp.forEach(function(element){
            if(element.name=="to")
            {
                if(element.value){
                    this.toEmail=element.value+';'+primayCons;
                    this.toEmail = Array.from(new Set(this.toEmail.split(';'))).toString();
                    this.toEmail  = this.toEmail.replace(/,/g, ';');

                }

            }
            
    },this);
        
    }

    fetchPrimaryContactsCC(event){
        let primayCons;
        primayCons= event.detail.primaryContacts;
        var inp=this.template.querySelectorAll("lightning-input");
        inp.forEach(function(element){
            if(element.name=="cc")
            {
                //alert('-cc-');
                if(element.value){
                    //alert('-val-'+element.value);
                    this.ccEmail=element.value+';'+primayCons;
                    this.ccEmail = Array.from(new Set(this.ccEmail.split(';'))).toString();
                    this.ccEmail  = this.ccEmail.replace(/,/g, ';');
                }
                else{
                    this.ccEmail=primayCons;
                    this.ccEmail = Array.from(new Set(this.ccEmail.split(';'))).toString();
                    this.ccEmail  = this.ccEmail.replace(/,/g, ';');
                }

            }
            
    },this);
        
    }
    handleUploadFinished(event) {
        //alert('-recId-'+this.recordId);
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        let docIds=[];
        for(let i=0;i<uploadedFiles.length;i++){
            docIds.push(uploadedFiles[i].documentId);
        }
        this.contentDocumentIds = this.contentDocumentIds.concat(docIds);
        //alert('--'+this.contentDocumentIds);
        //this.uploadedFileName= uploadedFiles[0].name;
        for(let i=0;i<uploadedFiles.length;i++){
            this.fileNames.push({name:uploadedFiles[i].name});
        }
   }

   onSelectEmailFolder(event){
       var templates;
       var options = [];
    var folderId = event.target.value;
    if (folderId != null && folderId != '' && folderId != 'undefined') {
        this.emailFolderTemplates.forEach(function (element) {
            if (element.folderId == folderId) {
               templates=element.emailtemplatelist;
            }
            
        });

    }
    for (var key in templates) {
        options.push({ label: templates[key].emailTemplatename, value: templates[key].emailTemplateId });
    }
    this.emailTemplates = options;
    this.emailtemplateLists = templates;

   }

   onSelectEmailTemplate(event){
    console.log('-original body-'+this.originalBody);
    let existingEmailBody = this.originalBody;
    this.body = '';
    var emailTempId = event.target.value;
    this.selectedEmailTemplateId = emailTempId;
    var emailbody = '';
    var emailSubject = '';
    if (emailTempId != null && emailTempId != '' && emailTempId != 'undefined') {
        this.emailtemplateLists.forEach(function (element) {
            if (element.emailTemplateId == emailTempId && element.emailbody != null) {
                emailbody = element.emailbody;
                emailSubject = element.emailSubject;
            }
        });
    }
    console.log('=='+this.currentRecordId);
    /*if(typeof(existingEmailBody) == 'undefined'){
        existingEmailBody = 'ref:'+this.currentRecordId;
    }*/
    if(existingEmailBody){
        this.body = emailbody+existingEmailBody;
    }
    else{
        this.body = emailbody;
    }
    this.subject = emailSubject;

   }

}