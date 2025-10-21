import org.jetbrains.kotlin.gradle.ExperimentalKotlinGradlePluginApi
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.plugin.mpp.KotlinNativeTarget
import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework
import org.gradle.internal.os.OperatingSystem

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

    iosArm64()
    iosSimulatorArm64()
    val xcf = XCFramework()

    targets.withType(KotlinNativeTarget::class.java).configureEach {
        binaries.framework {
            baseName = "Shared"
            isStatic = true
            xcf.add(this)   // wichtig: erzeugt die assemble*XCFramework Tasks auf macOS
        }
    }

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
            // nutze deine Versionen aus der libs.versions.toml
            export("dev.icerock.moko:resources:${libs.versions.resources.get()}")
            export("dev.icerock.moko:graphics:${libs.versions.graphics.get()}")
        }
        // Beispiel:
        // pod("Reachability", "~> 3.2")
    }

    sourceSets {
        val commonMain by getting {
            dependencies {
                api(libs.resources)
                api(libs.graphics)
            }
        }
        val commonTest by getting {
            dependencies {
                implementation(kotlin("test"))
                implementation(libs.resources.test)
            }
        }

        val iosMain by creating {
            dependsOn(commonMain)
        }
        val iosArm64Main by getting { dependsOn(iosMain) }
        val iosSimulatorArm64Main by getting { dependsOn(iosMain) }
    }
}

android {
    namespace = "org.iremia.iremia.shared"
    compileSdk = libs.versions.android.compileSdk.get().toInt()
    defaultConfig { minSdk = libs.versions.android.minSdk.get().toInt() }
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
    resourcesPackage.set("org.iremia.library") // Package für MR
    resourcesClassName.set("SharedRes")        // optional
    iosBaseLocalizationRegion.set("en")
    iosMinimalDeploymentTarget.set("14.0")
}

if (OperatingSystem.current().isMacOsX) {
    multiplatformResources {
        configureCopyXCFrameworkResources("Shared")
    }
}