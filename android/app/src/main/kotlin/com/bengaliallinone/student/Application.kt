// package com.demoLogin.app
// import io.flutter.app.FlutterApplication
// import io.flutter.plugin.common.PluginRegistry
// import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
// import io.flutter.view.FlutterMain
// import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService;

// class Application : FlutterApplication(), PluginRegistrantCallback {

//   override fun onCreate() {
//     super.onCreate()
//     FlutterFirebaseMessagingBackgroundService.setPluginRegistrant(this);
//     FlutterMain.startInitialization(this)
//   }

//   override fun registerWith(registry: PluginRegistry?) {
//   }
// }


// package com.demoLogin.app

// import io.flutter.app.FlutterApplication
// import io.flutter.plugin.common.PluginRegistry

// import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin

// class Application() : FlutterApplication(), PluginRegistry.PluginRegistrantCallback {
//   override fun registerWith(registry: PluginRegistry?) {
//       val key: String? = FlutterFirebaseMessagingPlugin::class.java.canonicalName
//       if (!registry?.hasPlugin(key)!!) {
//           FlutterFirebaseMessagingPlugin.registerWith(registry?.registrarFor("io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin"));
//         }
//     }
// }