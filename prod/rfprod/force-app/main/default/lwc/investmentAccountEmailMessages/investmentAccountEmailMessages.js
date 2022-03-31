import { LightningElement,track,api } from 'lwc';
import taskEmails from '@salesforce/apex/EmailMessagesInvestmentAccount.taskEmails';
//import emailBodyAttachment from '@salesforce/apex/EmailMessagesInvestmentAccount.emailBodyAttachment';
import emailBodyAttachment from '@salesforce/apex/EmailMessages.emailBodyAttachment';
import fwdEmails from '@salesforce/apex/EmailMessages.forwardEmails';
import fetchEmailServiceAddress from '@salesforce/apex/EmailMessages.emailServiceAddress';


import emailBody from '@salesforce/apex/EmailMessagesInvestmentAccount.emailBody';

export default class InvestmentAccountEmailMessages extends LightningElement {
    @api recordId;
    @track page = 1; //this will initialize 1st page
    @track items = []; //it contains all the records.
    @track taskItems = [];
    @track taskObject=false;;
    @track data = []; //data to be displayed in the table
    @track columns; //holds column info.
    @track startingRecord = 1; //start record position per page
    @track endingRecord = 0; //end record position per page
    @track pageSize = 5; //default value we are assigning
    @track totalRecountCount = 0; //total record count received from all retrieved records
    @track totalPage = 0; //total number of page is needed to display all records
    @api objectApiName;
   // @track taskMessages;
   @track showbody = false;
   @track showNotify = false;
   @track replyAll = false;
   @track forward = false;
   @track reply = false;
   @track emailBdy;
   @track isLoading = false;
   @track errorMessage;
   @track noEmails = false;
   @track showPagination = false;
   @track from;
   @track to;
   @track cc;
   @track subject;
   @track fileNames=[];
   @track forwardBody;
   @track body;
   @track emailServiceAddress;

   @track message = "Displaying" +this.startingRecord +"to"+ this.endingRecord+"of"+this.totalRecountCount+"records.Page"+this.page+"of"+this.totalPage;
    connectedCallback(){
        if(this.objectApiName == 'ATF_Work_Queue__c'){
            //alert('WQ');
            this.taskObject = true;
        }
        console.log('--'+this.taskObject);
        taskEmails({
            recordId:this.recordId
        }).then(data=>{
            if(data.length > 0){

                console.log('=data='+data);
               
                if(this.taskObject == true){
                    
                    
                   if(data[0]){
                        this.items = data[0].subjectEmailWrapList;
                        //alert('-this.items-'+JSON.stringify(this.items));
                        if(this.items.length>5){
                            this.showPagination = true;
                        }
                        this.data = this.items.slice(0,this.pageSize);
                   }
                    console.log('-data-'+this.data);
                }
                else{
                    this.items = data;
                    if(this.items.length>5){
                        this.showPagination = true;
                    }

                    this.data = this.items.slice(0,this.pageSize); 
                    
                }

                this.totalRecountCount = data.length; //here it is 23
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5
            
           
           // this.data = this.items.slice(0,this.pageSize); 
            this.endingRecord = this.pageSize;

            this.error = undefined;
        } else{
            this.noEmails = true;
            this.errorMessage = 'No Emails Found';
            
        
            }

        });
        fetchEmailServiceAddress({
            recordId:this.recordId
        }).then(data=>{
            console.log('-data-'+data);
            this.emailServiceAddress = data;
        })
    }

    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }             
    }

    //this method displays records page by page
    displayRecordPerPage(page){

        /*let's say for 2nd page, it will be => "Displaying 6 to 10 of 23 records. Page 2 of 5"
        page = 2; pageSize = 5; startingRecord = 5, endingRecord = 10
        so, slice(5,10) will give 5th to 9th records.
        */
        this.startingRecord = ((page -1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 
        
        this.data = this.items.slice(this.startingRecord, this.endingRecord);

        //increment by 1 to display the startingRecord count, 
        //so for 2nd page, it will show "Displaying 6 to 10 of 23 records. Page 2 of 5"
        this.startingRecord = this.startingRecord + 1;
    }
    
    openEmailBody(event){
        let emailRecId = event.target.id;
        let recId = emailRecId.split('-')[0];
        console.log('-recId-'+recId);
        this.currentEmailRecordId = recId;
        this.isLoading = true;

        emailBodyAttachment({emailRecId:recId})
        .then((data) => {
            var fromAddress;
            if (data) {
                this.emailBodyAttachments = data;
				this.showbody = true;
				//alert('-data-'+JSON.stringify(result));
				console.log('-data-'+JSON.stringify(data));
                console.log('-status-'+data.status);
            if(data.status === '3'){
                fromAddress = this.emailServiceAddress;
                //fromAddress = 'one@roofstock.com';
                console.log('-frm-'+fromAddress);
            }
            else{
                fromAddress = data.frm;
                console.log('-from-'+data.fromName);
            }

            var msgDate = new Date( Date.parse(data.messageDate));
                let localDate= msgDate.toLocaleString();

                var oriMessage = "--------------- Original Message ---------------";
                while(data.body.indexOf(oriMessage) != '-1')
                data.body = data.body.replace(oriMessage,"");
                this.body = '<br/><br/>--------------- Original Message ---------------<br/>From:'+data.fromName+'&lt'+fromAddress+'&gt'+'<br/>'+'Date:'+localDate+'<br/>'+'To:'+data.to+'<br/>'+data.body+'<br/>';


                var fwdMessage = "--------------- Forwarded Message ---------------";
                while(data.body.indexOf(fwdMessage) != '-1')
                data.body = data.body.replace(fwdMessage,"");
                this.forwardBody = '<br/><br/>--------------- Forwarded Message ---------------<br/>From:'+data.fromName+'&lt'+fromAddress+'&gt'+'<br/>'+'Date:'+localDate+'<br/>'+'To:'+data.to+'<br/>'+data.body+'<br/>';
            
            
            
                this.to = fromAddress;
            //this.body = data.body;
            console.log('-body-'+this.body);
            this.subject = data.subject;
            this.cc = data.cc;
            console.log('-from-'+this.from);
            if(!this.from){
                //this.from = this.emailServiceAddress;
                this.from = 'one@roofstock.com';
            }
            

            this.showbody = true;

            //alert('-data-'+JSON.stringify(data));
            console.log('-data-'+JSON.stringify(data));
            this.forwardedFiles(recId);
			}
			
       /* emailBody({emailRecId:recId})
        .then((result) => {
            this.emailBdy = result.HtmlBody;
            this.isLoading = false;

		})*/
		})
		
		

        
    

    }
    forwardedFiles(recId){
        console.log('-em id-'+recId);
        fwdEmails({
            recordId:recId
        }).then(result=>{
            console.log('data'+JSON.stringify(result));
            console.log('files'+JSON.stringify(result));
            for(let l=0;l<result.length;l++){
                this.fileNames.push({name:result[l].fileName});
            }
            
    
        });

    
}


    parsemsg(html){

    var tempDivElement = document.createElement("div");
    // Set the HTML content with the given value
    tempDivElement.innerHTML = html;
    // Retrieve the text property of the element 
    return tempDivElement.textContent || tempDivElement.innerText || "";

    }

    handleReply(event){
        this.showNotify = true;
        this.replyAll = false;
        this.forward = false;
        this.reply = true;

    }
    handleReplyAll(event){
        this.showNotify = true;
        this.replyAll = true;
        this.forward = false;
        this.reply = false;
    }

    handleForward(event){
        this.showNotify = true;
        this.replyAll = false;
        this.forward = true;
        this.reply = false;

    }
    
    closeViewBody(){
        this.showbody = false;
    }
    closeModal(){
        this.showNotify = false;
    }
    closeQA(){
        this.showNotify = false;
        this.showbody = false;
    }

}