use red4ext_rs::NativeRepr;

#[derive(Debug, Default, Clone, Copy, PartialEq, Eq)]
pub enum Ordering {
    Less = -1,
    #[default]
    Equal = 0,
    Greater = 1,
}

impl From<Ordering> for std::cmp::Ordering {
    fn from(value: Ordering) -> Self {
        match value {
            Ordering::Less => std::cmp::Ordering::Less,
            Ordering::Equal => std::cmp::Ordering::Equal,
            Ordering::Greater => std::cmp::Ordering::Greater,
        }
    }
}

unsafe impl NativeRepr for Ordering {
    const NAME: &'static str = "Collections.Utils.Ordering";
}
