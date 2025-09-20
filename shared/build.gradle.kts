import org.jetbrains.kotlin.gradle.ExperimentalKotlinGradlePluginApi
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.plugin.mpp.KotlinNativeTarget
import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework

plugins {
    id("org.jetbrains.kotlin.multiplatform")
    id("com.android.library")
    id("org.jetbrains.kotlin.native.cocoapods")
    id("app.cash.sqldelight")
    id("dev.icerock.mobile.multiplatform-resources")
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
    val xcf = XCFramework()

    targets.withType(KotlinNativeTarget::class.java).configureEach {
        binaries.framework {
            baseName = "Shared"
            isStatic = true
            xcf.add(this)   // << wichtig: sonst fehlt assembleSharedDebugXCFramework
        }
    }
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
            export("dev.icerock.moko:resources:0.25.0")
            export("dev.icerock.moko:graphics:0.10.1")
        }
        // Beispiel für zusätzliche Pods:
        // pod("Reachability", "~> 3.2")
    }

    sourceSets {
        val commonMain by getting {
            dependencies {
                api("dev.icerock.moko:resources:0.25.0")
                api("dev.icerock.moko:graphics:0.10.1")

            }
        }
        val commonTest by getting {
            dependencies {
                implementation(kotlin("test"))
                implementation("dev.icerock.moko:resources-test:0.25.0")

            }
        }

        val iosMain by creating {
            dependsOn(commonMain)
        }
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

multiplatformResources {
    resourcesPackage.set("org.iremia.library") // <- dein Package für MR
    resourcesClassName.set("SharedRes") // optional
    iosBaseLocalizationRegion.set("en") // deine Base Sprache
    iosMinimalDeploymentTarget.set("14.0")
    configureCopyXCFrameworkResources("Shared")
}