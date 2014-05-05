//
//  Settings.h
//  Mail
//
//  Created by David Coninckx on 12.02.14.
//  Copyright (c) 2014 Informatique. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Settings : NSWindowController <NSTextViewDelegate, NSWindowDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSArrayController *arrayController;

@property (strong) NSArray *connectionType;

@property (weak) IBOutlet NSView *settingsView;

@end
