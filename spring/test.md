## Mock

## mock 是什么
简单来说，mock 就是创建一个类的虚假的对象，在测试环境中，用来替换掉真实的对象。

在软件开发中，经常会遇到这样一个场景，当前系统 A 需要调用另一个系统 B 的某个接口，
但是 B 出于某种原因无法调通，我们并不关心 B 是否可用，只是期望它能够返回合适的数据，
来测试 A 系统是否正确实现。这时便可以使用 Mock 创建一个虚拟 B 对象，对 A 系统测试。

## Mockito


## 简单示例


```java
public class LocalTest {
    @Test
    public void localTest() {
        // 创建 mock 对象
        LocalTest localTest = Mockito.mock(LocalTest.class);
        // 设定返回值
        Mockito.when(localTest.sayHello("hello")).thenReturn("world");
        // 打印 world 而不是 hello
        System.out.println(localTest.sayHello("hello"));
    }

    public String sayHello(String msg) {
        return msg;
    }
}
```