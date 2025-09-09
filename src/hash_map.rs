use std::borrow::Borrow;
use std::cell::{Cell, RefCell};
use std::rc::Rc;

use indexmap::IndexMap;
use red4ext_rs::types::{IScriptable, RedString, Ref, StaticArray, Variant};
use red4ext_rs::{ScriptClass, ScriptClassOps, class_kind};
use smallvec::SmallVec;

#[derive(Default, Clone)]
#[repr(C)]
pub struct HashMapImpl {
    _base: IScriptable,
    inner: Rc<RefCell<IndexMap<Key, Variant>>>,
}

impl HashMapImpl {
    pub fn get(&self, key: Variant) -> Variant {
        RefCell::borrow(&self.inner)
            .get(get_key_bytes(&key))
            .cloned()
            .unwrap_or_default()
    }

    pub fn set(&self, key: Variant, value: Variant) {
        self.inner.borrow_mut().insert(Key::from(key), value);
    }

    pub fn has_key(&self, key: Variant) -> bool {
        RefCell::borrow(&self.inner).contains_key(get_key_bytes(&key))
    }

    pub fn iter(&self) -> Ref<IScriptable> {
        HashMapIteratorImpl::new_ref_with(|this| {
            this.inner = self.inner.clone();
        })
        .unwrap()
        .cast()
        .unwrap()
    }
}

unsafe impl ScriptClass for HashMapImpl {
    type Kind = class_kind::Native;

    const NAME: &'static str = "Collections.HashMap.MapImpl";
}

#[derive(Default, Clone)]
#[repr(C)]
pub struct HashMapIteratorImpl {
    _base: IScriptable,
    inner: Rc<RefCell<IndexMap<Key, Variant>>>,
    position: Cell<usize>,
}

impl HashMapIteratorImpl {
    pub fn next(&self) -> StaticArray<Variant, 2> {
        let map = RefCell::borrow(&self.inner);
        let entry = map
            .get_index(self.position.get())
            .map(|(k, v)| StaticArray::from([k.variant.clone(), v.clone()]))
            .unwrap_or_else(|| StaticArray::from([Variant::default(), Variant::default()]));
        self.position.set(self.position.get() + 1);
        entry
    }

    pub fn has_next(&self) -> bool {
        let map = RefCell::borrow(&self.inner);
        self.position.get() < map.len()
    }
}

unsafe impl ScriptClass for HashMapIteratorImpl {
    type Kind = class_kind::Native;

    const NAME: &'static str = "Collections.HashMap.MapIteratorImpl";
}

#[derive(Clone)]
struct Key {
    variant: Variant,
    encoded: SmallVec<u8, 16>,
}

impl From<Variant> for Key {
    fn from(variant: Variant) -> Self {
        let encoded = get_key_bytes(&variant).into();
        Self { variant, encoded }
    }
}

fn get_key_bytes(value: &Variant) -> &[u8] {
    if let Some(str) = value.try_access::<RedString>() {
        str.to_bytes()
    } else {
        value.as_bytes().unwrap_or_default()
    }
}

impl Borrow<[u8]> for Key {
    #[inline]
    fn borrow(&self) -> &[u8] {
        &self.encoded
    }
}

impl PartialEq for Key {
    #[inline]
    fn eq(&self, other: &Self) -> bool {
        self.encoded == other.encoded
    }
}

impl Eq for Key {}

impl std::hash::Hash for Key {
    #[inline]
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.encoded.hash(state);
    }
}
