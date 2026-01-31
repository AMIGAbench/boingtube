# BoingTube – Docker Setup Files

This repository provides the **Docker configuration files** required to run the BoingTube server.

It intentionally contains **only**:

* `docker-compose.yml`
* `setup_boingtube.sh`

No binaries and no third-party tools are bundled here.

---

## Files

### `docker-compose.yml`

Docker Compose configuration for running the BoingTube server.

Key characteristics:

* Starts the BoingTube backend container
* Runs in a **neutral base mode** by default
* Does **not** include or use `yt-dlp` automatically
* Must be enabled for YouTube support via an environment variable

The relevant setting is:

```yaml
ENABLE_YTDLP_FETCHER: NO
```

Change this value to `YES` to activate YouTube support.

---

### `setup_boingtube.sh`

Interactive setup helper script.

This script:

* downloads the official `docker-compose.yml` from this repository
* asks for explicit user consent (YES / NO)
* enables YouTube support after confirmation
* optionally starts the container

---

## Optional YouTube Support (yt-dlp)

BoingTube does **not** access YouTube by default.

If you choose to enable YouTube support:

* the container will download the external tool **yt-dlp** at startup
* yt-dlp is used to access content from third-party platforms such as YouTube

Use of these platforms is subject to their respective **terms of service**.
You are responsible for ensuring that your usage complies with those terms.

---

## Usage

### Option 1: Interactive setup (recommended)

```bash
chmod +x setup_boingtube.sh
./setup_boingtube.sh
```

Follow the on-screen instructions.

---

### Option 2: Manual configuration

Edit `docker-compose.yml`:

```yaml
ENABLE_YTDLP_FETCHER: NO
```

Change to:

```yaml
ENABLE_YTDLP_FETCHER: YES
```

Then start the container:

```bash
docker compose up -d
```

---

## Disabling YouTube Support

To disable YouTube support again, set:

```yaml
ENABLE_YTDLP_FETCHER: NO
```

and restart the container.

---

## Disclaimer

These files are provided as part of an **open-source hobby project**.

They do not host, store, or redistribute video content.
All content access is initiated by the user and handled by external tools.

This project is **not affiliated with YouTube or Google LLC**.

