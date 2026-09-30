allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}
subprojects {
    val configureSubproject: Project.() -> Unit = {
        val applyCompileSdk = {
            val android = extensions.findByName("android")
            if (android != null) {
                try {
                    val compileSdkVersion = android.javaClass.getMethod("compileSdkVersion", java.lang.Integer.TYPE)
                    compileSdkVersion.invoke(android, 36)
                } catch (e: Exception) {}
            }
        }
        if (state.executed) {
            applyCompileSdk()
        } else {
            afterEvaluate {
                applyCompileSdk()
            }
        }
    }
    configureSubproject()
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
