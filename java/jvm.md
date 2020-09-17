CompressedClassSpace

JVM 有个功能是 CompressedOops ，目的是为了在 64bit 机器上使用 32bit 的原始对象指针（oop，ordinary object pointer，这里直接就当成指针概念理解就可以了，不用关心啥是 ordinary）
来节约成本（减少内存/带宽使用），提高性能（提高 Cache 命中率）。使用了这个压缩功能，每个对象中的 Klass* 字段就会被压缩成 32bit（不是所有的 oop 都会被压缩的），
总所周知 Klass* 指向的 Klass 在永久代（Java7 及之前）。但是在 Java8 及之后，永久代没了，有了一个 Metaspace，
于是之前压缩指针 Klass* 指向的这块 Klass 区域有了一个名字 —— Compressed Class Space。Compressed Class Space 是 Metaspace 的一部分，默认大小为 1G。
所以其实 Compressed Class Space 这个名字取得很误导，压缩的并不是 Klass，而是 Klass*。