---
title: DokGen
url: https://github.com/openrndr/dokgen
year: 2018
img: dokgen.jpg
stack: Kotlin, Gradle
---

A documentation engine that generates a static site out of annotated Kotlin
source code. [OPENRNDR](https://openrndr.org/){target="__blank"} has a fast-moving codebase with frequent releases, still searching for a stable
public API. New releases often introduce breaking changes which require an
update to our documentation. [Dokka](https://github.com/Kotlin/dokka){target="__blank"}, Kotlin's official documentation engine is a great tool for automatically
re-generating [our API docs](https://api.openrndr.org/){target="__blank"}, but the example code and tutorials we provide in
our [guide](https://guide.openrndr.org/#/){target="__blank"} could still easily get out of sync with new releases. We needed a solution which would statically verify the correctness of
code snippets in our guide, so that we could ensure they are is always compatible with
the latest OPENRNDR release. I developed DokGen, a Gradle plugin, which renders
annotated Kotlin sources into markdown documents and assembles a static site
using docsify. When DokGen is run, the sources are checked by the Kotlin compiler, so if they ever
use outdated APIs, the build fails and it becomes impossible to publish
incorrect docs. DokGen also allows us to provide graphic illustrations for
the code snippets so that we can visually demonstrate OPENRNDR functionality. More details about DokGen can be read in this [Medium article](https://medium.com/openrndr/improving-the-openrndr-guide-f98fba29c393){target="__blank"}
or on [GitHub](https://github.com/openrndr/dokgen){target="__blank"}.
