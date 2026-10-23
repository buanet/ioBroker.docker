# Building a local ioBroker Docker image

Prerequisites: Bash, GNU sed (Linux or WSL), Docker with a running daemon,
and internet access for the build process.

```bash
cd ioBroker.docker/localbuild
chmod +x build-local.sh
./build-local.sh --debian trixie --node 24
```

By default, the image is named `iobroker-local:trixie-node24` and is stored
in the local Docker environment. The script locates the repository based on
its own file path; the command works from other working directories as well.

```bash
./build-local.sh --debian bookworm --node 22 --tag iobroker:test
./build-local.sh --debian trixie --node 24 --pull --no-cache
./build-local.sh --debian trixie --node 24 --platform linux/arm64
```

| Parameter            | Default / Meaning                                     |
| -------------------- | ----------------------------------------------------- |
| `--debian NAME`      | `trixie`; specify without `-slim`                     |
| `--node MAJOR`       | `24`; major version only, not the exact patch version |
| `--tag IMAGE:TAG`    | `iobroker-local:DEBIAN-nodeMAJOR`                     |
| `--version TEXT`     | `local`; image version metadata                       |
| `--platform OS/ARCH` | Docker default if omitted; e.g., `linux/amd64`        |
| `--no-cache`         | Ignore layer cache during build                       |
| `--pull`             | Pull the latest base image                            |
| `--help`             | Show help                                             |

The script uses `debian/` as the build context, creates a temporary
copy of the Dockerfile, and replaces the Debian base image as well as the
placeholders `${NODE}`, `${VERSION}`, `${BUILD}`, and `${DATI}`. The original
files remain unchanged; the temporary file is deleted upon completion. No
container is started, and no image is published.

The desired Debian/Node combination must be supported by the upstream
installation process. Builds for a different CPU architecture require
appropriate Docker emulation or a suitable builder. If the Dockerfile
structure is modified, the script aborts with a notification.
