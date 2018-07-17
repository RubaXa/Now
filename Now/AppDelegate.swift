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
        
        let getWeekOfDayForQ = {(date: Date, q: Int, start: Bool) -> DateComponents in
            var dc = self.calendar.dateComponents([.year, .month, .day], from: date)
            
            dc.month = q * 3 + (start ? -2 : 1);
            dc.day = start ? 1 : -1;
            
            let nd = self.calendar.date(from: dc)!;
            var res = self.calendar.dateComponents([.weekOfYear, .weekday, .year, .month, .day], from: nd)
            let wd = res.weekday!
            
            res.weekOfYear = res.weekOfYear! + (start
                ? (wd != 2 ? 1 : 0)
                : (wd == 2 && wd == 3 ? -1 : 0)
            );
            
            return res;
        };
        
        getters = [
            {(date: Date) -> String in
                let n = self.calendar.component(.weekOfYear, from: date)
                let m = self.calendar.component(.month, from: date)
                let q = Int(ceil(Float(m) / 3.0));
                return String(n) + " (Q" + String(q) + ")"
            },
            
            {(date: Date) -> String in
                let c = self.calendar.dateComponents([.weekOfYear, .month], from: date)
                let q = Int(ceil(Float(c.month!) / 3.0));
                
                let start = getWeekOfDayForQ(date, q, true);
                let startDate = self.calendar.date(from: start)!;
                
                let end = getWeekOfDayForQ(date, q, false);
                let endDate = self.calendar.date(from: end)!;
                
                let allDays = self.calendar.dateComponents([.day], from: startDate, to: endDate)
                let endDiff = self.calendar.dateComponents([.day], from: date, to: endDate)
                let used = Float(allDays.day! - endDiff.day!)/Float(allDays.day!)

                return "Days left: " + String(endDiff.day!) + " (" + String(end.weekOfYear! - c.weekOfYear!) + " weeks, ~" + String(round(used * 100)) + "%)";
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
