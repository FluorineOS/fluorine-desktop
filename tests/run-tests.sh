#!/usr/bin/env bash
set -euo pipefail

# Regression tests for the reliability fixes in the flr-* utilities. Each test
# runs the real command against stub tools in a temporary PATH, so no session,
# package manager, or privileged state is touched.

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
work=$(mktemp -d)
trap 'rm -rf "${work}"' EXIT

passed=0
failed=0

pass_test() {
    passed=$((passed + 1))
    printf 'PASS %s\n' "$1"
}

fail_test() {
    failed=$((failed + 1))
    printf 'FAIL %s: %s\n' "$1" "$2"
}

stub() {
    local path=$1
    cat >"${path}"
    chmod +x "${path}"
}

new_case() {
    local name=$1
    local dir="${work}/${name}"
    mkdir -p "${dir}/bin" "${dir}/home" "${dir}/state"
    printf '%s' "${dir}"
}

test_ctl_confirmation() {
    local dir output rc
    dir=$(new_case ctl)

    stub "${dir}/bin/fuzzel" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
count=0
if [ -f "${FUZZEL_COUNT}" ]; then
    count=$(cat "${FUZZEL_COUNT}")
fi
count=$((count + 1))
printf '%s\n' "${count}" >"${FUZZEL_COUNT}"
sed -n "${count}p" "${FUZZEL_RESPONSES}"
STUB

    stub "${dir}/bin/systemctl" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"${SYSTEMCTL_LOG}"
STUB

    stub "${dir}/bin/flr-power" <<'STUB'
#!/usr/bin/env bash
printf 'PWR BAL\n'
STUB

    printf 'Reboot\nCancel\n' >"${dir}/responses"
    if output=$(
        PATH="${dir}/bin:${PATH}" \
            HOME="${dir}/home" \
            XDG_STATE_HOME="${dir}/state" \
            FUZZEL_COUNT="${dir}/count" \
            FUZZEL_RESPONSES="${dir}/responses" \
            SYSTEMCTL_LOG="${dir}/systemctl.log" \
            bash "${repo_root}/bin/flr-ctl" 2>&1
    ); then
        rc=0
    else
        rc=$?
    fi

    if [ "${rc}" -ne 0 ]; then
        fail_test "flr-ctl cancel" "exit ${rc}: ${output}"
    elif [ -s "${dir}/systemctl.log" ]; then
        fail_test "flr-ctl cancel" "systemctl ran: $(cat "${dir}/systemctl.log")"
    else
        pass_test "flr-ctl cancel leaves the session running"
    fi

    printf 'Shut Down\nPower off the computer\n' >"${dir}/responses"
    rm -f "${dir}/count" "${dir}/systemctl.log"
    if output=$(
        PATH="${dir}/bin:${PATH}" \
            HOME="${dir}/home" \
            XDG_STATE_HOME="${dir}/state" \
            FUZZEL_COUNT="${dir}/count" \
            FUZZEL_RESPONSES="${dir}/responses" \
            SYSTEMCTL_LOG="${dir}/systemctl.log" \
            bash "${repo_root}/bin/flr-ctl" 2>&1
    ); then
        rc=0
    else
        rc=$?
    fi

    if [ "${rc}" -ne 0 ]; then
        fail_test "flr-ctl confirm" "exit ${rc}: ${output}"
    elif ! grep -qx 'poweroff' "${dir}/systemctl.log" 2>/dev/null; then
        fail_test "flr-ctl confirm" "poweroff was not dispatched"
    else
        pass_test "flr-ctl confirm dispatches the selected action"
    fi
}

test_power_failure() {
    local dir output rc
    dir=$(new_case power)

    stub "${dir}/bin/powerprofilesctl" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
    get)
        printf 'balanced\n'
        ;;
    set)
        exit "${POWER_SET_RC:-0}"
        ;;
esac
STUB

    if output=$(
        PATH="${dir}/bin:${PATH}" \
            HOME="${dir}/home" \
            POWER_SET_RC=1 \
            bash "${repo_root}/bin/flr-power" cycle 2>&1
    ); then
        rc=0
    else
        rc=$?
    fi

    if [ "${rc}" -eq 0 ]; then
        fail_test "flr-power failure" "cycle succeeded when the profile could not be set"
    elif ! grep -q 'could not set' <<<"${output}"; then
        fail_test "flr-power failure" "missing error message: ${output}"
    else
        pass_test "flr-power reports a failed profile change"
    fi

    if output=$(
        PATH="${dir}/bin:${PATH}" \
            HOME="${dir}/home" \
            POWER_SET_RC=0 \
            bash "${repo_root}/bin/flr-power" cycle 2>&1
    ); then
        rc=0
    else
        rc=$?
    fi

    if [ "${rc}" -ne 0 ] || [ "${output}" != "PWR PERF" ]; then
        fail_test "flr-power success" "exit ${rc}: ${output}"
    else
        pass_test "flr-power reports the new profile"
    fi
}

test_keys_outside_session() {
    local dir output rc
    dir=$(new_case keys)

    stub "${dir}/bin/hyprctl" <<'STUB'
#!/usr/bin/env bash
exit "${HYPRCTL_RC:-0}"
STUB
    stub "${dir}/bin/jq" <<'STUB'
#!/usr/bin/env bash
cat
STUB
    stub "${dir}/bin/fuzzel" <<'STUB'
#!/usr/bin/env bash
cat
STUB

    if output=$(
        env -u HYPRLAND_INSTANCE_SIGNATURE \
            PATH="${dir}/bin:${PATH}" \
            HOME="${dir}/home" \
            bash "${repo_root}/bin/flr-keys" 2>&1
    ); then
        rc=0
    else
        rc=$?
    fi

    if [ "${rc}" -eq 0 ] || ! grep -q 'not set' <<<"${output}"; then
        fail_test "flr-keys outside Hyprland" "exit ${rc}: ${output}"
    else
        pass_test "flr-keys rejects a missing Hyprland session"
    fi

    if output=$(
        PATH="${dir}/bin:${PATH}" \
            HOME="${dir}/home" \
            HYPRLAND_INSTANCE_SIGNATURE=test \
            HYPRCTL_RC=1 \
            bash "${repo_root}/bin/flr-keys" 2>&1
    ); then
        rc=0
    else
        rc=$?
    fi

    if [ "${rc}" -eq 0 ] || ! grep -q 'could not read' <<<"${output}"; then
        fail_test "flr-keys hyprctl failure" "exit ${rc}: ${output}"
    else
        pass_test "flr-keys reports a failed hyprctl call"
    fi
}

test_onboard_marker() {
    local dir output rc marker
    dir=$(new_case onboard)
    marker="${dir}/state/fluorine/onboarded"

    stub "${dir}/bin/flr-keys" <<'STUB'
#!/usr/bin/env bash
exit "${KEYS_RC:-0}"
STUB

    if output=$(
        PATH="${dir}/bin:${PATH}" \
            HOME="${dir}/home" \
            XDG_STATE_HOME="${dir}/state" \
            HYPRLAND_INSTANCE_SIGNATURE=test \
            KEYS_RC=1 \
            bash "${repo_root}/bin/flr-onboard" 2>&1
    ); then
        rc=0
    else
        rc=$?
    fi

    if [ "${rc}" -eq 0 ]; then
        fail_test "flr-onboard failure" "exit 0 after the cheat sheet failed"
    elif [ -e "${marker}" ]; then
        fail_test "flr-onboard failure" "the onboarded marker was written"
    else
        pass_test "flr-onboard retries after a failed cheat sheet"
    fi

    if output=$(
        PATH="${dir}/bin:${PATH}" \
            HOME="${dir}/home" \
            XDG_STATE_HOME="${dir}/state" \
            HYPRLAND_INSTANCE_SIGNATURE=test \
            KEYS_RC=0 \
            bash "${repo_root}/bin/flr-onboard" 2>&1
    ); then
        rc=0
    else
        rc=$?
    fi

    if [ "${rc}" -ne 0 ] || [ ! -e "${marker}" ]; then
        fail_test "flr-onboard success" "exit ${rc}, marker present: $([ -e "${marker}" ] && printf yes || printf no)"
    else
        pass_test "flr-onboard marks the session after success"
    fi
}

test_update_snapshot_gate() {
    local dir output rc
    dir=$(new_case update)

    stub "${dir}/bin/apt-get" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
    -s)
        printf 'Inst foo [1] (2 trixie [amd64])\n'
        printf 'Inst fluorine-desktop [1] (2 trixie [amd64])\n'
        ;;
    update | upgrade)
        printf '%s\n' "$*" >>"${APT_LOG:?}"
        ;;
esac
STUB
    stub "${dir}/bin/sudo" <<'STUB'
#!/usr/bin/env bash
exec "$@"
STUB
    stub "${dir}/bin/findmnt" <<'STUB'
#!/usr/bin/env bash
printf 'btrfs\n'
STUB
    stub "${dir}/bin/flr-snapshot" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"${SNAPSHOT_LOG:?}"
exit "${SNAPSHOT_RC:-0}"
STUB

    if output=$(
        PATH="${dir}/bin:${PATH}" \
            HOME="${dir}/home" \
            APT_LOG="${dir}/apt.log" \
            SNAPSHOT_LOG="${dir}/snapshot.log" \
            SNAPSHOT_RC=1 \
            bash "${repo_root}/bin/flr-update" 2>&1
    ); then
        rc=0
    else
        rc=$?
    fi

    if [ "${rc}" -eq 0 ]; then
        fail_test "flr-update snapshot gate" "the upgrade continued after the snapshot failed"
    elif grep -qx 'upgrade' "${dir}/apt.log" 2>/dev/null; then
        fail_test "flr-update snapshot gate" "apt-get upgrade ran"
    else
        pass_test "flr-update stops when the snapshot fails"
    fi

    rm -f "${dir}/apt.log"
    if output=$(
        PATH="${dir}/bin:${PATH}" \
            HOME="${dir}/home" \
            APT_LOG="${dir}/apt.log" \
            SNAPSHOT_LOG="${dir}/snapshot.log" \
            SNAPSHOT_RC=0 \
            bash "${repo_root}/bin/flr-update" 2>&1
    ); then
        rc=0
    else
        rc=$?
    fi

    if [ "${rc}" -ne 0 ] || ! grep -qx 'upgrade' "${dir}/apt.log" 2>/dev/null; then
        fail_test "flr-update success" "exit ${rc}: ${output}"
    else
        pass_test "flr-update upgrades after a successful snapshot"
    fi
}

test_mode_idle_control() {
    local dir output rc
    dir=$(new_case mode)

    stub "${dir}/bin/pgrep" <<'STUB'
#!/usr/bin/env bash
exit "${PGREP_RC:-1}"
STUB
    stub "${dir}/bin/pkill" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"${PKILL_LOG:?}"
STUB
    stub "${dir}/bin/setsid" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"${SETSID_LOG:?}"
STUB
    stub "${dir}/bin/hyprctl" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"${HYPRCTL_LOG:?}"
STUB
    stub "${dir}/bin/systemctl" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"${SYSTEMCTL_LOG:?}"
STUB
    stub "${dir}/bin/swaync-client" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
    stub "${dir}/bin/notify-send" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB

    if output=$(
        PATH="${dir}/bin:${PATH}" \
            HOME="${dir}/home" \
            XDG_STATE_HOME="${dir}/state" \
            HYPRLAND_INSTANCE_SIGNATURE=test \
            PGREP_RC=0 \
            PKILL_LOG="${dir}/pkill.log" \
            SETSID_LOG="${dir}/setsid.log" \
            HYPRCTL_LOG="${dir}/hyprctl.log" \
            SYSTEMCTL_LOG="${dir}/systemctl.log" \
            bash "${repo_root}/bin/flr-mode" present 2>&1
    ); then
        rc=0
    else
        rc=$?
    fi

    if [ "${rc}" -ne 0 ]; then
        fail_test "flr-mode present" "exit ${rc}: ${output}"
    elif ! grep -q -- '-x hypridle' "${dir}/pkill.log" 2>/dev/null; then
        fail_test "flr-mode present" "hypridle was not stopped"
    elif [ -s "${dir}/systemctl.log" ]; then
        fail_test "flr-mode present" "systemctl was used: $(cat "${dir}/systemctl.log")"
    else
        pass_test "flr-mode present stops the session hypridle"
    fi

    rm -f "${dir}/pkill.log" "${dir}/setsid.log" "${dir}/systemctl.log"
    if output=$(
        PATH="${dir}/bin:${PATH}" \
            HOME="${dir}/home" \
            XDG_STATE_HOME="${dir}/state" \
            HYPRLAND_INSTANCE_SIGNATURE=test \
            PGREP_RC=1 \
            PKILL_LOG="${dir}/pkill.log" \
            SETSID_LOG="${dir}/setsid.log" \
            HYPRCTL_LOG="${dir}/hyprctl.log" \
            SYSTEMCTL_LOG="${dir}/systemctl.log" \
            bash "${repo_root}/bin/flr-mode" work 2>&1
    ); then
        rc=0
    else
        rc=$?
    fi

    if [ "${rc}" -ne 0 ]; then
        fail_test "flr-mode work" "exit ${rc}: ${output}"
    elif ! grep -q 'hypridle' "${dir}/setsid.log" 2>/dev/null; then
        fail_test "flr-mode work" "hypridle was not restarted"
    elif [ -s "${dir}/systemctl.log" ]; then
        fail_test "flr-mode work" "systemctl was used: $(cat "${dir}/systemctl.log")"
    else
        pass_test "flr-mode work restarts the session hypridle"
    fi
}

test_python_helpers() {
    local dir output rc
    dir=$(new_case python)
    mkdir -p "${dir}/gi"

    cat >"${dir}/gi/__init__.py" <<'PY'
def require_version(*_args, **_kwargs):
    pass
PY

    cat >"${dir}/gi/repository.py" <<'PY'
class _Thing:
    def __init__(self, *args, **kwargs):
        pass


class _Namespace:
    def __getattr__(self, name):
        return _Thing


class _GLib(_Namespace):
    @staticmethod
    def get_user_config_dir():
        return "/tmp/flr-settings-test/config"

    @staticmethod
    def get_user_state_dir():
        return "/tmp/flr-settings-test/state"


Adw = _Namespace()
Gdk = _Namespace()
GdkPixbuf = _Namespace()
GLib = _GLib()
Gtk = _Namespace()
PY

    if output=$(
        PYTHONPATH="${dir}" python3 - "${repo_root}" <<'PY' 2>&1
import importlib.machinery
import importlib.util
import sys

root = sys.argv[1]


def load(name, path):
    loader = importlib.machinery.SourceFileLoader(name, path)
    spec = importlib.util.spec_from_loader(name, loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


store = load("flr_store", root + "/bin/flr-store")
calls = []
store.output = lambda command, timeout=5: (
    calls.append(command),
    "com.spotify.Client\n",
)[1]
assert store.flatpak_installed("com.spotify.Client") is True
assert "--columns=application" in calls[0]
assert store.flatpak_installed("org.example.Other") is False

sync = load("flr_sync", root + "/bin/flr-sync")
ok, lines = sync.restore_snapshot(confirmed=False)
assert ok is False
assert any("--yes" in line for line in lines)


class Completed:
    def __init__(self, returncode, stderr="", stdout=""):
        self.returncode = returncode
        self.stderr = stderr
        self.stdout = stdout


settings = load("flr_settings", root + "/bin/flr-settings")
calls = []


def failing_config(command, timeout=5):
    calls.append(command)
    if command[0] == "flr-config":
        return Completed(1, "read-only config")
    return Completed(0)


settings.run = failing_config


class DummyWindow:
    _gap_timeout = None

    def __init__(self):
        self.messages = []

    def toast(self, message):
        self.messages.append(message)

    def flash_status(self, message):
        self.messages.append(message)

    def refresh_displays(self):
        pass


window = DummyWindow()
settings.SettingsWindow.commit_gaps(window, 7)
assert any("could not apply the gap size" in item for item in window.messages)
assert any("read-only config" in item for item in window.messages)

settings.run = lambda command, timeout=5: (
    calls.append(command),
    Completed(0),
)[1]
window = DummyWindow()
settings.SettingsWindow.commit_gaps(window, 7)
assert "Applied to config.lua" in window.messages

settings.monitors = lambda: [{"name": "DP-1"}, {"name": "HDMI-A-1"}]


def failing_scale(command, timeout=5):
    calls.append(command)
    if command[0] == "hyprctl" and command[-1].startswith("DP-1"):
        return Completed(1, "rejected")
    return Completed(0)


settings.run = failing_scale
window = DummyWindow()
settings.SettingsWindow.apply_scale(window, "1.25")
assert any("Scale was not applied to DP-1" in item for item in window.messages)

settings.run = lambda command, timeout=5: (
    calls.append(command),
    Completed(0),
)[1]
window = DummyWindow()
settings.SettingsWindow.apply_scale(window, "1.25")
assert any("Scale set to 1.25" in item for item in window.messages)

print("python helper checks passed")
PY
    ); then
        rc=0
    else
        rc=$?
    fi

    if [ "${rc}" -ne 0 ]; then
        fail_test "Python helper checks" "exit ${rc}: ${output}"
    else
        pass_test "flr-store detection and flr-sync confirmation"
    fi
}

test_ctl_confirmation
test_power_failure
test_keys_outside_session
test_onboard_marker
test_update_snapshot_gate
test_mode_idle_control
test_python_helpers

printf '\n%d passed, %d failed\n' "${passed}" "${failed}"
[ "${failed}" -eq 0 ]
