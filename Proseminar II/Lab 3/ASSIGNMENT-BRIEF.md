# Lab 3: Worldbuilding with Gaussian Splats

## Overview

This workshop explores worldbuilding using Gaussian splats, spatial audio, and 3D objects in three.js. Using [LichtFeld Studio](https://lichtfeld.io/) and [Marble by World Labs](https://marble.worldlabs.ai/), you will create four separate scenes using Gaussian splats:

### 1. Fish out of Water

Building from your sketchbook drawings, capture and render a Gaussian splat environment using [LichtFeld Studio](https://lichtfeld.io/).

Place your "fish" (model) inside this new environment. Capture screenshots.

### 2. Personal Archive

Select a photo from your personal or family archive.

Using [Marble](https://marble.worldlabs.ai/), generate a Gaussian splat using the image as a reference. Augment the environment with spatial audio using online archives, such as:

- [BBC Sound Effects Archive](https://sound-effects.bbcrewind.co.uk/)
- [Freesound](https://freesound.org/)

### 3. Fantasy

Using [Marble](https://marble.worldlabs.ai/), create an imagined or surreal world with a natural language prompt. Augment the environment with foley audio that you record using your phone or an audio recorder.

### 4. Hand-Drawn Scene

Create a hand-drawn scene and scan or photograph it.

Using [Marble](https://marble.worldlabs.ai/), generate a Gaussian splat using the hand-drawn image as a reference.

## Workflow

### 1. Create Gaussian Splats (SPZ format)

- Go to [Marble by World Labs](https://marble.worldlabs.ai/).
- Upload an image or enter a text prompt.
- Generate your scene.
- Open in Studio Mode to refine.
- Upload mesh objects that you've generated or downloaded from sites such as [Free3D](https://free3d.com/) or [Poly Pizza](https://poly.pizza/).
- Export a `.zip` file including splat files as SPZ v3 and meshes.

### 2. Add Spatial Audio

- Unzip the exported folder.
- Download the [Marble Spatial Audio Viewer/Editor](https://github.com/dahvcduke/marble-audio-template).
- Replace the `index.html` file in your unzipped [Marble](https://marble.worldlabs.ai/) export with the repository's `index.html` file.
- Follow the repository's README instructions to upload and position spatial audio.

## Deploy

Deploy your Gaussian splat environments as static sites using [Dokploy](https://dokploy.com/).

1. Spin up a virtual machine (VM) using [Virtual Computing Manager](https://vcm.duke.edu/).
2. Click **Request a VM**, select **Linux**, and choose **Ubuntu Server 26.04**.
3. Create an alias, such as `[first name]-splats`.
4. Turn off **Automatic power downs** and provide a reason, such as "Deploying static websites for a class."
5. SSH into the machine using the admin user. Replace `admin` with your admin username and `your-alias` with your VM's alias:

   ```sh
   ssh admin@your-alias.colab.duke.edu
   ```

   Enter your password when prompted.

6. Install Dokploy using the following command:

   ```sh
   curl -sSL https://dokploy.com/install.sh | sh
   ```

7. After Dokploy installs, create a username and password and store them safely. In the Dokploy dashboard, go to **Settings** and enter your alias in the **Domain** field, such as `your-alias.colab.duke.edu`.
8. Enter your email in the **Let's Encrypt Email** field, turn **HTTPS** on, and select **Let's Encrypt** from the **Certificate Provider** dropdown.
9. Go to **Projects**, click **Create Project**, and select **Create Service → Application**.
10. Under **General**, click **Drop**.
11. Zip your static site folder and upload the zipped folder.
12. Under **Build Type**, choose **Static** and click **Save**.
13. Click **Deploy**.
14. Under **Domains**, click **Add Domain**. Click the dice icon to generate a random domain. Set **Container Port** to `80`, turn **HTTPS** on, select **Let's Encrypt** as the **Certificate Provider**, and click **Create**.

## Deliverables

- **1. Fish out of Water:** Upload screenshots to Canvas.
- **2–4. Personal Archive, Fantasy, and Hand-Drawn Scene:** Submit links to your deployed websites to Canvas.
