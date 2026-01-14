allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    afterEvaluate {
        // Find and configure the Android library extension
        project.extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)?.let {
            // If the namespace is not already set in the library's build.gradle
            if (it.namespace == null) {
                // Automatically generate a namespace from the project name
                // This is the key part that fixes the issue for packages like isar_flutter_libs
                it.namespace = "dev.isar.${project.name.replace("-", "_")}"
            }
        }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
