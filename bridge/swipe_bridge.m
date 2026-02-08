#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Cocoa/Cocoa.h>

#include <stdint.h>
#include <stdio.h>

typedef void (*swipe_sample_cb)(int32_t touch_count, float avg_x, float avg_y, double timestamp);

static swipe_sample_cb g_callback = NULL;
static CFMachPortRef g_tap = NULL;
static CFRunLoopSourceRef g_source = NULL;

int check_accessibility_permission(int prompt)
{
    @autoreleasepool {
        if (prompt) {
            NSDictionary* options = @{(__bridge id)kAXTrustedCheckOptionPrompt : @YES};
            if (AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options)) {
                return 0;
            }
            fprintf(stderr, "accessibility permission not granted\n");
            return 2;
        }

        if (AXIsProcessTrusted()) {
            return 0;
        }

        fprintf(stderr, "accessibility permission not granted\n");
        return 2;
    }
}

static CGEventRef handle_event(__unused CGEventTapProxy proxy, CGEventType type, CGEventRef event, __unused void* ref)
{
    if (type == kCGEventTapDisabledByTimeout || type == kCGEventTapDisabledByUserInput) {
        if (g_tap)
            CGEventTapEnable(g_tap, true);
        return event;
    }

    if (type != (CGEventType)NSEventTypeGesture)
        return event;

    if (!g_callback)
        return event;

    NSEvent* ev = [NSEvent eventWithCGEvent:event];
    NSSet<NSTouch*>* touches = [ev allTouches];
    if (!touches || touches.count == 0)
        return event;

    float sum_x = 0.0f;
    float sum_y = 0.0f;
    int32_t count = 0;

    for (NSTouch* touch in touches) {
        CGPoint p = [touch normalizedPosition];
        sum_x += p.x;
        sum_y += p.y;
        count += 1;
    }

    if (count > 0) {
        g_callback(count, sum_x / (float)count, sum_y / (float)count, CFAbsoluteTimeGetCurrent());
    }

    return event;
}

int run_swipe_event_loop(int prompt, swipe_sample_cb callback)
{
    @autoreleasepool {
        g_callback = callback;

        int access_rc = check_accessibility_permission(prompt);
        if (access_rc != 0)
            return access_rc;

        CGEventMask mask = 1 << NSEventTypeGesture;
        g_tap = CGEventTapCreate(kCGHIDEventTap,
            kCGHeadInsertEventTap,
            kCGEventTapOptionListenOnly,
            mask,
            handle_event,
            NULL);

        if (!g_tap) {
            fprintf(stderr, "failed to create event tap\n");
            return 3;
        }

        g_source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, g_tap, 0);
        if (!g_source) {
            fprintf(stderr, "failed to create runloop source\n");
            CFRelease(g_tap);
            g_tap = NULL;
            return 4;
        }

        CFRunLoopAddSource(CFRunLoopGetMain(), g_source, kCFRunLoopCommonModes);
        CGEventTapEnable(g_tap, true);
        CFRunLoopRun();
    }

    return 0;
}
