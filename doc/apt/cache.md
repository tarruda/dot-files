## apt-cacher-ng setup

Install the package:

```sh
sudo apt-get install apt-cacher-ng
```

While apt-cacher-ng is a proxy, it can also act as an apt mirror, which is the
best way to use it since it requires no client configuration(except configuring
the mirror in sources.list, of course), and is transparent to tools like
`debootstrap`.

By default, apt-cacher-ng configuration(/etc/apt-cacher-ng/acng.conf) should
have a line like this:

```sh
Remap-uburep: file:ubuntu_mirrors /ubuntu ; file:backends_ubuntu # Ubuntu Archives
```

The `file:ubuntu_mirrors /ubuntu` section is saying that repositories listed in the
`ubuntu_mirrors` file(same directory as acnf.conf) plus the local
repository(`/ubuntu`) should all have the same cache, which will live under the
`uburep` subdirectory under apt-cache-ng cache directory.

The second part(`; file:backends_ubuntu`) is saying that any requests to
`uburep` that miss the cache will be redirected to the repositories listed in
the `backends_ubuntu` file. While this file can have multiple entries, it is
best to leave only one entry for a nearby mirror.

The second part is optional, in which case apt-cacher-ng will simply merge the
cache of all repositories listed in `ubuntu_mirrors`.

For `backends_ubuntu`, a nearby amazon s3 mirror is recommended(s3 tends to be
fast):

```
http://us-east-1.clouds.archive.ubuntu.com/ubuntu/
http://us-west-1.clouds.archive.ubuntu.com/ubuntu/
http://us-west-2.clouds.archive.ubuntu.com/ubuntu/
http://sa-east-1.clouds.archive.ubuntu.com/ubuntu/
http://eu-west-1.clouds.archive.ubuntu.com/ubuntu/
http://eu-west-1.clouds.archive.ubuntu.com/ubuntu/
http://eu-central-1.clouds.archive.ubuntu.com/ubuntu/
http://eu-central-1.clouds.archive.ubuntu.com/ubuntu/
http://ap-southeast-1.clouds.archive.ubuntu.com/ubuntu/
http://ap-northeast-1.clouds.archive.ubuntu.com/ubuntu/
```
