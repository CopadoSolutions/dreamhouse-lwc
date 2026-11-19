public with sharing class SampleDataController {
    @AuraEnabled
    public static void importSampleData() {
        delete [SELECT Id FROM Case];
        delete [SELECT Id FROM Property__c];
        delete [SELECT Id FROM Broker__c];
        delete [SELECT Id FROM Contact];

        insertBrokers();
        insertProperties();
        insertContacts();
    }

    /**
     * Returns products visible to the current user that match the supplied
     * optional filters.
     *
     * @param searchTerm Text contained in a product name or product code
     * @param family Exact product family
     * @param isActive Product active status
     * @return Up to 200 matching Product2 records, sorted by name
     */
    @SuppressWarnings('PMD.AvoidBooleanMethodParameters')
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(
        String searchTerm,
        String family,
        Boolean isActive
    ) {
        List<String> conditions = new List<String>();
        Map<String, Object> bindVariables = new Map<String, Object>();

        if (String.isNotBlank(searchTerm)) {
            conditions.add(
                '(Name LIKE :searchPattern OR ProductCode LIKE :searchPattern)'
            );
            bindVariables.put('searchPattern', '%' + searchTerm.trim() + '%');
        }
        if (String.isNotBlank(family)) {
            conditions.add('Family = :family');
            bindVariables.put('family', family.trim());
        }
        if (isActive != null) {
            conditions.add('IsActive = :isActive');
            bindVariables.put('isActive', isActive);
        }

        String query =
            'SELECT Id, Name, ProductCode, Description, Family, IsActive ' +
            'FROM Product2';
        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }
        query += ' ORDER BY Name, ProductCode, Id LIMIT 200';

        return (List<Product2>) Database.queryWithBinds(
            query,
            bindVariables,
            AccessLevel.USER_MODE
        );
    }

    private static void insertBrokers() {
        StaticResource brokersResource = [
            SELECT Id, Body
            FROM StaticResource
            WHERE Name = 'sample_data_brokers'
        ];
        String brokersJSON = brokersResource.body.toString();
        List<Broker__c> brokers = (List<Broker__c>) JSON.deserialize(
            brokersJSON,
            List<Broker__c>.class
        );
        insert brokers;
    }

    private static void insertProperties() {
        StaticResource propertiesResource = [
            SELECT Id, Body
            FROM StaticResource
            WHERE Name = 'sample_data_properties'
        ];
        String propertiesJSON = propertiesResource.body.toString();
        List<Property__c> properties = (List<Property__c>) JSON.deserialize(
            propertiesJSON,
            List<Property__c>.class
        );
        randomizeDateListed(properties);
        insert properties;
    }

    private static void insertContacts() {
        StaticResource contactsResource = [
            SELECT Id, Body
            FROM StaticResource
            WHERE Name = 'sample_data_contacts'
        ];
        String contactsJSON = contactsResource.body.toString();
        List<Contact> contacts = (List<Contact>) JSON.deserialize(
            contactsJSON,
            List<Contact>.class
        );
        insert contacts;
    }

    private static void randomizeDateListed(List<Property__c> properties) {
        for (Property__c property : properties) {
            property.Date_Listed__c =
                System.today() - Integer.valueof((Math.random() * 90));
        }
    }
}
