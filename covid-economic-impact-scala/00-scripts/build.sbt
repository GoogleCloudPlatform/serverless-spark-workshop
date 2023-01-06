scalaVersion := "2.12.17"

name := "covid-economic-impact-assessment"
organization := "org.teksystems"
version := "1.0"

libraryDependencies ++= Seq(
  "org.scala-lang" % "scala-library" % scalaVersion.value % "provided",
  "org.apache.spark" %% "spark-core" % "3.2.3" % "provided",
  "org.apache.spark" %% "spark-sql" % "3.2.3" % "provided"

)
