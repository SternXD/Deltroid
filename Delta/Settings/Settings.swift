//
//  Settings.swift
//  Delta
//
//  Created by Riley Testut on 8/23/15.
//  Copyright © 2015 Riley Testut. All rights reserved.
//

import Foundation

import DeltaCore
import Features
import MelonDSDeltaCore

import Roxas

extension Settings.NotificationUserInfoKey
{
    static let system: Settings.NotificationUserInfoKey = "system"
    static let traits: Settings.NotificationUserInfoKey = "traits"
    static let core: Settings.NotificationUserInfoKey = "core"
}

extension Settings.Name
{
    static let localControllerPlayerIndex: Settings.Name = "localControllerPlayerIndex"
    static let translucentControllerSkinOpacity: Settings.Name = "translucentControllerSkinOpacity"
    static let preferredControllerSkin: Settings.Name = "preferredControllerSkin"
    static let syncingService: Settings.Name = "syncingService"
    static let isAltJITEnabled: Settings.Name = "isAltJITEnabled"
    static let respectSilentMode: Settings.Name = "respectSilentMode"
    static let autoLoadSave: Settings.Name = "autoLoadSave"
    static let gameArtworkSize: Settings.Name = "gameArtworkSize"
    static let themeColor: Settings.Name = "themeColor"
    static let playOverOtherMedia: Settings.Name = "playOverOtherMedia"
    static let gameVolume: Settings.Name = "gameVolume"
    static let isUnsafeFastForwardSpeedsEnabled: Settings.Name = "isUnsafeFastForwardSpeedsEnabled"
    static let isPromptSpeedEnabled: Settings.Name = "isPromptSpeedEnabled"
    static let fastForwardSpeed: Settings.Name = "fastForwardSpeed"
    static let isRewindEnabled: Settings.Name = "isRewindEnabled"
    static let rewindTimerInterval: Settings.Name = "rewindTimerInterval"
    static let isAltRepresentationsAvailable: Settings.Name = "isAltRepresentationsAvailable"
    static let isAltRepresentationsEnabled: Settings.Name = "isAltRepresentationsEnabled"
    static let isAlwaysShowControllerSkinEnabled: Settings.Name = "isAlwaysShowControllerSkinEnabled"
    static let isDebugModeEnabled: Settings.Name = "isDebugModeEnabled"
    static let isSkinDebugModeEnabled: Settings.Name = "isSkinDebugModeEnabled"
    static let skinDebugDevice: Settings.Name = "skinDebugDevice"
    static let screenshotSaveToPhotos: Settings.Name = "screenshotSaveToPhotos"
    static let screenshotSaveToFiles: Settings.Name = "screenshotSaveToFiles"
    static let screenshotImageScale: Settings.Name = "screenshotImageScale"
}

extension Settings
{
    enum GameShortcutsMode: String
    {
        case recent
        case manual
    }
    
    enum ThemeColor: String
    {
        case orange
        case purple
        case blue
        case red
        case green
        case teal
        case pink
        case yellow
        case mint
    }
    
    enum ArtworkSize: String
    {
        case small
        case medium
        case large
    }
    
    enum ScreenshotScale: Double, CaseIterable
    {
        case x1 = 1
        case x2 = 2
        case x3 = 3
        case x4 = 4
        case x5 = 5
    }
    
    enum SkinDebugDevice: String
    {
        case standard
        case edgeToEdge
        case ipad
        case splitView
    }
    
    typealias Name = SettingsName
    typealias NotificationUserInfoKey = SettingsUserInfoKey
    
    static let didChangeNotification = Notification.Name.settingsDidChange
}

struct Settings
{
    static func registerDefaults()
    {
        let defaults = [#keyPath(UserDefaults.lastUpdateShown): 1,
                        #keyPath(UserDefaults.themeColor): ThemeColor.orange.rawValue,
                        #keyPath(UserDefaults.gameArtworkSize): ArtworkSize.medium.rawValue,
                        #keyPath(UserDefaults.translucentControllerSkinOpacity): 0.7,
                        #keyPath(UserDefaults.gameShortcutsMode): GameShortcutsMode.recent.rawValue,
                        #keyPath(UserDefaults.sortSaveStatesByOldestFirst): false,
                        #keyPath(UserDefaults.isPreviewsEnabled): true,
                        #keyPath(UserDefaults.isAltJITEnabled): false,
                        #keyPath(UserDefaults.autoLoadSave): true,
                        #keyPath(UserDefaults.respectSilentMode): true,
                        #keyPath(UserDefaults.playOverOtherMedia): true,
                        #keyPath(UserDefaults.gameVolume): 1.0,
                        #keyPath(UserDefaults.screenshotSaveToFiles): true,
                        #keyPath(UserDefaults.screenshotSaveToPhotos): false,
                        #keyPath(UserDefaults.screenshotImageScale): ScreenshotScale.x1.rawValue,
                        #keyPath(UserDefaults.isRewindEnabled): false,
                        #keyPath(UserDefaults.rewindTimerInterval): 15,
                        #keyPath(UserDefaults.isUnsafeFastForwardSpeedsEnabled): false,
                        #keyPath(UserDefaults.isPromptSpeedEnabled): true,
                        #keyPath(UserDefaults.fastForwardSpeed): 4.0,
                        #keyPath(UserDefaults.isUseAltRepresentationsEnabled): false,
                        #keyPath(UserDefaults.isAltRepresentationsAvailable): false,
                        #keyPath(UserDefaults.isAlwaysShowControllerSkinEnabled): false,
                        #keyPath(UserDefaults.isDebugModeEnabled): false,
                        #keyPath(UserDefaults.isSkinDebugModeEnabled): false,
                        #keyPath(UserDefaults.skinDebugDevice): SkinDebugDevice.edgeToEdge.rawValue,
                        Settings.preferredCoreSettingsKey(for: .ds): MelonDS.core.identifier] as [String : Any]
        UserDefaults.standard.register(defaults: defaults)
    }
}

extension Settings
{
    /// Update
    static var lastUpdateShown: Int {
        set { UserDefaults.standard.lastUpdateShown = newValue }
        get { return UserDefaults.standard.lastUpdateShown }
    }
    
    /// Theme
    static var themeColor: ThemeColor {
        set {
            UserDefaults.standard.themeColor = newValue.rawValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.themeColor])
        }
        get {
            let theme = ThemeColor(rawValue: UserDefaults.standard.themeColor) ?? .orange
            return theme
        }
    }
    
    /// Artwork
    static var gameArtworkSize: ArtworkSize {
        set {
            UserDefaults.standard.gameArtworkSize = newValue.rawValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.gameArtworkSize])
        }
        get {
            let size = ArtworkSize(rawValue: UserDefaults.standard.gameArtworkSize) ?? .medium
            return size
        }
    }
    
    /// Controllers
    static var localControllerPlayerIndex: Int? = 0 {
        didSet {
            guard self.localControllerPlayerIndex != oldValue else { return }
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.localControllerPlayerIndex])
        }
    }
    
    static var translucentControllerSkinOpacity: CGFloat {
        set {
            guard newValue != self.translucentControllerSkinOpacity else { return }
            UserDefaults.standard.translucentControllerSkinOpacity = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.translucentControllerSkinOpacity])
        }
        get { return UserDefaults.standard.translucentControllerSkinOpacity }
    }
    
    static var previousGameCollection: GameCollection? {
        set { UserDefaults.standard.previousGameCollectionIdentifier = newValue?.identifier }
        get {
            guard let identifier = UserDefaults.standard.previousGameCollectionIdentifier else { return nil }
            
            let predicate = NSPredicate(format: "%K == %@", #keyPath(GameCollection.identifier), identifier)
            
            let gameCollection = GameCollection.instancesWithPredicate(predicate, inManagedObjectContext: DatabaseManager.shared.viewContext, type: GameCollection.self)
            return gameCollection.first
        }
    }
    
    static var gameShortcutsMode: GameShortcutsMode {
        set { UserDefaults.standard.gameShortcutsMode = newValue.rawValue }
        get {
            let mode = GameShortcutsMode(rawValue: UserDefaults.standard.gameShortcutsMode) ?? .recent
            return mode
        }
    }
    
    static var gameShortcuts: [Game] {
        set {
            let identifiers = newValue.map { $0.identifier }
            UserDefaults.standard.gameShortcutIdentifiers = identifiers
            
            let shortcuts = newValue.map { UIApplicationShortcutItem(localizedTitle: $0.name, action: .launchGame(identifier: $0.identifier)) }
            
            DispatchQueue.main.async {
                UIApplication.shared.shortcutItems = shortcuts
            }
        }
        get {
            let identifiers = UserDefaults.standard.gameShortcutIdentifiers
            
            do
            {
                let fetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "%K IN %@", #keyPath(Game.identifier), identifiers)
                fetchRequest.returnsObjectsAsFaults = false
                
                let games = try DatabaseManager.shared.viewContext.fetch(fetchRequest).sorted(by: { (game1, game2) -> Bool in
                    let index1 = identifiers.firstIndex(of: game1.identifier)!
                    let index2 = identifiers.firstIndex(of: game2.identifier)!
                    return index1 < index2
                })
                
                return games
            }
            catch
            {
                print(error)
            }
            
            return []
        }
    }
    
    static var syncingService: SyncManager.Service? {
        get {
            guard let syncingService = UserDefaults.standard.syncingService else { return nil }
            return SyncManager.Service(rawValue: syncingService)
        }
        set {
            UserDefaults.standard.syncingService = newValue?.rawValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.syncingService])
        }
    }
    
    static var sortSaveStatesByOldestFirst: Bool {
        set { UserDefaults.standard.sortSaveStatesByOldestFirst = newValue }
        get {
            let sortByOldestFirst = UserDefaults.standard.sortSaveStatesByOldestFirst
            return sortByOldestFirst
        }
    }
    
    static var isPreviewsEnabled: Bool {
        set {
            UserDefaults.standard.isPreviewsEnabled = newValue
        }
        get {
            let isPreviewsEnabled = UserDefaults.standard.isPreviewsEnabled
            return isPreviewsEnabled
        }
    }
    
    static var isAltJITEnabled: Bool {
        get {
            let isAltJITEnabled = UserDefaults.standard.isAltJITEnabled
            return isAltJITEnabled
        }
        set {
            UserDefaults.standard.isAltJITEnabled = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isAltJITEnabled])
        }
    }
    
    static var autoLoadSave: Bool {
        get {
            let autoLoadSave = UserDefaults.standard.autoLoadSave
            return autoLoadSave
        }
        set {
            UserDefaults.standard.autoLoadSave = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.autoLoadSave])
        }
    }
    
    static var respectSilentMode: Bool {
        get {
            let respectSilentMode = UserDefaults.standard.respectSilentMode
            return respectSilentMode
        }
        set {
            UserDefaults.standard.respectSilentMode = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.respectSilentMode])
        }
    }
    
    static var playOverOtherMedia: Bool {
        get {
            let playOverOtherMedia = UserDefaults.standard.playOverOtherMedia
            return playOverOtherMedia
        }
        set {
            UserDefaults.standard.playOverOtherMedia = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.playOverOtherMedia])
        }
    }
    
    static var gameVolume: CGFloat {
        set {
            guard newValue != self.gameVolume else { return }
            UserDefaults.standard.gameVolume = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.gameVolume])
        }
        get { return UserDefaults.standard.gameVolume }
    }
    
    static var isRewindEnabled: Bool {
        set {
            UserDefaults.standard.isRewindEnabled = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isRewindEnabled])
        }
        get {
            let isRewindEnabled = UserDefaults.standard.isRewindEnabled
            return isRewindEnabled
        }
    }
    
    static var rewindTimerInterval: Int {
        set {
            UserDefaults.standard.rewindTimerInterval = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.rewindTimerInterval])
        }
        get {
            let rewindTimerInterval = UserDefaults.standard.rewindTimerInterval
            return rewindTimerInterval
        }
    }
    
    static var isUnsafeFastForwardSpeedsEnabled: Bool {
        set {
            UserDefaults.standard.isUnsafeFastForwardSpeedsEnabled = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isUnsafeFastForwardSpeedsEnabled])
        }
        get {
            let isUnsafeFastForwardSpeedsEnabled = UserDefaults.standard.isUnsafeFastForwardSpeedsEnabled
            return isUnsafeFastForwardSpeedsEnabled
        }
    }
    
    static var isPromptSpeedEnabled: Bool {
        set {
            UserDefaults.standard.isPromptSpeedEnabled = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isPromptSpeedEnabled])
        }
        get {
            let isSpeedPromptEnabled = UserDefaults.standard.isPromptSpeedEnabled
            return isSpeedPromptEnabled
        }
    }
    
    static var fastForwardSpeed: CGFloat {
        set {
            UserDefaults.standard.fastForwardSpeed = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.fastForwardSpeed])
        }
        get {
            let fastForwardSpeed = UserDefaults.standard.fastForwardSpeed
            return fastForwardSpeed
        }
    }
    
    static var isAltRepresentationsEnabled: Bool {
        set {
            UserDefaults.standard.isUseAltRepresentationsEnabled = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isAltRepresentationsEnabled])
        }
        get {
            let isUseAltRepresentationsEnabled = UserDefaults.standard.isUseAltRepresentationsEnabled
            return isUseAltRepresentationsEnabled
        }
    }
    
    static var isAltRepresentationsAvailable: Bool {
        set {
            UserDefaults.standard.isAltRepresentationsAvailable = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isAltRepresentationsAvailable])
        }
        get {
            let isAltRepresentationsAvailable = UserDefaults.standard.isAltRepresentationsAvailable
            return isAltRepresentationsAvailable
        }
    }
    
    static var isAlwaysShowControllerSkinEnabled: Bool {
        set {
            UserDefaults.standard.isAlwaysShowControllerSkinEnabled = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isAlwaysShowControllerSkinEnabled])
        }
        get {
            let isAlwaysShowControllerSkinEnabled = UserDefaults.standard.isAlwaysShowControllerSkinEnabled
            return isAlwaysShowControllerSkinEnabled
        }
    }
    
    static var isDebugModeEnabled: Bool {
        set {
            UserDefaults.standard.isDebugModeEnabled = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isDebugModeEnabled])
        }
        get {
            let isDebugModeEnabled = UserDefaults.standard.isDebugModeEnabled
            return isDebugModeEnabled
        }
    }
    
    static var isSkinDebugModeEnabled: Bool {
        set {
            UserDefaults.standard.isSkinDebugModeEnabled = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.isSkinDebugModeEnabled])
        }
        get {
            let isSkinDebugModeEnabled = UserDefaults.standard.isSkinDebugModeEnabled
            return isSkinDebugModeEnabled
        }
    }
    
    static var skinDebugDevice: SkinDebugDevice {
        set {
            UserDefaults.standard.skinDebugDevice = newValue.rawValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.skinDebugDevice])
        }
        get {
            let device = SkinDebugDevice(rawValue: UserDefaults.standard.skinDebugDevice) ?? .edgeToEdge
            return device
        }
    }
    
    static var screenshotSaveToFiles: Bool {
        get {
            let isEnabled = UserDefaults.standard.screenshotSaveToFiles
            return isEnabled
        }
        set {
            UserDefaults.standard.screenshotSaveToFiles = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.screenshotSaveToFiles])
        }
    }
    
    static var screenshotSaveToPhotos: Bool {
        get {
            let isEnabled = UserDefaults.standard.screenshotSaveToPhotos
            return isEnabled
        }
        set {
            UserDefaults.standard.screenshotSaveToPhotos = newValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.screenshotSaveToPhotos])
        }
    }
    
    static var screenshotImageScale: ScreenshotScale {
        set {
            UserDefaults.standard.screenshotImageScale = newValue.rawValue
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: Name.screenshotImageScale])
        }
        get {
            let size = ScreenshotScale(rawValue: UserDefaults.standard.screenshotImageScale) ?? .x1
            return size
        }
    }
    
    static func preferredCore(for gameType: GameType) -> DeltaCoreProtocol?
    {
        let key = self.preferredCoreSettingsKey(for: gameType)
        
        let identifier = UserDefaults.standard.string(forKey: key)
        
        let core = System.allCores.first { $0.identifier == identifier }
        return core
    }
    
    static func setPreferredCore(_ core: DeltaCoreProtocol, for gameType: GameType)
    {
        Delta.register(core)
        
        let key = self.preferredCoreSettingsKey(for: gameType)
        
        UserDefaults.standard.set(core.identifier, forKey: key)
        NotificationCenter.default.post(name: Settings.didChangeNotification, object: nil, userInfo: [NotificationUserInfoKey.name: key, NotificationUserInfoKey.core: core])
    }
    
    static func preferredControllerSkin(for system: System, traits: DeltaCore.ControllerSkin.Traits) -> ControllerSkin?
    {
        guard let userDefaultsKey = self.preferredControllerSkinKey(for: system, traits: traits) else { return nil }
        
        let identifier = UserDefaults.standard.string(forKey: userDefaultsKey)
        
        do
        {
            // Attempt to load preferred controller skin if it exists
            
            let fetchRequest: NSFetchRequest<ControllerSkin> = ControllerSkin.fetchRequest()
            
            if let identifier = identifier
            {
                fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(ControllerSkin.gameType), system.gameType.rawValue, #keyPath(ControllerSkin.identifier), identifier)
                
                if let controllerSkin = try DatabaseManager.shared.viewContext.fetch(fetchRequest).first
                {
                    return controllerSkin
                }
            }
            
            // Controller skin doesn't exist, so fall back to standard controller skin
            
            fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K == YES", #keyPath(ControllerSkin.gameType), system.gameType.rawValue, #keyPath(ControllerSkin.isStandard))
            
            if let controllerSkin = try DatabaseManager.shared.viewContext.fetch(fetchRequest).first
            {
                Settings.setPreferredControllerSkin(controllerSkin, for: system, traits: traits)
                return controllerSkin
            }
        }
        catch
        {
            print(error)
        }
        
        return nil
    }
    
    static func setPreferredControllerSkin(_ controllerSkin: ControllerSkin?, for system: System, traits: DeltaCore.ControllerSkin.Traits)
    {
        guard let userDefaultKey = self.preferredControllerSkinKey(for: system, traits: traits) else { return }
        
        guard UserDefaults.standard.string(forKey: userDefaultKey) != controllerSkin?.identifier else { return }
        
        UserDefaults.standard.set(controllerSkin?.identifier, forKey: userDefaultKey)
        
        NotificationCenter.default.post(name: Settings.didChangeNotification, object: controllerSkin, userInfo: [NotificationUserInfoKey.name: Name.preferredControllerSkin, NotificationUserInfoKey.system: system, NotificationUserInfoKey.traits: traits])
    }
    
    static func preferredControllerSkin(for game: Game, traits: DeltaCore.ControllerSkin.Traits) -> ControllerSkin?
    {
        let preferredControllerSkin: ControllerSkin?
        
        switch traits.orientation
        {
        case .portrait: preferredControllerSkin = game.preferredPortraitSkin
        case .landscape: preferredControllerSkin = game.preferredLandscapeSkin
        }
        
        let alt = Settings.isAltRepresentationsEnabled
        if let controllerSkin = preferredControllerSkin, let _ = controllerSkin.supportedTraits(for: traits, alt: alt)
        {
            // Check if there are supported traits, which includes fallback traits for X <-> non-X devices.
            return controllerSkin
        }
        
        if let system = System(gameType: game.type)
        {
            // Fall back to using preferred controller skin for the system.
            let controllerSkin = Settings.preferredControllerSkin(for: system, traits: traits)
            return controllerSkin
        }
                
        return nil
    }
    
    static func setPreferredControllerSkin(_ controllerSkin: ControllerSkin?, for game: Game, traits: DeltaCore.ControllerSkin.Traits)
    {
        let context = DatabaseManager.shared.newBackgroundContext()
        context.performAndWait {
            let game = context.object(with: game.objectID) as! Game
            
            let skin: ControllerSkin?
            if let controllerSkin = controllerSkin, let contextSkin = context.object(with: controllerSkin.objectID) as? ControllerSkin
            {
                skin = contextSkin
            }
            else
            {
                skin = nil
            }            
            
            switch traits.orientation
            {
            case .portrait: game.preferredPortraitSkin = skin
            case .landscape: game.preferredLandscapeSkin = skin
            }
            
            context.saveWithErrorLogging()
        }
        
        game.managedObjectContext?.refresh(game, mergeChanges: false)
        
        if let system = System(gameType: game.type)
        {
            NotificationCenter.default.post(name: Settings.didChangeNotification, object: controllerSkin, userInfo: [NotificationUserInfoKey.name: Name.preferredControllerSkin, NotificationUserInfoKey.system: system, NotificationUserInfoKey.traits: traits])
        }
    }
}

extension Settings
{
    static func preferredCoreSettingsKey(for gameType: GameType) -> String
    {
        let key = "core." + gameType.rawValue
        return key
    }
}

private extension Settings
{
    static func preferredControllerSkinKey(for system: System, traits: DeltaCore.ControllerSkin.Traits) -> String?
    {
        let systemName: String
        
        switch system
        {
        case .nes: systemName = "nes"
        case .snes: systemName = "snes"
        case .gbc: systemName = "gbc"
        case .gba: systemName = "gba"
        case .n64: systemName = "n64"
        case .ds: systemName = "ds"
        case .genesis: systemName = "genesis"
        }
        
        let orientation: String
        
        switch traits.orientation
        {
        case .portrait: orientation = "portrait"
        case .landscape: orientation = "landscape"
        }
        
        let displayType: String
        
        switch traits.displayType
        {
        case .standard: displayType = "standard"
        case .edgeToEdge: displayType = "standard" // In this context, standard and edge-to-edge skins are treated the same.
        case .splitView: displayType = "splitview"
        }
        
        let key = systemName + "-" + orientation + "-" + displayType + "-controller"
        return key
    }
}

private extension UserDefaults
{
    @NSManaged var lastUpdateShown: Int
    
    @NSManaged var themeColor: String
    @NSManaged var gameArtworkSize: String
    
    @NSManaged var translucentControllerSkinOpacity: CGFloat
    @NSManaged var previousGameCollectionIdentifier: String?
    
    @NSManaged var gameShortcutsMode: String
    @NSManaged var gameShortcutIdentifiers: [String]
    
    @NSManaged var syncingService: String?
    
    @NSManaged var sortSaveStatesByOldestFirst: Bool
    
    @NSManaged var isPreviewsEnabled: Bool
    
    @NSManaged var isAltJITEnabled: Bool
    
    @NSManaged var autoLoadSave: Bool
    
    @NSManaged var respectSilentMode: Bool
    @NSManaged var playOverOtherMedia: Bool
    @NSManaged var gameVolume: CGFloat
    
    @NSManaged var isRewindEnabled: Bool
    @NSManaged var rewindTimerInterval: Int
    
    @NSManaged var isUnsafeFastForwardSpeedsEnabled: Bool
    @NSManaged var isPromptSpeedEnabled: Bool
    @NSManaged var fastForwardSpeed: CGFloat
    
    @NSManaged var isUseAltRepresentationsEnabled: Bool
    @NSManaged var isAltRepresentationsAvailable: Bool
    @NSManaged var isAlwaysShowControllerSkinEnabled: Bool
    
    @NSManaged var isDebugModeEnabled: Bool
    @NSManaged var isSkinDebugModeEnabled: Bool
    @NSManaged var skinDebugDevice: String
    
    @NSManaged var screenshotSaveToFiles: Bool
    @NSManaged var screenshotSaveToPhotos: Bool
    @NSManaged var screenshotImageScale: CGFloat
}
