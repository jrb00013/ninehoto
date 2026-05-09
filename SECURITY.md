# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x     | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in ninehoto, please **do not** open a public issue.

Instead, send a private report to the maintainers. Include:

- A description of the vulnerability
- Steps to reproduce it
- Potential impact
- Any suggested fixes (optional)

We aim to respond within 48 hours and will work with you to understand and address the issue promptly.

## Security Considerations

- ninehoto only requests photo library access to display and delete media you explicitly mark
- No media is uploaded anywhere — all processing happens on-device
- Deletions use the OS-native photo library APIs (`MediaStore` on Android, `PHPhotoLibrary` on iOS)
- No analytics, tracking, or third-party SDKs that transmit data
