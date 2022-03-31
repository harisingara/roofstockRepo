import { LightningElement,track,wire,api } from 'lwc';
import retrieveFeedback from '@salesforce/apex/RentlyComments.retrieveFeedback';
import { NavigationMixin } from 'lightning/navigation';

const columns = [
    { label: 'Feedback', fieldName: 'HasFeedback__c',type:'boolean'}     
];
let i=0;

export default class RentlyComments extends NavigationMixin(LightningElement) {

    cols = columns;  
        @api recordId;   
        @track page = 1;
        @track items = [];
        @track feedbackdata = [];
        @track columns;
        @track startingRecord = 1; //start record position per page
        @track endingRecord = 0; //end record position per page
        @track pageSize = 10; //default value we are assigning
        @track totalRecountCount = 0; //total record count received from all retrieved records
        @track totalPage = 0; //total number of page is needed to display all records
        @wire(retrieveFeedback,{listingId:'$recordId'})
        wiredFeedbacks({ error, data }) {
            if (data) {
                this.items = data;
                this.totalRecountCount = data.length; //here it is 23
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5
                
                //initial data to be displayed ----------->
                //slice will take 0th element and ends with 5, but it doesn't include 5th element
                //so 0 to 4th rows will be displayed in the table
                this.feedbackdata = this.items.slice(0,this.pageSize); 
                console.log('=data='+JSON.stringify(this.feedbackdata));
                //alert('=data='+JSON.stringify(this.feedbackdata));
                this.endingRecord = this.pageSize;
                //this.cols = columns;
    
                this.error = undefined;
            } else if (error) {
                this.error = error;
                this.feedbackdata = undefined;
            }
        }

        //Navigate To Record Page
        navigateToRecordPage(event){
            console.log('Value = ' + event.currentTarget.dataset.value);
            this[NavigationMixin.GenerateUrl]({
                type:'standard__recordPage',
                attributes:{
                    recordId:event.currentTarget.dataset.value,
                    objectApiName:'Opportunity',
                    actionName:'view'
                }
            }).then(url => {
                window.open(url, "_blank");
            });

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
            this.startingRecord = ((page -1) * this.pageSize) ;
            this.endingRecord = (this.pageSize * page);
    
            this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                                ? this.totalRecountCount : this.endingRecord; 
    
            this.feedbackdata = this.items.slice(this.startingRecord, this.endingRecord);
    
            //increment by 1 to display the startingRecord count, 
            //so for 2nd page, it will show "Displaying 6 to 10 of 23 records. Page 2 of 5"
            this.startingRecord = this.startingRecord + 1;
        }    
}