public with sharing class DemoGreeting {
    public static String greet(String name) {
        String who = String.isBlank(name) ? 'there' : name.trim();
        return 'Hello, ' + who;
    }
}