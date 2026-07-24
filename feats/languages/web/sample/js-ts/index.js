// Variable
const greeting = "Hello";

// Function
function greet(name) {
  return `${greeting}, ${name}!`;
}

// Class
class Person {
  constructor(name, age) {
    this.name = name;
    this.age = age;
  }

  introduce() {
    console.log(greet(this.name) + ` I am ${this.age} years old.`);
  }
}

// Example usage
const alice = new Person("Alice", 25);
const bob = new Person("Bob", 30);

alice.introduce();
bob.introduce();
