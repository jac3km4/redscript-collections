module Collections.BTreeMap

import Collections.Iter.*
import Collections.Utils.*

/// An ordered map based on a B-tree.
@privateConstructor("You should construct `BTreeMap` using `BTreeMap.New(comparator)` instead of the `new` operator")
public final class BTreeMap<K, V> {
  let impl: MapImpl;

  /// Creates a new BTreeMap with the given comparator, which is used to order of keys.
  ///
  /// ### Example
  /// ```
  /// let map = BTreeMap.New(Int32Comparator.New());
  /// map.Set(2, "hey");
  /// map.Set(1, "hello");
  /// map.Iter().ForEach((v) -> FTLog(s"v: \(v)")); // "hello" then "hey"
  /// ```
  public static func New(comp: Comparator<K>) -> BTreeMap<K, V> {
    let self = new BTreeMap();
    self.impl = MapImpl.New(comp.On((k) -> FromVariant<K>(k)));
    return self;
  }

  /// Retrieves the value associated with the given key.
  /// The returned entry will have the field `defined` set to true if the key was found.
  ///
  /// ### Example
  /// ```
  /// let map = BTreeMap.New(Int32Comparator.New());
  /// map.Set(1, "hello");
  /// let entry = map.Get(1);
  /// FTLog(s"Found: \(entry.value)"); // "Found: hello"
  /// ```
  public func Get(key: K) -> GetResult<K, V> {
    let variant = this.impl.Get(ToVariant(key));
    return GetResult(key, FromVariant(variant), IsDefined(variant));
  }

  /// Sets the value associated with the given key.
  public func Set(key: K, value: V) {
    this.impl.Set(ToVariant(key), ToVariant(value));
  }

  /// Checks if the map contains the given key.
  public func HasKey(key: K) -> Bool {
    return this.impl.HasKey(ToVariant(key));
  }

  /// Returns an iterator over the values in the map.
  public func Iter() -> Iter<Entry<K, V>> {
    return BTreeMapIterator.New(this.impl.Iter());
  }
}

/// Represents the result of a get operation on the map.
public struct GetResult<K, V> {
  /// The key associated with the entry.
  let key: K;
  /// The value associated with the entry.
  let value: V;
  /// Whether the entry is defined.
  let defined: Bool;
}

/// Represents an entry in the map.
public struct Entry<K, V> {
  /// The key associated with the entry.
  let key: K;
  /// The value associated with the entry.
  let value: V;
}

@deriveNew()
final class BTreeMapIterator<K, V> extends Iter<Entry<K, V>> {
  let impl: MapIteratorImpl;

  func HasNext() -> Bool = this.impl.HasNext();

  func Next() -> Entry<K, V> {
    let entry = this.impl.Next();
    return Entry(FromVariant<K>(entry[0]), FromVariant<V>(entry[1]));
  }
}

final native class MapImpl {
  public native static func New(comp: Comparator<Variant>) -> MapImpl;

  public native func Get(key: Variant) -> Variant;

  public native func Set(key: Variant, value: Variant);

  public native func HasKey(key: Variant) -> Bool;

  public native func Iter() -> MapIteratorImpl;
}

final native class MapIteratorImpl {
  public native func HasNext() -> Bool;

  public native func Next() -> [Variant; 2];
}
