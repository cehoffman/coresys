# Coresys

Compiled package management installed as a gem.

Coresys is heavily inspired by Homebrew but wants to work on the normal linux
box and not completely isolate itself from the system libraries. I usually
don't want to install packaged versions of my development dependencies because
they are either out of date, missing a feature I want, or install extra cruft
on my linux system that doesn't go away with an uninstall. Thus Coresys follows
the symlink method to link packages into a central environment.

Coresys also follows a similar package definition to Homebrew formula because
they work very well for quickly putting together a package for a source
package you might want to start fooling around with.

Probably the largest difference between the setup of Coresys and Homebrew is
how formula distribution is handled. Right now formula not shipped with the
main coresys gem, but instead kept inside a configured path like
`~/.coresys/formula` so the user might take their own approach to versioning
the formula how they see fit. One possible way this could be used is for
formula to be stored with or as a submodule to a person's main dotfiles. Then
to have the same environment on any system it would be a simple case of
fetching your dotfiles, installing coresys, and using coresys to install any
desired packages.

## Installation

And then execute:

    gem install coresys

## Usage

Right now configuraiton is pretty much non existent and expects packages to
be installed into `~/.local` and for formula to reside inside
`~/.coresys/formula`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
