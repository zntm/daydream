# System & Environment

Access to system information, time, input, and engine state.

---

## Time Macros

These values update automatically based on the current system time.

| Name              | Type   | Description                                |
| ----------------- | ------ | ------------------------------------------ |
| `CURRENT_YEAR`    | Number | The current year (e.g., 2025)              |
| `CURRENT_MONTH`   | Number | The current month (1-12)                   |
| `CURRENT_DAY`     | Number | The current day of the month (1-31)        |
| `CURRENT_WEEKDAY` | Number | The current weekday (0=Sunday, 6=Saturday) |
| `CURRENT_HOUR`    | Number | The current hour (0-23)                    |
| `CURRENT_MINUTE`  | Number | The current minute (0-59)                  |
| `CURRENT_SECOND`  | Number | The current second (0-59)                  |
| `CURRENT_TIME`    | Number | Milliseconds since the OS started          |

---

## Engine Macros

| Name         | Type   | Description                           |
| ------------ | ------ | ------------------------------------- |
| `FPS`        | Number | Current frames per second (capped)    |
| `FPS_REAL`   | Number | Uncapped real frames per second       |
| `DELTA_TIME` | Number | Time in microseconds since last frame |

---

## OS & Environment

| Name           | Type   | Description                                                 |
| -------------- | ------ | ----------------------------------------------------------- |
| `OS_TYPE`      | String | Operating system type (e.g., "Windows", "Linux", "Android") |
| `OS_BROWSER`   | String | Browser type (if running in HTML5)                          |
| `OS_VERSION`   | Number | OS version number                                           |
| `SYS_HOSTNAME` | String | Device hostname                                             |
| `SYS_USERNAME` | String | Current user name                                           |
| `SYS_PID`      | Number | Process ID                                                  |

---

## Hardware Info

| Name             | Type   | Description                       |
| ---------------- | ------ | --------------------------------- |
| `SYS_CPU`        | String | CPU name/model                    |
| `SYS_CPU_BRAND`  | String | CPU brand string                  |
| `SYS_CPU_VENDOR` | String | CPU vendor ID                     |
| `SYS_CPU_FREQ`   | Number | CPU frequency in MHz              |
| `SYS_CORE_COUNT` | Number | Number of CPU cores               |
| `SYS_CPU_USAGE`  | Number | Total CPU usage percentage        |
| `SYS_CPU_PROC`   | Number | Process CPU usage percentage      |
| `SYS_GPU`        | String | GPU name                          |
| `SYS_GPU_VRAM`   | Number | Total VRAM in bytes               |
| `SYS_GPU_USAGE`  | Number | GPU usage percentage              |
| `SYS_RAM_MAX`    | Number | Total system RAM in bytes         |
| `SYS_RAM_USED`   | Number | Used system RAM in bytes          |
| `SYS_RAM_PROC`   | Number | RAM used by this process in bytes |

---

## Display & Input

| Name             | Type   | Description                          |
| ---------------- | ------ | ------------------------------------ |
| `WINDOW_WIDTH`   | Number | Current window width in pixels       |
| `WINDOW_HEIGHT`  | Number | Current window height in pixels      |
| `DISPLAY_WIDTH`  | Number | Monitor width in pixels              |
| `DISPLAY_HEIGHT` | Number | Monitor height in pixels             |
| `WORLD_MOUSE_X`  | Number | Mouse X position in room coordinates |
| `WORLD_MOUSE_Y`  | Number | Mouse Y position in room coordinates |
| `DEVICE_MOUSE_X` | Number | Raw device mouse X position          |
| `DEVICE_MOUSE_Y` | Number | Raw device mouse Y position          |
| `GUI_MOUSE_X`    | Number | Mouse X position on GUI layer        |
| `GUI_MOUSE_Y`    | Number | Mouse Y position on GUI layer        |
