import { LightningElement, track, api, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/ldsUtils'
import { NavigationMixin } from 'lightning/navigation';

import getSubmitEMDData from '@salesforce/apex/SubmitEMDController.getSubmitEMDData';
import completeTask from "@salesforce/apex/SubmitEMDController.completeTask";
import publishPlatformEvent from '@salesforce/apex/SubmitEMDController.publishPlatformEvent';
import senddata from '@salesforce/apex/TransactionDetails.senddata';
import getRecordTypeId from '@salesforce/apex/ContractQCController.getRecordTypeId';
import updateTask from '@salesforce/apex/SubmitEMDController.updateTask';

import transactionObj from '@salesforce/schema/Transaction__c';
import taskObj from '@salesforce/schema/Task';

export default class SubmitEMD extends NavigationMixin(LightningElement) {

    @api objectApiName;
    @api recordId;

    isReadOnly = true;
    buyerPMInstructionsLabel;

    titleContactInstructionsLabel;
    
    connectedCallback() {
        this.getSubmitEMDData();
        this.senddata();
    }

    @wire(getObjectInfo, { objectApiName: transactionObj })
    transactionObjInfo;
 
    errorMessage;
    displayError = false;
    hideButtons = false;

    displayOptionFee = false;
    isEMDTaskCompleted = false; 

    submitEMDWrapper = {"state":"","task":{},"titleContactAccount":{}, "buyerPMAccount":{}, "transactionRecord":{},"emdAmount":{},"optionFeeAmount":{},"buyerPMContact":{},"titleContact":{}};
    submitEMDUpdateWrapper;
    getSubmitEMDData(){
        getSubmitEMDData({ recordId: this.recordId }).then(result => {
                console.log("Submit EMD Apex Data ==>" + JSON.stringify(result));
                this.submitEMDWrapper = result;

                if (this.submitEMDWrapper.task.Status === 'Completed') {
                    this.isEMDTaskCompleted = true;
                }

                // Display Option Fee related fields for Texas & North Carolina only
                if ((this.submitEMDWrapper.state === 'TX'))  {
                    this.displayOptionFee = true;
                }

                if (JSON.stringify(this.submitEMDWrapper.buyerPMAccount) != '{}'){ 
                    this.buyerPMInstructionsLabel = this.submitEMDWrapper.buyerPMAccount.Name + ' Transaction Instructions (Buyer PM)';
                } 

                if (JSON.stringify(this.submitEMDWrapper.titleContactAccount) != '{}'){ 
                    this.titleContactInstructionsLabel = this.submitEMDWrapper.titleContactAccount.Name + ' Transaction Instructions (Title Company)';
                }

                this.submitEMDUpdateWrapper = this.proxyToObj(result);
            }
        ).catch(error => {
            this.errorMessage = reduceErrors(error); 
            this.displayError = true;
            this.hideButtons = true;
            console.log(this.errorMessage)
        });
    }
    
    //Get Javascript object equivalent to Proxy
    proxyToObj(obj) {
        return JSON.parse(JSON.stringify(obj));
    }
    
    optionFeeStatusValues;
    emdStatusValues;
    @wire(getPicklistValuesByRecordType, { objectApiName: transactionObj, recordTypeId: '$transactionObjInfo.data.defaultRecordTypeId' })
    transactionObjPickListValues({ error, data }) {
        if (data) {
            this.optionFeeStatusValues = data.picklistFieldValues.EMD_Option_Fee_Status__c.values;
            this.emdStatusValues = data.picklistFieldValues.EMD_Status__c.values;
            
            console.log('Option Fee Status Picklist Values : ' + JSON.stringify(this.optionFeeStatusValues));
            console.log('EMD Status Picklist Values : ' + JSON.stringify(this.emdStatusValues));
        } else if (error) {
            console.log(JSON.stringify(error));
        }
    }

    FileWrapper = [];
    senddata() {
        senddata({ recordId: this.recordId, type: 'TransactionWiringInstructions' }).then(result => {
            this.FileWrapper = result;
            console.log("File ==>" + result);
        }).catch(error => {
            console.log("Error fetching files ==>" + JSON.stringify(error));
        });
    }

    @wire (getRecordTypeId, {recordTypeLabel :'Transaction Tasks'}) 
    transrecordTypeId;
    
    // Task Status Picklist Values
    @wire(getPicklistValuesByRecordType, { objectApiName: taskObj, recordTypeId: '$transrecordTypeId.data' })
    taskStatusPicklistValues({ error, data }) {
        if (data) {
            this.taskStatusPicklistValues = data.picklistFieldValues.Status.values;
            console.log('Task Status  Picklist : ' + JSON.stringify(this.taskStatusPicklistValues));
        } else if (error) {
            console.log(JSON.stringify(error));
        }
    }

    handleEdit() {
        this.isReadOnly = false;
    }

    handleCancel() {
        this.isReadOnly = true;
    }

    completeTask() {
        completeTask({ taskId: this.submitEMDWrapper.task.Id, recordId: this.recordId })
            .then(result => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Verified',
                    message: 'Submit EMD has been verified successfully!!',
                    variant: 'success' //variant can be error
                }));
        })
        .catch(error => {
            console.error(error);
        });
        this.refreshTheTransactionView();
    }

    handleSubmit() {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);

        if (allValid) {

            // Transaction Record
            if (null != this.template.querySelector("[data-field='emd.transactionRecord.EMD_Option_Fee_Status__c']")){
                this.submitEMDUpdateWrapper.transactionRecord.EMD_Option_Fee_Status__c = this.template.querySelector("[data-field='emd.transactionRecord.EMD_Option_Fee_Status__c']").value;
            }
            this.submitEMDUpdateWrapper.transactionRecord.EMD_Status__c = this.template.querySelector("[data-field='emd.transactionRecord.EMD_Status__c']").value;
            this.submitEMDUpdateWrapper.transactionRecord.Emd_Wired_On_Date__c = this.template.querySelector("[data-field='emd.transactionRecord.Emd_Wired_On_Date__c']").value;
            const transactionRecordToUpdate = {
                fields: this.submitEMDUpdateWrapper.transactionRecord
            };
            console.log('Txn Record : ' + JSON.stringify(transactionRecordToUpdate))

            updateRecord(transactionRecordToUpdate)
                .catch(error => {
                    this.displayError = true;
                    this.errorMessage = reduceErrors(error);
                });
            console.log('Transaction Saved Successfully : ' + JSON.stringify(this.submitEMDUpdateWrapper.transactionRecord.Id))

            // Save Task Changes
            this.submitEMDUpdateWrapper.task.Description = this.template.querySelector("[data-field='emd.task.Description']").value;
            //this.submitEMDUpdateWrapper.task.Status = this.template.querySelector("[data-field='emd.task.Status']").value;
            updateTask({ wrapper: this.submitEMDUpdateWrapper}).catch(error => {
                this.errorMessage = reduceErrors(error);
                this.displayError = true;
            });
            console.log('Task saved successfully for txn : ' + this.recordId)

            //Publish platform event
           publishPlatformEvent({ eventStringJSON: JSON.stringify(this.submitEMDUpdateWrapper)}).then(result => {
                console.log("Platform event published succesfully !!");
            }).catch(error => {
                console.log(error);
            });

            this.handleCancel();
            this.getSubmitEMDData();

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
        this[NavigationMixin.Navigate]({//if first refresh doesn't work it goes here and shows the default tab
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Transaction__c',
                actionName: 'view'
            },
        });
    }

    // handle custom lookup component event 
    lookupRecord(event) {
        if (typeof event.detail.selectedRecord !== "undefined") {
            if (event.target.dataset.field == 'emd.task.OwnerId') {
                this.submitEMDUpdateWrapper.task.OwnerId = event.detail.selectedRecord.Id;
            }
        }
    }

}