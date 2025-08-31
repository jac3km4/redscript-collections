module Collections.Array

import Collections.Utils.*
import Collections.Iter.*

public class ArrayIter<A> extends Iter<A> {
  let array: script_ref<[A]>;
  let index: Int32;

  public static func New(arr: script_ref<[A]>) -> ArrayIter<A> {
    let self = new ArrayIter();
    self.array = arr;
    self.index = 0;
    return self;
  }

  func HasNext() -> Bool {
    return this.index < ArraySize(Deref(this.array));
  }

  func Next() -> A {
    let value = this.array[this.index];
    this.index += 1;
    return value;
  }
}

public func SortArray<A>(out arr: [A], comp: Comparator<A>) {
  Quicksort(arr, 0, ArraySize(arr) - 1, comp);
}

func Quicksort<A>(out arr: [A], low: Int32, high: Int32, comp: Comparator<A>) {
  if low < high {
    let p = QuicksortPartition(arr, low, high, comp);
    Quicksort(arr, low, p - 1, comp);
    Quicksort(arr, p + 1, high, comp);
  }
}

func QuicksortPartition<A>(out arr: [A], low: Int32, high: Int32, comp: Comparator<A>) -> Int32 {
  let pivot = arr[high];
  let i = low - 1;
  let j = low;
  while j < high {
    if Equals(comp.Compare(arr[j], pivot), Ordering.Less) {
      i += 1;
      let temp = arr[i];
      arr[i] = arr[j];
      arr[j] = temp;
    }
    j += 1;
  }
  let temp = arr[i + 1];
  arr[i + 1] = arr[high];
  arr[high] = temp;
  return i + 1;
}

