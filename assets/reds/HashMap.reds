module Collections.HashMap

import Collections.Iter.*

/// A hash map implementation that preserves the insertion order of keys.
@privateConstructor("You should construct `HashMap` using `HashMap.New()` instead of the `new` operator")
public final class HashMap<K, V> {
  let impl: MapImpl;

  /// Creates a new instance of the `HashMap`.
  ///
  /// ### Example
  /// ```
  /// let map = HashMap.New();
  /// map.Set(2, "hey");
  /// map.Set(1, "hello");
  /// map.Iter().ForEach((v) -> FTLog(s"v: \(v)")); // "hey" then "hello"
  /// ```
  public static func New() -> HashMap<K, V> {
    let self = new HashMap();
    self.impl = new MapImpl();
    return self;
  }

  /// Retrieves the value associated with the given key.
  /// The returned entry will have the field `defined` set to true if the key was found.
  ///
  /// ### Example
  /// ```
  /// let map = HashMap.New();
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

  /// Returns an iterator over the entries in the map.
  public func Iter() -> Iter<Entry<K, V>> {
    return HashMapIterator.New(this.impl.Iter());
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
final class HashMapIterator<K, V> extends Iter<Entry<K, V>> {
  let impl: MapIteratorImpl;

  func HasNext() -> Bool = this.impl.HasNext();

  func Next() -> Entry<K, V> {
    let entry = this.impl.Next();
    return Entry(FromVariant<K>(entry[0]), FromVariant<V>(entry[1]));
  }
}

final native class MapImpl {
  public native func Get(key: Variant) -> Variant;

  public native func Set(key: Variant, value: Variant);

  public native func HasKey(key: Variant) -> Bool;

  public native func Iter() -> MapIteratorImpl;
}

final native class MapIteratorImpl {
  public native func HasNext() -> Bool;

  public native func Next() -> [Variant; 2];
}
