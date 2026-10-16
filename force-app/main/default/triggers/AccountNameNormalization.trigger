trigger AccountNameNormalization on Account(before insert, before update) {
    AccountNameNormalizer.normalizeNames(Trigger.new, Trigger.oldMap);
}
