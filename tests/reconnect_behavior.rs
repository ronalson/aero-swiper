use std::io;
use std::io::ErrorKind;

use aeroswiper::switcher::{WorkspaceSwitcher, WorkspaceTransport};
use aeroswiper::Direction;

struct FlakyTransport {
    fails_before_success: usize,
    reconnects: usize,
}

impl WorkspaceTransport for FlakyTransport {
    fn send_workspace_switch(&mut self, _direction: Direction) -> io::Result<()> {
        if self.fails_before_success > 0 {
            self.fails_before_success -= 1;
            return Err(io::Error::new(ErrorKind::BrokenPipe, "socket dropped"));
        }
        Ok(())
    }

    fn reconnect(&mut self) -> io::Result<()> {
        self.reconnects += 1;
        Ok(())
    }
}

#[test]
fn reconnect_and_retry_once() {
    let transport = FlakyTransport {
        fails_before_success: 1,
        reconnects: 0,
    };
    let mut switcher = WorkspaceSwitcher::new(transport);
    assert!(switcher.switch(Direction::Prev).is_ok());
}

#[test]
fn fails_after_second_send_error() {
    let transport = FlakyTransport {
        fails_before_success: 2,
        reconnects: 0,
    };
    let mut switcher = WorkspaceSwitcher::new(transport);
    assert!(switcher.switch(Direction::Next).is_err());
}
