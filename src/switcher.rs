use std::io;

use crate::Direction;

pub trait WorkspaceTransport {
    fn send_workspace_switch(&mut self, direction: Direction) -> io::Result<()>;
    fn reconnect(&mut self) -> io::Result<()>;
}

pub struct WorkspaceSwitcher<T: WorkspaceTransport> {
    transport: T,
}

impl<T: WorkspaceTransport> WorkspaceSwitcher<T> {
    pub fn new(transport: T) -> Self {
        Self { transport }
    }

    pub fn switch(&mut self, direction: Direction) -> io::Result<()> {
        match self.transport.send_workspace_switch(direction) {
            Ok(()) => Ok(()),
            Err(first_err) => {
                self.transport.reconnect()?;
                self.transport
                    .send_workspace_switch(direction)
                    .map_err(|_| first_err)
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::{Error, ErrorKind};

    #[derive(Default)]
    struct FakeTransport {
        fail_first: bool,
        reconnect_ok: bool,
        sends: usize,
        reconnects: usize,
    }

    impl WorkspaceTransport for FakeTransport {
        fn send_workspace_switch(&mut self, _direction: Direction) -> io::Result<()> {
            self.sends += 1;
            if self.fail_first && self.sends == 1 {
                return Err(Error::new(ErrorKind::BrokenPipe, "simulated send failure"));
            }
            Ok(())
        }

        fn reconnect(&mut self) -> io::Result<()> {
            self.reconnects += 1;
            if self.reconnect_ok {
                Ok(())
            } else {
                Err(Error::new(ErrorKind::ConnectionRefused, "simulated reconnect failure"))
            }
        }
    }

    #[test]
    fn retries_once_after_send_failure() {
        let transport = FakeTransport {
            fail_first: true,
            reconnect_ok: true,
            ..Default::default()
        };
        let mut switcher = WorkspaceSwitcher::new(transport);
        assert!(switcher.switch(Direction::Next).is_ok());
    }

    #[test]
    fn fails_when_reconnect_fails() {
        let transport = FakeTransport {
            fail_first: true,
            reconnect_ok: false,
            ..Default::default()
        };
        let mut switcher = WorkspaceSwitcher::new(transport);
        assert!(switcher.switch(Direction::Prev).is_err());
    }
}
