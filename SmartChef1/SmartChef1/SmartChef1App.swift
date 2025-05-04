import SwiftUI
import Firebase


@main
struct SmartChef1App: App {
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
