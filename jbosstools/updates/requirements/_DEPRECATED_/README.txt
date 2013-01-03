Removed builders:

./android/ - now linking directly to Google
./jrebel/ - cannot redistribute, no need for a composite site here
./jslint/ - no longer supported; removed from JBT/JBDS

Everything else in here used to live in either ../ or in ../m2eclipse/ and has been moved here because it is 
PROBABLY NO LONGER REQUIRED (but it is always better to move than delete, JUST IN CASE.)

---

For more on this cleanup effort, see:

* https://issues.jboss.org/browse/JBIDE-11677

---

For a detailed list of what requirements are needed, and for which release they are needed, see:

* https://docs.google.com/spreadsheet/ccc?key=0AmGcQy-AtllqdG9XWEYxaldRTnZMVDA5bXprTndPbEE#gid=0

-nboldt, 2013-01-03