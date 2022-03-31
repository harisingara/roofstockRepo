import { LightningElement,api,track,wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import TRANSACTION_OBJECT from '@salesforce/schema/Transaction__c';
import TRANSACTIONID_FIELD from '@salesforce/schema/Transaction__c.Transaction_Id__c';
import PORTFOLIOID_FIELD from '@salesforce/schema/Transaction__c.Portfolio_Transaction_Id__c';

import customMetadataId from '@salesforce/apex/BPMTransactionHelper.customMetadata';
import currentTransaction from '@salesforce/apex/BPMTransactionHelper.transactionRecord';

export default class BPMSection extends LightningElement {
    //Tracking Attribute Values
    @api iframeUrl;
    @api width;
    @api height;
    @api scrolling;
    @api frameBorder;
    @api styles;
    @api sandbox;
    @api cardName;
    @api objectApiName;
    /** Id of record to display. */
    @api recordId;
   // @track hasRendered = true;
    /* Load Transaction__c.Transaction_Id__c for custom rendering */
    /*
    @wire(getRecord, { recordId: '$recordId', fields: [TRANSACTIONID_FIELD,PORTFOLIOID_FIELD] })
    transaction(result){
      if(result.data){
        //console.log('==Rec Type Name=='+result.data.recordTypeInfo.name);
        let transactionId = result.data.fields.Transaction_Id__c.value;
        let portfolioTransactionId = result.data.fields.Portfolio_Transaction_Id__c.value;
        if(result.data.recordTypeInfo!=null){
          if(result.data.recordTypeInfo.name == 'Transaction'){
            this.iframeUrl = "https://staging-bpm.roofstock.com/RsAdmin/transactions/details";
            this.iframeUrl = this.iframeUrl+'/'+transactionId;
          }
          else if(result.data.recordTypeInfo.name == 'Portfolio Transaction'){
            this.iframeUrl = "https://bpm.roofstock.com/RsAdmin/PortfolioTransactions/details";
            this.iframeUrl = this.iframeUrl+'/'+portfolioTransactionId;
          }
        } 
         // this.iframeUrl = this.iframeUrl.substring(0, this.iframeUrl.lastIndexOf('/'));
          
          //alert('=iframe url='+this.iframeUrl);
          console.log('iframe value'+ this.iframeUrl); 
      }
      else if(result.error)
      {
        //something went wrong
      }
    }*/
    
    connectedCallback(){
      //if(this.hasRendered){
      var url;
      customMetadataId().then(result => {
        //alert('hey');
        this.url = result;
        currentTransaction({
          currentRecId: this.recordId 
        }).then(data => {
          if(data && data.RecordType){
            console.log('data'+JSON.stringify(data));
            if(data.RecordType.Name === 'Transaction'){
              if(typeof data.Transaction_Id__c != 'undefined'){
                let transactionId = data.Transaction_Id__c;
                this.iframeUrl = this.url+'/RsAdmin/transactions/details/'+transactionId;
              }
              else{
                this.iframeUrl = this.url+'/RsAdmin/transactions/details/null';
              }
            }
            if(data.RecordType.Name === 'Portfolio Transaction'){
              if(typeof data.Portfolio_Transaction_Id__c != 'undefined'){
                console.log('inside helo');
                let portfolioTransactionId = data.Portfolio_Transaction_Id__c;
                this.iframeUrl = this.url+'/RsAdmin/PortfolioTransactions/details/'+portfolioTransactionId;

              }
              else{
               
                this.iframeUrl = this.url+'/RsAdmin/PortfolioTransactions/details/null';


              }
            }
          }
          else this.iframeUrl = this.url+'/RsAdmin/transactions/details/null';
        })

      })
      
    //}
    //this.hasRendered = false;
  }

}