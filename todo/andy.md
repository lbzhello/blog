def max(a, b, c, d, e) {
    a = 3
    b = 4
    c = a + b
}

a = 23
b = 44

max (1, 2) (4, 5) [6, 7] {
    rst = if(a > b) a else b
    rst * 3
}{it -> 
    5
    6
    8
}

f(x)(y = 3) = {
    x + y
}

def partial(a)(b)(c) {
    ...
}

pa = partial(1)
pa2 = pa(2)

def varparam(a...) {

}

varparam([1, 2])

varparam[8]

arr = [1 2 3 4 5 6 7]
arr[1 3]  // [2 3]

def f(1, 2) {
    $0 + $1    
}

a = f 13 14

outNo = 55

// union
// define context (参数访问不到)
def flow (a)(b){
    a + b + $1
}{
    a * b - $3
}

flow 3 4

flow(3, 4){
    outNo - it
}  

(flow 3 4)

sort myListA myListB myListC

sort (myListA myListB myListC)

if flag || test a b {

}

if (test a b) != nil

(if a > b)


if max 5 7 > min 7 9 2

test pa1 left > right

? myf p1 p2 > 45 || test1 6 8 && print 9 4 {

} else {
    
}

for i in [1 2 3 4 5] {

}

myif 8 > 6 {
    
}

函数如果位于单独的一行，可以省略括号