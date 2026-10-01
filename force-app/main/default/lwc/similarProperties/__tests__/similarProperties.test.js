import { createElement } from '@lwc/engine-dom';
import SimilarProperties from 'c/similarProperties';
import getSimilarProperties from '@salesforce/apex/PropertyController.getSimilarProperties';
import { publish, subscribe, unsubscribe } from 'lightning/messageService';
import PROPERTYSELECTEDMC from '@salesforce/messageChannel/PropertySelected__c';

const mockSimilarProperties = require('./data/getSimilarProperties.json');

jest.mock(
    '@salesforce/apex/PropertyController.getSimilarProperties',
    () => {
        const {
            createApexTestWireAdapter
        } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

describe('c-similar-properties', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    async function flushPromises() {
        return Promise.resolve();
    }

    it('asks for a property when none is selected', () => {
        const element = createElement('c-similar-properties', {
            is: SimilarProperties
        });
        document.body.appendChild(element);

        const errorPanel = element.shadowRoot.querySelector('c-error-panel');
        expect(errorPanel.friendlyMessage).toBe(
            'Select a property to see similar properties'
        );
    });

    it('renders property tiles when similar properties are returned', async () => {
        const element = createElement('c-similar-properties', {
            is: SimilarProperties
        });
        element.recordId = 'a012F000009ovH0QAI';
        document.body.appendChild(element);

        getSimilarProperties.emit(mockSimilarProperties);
        await flushPromises();

        const tiles = element.shadowRoot.querySelectorAll('c-property-tile');
        expect(tiles.length).toBe(mockSimilarProperties.length);
        expect(tiles[0].property).toEqual(mockSimilarProperties[0]);
    });

    it('shows an empty message when no similar properties are returned', async () => {
        const element = createElement('c-similar-properties', {
            is: SimilarProperties
        });
        element.recordId = 'a012F000009ovH0QAI';
        document.body.appendChild(element);

        getSimilarProperties.emit([]);
        await flushPromises();

        const empty = element.shadowRoot.querySelector('p');
        expect(empty.textContent).toBe('No similar properties found.');
        expect(element.shadowRoot.querySelector('c-property-tile')).toBeNull();
    });

    it('renders an error panel when the wire returns an error', async () => {
        const element = createElement('c-similar-properties', {
            is: SimilarProperties
        });
        element.recordId = 'a012F000009ovH0QAI';
        document.body.appendChild(element);

        getSimilarProperties.error();
        await flushPromises();

        const errorPanel = element.shadowRoot.querySelector('c-error-panel');
        expect(errorPanel.friendlyMessage).toBe(
            'Error retrieving similar properties'
        );
    });

    it('registers and removes the property selection subscriber', () => {
        const element = createElement('c-similar-properties', {
            is: SimilarProperties
        });
        document.body.appendChild(element);

        expect(subscribe).toHaveBeenCalled();
        expect(subscribe.mock.calls[0][1]).toBe(PROPERTYSELECTEDMC);

        document.body.removeChild(element);
        expect(unsubscribe).toHaveBeenCalled();
    });

    it('publishes the selected similar property', async () => {
        const element = createElement('c-similar-properties', {
            is: SimilarProperties
        });
        element.recordId = 'a012F000009ovH0QAI';
        document.body.appendChild(element);

        getSimilarProperties.emit(mockSimilarProperties);
        await flushPromises();

        const tile = element.shadowRoot.querySelector('c-property-tile');
        tile.dispatchEvent(
            new CustomEvent('selected', {
                detail: mockSimilarProperties[0].Id
            })
        );

        expect(publish).toHaveBeenCalled();
        expect(publish.mock.calls[0][1]).toBe(PROPERTYSELECTEDMC);
        expect(publish.mock.calls[0][2]).toEqual({
            propertyId: mockSimilarProperties[0].Id
        });
    });
});
