import { LightningElement,api, wire, track } from 'lwc';
import modal from "@salesforce/resourceUrl/bpoCustomModal";
import callBPOServiceButton from '@salesforce/apex/BatchBPOServiceCalloutHelper.callBPOServiceButton';
import fetchPropertyData from '@salesforce/apex/BatchBPOServiceCalloutHelper.fetchPropertyData';
import getBPORequestList from '@salesforce/apex/BatchBPOServiceCalloutHelper.getBPORequestList';
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from "lightning/platformResourceLoader";
import pickListValueDynamically from '@salesforce/apex/BatchBPOServiceCalloutHelper.pickListValueDynamically';

export default class bpoPropertyValuation extends LightningElement {

    @track product;
    @track requiredvar = true;
    @track bpoScreen = false;
    @track headervalue = 'BPO Valuation';
 
    @wire(pickListValueDynamically, {customObjInfo: {'sobjectType' : 'Broker_Price_Opinion__c'},
    selectPicklistApi: 'Product__c'}) selectTargetValues;
    
    

    @api recordId;
    property_2;
    
    pool;
    branchId;
    error;
    LatestBPOValuationAmt;
    LatestBPOValuationDate;
    disable = false;
    calloutSuccess;
    callout =false;
    isLoaded=true;
    message='Please review below values and click yes to trigger BPO Valuation.';
    message1='Please enter the required BPO Order details.';
    messageclass='slds-notify slds-notify_alert slds-alert_warning';

    @track columns = [
    {
        label: 'Reference ID',
        fieldName: 'Reference_ID__c',
        type: 'text',
        sortable: true
    },
    {
        label: 'Order ID',
        fieldName: 'Order_ID__c',
        type: 'text',
        sortable: true
    },
    {
        label: 'Type of BPO Trigger',
        fieldName: 'Type_of_BPO_Trigger__c',
        type: 'text',
        sortable: true
    },
    {
        label: 'Valuation Amount',
        fieldName: 'Valuation_Amount__c',
        type: 'text',
        sortable: true
    },
    {
        label: 'Completion date',
        fieldName: 'Completion_date__c',
        type: 'date',
        sortable: true
    },
    {
        label: 'Inspection Date',
        fieldName: 'Inspection_Date__c',
        type: 'date',
        sortable: true
    },
    {
        label: 'Price Amount',
        fieldName: 'Price_Amount__c',
        type: 'text',
        sortable: true
    },
    {
        label: 'Internal Status',
        fieldName: 'Internal_Status__c',
        type: 'text',
        sortable: true
    },
    {
        label: 'Created Date',
        fieldName: 'CreatedDate',
        type: 'date',
        sortable: true
    }
    ];

    @track error;
    @track bpoReqList ;
    @wire(getBPORequestList, { recordId: '$recordId' })
    wiredAccounts({
        error,
        data
    }) {
        if (data) {
            this.bpoReqList = data;
        } else if (error) {
            this.error = error;
        }
    }

    connectedCallback() {
        loadStyle(this, modal);
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(()=> {
            this.getPropertyData();
        }, 0);
       
    }

    selectProductChangeValue(event){       
        this.product = event.target.value;
    }  
 
    selectPoolChangeValue(event){       
        this.pool = event.target.value;
    }
 
    selectBranchIdChangeValue(event){       
        this.branchId = event.target.value;
    }
    
    getPropertyData(){
        fetchPropertyData({
            recordId:this.recordId
        }).then((data) => {
            if(data){
                this.isLoaded = true;
                this.calloutSuccess = true;
                this.property_2 = data;
                if(typeof data.Client__c == 'undefined'){
                    this.message='This is applicable only to Starwood properties.';
                    this.messageclass='slds-notify slds-notify_alert slds-alert_error';
                }else{
                    var str=data.Client__c.toUpperCase();
                    var sarwoodprop='Project Spartan Capital Group';
                    if(str.indexOf(sarwoodprop.toUpperCase()) === -1 ){
                        this.message='This is applicable only to Starwood properties.';
                        this.messageclass='slds-notify slds-notify_alert slds-alert_error';
                    }else{
                        this.disable = false;
                        this.callout = true;
                        this.LatestBPOValuationAmt = data.Latest_BPO_Valuation_Amount__c;
                        this.LatestBPOValuationDate = data.Latest_BPO_Valuation_Date__c;
                    }
                }
                
            }else{
                this.disable = true;
                this.showNotification('BPO Valuation','Internal error in fetching data!','error');
            }

        });
    }
   
    goToNextScreen(event){
        console.log('I am here');
        this.bpoScreen = true;
        this.calloutSuccess = false;
        this.headervalue = 'BPO Order Details'
    }

    confirmBpoOrder(event){
        if(this.product == null || this.product == ''){
            this.showNotification('BPO Order Details','Please select a value for Product.','error');
        }
        else
        if(this.pool == null || this.pool == ''){
            this.showNotification('BPO Order Details','Please enter a value for Pool.','error');
        }
        else
        if(this.branchId == null || this.branchId == ''){
            this.showNotification('BPO Order Details','Please enter a value for Branch Id.','error');
        }
        else{
            this.callBPOService();
        }
    }

    callBPOService(event){
        this.isLoaded=false; 
        callBPOServiceButton({
            propRecord:this.property_2,
            product:this.product,
            pool:this.pool,
            branchId:this.branchId
        }).then((data) => {
            if(data){
                this.handleCancel(event);
                this.showNotification('BPO Valuation','Order was Placed!','success');
            }
            else{   
                this.handleCancel(event); 
                this.showNotification('BPO Valuation','Internal error Occured!!! Please contact Admin.','error');
            }
        
        }); 
        
    }

    showNotification(_title,message,variant) {
        const evt = new ShowToastEvent({
            title: _title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleCancel(event) {
        // Add your cancel button implementation here
        this.dispatchEvent(new CloseActionScreenEvent());
     }
   }