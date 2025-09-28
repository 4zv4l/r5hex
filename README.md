# r5hex

Toy UDP server serving md5 hex digest to be broken.

# Usage

```
Usage:
  ./r5hex.raku [-d|--db=<Str>] [-i|--ip=<Str>] [-p|--port[=UInt]] <file>
                                                                                             
    <file>              Path to file containing hashes to be loaded
    -d|--db=<Str>       Database file path [default: 'hashes.db']
    -i|--ip=<Str>       Bind to this address [default: 'localhost']
    -p|--port[=UInt]    Bind to this port [default: 9988]
```

To receive a hash, send `GIMME` to the server.  
To upload a hash/plain, send `<hex digest> <plain>`.  
