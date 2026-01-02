@startuml
class A { 
    - prop1
    + meth1()
}
class B { 
    - prop1 
    + meth2()
    # meth2()
}
class C { }
A -> B
B --> C
@enduml
