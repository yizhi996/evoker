//
//  Network.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import SystemConfiguration.CaptiveNetwork
import CoreTelephony

public enum NetworkType: String {
    case unknown
    case none
    case wifi
    case v2 = "2g"
    case v3 = "3g"
    case v4 = "4g"
    case v5 = "5g"
}

class Network {
    
    class func getIPAddress() -> String {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }

                guard let interface = ptr?.pointee else { return "" }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                    // wifi = ["en0"]
                    // wired = ["en2", "en3", "en4"]
                    // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]

                    let name: String = String(cString: (interface.ifa_name))
                    if  name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address ?? ""
    }
    
    class func fetchSSIDInfo() ->  String? {
        guard let interfaces:CFArray = CNCopySupportedInterfaces() else { return nil }
        var currentSSID: String?
        for i in 0..<CFArrayGetCount(interfaces){
            let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
            let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
            let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
            if let interfaceData = unsafeInterfaceData as? Dictionary<String, Any> {
                for (key, value) in interfaceData {
                    if key == "SSID" {
                        currentSSID = value as? String
                        if currentSSID != nil {
                            break
                        }
                    }
                }
            }
        }
        return currentSSID
    }
    
    class func isWiFiOn() -> Bool {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr!.pointee.ifa_next }
                let interface = ptr!.pointee
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    let name = String(cString: interface.ifa_name)
                    if name == "awdl0" {
                        return (Int32(interface.ifa_flags) & IFF_UP) == IFF_UP
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return false
    }
    
    class func getCellularType() -> NetworkType {
        let info = CTTelephonyNetworkInfo()
        var currentType = ""
        if #available(iOS 12.0, *) {
            currentType = info.serviceCurrentRadioAccessTechnology?.first?.value ?? ""
        } else {
            currentType = info.currentRadioAccessTechnology ?? ""
        }
        if #available(iOS 14.1, *) {
            switch currentType {
            case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
                return .v2
            case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA, CTRadioAccessTechnologyCDMAEVDORev0, CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB, CTRadioAccessTechnologyeHRPD:
                return .v3
            case CTRadioAccessTechnologyLTE:
                return .v4
            case CTRadioAccessTechnologyNRNSA, CTRadioAccessTechnologyNR:
                return .v5
            default:
                return .unknown
            }
        } else {
            switch currentType {
            case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
                return .v2
            case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA, CTRadioAccessTechnologyCDMAEVDORev0, CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB, CTRadioAccessTechnologyeHRPD:
                return .v3
            case CTRadioAccessTechnologyLTE:
                return .v4
            default:
                return .unknown
            }
        }
    }
}
