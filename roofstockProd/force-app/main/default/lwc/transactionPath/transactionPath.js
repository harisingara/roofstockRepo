import { LightningElement, track, api, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/ldsUtils';

import TIME_ZONE from '@salesforce/i18n/timeZone';

// Transaction Details Apex Functions
import getRequiredValues from '@salesforce/apex/TransactionDetails.getRequiredValues';
import getMilestonePicklistValues from '@salesforce/apex/TransactionDetails.getMilestonePicklistValues';
import getPropertyDetails from '@salesforce/apex/TransactionDetails.getPropertyDetails';
import senddata from '@salesforce/apex/TransactionDetails.senddata';
import saveTask from '@salesforce/apex/TransactionDetails.saveTask';

// Contract QC Controller Apex Functions
import getContractQCData from '@salesforce/apex/ContractQCController.getContractQCData';
import getAccountListByRecordType from '@salesforce/apex/ContractQCController.getAccountListByRecordType';
import updateTask from '@salesforce/apex/ContractQCController.updateTask';
import updateTransactionContact from '@salesforce/apex/ContractQCController.updateTransactionContact';
import upsertTransactionSettlement from '@salesforce/apex/ContractQCController.upsertTransactionSettlement';
import getRecordTypeId from '@salesforce/apex/ContractQCController.getRecordTypeId';
import publishPlatformEvent from '@salesforce/apex/ContractQCController.publishPlatformEvent';

// Review Checklist Apex Functions
import upsertTransactionSnapshot from '@salesforce/apex/ReviewChecklistController.upsertTransactionSnapshot';

import propertyUnitObj from '@salesforce/schema/Property_Unit__c';
import transactionObj from '@salesforce/schema/Transaction__c';
import taskObj from '@salesforce/schema/Task';

export default class PathPro extends NavigationMixin(LightningElement) {
    timeZone = TIME_ZONE;
    @track transactionMilesoneStatusValues = [];
    @track statusToShow = [];
    @track currentpath = 'New Transaction';
    @track propertydetailsList = [];
    
    @api objectApiName;
    @api recordId;
    
    contactFilterByAccountId = '';

    milestoneObjectFields = '';
    tempPath = '';
    activeSections = ['Transaction Details', 'Transaction Dates', 'EMD', 'Inspection_Details', 'Email_Communication', 'Files', 'Contract_Review', 'System_Information']; //to display section expanded
    pactiveSections = ['property section']; //to display section expanded
    selectedStage = '';
    
    @track optionFeeStatusValues;
    @track openEscrowPickList;
    @track inspectionNeededPicklistValues;

    columns = [
        { label: 'Address', fieldName: 'Name' },
        { label: 'Beds', fieldName: 'Bedrooms__c' },
        { label: 'Baths', fieldName: 'Bathrooms__c' },
        { label: 'Sq Feet', fieldName: 'Square_Feet__c' },
        { label: 'Inspected Bedrooms', fieldName: 'Inspected_Bedrooms__c' },
        { label: 'Inspected Bathrooms', fieldName: 'Inspected_Bathrooms__c' },
        { label: 'Occupancy', fieldName: 'Occupancy_at_Closing__c' },
        { label: 'Monthly Rent', fieldName: 'Monthly_Rent__c', type: 'currency' },
        { label: 'Lease Start', fieldName: 'Lease_Start__c', type: 'date' },
        { label: 'Lease End', fieldName: 'Lease_End__c', type: 'date' },
        { label: 'Move Out Date', fieldName: 'Move_Out_Date__c' }
    ];

    isTaskCompleted = false;
    displayOptionFee = false;
    displayOffMarket = true;
    updateSendEmail = true;

    contractQCUpdateWrapper;
    contractQCWrapper = {"accountingContact":{},"brokerSellerContact":{},"buyerSignerContact":{},"buyerSignerContactId":"","buyerSignerContactName":"","buyerTransactionContact":{},"emdAccount":{},"inspectionRecord":{},"state":"","projectManager":{},"propertyUnitList":[],"sellerContactAccountId":"","sellerContactAccountName":"","sellerTransactionContact":{},"task":{},"titleCompanyContact":{},"titleCompanyContactAccountName":"","titleContact":{},"transactionRecord":{},"emdAmount":{},"optionFeeAmount":{},"propertyRecord":{}};

    hideButtons = false;
    displayError = false;
    @track errorMessage;

    lstDocuments = [];
    lstReviewItems = [];
    reviewUpdateWrapper;
    
    getContractQCData(){
        getContractQCData({ recordId: this.recordId }).then(result => {
                console.log("Contract QC Data ==>" + JSON.stringify(result));
                this.contractQCWrapper = result;
                if (this.contractQCWrapper.task.Status === 'Completed') {
                    this.isTaskCompleted = true;
                }

                // Display Option Fee related fields for Texas & North Carolina only
                if (this.contractQCWrapper.state === 'TX' || this.contractQCWrapper.state === 'NC') {
                    this.displayOptionFee = true;
                }

                if (this.contractQCWrapper.transactionRecord.Origination_Source__c.startsWith('MLS')) {
                    this.displayOffMarket = false;
                }

                this.contactFilterByAccountId = this.contractQCWrapper.transactionRecord.Title_Company_Account__c;
                this.lstReviewItems = result.reviewWrapper.lstReviewChecklist;
                this.lstDocuments = result.reviewWrapper.lstDocuments;
                this.isDefaultChecklist = result.reviewWrapper.isDefaultChecklist;
                this.reviewUpdateWrapper = this.proxyToObj(result.reviewWrapper);

                this.contractQCUpdateWrapper = this.proxyToObj(result);
            }
        ).catch(error => {
            this.errorMessage = reduceErrors(error); 
            this.displayError = true;
            this.hideButtons = true;
        });
    }    

    //Get Javascript object equivalent to Proxy
    proxyToObj(obj) {
        return JSON.parse(JSON.stringify(obj));
    }

    @wire (getRecordTypeId, {recordTypeLabel :'Transaction Tasks'}) 
    txnTaskRecordTypeId;

    @wire(getObjectInfo, { objectApiName: transactionObj })
    transactionObjInfo;

    @wire(getObjectInfo, { objectApiName: propertyUnitObj })
    propertyUnitObjInfo;

    // Buyer Entity Dropdown Values 
    getAccountListByRecordType(){
        getAccountListByRecordType().then(result => {
                if (result && result.length > 0) {
                    console.log("Buyer Entity Dropdown Values ==>" + JSON.stringify(result));
                    this.buyerEntityDropdownValues = result;
                } else if (error) {
                    console.log(JSON.stringify(error));
                }
            }
        ).catch(error => {
            this.errorMessage = "Error retrieving buyer entity dropdown values"; 
            this.displayError = true;
        });
    }

    // Occupancy & Property Access Method Picklist Values
    @track propertyAccessMethodPicklistValues;
    @wire(getPicklistValuesByRecordType, { objectApiName: propertyUnitObj, recordTypeId: '$propertyUnitObjInfo.data.defaultRecordTypeId' })
    occupancyPicklistValues({ error, data }) {
        if (data) {
            this.occupancyPicklistValues = data.picklistFieldValues.Occupancy_at_Closing__c.values;
            this.propertyAccessMethodPicklistValues = data.picklistFieldValues.Property_Access_Method_Type__c.values;

            console.log('Occupancy Picklist : ' + JSON.stringify(this.occupancyPicklistValues));
            console.log('Property Access Method Picklist : ' + JSON.stringify(this.propertyAccessMethodPicklistValues));
        } else if (error) {
            console.log(JSON.stringify(error));
        }
    }

    // Task Status Picklist Values
    @wire(getPicklistValuesByRecordType, { objectApiName: taskObj, recordTypeId: '$txnTaskRecordTypeId.data' })
    taskStatusPicklistValues({ error, data }) {
        if (data) {
            this.taskStatusPicklistValues = data.picklistFieldValues.Status.values;
            console.log('Task Status Picklist : ' + JSON.stringify(this.taskStatusPicklistValues));
        } else if (error) {
            this.errorMessage = "Error retrieving Task Status picklist values"; 
            this.displayError = true;
            console.log(JSON.stringify(error));
        }
    }
    
     // Option Fee Required, Open Escrow & Inspection Needed Picklist Values
     @wire(getPicklistValuesByRecordType, { objectApiName: transactionObj, recordTypeId: '$transactionObjInfo.data.defaultRecordTypeId' })
     transactionObjPickListValues({ error, data }) {
           if (data) {
               this.optionFeeStatusValues = data.picklistFieldValues.EMD_Option_Fee_Status__c.values;
               console.log('Option Fee Status Picklist : ' + JSON.stringify(this.optionFeeStatusValues));

               this.openEscrowPickList = data.picklistFieldValues.Open_Escrow__c.values;               
               console.log('Open Escrow Picklist : ' + JSON.stringify(this.openEscrowPickList));

               this.inspectionNeededPicklistValues = data.picklistFieldValues.Inspection_Needed__c.values;
               console.log('Inspection_Needed  Picklist : ' + JSON.stringify(this.inspectionNeededPicklistValues));
           } else if (error) {
               console.log('inspection needed, Open Escrow, Option FeeStatus - picklist error : '+JSON.stringify(error));
           }
   }

    // handle custom lookup component event 
    lookupRecord(event) {

        if (typeof event.detail.selectedRecord !== "undefined") {
            
            if (event.target.dataset.field == 'transactionRecord.Roofstock_Accounting__c') {
                this.contractQCUpdateWrapper.transactionRecord.Roofstock_Accounting__c = event.detail.selectedRecord.Id;
            }
            // if (event.target.dataset.field == 'inspectionRecord.Project_Manager__c') {
            //     this.contractQCUpdateWrapper.inspectionRecord.Project_Manager__c = event.detail.selectedRecord.Id;
            // }

            // if (event.target.dataset.field == 'buyerTransactionContact') {
            //     this.contractQCUpdateWrapper.buyerTransactionContact.Contact__c = event.detail.selectedRecord.Id;
            // }
            if (event.target.dataset.field == 'sellerTransactionContact') {
                this.contractQCUpdateWrapper.sellerTransactionContact.Contact__c = event.detail.selectedRecord.Id;
            }
            if (event.target.dataset.field == 'titleCompanyContact.Contact__c') {
                this.contractQCUpdateWrapper.titleCompanyContact.Contact__c = event.detail.selectedRecord.Id;
                this.copyToContractReview(event); 
            }

            if (event.target.dataset.field == 'task.OwnerId') {
                this.contractQCUpdateWrapper.task.OwnerId = event.detail.selectedRecord.Id;
            }

            if (event.target.dataset.field == 'transactionRecord.Title_Company_Account__c') {
                this.contractQCUpdateWrapper.transactionRecord.Title_Company_Account__c = event.detail.selectedRecord.Id;
                this.copyToContractReview(event); 
            }
        }
    }

    handleFieldChange(event) {

        if (event.target.name == 'Occupancy_at_Closing__c') {
            this.contractQCUpdateWrapper.propertyUnitList[event.target.dataset.field].Occupancy_at_Closing__c = event.target.value;            
        }

        if (event.target.name == 'Property_Access_Method_Type__c') {
            this.contractQCUpdateWrapper.propertyUnitList[event.target.dataset.field].Property_Access_Method_Type__c = event.target.value;
        }

        if (event.target.name == 'Property_Access_Notes__c') {
            this.contractQCUpdateWrapper.propertyUnitList[event.target.dataset.field].Property_Access_Notes__c = event.target.value;
        }

        if (event.target.name == 'HOA__c') {
            this.contractQCUpdateWrapper.propertyRecord.HOA__c = event.target.checked;
        }

        // Contract Review - Checklist
        if (event.target.name == 'review.Verify__c') {
            this.reviewUpdateWrapper.lstReviewChecklist[event.target.dataset.field].Verify__c = event.target.checked;
        }

        // Contract Review - Document 
        if (event.target.name == 'document.TC_Updates__c') {
            this.reviewUpdateWrapper.lstDocuments[event.target.dataset.field].TC_Updates__c = event.target.value;
        }
        if (event.target.name == 'document.Verify__c') {
            this.reviewUpdateWrapper.lstDocuments[event.target.dataset.field].Verify__c = event.target.checked;
        }        

        this.copyToContractReview(event); 

        console.log('Field (Name : Value) ==>' + event.target.name + ' : ' + JSON.stringify(event.target.value));
        console.log('Field Id ==>' + event.target.dataset.field);
    }

    //ContractReview TC update fields population 
    copyToContractReview(event) {       
        var fieldValue = event.target.value;
        if (event.target.dataset.field == 'emdAmount.Unit_Price__c') {
            this.copyToTCUpdateField(event, 'EMD Amount', this.formatCurrency(fieldValue))            
        } else if (event.target.dataset.field == 'transactionRecord.Buyer_Entity__c') {
            this.copyToTCUpdateField(event, 'Buyer Entity', fieldValue)
        } else if (event.target.dataset.field == 'transactionRecord.In_Contract_Price__c') {
            this.copyToTCUpdateField(event, 'Contract Price', this.formatCurrency(fieldValue))
        } else if (event.target.dataset.field == 'transactionRecord.In_Contract_Date__c') {
            this.copyToTCUpdateField(event, 'Acceptance Date', this.formatDate(fieldValue))
        } else if (event.target.dataset.field == 'transactionRecord.EMD_Due_Date__c') {
            this.copyToTCUpdateField(event, 'EMD Due Date', this.formatDate(fieldValue))
        } else if (event.target.dataset.field == 'transactionRecord.Date_Contingencies_Lift__c') {
            this.copyToTCUpdateField(event, 'Due Diligence Date', this.formatDate(fieldValue))
        } else if (event.target.dataset.field == 'transactionRecord.Est_Close_Date__c') {
            this.copyToTCUpdateField(event, 'COE', this.formatDate(fieldValue))
        } else if (event.target.dataset.field == 'propertyRecord.HOA__c') {
            this.copyToTCUpdateField(event, 'HOA', fieldValue) 
        } else if (event.target.dataset.field == 'optionFeeAmount.Unit_Price__c') {
            this.copyToTCUpdateField(event, 'Option Fee', this.formatCurrency(fieldValue)) 
        } else if (event.target.dataset.field == 'transactionRecord.Inspection_Due_Date__c') {
            this.copyToTCUpdateField(event, 'Inspection Deadline', this.formatDate(fieldValue)) 
        } else if (event.target.dataset.field == 'transactionRecord.Assignment_Fee__c') {
            this.copyToTCUpdateField(event, 'Assignment Fee', this.formatCurrency(fieldValue)) 
        } else if (event.target.dataset.field == 'transactionRecord.Buyer_Commission_Percent__c') {
            this.copyToTCUpdateField(event, 'Buyer Paid Commission', this.formatPercentage(fieldValue)) 
        } else if (event.target.dataset.field == 'transactionRecord.Title_Company_Account__c') {
            fieldValue =  event.detail.selectedRecord.Name;
            this.copyToTCUpdateField(event, 'Title Company', fieldValue) 

            //Update the variable for filtering the contacts
            this.contactFilterByAccountId =  event.detail.selectedRecord.Id;
            //Clear Title Company Contact field
            this.template.querySelector("[data-field='titleCompanyContact.Contact__c']").handleRemove();
            
        } else if (event.target.dataset.field == 'titleCompanyContact.Contact__c') {
            fieldValue =  event.detail.selectedRecord.Name;
            this.copyToTCUpdateField(event, 'Title Company Contact', fieldValue) 
        }

        if (event.target.name == 'Occupancy_at_Closing__c') {

            // Update Inspection section property unit occupancy
            var propertyOccupancies = this.template.querySelectorAll(".property_occupancy");
            propertyOccupancies[event.target.dataset.field].innerHTML = fieldValue;                

            var homeCode = this.contractQCUpdateWrapper.propertyUnitList[event.target.dataset.field].HomeCode__c;
            if (null != homeCode){
                this.copyToTCUpdateField(event, 'Occupancy Status-'+homeCode, fieldValue)
            } else {
                this.copyToTCUpdateField(event, 'Occupancy Status', fieldValue);    
            }
        }
    }

    formatDate(dateToformat){
        let formattedDate = dateToformat;
        if (null !== dateToformat){
            const options = {
                year: 'numeric', month: 'numeric', day: 'numeric', timeZone: 'UTC',
            };
            formattedDate = new Intl.DateTimeFormat('en-US', options).format(new Date(dateToformat));
        }
        return formattedDate;
    }

    formatCurrency(currencyToFormat){
        let formattedCurrency = currencyToFormat;
        if (null !== currencyToFormat && currencyToFormat.length>0){
            const options =  {
                currency: `USD`, style: 'currency',
            };
            formattedCurrency = new Intl.NumberFormat(`en-US`, options).format(currencyToFormat);
        }
        return formattedCurrency;
    }

    formatPercentage(percentToFormat){
        let formattedPercent  = percentToFormat;
        if (null !== percentToFormat && percentToFormat.length>0){
            const options =  {
                style: 'percent',
                minimumFractionDigits: 2,
                maximumFractionDigits: 2,
            };
            formattedPercent = new Intl.NumberFormat(`en-US`, options).format(percentToFormat/100);
        }
        return formattedPercent;
    }

    copyToTCUpdateField(event, checklistName, fieldValue) {
        var checklists = this.template.querySelectorAll(".Review_Checklist_Type__c");
        checklists.forEach(function(element){
            if (checklistName == element.value){
                let tcUpdates = this.template.querySelectorAll(".TC_Updates__c");
                
                // if (undefined != event.detail.selectedRecord){                
                //     fieldValue = event.detail.selectedRecord.Name;
                // }
                if (event.target.dataset.field == 'propertyRecord.HOA__c') {
                    if (event.target.checked){
                        fieldValue = 'Yes';
                    } else {
                        fieldValue = 'No';
                    }
                } 
                tcUpdates[element.dataset.field].value = fieldValue;                
                this.reviewUpdateWrapper.lstReviewChecklist[element.dataset.field].TC_Updates__c = fieldValue;                
            }
        },this);
    }

    // //for mark as current button
    // updateCurrentMilestone(event) {
    //     if (this.currentpath !== this.tempPath) {
    //         const recordToUpdate = {
    //             fields: {
    //                 Id: this.recordId,
    //                 Milestone__c: this.tempPath
    //             }
    //         };
    //         updateRecord(recordToUpdate);
    //     }
    //     this.refreshTheTransactionView();
    // }

    saveTask() {
        saveTask({ recordId: this.recordId });
        
        this.isTaskCompleted = true;
        this.getContractQCData();

        //Publish platform event
        publishPlatformEvent({ eventStringJSON: JSON.stringify(this.contractQCUpdateWrapper)}).then(result => {
            console.log("Platform event published succesfully !!");
        }).catch(error => {
            console.log(error);
        });

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Contract Audit Verified Successfully',
                variant: 'success'
            })
        );
        this.refreshTheTransactionView();
    }

    handleUpdate() {
        this.updateSendEmail = false;
        this.handleSubmit();
        this.updateSendEmail = true;
    }

    handleSubmit() {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);

        if (allValid) {

            // Transaction Record
            this.contractQCUpdateWrapper.transactionRecord.In_Contract_Price__c = this.template.querySelector("[data-field='transactionRecord.In_Contract_Price__c']").value;
            //Update Sale Price to In Contract Price
            this.contractQCUpdateWrapper.transactionRecord.Sale_Price__c = this.template.querySelector("[data-field='transactionRecord.In_Contract_Price__c']").value;
            // this.contractQCUpdateWrapper.transactionRecord.Seller_Entity__c = this.template.querySelector("[data-field='transactionRecord.Seller_Entity__c']").value;
            this.contractQCUpdateWrapper.transactionRecord.In_Contract_Date__c = this.template.querySelector("[data-field='transactionRecord.In_Contract_Date__c']").value;
            this.contractQCUpdateWrapper.transactionRecord.Est_Close_Date__c = this.template.querySelector("[data-field='transactionRecord.Est_Close_Date__c']").value;
            
            if (null != this.template.querySelector("[data-field='transactionRecord.EMD_Option_Fee_Status__c']")){
                this.contractQCUpdateWrapper.transactionRecord.EMD_Option_Fee_Status__c = this.template.querySelector("[data-field='transactionRecord.EMD_Option_Fee_Status__c']").value;
            }
            this.contractQCUpdateWrapper.transactionRecord.EMD_Due_Date__c = this.template.querySelector("[data-field='transactionRecord.EMD_Due_Date__c']").value;
            // this.contractQCUpdateWrapper.transactionRecord.Inspection_Email_Cc__c = this.template.querySelector("[data-field='transactionRecord.Inspection_Email_Cc__c']").value;
            this.contractQCUpdateWrapper.transactionRecord.Buyer_Entity__c = this.template.querySelector("[data-field='transactionRecord.Buyer_Entity__c']").value;
            this.contractQCUpdateWrapper.transactionRecord.Date_Contingencies_Lift__c = this.template.querySelector("[data-field='transactionRecord.Date_Contingencies_Lift__c']").value;

            // Save Open Escrow as 'Sent' if value selected is 'Yes'
            if ('Yes' == this.template.querySelector("[data-field='transactionRecord.Open_Escrow__c']").value){
                this.contractQCUpdateWrapper.transactionRecord.Open_Escrow__c = 'Sent';
            } else {
                this.contractQCUpdateWrapper.transactionRecord.Open_Escrow__c = this.template.querySelector("[data-field='transactionRecord.Open_Escrow__c']").value;
            }

            // Save Inspection Needed as 'Sent' if value selected is 'Yes'
            if ('Yes' == this.template.querySelector("[data-field='transactionRecord.Inspection_Needed__c']").value){
                this.contractQCUpdateWrapper.transactionRecord.Inspection_Needed__c =  'Sent';
            } else {
                this.contractQCUpdateWrapper.transactionRecord.Inspection_Needed__c = this.template.querySelector("[data-field='transactionRecord.Inspection_Needed__c']").value;
            }
            
            this.contractQCUpdateWrapper.transactionRecord.Inspection_Due_Date__c = this.template.querySelector("[data-field='transactionRecord.Inspection_Due_Date__c']").value;

            if (null != this.template.querySelector("[data-field='transactionRecord.Assignment_Fee__c']")){
                this.contractQCUpdateWrapper.transactionRecord.Assignment_Fee__c = this.template.querySelector("[data-field='transactionRecord.Assignment_Fee__c']").value;
            }
            if (null != this.template.querySelector("[data-field='transactionRecord.Buyer_Commission_Percent__c']")){
                this.contractQCUpdateWrapper.transactionRecord.Buyer_Commission_Percent__c = this.template.querySelector("[data-field='transactionRecord.Buyer_Commission_Percent__c']").value;
            }
            const transactionRecordToUpdate = {
                fields: this.contractQCUpdateWrapper.transactionRecord
            };

            // Inspection Record
            //this.contractQCUpdateWrapper.inspectionRecord.Inspection_Scheduled_Date__c = this.template.querySelector("[data-field='inspectionRecord.Inspection_Scheduled_Date__c']").value;
            this.contractQCUpdateWrapper.inspectionRecord.Inspection_Due_Date__c = this.template.querySelector("[data-field='transactionRecord.Inspection_Due_Date__c']").value; //from txn record
            // this.contractQCUpdateWrapper.inspectionRecord.Inspection_Needed__c = this.template.querySelector("[data-field='transactionRecord.Inspection_Needed__c']").value; 
            // this.contractQCUpdateWrapper.inspectionRecord.Send_Email_to_Inspector__c = this.template.querySelector("[data-field='inspectionRecord.Send_Email_to_Inspector__c']").value;
            const inpsectionRecordToUpdate = {
                fields: this.contractQCUpdateWrapper.inspectionRecord
            };

             // Property Record (HOA)
             const propertyRecordToUpdate = {
                fields: this.contractQCUpdateWrapper.propertyRecord
            };

            // Transaction Settlement Records (EMD Amount & Option Fee Amount)
            this.contractQCUpdateWrapper.emdAmount.Unit_Price__c = this.template.querySelector("[data-field='emdAmount.Unit_Price__c']").value;
            if (null != this.template.querySelector("[data-field='optionFeeAmount.Unit_Price__c']")){
                this.contractQCUpdateWrapper.optionFeeAmount.Unit_Price__c = this.template.querySelector("[data-field='optionFeeAmount.Unit_Price__c']").value;
            }

            // Update Transaction 
            updateRecord(transactionRecordToUpdate)
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
            console.log('Transaction Saved Successfully : ' + JSON.stringify(this.contractQCUpdateWrapper.transactionRecord))

            // Update Inspection
            if (this.contractQCUpdateWrapper.inspectionRecord.Id != null) {
                updateRecord(inpsectionRecordToUpdate)
                .catch(error => {
                    console.log(JSON.stringify(error));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
                console.log('Inspection Saved Successfully : ' + JSON.stringify(this.contractQCUpdateWrapper.inspectionRecord))
            } else {
                console.log('Inspection record not found so not updating : ' + JSON.stringify(this.contractQCUpdateWrapper.inspectionRecord))
            }

             // Update Property
             if (this.contractQCUpdateWrapper.propertyRecord.Id != null) {
                updateRecord(propertyRecordToUpdate).catch(error => {
                    this.errorMessage = reduceErrors(error);
                    this.displayError = true;
                });
                console.log('Property record saved successfully : ' + JSON.stringify(this.contractQCUpdateWrapper.propertyRecord))
            }

            // Upsert Transaction Settlement (EMD Amount)
            this.contractQCUpdateWrapper.emdAmount.Description__c = 'Earnest Money Deposit';
            this.contractQCUpdateWrapper.emdAmount.Transaction_Id__c = this.contractQCUpdateWrapper.transactionRecord.Transaction_Id__c;
            upsertTransactionSettlement({ txnSettlement: this.contractQCUpdateWrapper.emdAmount, txnRecordId: this.recordId}).catch(error => {
                this.errorMessage = reduceErrors(error);
                this.displayError = true;
            });
            console.log('Txn Settlement (EMD Amount) saved successfully : ' + JSON.stringify(this.contractQCUpdateWrapper.emdAmount))

            // Upsert Transaction Settlement (Option Fee Amount)
            this.contractQCUpdateWrapper.optionFeeAmount.Description__c = 'Option Fee';
            this.contractQCUpdateWrapper.optionFeeAmount.Transaction_Id__c = this.contractQCUpdateWrapper.transactionRecord.Transaction_Id__c;
            upsertTransactionSettlement({ txnSettlement: this.contractQCUpdateWrapper.optionFeeAmount, txnRecordId: this.recordId}).catch(error => {
                this.errorMessage = reduceErrors(error);
                this.displayError = true;
            });
            console.log('Txn Settlement (Option Fee Amount) saved successfully : ' + JSON.stringify(this.contractQCUpdateWrapper.optionFeeAmount))

            // Update Buyer Signer Transaction Contact Record
            // console.log('Buyer Signer Txn Contact Record : ' + JSON.stringify(this.contractQCUpdateWrapper.buyerTransactionContact))    
            // updateTransactionContact({ recordId: this.recordId, txnContact: this.contractQCUpdateWrapper.buyerTransactionContact, contactType: "Buyer Signer" }).catch(error => {
            //     this.errorMessage = reduceErrors(error);
            //     this.displayError = true;
            // });
            // console.log('Buyer Signer Contact Saved Successfully : ' + JSON.stringify(this.contractQCUpdateWrapper.buyerTransactionContact.Contact__c));

            // Update Broker Seller Transaction Contact Record
            // console.log('Broker Seller Txn Contact Record : ' + JSON.stringify(this.contractQCUpdateWrapper.sellerTransactionContact))    
            // updateTransactionContact({ recordId: this.recordId, txnContact: this.contractQCUpdateWrapper.sellerTransactionContact, contactType: "Broker Seller" }).catch(error => {
            //     this.errorMessage = reduceErrors(error);
            //     this.displayError = true;
            // });
            // console.log('Broker Seller Contact Saved Successfully : ' + JSON.stringify(this.contractQCUpdateWrapper.sellerTransactionContact.Contact__c));

            // Update Title Company Transaction Contact Record
            console.log('Title Company Txn Contact Record : ' + JSON.stringify(this.contractQCUpdateWrapper.titleCompanyContact))    
            updateTransactionContact({ recordId: this.recordId, txnContact: this.contractQCUpdateWrapper.titleCompanyContact, contactType: "Title" }).catch(error => {
                this.errorMessage = reduceErrors(error);
                this.displayError = true;
            });
            console.log('Title Company Contact Saved Successfully : ' + JSON.stringify(this.contractQCUpdateWrapper.titleCompanyContact.Contact__c));

            // Save Property Units
            for (let i in this.contractQCUpdateWrapper.propertyUnitList) {

                const propertyUnitToUpdate = {
                    fields: this.contractQCUpdateWrapper.propertyUnitList[i]
                };
                console.log('Property Unit Contact Record : ' + JSON.stringify(propertyUnitToUpdate))

                updateRecord(propertyUnitToUpdate)
                    .catch(error => {                       
                        this.displayError = true;
                        this.errorMessage = reduceErrors(error);
                    });
                console.log('Property Unit Saved Successfully : ' + JSON.stringify(this.contractQCUpdateWrapper.propertyUnitList[i].Id))
            }

            // Save Task Changes
            this.contractQCUpdateWrapper.task.Description = this.template.querySelector("[data-field='task.Description']").value;
           // this.contractQCUpdateWrapper.task.Status = this.template.querySelector("[data-field='task.Status']").value;
            updateTask({ wrapper: this.contractQCUpdateWrapper}).catch(error => {
                this.errorMessage = reduceErrors(error);
                this.displayError = true;
            });
            console.log('Task Saved Successfully for txn : ' + this.recordId)

            // Upsert Transaction Snapshot
            upsertTransactionSnapshot({ reviewWrapper: this.reviewUpdateWrapper, txnRecordId: this.recordId, updateSendEmail: this.updateSendEmail}).catch(error => {
                this.errorMessage = reduceErrors(error);
                this.displayError = true;
            });
            console.log('Transaction Snapshot Saved Successfully : ' + JSON.stringify(this.reviewUpdateWrapper))            

            //Publish platform event
            publishPlatformEvent({ eventStringJSON: JSON.stringify(this.contractQCUpdateWrapper)}).then(result => {
                console.log("Platform event published succesfully !!");
            }).catch(error => {
                console.log(error);
            });

            this.changeMode();
            this.getContractQCData();

            // All changes saved, display success message
            if(!this.displayError){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contract Audit Updated Successfully',
                        variant: 'success'
                    })
                );
                this.refreshTheTransactionView();
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Save failed',
                        message: 'Contract Audit Save has been failed.Error :'+ this.errorMessage,
                        variant: 'error'
                    })
                );
            }
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something is wrong',
                    message: 'Check your input and try again.',
                    variant: 'error'
                })
            );
        }
    }

    //to refreshTheTransactionView
    refreshTheTransactionView() {
        eval("$A.get('e.force:refreshView').fire();");//to refresh
        this.getRequiredValues();
        this[NavigationMixin.Navigate]({//if first refresh doesn't work it goes here and shows the default tab
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Transaction__c',
                actionName: 'view'
            },
        });
    }

    //to get name of the milestone in the path
    referencePath = '';
    handleStepBlur(event) {
        console.log('Selected Milestone : ' + event.target.value);
        this.tempPath = event.target.value;
        this.referencePath = this.tempPath;
    }

    //to get the fieldset based on the stage value
    @track isContractQC = true;
    @track isSubmitEMD = false;
    handleTypeChange(event) {
        console.log('Selected Stage : '+event.target.value);

        let selectedValue = event.target.value;
        if (selectedValue === 'Contract_QC') {
            this.isContractQC = true;
        } else {
            this.isContractQC = false;
        } 

        if (selectedValue === 'Submit EMD Upload Request'){
            this.isSubmitEMD = true;
        } else {
            this.isSubmitEMD = false;
        }
        this.getPropertyDetails();
    }
    
    @api
    connectedCallback() {
        this.transactionMilesoneStatusValues = [];
        this.getContractQCData();
        this.getRequiredValues();
        this.getMilestonePicklistValues();
        this.getAccountListByRecordType();
        this.senddata();        
        // this.getCheckListValues();
    }

    FileWrapper = [];
    senddata() {
        senddata({ recordId: this.recordId, type: 'TransactionPurchaseSaleAgreement' }).then(result => {
            this.FileWrapper = result;
            console.log("File ==>" + result);
        }).catch(error => {
            console.log("Error fetching files ==>" + JSON.stringify(error));
        });
    }

    inspectionId;
    isAcquisitionBuy = false;
    //to get the current milestone value and the related information
    getRequiredValues() {
        getRequiredValues({ recordId: this.recordId }).then(result => {
            //to get the current milestone value
            if (result && result.length > 0) {
                this.currentpath = result[0].Milestone__c;
                this.referencePath = result[0].Milestone__c;
                if (result[0].Transaction_Type__c === 'Acquisition Buy') {
                    this.isAcquisitionBuy = true;
                }

                if (this.currentpath === '' || this.currentpath === null) {
                    this.tempPath = 'New Transaction';
                    this.currentpath = 'New Transaction';
                }

                if (result[0].Inspections__r && result[0].Inspections__r.length) {
                    this.inspectionId = result[0].Inspections__r[0].Id;
                    console.log('inspectionId..*********' + this.inspectionId);
                }
            }
        })
    }

    isshowNewTransaction = false;
    //to populate the stage dropdown values based on milestone
    get typeOptions() {
        let options = [];

        if (this.referencePath === 'New Transaction' || undefined == this.referencePath) {
            options.push({ label: 'QC: Contract Audit', value: 'Contract_QC' });
            options.push({ label: 'Submit EMD Upload Request', value: 'Submit EMD Upload Request' });
            this.isshowNewTransaction = true;
        }

        if (this.referencePath === 'Diligence') {
            options.push({ label: 'Inspection Review', value: 'inspection_Review' });
            options.push({ label: 'Diligence Review', value: 'Diligence_Review' });
        }
        return options;
    }

    //to populate the path
    getMilestonePicklistValues() {
        getMilestonePicklistValues().then(result => {
            for (let i = 0; i < result.length; i++) {
                this.transactionMilesoneStatusValues.push({
                    label: result[i],
                    value: result[i]
                });
            }
            console.log('Milestones ==> ' +JSON.stringify(this.transactionMilesoneStatusValues));
        });
    }

    getPropertyDetails() {
        getPropertyDetails({ recordId: this.recordId }).then(result => {
            if (result && result.length > 0) {
                this.propertydetailsList = result;
            }
        })
    }

    isInputValid() {
        let isValid = true;
        let inputFields;
        this.template.querySelectorAll('lightning-input-field').forEach((field) => {
            if (!field.reportValidity()) {
                isValid = false;
            }
        });
        return isValid;
    }

    isReadMode = true;
    modeSelected = 'Read Mode';
    changeMode() {
        this.isReadMode = !this.isReadMode;
        if (this.isReadMode) {
            this.modeSelected = 'Read Mode';
        } else {
            this.modeSelected = 'Edit Mode';
        }
    }
}