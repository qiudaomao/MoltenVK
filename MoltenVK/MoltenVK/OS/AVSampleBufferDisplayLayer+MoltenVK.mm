/*
 * AVSampleBufferDisplayLayer+MoltenVK.mm
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

#include "AVSampleBufferDisplayLayer+MoltenVK.h"
#include "MVKOSExtensions.h"
#include <objc/runtime.h>

#if MVK_MACOS && !MVK_MACCAT
#	include <AppKit/NSApplication.h>
#	include <AppKit/NSWindow.h>
#	include <AppKit/NSView.h>
#endif

// Private properties to store the required data
static char kMVKDeviceKey;
static char kMVKPixelFormatKey;
static char kMVKMaximumDrawableCountKey;
static char kMVKDisplaySyncEnabledKey;
static char kMVKColorspaceKey;
static char kMVKWantsExtendedDynamicRangeContentKey;

@implementation AVSampleBufferDisplayLayer (MoltenVK)

-(CGSize) naturalDrawableSizeMVK {
    CGSize drawSize = self.bounds.size;
    CGFloat scaleFactor = self.contentsScale;
    drawSize.width *= scaleFactor;
    drawSize.height *= scaleFactor;
    return drawSize;
}

// Device property implementation
-(id<MTLDevice>) device {
    return objc_getAssociatedObject(self, &kMVKDeviceKey);
}

-(void) setDevice:(id<MTLDevice>)device {
    objc_setAssociatedObject(self, &kMVKDeviceKey, device, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Pixel format property implementation
-(MTLPixelFormat) pixelFormat {
    NSNumber *formatNumber = objc_getAssociatedObject(self, &kMVKPixelFormatKey);
    return formatNumber ? (MTLPixelFormat)[formatNumber unsignedIntegerValue] : MTLPixelFormatBGRA8Unorm;
}

-(void) setPixelFormat:(MTLPixelFormat)pixelFormat {
    objc_setAssociatedObject(self, &kMVKPixelFormatKey, @(pixelFormat), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Maximum drawable count implementation
-(NSUInteger) maximumDrawableCountMVK {
    NSNumber *count = objc_getAssociatedObject(self, &kMVKMaximumDrawableCountKey);
    return count ? [count unsignedIntegerValue] : 3;
}

-(void) setMaximumDrawableCountMVK:(NSUInteger)count {
    objc_setAssociatedObject(self, &kMVKMaximumDrawableCountKey, @(count), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Display sync enabled implementation
-(BOOL) displaySyncEnabledMVK {
    NSNumber *enabled = objc_getAssociatedObject(self, &kMVKDisplaySyncEnabledKey);
    return enabled ? [enabled boolValue] : YES;
}

-(void) setDisplaySyncEnabledMVK:(BOOL)enabled {
    objc_setAssociatedObject(self, &kMVKDisplaySyncEnabledKey, @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Colorspace implementation
-(CGColorSpaceRef) colorspace {
    return (__bridge CGColorSpaceRef)objc_getAssociatedObject(self, &kMVKColorspaceKey);
}

-(void) setColorspace:(CGColorSpaceRef)colorspace {
    objc_setAssociatedObject(self, &kMVKColorspaceKey, (__bridge id)colorspace, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CFStringRef) colorspaceNameMVK {
    CGColorSpaceRef cs = self.colorspace;
    return cs ? CGColorSpaceGetName(cs) : NULL;
}

-(void) setColorspaceNameMVK:(CFStringRef)name {
    CGColorSpaceRef csRef = CGColorSpaceCreateWithName(name);
    self.colorspace = csRef;
    CGColorSpaceRelease(csRef);
}

// Extended dynamic range content implementation
-(BOOL) wantsExtendedDynamicRangeContentMVK {
    NSNumber *wantsEDR = objc_getAssociatedObject(self, &kMVKWantsExtendedDynamicRangeContentKey);
    return wantsEDR ? [wantsEDR boolValue] : NO;
}

-(void) setWantsExtendedDynamicRangeContentMVK:(BOOL)wantsEDR {
    objc_setAssociatedObject(self, &kMVKWantsExtendedDynamicRangeContentKey, @(wantsEDR), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#if (MVK_IOS_OR_TVOS || MVK_MACCAT) && !MVK_VISIONOS
-(UIScreen*) screenMVK {
    return UIScreen.mainScreen;
}
#endif

#if MVK_MACOS && !MVK_MACCAT
-(NSScreen*) screenMVK {
    __block NSScreen* screen;
    mvkDispatchToMainAndWait(^{
        // Find window containing this layer
        for (NSWindow* window in NSApplication.sharedApplication.windows) {
            CALayer* windowContentLayer = window.contentView.layer;
            for (CALayer* layer = (CALayer*)self; layer; layer = layer.superlayer) {
                if (layer == windowContentLayer) {
                    screen = window.screen;
                    break;
                }
            }
            if (screen) break;
        }
        
        if (!screen) {
            screen = NSScreen.mainScreen;
        }
    });
    return screen;
}
#endif

@end 