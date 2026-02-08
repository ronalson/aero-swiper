use std::env;
use std::io::{self, Read, Write};
use std::os::unix::net::UnixStream;
use std::path::PathBuf;

use crate::switcher::WorkspaceTransport;
use crate::Direction;

pub struct AerospaceSocket {
    socket_path: PathBuf,
    stream: Option<UnixStream>,
}

impl AerospaceSocket {
    pub fn new(socket_path: PathBuf) -> Self {
        Self {
            socket_path,
            stream: None,
        }
    }

    pub fn default_path() -> PathBuf {
        if let Ok(path) = env::var("AEROSPACE_SOCKET_PATH") {
            return PathBuf::from(path);
        }

        let user = env::var("USER").unwrap_or_else(|_| String::from("unknown"));
        PathBuf::from(format!("/tmp/bobko.aerospace-{user}.sock"))
    }

    fn connect(&mut self) -> io::Result<()> {
        let stream = UnixStream::connect(&self.socket_path)?;
        self.stream = Some(stream);
        Ok(())
    }

    fn send_request(&mut self, request: &str) -> io::Result<String> {
        if self.stream.is_none() {
            self.connect()?;
        }

        let stream = self
            .stream
            .as_mut()
            .ok_or_else(|| io::Error::new(io::ErrorKind::NotConnected, "socket not connected"))?;

        stream.write_all(request.as_bytes())?;
        stream.flush()?;

        let mut buf = [0u8; 4096];
        let n = stream.read(&mut buf)?;
        if n == 0 {
            return Err(io::Error::new(
                io::ErrorKind::UnexpectedEof,
                "aerospace socket closed connection",
            ));
        }

        let response = String::from_utf8_lossy(&buf[..n]).to_string();
        Ok(response)
    }
}

impl WorkspaceTransport for AerospaceSocket {
    fn send_workspace_switch(&mut self, direction: Direction) -> io::Result<()> {
        let ws = direction.workspace_arg();
        let req = format!(
            "{{\"command\":\"workspace\",\"stdin\":\"\",\"args\":[\"workspace\",\"{ws}\"]}}\n"
        );

        let resp = self.send_request(&req)?;
        if resp.contains("\"exitCode\":0") {
            Ok(())
        } else {
            Err(io::Error::new(
                io::ErrorKind::Other,
                format!("workspace command failed: {resp}"),
            ))
        }
    }

    fn reconnect(&mut self) -> io::Result<()> {
        self.stream = None;
        self.connect()
    }
}
