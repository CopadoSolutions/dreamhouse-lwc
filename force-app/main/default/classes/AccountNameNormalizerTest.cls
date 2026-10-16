@IsTest
private with sharing class AccountNameNormalizerTest {
    @IsTest
    static void normalizesNamesOnInsert() {
        // GIVEN
        List<Account> accounts = new List<Account>{
            new Account(Name = 'aCME cORPORATION'),
            new Account(Name = 'o\'CONNOR-hOLDINGS'),
            new Account(Name = 'dE lA cRUZ')
        };

        // WHEN
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert accounts;
        }

        // THEN
        Map<Id, Account> accountsById = new Map<Id, Account>(
            [SELECT Name FROM Account WHERE Id IN :accounts]
        );
        Assert.areEqual(
            'Acme Corporation',
            accountsById.get(accounts[0].Id).Name
        );
        Assert.areEqual(
            'O\'Connor-Holdings',
            accountsById.get(accounts[1].Id).Name
        );
        Assert.areEqual('De La Cruz', accountsById.get(accounts[2].Id).Name);
    }

    @IsTest
    static void normalizesOnlyChangedNamesOnUpdate() {
        // GIVEN
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Original Name'),
            new Account(Name = 'Unchanged Name')
        };
        insert accounts;
        accounts[0].Name = 'nEW cUSTOMER';
        accounts[1].Phone = '555-0100';

        // WHEN
        System.runAs(new User(Id = UserInfo.getUserId())) {
            update accounts;
        }

        // THEN
        Map<Id, Account> accountsById = new Map<Id, Account>(
            [SELECT Name, Phone FROM Account WHERE Id IN :accounts]
        );
        Assert.areEqual('New Customer', accountsById.get(accounts[0].Id).Name);
        Assert.areEqual(
            'Unchanged Name',
            accountsById.get(accounts[1].Id).Name
        );
        Assert.areEqual('555-0100', accountsById.get(accounts[1].Id).Phone);
    }

    @IsTest
    static void supportsBulkInserts() {
        // GIVEN
        List<Account> accounts = new List<Account>();
        for (Integer index = 0; index < 200; index++) {
            accounts.add(new Account(Name = 'cUSTOMER ' + index));
        }

        // WHEN
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert accounts;
        }

        // THEN
        Map<Id, Account> accountsById = new Map<Id, Account>(
            [SELECT Name FROM Account WHERE Id IN :accounts]
        );
        for (Integer index = 0; index < accounts.size(); index++) {
            Assert.areEqual(
                'Customer ' + index,
                accountsById.get(accounts[index].Id).Name
            );
        }
    }
}
