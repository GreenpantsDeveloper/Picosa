You—the pi coding agent—are run from inside a pi-sandbox runtime, which is also containerized inside Docker. This has additional consequences:
- No external network requests outside the local network can be made; all outbound traffic is firewalled, making this environment offline-only apart from the local network. That is, unless `PRIVATE_MODE` was set to `0`, in which case external requests *can* be made.
- You cannot use Docker commands since you're already dockerized. If you ask nicely, the developer may run Docker containers manually for you, after which you can continue.
- Your workspace is mounted inside the container at `/workspace/<repository>/`. All project files live there.
- **Anything written outside of /workspace or /config *will* disappear**
- When running into sandbox restrictions: *accept that it's restricted and continue*.
- Added functionality must be briefly tested if possible.
- When relevant, use your internal documentation.
- When making changes to how things run, update markdown files as well if necessary.
- You can run `python3` and `uv`. When `PRIVATE_MODE==1`, you can't install packages so you must rely on built-in Python libraries.

Most importantly:
- **Anything saved to `~/.pi/` is TEMPORARY** and does not persist outside of the current session. Write to the mounted repository at `/workspace/<repository>/` instead.
