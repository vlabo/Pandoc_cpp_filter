# Pandoc C++ lua filter

A simple pandoc filter that compiles and runs c++ code from markdown code block and add the result to the output document.

### Example use:  
`pandoc --lua-filter cpp.lua test.md -o test.html`

### Requirements:
* Pandoc 2
* POSIX OS (Linux, Mac, ...)
* GCC

### Usege:
* hide: remove the code block from the output
* ignore: those not execute the code
* global: those not execute the code. Adds it to a global file that is include to each subsequent code block.


````markdown
This code will NOT be executed but added to the next block
```{.cpp global="ture"}

#include <iostream>
using namespace std;

```

This Code will be executed
```cpp
int main()
{
	cout << "Hello World" << endl;
}
```
**Result**: Hello World

This code will be ignored and hiden from the output
```{.cpp hide="true" ignore="true"}
#include <iostream>
using namespace std;

int main()
{
	cout << "Ignored result" << endl;
}
```
````
