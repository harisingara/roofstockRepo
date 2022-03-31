//may10
import { LightningElement, track, wire, api } from "lwc";
// import server side apex class method
import getRentalListingList from "@salesforce/apex/searchRentalListingController.getRentalListingList";
import getRentalListingCount from "@salesforce/apex/searchRentalListingController.getRentalListingCount";

import checkORURecordExist from "@salesforce/apex/searchRentalListingController.checkORURecordExist";
import checkForInactiveStatus from "@salesforce/apex/searchRentalListingController.checkForInactiveStatus";

import { createRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import Property2_OBJECT from "@salesforce/schema/Property2__c";
import MARKET_FIELD from "@salesforce/schema/Property2__c.Leasing_Market__c";
import OPPORTUNITYRENTALUNIT_OBJECT from "@salesforce/schema/OpportunityRentalUnit__c";
import NAME_FIELD from "@salesforce/schema/OpportunityRentalUnit__c.Name";
import RENTALLISTINGID_FIELD from "@salesforce/schema/OpportunityRentalUnit__c.Leasing__c";
import OPPORTUNITYID_FIELD from "@salesforce/schema/OpportunityRentalUnit__c.Opportunity__c";
import ORUCURRENTMARKET_FIELD from "@salesforce/schema/OpportunityRentalUnit__c.Current_Market_Rent__c";
import ORUSTATUS_FIELD from "@salesforce/schema/OpportunityRentalUnit__c.Status__c";
import RENTALLISTING_OBJECT from "@salesforce/schema/Rental_Listing__c";
import STATUS_FIELD from "@salesforce/schema/Rental_Listing__c.Status__c";

const columns = [
  // { label: 'Id', fieldName: 'Id' },
  { label: "Name", fieldName: "Name", type: "text" },
  { label: "Market", fieldName: "Leasing_Market__c", type: "text" },
  {
    label: "Bed",
    fieldName: "Bedrooms__c",
    type: "number",
    cellAttributes: { alignment: "left" },
  },
  {
    label: "Bath",
    fieldName: "Bathrooms__c",
    type: "number",
    cellAttributes: { alignment: "left" },
  },
  {
    label: "Current Rent",
    fieldName: "Current_Rent__c",
    type: "currency",
    cellAttributes: { alignment: "left" },
  },
  { label: "Status", fieldName: "Status__c", type: "picklist" },
];

export default class RentalListingList extends LightningElement {
  @track rentalListings = [];
  sValBed = "";
  sValBath = "";
  sValMarket = "";
  sValStatus = "";
  sValAddress = "";
  @track currentPage = 0;
  @track pageSize = 0;
  @track totalPages;
  @track totalRecords = 0;

  @track error;
  @track columns = columns;
  @track sValMarket;
  @track sValStatus;
  @track sValAddress;

  @api objectApiName;
  @api recordid;

  @track currentObjectName;
  @track OpportunityRentalUnits;
  @track openmodel = false;
  @track rentalListings = [];
  @track loading = false;

  handlePrevious() {
    if (this.currentPage > 1) {
      this.currentPage = this.currentPage - 1;
      this.handlePagination();
    }
  }
  get showPage() {
    return this.rentalListings.length > 0;
  }
  get disableAdd() {
    return this.rentalListings.length == 0;
  }
  get showNoRecords() {
    return this.rentalListings.length == 0;
  }
  handleNext() {
    if (this.currentPage < this.totalPages) {
      this.currentPage = this.currentPage + 1;

      this.handlePagination();
    }
  }
  handleFirst() {
    this.currentPage = 1;
    this.handlePagination();
  }
  handleLast() {
    this.currentPage = this.totalPages;
    this.handlePagination();
  }
  openmodal() {
    this.openmodel = true;
  }
  closeModal() {
    this.rentalListings = [];
    this.sValBed = "";
    this.sValBath = "";
    this.sValMarket = "";
    this.sValStatus = "";
    this.sValAddress = "";
    this.dispatchEvent(new CustomEvent("close"));
  }

  connectedCallback() {
    this.currentObjectName = this.objectApiName;
    this.currentPage = 1;
    this.pageSize = 20;
    this.totalPages = 0;
    this.totalRecords = 0;
    this.loading = false;
  }

  @wire(getObjectInfo, { objectApiName: Property2_OBJECT })
  objectInfo;

  @wire(getObjectInfo, { objectApiName: RENTALLISTING_OBJECT })
  objectInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: MARKET_FIELD,
  })
  MarketPicklistValues;

  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: STATUS_FIELD,
  })
  StatusPicklistValues;

  resetPage() {
    this.currentPage = 1;
    this.totalPages = 0;
    this.totalRecords = 0;
    this.rentalListings = [];
  }
  updateSeachKeyAddress(event) {
    this.sValAddress = event.target.value;
  }

  updateSearchKeyStatus(event) {
    this.sValStatus = event.detail.value;
  }

  updateSearchKeyMarket(event) {
    this.sValMarket = event.detail.value;
  }

  // update sVal var when input field value change
  updateSeachKeyBed(event) {
    this.sValBed = event.target.value;
  }
  updateSeachKeyBath(event) {
    this.sValBath = event.target.value;
  }

  // call apex method on button click
  handleSearch() {
    this.resetPage();
    if (
      this.sValBed == "" &&
      this.sValBath == "" &&
      (this.sValMarket == "" || typeof this.sValMarket == "undefined") &&
      (this.sValStatus == "" || typeof this.sValStatus == "undefined") &&
      (this.sValAddress == "" || typeof this.sValAddress == "undefined")
    ) {
      const showError = new ShowToastEvent({
        title: "Error!!",
        message: "Please select any filter for the searching the records.",
        variant: "error",
      });
      this.dispatchEvent(showError);
      return;
    }
    this.loading = true;

    getRentalListingCount({
      sMarketkey: typeof this.sValMarket == "undefined" ? "" : this.sValMarket,
      dbedkey: this.sValBed == "" ? 0 : this.sValBed,
      dbathkey: this.sValBath == "" ? 0 : this.sValBath,
      sStatuskey: typeof this.sValStatus == "undefined" ? "" : this.sValStatus,
      sAddresskey:
        typeof this.sValAddress == "undefined" ? "" : this.sValAddress,
    })
      .then((recordsCount) => {
        this.totalRecords = recordsCount;
        if (recordsCount !== 0 && !isNaN(recordsCount)) {
          this.totalPages = Math.ceil(recordsCount / this.pageSize);

          getRentalListingList({
            pagenumber: this.currentPage,
            numberOfRecords: recordsCount,
            pageSize: this.pageSize,
            sMarketkey: this.sValMarket,
            dbedkey: this.sValBed == "" ? 0 : this.sValBed,
            dbathkey: this.sValBath == "" ? 0 : this.sValBath,
            sStatuskey: this.sValStatus,
            sAddresskey: this.sValAddress,
          })
            .then((result) => {
              this.loading = false;

              this.rentalListings = result;
            })
            .catch((error) => {
              console.log("***error", error);

              const event = new ShowToastEvent({
                title: "Error",
                variant: "error",
                message: error.body.message,
              });
              this.dispatchEvent(event);
              this.rentalListings = [];
              this.totalRecords = undefined;
              this.loading = false;
            });
        } else {
          console.log("***ese");
          this.loading = false;

          this.rentalListings = [];
          this.totalpages = 0;
          this.totalRecords = 0;
        }
      })
      .catch((error) => {
        console.log("***error", error);

        const event = new ShowToastEvent({
          title: "Error",
          variant: "error",
          message: error.body.message,
        });
      });
  }
  handlePagination() {
    if (
      this.sValBed == "" &&
      this.sValBath == "" &&
      (this.sValMarket == "" || typeof this.sValMarket == "undefined") &&
      (this.sValStatus == "" || typeof this.sValStatus == "undefined") &&
      (this.sValAddress == "" || typeof this.sValAddress == "undefined")
    ) {
      const showError = new ShowToastEvent({
        title: "Error!!",
        message: "Please select any filter for the searching the records.",
        variant: "error",
      });
      this.dispatchEvent(showError);
      return;
    }
    this.loading = true;
    console.log(
      "searching..",
      this.currentPage,
      this.totalRecords,
      this.pageSize
    );

    getRentalListingList({
      pagenumber: this.currentPage,
      numberOfRecords: this.totalRecords,
      pageSize: this.pageSize,
      sMarketkey: this.sValMarket,
      dbedkey: this.sValBed == "" ? 0 : this.sValBed,
      dbathkey: this.sValBath == "" ? 0 : this.sValBath,
      sStatuskey: this.sValStatus,
      sAddresskey: this.sValAddress,
    })
      .then((result) => {
        console.log("***result", result);

        this.loading = false;

        this.rentalListings = result;
      })
      .catch((error) => {
        console.log("***error", error);

        const event = new ShowToastEvent({
          title: "Error",
          variant: "error",
          message: error.body.message,
        });
        this.dispatchEvent(event);
        this.rentalListings = [];
        this.totalRecords = undefined;
        this.loading = false;
      });
  }
  handleAdd() {
    console.log(this.recordid);
    if (this.rentalListings == "" || this.rentalListings == null) {
      const showError = new ShowToastEvent({
        title: "Error!!",
        message: "Please select atleast one unit to add to opportunity",
        variant: "error",
      });
      this.dispatchEvent(showError);
    } else {
      var el = this.template.querySelector("lightning-datatable");
      var selected = el.getSelectedRows();
      var recordSelIds = [];
      if (selected.length > 0) {
        for (var i = 0; i < selected.length; i++) {
          recordSelIds.push(selected[i].Id);
        }
        checkForInactiveStatus({ rentallistingid: recordSelIds }).then(
          (result) => {
            if (result) {
              const showError = new ShowToastEvent({
                title: "Error!!",
                message:
                  "One or more of the selected units are not available for leasing. \nPlease remove the unavailable units and try again. ",
                variant: "error",
              });
              this.dispatchEvent(showError);
            } else {
              checkORURecordExist({
                rentallistingid: recordSelIds,
                oppid: this.recordid,
              }).then((result) => {
                if (result) {
                  const showError = new ShowToastEvent({
                    title: "Error!!",
                    message:
                      "One or more of the selected units already exists in this Opportunity. \nPlease remove the existing units and try again.",
                    variant: "error",
                  });
                  this.dispatchEvent(showError);
                } else {
                  var el1 = this.template.querySelector("lightning-datatable");
                  var selectedrow = el1.getSelectedRows();
                  for (var j = 0; j < selectedrow.length; j++) {
                    const fields = {};
                    fields[NAME_FIELD.fieldApiName] = selectedrow[j].Name;
                    fields[RENTALLISTINGID_FIELD.fieldApiName] =
                      selectedrow[j].Id;
                    fields[OPPORTUNITYID_FIELD.fieldApiName] = this.recordid;
                    fields[ORUSTATUS_FIELD.fieldApiName] = "Available";
                    fields[ORUCURRENTMARKET_FIELD.fieldApiName] =
                      selectedrow[j].Current_Rent__c;
                    const recordInput = {
                      apiName: OPPORTUNITYRENTALUNIT_OBJECT.objectApiName,
                      fields,
                    };
                    console.log("recordInput", recordInput);
                    createRecord(recordInput)
                      .then((OpportunityRentalUnit__c) => {
                        this.dispatchEvent(
                          new ShowToastEvent({
                            title: "Success",
                            message: "Unit succesfully added to Opportunity",
                            variant: "success",
                          })
                        );
                        this.closeModal();
                        //  window.location.reload();
                        eval("$A.get('e.force:refreshView').fire();");
                      })
                      .catch((error) => {
                        this.dispatchEvent(
                          new ShowToastEvent({
                            title: "Error creating record",
                            message: error.body.message,
                            variant: "error",
                          })
                        );
                      });
                  } //end of for
                }
              });
            }
          }
        );
      }
    }
  }
}