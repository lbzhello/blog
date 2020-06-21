# 常用函数

## let
非空时执行，返回 lambda 结果

```kotlin
val user = User(name = "tom", age = "22")

val name = user?.let {
    // user 非空时执行
    it.name = "new name"
    it.age = 19
    it.name // 返回 name
}
```

## with
调用时省略对象名，返回 lambda 结果

```kotlin
with(user) {
    name = "jerry" // tom 
    name
}
```

## also
与 let 相似，但是返回对象本身

```kotlin
user?.also {
    println(name)
    println(age)
}
```

## run
功能等同于 let + with
它弥补了 let 需要用 it 表示对象的缺陷，同时也弥补了 with 无法判空的缺陷。
```kotlin
user?.run {
    // user 非空时执行
    it.name = "new name"
    it.age = 19
    it.name // 返回 name
}
```

## apply
和 run 很像， 它们之间唯一的不同是它返回对象本身，而 run 返回 lambda 表达式的结果。

```kotlin
user?.apply {
    println(name)
    println(age)
}
```