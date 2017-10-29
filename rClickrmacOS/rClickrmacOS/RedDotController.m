//
//  AppDelegate.m
//  fix
//
//  Created by Numeric on 10/29/17.
//  Copyright © 2017 Numeric. All rights reserved.
//

#import "RedDotController.h"
#import "ProjectionOverlayViewController.h"
#import <Carbon/Carbon.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/graphics/IOGraphicsLib.h>
#include <IOKit/i2c/IOI2CInterface.h>

@interface RedDotController ()
@property (nonatomic, strong) ProjectionOverlayViewController *vc;
//@property (nonatomic, strong) NSDistributedNotificationCenter *center;

@end

@implementation RedDotController

- (void)blackoutSwitch {
    NSRect mainScreenRect = [[NSScreen mainScreen] frame];
    self.vc.blackOutView.frame = mainScreenRect;
    if (self.vc.blackOutView.layer.opacity < 1) {
        self.vc.blackOutView.layer.opacity = 1;
    } else {
        self.vc.blackOutView.layer.opacity = 0;
    }
}

- (void)updateRedDot:(NSDictionary *)dict {
    float x_coord = [((NSNumber *)dict[@"x"]) floatValue];
    float y_coord = [((NSNumber *)dict[@"y"]) floatValue];
    
    NSRect mainScreenRect = [[NSScreen mainScreen] frame];
    CGFloat wStart = mainScreenRect.size.width * x_coord;
    CGFloat hStart = mainScreenRect.size.height * y_coord;
    
    if (self.vc != nil) {
        NSRect newFrame = CGRectMake(wStart, hStart, self.vc.redDotView.frame.size.width, self.vc.redDotView.frame.size.height);
        self.vc.redDotView.frame = newFrame;
        [self.vc.redDotView setNeedsDisplay: YES];
    }
}

- (void)gotRedDot:(NSNotification *)notif {
    NSLog(@"should move red dot %@", notif.userInfo);
    NSDictionary *dict = notif.userInfo;
    float x_coord = [((NSNumber *)dict[@"x"]) floatValue];
    float y_coord = [((NSNumber *)dict[@"y"]) floatValue];

    NSRect mainScreenRect = [[NSScreen mainScreen] frame];
    CGFloat wStart = mainScreenRect.size.width * x_coord;
    CGFloat hStart = mainScreenRect.size.height * y_coord;
    
    if (self.vc != nil) {
        NSRect newFrame = CGRectMake(wStart, hStart, self.vc.redDotView.frame.size.width, self.vc.redDotView.frame.size.height);
        self.vc.redDotView.frame = newFrame;
        [self.vc.redDotView setNeedsDisplay: YES];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"shouldMoveRedDot" object:nil];
}


- (void)configurateEverything {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(gotRedDot:) name:@"shouldMoveRedDot" object:nil];
    
    //    [ws launchApplication:@"OtherApp.app"];
    
    NSRect mainScreenRect = [[NSScreen mainScreen] frame];
    NSPanel *test_panel = [[NSPanel alloc] initWithContentRect:mainScreenRect styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable backing:NSBackingStoreBuffered defer:YES];

//    NSPanel *test_panel = [[NSPanel alloc] initWithContentRect:NSMakeRect(300, 300, 500, 500) styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable backing:NSBackingStoreBuffered defer:YES];
    test_panel.backgroundColor = [NSColor clearColor];
    test_panel.hasShadow = NO;
    [test_panel setReleasedWhenClosed:YES];
    [test_panel setHidesOnDeactivate:NO];
    [test_panel setFloatingPanel:YES];
    [test_panel setStyleMask:NSWindowStyleMaskBorderless | NSWindowStyleMaskNonactivatingPanel];
    [test_panel setLevel:kCGMainMenuWindowLevel-1];
    [test_panel  setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorFullScreenAuxiliary];
    //    [test_panel setCanBeVisibleOnAllSpaces:YES];
    [test_panel center];
    [test_panel orderFront:nil];
    
    self.vc = [[ProjectionOverlayViewController alloc] initWithNibName:@"ProjectionOverlayViewController" bundle:nil];
    self.vc.view.frame = mainScreenRect;
//    tf.stringValue = @"dfsakjfdsaiufsadfas";
    test_panel.contentViewController = self.vc;

    // Insert code here to initialize your application
}

static io_connect_t get_event_driver(void)
{
    static  mach_port_t sEventDrvrRef = 0;
    mach_port_t masterPort, service, iter;
    kern_return_t    kr;
    
    if (!sEventDrvrRef)
    {
        kr = IOMasterPort( bootstrap_port, &masterPort );
        kr = IOServiceGetMatchingServices( masterPort, IOServiceMatching( kIOHIDSystemClass ), &iter );
        service = IOIteratorNext( iter );
        kr = IOServiceOpen( service, mach_task_self(),
                           kIOHIDParamConnectType, &sEventDrvrRef );
        IOObjectRelease( service );
        IOObjectRelease( iter );
    }
    return sEventDrvrRef;
}

static void HIDPostAuxKey( const UInt8 auxKeyCode )
{
    NXEventData   event;
    kern_return_t kr;
    IOGPoint      loc = { 0, 0 };
    
    // Key press event
    UInt32      evtInfo = auxKeyCode << 16 | NX_KEYDOWN << 8;
    bzero(&event, sizeof(NXEventData));
    event.compound.subType = NX_SUBTYPE_AUX_CONTROL_BUTTONS;
    event.compound.misc.L[0] = evtInfo;
    kr = IOHIDPostEvent( get_event_driver(), NX_SYSDEFINED, loc, &event, kNXEventDataVersion, 0, FALSE );
    
    // Key release event
    evtInfo = auxKeyCode << 16 | NX_KEYUP << 8;
    bzero(&event, sizeof(NXEventData));
    event.compound.subType = NX_SUBTYPE_AUX_CONTROL_BUTTONS;
    event.compound.misc.L[0] = evtInfo;
    kr = IOHIDPostEvent( get_event_driver(), NX_SYSDEFINED, loc, &event, kNXEventDataVersion, 0, FALSE );
}

- (void)decreaseVolume {
    HIDPostAuxKey(NX_KEYTYPE_SOUND_DOWN);
}

- (void)increaseVolume {
    HIDPostAuxKey(NX_KEYTYPE_SOUND_UP);
}

- (void)muteVolume {
    HIDPostAuxKey(NX_KEYTYPE_MUTE);
}
@end
