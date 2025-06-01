plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // This line is correct
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.emotifai.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.emotifai.app"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// --- ADD THIS DEPENDENCIES BLOCK ---
dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.14.0"))
    // Firebase Auth
    implementation("com.google.firebase:firebase-auth")
    // Google Sign-In for Authentication
    implementation("com.google.android.gms:play-services-auth:21.1.0")
    // (Optional) Add more Firebase dependencies as needed
    // implementation("com.google.firebase:firebase-analytics")
}
