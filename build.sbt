lazy val commonSettings = Seq(
  organization := "edu.berkeley.cs",
  version := "1.0",
  scalaVersion := "2.12.15",
  crossScalaVersions := Seq("2.12.15"),
  parallelExecution in Global := false,
  scalacOptions ++= Seq("-deprecation","-unchecked","-Xsource:2.11"),
  addCompilerPlugin("edu.berkeley.cs" % "chisel3-plugin" % "3.5.2" cross CrossVersion.full),
  libraryDependencies ++= Seq("edu.berkeley.cs" %% "chisel3" % "3.5.2"))

lazy val vivado = (project in file("."))
  .dependsOn(boom)
  .dependsOn(rocketchip)
  .dependsOn(sifive_cache)
  .dependsOn(gemmini)
  .settings(commonSettings)

lazy val rocketchip = (project in file("rocket-chip"))
  .settings(commonSettings)

lazy val testchipip = (project in file("generators/testchipip"))
  .dependsOn(rocketchip)
  .settings(commonSettings)
  .settings(includeFilter in unmanagedSources := { "Util.scala" || "TraceIO.scala" })

lazy val boom = (project in file("generators/riscv-boom"))
  .dependsOn(rocketchip)
  .dependsOn(testchipip)
  .settings(commonSettings)
  .settings(addCompilerPlugin("org.scalamacros" % "paradise" % "2.1.1" cross CrossVersion.full))

lazy val sifive_cache = (project in file("generators/sifive-cache"))
  .dependsOn(rocketchip)
  .settings(commonSettings)
  .settings(scalaSource in Compile := baseDirectory.value / "design/craft")

lazy val gemmini = (project in file("generators/gemmini"))
  .dependsOn(rocketchip)
  .dependsOn(testchipip)
  .dependsOn(targetutils)
  .settings(commonSettings)

lazy val targetutils = (project in file("generators/targetutils"))
  .settings(commonSettings)

