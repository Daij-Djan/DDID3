DDID3
=====

A rudimentary objC wrapper for libid3 that works with OSX and IOS

-
For OSX, it is compiles to an embeddable framework that provides the main class `DDID3Tag` used to read or write or update a tag.

The framework comes with a separate **unit testing** bundle that assures minimal functionality: Reading, writing, cloning, celeting of a tag.

-

For IOS it compiles to a static library that needs libz, libiconv and libstdc++ (sorry for that dependency. I havent changed it to libc++ so far)

In the end it provides the same interface as the OSX framework. Namely the class `DDID3Tag` used to read or write or update a tag.

The IOS lib comes with a **demo app** that runs the same unit tests as the OSX version and also displays a tag content inside a UITextView.