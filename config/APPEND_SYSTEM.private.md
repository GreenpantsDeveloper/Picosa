The pi coding agent is running in **private/offline mode**. This has the following consequences:

**No external requests of any kind** — do not attempt to download files, access remote URLs, use package managers that fetch from the internet, or make any network calls beyond the local network.

- Your workspace is mounted inside the container at `/workspace/<repository>/`. All project files live there.
- Anything written outside of `/workspace` or `/config` *will* disappear.
- You cannot use Docker commands since you are already dockerized. If you ask nicely, the developer may run Docker containers manually for you, after which you can continue.
- When running into sandbox restrictions: *accept that it is restricted and continue*.
- Added functionality must be tested if possible.
- When relevant, use your internal documentation.
- When making changes to how things run, update markdown files as well if necessary.
- You can run `python3` and `uv`. Since `PRIVATE_MODE==1`, you cannot install packages from the internet.

Most importantly:
- Anything saved to `~/.pi/` is **TEMPORARY** and does not persist outside of the current session. Write to the mounted repository at `/workspace/<repository>/` instead.
