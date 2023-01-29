//
//  RegularApps.swift
//  Menu Bar Dock
//
//  Created by Ethan Sarif-Kattan on 12/04/2021.
//  Copyright © 2021 Ethan Sarif-Kattan. All rights reserved.
//

import Cocoa

protocol RegularAppsHideUserPrefsDataSource: AnyObject {
	var regularAppsHideUrls: [URL] { get }
}

class RegularAppsHide { // regular apps are just apps that use user added manually
	public var apps: [RegularApp]  = [] // order is correct

	weak var userPrefsDataSource: RegularAppsHideUserPrefsDataSource!

	init(
		userPrefsDataSource: RegularAppsHideUserPrefsDataSource
	) {
		self.userPrefsDataSource = userPrefsDataSource
		populateApps()
	}

	func update() {
		populateApps()
	}

	func handleAppActivation(runningApp: NSRunningApplication) {
		correspondingRegularApp(for: runningApp)?.runningApp = runningApp
		// we DON'T want to update here, because it doesn't make sense to update regular apps based on app activations, otherwise they would be RunningApp()s!
	}

	func handleAppQuit(runningApp: NSRunningApplication) {
		correspondingRegularApp(for: runningApp)?.runningApp = nil
	}

	private func correspondingRegularApp(for runningApp: NSRunningApplication) -> RegularApp? {
		return apps.first { $0.id == RunningApp(app: runningApp).id} // we just use RunningApp() just to get the id...kinda hacky
	}

	private func populateApps() {
		apps = []
        for url in userPrefsDataSource.regularAppsHideUrls {
			if let app = regularAppHide(for: url) {
				apps.append(app)
			}
		}
		addRunningAppsHide()
	}

	private func regularAppHide(for url: URL) -> RegularApp? {
		guard let bundle = Bundle(url: url) else { return nil }

		let icon = NSWorkspace.shared.icon(forFile: url.path)

		let app = RegularApp(
			bundle: bundle,
			icon: icon,
			name: bundle.name
		)

		return app
	}

	private func addRunningAppsHide() {
		let runningApps = NSWorkspace.shared.runningApplications
		for app in apps {
			app.runningApp = runningApps.first {RunningApp(app: $0).id == app.id} // we instantiate RunningApp just to get id. kinda hacky, but oh well.
		}
	}
}
