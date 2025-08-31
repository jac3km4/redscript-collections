# redscript-collections

A collections library for REDscript.

## Array

### ArrayIter

Iterate over arrays with functional methods.

```reds
let arr = [1, 2, 3, 4, 5];
ArrayIter.New(arr).ForEach((val) -> FTLog(s"\(val)"));
```

### SortArray

Sort arrays in place.

```reds
let arr = [3, 1, 4, 1, 5];
SortArray(arr, Int32Comparator.New());
```

## HashMap

Hash map that preserves insertion order.

```reds
let map = HashMap.New();
map.Set("key", "value");
let result = map.Get("key");
if result.defined {
    FTLog(s"Found: \(result.value)");
}
map.Iter().ForEach((entry) -> FTLog(s"\(entry)"));
```

## BTreeMap

Ordered map sorted by keys.

```reds
let map = BTreeMap.New(Int32Comparator.New());
map.Set(2, "second");
map.Set(1, "first");

// Iterate in sorted order
map.Iter().ForEach((entry) -> FTLog(s"\(entry)"));

// Custom comparator using On
let tupleMap = BTreeMap.New(Int32Comparator.New().On((t: Tuple) -> t.first));
```
