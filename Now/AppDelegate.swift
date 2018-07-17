//
//  AppDelegate.swift
//  Now
//
//  Created by Konstantin Lebedev on 16/07/2018.
//  Copyright © 2018 Konstantin Lebedev. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!
    
    private let pasteboard = NSPasteboard.general
    private let calendar = Calendar.current
    private let formatter = DateFormatter()
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var timer: Timer?
    private var getters: Array<(Date) -> String> = [];
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.menu = menu;
        nextTick();
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(nextTick), userInfo: nil, repeats: true);
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
        
        getters = [
            {(date: Date) -> String in
                let n = self.calendar.component(.weekOfYear, from: date)
                let m = self.calendar.component(.month, from: date)
                let q = Int(ceil(Float(m) / 3.0));
                return String(n) + " (Q" + String(q) + ")"
            },
            {(_: Date) -> String in
                return "-";
            },

            {(date: Date) -> String in
                self.formatter.dateFormat = "HH:mm"
                return self.formatter.string(from: date);
            },

            {(date: Date) -> String in
                self.formatter.dateFormat = "dd.MM.yyyy"
                return self.formatter.string(from: date);
            },

            {(date: Date) -> String in
                self.formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
                return self.formatter.string(from: date);
            },
            
            {(_: Date) -> String in
                return "-";
            },
            
            {(date: Date) -> String in
                self.formatter.dateFormat = "EEEE (dd)"
                return self.formatter.string(from: date);
            },

            {(date: Date) -> String in
                self.formatter.dateFormat = "LLLL (MM)"
                return self.formatter.string(from: date);
            },

            {(date: Date) -> String in
                self.formatter.dateFormat = "yyyy"
                return self.formatter.string(from: date);
            },
        ];
        
        let date = Date()
        getters.forEach( { (fn) in
            let val = fn(date);
            let item: NSMenuItem = val == "-" ? NSMenuItem.separator() : NSMenuItem(title: val, action: #selector(itemClicked), keyEquivalent: "")
            menu.addItem(item)
        })
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Exit", action: #selector(quiteClicked), keyEquivalent: ""))
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    

    @objc func nextTick() {
        let date = Date()

        for (idx, fn) in getters.enumerated() {
            let value = fn(date);
            
            if value == "-" {
                continue
            }
            
            if idx == 0 {
                statusItem.title = value.components(separatedBy: " ")[0]
            }
            
            menu.items[idx].title = value
        }
    }
    
    func copy(value: String) {
        print("copy:", value);
        pasteboard.clearContents()
        pasteboard.setString(value, forType: NSPasteboard.PasteboardType.string)
    }

    @objc func itemClicked(_ sender: NSMenuItem) {
        copy(value: sender.title);
    }

    @objc func quiteClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }

}
