//
//  AppDelegate.swift
//  MachumCafe
//
//  Created by Febrix on 2017. 4. 25..
//  Copyright © 2017년 Febrix. All rights reserved.
//
// TODO: 카카오톡 로그인 연동 리팩토링! ! !

import UIKit
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var googleMapKey = Config.googleMapKey
    var locationManager = CLLocationManager()
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
        [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey(googleMapKey)
        GMSPlacesClient.provideAPIKey(googleMapKey)
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        let backButtonImage = #imageLiteral(resourceName: "back_Bt").stretchableImage(withLeftCapWidth: 13, topCapHeight: 22)
        UINavigationBar.appearance().backIndicatorImage = backButtonImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backButtonImage
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor(red: 51, green: 51, blue: 51)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 255, green: 232, blue: 129)]
        
        UINavigationBar.appearance().isTranslucent = false
        
        // MARK: 카톡 로그인 세션 있을 경우 유저정보 Get, 없을경우 우리 서버에서 유저정보 Get, 둘다 세션 없을경우 nil
        let session = KOSession.shared()
        // 카톡 세션 있을 시 유저 정보 모델 저장
        if (session?.isOpen())! {
            KOSessionTask.meTask(completionHandler: { (profile, error) in
                if let userProfile = profile {
                    let user = userProfile as! KOUser
                    let email = user.email!
                    
                    NetworkUser.kakaoLogin(email: email, nickname: String(), imageURL: String()) { (result, user) in
                        User.sharedInstance.user = user
                        User.sharedInstance.isUser = true
                    }
                }
            })
        } else {
            // 카톡 유저 아닐 경우 우리 서버에서 세션 확인 후 모델 저장
            NetworkUser.getUser { (result, user) in
                if result {
                    User.sharedInstance.user = user
                    User.sharedInstance.isUser = true
                }
            }
        }
        KOSession.shared().isAutomaticPeriodicRefresh = true

        return true
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        if KOSession.isKakaoAccountLoginCallback(url) {
            return KOSession.handleOpen(url)
        }
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if KOSession.isKakaoAccountLoginCallback(url) {
            return KOSession.handleOpen(url)
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        KOSession.handleDidEnterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        KOSession.handleDidBecomeActive()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }


    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // machumCafe://host/cafe/:id
        let cafeDetailViewController = UIStoryboard.CafeDetailViewStoryboard.instantiateViewController(withIdentifier: "CafeDetail") as! CafeDetailViewController
        
        getCafeInfo(id: url.pathComponents, target: cafeDetailViewController) {
            self.pushSpecificCafeDetailView(target: cafeDetailViewController)
        }
        
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func pushSpecificCafeDetailView(target: CafeDetailViewController) {
        let mainViewController = UIStoryboard.MainViewStoryboard.instantiateViewController(withIdentifier: "Main")
        let mainNavigationViewController = UINavigationController(rootViewController: mainViewController)
        self.window?.rootViewController = mainNavigationViewController
        mainNavigationViewController.pushViewController(target, animated: true)
    }
    
    func getCafeInfo(id: [String], target: CafeDetailViewController, callback: @escaping () -> Void) {
        NetworkCafe.getSpecificCafe(cafeId: id[2]){ (modelCafe) in
            Cafe.sharedInstance.specificCafe = modelCafe
            target.currentCafeModel = Cafe.sharedInstance.specificCafe
            callback()
        }
    }

    // When location Updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        let location = manager.location?.coordinate
        if let currentLocation = location {
            Location.sharedInstance.currentLocation = ModelLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        }
    }
}
