import { LightningElement, api, wire } from 'lwc';
import {
    publish,
    subscribe,
    unsubscribe,
    MessageContext
} from 'lightning/messageService';
import PROPERTYSELECTEDMC from '@salesforce/messageChannel/PropertySelected__c';
import getSimilarProperties from '@salesforce/apex/PropertyController.getSimilarProperties';

export default class SimilarProperties extends LightningElement {
    propertyId;
    subscription;

    @wire(MessageContext)
    messageContext;

    @wire(getSimilarProperties, { propertyId: '$propertyId' })
    properties;

    @api
    get recordId() {
        return this.propertyId;
    }

    set recordId(propertyId) {
        this.propertyId = propertyId;
    }

    get hasNoPropertyId() {
        return !this.propertyId;
    }

    get isLoading() {
        return (
            this.propertyId &&
            this.properties &&
            this.properties.data === undefined &&
            this.properties.error === undefined
        );
    }

    get hasProperties() {
        return this.properties?.data?.length > 0;
    }

    connectedCallback() {
        this.subscription = subscribe(
            this.messageContext,
            PROPERTYSELECTEDMC,
            (message) => {
                this.handlePropertySelected(message);
            }
        );
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handlePropertySelected(message) {
        this.propertyId = message.propertyId;
    }

    handleTileSelected(event) {
        const message = { propertyId: event.detail };
        publish(this.messageContext, PROPERTYSELECTEDMC, message);
    }
}
