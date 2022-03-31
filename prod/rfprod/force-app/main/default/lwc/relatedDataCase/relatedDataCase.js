import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getTenant from '@salesforce/apex/CaseRelatedDataController.getTenant';
import getRelationRentalListingLLRU from '@salesforce/apex/CaseRelatedDataController.getRelationRentalListingLLRU';
import getRelationOpportunity from '@salesforce/apex/CaseRelatedDataController.getRelationOpportunity';


import getTenantList from '@salesforce/apex/CaseRelatedDataController.getTenantList';
import getLeaseList from '@salesforce/apex/CaseRelatedDataController.getLeaseList';
import getOpportunityList from '@salesforce/apex/CaseRelatedDataController.getOpportunityList';
import getRentalListingList from '@salesforce/apex/CaseRelatedDataController.getRentalListingList';
import getLeadLeasingRentalUnitList from '@salesforce/apex/CaseRelatedDataController.getLeadLeasingRentalUnitList';


const tenantColumns = [
    {label: 'Related Tenants',fieldName:'recordLink', type: 'url',   
    typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_blank" } },
    {label: 'Email',fieldName:'Email__c', type: 'text'},
    {label: 'Phone',fieldName:'Phone__c', type: 'text'},
    {label: 'Status',fieldName:'Status__c', type: 'text'},
];
const leaseColumns = [
    {label: 'Tenant\'s Leases',fieldName:'recordLink', type: 'url',   
    typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_blank" } },
    {label: 'Start Date',fieldName:'Lease_Start_Date__c', type: 'text'},
    {label: 'End Date',fieldName:'Lease_End_Date__c', type: 'text'},
    {label: 'Lease Signed Date',fieldName:'Lease_Signed_Date__c', type: 'text'},
    {label: 'APPR Status',fieldName:'APPR_Status__c', type: 'text'},
    {label: 'Renewal Step',fieldName:'Renewal_Step__c', type: 'text'},
];
const opportunityColumns = [
    {label: 'Opportunities',fieldName:'recordLink', type: 'url',   
    typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_blank" } },
    {label: 'Stage',fieldName:'StageName', type: 'text'},
    {label: 'Sub Stage',fieldName:'Sub_Stage__c', type: 'text'},
    {label: 'Close Date',fieldName:'CloseDate', type: 'text'},
];


const rentalListingColumns = [
    {label: 'Rental Listings',fieldName:'recordLink', type: 'url',   
    typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_blank" } },
    {label: 'Address',fieldName:'Property_Unit__r.Address', type: 'text'},
    {label: 'Rently Status',fieldName:'Status__c', type: 'text'},
    {label: 'PM Email',fieldName:'PM_Email__c', type: 'text'},
    {label: 'RM Email',fieldName:'RM_Email__c', type: 'text'},
    {label: 'Phone',fieldName:'', type: 'text'},
];

const leadLeasingRentalUnitColumns = [
    {label: 'Lead Leasing Rental Units',fieldName:'recordLink', type: 'url',   
    typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name", target: "_blank" } },
    {label: 'Rental Listing ID',fieldName:'Rental_Listing_Id__c', type: 'text'},
    {label: 'Rental Listing',fieldName:'Rental_Listing__c', type: 'text'},
    {label: 'Lead',fieldName:'Lead__c', type: 'text'},
];

export default class RelatedDataCase extends NavigationMixin(LightningElement) {
    @api recordId;
    @track tenantRecord;
    @track leaseRecord;
    @track opportunityRecord;
    @track rentalListingRecord;
    @track leadLeasingRentalUnitRecord;

    @track opportunityListRecord;
    @track tenantListRecord;
    @track leaseListRecord;
    @track LLRUListRecord;
    @track rentalListingListRecord;
    

    tenantColumns=tenantColumns;
    leaseColumns=leaseColumns;
    opportunityColumns=opportunityColumns;
    rentalListingColumns=rentalListingColumns;
    leadLeasingRentalUnitColumns=leadLeasingRentalUnitColumns;

    tenantName;
    tenantEmail;
    leaseName;
    //propertyUnitName;
    opportunityName;
    rentalListingName;
    leadLeasingRentalUnitName;

    tenantRecordId;
    leaseRecordId;
    propertyUnitRecordId;
    opportunityRecordId;
    rentalListingRecordId;
    leadLeasingRentalUnitRecordId;

    tenantURL;
    leaseURL;
    opportunityURL;
    rentalListingURL;
    LLRUURL;

    activeTab=1;

    tenantOffset = 0;
    loadMoreTenant = true;
    leaseOffset = 0;
    loadMoreLease = true;
    opportunityOffset = 0;
    loadMoreOpportunity = true;
    rentalListingOffset=0;
    loadMoreRentalListing = true;
    LLRUOffset=0;
    loadMoreLLRU = true;

    rowLimit = 25;

    connectedCallback(){
        console.log(this.recordId);
        getTenant({
            caseId: this.recordId
        })
        .then(result => {
            console.log(result);
            console.log(result[0]);
            console.log(result[1]);
            console.log(result[2]);


            this.tenantRecord = result[0];
            this.leaseRecord = result[1];
            this.propertyUnitRecord = result[2];
            
            this.tenantRecordId = this.tenantRecord.Id;
            this.leaseRecordId = this.leaseRecord.Id;
            this.propertyUnitRecordId = this.propertyUnitRecord.Id;

            this.tenantName = this.tenantRecord.Name;
            this.leaseName = this.leaseRecord.Name;
            //this.propertyUnitName = this.propertyUnitRecord.Name;

            getRelationRentalListingLLRU({puId: this.propertyUnitRecordId}).then(resultR1=>{
                console.log(resultR1);
                if(resultR1.length>=1){
                    this.rentalListingRecord = resultR1[0];
                    this.rentalListingRecordId = this.rentalListingRecord.Id;
                    this.rentalListingName = this.rentalListingRecord.Name;
                    this.RentalListingPageRef={
                        type: 'standard__recordPage',
                        attributes: {
                            recordId:this.rentalListingRecordId,
                            objectApiName: 'Rental_Listing__c',
                            actionName: 'view'
                        },
                    };
                    this[NavigationMixin.GenerateUrl](this.RentalListingPageRef)
                    .then(url => this.rentalListingURL = url);
                    this.getRentalListingList();

                    if(resultR1.length == 2){// If leadLeasingRentalUnitRecord exists
                        this.leadLeasingRentalUnitRecord = resultR1[1];
                        this.leadLeasingRentalUnitRecordId = this.leadLeasingRentalUnitRecord.Id;
                        this.leadLeasingRentalUnitName = this.leadLeasingRentalUnitRecord.Name;
    
                        this.LLRUPageRef={
                            type: 'standard__recordPage',
                            attributes: {
                                recordId:this.leadLeasingRentalUnitRecordId,
                                objectApiName: 'Lead_Leasing_Rental_Unit__c',
                                actionName: 'view'
                            },
                        };
                        this[NavigationMixin.GenerateUrl](this.LLRUPageRef)
                        .then(url => this.LLRUURL = url);
    
                        this.getLeadLeasingRentalUnitList();
                    }
                }
            })
            .catch(error => {
                if(error)
                    console.log(error);
    
            });;

            getRelationOpportunity({puId: this.propertyUnitRecordId}).then(resultR2=>{
                if(resultR2.length >0){
                    this.opportunityRecord = resultR2[0];
                    this.opportunityRecordId = this.opportunityRecord.Id;
                    console.log('getRelationOpp'+this.opportunityRecordId);
                    this.opportunityName = this.opportunityRecord.Name;
                    
                    this.OpportunityPageRef={
                        type: 'standard__recordPage',
                        attributes: {
                            recordId:this.rentalListingRecordId,
                            objectApiName: 'Opportunity',
                            actionName: 'view'
                        },
                    };
                    this[NavigationMixin.GenerateUrl](this.OpportunityPageRef)
                    .then(url => this.opportunityURL = url);
                }
            })
            .catch(error => {
                if(error)
                    console.log(error);
    
            });;
            
            this.tenantPageRef={
                type: 'standard__recordPage',
                attributes: {
                    recordId:this.tenantRecordId,
                    objectApiName: 'Tenant__c',
                    actionName: 'view'
                },
            };
            this[NavigationMixin.GenerateUrl](this.tenantPageRef)
            .then(url => this.tenantURL = url);

            this.leasePageRef={
                type: 'standard__recordPage',
                attributes: {
                    recordId:this.leaseRecordId,
                    objectApiName: 'Lease__c',
                    actionName: 'view'
                },
            };
            this[NavigationMixin.GenerateUrl](this.leasePageRef)
            .then(url => this.leaseURL = url);
            
            /*
            this.opportunityPageRef={
                type: 'standard__recordPage',
                attributes: {
                    recordId:this.opportunityUnitRecord.Id,
                    objectApiName: 'Opportunity',
                    actionName: 'view'
                },
            };
            this[NavigationMixin.GenerateUrl](this.opportunityPageRef)
            .then(url => this.opportunityURL = url);*/
            
            
            this.getTenantList();
            this.getLeaseList();
            this.getOpportunityList();
        })
        .catch(error => {
            if(error)
                console.log(error);

        });
    }

    handleActive(event) {
        this.activeTab = event.target.value;
       }

    onClick(event){
        if(event.target.value === 'tenant')
            this[NavigationMixin.Navigate](this.tenantPageRef);
        if(event.target.value === 'lease')
            this[NavigationMixin.Navigate](this.leasePageRef);
    }


    loadMoreTenantData(event){
        if(this.loadMoreTenant){
            //console.log('Load more data');
            this.tenantOffset += 25;
            const { target } = event;
            target.isLoading = true;
            //console.log('is loading');
            this.getTenantListLoadMore().then(()=>{target.isLoading = false; });
        }
    }

    loadMoreLeaseData(event){
        if(this.loadMoreLease){
            //console.log('Load more data');
            this.leaseOffset += 25;
            const { target } = event;
            target.isLoading = true;
            //console.log('is loading');
            this.getLeaseListLoadMore().then(()=>{target.isLoading = false; });
        }  
    }

    loadMoreOpportunityData(event){
        if(this.loadMoreOpportunity){
            //console.log('Load more data');
            this.opportunityOffset += 25;
            const { target } = event;
            target.isLoading = true;
            //console.log('is loading');
            this.getOpportunityListLoadMore().then(()=>{target.isLoading = false; });
        }  
    }
    loadMoreRentalListingData(event){
        if(this.loadMoreRentalListing){
            //console.log('Load more data');
            this.opportunityOffset += 25;
            const { target } = event;
            target.isLoading = true;
            //console.log('is loading');
            this.getRentalListingListLoadMore().then(()=>{target.isLoading = false; });
        }  
    }
    loadMoreLLRUData(event){
        if(this.loadMoreLLRU){
            //console.log('Load more data');
            this.LLRUOffset += 25;
            const { target } = event;
            target.isLoading = true;
            //console.log('is loading');
            this.getLLRUListLoadMore().then(()=>{target.isLoading = false; });
        }  
    } 

    getResults(result){
        var tempRecordList = [];
        //Adds in the relation to facility site if it exists
        for (var i = 0; i < result.length; i++) {
            let tempRecord = Object.assign({}, result[i]); //cloning object  
            tempRecord.recordLink = "/" + tempRecord.Id;
            tempRecordList.push(tempRecord);  
        }
        return tempRecordList;
    }

    getError(error){
        if (Array.isArray(error.body)) {
            this.errorMsg = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            this.errorMsg = error.body.message;
        }
    }


    getTenantList(){
        //Set for loading more
        this.loadMoreTenant = true;
        this.tenantOffset = 0;
        return getTenantList({
            tenantId: this.tenantRecordId,
            leaseId: this.leaseRecordId,
            offset: this.tenantOffset,
            limitSize: this.rowLimit
        })
        .then(result => {
            console.log('Result found' +result.length);
            console.log(result);
            this.tenantListRecord=this.getResults(result);
            this.loadMoreTenant = true;
            if(result.length<25)
                this.loadMoreTenant=false;
        })
        .catch(error => {
            if(error) 
                this.getError(error);
            this.loadMoreTenant = false;
            this.tenantListRecord = null;
        });
    }
    getLeaseList(){
        //Set for loading more
        this.loadMoreLease = true;
        this.leaseOffset = 0;
        return getLeaseList({
            tenantId: this.tenantRecordId,
            offset: this.leaseOffset,
            limitSize: this.rowLimit
        })
        .then(result => {
            console.log('Result found');
            console.log(result);
            this.leaseListRecord=this.getResults(result);
            this.loadMoreLease = true;
            if(result.length<25)
                this.loadMoreLease=false;
        })
        .catch(error => {
            if(error) 
                this.getError(error);
            this.loadMoreLease = false;
            this.leaseListRecord = null;
        });
    }

    getOpportunityList(){
        //Set for loading more
        this.loadMoreOpportunity = true;
        this.opportunityOffset = 0;
        return getOpportunityList({
            puId: this.propertyUnitRecordId,
            offset: this.opportunityOffset,
            limitSize: this.rowLimit
        })
        .then(result => {
            console.log('Result found');
            console.log(result);
            this.opportunityListRecord=this.getResults(result);
            this.loadMoreOpportunity = true;
            if(result.length<25)
                this.loadMoreOpportunity=false;
        })
        .catch(error => {
            if(error) 
                this.getError(error);
            this.loadMoreOpportunity = false;
            this.opportunityListRecord = null;
        });
    }

    getRentalListingList(){
        //Set for loading more
        this.loadMoreRentalListing = true;
        this.rentalListingOffset = 0;
        return getRentalListingList({
            puId: this.propertyUnitRecordId,
            offset: this.rentalListingOffset,
            limitSize: this.rowLimit
        })
        .then(result => {
            console.log('Result found');
            console.log(result);
            this.rentalListingListRecord=this.getResults(result);
            this.loadMoreRentalListing = true;
            if(result.length<25)
                this.loadMoreRentalListing=false;
        })
        .catch(error => {
            if(error) 
                this.getError(error);
            this.loadMoreRentalListing = false;
            this.rentalListingListRecord = null;
        });
    }

    getLeadLeasingRentalUnitList(){
        //Set for loading more
        this.loadMoreLLRU = true;
        this.LLRUOffset = 0;
        return getLeadLeasingRentalUnitList({
            rlId: this.rentalListingRecordId,
            offset: this.LLRUOffset,
            limitSize: this.rowLimit
        })
        .then(result => {
            console.log('Result found');
            console.log(result);
            this.LLRUListRecord=this.getResults(result);
            this.loadMoreLLRU = true;
            if(result.length<25)
                this.loadMoreLLRU=false;
        })
        .catch(error => {
            if(error) 
                this.getError(error);
            this.loadMoreLLRU = false;
            this.LLRUListRecord = null;
        });
    }

    getTenantListLoadMore(){
        return getTenantList({
            tenantId: this.tenantRecordId,
            leaseId: this.leaseRecordId,
            offset: this.tenantOffset,
            limitSize: this.rowLimit
        })
        .then(result => {
            if(this.loadMoreTenant){
                var tempRecordList = this.getResults(result);
                let updatedRecords = [...this.tenantListRecord, ...tempRecordList];
                this.tenantListRecord = updatedRecords;
                console.log(result);
            }
            this.loadMoreTenant = true;
            if(result.length < 25){
                console.log('length is less than 25')
                this.loadMoreTenant = false;
            }
        })
        .catch(error => {
            console.log('error caught');
            console.log(error);
            if(error.body.message != 'No Record Found...'){
                this.getError(error);
                this.tenantListRecord = null;
            }
            this.loadMoreTenant = false;
        });
    }
    
    getLeaseListLoadMore(){
        return getLeaseList({
            tenantId: this.tenantRecordId,
            offset: this.leaseOffset,
            limitSize: this.rowLimit
        })
        .then(result => {
            if(this.loadMoreLease){
                var tempRecordList = this.getResults(result);
                let updatedRecords = [...this.leaseListRecord, ...tempRecordList];
                this.leaseListRecord = updatedRecords;
                console.log(result);
            }
            this.loadMoreLease = true;
            if(result.length < 25){
                console.log('length is less than 25')
                this.loadMoreLease = false;
            }
        })
        .catch(error => {
            console.log('error caught');
            console.log(error);
            if(error.body.message != 'No Record Found...'){
                this.getError(error);
                this.leaseListRecord = null;
            }
            this.loadMoreLease = false;
        });
    }

    getOpportunityListLoadMore(){
        return getOpportunityList({
            puId: this.propertyUnitRecordId,
            offset: this.opportunityOffset,
            limitSize: this.rowLimit
        })
        .then(result => {
            if(this.loadMoreOpportunity){
                var tempRecordList = this.getResults(result);
                let updatedRecords = [...this.opportunityListRecord, ...tempRecordList];
                this.opportunityListRecord = updatedRecords;
                console.log(result);
            }
            this.loadMoreOpportunity = true;
            if(result.length < 25){
                console.log('length is less than 25')
                this.loadMoreOpportunity = false;
            }
        })
        .catch(error => {
            console.log('error caught');
            console.log(error);
            if(error.body.message != 'No Record Found...'){
                this.getError(error);
                this.opportunityListRecord = null;
            }
            this.loadMoreOpportunity = false;
        });
    }

    getRentalListingListLoadMore(){
        return getRentalListingList({
            puId: this.propertyUnitRecordId,
            offset: this.rentalListingOffset,
            limitSize: this.rowLimit
        })
        .then(result => {
            if(this.loadMoreRentalListing){
                var tempRecordList = this.getResults(result);
                let updatedRecords = [...this.rentalListingListRecord, ...tempRecordList];
                this.rentalListingListRecord = updatedRecords;
                console.log(result);
            }
            this.loadMoreRentalListing = true;
            if(result.length < 25){
                console.log('length is less than 25')
                this.loadMoreRentalListing = false;
            }
        })
        .catch(error => {
            console.log('error caught');
            console.log(error);
            if(error.body.message != 'No Record Found...'){
                this.getError(error);
                this.rentalListingListRecord = null;
            }
            this.loadMoreRentalListing = false;
        });
    }
    getLLRUListLoadMore(){
        return getRentalListingList({
            rlId: this.rentalListingRecordId,
            offset: this.rentalListingOffset,
            limitSize: this.rowLimit
        })
        .then(result => {
            if(this.loadMoreLLRU){
                var tempRecordList = this.getResults(result);
                let updatedRecords = [...this.LLRUListRecord, ...tempRecordList];
                this.LLRUListRecord = updatedRecords;
                console.log(result);
            }
            this.loadMoreLLRU = true;
            if(result.length < 25){
                console.log('length is less than 25')
                this.loadMoreLLRU = false;
            }
        })
        .catch(error => {
            console.log('error caught');
            console.log(error);
            if(error.body.message != 'No Record Found...'){
                this.getError(error);
                this.LLRUListRecord = null;
            }
            this.loadMoreLLRU = false;
        });
    }
}