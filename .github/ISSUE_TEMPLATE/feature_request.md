name: Feature Request
description: Suggest a new feature or improvement
title: "[Feature] "
labels: ["feature"]
assignees: []
body:

- type: markdown
  attributes:
    value: |

      ## Feature Description
      Describe the feature or improvement you'd like to see.

- type: textarea
  id: problem
  attributes:
    label: Problem It Solves
    description: What problem does this feature solve?
    placeholder: "As a user, I want... so that..."

- type: textarea
  id: solution
  attributes:
    label: Proposed Solution
    description: How should this feature work?
    placeholder: A clear description of your proposed solution.

- type: textarea
  id: alternatives
  attributes:
    label: Alternatives Considered
    description: Any alternative solutions you've considered.
    placeholder: Alternative approaches...

- type: checkboxes
  id: platform
  attributes:
    label: Platform
    options:
      - label: iOS
      - label: Android
      - label: Both
      - label: Cross-platform

- type: checkboxes
  id: priority
  attributes:
    label: Priority
    options:
      - label: Nice to have
      - label: Important
      - label: Critical

- type: checkboxes
  id: terms
  attributes:
    label: ""
    options:
      - label: I am willing to help implement this feature if needed.
        required: true
