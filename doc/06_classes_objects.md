# Classes and Objects

Daydream is object-oriented and supports class-based inheritance.

## Defining a Class

Use the `class` keyword. A special `constructor` method is called when creating an instance.

```javascript
class Animal {
    fn constructor(name) {
        this.name = name;
    }

    fn speak() {
        print($"{this.name} makes a noise.");
    }
}
```

## Creating Instances

Use the `new` keyword.

```javascript
var dog = new Animal("Rex");
dog.speak(); // "Rex makes a noise."
```

## Inheritance

Classes can extend other classes using `extends`. Use `super` to access the parent class.

```javascript
class Dog extends Animal {
    fn constructor(name, breed) {
        super(name); // Call parent constructor
        this.breed = breed;
    }

    fn speak() {
        print($"{this.name} (the {this.breed}) barks!");
    }
}

var d = new Dog("Buddy", "Golden Retriever");
d.speak(); // "Buddy (the Golden Retriever) barks!"
```

## Static Members

Static members belong to the class itself, not instances.

```javascript
class MathUtils {
    static fn add(a, b) {
        return a + b;
    }
}

print(MathUtils.add(10, 5));
```

Inside a method, `this` refers to the current instance.

## Keywords as Property Names

Reserved keywords can be used as property names when accessed via the dot (`.`) or optional chaining (`?.`) operators.

```javascript
var obj = {
    default: "Value",
    if: true,
};

print(obj.default); // "Value"
print(obj.if); // true
```
