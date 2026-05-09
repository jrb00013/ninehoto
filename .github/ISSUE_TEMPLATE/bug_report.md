name: Bug Report
description: File a bug report to help us improve
title: "[Bug] "
labels: ["bug"]
assignees: []
body:

- type: markdown
  attributes:
    value: |
      ## Bug Description
      A clear and concise description of what the bug is.

- type: textarea
  id: steps
  attributes:
    label: Steps to Reproduce
    description: How you encountered the bug. Be specific.
    placeholder: |
      1. Go to '...'
      2. Tap on '...'
      3. Swipe left/right
      4. See error
  validations:
    required: true

- type: textarea
  id: expected
  attributes:
    label: Expected Behavior
    description: What you expected to happen.
    placeholder: A clear description of what you expected.
  validations:
    required: true

- type: textarea
  id: actual
  attributes:
    label: Actual Behavior
    description: What actually happened.
    placeholder: A clear description of what went wrong.
  validations:
    required: true

- type: dropdown
  id: platform
  attributes:
    label: Platform
    description: Which platform did this occur on?
    options:
      - iOS
      - Android
      - Both
  validations:
    required: true

- type: input
  id: version
  attributes:
    label: App Version
    description: "Version: e.g. 1.0.0"
    placeholder: "1.0.0"

- type: input
  id: device
  attributes:
    label: Device / Simulator
    description: "e.g. iPhone 15 Pro, Pixel 6, Android Emulator API 33"
    placeholder: "iPhone 15 Pro"

- type: textarea
  id: logs
  attributes:
    label: Relevant Logs
    description: Paste any relevant log output (optional).
    placeholder: Paste log output here...

- type: checkboxes
  id: terms
  attributes:
    label: ""
    options:
      - label: I confirm this is a reproducible bug and not a feature request.
        required: true
