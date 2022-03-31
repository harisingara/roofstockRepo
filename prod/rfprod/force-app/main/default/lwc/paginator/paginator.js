import { LightningElement,api } from 'lwc';

export default class Paginator extends LightningElement {
    @api startingRecord;
    @api endingRecord;
    @api pageSize;
    @api totalRecountCount;
    @api totalPage;
    @api message;
    @api page;

    previousHandler() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    nextHandler() {
        this.dispatchEvent(new CustomEvent('next'));
    }
}