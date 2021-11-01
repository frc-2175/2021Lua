# Metadesk

In our project we use Metadesk to automatically generate bindings for WPILib C++ functions for our LuaJIT FFI. The documentation for these WPILib functions can be found [here.](https://first.wpi.edu/wpilib/allwpilib/docs/release/cpp/index.html)


## Why?

Because many of the WPILib functions return or use thier own datatypes as arguments. This presents a challenge as those datatypes don't exist in C. In fact, C doesn't natively support many of the datatypes found in vanilla C++(strings and vectors for example).

## How?

We use the file [bindings.metadesk](src/bindings/bindings.metadesk) to generate these bindings. The file can seem daunting at first, especially because of it's lack of syntax highlighting, however it's basic structure isn't actually too bad.

### Nodes
At the top level we have nodes. Each of these generate their own `.cpp`  files. Often above each node will be an `@include` tag, but we'll get to those later. Nodes serve as a grouping of related classes, functions, methods, and values. 

### Classes
Within most of these nodes will be classes. These corespond to the classes found in the WPILib C++ library. You can find a full list of these classes [here.](https://first.wpi.edu/wpilib/allwpilib/docs/release/cpp/annotated.html) In layman's terms, a class in C++ acts like it's own datatype with a collection of data and functions. These classes are specified with the `@class` tag. As an example, the first class accessed in the metadesk file is the `frc::Joystick` class, so we write `@class("frc::Joystick")` before the group of functions and data that belong to that class. Without the class, Metadesk won't know what function you're trying to call, and you'll get an empty function that doesn't do anything.

### Functions
Inside each of these classes will be functions. This is the real meat of the file. Since the purpose of the file is to generate functions, it makes since that this is the important part. 

Most functions will begin with a datatype(int, float, double, bool, const char\*) which specifies what kind of data the function will return. Some functions, however, won't. These are called void functions and are often used to set or change existing values. The WPILib documentation will specify what type a function is.