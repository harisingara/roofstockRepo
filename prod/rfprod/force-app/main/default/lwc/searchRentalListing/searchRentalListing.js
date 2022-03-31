import { LightningElement, track, api } from "lwc";
const PAGE_SIZE = 5;
export default class SearchRentalListing extends LightningElement {
  @track openmodel = false;
  @api recordId;
  openmodal() {
    this.openmodel = true;
  }

  closeModal() {
    this.openmodel = false;
  }
}