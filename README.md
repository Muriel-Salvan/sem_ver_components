[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

# sem_ver_components - Apply and maintain semantic versioning to your package's components

A set of tools helping you track, automatically compute and maintain easily semantic versioning at components level.

## Description

Need to **track semantic versioning on different public APIs** of your project?
**Fed up with impacting all your clients when you bump** your project's major version, only because 1 API has been broken, used by only half of them?

Then `sem_ver_components` is for you.

**[Semantic versioning](https://semver.org/) is great**:
* It gives your clients an idea of the **risks they take in upgrading** their dependency on your project.
* It is clearly defined and gives you **ways to automate your project's versioning**.
* It allows your clients to **easily benefit from non-breaking bug fixes and features** without manually bumping their dependencies' versions (thanks to clever operators like `~>`).
* It makes projects **version their interfaces** instead of their implementation.
* closes the gap between feature-detection and version-detection.

However, most of the projects have **several API parts** (like a user and admin interfaces, a CLI and an API, an API for users and another for plugins developers...) and those APIs are often **bundled together in a single package, with a single version**.

If you apply semantic versioning correctly, you have to bump major version everytime 1 of your APIs breaks. However this bump will impact the dependencies' definitions of all the clients that use your package for the other APIs as well. You basically ask them to bump the major version of their dependency without any change on the API part they are using. They will also stop benefitting from patches automatically, unless you take the burden to retrofit any patch on as many release branches as major versions you keep alive. In short: it does not scale.

The underlying issue here is that semantic versioning makes you version your interfaces (technical and functional), as they are what is being used by your clients. A project always has several interfaces, and purists might argue that every public method is an interface that would need its own semantic versioning.
Getting the right balance in choosing which interfaces can be grouped in the same semantic version is at the discretion of every project.

What `sem_ver_components` is helping you for:
* **Track those components semantic versions**, based on git commits.
* **Link those components semantic versions to the package global version** (as we still need 1 final version to be packaged and released).
* Help you **know which dependencies version is still compatible with your components semantic version** (as the `~>` operators still work on the global package version, and not the components one - we would need operators like `my_dep(component) ~> x.y.z`).
* **Generate clever changelogs** per component, so that your clients know exactly which changelog is relevant to them.

## Example

Let's take a `bakery` library that offers clients to buy bread using a public `buy_bread` method.
Let's imagine this library can use locales plugins (externally packaged). Let's say the `bakery` library uses the public method `translate` in any of the locales plugins to get a sentence translate into a given language.

Our `bakery` library has 2 contractual interfaces:
* 1 public API for customers, so that they can buy bread using the `buy_bread` method - The `customers` component
* 1 API call to any locale plugin, using the `translate` method - The `plugins` component

Now imagine we have this commit log:

```
* [Feature(customers)] Make buy_bread accept even moare bread!
* [Perf(customers)] More efficient buying process
* [Break(plugins)] Rename back to translate
* [Break(plugins)] Rename translate into translate_sentence
* [Fix] Typo
* [Feature(customers)] Make buy_bread accept more bread
* Initial commit - v1.0.0
```

If we were to semantic release every commit, this is the different semantic versions we should have:

```
+--------------------------------------------------------------+-------------------+-----------------+------------------------+
| Commit                                                       | customers version | plugins version | Global package version |
+--------------------------------------------------------------+-------------------+-----------------+------------------------+
| [Feature(customers)] Make buy_bread accept even moare bread! | 1.2.0             | 3.0.2           | 3.1.0                  |
| [Perf(customers)] More efficient buying process              | 1.1.4             | 3.0.1           | 3.0.1                  |
| [Break(plugins)] Rename back to translate                    | 1.1.3             | 3.0.0           | 3.0.0                  |
| [Break(plugins)] Rename translate into translate_sentence    | 1.1.2             | 2.0.0           | 2.0.0                  |
| [Fix] Typo                                                   | 1.1.1             | 1.0.2           | 1.1.1                  |
| [Feature(customers)] Make buy_bread accept more bread        | 1.1.0             | 1.0.1           | 1.1.0                  |
| Initial commit - v1.0.0                                      | 1.0.0             | 1.0.0           | 1.0.0                  |
+--------------------------------------------------------------+-------------------+-----------------+------------------------+
```

With this information:
* As a customer of the v1.0.0 `bakery` library I know that I can automatically use `bakery` up to v3.1.0 without breaking the interface I was using.
* As a locale plugin developer for the v1.0.0 `bakery` library I know that I will have an impact on the API I'm using starting at version 2.0.0.

## Requirements

`sem_ver_components` only needs [Ruby](https://www.ruby-lang.org/) to run.

Its interface is then command-line only.

## Install

Via gem

``` bash
$ gem install sem_ver_components
```

If using `bundler`, add this in your `Gemfile`:

``` ruby
gem 'sem_ver_components'
```

## Usage

### `sem_ver_git`

`sem_ver_git` is a command-line tool analyzing commit messages from a local git repository and displaying bump levels to be applied on components.

```
Usage: sem_ver_git [options]
    -f, --from GIT_REF               Git reference from which commits are to be analyzed (defaults to first commit)
    -h, --help                       Display this help
    -o, --output OUTPUT              Specify the output format of the analysis. Possible values are info, semantic_release_analyze, semantic_release_generate_notes (defauts to info)
    -r, --repo GIT_URL               Specify the Git URL of the repository to analyze (defaults to .)
    -t, --to GIT_REF                 Git reference to which commits are to be analyzed (defaults to HEAD)
    -v, --version                    Display version
```

## Change log

Please see [CHANGELOG](CHANGELOG.md) for more information on what has changed recently.

## Contributing

Any contribution is welcome:
* Fork the github project and create pull requests.
* Report bugs by creating tickets.
* Suggest improvements and new features by creating tickets.

## Credits

- [Muriel Salvan][link-author]

## License

The BSD License. Please see [License File](LICENSE.md) for more information.
