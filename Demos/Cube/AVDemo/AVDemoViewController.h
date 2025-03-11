/*
 * AVDemoViewController.h
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>


#pragma mark -
#pragma mark AVDemoViewController

/** The main view controller for the AV demo storyboard. */
@interface AVDemoViewController : UIViewController<AVPictureInPictureSampleBufferPlaybackDelegate>
@end


#pragma mark -
#pragma mark AVDemoView

/** The video-compatibile view for the AV demo Storyboard. */
@interface AVDemoView : UIView
@end 
