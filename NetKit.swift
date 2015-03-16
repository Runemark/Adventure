//
//  NetKit.swift
//  NanoChat
//
//  Created by Martin Mumford on 3/4/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
import MultipeerConnectivity

// Minimum Possible Networking to start advertising
// This version of NetKit automatically broadcasts and advertises with a single service type, and automatically conncets to all and any peers
// This will not be acceptable in more robust, general versions of NetKit

enum BrowsingStatus
{
    case browser_browsing, browser_stopped
}

enum AdvertisingStatus
{
    case advertiser_advertising, advertiser_stopped
}

public protocol NetKitDelegate {
    
    // Not needed right now, discovery happens automagically. All peers are auto-conencted
    func peerDiscovered(peerIDString:String)
    func peerRequestFrom(peerIDString:String)
    
    func peerConnecting(peerIDString:String)
    func peerConnected(peerIDString:String)
    func peerDisconnected(peerIDString:String)
    
    func receivedDataFromPeer(peerIDString:String, dataString:String)
}

class NetKit: NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate
{
    var serviceAdvertiser:MCNearbyServiceAdvertiser?
    var serviceBrowser:MCNearbyServiceBrowser?
    var session:MCSession
    var myPeerID:MCPeerID
    var browsingStatus:BrowsingStatus
    var advertisingStatus:AdvertisingStatus
    
    var peers:[String:MCPeerID]
    
    var delegate:NetKitDelegate?
    
    init(displayName:String)
    {
        self.myPeerID = MCPeerID(displayName:displayName)
        self.session = MCSession(peer:myPeerID)
        
        self.browsingStatus = .browser_stopped
        self.advertisingStatus = .advertiser_stopped
        
        self.peers = [String:MCPeerID]()
        
        super.init()
        
        self.session.delegate = self
    }
    
    func setDelegate(delegate:NetKitDelegate)
    {
        self.delegate = delegate
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Communication
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func sendToAllPeers(dataString:String)
    {
        if (session.connectedPeers.count > 0)
        {
            let data = dataString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion:false)
            session.sendData(data, toPeers:session.connectedPeers, withMode:MCSessionSendDataMode.Unreliable, error:nil)
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Information
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func peerAlreadyConnected(peerID:MCPeerID) -> Bool
    {
        var alreadyConnected = false
        
        for connectedPeer:MCPeerID in connectedPeerIDs()
        {
            if (connectedPeer == peerID)
            {
                alreadyConnected = true
                break
            }
        }
        
        return alreadyConnected
    }
    
    func connectedPeerIDs() -> [MCPeerID]
    {
        var peerIDs = [MCPeerID]()
        
        for peerID in session.connectedPeers
        {
            peerIDs.append(peerID as MCPeerID)
        }
        
        return peerIDs
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Service Control
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func disconnect()
    {
        if advertisingStatus == .advertiser_advertising
        {
            stopAdvertising()
        }
        
        if browsingStatus == .browser_browsing
        {
            stopBrowsing()
        }
        
        session.delegate = nil
        session.disconnect()
    }
    
    //////////////////////////////////////////////////
    // Transceiving Control (Simulatneously Advertise and Browse)
    //////////////////////////////////////////////////
    
    func startTransceiving(#serviceType:String)
    {
        println("Start Transceiving")
        
        startAdvertising(serviceType:serviceType)
        startBrowsing(serviceType:serviceType)
    }
    
    func resumeTransceiving()
    {
        println("Resume Transceiving")
        
        resumeAdvertising()
        resumeBrowsing()
    }
    
    func pauseTransceiving()
    {
        println("Pause Transceiving")
        
        pauseAdvertising()
        pauseBrowsing()
    }
    
    func stopTransceiving()
    {
        println("Stop Transceiving")
        
        stopAdvertising()
        stopBrowsing()
    }
    
    //////////////////////////////////////////////////
    // Advertising Control
    //////////////////////////////////////////////////
    
    func startAdvertising(#serviceType:String)
    {
        println("Start Advertising")
        
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer:myPeerID, discoveryInfo:nil, serviceType:serviceType)
        serviceAdvertiser?.delegate = self;
        
        advertisingStatus = .advertiser_advertising
        serviceAdvertiser?.startAdvertisingPeer()
    }
    
    func resumeAdvertising()
    {
        println("Resume Advertising")
        
        advertisingStatus = .advertiser_advertising
        serviceAdvertiser?.startAdvertisingPeer()
    }
    
    func pauseAdvertising()
    {
        println("Pause Advertising")
        
        advertisingStatus = .advertiser_stopped
        serviceAdvertiser?.stopAdvertisingPeer()
    }
    
    func stopAdvertising()
    {
        println("Stop Advertising")
        
        serviceAdvertiser?.delegate = nil
        
        advertisingStatus = .advertiser_stopped
        serviceAdvertiser?.stopAdvertisingPeer()
    }
    
    //////////////////////////////////////////////////
    // Browsing Control
    //////////////////////////////////////////////////
    
    func startBrowsing(#serviceType:String)
    {
        println("Start Browsing")
        
        serviceBrowser = MCNearbyServiceBrowser(peer:myPeerID, serviceType:serviceType)
        serviceBrowser?.delegate = self;
        
        browsingStatus = .browser_browsing
        serviceBrowser?.startBrowsingForPeers()
    }
    
    func resumeBrowsing()
    {
        println("Resume Browsing")
        
        browsingStatus = .browser_browsing
        serviceBrowser?.startBrowsingForPeers()
    }
    
    func pauseBrowsing()
    {
        println("Pause Browsing")
        
        browsingStatus = .browser_stopped
        serviceBrowser?.stopBrowsingForPeers()
    }
    
    func stopBrowsing()
    {
        println("Stop Browsing")
        
        serviceBrowser?.delegate = nil
        
        browsingStatus = .browser_stopped
        serviceBrowser?.stopBrowsingForPeers()
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Utility
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func peerIDToString(peerID:MCPeerID) -> String
    {
        return peerID.displayName
    }
    
    func peerIDWithDisplayName(displayName:String) -> MCPeerID?
    {
        return peers[displayName]
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Events
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //////////////////////////////////////////////////
    // MCNearbyServiceAdvertiserDelegate
    //////////////////////////////////////////////////
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!) {
        
        println("AdvertiserDelegate:didNotStartAdvertisingPeer error:\(error)")
        
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        
        println("AdvertiserDelegate:didReceiveInvitationFromPeer:\(peerID)")
        
        if (!peerAlreadyConnected(peerID))
        {
            // Makes the connection
            invitationHandler(true, session);
        }
    }
    
    //////////////////////////////////////////////////
    // MCNearbyServiceBrowserDelegate
    //////////////////////////////////////////////////
    
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        
        println("BrowserDelegate:didNotStartBrowserPeer error:\(error)")
        
    }
    
    func browser(browser:MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        
        println("BrowserDelegate:foundPeer peerID:\(peerID)")
        
        // Automatically invite every peer you see
        serviceBrowser?.invitePeer(peerID, toSession:session, withContext:nil, timeout:30)
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        
        println("BrowserDelegate:lostPeer peerID:\(peerID)")
        
    }
    
    //////////////////////////////////////////////////
    // MCNearbyServiceBrowserDelegate
    //////////////////////////////////////////////////
    
    // MCSessionState: {0:MCSessionStateNotConected, 1:MCSessionStateConnecting, 2:MCSessionStateConnected}
    // A (0) MCSessionStateNotConnected change occurs when a client disconnects, or when a browser's invitation times out
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState)
    {
        println("Session:peer:\(peerID) didChangeState:\(state.rawValue)")
        
        let peerIDString:String = peerIDToString(peerID)
        
        switch state
        {
        case MCSessionState.Connected:
            delegate?.peerConnected(peerIDString)
        case MCSessionState.Connecting:
            delegate?.peerConnecting(peerIDString)
        case MCSessionState.NotConnected:
            delegate?.peerDisconnected(peerIDString)
        default:
            println("Nothing to see here...")
            break
        }
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!)
    {
        delegate?.receivedDataFromPeer(peerID.displayName, dataString:NSString(data:data, encoding:NSUTF8StringEncoding)!)
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!)
    {
        println("Session:didStartReceivingResourceWithName: \(resourceName) fromPeer: \(peerID)")
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!)
    {
        println("Session:didFinishReceivingResourceWithName: \(resourceName) fromPeer: \(peerID)")
    }
    
    func session(session: MCSession!, didReceiveCertificate certificate: [AnyObject]!, fromPeer peerID: MCPeerID!, certificateHandler: ((Bool) -> Void)!)
    {
        println("Session:didReceiveCertificate fromPeer: \(peerID)")
        // Even though this method is listed as optional in the docs, if you leave it blank your peers CANNOT CONNECT. Great work there, Apple.
        certificateHandler(true)
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!)
    {
        println("Session:didReceiveStream withName: \(streamName) fromPeer: \(peerID)")
        // Unused
    }
    
}
