//
//  Settings.h
//  Mail
//
//  Created by David Coninckx on 12.02.14.
//  Copyright (c) 2014 Coninckx David. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/** Contrôleur de l'interface de paramétrage des comptes */
@interface Settings : NSWindowController <NSTextViewDelegate, NSWindowDelegate>

/** Vue listant les comptes dejà configuré */
@property (weak) IBOutlet NSTableView *tableView;

@property (strong) IBOutlet NSArrayController *arrayController;

/** Type de connexion utilisé pour un compte */
@property (strong) NSArray *connectionType;

/** Vue des paramètres pour un compte selectionné */
@property (weak) IBOutlet NSView *settingsView;

@end
