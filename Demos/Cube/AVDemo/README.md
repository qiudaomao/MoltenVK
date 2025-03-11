# MoltenVK AVSampleBufferDisplayLayer Cube Demo

This demo showcases MoltenVK's capability to render to an `AVSampleBufferDisplayLayer` instead of the standard `CAMetalLayer`. 

## Features

- Uses the standard Vulkan cube demo
- Renders to an `AVSampleBufferDisplayLayer` instead of `CAMetalLayer`
- Demonstrates how to set up MoltenVK with video-based layers for optimal video rendering
- Shows integration with Picture-in-Picture capabilities on iOS

## How it Works

The demo initializes a Vulkan instance and device as normal, but instead of creating a swapchain with a `CAMetalLayer`, it uses an `AVSampleBufferDisplayLayer`. This leverages MoltenVK's ability to use either type of layer as a rendering surface.

When rendering, MoltenVK detects the `AVSampleBufferDisplayLayer` and automatically converts the Metal textures to video samples that can be displayed by the layer. This is particularly useful for applications that need to:

1. Render video content with effects applied through Vulkan
2. Support Picture-in-Picture on iOS
3. Integrate with other AVFoundation functionality
4. Achieve better performance for video-oriented applications

## Usage

Simply build and run the AV demo application. You'll see the same spinning cube as in the standard demo, but it's being rendered via an `AVSampleBufferDisplayLayer` behind the scenes. 