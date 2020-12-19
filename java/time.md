## 
https://docs.oracle.com/javase/8/docs/api/java/time/format/DateTimeFormatter.html

## 解析带有时区字符串

```java
OffsetDateTime.parse("2020-12-19T13:38:10+08:00", DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ssXXX")) // DateTimeFormatter.ISO_OFFSET_DATE_TIME
```