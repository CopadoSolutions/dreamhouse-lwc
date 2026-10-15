import { createElement } from '@lwc/engine-dom';
import SimilarProperties from 'c/similarProperties';
import getSimilarProperties from '@salesforce/apex/PropertyController.getSimilarProperties';

const mockGetSimilarProperties = require('./data/getSimilarProperties.json');

// Mock getSimilarProperties Apex wire adapter
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

const RECORD_ID = 'a012F000009ovH0QAI';

describe('c-similar-properties', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    // Helper function to wait until the microtask queue is empty.
    // Used when having to wait for asynchronous DOM updates.
    async function flushPromises() {
        return Promise.resolve();
    }

    it('renders a spinner while data is loading', async () => {
        const element = createElement('c-similar-properties', {
            is: SimilarProperties
        });
        element.recordId = RECORD_ID;
        document.body.appendChild(element);

        // Wire has not emitted yet so loading state should be active
        await flushPromises();

        const spinner = element.shadowRoot.querySelector('lightning-spinner');
        expect(spinner).not.toBeNull();
    });

    it('renders property tiles when data is returned', async () => {
        const element = createElement('c-similar-properties', {
            is: SimilarProperties
        });
        element.recordId = RECORD_ID;
        document.body.appendChild(element);

        getSimilarProperties.emit(mockGetSimilarProperties);

        await flushPromises();

        const tiles = element.shadowRoot.querySelectorAll('c-property-tile');
        expect(tiles.length).toBe(mockGetSimilarProperties.length);
    });

    it('passes the correct property object to each property tile', async () => {
        const element = createElement('c-similar-properties', {
            is: SimilarProperties
        });
        element.recordId = RECORD_ID;
        document.body.appendChild(element);

        getSimilarProperties.emit(mockGetSimilarProperties);

        await flushPromises();

        const tiles = element.shadowRoot.querySelectorAll('c-property-tile');
        tiles.forEach((tile, index) => {
            expect(tile.property).toStrictEqual(
                mockGetSimilarProperties[index]
            );
        });
    });

    it('renders a no-results message when the list is empty', async () => {
        const element = createElement('c-similar-properties', {
            is: SimilarProperties
        });
        element.recordId = RECORD_ID;
        document.body.appendChild(element);

        getSimilarProperties.emit([]);

        await flushPromises();

        const tiles = element.shadowRoot.querySelectorAll('c-property-tile');
        expect(tiles.length).toBe(0);

        const noResultsEl = element.shadowRoot.querySelector('p');
        expect(noResultsEl).not.toBeNull();
        expect(noResultsEl.textContent).toContain('No similar properties');
    });

    it('renders an error panel when the wire adapter returns an error', async () => {
        const element = createElement('c-similar-properties', {
            is: SimilarProperties
        });
        element.recordId = RECORD_ID;
        document.body.appendChild(element);

        getSimilarProperties.error();

        await flushPromises();

        const errorPanel = element.shadowRoot.querySelector('c-error-panel');
        expect(errorPanel).not.toBeNull();
    });

    it('does not render tiles when an error occurs', async () => {
        const element = createElement('c-similar-properties', {
            is: SimilarProperties
        });
        element.recordId = RECORD_ID;
        document.body.appendChild(element);

        getSimilarProperties.error();

        await flushPromises();

        const tiles = element.shadowRoot.querySelectorAll('c-property-tile');
        expect(tiles.length).toBe(0);
    });

    it('is accessible when data is returned', async () => {
        const element = createElement('c-similar-properties', {
            is: SimilarProperties
        });
        element.recordId = RECORD_ID;
        document.body.appendChild(element);

        getSimilarProperties.emit(mockGetSimilarProperties);

        await flushPromises();

        await expect(element).toBeAccessible();
    });

    it('is accessible when no results are returned', async () => {
        const element = createElement('c-similar-properties', {
            is: SimilarProperties
        });
        element.recordId = RECORD_ID;
        document.body.appendChild(element);

        getSimilarProperties.emit([]);

        await flushPromises();

        await expect(element).toBeAccessible();
    });
});
