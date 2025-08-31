module Collections.HashMap

import Collections.Iter.*

public final class HashMap<K, V> {
  let impl: HashMapImpl;

  public static func New() -> HashMap<K, V> {
    let self = new HashMap();
    self.impl = new HashMapImpl();
    return self;
  }

  public func Get(key: K) -> Entry<K, V> {
    let variant = this.impl.Get(ToVariant(key));
    return Entry(key, FromVariant(variant), IsDefined(variant));
  }

  public func Set(key: K, value: V) {
    this.impl.Set(ToVariant(key), ToVariant(value));
  }

  public func Iter() -> Iter<V> {
    return HashMapIterator.New(this.impl.Iter());
  }
}

public struct Entry<K, V> {
  let key: K;
  let value: V;
  let defined: Bool;
}

@deriveNew()
final class HashMapIterator<V> extends Iter<V> {
  let impl: HashMapIteratorImpl;

  func HasNext() -> Bool = this.impl.HasNext();

  func Next() -> V = FromVariant<V>(this.impl.Next());
}

final native class HashMapImpl {
  public native func Get(key: Variant) -> Variant;

  public native func Set(key: Variant, value: Variant);

  public native func Iter() -> HashMapIteratorImpl;
}

final native class HashMapIteratorImpl {
  public native func HasNext() -> Bool;

  public native func Next() -> Variant;
}

