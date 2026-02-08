pub mod gesture;
pub mod switcher;
pub mod transport;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Direction {
    Prev,
    Next,
}

impl Direction {
    pub fn workspace_arg(self) -> &'static str {
        match self {
            Self::Prev => "prev",
            Self::Next => "next",
        }
    }
}
