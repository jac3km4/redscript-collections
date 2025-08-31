use red4ext_rs::{
    ClassExport, Exportable, Plugin, SemVer, U16CStr, export_plugin_symbols, exports, methods,
    static_methods, wcstr,
};

use crate::btree_map::{BTreeMapImpl, BTreeMapIteratorImpl};
use crate::hash_map::{HashMapImpl, HashMapIteratorImpl};

mod btree_map;
mod hash_map;
mod util;
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
                    c"HasKey" => HashMapImpl::has_key,
                    c"Iter" => HashMapImpl::iter,
                ])
                .build(),
            ClassExport::<HashMapIteratorImpl>::builder()
                .methods(methods![
                    c"Next" => HashMapIteratorImpl::next,
                    c"HasNext" => HashMapIteratorImpl::has_next,
                ])
                .build(),
            ClassExport::<BTreeMapImpl>::builder()
                .methods(methods![
                    c"Get" => BTreeMapImpl::get,
                    c"Set" => BTreeMapImpl::set,
                    c"HasKey" => BTreeMapImpl::has_key,
                    c"Iter" => BTreeMapImpl::iter,
                ])
                .static_methods(static_methods![
                    c"New" => BTreeMapImpl::new_ref,
                ])
                .build(),
            ClassExport::<BTreeMapIteratorImpl>::builder()
                .methods(methods![
                    c"Next" => BTreeMapIteratorImpl::next,
                    c"HasNext" => BTreeMapIteratorImpl::has_next,
                ])
                .build()
        ]
    }
}

export_plugin_symbols!(RedscriptCollections);
