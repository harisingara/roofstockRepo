import { LightningElement,track,wire,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import TRANSACTION_OBJECT from '@salesforce/schema/Certification__c';
import HOACONTACT_FIELD from '@salesforce/schema/Certification__c.HOA_Contact__c';
import SELLERCONTACT_FIELD from '@salesforce/schema/Certification__c.Seller_Contact__c';
import SELLERPMCONTACT_FIELD from '@salesforce/schema/Certification__c.Seller_PM_Contact__c';
import TITLECOMPANYCONTACT_FIELD from '@salesforce/schema/Certification__c.Title_Company_Contact__c';
import RSLISTINGAGENTCONTACT_FIELD from '@salesforce/schema/Certification__c.Roofstock_Listing_Agent_Contact__c';
import INSPECTIONCOMPANYCONTACT_FIELD from '@salesforce/schema/Certification__c.Inspection_Company_Contact__c';

import HOAACCOUNTID_FIELD from '@salesforce/schema/Certification__c.HOA_Contact__r.AccountId';
import SELLERACCOUNTID_FIELD from '@salesforce/schema/Certification__c.Seller_Contact__r.AccountId';
import SELLERPMACCOUNTID_FIELD from '@salesforce/schema/Certification__c.Seller_PM_Contact__r.AccountId';
import TITLECOMPANYACCOUNTID_FIELD from '@salesforce/schema/Certification__c.Title_Company_Contact__r.AccountId';
import RSLISTINGAGENTACCOUNTID_FIELD from '@salesforce/schema/Certification__c.Roofstock_Listing_Agent_Contact__r.AccountId';
import INSPECTIONCOMPANYACCOUNTID_FIELD from '@salesforce/schema/Certification__c.Inspection_Company_Contact__r.AccountId';

import TRANSACTIONRECORDID_FIELD from '@salesforce/schema/Certification__c.Id';


import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

export default class CreateCaseForCertification extends NavigationMixin(LightningElement) {
    @track contactType;

    @track hoaContact;
    @track sellerContact;
    @track sellerPMContact;
    @track titleCompanyContact;
    @track rsListingAgentContact;
    @track inspectionCompanyContact;

    @track hoaAccountId;
    @track sellerAccountId;
    @track sellerPMAccountId;
    @track titleCompanyAccountId;
    @track rsListingAgentAccountId;
    @track inspectionCompanyAccountId;

    @api recordId;
    @api recordTypeId;
    @track certificationRecordId;
    @api recTypeName;
    @track objectInfo;
    @track recTId;
    @track accountId;
    @track conId;

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT})
    objectInfo;
    get options() {
        return [
                    { label: 'HOA', value: 'HOA' },
                    { label: 'Seller', value: 'Seller' },
                    { label: 'Seller PM', value: 'Seller PM' },
                    { label: 'Title Company', value: 'Title Company' },
                    { label: 'Roofstock Listing Agent', value: 'Roofstock Listing Agent' },
                    { label: 'Inspection Company', value: 'Inspection Company' },
                   
                ];
    }

    @wire(getRecord, { recordId: '$recordId', fields: [HOACONTACT_FIELD,SELLERCONTACT_FIELD,SELLERPMCONTACT_FIELD,TITLECOMPANYCONTACT_FIELD,
                                                       RSLISTINGAGENTCONTACT_FIELD,INSPECTIONCOMPANYCONTACT_FIELD,HOAACCOUNTID_FIELD,SELLERACCOUNTID_FIELD,
                                                       SELLERPMACCOUNTID_FIELD,TITLECOMPANYACCOUNTID_FIELD,RSLISTINGAGENTACCOUNTID_FIELD,INSPECTIONCOMPANYACCOUNTID_FIELD] })
    certification(result){
        if(result.data){
            if(result.data.fields.HOA_Contact__c.value!=null ){
                this.hoaContact = result.data.fields.HOA_Contact__c.value;
                this.hoaAccountId = result.data.fields.HOA_Contact__r.value.fields.AccountId!=null?result.data.fields.HOA_Contact__r.value.fields.AccountId.value:null;
                //alert('=this.hoaContact='+this.hoaContact);
                //alert('=this.hoaAccountId='+this.hoaAccountId);
            }
            if(result.data.fields.Seller_Contact__c.value!=null ){
                this.sellerContact = result.data.fields.Seller_Contact__c.value;
                this.sellerAccountId = result.data.fields.Seller_Contact__r.value.fields.AccountId!=null?result.data.fields.Seller_Contact__r.value.fields.AccountId.value:null;
            }
            if(result.data.fields.Seller_PM_Contact__c.value!=null ){
                this.sellerPMContact = result.data.fields.Seller_PM_Contact__c.value;
                this.sellerPMAccountId = result.data.fields.Seller_PM_Contact__r.value.fields.AccountId!=null?result.data.fields.Seller_PM_Contact__r.value.fields.AccountId.value:null;
            }
            if(result.data.fields.Title_Company_Contact__c.value!=null ){
                this.titleCompanyContact = result.data.fields.Title_Company_Contact__c.value;
                this.titleCompanyAccountId = result.data.fields.Title_Company_Contact__r.value.fields.AccountId!=null?result.data.fields.Title_Company_Contact__r.value.fields.AccountId.value:null;
            }
            if(result.data.fields.Roofstock_Listing_Agent_Contact__c.value!=null ){
                this.rsListingAgentContact = result.data.fields.Roofstock_Listing_Agent_Contact__c.value;
                this.rsListingAgentAccountId = result.data.fields.Roofstock_Listing_Agent_Contact__r.value.fields.AccountId!=null?result.data.fields.Roofstock_Listing_Agent_Contact__r.value.fields.AccountId.value:null;
            }
            if(result.data.fields.Inspection_Company_Contact__c.value!=null ){
                this.inspectionCompanyContact = result.data.fields.Inspection_Company_Contact__c.value;
                this.inspectionCompanyAccountId = result.data.fields.Inspection_Company_Contact__r.value.fields.AccountId!=null?result.data.fields.Inspection_Company_Contact__r.value.fields.AccountId.value:null;
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
        this.recTId = this.getRecordTypeId('Certification');
        //alert(this.contactType);
        //alert('recType'+this.recTId);
        if(this.contactType === 'HOA'){
            this.conId = this.hoaContact;
            this.accountId = this.hoaAccountId;
            //alert('accId1'+this.accountId);
        }
        if(this.contactType === 'Seller'){
            this.conId = this.sellerContact;
            this.accountId = this.sellerAccountId;
           // alert('accId1'+this.accountId);
        }
        if(this.contactType === 'Seller PM'){
            this.conId = this.sellerPMContact;
            this.accountId = this.sellerPMAccountId;
            //alert('accId1'+this.accountId);
        }
        if(this.contactType === 'Title Company'){
            this.conId = this.titleCompanyContact;
            this.accountId = this.titleCompanyAccountId;
            //alert('accId1'+this.accountId);
        }
        if(this.contactType === 'Roofstock Listing Agent'){
            this.conId = this.rsListingAgentContact;
            this.accountId = this.rsListingAgentAccountId;
            //alert('accId1'+this.accountId);
        }
        if(this.contactType === 'Inspection Company'){
            this.conId = this.inspectionCompanyContact;
            this.accountId = this.inspectionCompanyAccountId;
            //alert('accId1'+this.accountId);
        }
        const defaultValues = encodeDefaultFieldValues({
            RecordTypeId:this.recTId,
            ContactId:this.conId,
            AccountId:this.accountId,
            Certification__c:this.recordId
           
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