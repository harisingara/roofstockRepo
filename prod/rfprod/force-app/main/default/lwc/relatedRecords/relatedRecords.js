import { LightningElement,wire,track,api} from 'lwc';
import fetchAssoictedRecords from "@salesforce/apex/ContactController.fetchAllAssoictedRecords"; 
import { refreshApex } from '@salesforce/apex';

var COLSTransaction = [  
    {  
     label: "Name",  
     fieldName: "recordLink",  
     type: "url",  
     typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_blank" },
     hideDefaultActions: "true" 
    },  
    { label: "Status", fieldName: "Transaction_Status__c", type: "text",hideDefaultActions: "true"},
    { label: "Start Date", fieldName: "Start_Date__c", type: "text",hideDefaultActions: "true" },
    { label: "Est. Close Date", fieldName: "Est_Close_Date__c", type: "text",hideDefaultActions: "true" },
    { label: "List Price", fieldName: "List_Price__c", type: "text",hideDefaultActions: "true" }   
   ];

var COLSCertification = [  
    {  
     label: "Name",  
     fieldName: "recordLink",  
     type: "url",  
     typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_blank" },
     hideDefaultActions: "true"  
    },  
    { label: "Status", fieldName: "Certification_Status__c", type: "text",hideDefaultActions: "true" },
    { label: "Start Date", fieldName: "Certification_Start_Date__c", type: "text",hideDefaultActions: "true" },
    { label: "List Price", fieldName: "List_Price__c", type: "text",hideDefaultActions: "true" }
   ];

 

export default class RelatedRecords extends LightningElement {
    @api recordId;
    @api objectApiName;  
    error;  
    @track recList = [];
    @track strTitle;
    @track recCount;
    @api Transaction;
    @api Certification;
    @track contextObject;
    @track wiredRecordList = [];
    colmns=[];
    
    @api
    get cols() {
        if(this.Transaction === true){
            this.contextObject = 'Transaction';
            return  COLSTransaction;

        }
        if(this.Certification === true){
            this.contextObject = 'Certification';
            return COLSCertification;            
        }
    }

    @api
    get Title() {
        if(this.Transaction === true){
            return 'Transactions';               
        }
        if(this.Certification === true){
            return 'Certifications';            
        }
    }

   

    @wire(fetchAssoictedRecords,{
        recordId:'$recordId',
        objectType:'$contextObject'
       
    })getRecList({ error, data }) {  
        this.wiredRecordList = data;
     if (data) {  
      var tempRecList = [];  
      for (var i = 0; i < data.length; i++) {  
       let tempRecord = Object.assign({}, data[i]); //cloning object  
       tempRecord.recordLink = "/" + tempRecord.Id;  
       tempRecList.push(tempRecord);  
      }  
      this.recList = tempRecList;
      this.contextObject =  this.contextObject +' '+ '('+this.recList.length+')';
      refreshApex(this.wiredRecordList);
      this.error = undefined;
     } else if (error) {  
      this.error = error;  
      this.recList = undefined;  
     }  
    }  
   }