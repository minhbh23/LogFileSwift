//
//  CrashLogger.swift
//  TestLog
//
//  Created by Paraline App on 22/08/2023.
//

import Foundation
import UIKit

//--------------------------------------------------------------------------
// MARK: - CrashEyeDelegate
//--------------------------------------------------------------------------
public protocol CrashEyeDelegate: NSObjectProtocol {
    func crashEyeDidCatchCrash(with model: CrashModel)
}

//--------------------------------------------------------------------------
// MARK: - WeakCrashEyeDelegate
//--------------------------------------------------------------------------
class WeakCrashEyeDelegate: NSObject {
    weak var delegate: CrashEyeDelegate?
    
    init(delegate: CrashEyeDelegate) {
        super.init()
        self.delegate = delegate
    }
}

//--------------------------------------------------------------------------
// MARK: - CrashModelType
//--------------------------------------------------------------------------
public enum CrashModelType: Int {
    case signal = 1
    case exception = 2
}

//--------------------------------------------------------------------------
// MARK: - CrashModel
//--------------------------------------------------------------------------
open class CrashModel: NSObject {
    
    open var type: CrashModelType!
    open var name: String!
    open var reason: String!
    open var appinfo: String!
    open var callStack: String!
    
    init(type: CrashModelType,
         name: String,
         reason: String,
         appinfo: String,
         callStack: String) {
        super.init()
        self.type = type
        self.name = name
        self.reason = reason
        self.appinfo = appinfo
        self.callStack = callStack
    }
}

//--------------------------------------------------------------------------
// MARK: - GLOBAL VARIABLE
//--------------------------------------------------------------------------
private var app_old_exceptionHandler:(@convention(c) (NSException) -> Swift.Void)? = nil

//--------------------------------------------------------------------------
// MARK: - CrashEye
//--------------------------------------------------------------------------
public class CrashLoggerHandle: NSObject {
    
    //--------------------------------------------------------------------------
    // MARK: OPEN PROPERTY
    //--------------------------------------------------------------------------
    public private(set) static var isOpen: Bool = false

    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTY
    //--------------------------------------------------------------------------
    fileprivate static var delegates = [WeakCrashEyeDelegate]()

    //--------------------------------------------------------------------------
    // MARK: OPEN FUNCTION
    //--------------------------------------------------------------------------
    open class func add(delegate: CrashEyeDelegate) {
//        // delete null week delegate
//        self.delegates = self.delegates.filter {
//            return $0.delegate != nil
//        }
//
//        // judge if contains the delegate from parameter
//        let contains = self.delegates.contains {
//            return $0.delegate?.hash == delegate.hash
//        }
//        // if not contains, append it with weak wrapped
//        if contains == false {
//            let week = WeakCrashEyeDelegate(delegate: delegate)
//            self.delegates.append(week)
//        }
//
//        if self.delegates.count > 0 {
            self.open()
//        }
    }
    
    open class func remove(delegate: CrashEyeDelegate) {
        self.delegates = self.delegates.filter {
            // filter null weak delegate
            return $0.delegate != nil
        }.filter {
            // filter the delegate from parameter
            return $0.delegate?.hash != delegate.hash
        }
        
        if self.delegates.count == 0 {
            self.close()
        }
    }
    
    //--------------------------------------------------------------------------
    // MARK: PRIVATE FUNCTION
    //--------------------------------------------------------------------------
    private class func open() {
        guard self.isOpen == false else {
            return
        }
        CrashLoggerHandle.isOpen = true
        
        app_old_exceptionHandler = NSGetUncaughtExceptionHandler()
        NSSetUncaughtExceptionHandler(CrashLoggerHandle.RecieveException)
        self.setCrashSignalHandler()
    }
    
    private class func close() {
        guard self.isOpen == true else {
            return
        }
        CrashLoggerHandle.isOpen = false
        NSSetUncaughtExceptionHandler(app_old_exceptionHandler)
    }
    
    private class func setCrashSignalHandler(){
        signal(SIGABRT, CrashLoggerHandle.RecieveSignal)
        signal(SIGILL, CrashLoggerHandle.RecieveSignal)
        signal(SIGSEGV, CrashLoggerHandle.RecieveSignal)
        signal(SIGFPE, CrashLoggerHandle.RecieveSignal)
        signal(SIGBUS, CrashLoggerHandle.RecieveSignal)
        signal(SIGPIPE, CrashLoggerHandle.RecieveSignal)
        //http://stackoverflow.com/questions/36325140/how-to-catch-a-swift-crash-and-do-some-logging
        signal(SIGTRAP, CrashLoggerHandle.RecieveSignal)
    }
    
    private static let RecieveException: @convention(c) (NSException) -> Swift.Void = {
        (exteption) -> Void in
        if (app_old_exceptionHandler != nil) {
            app_old_exceptionHandler!(exteption);
        }
        
        guard CrashLoggerHandle.isOpen == true else {
            return
        }
        
        let callStack = exteption.callStackSymbols.joined(separator: "\r")
        let reason = exteption.reason ?? ""
        let name = exteption.name
        let appinfo = CrashLoggerHandle.appInfo()
        
        
        let model = CrashModel(type: CrashModelType.exception,
                               name: name.rawValue,
                               reason: reason,
                               appinfo: appinfo,
                               callStack: callStack)
        for delegate in CrashLoggerHandle.delegates {
            delegate.delegate?.crashEyeDidCatchCrash(with: model)
        }
    }
    
    private static let RecieveSignal: @convention(c) (Int32) -> Void = {
        (signal) -> Void in
        
        guard CrashLoggerHandle.isOpen == true else {
            return
        }
        
        var stack = Thread.callStackSymbols
        stack.removeFirst(2)
        let callStack = stack.joined(separator: "\r")
        let reason = "Signal \(CrashLoggerHandle.name(of: signal))(\(signal)) was raised.\n"
        let appinfo = CrashLoggerHandle.appInfo()
        
        let model = CrashModel(type: CrashModelType.signal,
                               name: CrashLoggerHandle.name(of: signal),
                               reason: reason,
                               appinfo: appinfo,
                               callStack: callStack)
        
        for delegate in CrashLoggerHandle.delegates {
            delegate.delegate?.crashEyeDidCatchCrash(with: model)
        }
        
        CrashLoggerHandle.killApp()
    }
    
    private class func appInfo() -> String {
        let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? ""
        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? ""
        let deviceModel = UIDevice.current.model
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        return "App: \(displayName) \(shortVersion)(\(version))\n" +
        "Device:\(deviceModel)\n" + "OS Version:\(systemName) \(systemVersion)"
    }
    
    
    private class func name(of signal: Int32) -> String {
        switch (signal) {
        case SIGABRT:
            return "SIGABRT"
        case SIGILL:
            return "SIGILL"
        case SIGSEGV:
            return "SIGSEGV"
        case SIGFPE:
            return "SIGFPE"
        case SIGBUS:
            return "SIGBUS"
        case SIGPIPE:
            return "SIGPIPE"
        default:
            return "OTHER"
        }
    }
    
    private class func killApp() {
        NSSetUncaughtExceptionHandler(nil)
        
        signal(SIGABRT, SIG_DFL)
        signal(SIGILL, SIG_DFL)
        signal(SIGSEGV, SIG_DFL)
        signal(SIGFPE, SIG_DFL)
        signal(SIGBUS, SIG_DFL)
        signal(SIGPIPE, SIG_DFL)
        
        kill(getpid(), SIGKILL)
    }
}
