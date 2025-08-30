use std::cell::{Cell, RefCell};
use std::rc::Rc;

use indexmap::IndexMap;
use red4ext_rs::types::{IScriptable, RedString, Ref, Variant};
use red4ext_rs::{
    ClassExport, Exportable, Plugin, ScriptClass, ScriptClassOps, SemVer, U16CStr, class_kind,
    export_plugin_symbols, exports, methods, wcstr,
};
use smallvec::SmallVec;

mod version;

pub struct RedscriptCollections;

impl Plugin for RedscriptCollections {
    const AUTHOR: &'static U16CStr = wcstr!("jekky");
    const NAME: &'static U16CStr = wcstr!("redscript-collections");
    const VERSION: SemVer = SemVer::new(version::MAJOR, version::MINOR, version::PATCH);

    fn exports() -> impl Exportable {
        exports![
            ClassExport::<HashMapImpl>::builder()
                .methods(methods![
                    c"Get" => HashMapImpl::get,
                    c"Set" => HashMapImpl::set,
                    c"Iter" => HashMapImpl::iter,
                ])
                .build(),
            ClassExport::<HashMapIteratorImpl>::builder()
                .methods(methods![
                    c"Next" => HashMapIteratorImpl::next,
                    c"HasNext" => HashMapIteratorImpl::has_next,
                ])
                .build()
        ]
    }
}

export_plugin_symbols!(RedscriptCollections);

#[derive(Default, Clone)]
#[repr(C)]
struct HashMapImpl {
    _base: IScriptable,
    inner: Rc<RefCell<IndexMap<SmallVec<u8, 16>, Variant>>>,
}

impl HashMapImpl {
    fn get(&self, key: Variant) -> Variant {
        self.inner
            .borrow()
            .get(&key_as_bytes(key))
            .cloned()
            .unwrap_or_default()
    }

    fn set(&self, key: Variant, value: Variant) {
        self.inner.borrow_mut().insert(key_as_bytes(key), value);
    }

    fn iter(&self) -> Ref<IScriptable> {
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

    const NAME: &'static str = "Collections.HashMap.HashMapImpl";
}

fn key_as_bytes(mut key: Variant) -> SmallVec<u8, 16> {
    if let Some(str) = key.try_take::<RedString>() {
        str.to_bytes().into()
    } else {
        key.as_bytes().unwrap_or_default().into()
    }
}

#[derive(Default, Clone)]
#[repr(C)]
struct HashMapIteratorImpl {
    _base: IScriptable,
    inner: Rc<RefCell<IndexMap<SmallVec<u8, 16>, Variant>>>,
    position: Cell<usize>,
}

impl HashMapIteratorImpl {
    fn next(&self) -> Variant {
        let map = self.inner.borrow();
        let val = map
            .get_index(self.position.get())
            .map(|(_, v)| v.clone())
            .unwrap_or_default();
        self.position.set(self.position.get() + 1);
        val
    }

    fn has_next(&self) -> bool {
        let map = self.inner.borrow();
        self.position.get() < map.len()
    }
}

unsafe impl ScriptClass for HashMapIteratorImpl {
    type Kind = class_kind::Native;

    const NAME: &'static str = "Collections.HashMap.HashMapIteratorImpl";
}
