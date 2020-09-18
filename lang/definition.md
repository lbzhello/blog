def hello p1 p2 type int int -> string do
    p3 = p1 + p2
    print "hello world"
    p3
end

def hello p1:int p2:int do
    p3 = p1 + p2
    print "hello world"
    p3
end


def hello p1:int p2:(int, long -> int -> string) -> string do
def hello p1:int, p2:(int, (long -> int) -> string) -> string do
    p3 = p1 + p2
    print "hello world"
    p3
end

let hello int, int -> string = {a, b -> str a b}

let a int = 3

def hello p1:()

def hello(p1:int, b:int) 

def hello p1:(int, int -> String, String)  p2:int -> rst: (int -> double) do
    p3 = p1 + p2
    print "hello world"
    rst = 3
end

def hello p1:(int, int -> String, String)  p2:int -> rst: (int -> double) = {
    p3 = p1 + p2
    print "hello world"
    rst = 3
}

def hello int int -> string do p1 p2 ->
    p3 = p1 + p2
    print "hello world"
    rst = 3
end

rst = hello 2 5

def f(x) = 2 + 3

def goods size
    name: "234"
    date: 2020-01-02

    def getName 
        name
    end
end

def ptest p1 do p1 end

parse /path/to/dir >> it.

true fals

num = 0
while i < num do

end