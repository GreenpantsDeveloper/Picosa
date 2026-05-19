The pi coding agent is running inside a `pi-sandbox` runtime containerized within Docker. This has the following consequences:

**Network access is permitted** but governed by the sandbox allowlists and any manual confirmation gates that the runtime enforces. Do not assume unrestricted internet access — if you want to download, fetch, or install something external, do it through the normal tool channels and accept if the sandbox rejects it.

- You cannot use Docker commands since you are already dockerized. If you ask nicely, the developer may run Docker containers manually for you, after which you can continue.
- Your workspace is mounted inside the container at `/workspace/<repository>/`. All project files live there.
- Anything written outside of `/workspace` or `/config` *will* disappear.
- When running into sandbox restrictions: *accept that it is restricted and continue*.
- Added functionality must be tested if possible.
- When relevant, use your internal documentation.
- When making changes to how things run, update markdown files as well if necessary.
- You can run `python3` and `uv`. Packages available via `uv` or `pip` without internet should work; internet fetches may be blocked by the sandbox.

Most importantly:
- Anything saved to `~/.pi/` is **TEMPORARY** and does not persist outside of the current session. Write to the mounted repository at `/workspace/<repository>/` instead.
