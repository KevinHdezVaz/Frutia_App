import UIKit
import Flutter
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configuración avanzada de AVAudioSession
    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(
        .playback,
        mode: .default,
        policy: .default,
        options: [.defaultToSpeaker, .allowBluetooth, .mixWithOthers]
      )
      try session.setActive(true, options: .notifyOthersOnDeactivation)
      try session.setPreferredSampleRate(44100)
      try session.setPreferredIOBufferDuration(0.005)
      print("✅ Configuración de AVAudioSession completada con éxito")
    } catch {
      print("❌ Error al configurar AVAudioSession: \(error.localizedDescription)")
    }

    // Registrar plugins de Flutter
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    return super.application(app, open: url, options: options)
  }
  
  // Configuración adicional para manejo de audio en segundo plano
  override func applicationWillResignActive(_ application: UIApplication) {
    do {
      try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    } catch {
      print("Error al desactivar AVAudioSession: \(error.localizedDescription)")
    }
  }
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
    do {
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("Error al reactivar AVAudioSession: \(error.localizedDescription)")
    }
  }
}