def max(a, b, c, d, e) {
    a = 3
    b = 4
    c = a + b
}

a = 23
b = 44

max(1, 2)(4, 5)[6, 7]{
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

a = f()

outNo = 55

// union
// define context (参数访问不到)
def flow (a)(b){
    a + b + $1
}{
    a * b - $3
}

flow(3)(4)

flow(3, 4){
    outNo - it
}  

(flow 3 4)

  0   1 2