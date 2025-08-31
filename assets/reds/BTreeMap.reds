module Collections.BTreeMap

import Collections.Iter.*
import Collections.Utils.*

public final class BTreeMap<K, V> {
  let impl: BTreeMapImpl;

  public static func New(comp: Comparator<K>) -> BTreeMap<K, V> {
    let self = new BTreeMap();
    self.impl = BTreeMapImpl.New(comp.On((k) -> FromVariant<K>(k)));
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
    return BTreeMapIterator.New(this.impl.Iter());
  }
}

public struct Entry<K, V> {
  let key: K;
  let value: V;
  let defined: Bool;
}

@deriveNew()
final class BTreeMapIterator<V> extends Iter<V> {
  let impl: BTreeMapIteratorImpl;

  func HasNext() -> Bool = this.impl.HasNext();

  func Next() -> V = FromVariant<V>(this.impl.Next());
}

final native class BTreeMapImpl {
  public native static func New(comp: Comparator<Variant>) -> BTreeMapImpl;

  public native func Get(key: Variant) -> Variant;

  public native func Set(key: Variant, value: Variant);

  public native func Iter() -> BTreeMapIteratorImpl;
}

final native class BTreeMapIteratorImpl {
  public native func HasNext() -> Bool;

  public native func Next() -> Variant;
}

