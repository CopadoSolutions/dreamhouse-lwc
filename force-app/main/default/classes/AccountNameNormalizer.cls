/**
 * Normalizes Account names before records are saved.
 */
public with sharing class AccountNameNormalizer {
    /**
     * Normalizes names for inserted Accounts or updated Accounts whose names
     * changed.
     *
     * @param accounts Accounts being inserted or updated.
     * @param oldAccounts Existing Account values for update operations.
     */
    public static void normalizeNames(
        List<Account> accounts,
        Map<Id, Account> oldAccounts
    ) {
        for (Account accountRecord : accounts) {
            if (
                oldAccounts != null &&
                oldAccounts.containsKey(accountRecord.Id) &&
                accountRecord.Name == oldAccounts.get(accountRecord.Id).Name
            ) {
                continue;
            }

            accountRecord.Name = toNameCase(accountRecord.Name);
        }
    }

    private static String toNameCase(String value) {
        if (String.isBlank(value)) {
            return value;
        }

        String normalizedValue = '';
        Boolean capitalizeNext = true;
        String lowercaseValue = value.toLowerCase();

        for (Integer index = 0; index < lowercaseValue.length(); index++) {
            String character = lowercaseValue.substring(index, index + 1);
            normalizedValue += capitalizeNext
                ? character.toUpperCase()
                : character;
            capitalizeNext =
                character == ' ' ||
                character == '-' ||
                character == '\'';
        }

        return normalizedValue;
    }
}
