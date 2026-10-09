class TopicSubtopic {
  static const List<String> cTopics = [
    "1. Basics and I/O",
    "2. Operators and Expressions",
    "3. Conditional Statements",
    "4. Loops and Iteration",
    "5. Functions",
    "6. Arrays",
    "7. Strings",
    "8. Pointers",
    "9. Dynamic Memory Allocation",
    "10. Structures",
    "11. Unions and Enums",
    "12. File Handling"
  ];

  static const cSubTopics = [
    ["Keywords, Identifiers, Data Types", "Input and Output (printf, scanf)", "Type Conversion"],
    ["Arithmetic, Relational, Logical, Assignment, Bitwise Operators", "Increment/Decrement", "Ternary Operator", "Operator Precedence"],
    ["if, if-else, else-if ladder", "switch-case", "goto (with caution)"],
    ["for, while, do-while loops", "Nested loops", "break and continue"],
    ["Function declaration and definition", "Parameters and return values", "Recursion", "Storage classes"],
    ["1D and 2D arrays", "Array traversal", "Array manipulation", "Multidimensional arrays"],
    ["Using string.h functions", "Manual string operations (without string.h)", "Character arrays"],
    ["Pointer basics", "Pointer arithmetic", "Pointers with arrays and functions", "Double pointers"],
    ["malloc, calloc, realloc, free", "Common memory errors", "Memory leak prevention"],
    ["Defining structures", "Nested structures", "Arrays of structures", "Pointers to structures", "Unions"],
    ["This is all about enums and unions "],
    ["File pointers", "fopen, fclose, fprintf, fscanf", "fgets, fputs", "Text vs Binary files", "File modes and error handling"]
  ];

  static const cFileNames = [
    'basics', 'operators', 'conditional', 'loops', 'functions', 'arrays', 'strings', 'pointers', 'dynamic', 'structures', 'enums', 'files'
  ];

  static const List<String> cppTopics = [
    "1. Input/Output & Basic Syntax",
    "2. Operators and Expressions",
    "3. Conditional Statements",
    "4. Loops and Iteration",
    "5. Functions",
    "6. Arrays and Strings",
    "7. Pointers and References",
    "8. Object-Oriented Programming",
    "9. Inheritance and Polymorphism",
    "10. STL and Containers",
    "11. File Handling",
    "12. Exception Handling and Templates"
  ];

  static const cppSubTopics = [
    ["cin, cout, data types, basic program structure"],
    ["Arithmetic, logical, bitwise, comparison, compound assignment"],
    ["if, if-else, else-if, switch-case, nested conditions"],
    ["for loop, while loop, do-while, nested loops, loop control"],
    ["Function definition and calling, parameters, recursion, overloading"],
    ["1D and 2D arrays, string manipulation, character arrays"],
    ["Pointers, pointer arithmetic, dynamic memory with new/delete, references"],
    ["Classes and objects, constructors/destructors, static members, encapsulation"],
    ["Single/multiple/multilevel inheritance, function overriding, virtual functions"],
    ["vector, list, map, set, stack, queue, iterators, algorithms"],
    ["Reading/writing files, file modes, binary vs text I/O"],
    ["try-catch, custom exceptions, function/class templates"]
  ];

  static const cppFileNames = [
    'basics', 'operators', 'conditional', 'loops', 'functions', 'arrays_strings', 'pointers', 'oops', 'inheritance', 'stl', 'files', 'exception'
  ];

  static const List<String> pythonTopics = [
    "1. Variables and Input/Output",
    "2. Operators and Expressions",
    "3. Conditional Statements",
    "4. Loops and Iteration",
    "5. Functions and Recursion",
    "6. Lists and Tuples",
    "7. Dictionaries and Sets",
    "8. String Manipulation",
    "9. File Handling",
    "10. Exception Handling",
    "11. Classes and Objects",
    "12. Functional Programming and Comprehensions"
  ];

  static const pyFileNames = [
    'variables', 'operators', 'conditional', 'loops', 'functions', 'lists', 'dict_sets', 'strings', 'files', 'exception', 'class', 'functional'
  ];

  static const pythonSubTopics = [
    ["input(), print(), type conversion, basic syntax"],
    ["Arithmetic, comparison, logical, assignment, identity operators"],
    ["if, elif, else, nested conditions"],
    ["for loop, while loop, break, continue, range()"],
    ["def, return, arguments, default/keyword args, recursion"],
    ["Creating, indexing, slicing, nested lists, list methods"],
    ["Creating dicts/sets, keys/values, adding/removing/searching"],
    ["String slicing, formatting, built-in methods, raw strings"],
    ["read/write text files, file modes, with statement"],
    ["try-except, finally, raise custom errors"],
    ["Defining classes, __init__, self, inheritance, method overriding"],
    ["lambda, map, filter, reduce, list/dict comprehensions"]
  ];

  static const List<String> javaTopics = [
    "1. Input/Output & Data Types",
    "2. Operators and Expressions",
    "3. Control Flow (if/switch)",
    "4. Loops and Iteration",
    "5. Methods",
    "6. Arrays and Strings",
    "7. Object-Oriented Programming",
    "8. Inheritance and Polymorphism",
    "9. Exception Handling",
    "10. File I/O",
    "11. Collections Framework",
    "12. Basic Multithreading"
  ];

  static const javaFileNames = [
    'basics', 'operators', 'controlflow', 'loops', 'functions', 'arrays_strings', 'oops2', 'inheritance_polymorphism', 'exceptoin', 'files', 'collections', 'multithread'
  ];

  static const javaSubTopics = [
    ["Scanner input, System.out.println", "Primitive types, Type casting"],
    ["Arithmetic, logical, comparison, assignment, ternary"],
    ["if-else, nested if, switch-case"],
    ["for, while, do-while, break, continue"],
    ["Method creation, return types, parameters, recursion"],
    ["1D/2D arrays, String operations, StringBuilder"],
    ["Classes/Objects, Constructors, Static/Instance members"],
    ["Inheritance, Method Overriding, Polymorphism, super"],
    ["try-catch, finally, custom exceptions, throw/throws"],
    ["FileReader/FileWriter, BufferedReader, reading/writing files"],
    ["List, Set, Map, ArrayList, HashMap, Iterators"],
    ["Thread class, Runnable interface, thread lifecycle"]
  ];

  static const List<String> htmlTopics = [
    "1. Basic Structure",
    "2. Text Formatting",
    "3. Lists",
    "4. Links and Images",
    "5. Tables",
    "6. Forms and Input",
    "7. Semantic Elements",
    "8. Media Elements",
    "9. HTML5 APIs"
  ];

  static const htmlSubTopics = [
    ["DOCTYPE, html, head, body"],
    ["h1-h6, p, span, strong, em"],
    ["ul, ol, li, nested lists"],
    ["a href, img src, alt, target"],
    ["table, tr, td, th, colspan, rowspan"],
    ["form, input types, textarea, select, label, button"],
    ["section, article, header, footer, aside, nav"],
    ["audio, video, source, controls"],
    ["canvas, geolocation, localStorage, data-* attributes"]
  ];

  static const List<String> jsTopics = [
    "1. Variables and Data Types",
    "2. Operators and Expressions",
    "3. Conditional Statements",
    "4. Loops and Iteration",
    "5. Functions and Scope",
    "6. Arrays and Objects",
    "7. DOM Manipulation",
    "8. Events",
    "9. ES6+ Features",
    "10. JSON and Fetch API"
  ];

  static const jsSubTopics = [
    ["var, let, const, typeof, conversions"],
    ["+, -, ==, ===, !=, &&, ||, ternary"],
    ["if, else, switch"],
    ["for, while, for-in, for-of, break, continue"],
    ["Function declaration, arrow functions, closures"],
    ["Array methods (push, pop, map, filter)", "Object creation/access"],
    ["document.getElementById/querySelector, innerHTML, style"],
    ["onclick, addEventListener, form events"],
    ["Destructuring, Spread/Rest, let/const, template literals"],
    ["JSON.parse/stringify, fetch(), async/await"]
  ];

  static List<String> get topics => cTopics;
  static List<String> getSubtopics(String topic) {
    int index = cTopics.indexOf(topic);
    if (index != -1 && index < cSubTopics.length) {
      return cSubTopics[index];
    }
    return [];
  }
}
