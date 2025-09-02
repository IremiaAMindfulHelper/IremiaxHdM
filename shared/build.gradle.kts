import org.jetbrains.kotlin.gradle.ExperimentalKotlinGradlePluginApi
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("org.jetbrains.kotlin.multiplatform")
    id("com.android.library")
    id("org.jetbrains.kotlin.native.cocoapods")
    id("app.cash.sqldelight")
}

kotlin {
    androidTarget {
        @OptIn(ExperimentalKotlinGradlePluginApi::class)
        compilerOptions { jvmTarget.set(JvmTarget.JVM_11) }
    }

    // iOS Targets
    iosArm64()
    iosSimulatorArm64()
    // iosX64() // nur falls Intel-Simulatoren benötigt werden

    // <- WICHTIG: cocoapods{} MUSS innerhalb von kotlin{} stehen
    cocoapods {
        version = "0.1.0"
        summary = "Shared Kotlin Multiplatform module"
        homepage = "https://iremia.app"
        authors = "Iremia a Mindful Helper"
        license = "MIT"
        ios.deploymentTarget = "14.0"
        framework {
            baseName = "Shared"
            isStatic = true
        }
        // Beispiel für zusätzliche Pods:
        // pod("Reachability", "~> 3.2")
    }

    sourceSets {
        val commonMain by getting
        val commonTest by getting {
            dependencies { implementation(kotlin("test")) }
        }

        val iosMain by creating { dependsOn(commonMain) }
        val iosArm64Main by getting { dependsOn(iosMain) }
        val iosSimulatorArm64Main by getting { dependsOn(iosMain) }

        // iOS SQLDelight-Driver bei Bedarf:
        // iosMain.dependencies {
        //     implementation("app.cash.sqldelight:native-driver:2.1.0")
        // }
    }
}

android {
    namespace = "org.iremia.iremia.shared"
    compileSdk = 34
    defaultConfig { minSdk = 24 }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

sqldelight {
    databases {
        create("UserData") {
            packageName.set("com.iremia")
        }
    }
}