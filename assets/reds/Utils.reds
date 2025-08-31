module Collections.Utils

public enum Ordering {
  Less = -1,
  Equal = 0,
  Greater = 1,
}

public abstract class Comparator<-A> {
  public func Compare(lhs: A, rhs: A) -> Ordering;

  public final func On<B>(f: (B) -> A) -> Comparator<B> {
    return OnComparator.New(this, f);
  }

  public final func Reverse() -> Comparator<A> {
    return ReverseComparator.New(this);
  }
}

@deriveNew()
public final class Int32Comparator extends Comparator<Int32> {
  func Compare(lhs: Int32, rhs: Int32) -> Ordering {
    return lhs < rhs ? Ordering.Less : lhs > rhs ? Ordering.Greater : Ordering.Equal;
  }
}

@deriveNew()
public final class StringComparator extends Comparator<String> {
  func Compare(lhs: String, rhs: String) -> Ordering {
    let result = UnicodeStringCompare(lhs, rhs);
    return result < 0 ? Ordering.Less : result > 0 ? Ordering.Greater : Ordering.Equal;
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

