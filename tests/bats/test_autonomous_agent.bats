#!/usr/bin/env bats
# P2-002 — Autonomous Agent Scripts Exist + Executable (FR-7.1)
#
# Asserts that all autonomous-implementation/ scripts exist and are valid.
# Path correction: run-autonomous.sh is at autonomous-implementation/scripts/
# (not at autonomous-implementation/ as originally specced — confirmed in
#  sprint3-dependency-assessment.md)

PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
AI_DIR="${PROJECT_ROOT}/autonomous-implementation"

# ---------------------------------------------------------------------------
# Python scripts — exist
# ---------------------------------------------------------------------------

@test "P2-002-a: agent.py exists" {
    [ -f "${AI_DIR}/agent.py" ]
}

@test "P2-002-b: client.py exists" {
    [ -f "${AI_DIR}/client.py" ]
}

@test "P2-002-c: prompts.py exists" {
    [ -f "${AI_DIR}/prompts.py" ]
}

@test "P2-002-d: security.py exists" {
    [ -f "${AI_DIR}/security.py" ]
}

# ---------------------------------------------------------------------------
# Python scripts — valid Python (parseable without syntax errors)
# ---------------------------------------------------------------------------

@test "P2-002-e: agent.py is valid Python" {
    run python3 -m py_compile "${AI_DIR}/agent.py"
    [ "$status" -eq 0 ]
}

@test "P2-002-f: client.py is valid Python" {
    run python3 -m py_compile "${AI_DIR}/client.py"
    [ "$status" -eq 0 ]
}

@test "P2-002-g: prompts.py is valid Python" {
    run python3 -m py_compile "${AI_DIR}/prompts.py"
    [ "$status" -eq 0 ]
}

@test "P2-002-h: security.py is valid Python" {
    run python3 -m py_compile "${AI_DIR}/security.py"
    [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# run-autonomous.sh — correct path, executable, valid shell
# ---------------------------------------------------------------------------

@test "P2-002-i: run-autonomous.sh exists at scripts/ subdir (not root)" {
    [ -f "${AI_DIR}/scripts/run-autonomous.sh" ]
}

@test "P2-002-j: run-autonomous.sh is NOT at the root AI dir (path corrected)" {
    [ ! -f "${AI_DIR}/run-autonomous.sh" ]
}

@test "P2-002-k: run-autonomous.sh is executable" {
    [ -x "${AI_DIR}/scripts/run-autonomous.sh" ]
}

@test "P2-002-l: run-autonomous.sh has a shebang line" {
    first_line=$(head -1 "${AI_DIR}/scripts/run-autonomous.sh")
    [[ "$first_line" == "#!/"* ]]
}

@test "P2-002-m: run-autonomous.sh passes bash syntax check" {
    run bash -n "${AI_DIR}/scripts/run-autonomous.sh"
    [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# prompts/ directory — required prompt files exist
# ---------------------------------------------------------------------------

@test "P2-002-n: prompts/ subdirectory exists" {
    [ -d "${AI_DIR}/prompts" ]
}

@test "P2-002-o: coding_prompt.md exists" {
    [ -f "${AI_DIR}/prompts/coding_prompt.md" ]
}

@test "P2-002-p: initializer_prompt.md exists" {
    [ -f "${AI_DIR}/prompts/initializer_prompt.md" ]
}
