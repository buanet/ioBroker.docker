# Lokales ioBroker-Docker-Image bauen

Voraussetzungen: Bash, GNU sed (Linux oder WSL), Docker mit laufendem Daemon
und Internetzugang für den Build.

```bash
cd ioBroker.docker/localbuild
chmod +x build-local.sh
./build-local.sh --debian trixie --node 24
```

Das Image heißt standardmäßig `iobroker-local:trixie-node24` und wird im
lokalen Docker gespeichert. Das Skript findet das Repository über seinen
Speicherort; der Aufruf funktioniert auch aus anderen Arbeitsverzeichnissen.

```bash
./build-local.sh --debian bookworm --node 22 --tag iobroker:test
./build-local.sh --debian trixie --node 24 --pull --no-cache
./build-local.sh --debian trixie --node 24 --platform linux/arm64
```

| Parameter            | Standard / Bedeutung                                  |
| -------------------- | ----------------------------------------------------- |
| `--debian NAME`      | `trixie`; ohne `-slim` angeben                        |
| `--node MAJOR`       | `24`; nur die Hauptversion, keine exakte Patchversion |
| `--tag IMAGE:TAG`    | `iobroker-local:DEBIAN-nodeMAJOR`                     |
| `--version TEXT`     | `local`; Versionsmetadaten des Images                 |
| `--platform OS/ARCH` | Ohne Angabe Docker-Standard; z. B. `linux/amd64`      |
| `--no-cache`         | Layer-Cache beim Build ignorieren                     |
| `--pull`             | Aktuelles Basisimage abrufen                          |
| `--help`             | Hilfe anzeigen                                        |

Das Skript verwendet `debian/` als Build-Kontext, erstellt eine temporäre
Dockerfile-Kopie und ersetzt Debian-Basisimage sowie die Platzhalter
`${NODE}`, `${VERSION}`, `${BUILD}` und `${DATI}`. Die Originaldateien bleiben
unverändert; die temporäre Datei wird beim Beenden gelöscht. Es wird kein
Container gestartet und kein Image veröffentlicht.

Die gewünschte Debian-/Node-Kombination muss vom Upstream-Installationsprozess
unterstützt werden. Builds für eine andere CPU-Architektur benötigen passende
Docker-Emulation bzw. einen geeigneten Builder. Bei geändertem Dockerfile-Aufbau
bricht das Skript mit einem Hinweis ab.
