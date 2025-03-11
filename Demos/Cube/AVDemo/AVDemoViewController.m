/*
 * AVDemoViewController.m
 *
 * Copyright (c) 2015-2024 The Brenwill Workshop Ltd. (http://www.brenwill.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AVDemoViewController.h"
#import <AVKit/AVKit.h>

#include <MoltenVK/mvk_vulkan.h>
#include "cube.c"


#pragma mark -
#pragma mark AVDemoViewController

@interface AVDemoViewController () <AVPictureInPictureControllerDelegate>
@property (nonatomic, strong) AVPictureInPictureController *pipController;
@end

@implementation AVDemoViewController {
    CADisplayLink* _displayLink;
    struct demo demo;
    AVSampleBufferDisplayLayer* _avLayer;
}

/** Since this is a single-view app, initialize Vulkan as view is appearing. */
-(void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
    
    self.view.contentScaleFactor = UIScreen.mainScreen.nativeScale;
    
    // Create and configure the AVSampleBufferDisplayLayer
    _avLayer = [AVSampleBufferDisplayLayer layer];
    _avLayer.frame = self.view.bounds;
    _avLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:_avLayer];
    
    // Setup Picture-in-Picture if available
    [self setupPictureInPicture];
    
#if TARGET_OS_SIMULATOR
    // Avoid linear host-coherent texture loading on simulator
    const char* argv[] = { "cube", "--use_staging" };
#else
    const char* argv[] = { "cube" };
#endif
    int argc = sizeof(argv)/sizeof(char*);
    
    // Pass the AVSampleBufferDisplayLayer to initialize Vulkan
    demo_main(&demo, _avLayer, argc, argv);
//    demo_draw(&demo);
    
    uint32_t fps = 60;
    _displayLink = [CADisplayLink displayLinkWithTarget: self selector: @selector(renderLoop)];
    [_displayLink setFrameInterval: 60 / fps];
    [_displayLink addToRunLoop: NSRunLoop.currentRunLoop forMode: NSDefaultRunLoopMode];
}

-(void) renderLoop {
    NSLog(@"renderLoop");
    demo_draw(&demo);
}

// Allow device rotation to resize the swapchain
-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Update the AVSampleBufferDisplayLayer frame
    _avLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    demo_resize(&demo);
}

-(void) viewDidDisappear: (BOOL) animated {
    [_displayLink invalidate];
    [_displayLink release];
    demo_cleanup(&demo);
    [super viewDidDisappear: animated];
}

#pragma mark - Picture-in-Picture

- (void)setupPictureInPicture {
    // Check if PiP is supported on this device
    if ([AVPictureInPictureController isPictureInPictureSupported]) {
        // Create a PiP controller with the AVSampleBufferDisplayLayer
        AVPictureInPictureControllerContentSource *contentSource = [[AVPictureInPictureControllerContentSource alloc] initWithSampleBufferDisplayLayer:_avLayer playbackDelegate:self];
        self.pipController = [[AVPictureInPictureController alloc] initWithContentSource:contentSource];
        
        self.pipController.delegate = self;
        
        // Add a button to start PiP
        UIButton *pipButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [pipButton setTitle:@"PiP" forState:UIControlStateNormal];
        [pipButton addTarget:self action:@selector(togglePictureInPicture:) forControlEvents:UIControlEventTouchUpInside];
        pipButton.frame = CGRectMake(20, 40, 60, 40);
        [self.view addSubview:pipButton];
    }
}

- (void)togglePictureInPicture:(UIButton *)sender {
    if (self.pipController.isPictureInPictureActive) {
        [self.pipController stopPictureInPicture];
    } else {
        [self.pipController startPictureInPicture];
    }
}

#pragma mark - AVPictureInPictureControllerDelegate

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"PiP started");
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"PiP stopped");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error {
    NSLog(@"PiP failed to start: %@", error);
}

- (void)pictureInPictureController:(nonnull AVPictureInPictureController *)pictureInPictureController setPlaying:(BOOL)playing { 
}

- (BOOL)pictureInPictureControllerIsPlaybackPaused:(nonnull AVPictureInPictureController *)pictureInPictureController {
    return NO;
}

- (CMTimeRange)pictureInPictureControllerTimeRangeForPlayback:(nonnull AVPictureInPictureController *)pictureInPictureController { 
    return CMTimeRangeMake(CMTimeMakeWithSeconds(0, 1000), CMTimeMakeWithSeconds(INT32_MAX, 1000));
}

- (void)pictureInPictureController:(nonnull AVPictureInPictureController *)pictureInPictureController didTransitionToRenderSize:(CMVideoDimensions)newRenderSize { 
}


- (void)pictureInPictureController:(nonnull AVPictureInPictureController *)pictureInPictureController skipByInterval:(CMTime)skipInterval completionHandler:(nonnull void (^)(void))completionHandler {
    completionHandler();
}

@end


#pragma mark -
#pragma mark AVDemoView

@implementation AVDemoView

/** Returns a video layer for rendering. */
+(Class) layerClass { return [AVSampleBufferDisplayLayer class]; }

@end 
