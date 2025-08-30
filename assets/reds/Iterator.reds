module Collections.Iter

public abstract class Iter<A> {
  public func HasNext() -> Bool;

  public func Next() -> A;

  public func Map<B>(f: (A) -> B) -> Iter<B> = MapIter.New(this, f);

  public func Filter(predicate: (A) -> Bool) -> Iter<A> = FilterIter.New(this, predicate);

  public final func Find(predicate: (A) -> Bool) -> A {
    while this.HasNext() {
      let next = this.Next();
      if predicate(next) {
        return next;
      }
    }
  }

  public final func Fold<B>(initial: B, f: (B, A) -> B) -> B {
    let acc = initial;
    while this.HasNext() {
      acc = f(acc, this.Next());
    }
    return acc;
  }

  public final func ForEach(f: (A) -> Void) {
    while this.HasNext() {
      f(this.Next());
    }
  }

  public final func ToArray() -> [A] {
    let arr = [];
    while this.HasNext() {
      ArrayPush(arr, this.Next());
    }
    return arr;
  }
}

@deriveNew()
final class MapIter<A, B> extends Iter<B> {
  let inner: Iter<A>;
  let f: (A) -> B;

  func HasNext() -> Bool = this.inner.HasNext();

  func Next() -> B = this.f(this.inner.Next());
}

final class FilterIter<A> extends Iter<A> {
  let inner: Iter<A>;
  let predicate: (A) -> Bool;
  let current: A;

  public static func New(inner: Iter<A>, predicate: (A) -> Bool) -> FilterIter<A> {
    let self = new FilterIter();
    self.inner = inner;
    self.predicate = predicate;
    return self;
  }

  func HasNext() -> Bool {
    while this.inner.HasNext() {
      let next = this.inner.Next();
      if this.predicate(next) {
        this.current = next;
        return true;
      }
    }
    return false;
  }

  func Next() -> A = this.current;
}

