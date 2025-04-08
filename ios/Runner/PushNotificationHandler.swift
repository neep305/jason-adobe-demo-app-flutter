//
//  PushNotificationHandler.swift
//  Runner
//
//  Created by Jason Nam on 4/4/25.
//

import Foundation
import AEPCampaignClassic

enum TrackType {
    case receive, click
}

func handleTrackNotification(call: FlutterMethodCall, type: TrackType) -> [String: Any]? {
    guard
        let args = call.arguments as? [String: Any],
        let data = args["data"] as? [String: Any]
    else {
        print("❌ 잘못된 트래킹 payload")
        return nil
    }

    var trackingInfo: [String: Any] = [:]
    if let mid = data["_mId"] {
        trackingInfo["_mId"] = mid
    }
    if let did = data["_dId"] {
        trackingInfo["_dId"] = did
    }

    switch type {
    case .receive:
        CampaignClassic.trackNotificationReceive(withUserInfo: trackingInfo)
        print("✅ trackNotificationReceive 호출됨 with: \(trackingInfo)")
        
        return trackingInfo
    case .click:
        CampaignClassic.trackNotificationClick(withUserInfo: trackingInfo)
        print("✅ trackNotificationClick 호출됨 with: \(trackingInfo)")
        
        return trackingInfo
    }
}
