GraalVM is a universal virtual machine for running applications written in JavaScript, Python, Ruby, R, JVM-based languages like Java, Scala, Clojure, Kotlin, and LLVM-based languages such as C and C++.

## Truffle语言框架
功能：语言 -> AST --Graal 编译器-> 机械代码 

> 对于 C/C++ 静态语言，可以使用Sulong（顺便一提这个sulong是汉语的速（rapid）龙（dragon））。解决方案是将C/C++这些语言用一些工具（如clang）转换为LLVM IR，然后使用基于Truffle的AST解释LLVM IR，这个解释LLVM IR的东西就是Sulong