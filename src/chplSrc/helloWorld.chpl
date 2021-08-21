
module CalliopeNET {
    var _globalDomain: domain(int);
    var _globalArray: [_globalDomain] real;
    var _globalDomainSize: int;

    var _globalDataArray: [0..4000] bytes;
    var _currentArrayStart: atomic int;
    
    var _pointerArrayDomain: domain(string);
    var _pointerArray: [_pointerArrayDomain] _dataPointerClass;

    record _dataPointerClass {
        var startPosition: int;
        var endPosition: int;
        var size: int;
    }

    export proc getArrayPosition(dataSize: int, dataName: c_string): int {
        var newDataPointer = new _dataPointerClass();
        newDataPointer.startPosition = _currentArrayStart.fetchAdd(dataSize);
        newDataPointer.endPosition = newDataPointer.startPosition + dataSize;
        newDataPointer.size = dataSize;
        _pointerArrayDomain.add(dataName : string);
        _pointerArray[dataName : string] = newDataPointer;
        return newDataPointer.startPosition;
    }

    export proc myFunc(x: int) : int {
        writeln(x);
        forall msg in 1..x do
          writeln("Hello, world! (from iteration ", msg, " of ", x, ")");
        return 10;
    }
    
    export proc createArray(n: int) {
        writeln(n);
        _globalDomainSize = n;
        for i in 1..n do
        {
            _globalDomain.add(i);
        }
            
        writeln(_globalArray);
    }
    
    export proc addToArray(x: int) {
        coforall i in 1.._globalDomainSize do
          _globalArray[i] += x;
        writeln(_globalArray);
    }
}

