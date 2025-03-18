plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.kashpers.project_a"
    compileSdk = 36  // Add this line with your target SDK version
    
    signingConfigs {
        create("release") {
            // For now, leaving keystore details empty
            // You should fill these with your actual keystore information when ready
            // storeFile = file("your-release-key.keystore")
            // storePassword = "your-store-password"
            // keyAlias = "your-key-alias"
            // keyPassword = "your-key-password"
        }
    }

    defaultConfig {
        applicationId = "com.kashpers.project_a"
        minSdkVersion(21)
        targetSdkVersion(36)
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        getByName("release") {
            // Enables code shrinking, obfuscation, and optimization
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
    }
    
    // Add this to ensure compatibility with Flutter
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    
    kotlinOptions {
        jvmTarget = "1.8"
    }
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.10.0"))

    // TODO: Add the dependencies for Firebase products you want to use
    // When using the BoM, don't specify versions in Firebase dependencies
    implementation("com.google.firebase:firebase-analytics")

    // Add the dependencies for any other desired Firebase products
    // https://firebase.google.com/docs/android/setup#available-libraries
}
