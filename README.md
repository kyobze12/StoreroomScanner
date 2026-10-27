Attempting to perform the InitializeDefaultDrives operation on the 'FileSystem' provider failed.
# Storeroom Scanner — free iPhone build attempt

This small native prototype checks the free Windows-to-iPhone build route:

- SwiftUI tabs and a SwiftData inventory model
- an ARKit camera view, plane detection, and LiDAR mesh reconstruction when the iPhone supports it
- a simple particle-cloud preview
- a GitHub Actions workflow that builds an unsigned IPA on a hosted macOS runner

It is a build-path prototype, not the complete scanner. It does not yet save AR world maps, raycast item tags, provide Find mode, or export meshes.

## Put this in a private GitHub repository

1. Create a new **private** repository named StoreroomScanner.
2. Install GitHub Desktop on Windows, clone the empty repository, and copy the contents of this folder into the cloned repository. Keep the hidden `.github/workflows` folder in place.
3. In GitHub Desktop, commit the files and push to GitHub. The workflow starts on a push to `main`.
4. On GitHub, open **Actions → Build unsigned iPhone app**. When the run finishes, download the `StoreroomScanner-unsigned-ipa` artifact.

GitHub Actions on a private repository uses the included monthly macOS minutes. The free quota is limited, so this first build is intentionally small.

## Install on Windows and iPhone

1. Install AltServer from [altstore.io](https://altstore.io/) on Windows and connect the iPhone by USB.
2. Use AltServer's **Sideload .ipa…** option to select StoreroomScanner.ipa.
3. Sign with your Apple Account. Enable Developer Mode on the iPhone if prompted, then trust the developer profile under **Settings → General → VPN & Device Management**.
4. Refresh or reinstall the app within 7 days using the same PC and a USB connection.

Before keeping the project, replace com.example.StoreroomScanner in project.yml with your own unique bundle identifier.

