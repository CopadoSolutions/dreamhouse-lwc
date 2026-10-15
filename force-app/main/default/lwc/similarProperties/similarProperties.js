import { LightningElement, api, wire } from 'lwc';
import getSimilarProperties from '@salesforce/apex/PropertyController.getSimilarProperties';

export default class SimilarProperties extends LightningElement {
    @api recordId;

    @wire(getSimilarProperties, { propertyId: '$recordId' })
    similarProperties;

    get isLoading() {
        return !this.similarProperties.data && !this.similarProperties.error;
    }

    get hasError() {
        return !!this.similarProperties.error;
    }

    get hasResults() {
        return (
            this.similarProperties.data &&
            this.similarProperties.data.length > 0
        );
    }

    get hasNoResults() {
        return (
            this.similarProperties.data &&
            this.similarProperties.data.length === 0
        );
    }
}
