import { LightningElement,track,wire,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import TRANSACTION_OBJECT from '@salesforce/schema/Transaction__c';
import BUYER1CONTACT_FIELD from '@salesforce/schema/Transaction__c.Buyer_Contact1__c';
import BUYER2CONTACT_FIELD from '@salesforce/schema/Transaction__c.Buyer_Contact2__c';
import SELLERCONTACT_FIELD from '@salesforce/schema/Transaction__c.Seller_Contact__c';
import INSPECTORCONTACT_FIELD from '@salesforce/schema/Transaction__c.Inspector_Contact__c';
import ESCROWCONTACT_FIELD from '@salesforce/schema/Transaction__c.Escrow_Contact__c';
import TITLECONTACT_FIELD from '@salesforce/schema/Transaction__c.Title_Contact__c';
import INSURANCECONTACT_FIELD from '@salesforce/schema/Transaction__c.Insurance_Contact__c';
import RSPROJEACTMANAGERCONTACT_FIELD from '@salesforce/schema/Transaction__c.Roofstock_Project_Manager__c';
import BUYERBROKERCONTACT_FIELD from '@salesforce/schema/Transaction__c.Buyer_Broker_Contact__c';
import SELLERBROKERCONTACT_FIELD from '@salesforce/schema/Transaction__c.Seller_Broker_Contact__c';

import BUYER1ACCOUNTID_FIELD from '@salesforce/schema/Transaction__c.Buyer_Contact1__r.AccountId';
import BUYER2ACCOUNTID_FIELD from '@salesforce/schema/Transaction__c.Buyer_Contact2__r.AccountId';
import SELLERACCOUNTID_FIELD from '@salesforce/schema/Transaction__c.Seller_Contact__r.AccountId';
import INSPECTORACCOUNTID_FIELD from '@salesforce/schema/Transaction__c.Inspector_Contact__r.AccountId';
import ESCROWACCOUNTID_FIELD from '@salesforce/schema/Transaction__c.Escrow_Contact__r.AccountId';
import TITLEACCOUNTID_FIELD from '@salesforce/schema/Transaction__c.Title_Contact__r.AccountId';
import INSURNCEACCOUNTID_FIELD from '@salesforce/schema/Transaction__c.Insurance_Contact__r.AccountId';
import RSPROJECTMANAGERACCOUNTID_FIELD from '@salesforce/schema/Transaction__c.Roofstock_Project_Manager__r.AccountId';
import BUYERBROKERACCOUNTID_FIELD from '@salesforce/schema/Transaction__c.Buyer_Broker_Contact__r.AccountId';
import SELLERBROKERACCOUNTID_FIELD from '@salesforce/schema/Transaction__c.Seller_Broker_Contact__r.AccountId';


import TRANSACTIONRECORDID_FIELD from '@salesforce/schema/Transaction__c.Id';


import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

export default class CreateCaseForTransaction extends NavigationMixin(LightningElement) {
    
@track contactType;
@track buyer1Contact;
@track buyer2Contact;
@track seller;
@track inspector;
@track escrow;
@track title;
@track insurance;
@track projectManager;
@track buyerBroker;
@track sellerBroker;

@track buyer1AccountId;
@track buyer2AccountId;
@track sellerAccountId;
@track inspectorAccountId;
@track escrowAccountId;
@track titleAccountId;
@track insuranceAccountId;
@track projectManagerAccountId;
@track buyerBrokerAccountId;
@track sellerBrokerAccountId;

@api recordId;
@api recordTypeId;
@track transactionRecordId;
@api recTypeName;
@track objectInfo;
@track recTId;
@track accountId;
@track conId;

@wire(getObjectInfo, { objectApiName: CASE_OBJECT})
objectInfo;

get options() {
    return [
                { label: 'Buyer1', value: 'Buyer1' },
                { label: 'Buyer2', value: 'Buyer2' },
                { label: 'Seller', value: 'Seller' },
                { label: 'Inspector', value: 'Inspector' },
                { label: 'Escrow', value: 'Escrow' },
                { label: 'Title', value: 'Title' },
                { label: 'Insurance', value: 'Insurance' },
                { label: 'Project Manager', value: 'Project Manager' },
                { label: 'Buyer Broker', value: 'Buyer Broker' },
                { label: 'Seller Broker', value: 'Seller Broker' },
            ];
}
@wire(getRecord, { recordId: '$recordId', fields: [BUYER1CONTACT_FIELD,BUYER2CONTACT_FIELD,SELLERCONTACT_FIELD,
                                                   INSPECTORCONTACT_FIELD,ESCROWCONTACT_FIELD,TITLECONTACT_FIELD,SELLERBROKERCONTACT_FIELD,
                                                   INSURANCECONTACT_FIELD,RSPROJEACTMANAGERCONTACT_FIELD,BUYERBROKERCONTACT_FIELD,
                                                   TRANSACTIONRECORDID_FIELD,SELLERACCOUNTID_FIELD,
                                                   BUYER1ACCOUNTID_FIELD,BUYER2ACCOUNTID_FIELD,INSPECTORACCOUNTID_FIELD,ESCROWACCOUNTID_FIELD,
                                                   TITLEACCOUNTID_FIELD,INSURNCEACCOUNTID_FIELD,RSPROJECTMANAGERACCOUNTID_FIELD,
                                                   BUYERBROKERACCOUNTID_FIELD,SELLERBROKERACCOUNTID_FIELD] })
transaction(result){
    if(result.data){
       // alert('=buyer contact='+JSON.stringify(result.data.fields.Buyer_Contact1__c));
        if(result.data.fields.Buyer_Contact1__c.value!=null ){
            //alert('1');
            this.buyer1Contact = result.data.fields.Buyer_Contact1__c.value;
            this.buyer1AccountId = result.data.fields.Buyer_Contact1__r.value.fields.AccountId!=null?result.data.fields.Buyer_Contact1__r.value.fields.AccountId.value:null;
        }
        if(result.data.fields.Buyer_Contact2__c.value!=null){
            //alert('2');
            this.buyer2Contact = result.data.fields.Buyer_Contact2__c.value;
            this.buyer2AccountId = result.data.fields.Buyer_Contact2__r.value.fields.AccountId!=null?result.data.fields.Buyer_Contact2__r.value.fields.AccountId.value:null;
        }
        if(result.data.fields.Seller_Contact__c.value!=null){
            //alert('3');
            this.seller = result.data.fields.Seller_Contact__c.value;
            this.sellerAccountId = result.data.fields.Seller_Contact__r.value.fields.AccountId!=null?result.data.fields.Seller_Contact__r.value.fields.AccountId.value:null;
        }
        if(result.data.fields.Inspector_Contact__c.value!=null){
            //alert('4');
            this.inspector = result.data.fields.Inspector_Contact__c.value;
            //alert('=inspector=');
            this.inspectorAccountId = result.data.fields.Inspector_Contact__r.value.fields.AccountId!=null?result.data.fields.Inspector_Contact__r.value.fields.AccountId.value:null;
            //alert('4->Pass');
        }
        if(result.data.fields.Escrow_Contact__c.value!=null){
            //alert('5');
            this.escrow = result.data.fields.Escrow_Contact__c.value;
            this.escrowAccountId = result.data.fields.Escrow_Contact__r.value.fields.AccountId!=null?result.data.fields.Escrow_Contact__r.value.fields.AccountId.value:null;
        }
        if(result.data.fields.Title_Contact__c.value!=null){
            //alert('6');
            this.title = result.data.fields.Title_Contact__c.value;
            this.titleAccountId = result.data.fields.Title_Contact__r.value.fields.AccountId!=null?result.data.fields.Title_Contact__r.value.fields.AccountId.value:null;
        }
        if(result.data.fields.Insurance_Contact__c.value!=null){
            //alert('7');
            this.insurance = result.data.fields.Insurance_Contact__c.value;
            this.insuranceAccountId = result.data.fields.Insurance_Contact__r.value.fields.AccountId!=null?result.data.fields.Insurance_Contact__r.value.fields.AccountId.value:null;
        }
        if(result.data.fields.Roofstock_Project_Manager__c.value!=null){
            //alert('8');
            this.projectManager = result.data.fields.Roofstock_Project_Manager__c.value;
            this.projectManagerAccountId = result.data.fields.Roofstock_Project_Manager__r.value.fields.AccountId!=null?result.data.fields.Roofstock_Project_Manager__r.value.fields.AccountId.value:null;
        }
        if(result.data.fields.Buyer_Broker_Contact__c.value!=null){
            //alert('9');
            this.buyerBroker = result.data.fields.Buyer_Broker_Contact__c.value;
            this.buyerBrokerAccountId = result.data.fields.Buyer_Broker_Contact__r.value.fields.AccountId!=null?result.data.fields.Buyer_Broker_Contact__r.value.fields.AccountId.value:null;
        }
        if(result.data.fields.Seller_Broker_Contact__c.value!=null){
            //alert('10');
            this.sellerBroker = result.data.fields.Seller_Broker_Contact__c.value;
            this.sellerBrokerAccountId = result.data.fields.Seller_Broker_Contact__r.value.fields.AccountId!=null?result.data.fields.Seller_Broker_Contact__r.value.fields.AccountId.value:null;
        }
        
    }

}

handleChange(event) {
    this.contactType = event.detail.value;
    }

getRecordTypeId(recordTypeName) {
    let recordtypeinfo = this.objectInfo.data.recordTypeInfos;
    let recordTypeId;
    for(var eachRecordtype in  recordtypeinfo)
    {
        // alert('-rt2-'+recordtypeinfo[eachRecordtype].name);
        if(recordtypeinfo[eachRecordtype].name===recordTypeName){
            recordTypeId = recordtypeinfo[eachRecordtype].recordTypeId;
            break;
        }
    }   
    console.log('returning -   ' + recordTypeId); 
    //alert('rec type'+recordTypeId);     
    return recordTypeId;  
}  

createContact() {
    this.recTId = this.getRecordTypeId('Transaction');
    //alert(this.contactType);
    //alert('recType'+this.recTId);
    if(this.contactType === 'Buyer1'){
        this.conId = this.buyer1Contact;
        this.accountId = this.buyer1AccountId;
       // alert('accId1'+this.accountId);
    }
    if(this.contactType === 'Buyer2'){
        this.conId = this.buyer2Contact;
        this.accountId = this.buyer2AccountId;
        //alert('accId2'+this.accountId);
    }
    if(this.contactType === 'Seller'){
        this.conId = this.seller;
        this.accountId = this.sellerAccountId;
    }
    if(this.contactType === 'Inspector'){
        this.conId = this.inspector;
        this.accountId = this.inspectorAccountId;
    }
    if(this.contactType === 'Escrow'){
        this.conId = this.escrow;
        this.accountId = this.escrowAccountId;
    }
    if(this.contactType === 'Title'){
        this.conId = this.title;
        this.accountId = this.titleAccountId;
    }
    if(this.contactType === 'Insurance'){
        this.conId = this.insurance;
        this.accountId = this.insuranceAccountId;
    }
    if(this.contactType === 'projectManager'){
        this.conId = this.projectManager;
        this.accountId = this.projectManagerAccountId;
    }
    if(this.contactType === 'buyerBroker'){
        this.conId = this.buyerBroker;
        this.accountId = this.buyerBrokerAccountId;
    }
    if(this.contactType === 'Seller Broker'){
        this.conId = this.sellerBroker;
        this.accountId = this.sellerBrokerAccountId;
    }
    const defaultValues = encodeDefaultFieldValues({
        RecordTypeId:this.recTId,
        ContactId:this.conId,
        AccountId:this.accountId,
        Transaction__c:this.recordId
       
    });
    this[NavigationMixin.Navigate]({

        type: 'standard__objectPage',
        attributes: {
            objectApiName: 'Case',
            actionName: 'new'                
        },
        state : {
            nooverride: '1',
            recordTypeId: this.recTId,
            defaultFieldValues:defaultValues
        }
    });

}

}