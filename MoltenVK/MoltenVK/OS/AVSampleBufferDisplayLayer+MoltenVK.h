/*
 * AVSampleBufferDisplayLayer+MoltenVK.h
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

#pragma once

#include "MVKCommonEnvironment.h"

#import <AVFoundation/AVSampleBufferDisplayLayer.h>

#if MVK_IOS_OR_TVOS || MVK_MACCAT
#	include <UIKit/UIKit.h>
#endif

#if MVK_MACOS && !MVK_MACCAT
#	include <AppKit/NSScreen.h>
#endif

/** Extensions to AVSampleBufferDisplayLayer to support MoltenVK. */
@interface AVSampleBufferDisplayLayer (MoltenVK)

/**
 * Returns the natural drawable size for this layer.
 *
 * The natural drawable size is the size of the bounds
 * property multiplied by the contentsScale property.
 */
@property(nonatomic, readonly) CGSize naturalDrawableSizeMVK;

/**
 * The Metal device to use for this layer.
 */
@property(nonatomic, retain) id<MTLDevice> device;

/**
 * The pixel format to use for creating Metal textures.
 */
@property(nonatomic, assign) MTLPixelFormat pixelFormat;

/**
 * The maximum number of drawables that can be held by this layer.
 */
@property(nonatomic, readwrite) NSUInteger maximumDrawableCountMVK;

/**
 * Indicates whether presentation of video frames should be synchronized with the display refresh rate.
 */
@property(nonatomic, readwrite) BOOL displaySyncEnabledMVK;

/**
 * The colorspace for this layer.
 */
@property(nonatomic, assign) CGColorSpaceRef colorspace;

/**
 * The name of the CGColorSpaceRef in the colorspace property of this layer.
 */
@property(nonatomic, readwrite) CFStringRef colorspaceNameMVK;

/**
 * Indicates whether this layer wants extended dynamic range content.
 */
@property(nonatomic, readwrite) BOOL wantsExtendedDynamicRangeContentMVK;

#if MVK_IOS_OR_TVOS || MVK_MACCAT
/** Returns the screen on which this layer is rendering. */
@property(nonatomic, readonly) UIScreen* screenMVK;
#endif

#if MVK_MACOS && !MVK_MACCAT
/** Returns the screen on which this layer is rendering. */
@property(nonatomic, readonly) NSScreen* screenMVK;
#endif

@end 
