module Collections.Utils

/// Represents the result of a comparison between two values.
public enum Ordering {
  Less = -1,
  Equal = 0,
  Greater = 1,
}

/// A comparator for values of type `A`.
public abstract class Comparator<-A> {
  /// Compares two values and returns an `Ordering`.
  public func Compare(lhs: A, rhs: A) -> Ordering;

  /// Returns a new comparator that applies the given function to the left-hand side
  /// value before comparing. It can be used to create comparators for more complex
  /// types from simple scalar comparators.
  ///
  /// ### Example
  /// ```
  /// let comp = Int32Comparator.New();
  /// let structComp = comp.On((x: Struct) => x.field);
  /// ```
  public final func On<B>(f: (B) -> A) -> Comparator<B> = OnComparator.New(this, f);

  /// Returns a new comparator that reverses the order of the elements.
  public final func Reverse() -> Comparator<A> = ReverseComparator.New(this);
}

/// A comparator for values of type `Int32`.
@deriveNew()
public final class Int32Comparator extends Comparator<Int32> {
  func Compare(lhs: Int32, rhs: Int32) -> Ordering {
    return lhs < rhs ? Ordering.Less : lhs > rhs ? Ordering.Greater : Ordering.Equal;
  }
}

/// A comparator for values of type `Int64`.
@deriveNew()
public final class Int64Comparator extends Comparator<Int64> {
  func Compare(lhs: Int64, rhs: Int64) -> Ordering {
    return lhs < rhs ? Ordering.Less : lhs > rhs ? Ordering.Greater : Ordering.Equal;
  }
}

/// A comparator for values of type `Uint32`.
@deriveNew()
public final class Uint32Comparator extends Comparator<Uint32> {
  func Compare(lhs: Uint32, rhs: Uint32) -> Ordering {
    return lhs < rhs ? Ordering.Less : lhs > rhs ? Ordering.Greater : Ordering.Equal;
  }
}

/// A comparator for values of type `Uint64`.
@deriveNew()
public final class Uint64Comparator extends Comparator<Uint64> {
  func Compare(lhs: Uint64, rhs: Uint64) -> Ordering {
    return lhs < rhs ? Ordering.Less : lhs > rhs ? Ordering.Greater : Ordering.Equal;
  }
}

/// A comparator for values of type `Float`.
@deriveNew()
public final class FloatComparator extends Comparator<Float> {
  func Compare(lhs: Float, rhs: Float) -> Ordering {
    return lhs < rhs ? Ordering.Less : lhs > rhs ? Ordering.Greater : Ordering.Equal;
  }
}

/// A comparator for values of type `Double`.
@deriveNew()
public final class DoubleComparator extends Comparator<Double> {
  func Compare(lhs: Double, rhs: Double) -> Ordering {
    return lhs < rhs ? Ordering.Less : lhs > rhs ? Ordering.Greater : Ordering.Equal;
  }
}

/// A comparator for values of type `String`.
@deriveNew()
public final class StringComparator extends Comparator<String> {
  func Compare(lhs: String, rhs: String) -> Ordering {
    let result = UnicodeStringCompare(lhs, rhs);
    return result < 0 ? Ordering.Less : result > 0 ? Ordering.Greater : Ordering.Equal;
  }
}

/// A comparator for arrays.
@deriveNew()
public final class ArrayComparator<A> extends Comparator<[A]> {
  let elementComparator: Comparator<A>;

  func Compare(lhs: [A], rhs: [A]) -> Ordering {
    let lhsSize = ArraySize(lhs);
    let rhsSize = ArraySize(rhs);
    let last = Min(lhsSize, rhsSize);
    let i = 0;
    while i < last {
      let ord = this.elementComparator.Compare(lhs[i], rhs[i]);
      if ord != Ordering.Equal {
        return ord;
      }
      i += 1;
    }
    return lhsSize < rhsSize ? Ordering.Less : lhsSize > rhsSize ? Ordering.Greater : Ordering.Equal;
  }
}

@deriveNew()
final class OnComparator<A, B> extends Comparator<B> {
  let inner: Comparator<A>;
  let f: (B) -> A;

  func Compare(lhs: B, rhs: B) -> Ordering {
    return this.inner.Compare(this.f(lhs), this.f(rhs));
  }
}

@deriveNew()
final class ReverseComparator<A> extends Comparator<A> {
  let inner: Comparator<A>;

  func Compare(lhs: A, rhs: A) -> Ordering {
    switch this.inner.Compare(lhs, rhs) {
      case Ordering.Less:
        return Ordering.Greater;
      case Ordering.Greater:
        return Ordering.Less;
      case Ordering.Equal:
        return Ordering.Equal;
    }
  }
}

