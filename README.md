# r5hex

Toy UDP server serving md5 hex digest to be broken.

# Usage

```
Usage:
  ./server.raku [-d=<Str>] [-i=<Str>] [-p[=UInt]] <file>

    <file>       Path to file containing hashes to be loaded
    -d=<Str>     Database file path [default: 'hashes.db']
    -i=<Str>     Bind to this address [default: 'localhost']
    -p[=UInt]    Bind to this port [default: 9988]
```

To receive a hash, send `GIMME` to the server.  
To upload a hash/plain, send `<hex digest> <plain>`.  
