module Collections.Iter

/// An iterator over a collection of elements of type `A`.
/// Iterators must be consumed by calling `HasNext` and then `Next`, until `HasNext` returns false.
/// It's necessary to call `HasNext` before `Next` in order for the iterator to function correctly.
///
/// ### Example
/// ```
/// while iter.HasNext() {
///   let value = iter.Next();
///   Log(value);
/// }
/// ```
public abstract class Iter<A> {
  /// Returns true if the iterator has more elements.
  public func HasNext() -> Bool;

  /// Returns the next element in the iterator.
  public func Next() -> A;

  /// Maps the elements of the iterator using the provided function.
  ///
  /// ### Example
  /// ```
  /// iter.Map((x) => x * 2);
  /// ```
  public func Map<B>(f: (A) -> B) -> Iter<B> = MapIter.New(this, f);

  /// Filters the elements of the iterator using the provided predicate.
  ///
  /// ### Example
  /// ```
  /// iter.Filter((x) => x % 2 == 0);
  /// ```
  public func Filter(predicate: (A) -> Bool) -> Iter<A> = FilterIter.New(this, predicate);

  /// Finds the first element in the iterator that matches the provided predicate.
  ///
  /// ### Example
  /// ```
  /// let result = iter.Find((x) => x == 3);
  /// ```
  public final func Find(predicate: (A) -> Bool) -> A {
    while this.HasNext() {
      let next = this.Next();
      if predicate(next) {
        return next;
      }
    }
  }

  /// Folds the elements of the iterator using the provided initial value and function.
  /// The function is applied to each element in the iterator, threading an accumulator
  /// through the computation.
  ///
  /// ### Example
  /// ```
  /// let sum = iter.Fold(0, (acc, x) => acc + x);
  /// ```
  public final func Fold<B>(initial: B, f: (B, A) -> B) -> B {
    let acc = initial;
    while this.HasNext() {
      acc = f(acc, this.Next());
    }
    return acc;
  }

  /// Applies the given function to each element in the iterator.
  ///
  /// ### Example
  /// ```
  /// iter.ForEach((x) => FTLog(s"\(x)"));
  /// ```
  public final func ForEach(f: (A) -> Void) {
    while this.HasNext() {
      f(this.Next());
    }
  }

  /// Converts the iterator to an array.
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

