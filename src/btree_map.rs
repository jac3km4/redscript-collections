use std::cell::RefCell;
use std::collections::BTreeMap;
use std::rc::Rc;

use red4ext_rs::types::{IScriptable, Ref, StaticArray, Variant};
use red4ext_rs::{ScriptClass, ScriptClassOps, call, class_kind};

use crate::util::Ordering;

#[derive(Default, Clone)]
#[repr(C)]
pub struct BTreeMapImpl {
    _base: IScriptable,
    inner: RefCell<BTreeMap<Key, Variant>>,
    comparator: Ref<IScriptable>,
}

impl BTreeMapImpl {
    pub fn new_ref(comparator: Ref<IScriptable>) -> Ref<IScriptable> {
        Self::new_ref_with(|this| {
            this.comparator = comparator;
        })
        .unwrap()
        .cast()
        .unwrap()
    }

    pub fn get(&self, key: Variant) -> Variant {
        self.inner
            .borrow()
            .get(&Key::new(key, self.comparator.clone()))
            .cloned()
            .unwrap_or_default()
    }

    pub fn set(&self, key: Variant, value: Variant) {
        self.inner
            .borrow_mut()
            .insert(Key::new(key, self.comparator.clone()), value);
    }

    pub fn has_key(&self, key: Variant) -> bool {
        self.inner
            .borrow()
            .contains_key(&Key::new(key, self.comparator.clone()))
    }

    pub fn iter(&self) -> Ref<IScriptable> {
        BTreeMapIteratorImpl::new_ref_with(|this| {
            this.inner = Rc::new(self.inner.borrow().clone().into_iter().into());
        })
        .unwrap()
        .cast()
        .unwrap()
    }
}

unsafe impl ScriptClass for BTreeMapImpl {
    type Kind = class_kind::Native;

    const NAME: &'static str = "Collections.BTreeMap.MapImpl";
}

#[derive(Default, Clone)]
#[repr(C)]
pub struct BTreeMapIteratorImpl {
    _base: IScriptable,
    inner: Rc<RefCell<std::collections::btree_map::IntoIter<Key, Variant>>>,
}

impl BTreeMapIteratorImpl {
    pub fn next(&self) -> StaticArray<Variant, 2> {
        let mut map = self.inner.borrow_mut();
        map.next()
            .map(|(k, v)| StaticArray::from([k.variant.clone(), v.clone()]))
            .unwrap_or_else(|| StaticArray::from([Variant::default(), Variant::default()]))
    }

    pub fn has_next(&self) -> bool {
        self.inner.borrow().len() > 0
    }
}

unsafe impl ScriptClass for BTreeMapIteratorImpl {
    type Kind = class_kind::Native;

    const NAME: &'static str = "Collections.BTreeMap.MapIteratorImpl";
}

#[derive(Clone)]
struct Key {
    variant: Variant,
    comparator: Ref<IScriptable>,
}

impl Key {
    fn new(variant: Variant, comparator: Ref<IScriptable>) -> Self {
        Self {
            variant,
            comparator,
        }
    }
}

impl PartialEq for Key {
    fn eq(&self, other: &Self) -> bool {
        let result = call!(self.comparator, "Compare;VariantVariant" (self.variant.clone(), other.variant.clone()) -> Ordering);
        result.unwrap() == Ordering::Equal
    }
}

impl Eq for Key {}

impl PartialOrd for Key {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for Key {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        let result = call!(self.comparator, "Compare;VariantVariant" (self.variant.clone(), other.variant.clone()) -> Ordering);
        result.unwrap().into()
    }
}
