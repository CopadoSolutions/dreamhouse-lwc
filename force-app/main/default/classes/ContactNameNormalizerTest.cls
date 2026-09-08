@IsTest
private with sharing class ContactNameNormalizerTest {
    @IsTest
    static void normalizesNamesOnInsert() {
        // GIVEN
        List<Contact> contacts = new List<Contact>{
            new Contact(FirstName = 'jANE', LastName = 'dOE'),
            new Contact(FirstName = 'mARY-aNN', LastName = 'o\'CONNOR-smITH'),
            new Contact(LastName = 'dE lA cRUZ')
        };

        // WHEN
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert contacts;
        }

        // THEN
        Map<Id, Contact> contactsById = new Map<Id, Contact>(
            [
                SELECT FirstName, LastName
                FROM Contact
                WHERE Id IN :contacts
            ]
        );
        Assert.areEqual('Jane', contactsById.get(contacts[0].Id).FirstName);
        Assert.areEqual('Doe', contactsById.get(contacts[0].Id).LastName);
        Assert.areEqual('Mary-Ann', contactsById.get(contacts[1].Id).FirstName);
        Assert.areEqual(
            'O\'Connor-Smith',
            contactsById.get(contacts[1].Id).LastName
        );
        Assert.isNull(contactsById.get(contacts[2].Id).FirstName);
        Assert.areEqual(
            'De La Cruz',
            contactsById.get(contacts[2].Id).LastName
        );
    }

    @IsTest
    static void normalizesNamesOnUpdate() {
        // GIVEN
        Contact contactRecord = new Contact(
            FirstName = 'Original',
            LastName = 'Name'
        );
        insert contactRecord;
        contactRecord.FirstName = 'jOHN pAUL';
        contactRecord.LastName = 'vAN dYKE';

        // WHEN
        System.runAs(new User(Id = UserInfo.getUserId())) {
            update contactRecord;
        }

        // THEN
        Contact updatedContact = [
            SELECT FirstName, LastName
            FROM Contact
            WHERE Id = :contactRecord.Id
        ];
        Assert.areEqual('John Paul', updatedContact.FirstName);
        Assert.areEqual('Van Dyke', updatedContact.LastName);
    }
}
