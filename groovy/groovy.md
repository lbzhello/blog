## 读写文件

### 读文件

```groovy
def file = new File("C:/tmp.txt")

// groovy 会自动关闭文件
file.eachLine { line ->
    println line
}

// 指定编码, 默认 utf-8
file.eachLine("gbk") { line ->
    println line
}

// 获取行号
file.eachLine { line, no ->
    println "line $no: $line"
}

// 转成 list
def list = file.collect {it}

// 转成数组
def array = file as String[]

// 转字节数组
byte[] contents = file.getBytes()

// 获取 Reader, 同理可以获取 InputStream
// newReader 可以获取 Reader 但需要自己维护资源 
file.withReader {
    while (it.readLine()) {
        // do something...
    }
}
```

### 写文件

```groovy
def file = new File("C:/tmp.txt")

// 直接写入字符串（追加）
file << '''
hello world
'''

// Writer 写入
file.withWriter('utf-8') {
    it.writeLine 'hello world'
}

// 覆盖写入字节数组
file.bytes = [66,22,11]

```

### 目录操作

```groovy
def dir = new File("D:")
// 目录名
dir.eachFile {
    println it.name
}

// 正则匹配
dir.eachFileMatch(~/.*\.txt/) {
    println it.name
}

// 递归获取目录名，目录下子目录文件名
dir.eachFileRecurse {                    
    println it.name
}

// 指定文件类型，同 eachFile
dir.eachFileRecurse(FileType.FILES) {
    println it.name
}

// 终止，跳过
dir.traverse { file ->
    if (file.directory && file.name=='bin') {
        FileVisitResult.TERMINATE                   
    } else {
        println file.name
        FileVisitResult.CONTINUE                    
    }
}
```

## 对象序列化

```groovy
boolean b = true
String message = 'Hello from Groovy'
// Serialize data into a file
file.withDataOutputStream { out ->
    out.writeBoolean(b)
    out.writeUTF(message)
    // 需要实现 Serializable 接口
    out.writeObject(new Person(name: 'Bob', age: '22'))
}
// ...
// Then read it back
file.withDataInputStream { input ->
    assert input.readBoolean() == b
    assert input.readUTF() == message
    def p2 = input.readObject()
    assert p2.name == p.name
    assert p2.age == p.age
}

```

## 命令行

```groovy
def process = "ls -l".execute()             
process.in.eachLine { line ->               
    println line                            
}

// 获取命令输出，指定编码
def message = process.in.getText("gbk")

// shell 内建命令不能直接调用 'dir'.execute() 会提示
// Cannot run program "dir": CreateProcess error=2, The system cannot find the file specified.
// 可以像如下这样调用
def process = "cmd /c ls".execute()
process.in.getText("gbk").eachLine { line ->
    println line
}

// 有些命令可能执行时间很长，可以使用 consumeProcessOutput
def sout = new StringBuilder()
def serr = new StringBuilder()
def p = "ls -l".execute()
p.consumeProcessOutput(sout, serr)
p.waitFor()

println sout
println serr
```


## 参考
[The Groovy Development Kit](http://www.groovy-lang.org/groovy-dev-kit.html#_negation)